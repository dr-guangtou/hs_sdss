; + 
; NAME:
;              HS_SPEC_INDEX_MEASURE
;
; PURPOSE:
;              Measure the value and error of certain spectral index 
;
; USAGE:
;    value=hs_spec_index_measure( wave, flux, index, error=error, snr=snr, $
;             /plot, eps_name=eps_name, /debug, /silent )
;              
; OUTPUT
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_SPEC
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_spec_index_measure, wave, flux, index, error=error, $ 
    snr=snr, plot=plot, eps_name=eps_name, debug=debug, $
    silent=silent 
    
    ;; Check the basic inputs 
    n_pix = n_elements( wave ) 
    if ( n_elements( flux ) NE n_pix ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The wavelength and flux array should have the same size ! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1
    endif else begin 
        min_wave = min( wave ) 
        max_wave = max( wave ) 
    endelse

    ;; Check the index structure
    if ( ( tag_indx( index, 'name' ) EQ -1 ) OR $
        ( tag_indx( index, 'lam0' ) EQ -1 ) OR $
        ( tag_indx( index, 'lam1' ) EQ -1 ) OR $ 
        ( tag_indx( index, 'red0' ) EQ -1 ) OR $ 
        ( tag_indx( index, 'red1' ) EQ -1 ) OR $ 
        ( tag_indx( index, 'blue0' ) EQ -1 ) OR $ 
        ( tag_indx( index, 'blue1' ) EQ -1 ) OR $ 
        ( tag_indx( index, 'type' ) EQ -1 ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The structure for the index is not compatible ! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1
    endif else begin 
        ;; Basic information about the index
        lam0  = index.lam0 
        lam1  = index.lam1
        blue0 = index.blue0 
        blue1 = index.blue1 
        red0  = index.red0 
        red1  = index.red1 
        type  = index.type 
        ;; Check if the wavelength definition is reasonable
        if ( type ne 2 ) then begin  
            if ( ( lam0 GE lam1 ) OR ( blue0 GE blue1 ) OR ( red0 GE red1 ) ) $
                then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, 'Something wrong with the wavelength definition ! Check!'
                print, index.name
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1
            endif
        endif
    endelse

    ;; Check the possible error array 
    if keyword_set( error ) then begin 
        if ( n_elements( error ) ne n_pix ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The wavelength and error array should have the same size !'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1
        endif 
    endif else begin 
        if keyword_set( snr ) then begin 
            if ( n_elements( snr ) EQ 1 ) then begin 
                snr_new = float( snr ) 
            endif else begin 
                if ( n_elements( snr ) EQ n_elements( flux ) ) then begin 
                    snr_new = snr 
                endif else begin 
                    if NOT keyword_set( silent ) then begin 
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    print, ' The SNR should be either a single value or '
                    print, '  array with the same number of pixels with '
                    print, '  flux array !! --> Use the median value instead !'
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    endif
                    snr_new = median( snr ) 
                endelse
            endelse
        endif else begin 
            snr_new = 500.0 
        endelse
        error = ( flux / 2000.0D ) 
        arm_addnoise, flux, error, snr_new, $
            signal_new=flux_new, noise_new=error_new
        error = error_new 
    endelse

    ;; Define the output for measured index 
    output = { name:index.name, value:0.0, error:0.0, type:type, $
        lam0:lam0, lam1:lam1, blue0:blue0, blue1:blue1, red0:red0, red1:red1 }

    if keyword_set( debug ) then begin 
        print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        print, ' INDEX : ' + index.name 
        print, '  BLUE : ', blue0, blue1
        print, '  BAND : ', lam0,  lam1 
        print, '   RED : ', red0,  red1 
        print, '  TYPE : ', type 
        print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    endif

    ;; If the index is Not covered by the wavelength range, return NaN
    if ( ( min_wave GT blue0 ) OR ( max_wave LT red1 ) ) then begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' * ' + index.name + ' is not covered ! '
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif
        output.value = !Values.F_NaN
        output.error = !Values.F_NaN
        return, output 
    endif 

    ;; Pre-interpolate the spectra 
    wave_inter = [ wave, lam0, lam1, blue0, blue1, red0, red1 ] 
    wave_inter = wave_inter[ uniq( wave_inter, sort( wave_inter ) ) ]
    index_inter = findex( wave, wave_inter ) 
    flux_inter  = interpolate( flux,  index_inter ) 
    error_inter = interpolate( error, index_inter ) 
    ;;  
    wave = wave_inter 
    flux = flux_inter 
    error = error_inter 
    ;; Normalize the flux and error
    flux_ori = flux 
    snr_ori = ( flux / error )

    ;; For the atomic and molecular index 
    if ( ( type EQ 0 ) OR ( type EQ 1 ) ) then begin 

        flux = ( flux / median( flux ) )
        error = ( flux / snr_ori )

        ;; Index 
        index_b = where( ( wave GE blue0 ) AND ( wave LE blue1 ) ) 
        index_r = where( ( wave GE red0  ) AND ( wave LE red1  ) ) 
        index_i = where( ( wave GE lam0  ) AND ( wave LE lam1  ) ) 
        ;; Width of the wavelength window 
        width_b = ( blue1 - blue0 ) 
        width_r = ( red1  - red0  ) 
        width_i = ( lam1  - lam0  )
        ;; The central wavelength of the red and blue pseudo-continuum region 
        center_b = ( ( blue0 + blue1 ) / 2.0 )
        center_r = ( ( red0  + red1  ) / 2.0 ) 
        center_i = ( ( lam0  + lam1  ) / 2.0 ) 
        ;; Array for wavelength step 
        dwave_b = ( wave[ index_b ] - wave[ index_b - 1 ] )
        dwave_r = ( wave[ index_r ] - wave[ index_r - 1 ] ) 
        dwave_i = ( wave[ index_i ] - wave[ index_i - 1 ] ) 
        ;; Number of pixels
        n_pix_b = n_elements( index_b ) 
        n_pix_r = n_elements( index_r ) 
        n_pix_i = n_elements( index_i ) 

        ;; Isolate the flux inside the wavelength region for the index 
        flux_index  = flux[ index_i ] 
        error_index = error[ index_i ]

        ;; Include the fractional pixels at the end of band 
        ;; Blue side
        frac_b_0 = ( wave[ min( index_b ) ] - blue0 ) / $
                   ( wave[ min( index_b ) ] - wave[ min( index_b ) - 1 ] )
        frac_b_1 = ( blue1 - wave[ max( index_b ) ] ) / $ 
                   ( wave[ max( index_b ) + 1 ] - wave[ max( index_b ) ] )
        last_b = ( n_pix_b - 1 )
        ;; Red side 
        frac_r_0 = ( wave[ min( index_r ) ] - red0 ) / $
                   ( wave[ min( index_r ) ] - wave[ min( index_r ) - 1 ] )
        frac_r_1 = ( red1 - wave[ max( index_r ) ] ) / $ 
                   ( wave[ max( index_r ) + 1 ] - wave[ max( index_r ) ] )
        last_r = ( n_pix_r - 1 )
        ;; Fractional pixels for the index range
        frac_i_0 = ( wave[ min( index_i ) ] - lam0 ) / $
                   ( wave[ min( index_i ) ] - wave[ min( index_i ) - 1 ] ) 
        frac_i_1 = ( lam1 - wave[ max( index_i ) ] ) / $ 
                   ( wave[ max( index_i ) + 1 ] - wave[ max( index_i ) ] )
        last_i = ( n_pix_i -1 )

        if keyword_set( debug ) then begin 
            print, '  WIDTH_B/R : ', width_b,  width_r 
            print, ' CENTER_B/R : ', center_b, center_r 
            print, ' FRAC_B_0/1 : ', frac_b_0, frac_b_1 
            print, ' FRAC_R_0/1 : ', frac_r_0, frac_r_1 
            print, ' FRAC_I_0/1 : ', frac_i_0, frac_i_1 
            print, '   LAST_0/1 : ', last_b, last_r, last_i
            print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        endif

        ;; Find the average point in the blue and red pseudocontinua
        ave_b = ( int_tabulated( wave[ index_b ], flux[ index_b ], /double ) + $
            ( frac_b_0 * flux[ min( index_b ) - 1 ] * dwave_b[0] )  + $ 
            ( frac_b_1 * flux[ max( index_b ) ] * dwave_b[last_b] ) ) / width_b
        ave_r = ( int_tabulated( wave[ index_r ], flux[ index_r ], /double ) + $
            ( frac_r_0 * flux[ min( index_r ) - 1 ] * dwave_r[0] )  + $ 
            ( frac_r_1 * flux[ max( index_r ) ] * dwave_r[last_r] ) ) / width_r

        ;; Make the pseudo-continuum 
        pseudo_slope = ( ave_r - ave_b ) / ( center_r - center_b )
        pseudo_inter = ( ave_b - ( pseudo_slope * center_b ) ) 
        ;; The whole pseudo-continuum and the pseudo-continuum in the index range
        pseudo_index = ( pseudo_slope * wave[ index_i ] + pseudo_inter ) 
        pseudo_whole = ( pseudo_slope * wave + pseudo_inter )

        if keyword_set( debug ) then begin 
            print, '      AVE_B/R : ', ave_b, ave_r
            print, ' PSEUDO_SLOPE : ', pseudo_slope
            print, ' PSEUDO_INTER : ', pseudo_inter 
            print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        endif

        ;; Measure the Angstrom index 
        if ( type EQ 0 ) then begin 

            value_ang = int_tabulated( wave[ index_i ], $
                ( 1.0 - ( flux_index / pseudo_index ) ), /double )
            value_ang = value_ang + $
                frac_i_0 * 0.5 * ( $ 
                ( ( 1.0 - flux[ min( index_i ) - 1 ] / $
                pseudo_whole[ min( index_i ) - 1 ] ) * dwave_i[0] ) + $ 
                ( ( 1.0 - flux[ min( index_i ) ] / $
                pseudo_whole[ min( index_i ) ] ) * dwave_i[0] ) )
            value_ang = value_ang + $
                frac_i_1 * 0.5 * ( $ 
                ( ( 1.0 - flux[ max( index_i ) + 1 ] / $
                pseudo_whole[ max( index_i ) + 1 ] ) * dwave_i[last_i] ) + $ 
                ( ( 1.0 - flux[ max( index_i ) ] / $
                pseudo_whole[ max( index_i ) ] ) * dwave_i[last_i] ) )

            if keyword_set( debug ) then begin 
                print, ' VALUE_ANG : ', value_ang
                print, ' WIDTH     : ', width_i
                print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
            endif

            output.value = value_ang

        endif 

        ;; Measure the Magnitude index 
        if ( type EQ 1 ) then begin 

            value_ang = int_tabulated( wave[ index_i ], $
                ( flux_index / pseudo_index ), /double )
            value_ang = value_ang + $ 
                frac_i_0 * 0.5 * ( $ 
                ( ( flux[ min( index_i ) - 1 ] / $
                pseudo_whole[ min( index_i ) - 1 ] ) * dwave_i[0] ) + $
                ( ( flux[ min( index_i ) ] / $
                pseudo_whole[ min( index_i ) ] ) * dwave_i[0] ) )
            value_ang = value_ang + $
                frac_i_0 * 0.5 * ( $ 
                ( ( flux[ max( index_i ) + 1 ] / $
                pseudo_whole[ max( index_i ) + 1 ] ) * dwave_i[last_i] ) + $
                ( ( flux[ max( index_i ) ] / $
                pseudo_whole[ max( index_i ) ] ) * dwave_i[last_i] ) ) 

            ;; Get the magnitude value  
            value_mag = -2.50 * alog10( value_ang / width_i )

            if keyword_set( debug ) then begin 
                print, ' VALUE_ANG : ', value_ang
                print, ' WIDTH     : ', width_i
                print, ' VALUE_MAG : ', value_mag
                print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
            endif

            output.value = value_mag 

        endif 

        ;; Measure the error of index according to Cardiel+1998, A&A
        ;; Variance at the blue and red side 
        variance_b = ( total( error[ index_b ]^2.0 * dwave_b^2.0 ) ) / $ 
            ( width_b^2.0 ) 
        variance_r = ( total( error[ index_r ]^2.0 * dwave_r^2.0 ) ) / $ 
            ( width_r^2.0 ) 
        if keyword_set( debug ) then begin 
            print, ' VARIANCE_B : ', variance_b 
            print, ' VARIANCE_R : ', variance_r 
            print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        endif
        ;; Get the error for atomic index 
        sum = 0.0D 
        rb_square = ( center_r - center_b )^2.0
        for ii = 0, ( n_pix_i - 1 ), 1 do begin 
            ;; Variance for the index region 
            variance_i = $
                ( ( center_r - wave[ index_i[ii] ] )^2.0 / rb_square ) $ 
                * variance_b + $ 
                ( ( wave[ index_i[ii] ] - center_b )^2.0 / rb_square ) $
                * variance_r
            ;; First term 
            sum = sum + ( ( $
                pseudo_whole[ index_i[ii] ]^2.0 * $
                error[ index_i[ii] ]^2.0 + $ 
                flux[ index_i[ii] ]^2.0 * variance_i ) / $ 
                pseudo_whole[ index_i[ii] ]^4.0 ) * ( dwave_i[ii]^2.0 )
            ;; Second term 
            for jj = 0, ( n_pix_i - 1 ), 1 do begin 
                ;; Lamda parameters 
                lambda_1 = ( center_r - wave[ index_i[ii] ] ) * $ 
                    ( center_r - wave[ index_i[jj] ] ) / $ 
                    rb_square 
                lambda_4 = ( wave[ index_i[ii] ] - center_b ) * $ 
                    ( wave[ index_i[jj] ] - center_b ) / $ 
                    rb_square 
                ;; 
                if ( ii ne jj ) then begin 
                    sum = sum + ( ( $ 
                        ( flux[ index_i[ii] ] * flux[ index_i[jj] ] ) / $ 
                        ( pseudo_whole[ index_i[ii] ]^2.0 * $
                          pseudo_whole[ index_i[jj] ]^2.0 ) ) * $ 
                        ( lambda_1 * variance_b + lambda_4 * variance_r ) ) * $
                        ( dwave_i[ii] * dwave_i[jj] )
                endif
            endfor
        endfor 
        ;; Output the error
        if ( type EQ 0 ) then begin  ;; Atmoic index 
            output.error = sqrt( sum ) 
        endif else begin   ;; Molecular index 
            output.error = 2.50 * ( alog10( exp( 1.0 ) ) / $ 
                10.0^( -0.4 * output.value ) ) * sqrt( sum ) / width_i 
        endelse

        ;; Make a plot 
        if keyword_set( plot ) then begin 

            if keyword_set( eps_name ) then begin 
                plot_name = strcompress( eps_name, /remove_all )
            endif else begin 
                plot_name = strcompress( index.name, /remove_all ) + '.eps' 
            endelse

            mydevice = !d.name 
            !p.font=1
            set_plot, 'ps' 
            device, filename=plot_name, font_size=9.0, /encapsulated, $
                /color, /helvetica, /bold, $
                xsize=27, ysize=22
            position = [ 0.145, 0.15, 0.99, 0.99 ]
            
            wave_plot_0 = ( blue0 > min_wave )  
            wave_plot_1 = ( red1  < max_wave )
            wave_plot_s = ( ( wave_plot_1 - wave_plot_0 ) / 15.0 ) 
            wave_plot_0 = ( wave_plot_0 - wave_plot_s )
            wave_plot_1 = ( wave_plot_1 + wave_plot_s )
            flux_plot_0 = min( flux[ min( index_b ): max( index_r ) ] - $
                error[ min( index_b ): max( index_r ) ] )
            flux_plot_1 = max( flux[ min( index_b ): max( index_r ) ] + $
                error[ min( index_b ): max( index_r ) ] )
            flux_plot_s = ( ( flux_plot_1 - flux_plot_0 ) / 10.0 )
            flux_plot_0 = ( flux_plot_0 - flux_plot_s )
            flux_plot_1 = ( flux_plot_1 + flux_plot_s )
            ;; index plot 
            index_plot = where( ( wave GE wave_plot_0 ) AND $
                ( wave LE wave_plot_1 ) ) 
            if ( index_plot[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Huh??? Something wrong !! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif 

            cgPlot, wave, flux, xstyle=1, ystyle=1, $
                xrange=[ wave_plot_0, wave_plot_1 ], $
                yrange=[ flux_plot_0, flux_plot_1 ], $
                xthick=10.0, ythick=10.0, charsize=4.0, charthick=12.0, $ 
                xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
                /nodata, position=position 

            ;; Error fill
            cgColorFill, [ wave_plot_0, wave[ index_plot ], $
                reverse( wave[ index_plot ] ) ], $
                [ ( flux[ index_plot[0] ] + error[ index_plot[0] ] ), $
                ( flux[ index_plot ] - error[ index_plot ] ), $ 
                reverse( flux[ index_plot ] + error[ index_plot ] ) ], $
                color=cgColor( 'Gray' )
            ;; Boundary for each region
            cgColorFill, [ blue0, blue1, blue1, blue0 ], $
                [ flux_plot_0, flux_plot_0, flux_plot_1, flux_plot_1 ], $ 
                color=cgColor( 'BLU2' )
            cgPlot, [ blue0, blue0 ], !Y.Crange, linestyle=0, thick=6.0, $
                /overplot, color=cgColor( 'BLU4' ) 
            cgPlot, [ blue1, blue1 ], !Y.Crange, linestyle=0, thick=6.0, $
                /overplot, color=cgColor( 'BLU4' ) 
            cgColorFill, [ red0, red1, red1, red0 ], $
                [ flux_plot_0, flux_plot_0, flux_plot_1, flux_plot_1 ], $ 
                color=cgColor( 'RED2' )
            cgPlot, [ red0, red0 ], !Y.Crange, linestyle=0, thick=6.0, $
                /overplot, color=cgColor( 'RED4' ) 
            cgPlot, [ red1, red1 ], !Y.Crange, linestyle=0, thick=6.0, $
                /overplot, color=cgColor( 'RED4' ) 
            ;; Fill the region inside 
            cgColorFill, $
                [ lam0, wave[ index_i ], wave[ reverse( index_i ) ] ], $ 
                [ pseudo_whole[ min( index_i ) ], flux[ index_i ], $
                  pseudo_whole[ reverse( index_i ) ] ], $ 
                color=cgColor( 'ORG2' )
            cgPlot, [ lam0, lam0 ], $
                [ pseudo_whole[ min( index_i ) ], flux[ min( index_i ) ] ], $ 
                linestyle=0, thick=7.0, color=cgColor( 'ORG5' ), /overplot
            cgPlot, [ lam1, lam1 ], $
                [ pseudo_whole[ max( index_i ) ], flux[ max( index_i ) ] ], $ 
                linestyle=0, thick=7.0, color=cgColor( 'ORG5' ), /overplot
            ;; Error spectra 
            cgPlot, wave, ( flux - error ), /overplot, linestyle=0, $
                thick=3.0, color=cgColor( 'Dark Gray' ) 
            cgPlot, wave, ( flux + error ), /overplot, linestyle=0, $
                thick=3.0, color=cgColor( 'Dark Gray' ) 
            ;; Pseudocontinua
            cgPlot, wave, pseudo_whole, linestyle=2, thick=7.0, /overplot, $
                color=cgColor( 'Brown' )
            cgPlot, center_b, ave_b, /overplot, psym=16, symsize=2.5, $
                color=cgColor( 'Brown' ) 
            cgPlot, center_r, ave_r, /overplot, psym=16, symsize=2.5, $
                color=cgColor( 'Brown' ) 
            ;; Spectra
            cgPlot, wave, flux, linestyle=0, thick=6.5, /overplot, $
                color=cgColor( 'Black' )
            ;; Re-draw the axis 
            cgPlot, wave, flux, xstyle=1, ystyle=1, $
                xrange=[ wave_plot_0, wave_plot_1 ], $
                yrange=[ flux_plot_0, flux_plot_1 ], $
                xthick=10.0, ythick=10.0, charsize=4.0, charthick=12.0, $ 
                xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
                /nodata, position=position, /noerase 
            ;; Label 
            xloc = ( ( position[0] + position[2] ) / 2.0 ) - 0.005
            yloc = position[3] - 0.07
            label = strcompress( index.name, /remove_all ) 
            cgText, xloc, yloc, label, charsize=3.5, charthick=10.0, $
                color=cgColor( 'Black' ), alignment=1.0, /normal
            xloc = ( ( position[0] + position[2] ) / 2.0 )
            yloc = position[3] - 0.07
            label = ': ' + strcompress( string( output.value, format='(F8.4)' ), $
                /remove_all )
            cgText, xloc, yloc, label, charsize=3.5, charthick=10.0, $
                color=cgColor( 'Black' ), alignment=0.0, /normal

            device, /close 
            set_plot, mydevice 

        endif 

    endif else begin 

        ;; Measure the break-like index 
        if ( type EQ 2 ) then begin 
            
            ;; Index 
            index_b = where( ( wave GE blue0 ) AND ( wave LE blue1 ) ) 
            index_r = where( ( wave GE red0  ) AND ( wave LE red1  ) ) 
            ;; Width of the wavelength window 
            width_b = ( blue1 - blue0 ) 
            width_r = ( red1  - red0  ) 
            ;; Array for wavelength step 
            dwave_b = ( wave[ index_b ] - wave[ index_b - 1 ] )
            dwave_r = ( wave[ index_r ] - wave[ index_r - 1 ] ) 

            v_blue = int_tabulated( wave[ index_b ], $
                ( ( wave[ index_b ]^2.0D ) * flux[ index_b ] ), /double ) / $ 
                width_b 
            v_red  = int_tabulated( wave[ index_r ], $
                ( ( wave[ index_r ]^2.0D ) * flux[ index_r ] ), /double ) / $ 
                width_r 

            value_break = ( v_red / v_blue )

            output.value = value_break
    
            ;; Error for break-like index 
            ;; Only an approximate error
            mean_snr_b = mean( snr_ori[ index_b ] ) 
            mean_snr_r = mean( snr_ori[ index_r ] ) 
            output.error = ( output.value / sqrt( 200.0 ) ) * $ 
                sqrt( ( 1.0 / mean_snr_b^2.0 ) + ( 1.0 / mean_snr_r^2.0 ) )
            ;; More accurate error
            ;fsquare_b = total( ( wave[ index_b ] )^2.0 * $
            ;   flux[ index_b ] )
            ;fsquare_r = total( ( wave[ index_r ] )^2.0 * $
            ;    flux[ index_r ] )
            ;sigma_b = total( ( wave[ index_b ] )^4.0 * $
            ;    ( error[ index_b ] )^2.0 )
            ;sigma_r = total( ( wave[ index_r ] )^4.0 * $
            ;    ( error[ index_r ] )^2.0 )
            ;sigma_break = ( fsquare_r * sigma_b + fsquare_b * sigma_r ) / $
            ;    ( fsquare_b^2.0 )
            ;output.error = sqrt( sigma_break )
    
            ;; Make a plot 
            if keyword_set( plot ) then begin 
    
                if keyword_set( eps_name ) then begin 
                    plot_name = strcompress( eps_name, /remove_all )
                endif else begin 
                    plot_name = strcompress( index.name, /remove_all ) + '.eps' 
                endelse
    
                mydevice = !d.name 
                !p.font=1
                set_plot, 'ps' 
                device, filename=plot_name, font_size=9.0, /encapsulated, $
                    /color, /helvetica, /bold, $
                    xsize=27, ysize=22
                position = [ 0.145, 0.15, 0.99, 0.99 ]

                ;; Normalize; just for plot
                flux = ( flux / median( flux ) )
                error = ( flux / snr_ori )
                
                wave_plot_0 = ( blue0 > min_wave )  
                wave_plot_1 = ( red1  < max_wave )
                wave_plot_s = ( ( wave_plot_1 - wave_plot_0 ) / 15.0 ) 
                wave_plot_0 = ( wave_plot_0 - wave_plot_s )
                wave_plot_1 = ( wave_plot_1 + wave_plot_s )
                flux_plot_0 = min( flux[ min( index_b ): max( index_r ) ] )
                flux_plot_1 = max( flux[ min( index_b ): max( index_r ) ] )
                flux_plot_s = ( ( flux_plot_1 - flux_plot_0 ) / 10.0 )
                flux_plot_0 = ( flux_plot_0 - flux_plot_s )
                flux_plot_1 = ( flux_plot_1 + flux_plot_s )
                ;; index plot 
                index_plot = where( ( wave GE wave_plot_0 ) AND $
                    ( wave LE wave_plot_1 ) ) 
                if ( index_plot[0] EQ -1 ) then begin 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    print, ' Huh??? Something wrong !! '
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    message, ' '
                endif 
    
                cgPlot, wave, flux, xstyle=1, ystyle=1, $
                    xrange=[ wave_plot_0, wave_plot_1 ], $
                    yrange=[ flux_plot_0, flux_plot_1 ], $
                    xthick=10.0, ythick=10.0, charsize=4.0, charthick=12.0, $ 
                    xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
                    /nodata, position=position 
    
                ;; Error fill
                cgColorFill, [ wave_plot_0, wave[ index_plot ], $
                    reverse( wave[ index_plot ] ) ], $
                    [ ( flux[ index_plot[0] ] + error[ index_plot[0] ] ), $
                    ( flux[ index_plot ] - error[ index_plot ] ), $ 
                    reverse( flux[ index_plot ] + error[ index_plot ] ) ], $
                    color=cgColor( 'Gray' )
                ;; Boundary for each region
                cgColorFill, [ blue0, blue1, blue1, blue0 ], $
                    [ flux_plot_0, flux_plot_0, flux_plot_1, flux_plot_1 ], $ 
                    color=cgColor( 'BLU2' )
                cgPlot, [ blue0, blue0 ], !Y.Crange, linestyle=0, thick=6.0, $
                    /overplot, color=cgColor( 'BLU4' ) 
                cgPlot, [ blue1, blue1 ], !Y.Crange, linestyle=0, thick=6.0, $
                    /overplot, color=cgColor( 'BLU4' ) 
                cgColorFill, [ red0, red1, red1, red0 ], $
                    [ flux_plot_0, flux_plot_0, flux_plot_1, flux_plot_1 ], $ 
                    color=cgColor( 'RED2' )
                cgPlot, [ red0, red0 ], !Y.Crange, linestyle=0, thick=6.0, $
                    /overplot, color=cgColor( 'RED4' ) 
                cgPlot, [ red1, red1 ], !Y.Crange, linestyle=0, thick=6.0, $
                    /overplot, color=cgColor( 'RED4' ) 
                ;; Error spectra 
                cgPlot, wave, ( flux - error ), /overplot, linestyle=0, $
                    thick=3.0, color=cgColor( 'Dark Gray' ) 
                cgPlot, wave, ( flux + error ), /overplot, linestyle=0, $
                    thick=3.0, color=cgColor( 'Dark Gray' ) 
                ;; Spectra
                cgPlot, wave, flux, linestyle=0, thick=6.5, /overplot, $
                    color=cgColor( 'Black' )
                ;; Re-draw the axis 
                cgPlot, wave, flux, xstyle=1, ystyle=1, $
                    xrange=[ wave_plot_0, wave_plot_1 ], $
                    yrange=[ flux_plot_0, flux_plot_1 ], $
                    xthick=10.0, ythick=10.0, charsize=4.0, charthick=12.0, $ 
                    xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
                    /nodata, position=position, /noerase 
                ;; Label 
                xloc = ( position[0] + 0.20 )
                yloc = position[3] - 0.07
                label = strcompress( index.name, /remove_all ) 
                cgText, xloc, yloc, label, charsize=3.5, charthick=10.0, $
                    color=cgColor( 'Black' ), alignment=1.0, /normal
                xloc = ( position[0] + 0.205 )
                yloc = position[3] - 0.07
                label = ': ' + strcompress( string( output.value, format='(F8.4)' ), $
                    /remove_all )
                cgText, xloc, yloc, label, charsize=3.5, charthick=10.0, $
                    color=cgColor( 'Black' ), alignment=0.0, /normal
    
                device, /close 
                set_plot, mydevice 
    
            endif 

        endif

    endelse

    ;; Return output 
    return, output
    ;; 
    free_all

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro test_index 

    list_file = 'hs_index.lis' 
    index_struc = index_list2struc( list_file )

    file = 'Iun1.30Zp0.00T10.0000_linear_Sigma_350.0.fits' 
    flux = mrdfits( file, 0, head ) 
    n_pix = fxpar( head, 'NAXIS1' ) 
    wave0 = fxpar( head, 'CRVAL1' ) 
    dwave = fxpar( head, 'CDELT1' ) 
    wave = wave0 + findgen( n_pix ) * dwave 

    ;wave_r = wave0 + findgen( n_pix * 4 ) * ( dwave / 4.0 ) 
    ;index_r = findex( wave, wave_r ) 
    ;flux_r = interpolate( flux, index_r )
    ;wave = wave_r 
    ;flux = flux_r

    ;; error spectrum 
    ;error = ( flux / 100.0 ) 
    ;mwrfits, error, 'fake_error.fits', head, /create

    ;print, index_struc

    ;output_struc = index_list_measure( flux, wave, index_struc, error=error, $
    ;    /plot, prefix='Iun1.30Zp0.00T10.0000_linear_Sigma_350.0' ) 

    ;for i = 0, ( n_elements( index_struc.name ) - 1 ), 1 do begin 
    ;    print, output_struc[i].name, '  ', output_struc[i].value, ' ', $
    ;        output_struc[i].error 
    ;endfor


    ;Lick_CN1      4142.125  4177.125  4080.125  4117.625  4244.125  4284.125  mag
    ;Lick_CN2      4142.125  4177.125  4083.875  4096.375  4244.125  4284.125  mag
    ;Lick_Fe5406   5387.500  5415.000  5376.250  5387.500  5415.000  5425.000  A
    ;Lick_Fe5709   5696.625  5720.375  5672.857  5696.625  5722.875  5736.625  A
    ;Lick_Fe5782   5776.625  5796.625  5765.375  5775.375  5797.875  5811.625  A
    ;Lick_NaD      5876.875  5909.375  5860.625  5875.625  5922.125  5948.125  A
    ;; Expected value: 
    ;; CN1: 0.0406 ; CN2: 0.0681 ; 
    ;; Fe5406: 1.2995  ; Fe5709: 0.8235 ; Fe5782 : 0.5673 ; 
    ;; NaD: 3.0363

    index = { lam0:0.0, lam1:0.0, blue0:0.0, blue1:0.0, red0:0.0, red1:0.0, $
        type:0, name:'' } 

    index.name  = 'Lick_Fe5406'
    index.lam0  = 5387.500  
    index.lam1  = 5415.000 
    index.blue0 = 5376.250 
    index.blue1 = 5387.500 
    index.red0  = 5415.000 
    index.red1  = 5425.000 
    index.type  = 0   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    ;hs_CaH2  6510.000  6539.250  6775.000  6900.000  7017.000  7064.000 
    index.name  = 'HS_CaH2'
    index.lam0  = 6775.000  
    index.lam1  = 6900.000
    index.blue0 = 6510.000
    index.blue1 = 6539.250 
    index.red0  = 7017.000 
    index.red1  = 7064.000
    index.type  = 1   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    index.name  = 'Lick_NaD'
    index.lam0  = 5876.875  
    index.lam1  = 5909.375
    index.blue0 = 5860.625 
    index.blue1 = 5875.625
    index.red0  = 5922.125 
    index.red1  = 5948.125
    index.type  = 0   ;; 0: Angstrom ; 1: Mag ; 2: Break 
    ;Lick_NaD      5876.875  5909.375  5860.625  5875.625  5922.125  5948.125  A

    ;hs_CaH1  6342.125  6356.500  6357.500  6401.750  6408.500  6429.750
    index.name  = 'HS_CaH1'
    index.lam0  = 6357.500  
    index.lam1  = 6401.750
    index.blue0 = 6342.125
    index.blue1 = 6356.500 
    index.red0  = 6408.500 
    index.red1  = 6429.750
    index.type  = 1   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    index.name  = 'Lick_CN1'
    index.lam0  = 4142.125 
    index.lam1  = 4177.125 
    index.blue0 = 4080.125 
    index.blue1 = 4117.625 
    index.red0  = 4244.125 
    index.red1  = 4284.125 
    index.type  = 1   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    index.name  = 'Lick_Fe5782'
    index.lam0  = 5776.625  
    index.lam1  = 5796.625
    index.blue0 = 5765.375 
    index.blue1 = 5775.375
    index.red0  = 5797.875 
    index.red1  = 5811.625
    index.type  = 0   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    index.name  = 'Dn4000'
    index.lam0  = 0.00  
    index.lam1  = 0.00 
    index.blue0 = 3850.000 
    index.blue1 = 3950.000
    index.red0  = 4000.000 
    index.red1  = 4100.000
    index.type  = 2   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    index.name  = 'Lick_CN2'
    index.lam0  = 4142.125 
    index.lam1  = 4177.125 
    index.blue0 = 4083.875 
    index.blue1 = 4096.375 
    index.red0  = 4244.125 
    index.red1  = 4284.125 
    index.type  = 1   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    index.name  = 'Lick_Fe5015'
    index.lam0  = 4977.750  
    index.lam1  = 5054.000
    index.blue0 = 4946.500 
    index.blue1 = 4977.750
    index.red0  = 5054.000 
    index.red1  = 5065.250
    index.type  = 0   ;; 0: Angstrom ; 1: Mag ; 2: Break 

    ;; Make sure the input wavelength is in Air
    result = hs_spec_index_measure( wave, flux, index, snr=600.0, /debug )
    print, result.name, result.value, result.error

end

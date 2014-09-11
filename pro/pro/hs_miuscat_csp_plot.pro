pro hs_miuscat_csp_plot, csp_file, $
    topng=topng, togif=togif, normalize=normalize 

    ;; Check the CSP file 
    csp_file = strcompress( csp_file, /remove_all ) 
    if NOT file_test( csp_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the CSP file: ' + csp_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        csp_struc = mrdfits( csp_file, 1, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the CSP file : ' + csp_file 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin  
            if ( ( tag_indx( csp_struc, 'wave' )    EQ -1 ) OR $
                ( tag_indx( csp_struc, 'flux' )     EQ -1 ) OR $
                ( tag_indx( csp_struc, 'time' )     EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'time_lb' )  EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'sfr' )      EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'mstar' )    EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'age_mw' )   EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'age_lw' )   EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'imf' )      EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'met' )      EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'ts' )       EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'np' )       EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'tau' )      EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'tr' )       EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'n_time' )   EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 't_cosmos' ) EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'resolution' ) EQ -1 ) OR $ 
                ( tag_indx( csp_struc, 'unit' )     EQ -1 ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The CSP structure has incompatible tags ! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif 
        endelse
    endelse

    ;; The string for this CSP 
    csp_string = str_replace( csp_file, '.fits', '' ) 

    ;; The number of time frames 
    n_time = csp_struc.n_time 
    
    ;; Reconstruct the SFH with a refined time array 
    ;; Cosmos age 
    t_cosmos = csp_struc.t_cosmos 
    ;; T_start 
    t_start = csp_struc.ts 
    ;; N_power 
    n_power = csp_struc.np 
    ;; Tau 
    tau = csp_struc.tau 
    ;; T_trunc 
    t_trunc = csp_struc.tr
    if ( t_trunc LT 0.0 ) then begin 
        do_truncation = 0 
    endif else begin 
        do_truncation = 1 
    endelse

    ;; Make a refined lookback time array 
    d_time = ( t_cosmos / 3000.0 ) 
    refined_lbt = findgen( 3000 ) * d_time 
    refined_sfr = ( ( t_start - refined_lbt ) / t_start )^( n_power ) * $ 
        exp( -1.0D * ( t_start - refined_lbt ) / tau )

    ;; Remove the negative and infinite SFR in the array 
    index_zero = where( refined_sfr LT 0.0 ) 
    if ( index_zero[0] NE -1 ) then begin
        refined_sfr[ index_zero ] = 0.0 
    endif 
    index_nan = where( finite( refined_sfr, /NaN ) EQ 1 ) 
    if ( index_nan[0] NE -1 ) then begin 
        refined_sfr[ index_nan ] = 0.0 
    endif

    ;; Apply the truncation of SFR 
    if ( do_truncation EQ 1 ) then begin 
        index_trunc = where( refined_arr LT t_trunc ) 
        if ( index_trunc[0] EQ -1 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something weird about the truncation age! Check!  '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            refined_sfr[ index_trunc ] = 0.0 
        endelse
    endif

    ;; Normalize the SFH 
    refined_sfr = ( refined_sfr / max( refined_sfr ) )

    ;; Useful information and the Min/Max values 
    imf  = csp_struc.imf 
    met  = csp_struc.met
    wave = csp_struc.wave 
    mass = csp_struc.mstar 
    time = csp_struc.time_lb 
    sfr  = csp_struc.sfr 
    agem = csp_struc.age_mw
    agel = csp_struc.age_lw

    ;; Organize the data --> remove infinite value
    index_nan = where( finite( mass, /NaN ) EQ 1 ) 
    if ( index_nan[0] NE -1 ) then begin 
        mass[ index_nan ] = 0.0 
    endif
    index_nan = where( finite( agem, /NaN ) EQ 1 ) 
    if ( index_nan[0] NE -1 ) then begin 
        agem[ index_nan ] = 0.0 
    endif
    index_nan = where( finite( agel, /NaN ) EQ 1 ) 
    if ( index_nan[0] NE -1 ) then begin 
        agel[ index_nan ] = 0.0 
    endif

    ;; wavelength 
    min_wave = min( wave ) 
    max_wave = max( wave ) 
    wave_range = [ min_wave, max_wave ]
    ;; mass 
    min_mass = min( mass ) 
    max_mass = max( mass ) 
    mass_range = [ -0.09, ( max_mass * 1.15 ) ]
    ;; time 
    time_range = [ -0.10, ( t_cosmos + 0.15 ) ]
    ;; sfr 
    sfr = ( sfr / max( sfr ) )
    sfr_range  = [ -0.09, 1.150 ]
    ;; age 
    max_age = ( max( agem ) > max( agel ) ) 
    age_range  = [ -0.99, ( max_age * 1.15 ) ]
    ;; flux 
    max_flux = max( csp_struc.flux )
    flux_range = [ 0.000, 1.050 ]

    ;; Number of digits for the maximum number of time frames 
    max_num = max( n_time ) 
    max_num_str = strcompress( string( max_num, format='(I6)' ), /remove_all )
    max_digit   = strlen( max_num_str )
    ;; Start making the plots 
    ; For test only
    ;for ii = ( n_time - 2 ), ( n_time - 1 ), 1 do begin 
    for ii = 0, ( n_time - 1 ), 1 do begin 

        ;; File name for the output figure 
        num_str = strcompress( string( ( ii + 1 ), format='(I6)' ), $
            /remove_all ) 
        num_digit = strlen( num_str ) 
        num_diff = ( max_digit - num_digit ) 
        for jj = 0, ( num_diff - 1 ), 1 do begin 
            num_str = '0' + num_str 
        endfor
        csp_eps = csp_string + '_' + num_str + '.eps' 
        csp_png = csp_string + '_' + num_str + '.png' 

        ;; Extract the flux array 
        flux = csp_struc.flux[ *, ii ]
        if ( n_elements( flux ) NE csp_struc.n_pix ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with flux array !!! Check! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif 

        ;; Check if the flux array is useful
        if ( min( flux ) EQ max( flux ) ) then begin 
            flux_useful = 0 
        endif else begin 
            flux_useful = 1 
        endelse

        ;; Normalize the flux array 
        if keyword_set( normalize ) then begin 
            flux = ( flux / max_flux )
        endif else begin
            flux = ( flux / max( flux ) )
        endelse
        
        if ( flux_useful EQ 1 ) then begin 

            ;; Size of the EPS output 
            psxsize=50 
            psysize=40
            ;; Location of each sub-figures 
            position_1 = [ 0.08, 0.10, 0.99, 0.44 ] 
            position_2 = [ 0.08, 0.45, 0.99, 0.60 ] 
            position_3 = [ 0.08, 0.60, 0.99, 0.75 ] 
            position_4 = [ 0.08, 0.75, 0.99, 0.90 ] 

            mydevice = !d.name 
            !p.font=1
            set_plot, 'ps' 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            device, filename=csp_eps, font_size=9.0, /encapsulated, $
                /color, set_font='TIMES-ROMAN', /bold, $
                xsize=psxsize, ysize=psysize

            ;; 1. Spectra 
            cgPlot, wave, flux, xstyle=1, ystyle=1, $
                xrange=wave_range, yrange=flux_range, $ 
                xthick=12.0, ythick=12.0, charsize=4.2, charthick=12.0, $
                xtickformat='(A1)', ytitle='Flux (Normalized)', $
                color=cgColor( 'Black' ), /noerase, /nodata, $
                position=position_1, xticklen=0.04, yticklen=0.0125 
            cgAxis, xaxis=0.0, xstyle=1, xrange=wave_range, xthick=12.0, $
                charsize=5.0, charthick=12.0, xticklen=0.04, $
                xtitle='Wavelength (Angstrom)'
            cgPlot, wave, flux, /overplot, linestyle=0, thick=2.0, $
                color=cgColor( 'Navy' )

            ;; 2. SFR plot 
            cgPlot, refined_lbt, refined_sfr, xstyle=1, ystyle=1, $
                xrange=time_range, yrange=sfr_range, $ 
                xthick=12.0, ythick=12.0, charsize=4.0, charthick=12.0, $
                xtickformat='(A1)', ytitle='SFR', $
                color=cgColor( 'Black' ), /noerase, /nodata, $
                xtickinter=1.0, xminor=2, yminor=2, $
                xticklen=0.05, yticklen=0.0125, $
                position=position_2 
            cgPlot, refined_lbt, refined_sfr, /overplot, linestyle=2, $
                thick=12.0, color=cgColor( 'Navy' )
            cgPlots, time[ii], sfr[ii], psym=16, symsize=3.0, $
                symcolor=cgColor( 'Dark Gray' )
            cgPlots, time[ii], sfr[ii], psym=9,  symsize=3.3, $
                symcolor=cgColor( 'Red' ), thick=9.0
            ;; Label for the SFH 
            ;; T_start
            xloc = ( position_2[0] + 0.025 )
            yloc = ( position_2[3] - 0.04 ) 
            label = 't_s:' + strcompress( string( t_start, format='(F5.1)' ), $
                /remove_all ) + ' Gyr' 
            cgText, xloc, yloc, label, /normal, color=cgColor( 'Black' ), $
                charsize=4.0, charthick=10.0, alignment=0.0
            ;; Tau 
            xloc = xloc
            yloc = ( yloc - 0.03 ) 
            label = 'tau:' + strcompress( string( tau, format='(F5.1)' ), $
                /remove_all ) + ' Gyr'
            cgText, xloc, yloc, label, /normal, color=cgColor( 'Black' ), $
                charsize=4.0, charthick=10.0, alignment=0.0
            ;; N_power 
            xloc = ( position_2[0] + 0.14 )
            yloc = ( position_2[3] - 0.04 ) 
            label = 'n_p:' + strcompress( string( n_power, format='(F5.2)' ), $
                /remove_all )
            cgText, xloc, yloc, label, /normal, color=cgColor( 'Black' ), $
                charsize=4.0, charthick=10.0, alignment=0.0
            ;; T_trunc 
            if ( do_truncation EQ 1 ) then begin 
                xloc = xloc 
                yloc = ( yloc - 0.03 ) 
                label = 't_r:' + strcompress( string( t_trunc, $
                    format='(F5.1)' ), /remove_all )
                cgText, xloc, yloc, label, /normal, color=cgColor( 'Black' ), $
                    charsize=4.0, charthick=10.0, alignment=0.0
            endif 

            ;; 3. Mass plot 
            cgPlot, time, mass, xstyle=1, ystyle=1, $
                xrange=time_range, yrange=mass_range, $
                xthick=12.0, ythick=12.0, charsize=4.0, charthick=12.0, $
                xtickformat='(A1)', ytitle='Stellar Mass', $
                color=cgColor( 'Black' ), /noerase, /nodata, $
                xtickinter=1.0, xminor=2, yminor=2, $
                xticklen=0.05, yticklen=0.0125, $
                position=position_3 
            cgPlot, time, mass, /overplot, linestyle=2, thick=10.0, $
                color=cgColor( 'Navy' ) 
            cgPlots, time[ii], mass[ii], psym=16, symsize=3.0, $
                symcolor=cgColor( 'Dark Gray' )
            cgPlots, time[ii], mass[ii], psym=9,  symsize=3.3, $
                symcolor=cgColor( 'Red' ), thick=9.0

            ;; 4. Age Plot 
            cgPlot, time, agem, xstyle=1, ystyle=1, $
                xrange=time_range, yrange=age_range, $
                xthick=12.0, ythick=12.0, charsize=4.0, charthick=12.0, $
                xtickformat='(A1)', ytitle='Stellar Age', $
                color=cgColor( 'Black' ), /noerase, /nodata, $
                xtickinter=1.0, xminor=2, xticklen=0.05, yticklen=0.0125, $
                position=position_4 
            cgAxis, xaxis=1.0, xthick=12.0, ythick=12.0, $
                charsize=5.0, charthick=12.0, xstyle=1, xrange=time_range, $
                xtickinter=1.0, xminor=2, xticklen=0.05, $
                xtitle='Look-back Time (Gyr)' 
            cgPlot, time, agem, /overplot, linestyle=2, thick=10.0, $
                color=cgColor( 'Navy' )
            cgPlot, time, agel, /overplot, linestyle=0, thick=10.0, $
                color=cgColor( 'Red' )
            cgPlots, time[ii], agem[ii], psym=16, symsize=3.0, $
                symcolor=cgColor( 'Dark Gray' )
            cgPlots, time[ii], agem[ii], psym=9,  symsize=3.3, $
                symcolor=cgColor( 'Navy' ), thick=9.0
            cgPlots, time[ii], agel[ii], psym=16, symsize=3.0, $
                symcolor=cgColor( 'Dark Gray' )
            cgPlots, time[ii], agel[ii], psym=9,  symsize=3.3, $
                symcolor=cgColor( 'Red' ), thick=9.0
            ;; Label the SSPs 
            ;; IMF string
            xloc = ( position_4[2] - 0.16 )
            yloc = ( position_4[3] - 0.045 ) 
            label = 'IMF: ' + imf 
            cgText, xloc, yloc, label, /normal, color=cgColor( 'Black' ), $
                charsize=5.0, charthick=11.0, alignment=0.0
            ;; Metal string
            xloc = xloc  
            yloc = ( yloc - 0.035 ) 
            label = 'MET: ' + strcompress( string( met, format='(F6.3)' ), $
                /remove_all )
            cgText, xloc, yloc, label, /normal, color=cgColor( 'Black' ), $
                charsize=5.0, charthick=11.0, alignment=0.0

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            device, /close 
            set_plot, mydevice

            ;; To PNG 
            if keyword_set( topng ) then begin 
                spawn, 'which convert', imagick_convert 
                spawn, imagick_convert + ' -density 200 -resize 800x640 ' $
                    + csp_eps + ' -quality 95 -flatten ' + csp_png
            endif 

        endif

    endfor

end

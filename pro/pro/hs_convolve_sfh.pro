;; Modified from im_convolve_sfh by J.Moustakas

function hs_convolve_sfh, $
    ssp, $  ;; Structure of SSPs used for convolution
    sfh, $  ;; Structure for the input SFH information 
    min_norm=min_norm, max_norm=max_norm, $
    makeplot=make_plot

    ;; Check the input of SSP 
    if ( n_elements( ssp ) EQ 0L ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the SSP structure ! Check !            '
        print, ' ssp={ age:fltarr(), mstar:fltarr(), wave:fltarr(), '
        print, '       flux:fltarr(,)                                 '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if ( ( tag_indx( ssp, 'age' ) EQ -1 ) OR $
            ( tag_indx( ssp, 'wave' ) EQ -1 ) OR $
            ( tag_indx( ssp, 'flux' ) EQ -1 ) OR $
            ( tag_indx( ssp, 'mstar' ) EQ -1 ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the SSP structure ! Check !        '
            print, ' ssp={ age:fltarr(), mstar:fltarr(), wave:fltarr(), '
            print, '       flux:fltarr(,)                                 '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin 
            n_ssp = n_elements( ssp.age )           ;; Number of SSPs to be used 
            n_pix = n_elements( ssp.wave )   ;; Number of pixels within SSP 
            min_wave = min( ssp.wave )
            max_wave = max( ssp.wave )
            min_age = min( ssp.age ) 
            max_age = max( ssp.age ) 
            if ( max_age GT 20.0 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The unit for age of SSP should be Giga-year (Gyr)'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1
            endif 
            if ( n_pix NE n_elements( ssp.flux[*,0] ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The wavelength and flux array should be same in size !'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif 
        endelse
    endelse

    ;; Check the input of SFH 
    if ( n_elements( sfh ) EQ 0L ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the SFH structure ! Check !            '
        print, ' sfh={ time:0.0, sfr:0.0 }  '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if ( ( tag_indx( sfh, 'time' ) EQ -1 )  $
            OR ( tag_indx( sfh, 'sfr' ) EQ -1 ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the SFH structure ! Check !            '
            print, ' sfh={ time:0.0, sfr:0.0 }  '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin 
            n_sfh = n_elements( sfh )          ;; Number of elements in SFH array  
            n_sfr = n_elements( sfh[0].time )
            min_time = min( sfh[0].time ) 
            max_time = max( sfh[0].time ) 
            if ( max_time GT 20.0 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The unit for cosmic time should be Giga-year (Gyr)'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1
            endif 
        endelse
    endelse

    ;; Make a combined time frame arrary 
    bigtime = [ ssp.age, sfh[0].time, 0.0D ]
    bigtime = bigtime[ uniq( bigtime, sort( bigtime ) ) ]
    n_bigtime = n_elements( bigtime )

    ;; Structure for output 
    csp = { time:fltarr( n_sfr ), $
        wave:fltarr( n_pix ), $
        flux:fltarr( n_pix, n_sfr ), $
        mass:fltarr( n_sfr ), $
        age_mw:fltarr( n_sfr ), $
        age_lw:fltarr( n_sfr ) }
    csp = replicate( csp, n_sfh )

    for i = 0, ( n_sfh - 1 ), 1 do begin 

        csp[i].wave = ssp.wave 

        csp_flux = fltarr( n_pix, n_sfr )
        csp_mass = fltarr( n_sfr )  
        csp_time = fltarr( n_sfr ) 
        csp_age_mw = fltarr( n_sfr ) 
        csp_age_lw = fltarr( n_sfr ) 

        ;; Start the integration 
        for k = 0, ( n_sfr - 1 ), 1 do begin 

            time_temp = sfh[i].time 
            tframe = time_temp[k]  ;;Gyr 
            csp_time[k] = tframe

            ;; Build the time array 
            otime = [0D, ( bigtime < tframe ), ( tframe - bigtime )>0, tframe]
            otime = otime[ uniq( otime, sort( otime ) ) ]
            this_time = interpolate( otime, dindgen( 2.0 * n_elements( otime ) $ 
                - ( 2.0 - 1.0 ) ) / ( 2.0 * 1D ) )
            n_this = n_elements( this_time )

            ;; Interpolate the SFR array 
            sfr_index =  findex( sfh[i].time, this_time )
            this_sfr  = interpolate( sfh[i].sfr, sfr_index )

            ;; Interpolate SSP flux array  
            ssp_index = findex( ssp.age, reverse( this_time ) )
            ssp_flux  = interpolate( ssp.flux, ssp_index, /grid ) 

            ;; The convolution integral 
            delta_t = ( shift( this_time, -1 ) - shift( this_time, +1 ) ) / 2.0
            delta_t[0] = ( ( this_time[1] - this_time[0] ) / 2.0 )
            delta_t[ n_this - 1 ] = ( this_time[ n_this - 1 ] - $ 
                this_time[ n_this - 2 ] ) / 2.0 

            ;; Compute the csp spectra 
            weight = ( this_sfr * delta_t )   ;; [Msun] 
            vweight = rebin( reform( weight, 1, n_this ), n_pix, n_this ) 
            csp_flux[ *, k ] = total( ( ssp_flux * vweight ), 2, /double ) 

            ;; Compute the csp stellar mass 
            csp_mass[ k ] = total( $
                ( interpolate( ssp.mstar, ssp_index ) * weight ), /double )

            ;; Compute the mass and luminosity weighted age 
            ;; Mass-weighted age 
            csp_age_mw[k] = $
                total( interpolate( ssp.mstar, ssp_index ) * weight * $
                interpolate( ssp.age, ssp_index ) ) / $
                total( interpolate( ssp.mstar, ssp_index ) * weight )
            ;; Luminosity-weighted age 
            if keyword_set( min_norm ) then begin 
                min_norm = min_norm > min_wave 
            endif else begin 
                min_norm = 4900.0 
            endelse
            if keyword_set( max_norm ) then begin 
                max_norm = max_norm < max_wave 
            endif else begin 
                max_norm = 5100.0 
            endelse
            index_norm = where( ( ssp.wave GT min_norm ) AND $
                ( ssp.wave LT max_norm ) ) 
            if ( index_norm[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the normalization window ! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif else begin 
                lum = total( ssp_flux[ index_norm, * ], 1, /nan ) / $
                    double( n_elements( index_norm ) )
            endelse
            csp_age_lw[k] = $
                total( lum * weight * interpolate( ssp.age, ssp_index ) ) / $
                total( lum * weight )

        endfor
        
        csp[i].time = csp_time 
        csp[i].flux = csp_flux 
        csp[i].mass = csp_mass 
        csp[i].age_mw = csp_age_mw
        csp[i].age_lw = csp_age_lw

    endfor

    return, csp
    
end

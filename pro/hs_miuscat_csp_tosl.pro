pro hs_miuscat_csp_tosl, csp_file, index=index, $
    last=last, sigma=sigma, av=av, sn=sn, $
    normalize=normalize, debug=debug, base_line=base_line

    ;; X-range for display 
    debug_range = [ 3700, 9200 ]
    ;debug_range = [ 4700, 5200 ]
    sigma_default = 350.0

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
    ;; Extract information from the CSP file title 
    temp = strsplit( csp_string, '_', /extract )
    if ( n_elements( temp ) NE 4 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Are you sure this is the correct CSP file ? '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        ssp_str = temp[1] 
        sfh_str = temp[2] 
        ;;
        imf_str = strmid( ssp_str, 0, 4 ) 
        imf_slope = strmid( imf_str, 2, 2 )
        met_str = strmid( ssp_str, 4, 2 ) 
        ;;
        sfh_len = strlen( sfh_str )
        s_pos = strpos( sfh_str, 's' ) 
        n_pos = strpos( sfh_str, 'n' ) 
        t_pos = strpos( sfh_str, 't' ) 
        r_pos = strpos( sfh_str, 'r' ) 
        ;;
        sfh_ts = strmid( sfh_str, ( s_pos + 1 ), ( n_pos - s_pos - 1 ) )
        sfh_np = strmid( sfh_str, ( n_pos + 1 ), ( t_pos - n_pos - 1 ) )
        if ( r_pos EQ -1 ) then begin 
            sfh_ta = strmid( sfh_str, ( t_pos + 1 ), ( sfh_len - t_pos - 1 ) ) 
            sfh_tr = 0.0 
        endif else begin 
            sfh_ta = strmid( sfh_str, ( t_pos + 1 ), ( r_pos - t_pos - 1 ) ) 
            sfh_tr = strmid( sfh_str, ( r_pos + 1 ), ( sfh_len - r_pos - 1 ) ) 
        endelse
    endelse

    ;; The number of time frames 
    n_time = csp_struc.n_time 
    ;; 
    value_met = 0.02 * ( 10.0D^csp_struc.met )
    value_tau = csp_struc.tau
    value_np  = csp_struc.np
    value_tr  = csp_struc.tr
    value_csp = value_tau * value_np + ( value_tr / 10.0 ) 

    ;; Select the time frame to process 
    if keyword_set( last ) then begin 
        index_use = ( n_time - 1 ) 
    endif else begin 
        if ( n_elements( index ) GT 1 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Please select only one index at a time ! ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif 
        if ( ( index LT 0 ) OR ( index GT ( n_time - 1 ) ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The index should be in the range of 0 and ' + $
                strcompress( string( ( n_time - 1 ), format='(I8)' ), $
                /remove_all ) 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif
        index_use = index
    endelse

    ;; String for the index  
    num_str = strcompress( string( ( index_use + 1 ), format='(I6)' ), $
        /remove_all ) 
    max_digit = strlen( strcompress( string( n_time ), /remove_all ) )
    num_digit = strlen( num_str ) 
    num_diff = ( max_digit - num_digit ) 
    for jj = 0, ( num_diff - 1 ), 1 do begin 
        num_str = '0' + num_str 
    endfor

    ;; Name of the output txt file for Starlight 
    sl_file = csp_string + '_' + num_str + '.txt'

    ;; Return a line for making the BASES file 
    base_line = sl_file + ' ' + $
        strcompress( string( value_csp, format='(F6.2)' ), /remove_all ) + ' ' + $
        strcompress( string( value_met, format='(F6.3)' ), /remove_all ) + ' ' + $
        csp_string + ' 1.000 0 0.00 '  

    ;; Extract information 
    wave = csp_struc.wave 
    flux = csp_struc.flux[ *, index_use ] 
    if ( n_elements( wave ) NE n_elements( flux ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something is wrong with this CSP file! Check! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        min_wave = ceil( min( wave ) )
        max_wave = floor( max( wave ) ) 
        ;; Interpolate the spectra into a linear sampled wavelength array
        wave_inter = min_wave + findgen( max_wave - min_wave + 1) * 1.0 ;; Angstrom 
        index_inter = findex( wave, wave_inter ) 
        flux_inter = interpolate( flux, index_inter ) 
        n_pix_inter = n_elements( wave_inter )
    endelse
    ;; For Debug
    if keyword_set( debug ) then begin 
        cgPlot, wave_inter, flux_inter, xstyle=1, ystyle=1, thick=4.0, $
            color=cgColor( 'Gray' ), xrange=debug_range, $
            position=[0.05, 0.06, 0.995, 0.995]
        cgPlot, wave, flux, /overplot, thick=1.5, color=cgColor( 'Black' )
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; If selected, redden the spectra 
    if keyword_set( av ) then begin 
        av = float( av ) 
        r_v = 3.10D 
        e_bv = ( av / r_v ) 
        ;; Get the k_lambda array 
        k_lam = k_lambda( wave_inter, r_v=r_v, /ccm, /silent )
        a_lam = ( e_bv * k_lam )
        flux_redden = ( flux_inter * ( 10.0D^( -0.4 * a_lam ) ) )
        ;; 
        flux_inter = flux_redden
        ;;
        if keyword_set( debug ) then begin 
            cgPlot, wave_inter, flux_redden, /overplot, color='RED2', $
                linestyle=0, thick=1.0
        endif 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the velocity dispersion for convolution
    if keyword_set( sigma ) then begin 
        sigma = float( sigma ) 
    endif else begin 
        sigma = sigma_default 
    endelse
    ;; Get the resolution of the spectrum
    if ( csp_struc.unit NE 'km/s' ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Currently, it only works for rm/s unit !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        sigma_input = float( csp_struc.resolution ) 
    endelse
    ;; Calculate the difference for velocity dispersion 
    if ( sigma_input GE sigma ) then begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' The target velocity dispersion is lower than the current one!'
        print, '     NO convolution will be applied ! '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        wave_conv = wave_inter 
        flux_conv = flux_inter
    endif else begin 
        ;; Log-Rebin the linear sampled spectra 
        cs = 299792.458d   ;; km/s 
        ;; Wavelength separation for log10-rebin spectra 
        dlogwave = ( 1.0D-4 )
        ;; The velocity scale 
        velscale = ( dlogwave * cs * alog( 10.0D ) )
        ;; Define a new wavelength array
        logwave0 = alog10( min_wave )
        logwave  = logwave0 + findgen( 10000 ) * dlogwave 
        wave_conv = ( 10.0^logwave )
        wave_conv = wave_conv[ where( wave_conv LE max_wave ) ]
        ;; Interpolate the spectrum to the log10-rebinned wavelength grid
        index_new = findex( wave, wave_conv ) 
        ;flux_new = interpolate( flux, index_new )
        flux_new = interpolate( flux_inter, index_new )
        ;; Get the difference in velocity dispersion
        sigma_diff = sqrt( sigma^2.0 - sigma_input^2.0 )
        smoothing = ( sigma_diff / velscale )  ;; in pixels 
        ;; Do the convolution
        flux_conv = gconv( flux_new, smoothing )
    endelse

    if keyword_set( debug ) then begin 
        cgPlot, wave_conv, flux_conv, /overplot, color='NAVY', thick=4.5
    endif 

    ;; Interpolate the spectrum back to linear sampling
    index_inter = findex( wave_conv, wave_inter )
    flux_inter = interpolate( flux_conv, index_inter )

    if keyword_set( debug ) then begin 
        cgPlot, wave_inter, flux_inter, /overplot, color='ORG3', thick=2.0
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Normalize the spectrum before save it 
    if keyword_set( normalize ) then begin 
        flux_inter = ( flux_inter / max( flux_inter ) )
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; If selected, degrade the spectrum into desired S/N 
    if keyword_set( sn ) then begin 
        sn = float( sn )
        ;; Make a S/N ratio array  
        snr_new = ( ( flux_inter * 0.0 ) + sn )
        ;; Make a fake noise array 
        sn_fake = 5000.0D
        noise_fake = ( flux_inter / sn_fake )
        ;; Degrade the spectrum 
        arm_addnoise, flux_inter, noise_fake, snr_new, $
            signal_new=flux_new, noise_new=noise_new
        flux_inter = flux_new 
    endif
    if keyword_set( debug ) then begin 
        snr_test = der_snr( flux_new ) 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' Desired SNR after degrading  : ', sn 
        print, ' Measured SNR after degrading : ', snr_test
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        if NOT keyword_set( normalize ) then begin 
            cgPlot, wave_inter, flux_new, /overplot, color='BLU7', thick=1.5 
        endif 
    endif 
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the STARLIGHT file 
    openw, 20, sl_file, width=400 
    for ii = 0, ( n_pix_inter - 1 ), 1 do begin 
        if NOT keyword_set( sn ) then begin 
            printf, 20, $
                strcompress( string( wave_inter[ii] ), /remove_all ) + $
                '    ' + $
                strcompress( string( flux_inter[ii] ) )
        endif else begin 
            printf, 20, $
                strcompress( string( wave_inter[ii] ), /remove_all ) + $
                '    ' + $
                strcompress( string( flux_inter[ii] ) ) + '    ' + $ 
                strcompress( string( noise_new[ii] ) ) + '    0 '
        endelse
    endfor
    close, 20
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro list_mius_cspbase

    sfh_list = 'sfh_use.lis' 
    readcol, sfh_list, sfh_str, format='A', delimiter=' ', comment='#', /silent
    n_sfh = n_elements( sfh_str ) 
    sfh_str = strcompress( sfh_str, /remove_all )

    prefix = [ 'mius_un13', 'mius_un18' ]
    n_pre = n_elements( prefix )

    for i = 0, ( n_pre - 1 ), 1 do begin 

        index_time = 96 
        value_time = 13
        base_file = prefix[i] + '_csp_13.base'
        openw, 10, base_file, width=500 

        ;; z5 
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            csp_file = prefix[i] + 'z5_' + sfh_str[j] + '_n100.fits'
            hs_miuscat_csp_tosl, csp_file, index=index_time, $
                sigma=70.0, base_line=base_line
            printf, 10, base_line 
        endfor 

        ;; z6 
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            csp_file = prefix[i] + 'z6_' + sfh_str[j] + '_n100.fits'
            hs_miuscat_csp_tosl, csp_file, index=index_time, $
                sigma=70.0, base_line=base_line
            printf, 10, base_line 
        endfor 

        ;; z7 
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            csp_file = prefix[i] + 'z7_' + sfh_str[j] + '_n100.fits'
            hs_miuscat_csp_tosl, csp_file, index=index_time, $
                sigma=70.0, base_line=base_line
            printf, 10, base_line 
        endfor 

        ;;
        close, 10 
        free_lun, 10

    endfor 

end 

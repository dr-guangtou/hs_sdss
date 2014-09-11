;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro measure_batch 

    sfh_list = 'sfh_use.lis' 
    readcol, sfh_list, sfh_str, format='A', delimiter=' ', comment='#', /silent
    ;;
    sfh_str = strcompress( sfh_str, /remove_all )
    n_sfh = n_elements( sfh_str ) 
    ;;
    imf_str = [ 'mius_un13', 'mius_un18' ]
    n_imf = n_elements( imf_str )
    ;;
    met_str = [ 'z5', 'z6', 'z7' ]
    n_met = n_elements( met_str )

    for i = 0, ( n_imf - 1 ), 1 do begin 
        for j = 0, ( n_met - 1 ), 1 do begin 
            for k = 0, ( n_sfh - 1 ), 1 do begin 
                csp_file = imf_str[i] + met_str[j] + '_' + sfh_str[k] + $
                    '_n100.fits'
                hs_miuscat_csp_index, csp_file, index_list='hs_index_old.lis', $
                    /save_fits, min_time=11.2, max_time=13.7, sigma=348.0 
            endfor 
        endfor
    endfor

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_miuscat_csp_index, csp_file, index_list=index_list, $
    save_fits=save_fits, silent=silent, min_time=min_time, max_time=max_time, $
    last=last, sigma=sigma

    ;; Default sigma value
    sigma_default = 350.0
    if keyword_set( sigma ) then begin 
        sigma = float( sigma ) 
    endif else begin 
        sigma = sigma_default 
    endelse

    ;; check the input file 
    csp_file = strcompress( csp_file, /remove_all ) 
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
        ;; csp line 
        csp_head = ' SSP_STR , SFH_STR , IMF_STR , IMF_SLOPE , MET_STR , ' + $ 
            ' SFH_TS , SFH_NP , SFH_TAU , SFH_TR '
        csp_line = ssp_str + ' , ' + sfh_str + ' , ' + imf_str + ' , ' + $
            imf_slope + ' , ' + met_str + ' , ' + sfh_ts + ' , ' + $ 
            sfh_np + ' , ' + sfh_ta + ' , ' + sfh_tr 
    endelse
    ;;
    if NOT file_test( csp_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input CSP file !! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        csp_struc = mrdfits( csp_file, 1, head, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the input CSP fits file !! ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif else begin 
            if ( ( tag_indx( csp_struc, 'WAVE' ) EQ -1 ) OR $ 
                 ( tag_indx( csp_struc, 'FLUX' ) EQ -1 ) OR $ 
                 ( tag_indx( csp_struc, 'TIME' ) EQ -1 ) ) then begin 
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 print, ' The CSP structure is incompatible !! Check !! '
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 message, ' '
             endif else begin 
                 lambda = csp_struc.wave 
                 time   = csp_struc.time 
                 n_pix  = n_elements( lambda ) 
                 n_time = n_elements( time ) 
                 flux_arr = csp_struc.flux 
                 sigma_input = csp_struc.resolution
                 if ( ( size( flux_arr, /dimension ) )[0] NE n_pix ) then begin 
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     print, ' The flux and wave array should be the same in size'
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     message, ' '
                 endif
                 if ( ( size( flux_arr, /dimension ) )[1] NE n_time ) then begin 
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     print, ' The flux and time array should be the same in size'
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     message, ' '
                 endif
             endelse
         endelse
     endelse

     ;; Check the input index array 
     index_default = 'hs_index_all.lis' 
     if file_test( index_default ) then begin 
         find_default = 1 
     endif else begin 
         find_default = 0 
     endelse
     if keyword_set( index_list ) then begin 
         index_list = strcompress( index_list, /remove_all ) 
         if file_test( index_list ) then begin 
             index_list = index_list 
         endif else if ( find_default EQ 1 ) then begin 
             index_list = index_default 
         endif else begin 
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             print, ' Can not find a useful index list !! '
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             message, ' ' 
         endelse
     endif else begin 
         if ( find_default EQ 1 ) then begin 
             index_list = index_default 
         endif else begin 
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             print, ' Can not find a useful index list !! '
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             message, ' ' 
         endelse 
     endelse

     ;; Define the output file structure 
     csv_file  = hs_string_replace( csp_file, '.fits', '_index.csv'  ) 
     fits_file = hs_string_replace( csp_file, '.fits', '_index.fits' )

     ;; Open the csv file for reading 
     openw, 10, csv_file, width=6000  

     if keyword_set( last ) then begin 
         n_0 = ( n_time - 1 ) 
         n_1 = ( n_time - 1 ) 
     endif else begin 
         if keyword_set( min_time ) then begin 
             index_min = where( time GE min_time, n_min )
             if ( n_min GT 0 ) then begin 
                 n_0 = index_min[0] 
             endif else begin 
                 print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                 print, ' WARNNING: Bad choice of min_time !! '
                 print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                 n_0 = 0 
             endelse
         endif else begin 
             n_0 = 0 
         endelse
         if keyword_set( max_time ) then begin 
             index_max = where( time LE max_time, n_max )
             if ( n_max GT 0 ) then begin 
                 n_1 = index_max[ n_max - 1] 
             endif else begin 
                 print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                 print, ' WARNNING: Bad choice of max_time !! '
                 print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                 n_1 = ( n_time - 1 )  
             endelse
         endif else begin 
             n_1 = ( n_time - 1 )  
         endelse
     endelse
     if ( n_0 GT n_1 ) then begin 
         print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
         print, ' WARNING: Bad choice of min/max_time !! Check !! '
         print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
         n_0 = 0 
         n_1 = ( n_time - 1 ) 
     endif

     ;; Main iteration 
     for ii = n_0, n_1, 1 do begin 

         ;; Time 
         t_csp = time[ii]
         ;; Use time as prefix 
         prefix = strcompress( string( t_csp, format='(F6.2)' ), /remove_all )
         if NOT keyword_set( silent ) then begin 
             print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
             print, ' TIME : ' + prefix + ' Gyr' 
         endif

         ;; Flux array 
         wave = lambda 
         flux = flux_arr[*,ii] 
         min_wave = min( wave ) 
         max_wave = max( wave )

        ;; Calculate the difference for velocity dispersion 
        if ( sigma_input GE sigma ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' The target velocity dispersion is lower than the current one!'
            print, '     NO convolution will be applied ! '
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            wave_conv = wave 
            flux_conv = flux
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
            flux_new = interpolate( flux, index_new )
            ;; Get the difference in velocity dispersion
            sigma_diff = sqrt( sigma^2.0 - sigma_input^2.0 )
            smoothing = ( sigma_diff / velscale )  ;; in pixels 
            ;; Do the convolution
            flux_conv = gconv( flux_new, smoothing )
        endelse

        ;; Get the index structure 
        index_struc = hs_list_measure_index( flux_conv, wave_conv, snr=600.0, $
            /silent, header_line=header_line, index_line=index_line, $
            prefix=prefix, index_list=index_list )

        if ( ii EQ n_0 ) then begin 
            printf, 10, header_line + ' , ' + csp_head
        endif 
        printf, 10, index_line + ' , ' + csp_line

        if keyword_set( save_fits ) then begin 
            if ( ii EQ n_0 ) then begin 
                mwrfits, index_struc, fits_file, /create 
            endif else begin 
                mwrfits, index_struc, fits_file 
            endelse 
        endif 

     endfor

     ;; close file 
     close, 10

end

function hs_starlight_expand_out, sl_file, deconv=deconv, dered=dered, $
    plot=plot, basevd=basevd, debug=debug 

    ;; Speed of light in km/s 
    c = 299792.458d

    ;; Velocity dispersion of base file  
    if keyword_set( basevd ) then begin 
        vd_base = float( basevd ) 
    endif else begin 
        vd_base = 70.0D    ;; km/s as default value 
    endelse

    ;; Check the STARLIGHT output file
    if NOT file_test( sl_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input file: ' + sl_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        temp = strsplit( sl_file, '.', /extract ) 
        out_string = strcompress( temp[0], /remove_all ) 
        ;; The name of the results file
        res_file = out_string + '_result.fits' 
        if file_test( res_file ) then begin 
            ;; Read three structures from the result files 
            spec_struc = mrdfits( res_file, 1, status=status1, /silent )
            sl_struc   = mrdfits( res_file, 2, status=status2, /silent ) 
            base_struc = mrdfits( res_file, 3, status=status3, /silent )
            if ( ( status1 NE 0 ) OR ( status2 NE 0 ) OR ( status3 NE 0 ) ) $
                then begin  
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the result file: ' + sl_file 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif 
        endif else begin 
            ;; If the result file is not found, try run parse_sl_output 
            hs_starlight_read_out, sl_file, sl_struc, base_struc, spec_struc, $
              /quiet, /save_fits 
            ;; Read three structures from the result files 
            spec_struc = mrdfits( res_file, 1, status=status1, /silent )
            sl_struc   = mrdfits( res_file, 2, status=status2, /silent ) 
            base_struc = mrdfits( res_file, 3, status=status3, /silent )
            if ( ( status1 NE 0 ) OR ( status2 NE 0 ) OR ( status3 NE 0 ) ) $
                then begin  
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the result file: ' + sl_file 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif 
        endelse 
    endelse
    
    ;; Name of the plot 
    plot_file = out_string + '_result.eps'
    
    ;; Number of bases  
    n_base = n_elements( base_struc.xj )
    ;; Sum of the xj vector
    xj_sum = sl_struc.xj_sum 
    ;; min and max value for different spectra
    min_lam = min( spec_struc.spec_lam )
    max_lam = max( spec_struc.spec_lam )
    min_obs = min( spec_struc.spec_obs )
    max_obs = max( spec_struc.spec_obs )
    min_syn = min( spec_struc.spec_syn )
    max_syn = max( spec_struc.spec_syn )
    
    ;; wavelength separation for the input spectrum 
    dl = sl_struc.dl 
    ;; pixel value at the wavelength for normalization for synthetic spectrum 
    l_base_norm = sl_struc.l_norm 

    ;; The number of useful SSPs 
    index_ssp_use = where( base_struc.xj GT 0.0D ) 
    if ( index_ssp_use[0] NE -1 ) then begin 
        n_ssp_use = n_elements( index_ssp_use ) 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, 'There are ', n_ssp_use, ' SSPs with x_j > 0.0%'
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' There is something wrong with this STARLIGHT run ! '
        print, ' There seems to be no SSP with more than 2% contribution' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endelse  

    ;; Get the velocity and velocity dispersion value 
    v0_min = sl_struc.v0_min 
    vd_min = sl_struc.vd_min 
    ;; Get the extinction value 
    av_min = sl_struc.av_min 
    ;; And the extinction law 
    av_law = sl_struc.red_law 

    ;; Isolate the information for the useful SSPs
    base_use = base_struc[ index_ssp_use ] 
    ;; 
    check = ( n_ssp_use - 1 )

    for i = 0, ( n_ssp_use - 1 ), 1 do begin 

        ssp_file = base_use[i].ssp_loc
        ssp_frac = ( base_use[i].xj / 100.0D )

        if file_test( ssp_file ) then begin 
            
            ;; Read in the SSP spectra
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' Read in the SSP: ' + ssp_file 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            readcol, ssp_file, ssp_wave, ssp_flux, FORMAT='F,D', /silent, $
                comment='#', delimiter=' ' 

            ;; Normalize the flux to avoid numerical issue
            ;; Use the value of (L/M)_j in the base structure 
            ssp_flux = ( ssp_flux / base_use[i].l2m )

            ;; Define a common, linear-sampled wavelength array 
            if ( i EQ 0 ) then begin 
                min_wave = round( min( ssp_wave ) )
                max_wave = round( max( ssp_wave ) )
                n_pix_inter = ( max_wave - min_wave ) 
                wave_inter = min_wave + findgen( n_pix_inter ) * 1.0 
                index_inter = findex( ssp_wave, wave_inter ) 
                ;; Build an array for the output
                full_spec = fltarr( n_pix_inter ) 
                full_ssps = fltarr( n_pix_inter, n_ssp_use )
                if keyword_set( debug ) then begin 
                    print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                    print, ' MIN_WAVE : ', min_wave
                    print, ' MAX_WAVE : ', max_wave
                    print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                endif
            endif 

            ;; Interpolate the SSP spectrum to the common wavelength grid
            flux_inter = interpolate( ssp_flux, index_inter )
            if ( keyword_set( debug ) and ( i EQ check ) ) then begin 
                cgPlot, wave_inter, flux_inter, xstyle=1, ystyle=1, $ 
                    ;xrange=[ 8000, 8400 ], $
                    ;xrange=[ 4000, 4300 ], $
                    xrange=[ min_wave, max_wave ], $
                    position=[0.08,0.09,0.99,0.99], linestyle=0, thick=1.5, $
                    color=cgColor( 'Dark Gray' )
            endif 

            ;; Correction for the velocity 
            ;v0_c = ( 1.0 * v0_min / c ) 
            v0_c = 0.0
            wave_inter = wave_inter * SQRT( ( 1.0D + v0_c ) / ( 1.0D - v0_c ) ) 
            if ( keyword_set( debug ) and ( i EQ check ) ) then begin 
                print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                print, ' V0_MIN = ', v0_min
                print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                cgPlot, wave_inter, flux_inter, /overplot, $
                    linestyle=0, thick=1.5, color=cgColor( 'Red4' )
            endif

            ;; Convolve the SSP to the velocity dispersion of the observed 
            ;; spectrum 
            if ( ( NOT keyword_set( deconv ) ) AND ( vd_base LT vd_min ) ) $
                then begin 

                ;; Wavelength separation for log10-rebin spectra 
                dlogwave = ( 1.0D-4 )
                ;; The velocity scale 
                velscale = ( dlogwave * c * alog( 10.0D ) )
                ;; Define a new wavelength array
                logwave0 = alog10( min_wave )
                logwave  = logwave0 + findgen( 20000 ) * dlogwave 
                wave_conv = ( 10.0^logwave )
                wave_conv = wave_conv[ where( wave_conv LE max_wave ) ]
                ;; Interpolate the spectrum to the log10-rebinned wavelength grid
                index_inter2 = findex( wave_inter, wave_conv ) 
                flux_inter2 = interpolate( flux_inter, index_inter2 )
                ;; Get the difference in velocity dispersion
                sigma_diff = sqrt( vd_min^2.0 - vd_base^2.0 )
                smoothing = ( sigma_diff / velscale )  ;; in pixels 
                ;; Do the convolution
                flux_conv = gconv( flux_inter2, smoothing )
                ;; Interpolate it back to the common linear wavelength 
                index_inter3 = findex( wave_conv, wave_inter ) 
                flux_inter = interpolate( flux_conv, index_inter3 )
                
                if ( keyword_set( debug ) and ( i EQ check ) ) then begin 
                   print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                   print, ' Vd_MIN = ', vd_min
                   print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
                    cgPlot, wave_inter, flux_inter, /overplot, $ 
                        linestyle=0, thick=2.0, color=cgColor( 'BlU3' ) 
                endif 

            endif

            ;; Check the reddening law:  
            ;; TODO: Now only supports the CCM and CAL
            case strlowcase( strcompress( av_law, /remove_all ) ) of 
                'ccm': begin 
                    r_v = 3.1 
                    k_wave = k_lambda( wave_inter, r_v=r_v, /ccm )
                    q_wave = ( k_wave / r_v ) 
                    index_temp = where( $
                        ( wave_inter GT ( l_base_norm - dl + 0.1 ) ) AND $
                        ( wave_inter LT ( l_base_norm + dl - 0.1 ) ) ) 
                    if ( index_temp[0] NE -1 ) then begin 
                        q_norm = median( q_wave[ index_temp ] )
                    endif else begin 
                        message, 'Weird!!!'
                    endelse
                    red_cor = ( -0.4D * av_min * ( q_wave - q_norm ) )
                    norm_red = ( 10.0D^( -0.4D * av_min * q_norm ) )
                    flux_red = ( 10.0D^( red_cor ) ) * flux_inter
                    end 
                'cal': begin 
                    r_v = 4.0 
                    k_wave = k_lambda( wave_inter, r_v=r_v, /calzetti )
                    q_wave = ( k_wave / r_v ) 
                    index_temp = where( $
                        ( wave_inter GT ( l_base_norm - dl + 0.1 ) ) AND $
                        ( wave_inter LT ( l_base_norm + dl - 0.1 ) ) ) 
                    if ( index_temp[0] NE -1 ) then begin 
                        q_norm = median( q_wave[ index_temp ] )
                    endif else begin 
                        message, 'Weird!!!'
                    endelse
                    red_cor = ( -0.4D * av_min * ( q_wave - q_norm ) )
                    norm_red = ( 10.0D^( -0.4D * av_min * q_norm ) )
                    flux_red = ( 10.0D^( red_cor ) ) * flux_inter
                    end 
                else:  begin 
                    flux_red = flux_inter 
                    end 
            endcase

            ;; Reddening the spectrum 
            if NOT keyword_set( dered ) then begin 

                flux_inter = flux_red
                ssp_frac = ssp_frac 

            endif else begin 

                flux_inter = flux_inter 
                ssp_frac = ( ssp_frac / norm_red ) 
                
            endelse

            if ( keyword_set( debug ) and ( i EQ check ) ) then begin 
               print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               print, ' RED_LAW  : ', av_law 
               print, ' AV_MIN   : ', av_min 
               print, ' NORM_RED : ', norm_red
               print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
               cgPlot, wave_inter, flux_inter, /overplot, $
                   linestyle=0, thick=2.0, color=cgColor( 'ORG5' ) 
            endif 

                
        endif else begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the ssp file: ' + ssp_file 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endelse

        ;; Re-normalize the spectra according to its contribution
        flux_norm = ( flux_inter * ssp_frac ) 

        ;; Output 
        full_ssps[ *, i ] = flux_norm
        full_spec = full_spec + flux_norm
             
    endfor

    ;; Define a structure for output 
    out_struc = { wave:wave_inter, spec:full_spec, ssps:full_ssps }
    return, out_struc

    if keyword_set( debug ) then begin 
        cgPlot, wave_inter, full_spec, xstyle=1, ystyle=1
        for j = 0, ( n_ssp_use - 1 ), 1 do begin 
            cgPlot, wave_inter, full_ssps[*,j], /overplot, color=cgColor('RED3')
        endfor
    endif

    spec_syn_norm = spec_struc.spec_syn 
    spec_rec_norm = full_spec
    ;; Range of flux 
    min_flux = min( [ spec_syn_norm, spec_rec_norm ] )
    max_flux = max( [ spec_syn_norm, spec_rec_norm ] )

    if keyword_set( debug ) then begin 
        print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        print, ' MIN_FLUX : ', min_flux 
        print, ' MAX_FLUX : ', max_flux 
        print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    endif

    if keyword_set( plot ) then begin 
        cgPlot, wave_inter, spec_rec_norm, xstyle=1, ystyle=1, $ 
            xrange=[ min_wave, max_wave ], $
            yrange=[ 0.301, max_flux ], $
            /nodata, position=[ 0.08, 0.12, 0.99, 0.99 ], $
            xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
            charsize=2.5, charthick=2.0, $
            xthick=3.0, ythick=3.0
        cgPlot, wave_inter, spec_rec_norm, /overplot, $ 
            linestyle=0, thick=1.5, color=cgColor( 'BLU6' )
        cgPlot, spec_struc.spec_lam, spec_syn_norm, /overplot, $
            linestyle=0, thick=2.0, color=cgColor( 'RED6' ) 
    endif

    ;; XXX Old, dirty debug stuff
    ;index_aa = findex( wave_inter, spec_struc.spec_lam ) 
    ;flux_aa = interpolate( spec_rec_norm, index_aa )
    ;print, median( spec_syn_norm / flux_aa )

end

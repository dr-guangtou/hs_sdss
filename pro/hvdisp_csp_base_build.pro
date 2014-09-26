pro hvdisp_csp_base_build, index_list=index_list, n_time=n_time 

    hvdisp_location, hvdisp_home, data_home

    if keyword_set( index_list ) then begin 
        index_list = hvdisp_home + 'pro/lis/' + index_list 
    endif else begin 
        index_list = hvdisp_home + 'pro/lis/hs_index_all.lis'
    endelse

    if NOT keyword_set( n_time ) then begin 
        n_time = 100 
    endif else begin 
        n_time = long( n_time ) 
    endelse

    mius_file = hvdisp_home + 'lib/mius_sigma70.fits'
    if NOT file_test( mius_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP files !!! '
        print, mius_file
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    endif 

    print, '###################################################################'
    t0 = systime(1) 

    ;; Choice of SSP parameters
    imf_arr = [ 'kb1.30', 'un1.30', 'un2.00' ]
    met_arr = [ 'z4', 'z5', 'z6', 'z7' ]
    n_p_arr = [ 1.0, 2.0, 4.0 ]
    tau_arr = [ 0.2, 0.6, 1.2, 1.8 ]
    tru_arr = [ 0.0, 4.0 ]

    ;; For test
    ;imf_arr = [ 'kb1.30' ]
    ;met_arr = [ 'z4' ]
    ;n_p_arr = [ 2.0 ]
    ;tau_arr = [ 1.2 ]
    ;tru_arr = [ 0.0 ]

    n_imf = n_elements( imf_arr ) 
    n_met = n_elements( met_arr ) 
    n_np  = n_elements( n_p_arr ) 
    n_tau = n_elements( tau_arr ) 
    n_tru = n_elements( tru_arr ) 
    n_csp = ( n_imf * n_met * n_np * n_tau * n_tru )

    for i = 0, ( n_imf - 1 ), 1 do begin 
        for j = 0, ( n_met - 1 ), 1 do begin 
            for k = 0, ( n_np - 1 ), 1 do begin 
                for m = 0, ( n_tau - 1 ), 1 do begin 
                    for n = 0, ( n_tru - 1 ), 1 do begin 

                        csp_out = hs_miuscat_csp_build( mius_file, $
                            imf = imf_arr[i], $
                            metal = met_arr[j], $
                            np  = n_p_arr[k], $
                            tau = tau_arr[m], $
                            tr  = tru_arr[n], $
                            t_cosmos = 14.0, $
                            ts = 13.6, $
                            n_time=n_time, $
                            /savefits )

                        csp_fits = csp_out[0].filename 

                        if file_test( csp_fits ) then begin 

                            ;;
                            hs_miuscat_csp_tosl, csp_fits, index=(n_time-1) 
                            print, '###########################################'
                            print, ' ' + string(n_time-1) + $
                                ': ' + string( csp_out.time[(n_time-1)] ) + $
                                '  ' + string( csp_out.time_lb[(n_time-1)] ) 
                            ;;
                            hs_miuscat_csp_tosl, csp_fits, index=(n_time-10) 
                            print, '###########################################'
                            print, ' ' + string(n_time-10) + $
                                ': ' + string( csp_out.time[(n_time-10)] ) + $
                                '  ' + string( csp_out.time_lb[(n_time-10)] ) 
                            ;;
                            hs_miuscat_csp_tosl, csp_fits, index=(n_time-20) 
                            print, '###########################################'
                            print, ' ' + string(n_time-20) + $
                                ': ' + string( csp_out.time[(n_time-20)] ) + $
                                '  ' + string( csp_out.time_lb[(n_time-20)] ) 
                            ;;
                            hs_miuscat_csp_tosl, csp_fits, index=(n_time-30) 
                            print, '###########################################'
                            print, ' ' + string(n_time-30) + $
                                ': ' + string( csp_out.time[(n_time-30)] ) + $
                                '  ' + string( csp_out.time_lb[(n_time-30)] ) 
                            ;; 
                            hs_miuscat_csp_plot, csp_fits, /topng, /togif, $
                                gif_delay=10
                            ;; 
                            hs_miuscat_csp_index, csp_fits, sigma=350.0, $
                                index_list=index_list, /save_fits, $
                                min_time=10.0, max_time=13.7, /silent

                        endif else begin 

                            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                            print, ' Something is wrong with the CSP file !! '
                            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                            message, ' ' 

                        endelse

                        free_all 

                    endfor
                endfor
            endfor
        endfor
    endfor

    print, '###################################################################'
    print, '  TOTAL TIME : ', ( systime(1) - t0 ), ' Seconds'
    print, '###################################################################'

end 

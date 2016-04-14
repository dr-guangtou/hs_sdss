pro stack_index_measure 

    struc_stack = mrdfits( 'sdss_stack.fits', 1 ) 
    n_stack = n_elements( struc_stack.file ) 

    ;; Open the output file 
    openw, 20, 'sdss_stack_index.csv', width=8000 

    comma = ' , '

    ;; 
    for ii = 0, ( n_stack - 1 ), 1 do begin 

        wave = struc_stack[ii].wave 
        flux = struc_stack[ii].flux 

        file     = struc_stack[ii].file
        sigma    = struc_stack[ii].sigma
        redshift = struc_stack[ii].redshift 
        group    = struc_stack[ii].group
        method   = struc_stack[ii].method
        s_str    = struc_stack[ii].s_str 

        stack_head = ' , File , Redshift , Sigma , Group , Method , SigStr '
        stack_line = comma + file + comma + string( redshift ) + comma + $ 
            string( sigma ) + comma + group + comma + method + comma + s_str

        ouput_struc = hs_list_measure_index( flux, wave, $
            index_list='hs_index_stack_old.lis', snr=800.0, /silent, $
            prefix=file, header_line=header_line, index_line=index_line )

        if ( ii EQ 0 ) then begin 
            printf, 20, header_line + stack_head 
        endif 
        printf, 20, index_line + stack_line

    endfor

    ;;
    close, 20

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_stack_txt_summary, type_str, output_file=output_file, $
    min_wave=min_wave, max_wave=max_wave, emirem=emirem

    ;; Get the spectra list 
    type_str = strcompress( type_str, /remove_all )
    spawn, 'ls z*' + type_str + '*.txt', spec_list 

    if ( spec_list[0] EQ '' ) then begin 
        message, ' There is something wrong with the spectra files !!' 
    endif else begin 
        n_spec = n_elements( spec_list ) 
        print, 'About to summarize ' + str(n_spec) + ' spectra !!'
    endelse 
    ;; 
    if not keyword_set(output_file) then begin 
        output_file = 'sdss_stack.fits'
    endif else begin 
        output_file = strcompress(output_file, /remove_all)
    endelse

    if not keyword_set(min_wave) then begin 
        min_wave = 3650.0 
    endif else begin 
        min_wave = min_wave > 3500.0
    endelse
    if not keyword_set(max_wave) then begin 
        max_wave = 8600.0 
    endif else begin 
        max_wave = max_wave < 8600.0
    endelse

    wave_arr = min_wave + findgen( max_wave - min_wave )
    n_pix = n_elements( wave_arr )

    stack_struc = { file:'', redshift:0.0, sigma:0.0, method:'', group:'', $
                    z_str:'', g_str:'', s_str:'', emirem:'', $
                    min_wave:0.0, max_wave:0.0, min_flux:0.0, max_flux:0.0, $
                    wave:fltarr( n_pix ), flux:fltarr( n_pix ), error:fltarr( n_pix ) } 
    stack_struc = replicate( stack_struc, n_spec ) 

    for i = 0, ( n_spec - 1 ), 1 do begin 

        spec_file = strcompress( spec_list[i], /remove_all ) 

        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' SPECTRUM : ' + spec_file
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

        if keyword_set(emirem) then begin 
            readcol, spec_file, spec_wave, flux_ori, spec_flux, emi_flux, $ 
                format='F,F,F,F', comment='#', delimiter=' ', /silent 
        endif else begin 
            readcol, spec_file, spec_wave, spec_flux, spec_err, spec_mask, $ 
                format='F,F,F,F', comment='#', delimiter=' ', /silent 
        endelse

        ;; Move to air wavelength
        vactoair, spec_wave, wave_air 

        spec_str = str_replace( spec_file, '.txt', '' )
        temp = strsplit( spec_str, '_', /extract ) 

        n_seg = n_elements(temp)
        z_seg = temp[0]
        s_seg = temp[1] 
        m_seg = temp[2]
        if n_seg EQ 3 then begin 
            e_seg = 'none'
        endif else begin 
            e_seg = temp[3] + '_' + temp[4]
        endelse
        
        z_ind = long( strmid( z_seg, 1, 1 ) )
        s_str = strmid( s_seg, 0, 2 )
        s_ind = strmid( s_seg, 1, 1 ) 
        g_ind = strmid( s_seg, 2, 1 )

        stack_struc[i].file      = spec_file 
        stack_struc[i].method    = m_seg 
        stack_struc[i].emirem    = e_seg 
        stack_struc[i].group     = g_ind 
        stack_struc[i].z_str     = z_seg 
        stack_struc[i].s_str     = s_str  
        stack_struc[i].g_str     = g_ind
        stack_struc[i].wave      = wave_arr  

        case z_ind of 
            0 : begin 
                    stack_struc[i].redshift = 0.075
                    stack_struc[i].min_wave = 3700.0
                    stack_struc[i].max_wave = 8500.0
                    if keyword_set(emirem) then begin 
                        median_sn = 700
                    endif else begin 
                        median_sn = median( spec_flux / spec_err )
                    endelse
                end
            1 : begin 
                    stack_struc[i].redshift = 0.045
                    stack_struc[i].min_wave = 3750.0
                    stack_struc[i].max_wave = 8600.0
                    if keyword_set(emirem) then begin 
                        median_sn = 570
                    endif else begin 
                        median_sn = median( spec_flux / spec_err )
                    endelse
                end 
            2 : begin 
                    stack_struc[i].redshift = 0.100
                    stack_struc[i].min_wave = 3650.0
                    stack_struc[i].max_wave = 8300.0
                    if keyword_set(emirem) then begin 
                        median_sn = 600
                    endif else begin 
                        median_sn = median( spec_flux / spec_err )
                    endelse
                end 
            3 : begin 
                    stack_struc[i].redshift = 0.155
                    stack_struc[i].min_wave = 3600.0
                    stack_struc[i].max_wave = 8150.0
                    if keyword_set(emirem) then begin 
                        median_sn = 600
                    endif else begin 
                        median_sn = median( spec_flux / spec_err )
                    endelse
                end 
            else : message, 'Something wrong with the spectrum: ' + spec_file 
        endcase

        stack_struc[i].flux = interpol( flux_ori, wave_air, wave_arr ) 
        if keyword_set(emirem): 
            stack_struc[i].error = stack_struc[i].flux / median_sn 
        endif else begin 
            error_temp = interpol( (error_ori^2.0), wave_ori, wave_arr ) 
            stack_struc[i].error     = sqrt( error_temp )
        endelse

        index_nodata = where( $
            ( wave_arr LT stack_struc[i].min_wave ) OR $
            ( wave_arr GT stack_struc[i].max_wave ) )
        if ( index_nodata[0] NE -1 ) then begin 
            stack_struc[i].flux[ index_nodata ]  = !VALUES.F_NaN
            stack_struc[i].error[ index_nodata ] = !VALUES.F_NaN
        endif 

        stack_struc[i].min_flux  = min( stack_struc[i].flux )  
        stack_struc[i].max_flux  = max( stack_struc[i].flux )  

        case s_ind of 
            '1' : stack_struc[i].sigma = 150.0
            '2' : stack_struc[i].sigma = 170.0
            '3' : stack_struc[i].sigma = 190.0
            '4' : stack_struc[i].sigma = 210.0
            '5' : stack_struc[i].sigma = 230.0
            '6' : stack_struc[i].sigma = 250.0
            '7' : stack_struc[i].sigma = 275.0
            '8' : stack_struc[i].sigma = 305.0
            else : message, 'Something wrong with the spectrum: ' + spec_file 
        endcase

    endfor

    mwrfits, stack_struc, output_file, /create
    print, ' STRUCTURE FILE HAS BEEN SAVED TO: ' + output_file +  ' !!'
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

end

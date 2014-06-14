pro hs_starlight_repeat, sl_input, n_repeat, is_error=is_error

    n_repeat = long( n_repeat )
    n_string = strcompress( string( n_repeat ), /remove_all ) 
    
    temp = strsplit( sl_input, '.', /extract ) 
    n_seg = n_elements( temp ) 
    if ( n_seg EQ 1 ) then begin 
        input_string = temp[0] + '_' + n_string + '.in'  
    endif else begin 
        input_string = ''
        for i = 0, ( n_seg - 2 ), 1 do begin 
            input_string = input_string + temp[i] 
        endfor 
        input_string = input_string + '_' + n_string + '.in' 
    endelse

    ;; INPUT Files
    if NOT file_test( sl_input ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the STARLIGHT input file: ' + sl_input 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        n_lines = file_lines( sl_input ) 
        input_arr = strarr( n_lines ) 
        openr, 10, sl_input 
        readf, 10, input_arr 
        close, 10 
    endelse

    ;; Lines for number of runs 
    input_arr[0] = n_string + '                         [Number of fits to run]' 

    ;; Lines for the input configuration 
    temp = strsplit( input_arr[15], ' ', /extract ) 
    input_spec  = temp[0] 
    config_file = temp[1]
    base_file   = temp[2] 
    mask_file   = temp[3] 
    dered_law   = temp[4] 
    v0_guess    = temp[5] 
    vd_guess    = temp[6] 
    out_file    = temp[7] 

    temp = strsplit( out_file, '.', /extract )  
    n_seg = n_elements( temp ) 
    if ( n_seg EQ 1 ) then begin 
        output_string = temp[0]  
    endif else begin 
        output_string = ''
        for i = 0, ( n_seg - 2 ), 1 do begin 
            output_string = output_string + temp[i] 
        endfor 
    endelse

    ;; Adjust the input spectra 
    if NOT file_test( input_spec ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        print, ' Can not find the input spectrum : ' + input_spec 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        message, '  '
    endif else begin 
        if keyword_set( is_error ) then begin 
            readcol, input_spec, wave, flux, error, flag, format='F,F,F,I', $
                comment='#', delimiter=' ', /silent 
            n_pixel = n_elements( wave ) 
        endif else begin 
            readcol, input_spec, wave, flux, format='F,F', $
                comment='#', delimiter=' ', /silent 
            n_pixel = n_elements( wave ) 
            error = fltarr( n_pixel ) 
            flag  = intarr( n_pixel )
        endelse
    endelse

    ;; Write the input file 
    openw, 20, input_string, width=500 
    for i = 0, 14, 1 do begin 
        printf, 20, input_arr[i] 
    endfor
    for i = 0, ( n_repeat - 1 ), 1 do begin 
        index = strcompress( string( i+1 ), /remove_all ) 
        printf, 20, input_spec + ' ' + config_file + ' ' + base_file + ' ' + $ 
            mask_file + ' ' + dered_law + ' ' + v0_guess + ' ' + vd_guess + $
            ' ' + output_string + '_' + index + '.out'  
    endfor
    close, 20

end

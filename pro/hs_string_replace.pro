function hs_string_replace, str0, str1, str2 

    n_param = n_params()
    if ( n_param NE 3 ) then begin 
        message, ' str_out = hs_string_replace( str_in, find, replace ) '
    endif 

    str_in = str0
    str_out = str_in
    str_size = size( str_in )
    n_str    = n_elements( str_size ) 
    if ( str_size[ n_str - 2 ] NE 7 ) then begin 
        message, ' The input has to be a string array '
    endif 

    find = strcompress( string( str1 ), /remove_all )
    repl = strcompress( string( str2 ), /remove_all )

    str_pos = strpos( str_in, find )
    here = where( str_pos NE -1, n_replace ) 

    if ( n_replace NE 0 ) then begin 

        find_len = strlen( find ) 
        for ii = 0, ( n_replace - 1 ), 1 do begin 
            jj = here[ii] 
            prefix = strmid( str_in[jj], 0, str_pos[jj] ) 
            suffix = strmid( str_in[jj], ( str_pos[jj] + find_len ), $ 
                ( strlen( str_in[jj] ) - ( str_pos[jj] + find_len ) ) ) 
            str_out[jj] = prefix + repl + suffix 
        endfor 
    endif else begin 
        return, str_in 
    endelse

    return, str_out

end

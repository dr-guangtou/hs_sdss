function hs_string_extract, str_arr, tag  ;;, status=status, number=number

    ;; TODO: return status and number

    tag_posit = strpos( str_arr, tag ) 
    tag_exist = where( tag_posit NE -1 ) 

    if ( tag_exist[0] EQ -1 ) then begin 
        line = '' 
        if keyword_set( number ) then begin 
            number = 0 
        endif 
    endif else begin 
        line = str_arr[ tag_exist ] 
        n_line = n_elements( tag_exist ) 
        if keyword_set( number ) then begin 
            number = n_line 
        endif 
    endelse

    return, line

end

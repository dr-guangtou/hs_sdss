function hs_retrieve_para, chunk, tag, sep, num

    line = hs_string_extract( chunk, tag )
    if ( n_elements( line ) EQ 1 ) then begin 
        if ( line[0] NE '' ) then begin 
            temp = strsplit( line, sep, /extract ) 
            n_seg = n_elements( temp ) 
            if ( num GT ( n_seg - 1) ) then begin 
                para = !VALUES.F_NaN 
            endif else begin 
                para = strcompress( temp[ num ], /remove_all ) 
            endelse
        endif else begin 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            print, ' Can not find line that include: ' + tag + ' ! ' 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            para = !VALUES.F_NaN
        endelse
    endif else begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, '  Be careful, there are more than one line that includes: ' + tag 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        para = !VALUES.F_NaN
    endelse

    return, para

end

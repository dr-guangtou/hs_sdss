function hs_list_file_check, list, location=location 

    if keyword_set( location ) then begin 
        top = strcompress( location, /remove_all )
    endif else begin 
        top = '' 
    endelse

    list = strcompress( list, /remove_all ) 
    if NOT file_test( list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file : ' + list + ' !!!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        n_file = file_lines( list ) 
        name = strarr( n_file ) 
        openr, 10, list 
        readf, 10, name 
        close, 10 
    endelse

    n_miss = 0
    for i = 0, ( n_file - 1 ), 1 do begin 
        file = strcompress( name[i], /remove_all ) 
        if NOT file_test( top + file ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, 'Can not find : ' + file 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            n_miss = n_miss + 1
        endif  
    endfor 

    return, n_miss

end 

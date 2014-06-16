function hs_bootstrap_index, n_objs, n_boot 

    ;; Output array 
    output = intarr( n_objs, n_boot ) 

    ;; Generate random index 
    for i = 0, ( n_boot - 1 ), 1 do begin 
        index = floor( randomu( seconds, n_objs ) * n_objs ) 
        output[*,i] = index[ sort( index ) ]
    endfor

    return, output

end

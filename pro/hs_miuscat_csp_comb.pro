function hs_miuscat_csp_comb, csp_list, csp_weights, get_index=get_index 

    ;; Check the list of CSP files 
    n_csp = n_elements( csp_list ) 
    if ( n_csp NE n_elements( csp_weights ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The weights array should have the same size with the files !'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 

    for ii = 0, ( n_csp - 1 ), 1 do begin 

        csp_struc = mrdfits( csp_list[ ii ], 1 )

        if ( ii EQ 0 ) then begin 
            flux_comb = csp_struc.flux * csp_weights[ ii ]
        endif else begin 
            flux_comb = flux_comb + csp_struc.flux * csp_weights[ ii ]
        endelse

    endfor 

end

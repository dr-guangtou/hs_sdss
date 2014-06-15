; + 
; NAME:
;              HS_READ_INDEX_LIST
;
; PURPOSE:
;              Read the spectral index list into a structure 
;
; USAGE:
;    index_struc=hs_read_index_list( index_list_file )
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/15 - First version 
;-
; CATEGORY:    HS_SPEC
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_read_index_list, index_list_file

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    list_file = strcompress( index_list_file, /remove_all ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( list_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file: ' + list_file + ' !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        n_index = file_lines( list_file ) 
        index_struc = { name:'', type:0, lam0:0.0, lam1:0.0, $
            blue0:0.0, blue1:0.0, red0:0.0, red1:0.0 }
        index_struc = replicate( index_struc, n_index ) 
        ;; read in the list file 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        readcol, list_file, name, lam0, lam1, blue0, blue1, $
            red0, red1, type, format='A,F,F,F,F,F,F,I', comment='#', $
            delimiter=' ', /silent
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for ii = 0, ( n_index - 1 ), 1 do begin 
            index_struc[ii].name  = name[ii]
            index_struc[ii].type  = type[ii] 
            index_struc[ii].lam0  = lam0[ii]
            index_struc[ii].lam1  = lam1[ii]
            index_struc[ii].red0  = red0[ii]
            index_struc[ii].red1  = red1[ii]
            index_struc[ii].blue0 = blue0[ii]
            index_struc[ii].blue1 = blue1[ii]
        endfor
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    return, index_struc 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

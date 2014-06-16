; + 
; NAME:
;              HS_SPEC_TO_TXT
;
; PURPOSE:
;              Write a spectrum to TXT file 
;
; USAGE:
;    hs_spec_to_txt, wave, flux, txt_file, error=error, mask=mask, dw=dw
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/07 - First version 
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_spec_to_txt, wave, flux, txt_file, error=error, mask=mask, dw=dw 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_pix = n_elements( wave ) 
    if ( n_elements( flux ) NE n_pix ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The wavelength and flux array should have the same size ! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    min_wave = min( wave ) 
    max_wave = max( wave ) 
    if keyword_set( dw ) then begin 
        dw = float( dw ) 
    endif else begin 
        dw = 1.0 
    endelse
    n_pix_new = ( ( max_wave - min_wave ) / dw ) 
    new_wave = min_wave + findgen( n_pix_new ) * dw 
    index_inter = findex( wave, new_wave ) 
    new_flux = interpolate( flux, index_inter )  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( error ) then begin 
        if ( n_elements( error ) NE n_pix ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The wavelength and flux array should have the same size ! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            temp = interpolate( error^2.0, index_inter ) 
            new_error = sqrt( temp )
        endelse
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( mask ) then begin 
        if ( n_elements( mask ) NE n_pix ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The wavelength and mask array should have the same size ! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            new_mask = interpolate( mask, index_inter ) 
            index_bad = where( new_mask GT 0, n_bad, complement=index_good, $
                ncomplement=n_good )
            if ( n_bad GT 1 ) then begin 
                new_mask[ index_bad ]  = 1L 
            endif 
            if ( n_good GT 1 ) then begin 
                new_mask[ index_good ] = 0L
            endif
        endelse
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the txt file 
    tab = '   '
    openw, lun, txt_file, /get_lun
    for ii = 0, ( n_pix_new - 1 ), 1 do begin 
        line = string( new_wave[ii] ) + tab + string( new_flux[ii] ) + tab 
        if keyword_set( error ) then begin 
            line = line + string( new_error[ii] ) + tab 
        endif 
        if keyword_set( mask ) then begin 
            line = line + string( new_mask[ii] ) 
        endif 
        printf, lun, line 
    endfor 
    close, lun
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    free_lun, lun 
    free_all 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

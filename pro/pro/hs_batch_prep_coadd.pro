; + 
; NAME:
;              HS_BATCH_PREP_COADD
;
; PURPOSE:
;              Prepare SDSS DR8/9 spectra for coaddtion
;
; USAGE:
;    hs_batch_prep_coadd, list_file 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_batch_prep_coadd, list_file, hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    loc_coadd = hvdisp_home + 'coadd/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( list_file ) then begin 
        print, '###############################################################'
        print, ' Can not find the list file : ' + list_file + ' !!'
        print, '###############################################################'
        message, ' '
    endif else begin 
        readcol, list_file, list_html, format='A', delimiter=',', comment='#', $
            /silent, count=n_spec  
        n_file = n_elements( list_html )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0L, ( n_file - 1 ), 1 do begin 
        ;;
        input_list = list_html[ ii ]
        ;; 
        temp = strsplit( input_list, '/.', /extract ) 
        prefix = temp[ n_elements( temp ) - 2 ]
        strreplace, prefix, '_html', '' 
        ;; directory 
        loc_input = loc_coadd + prefix + '/'
        if ( dir_exist( loc_input ) EQ 0 ) then begin 
            spawn, 'mkdir ' + loc_input 
        endif 
        ;; output 
        output = loc_input + prefix + '_prep.fits'
        ;;
        hs_coadd_sdss_prep, input_list, csigma=350.0, output=output, $
            /mask_all, /quiet 
        ;;
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

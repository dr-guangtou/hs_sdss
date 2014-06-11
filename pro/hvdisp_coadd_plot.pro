; + 
; NAME:
;              HVDISP_COADD_PLOT
;
; PURPOSE:
;              Make summary figures of coadded spectra in batch mode 
;
; USAGE:
;    hvdisp_coadd_plot, hvdisp_home=hvdisp_home, feature_list=feature_list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/09 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_coadd_plot, hvdisp_home=hvdisp_home, index_list=index_list
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    resolve_routine, 'hs_coadd_sdss_plot'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_indexlis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( index_list ) then begin 
        index_list = 'hs_index_plot.lis'
    endif else begin 
        index_list = strcompress( index_list, /remove_all ) 
    endelse 
    ;; 
    if NOT file_test( loc_indexlis + index_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the index file : ' + loc_indexlis + index_list + '!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the list of coadded files 
    spawn, 'ls ' + loc_coadd + '*/z?_*_coadd.fits', list_coadd 
    n_coadd = n_elements( list_coadd ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0, ( n_coadd - 1 ), 1 do begin 
    ;for ii = 0, 1, 1 do begin 
        ;; 
        sum_file = list_coadd[ ii ] 
        feature_list = index_list
        print, '###############################################################'
        print, ' Make summary plot for : ' + sum_file
        ;; 
        temp = strsplit( sum_file, '/', /extract ) 
        prefix = temp[ n_elements( temp ) - 1 ]
        strreplace, prefix, '_coadd.fits', ''
        ;;
        hs_coadd_sdss_plot, sum_file, index_list=feature_list, prefix=prefix 
        ;;
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

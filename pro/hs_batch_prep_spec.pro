; + 
; NAME:
;              HS_BATCH_PREP_SPEC
;
; PURPOSE:
;              Prepare SDSS DR8/9 spectra for further analysis
;
; USAGE:
;    hs_batch_prep_spec, list_of_csv_file 
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
pro hs_batch_prep_spec, list_file, hvdisp_home=hvdisp_home, data_home=data_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( data_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        data_home = strcompress( data_home, /remove_all ) 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( list_file ) then begin 
        print, '###############################################################'
        print, ' Can not find the csv file : ' + list_file + ' !!'
        print, '###############################################################'
        message, ' '
    endif else begin 
        readcol, list_file, list_spec, list_plate, list_mjd, list_fiber, $
            list_vdp, format='A, A, A, A, F', delimiter=',', comment='#', $
            /silent, count=n_spec  
        list_spec  = strcompress( list_spec,  /remove_all ) 
        list_plate = strcompress( list_plate, /remove_all )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0L, ( n_spec - 1 ), 1 do begin 

        head = data_home + 'spec/' + list_plate[ ii ] + '/'
        spec_file = head + list_spec[ ii ]
        ;;
        hs_sdss_prep_spec, spec_file, /quiet, /ccm, /save_sl, $
            new_vdp=list_vdp[ ii ]
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; + 
; NAME:
;              HVDISP_RUN_STARLIGHT
;
; PURPOSE:
;              Run STARLIGHT Stellar Population Fitting code within IDL 
;
; USAGE:
;    hvdisp_run_starlight, input_list 
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/15 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_starlight_batch, input_list, hvdisp_home=hvdisp_home, $
    local_result=local_result

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, '###############################################################'
    print, ' INPUT_LIST : ' + input_list  
    print, '###############################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_ancil    = hvdisp_home + 'pro/ancil/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spawn, 'ls ' + loc_ancil + 'hvdisp_*.in', template_list 
    n_temp = n_elements( template_list ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for mm = 0, ( n_temp - 1 ), 1 do begin 
        ;;
        sl_template = strcompress( template_list[ mm ], /remove_all )
        temp = strsplit( sl_template, '/', /extract )
        sl_template = temp[ n_elements( temp ) - 1 ]
        ;;
        print, '###############################################################'
        print, '  STARLIGHT Template : ' + sl_template
        print, '###############################################################'
        if keyword_set( local_result ) then begin 
            hvdisp_run_starlight, input_list, sl_template, /run_sl, $
                /local_result 
        endif else begin 
            hvdisp_run_starlight, input_list, sl_template, /run_sl 
        endelse
        ;;
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_run_starlight, input_list, sl_template, hvdisp_home=hvdisp_home, $
    sl_command=sl_command, run_sl=run_sl, local_result=local_result

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( sl_command ) then begin 
        sl_command = strcompress( string( sl_command ), /remove_all ) 
    endif else begin 
        sl_command = 'starlight' 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spawn, 'which ' + sl_command, loc_sl 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( loc_sl EQ '' ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Please check if STARLIGHT is properly installed !!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_indexlis = hvdisp_home + 'pro/lis/'
    loc_ancil    = hvdisp_home + 'pro/ancil/'
    loc_result   = hvdisp_home + 'coadd/results/starlight/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    input_list = strcompress( input_list, /remove_all ) 
    if NOT file_test( input_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input list : ' + input_list + ' !!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, input_list, input_spec, format='A', comment='#', $
            delimiter=' ', count=n_spec, /silent 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sl_template = strcompress( sl_template, /remove_all ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp = strsplit( sl_template, '.', /extract ) 
    template_prefix = temp[0]
    strreplace, template_prefix, 'hvdisp_', ''
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( loc_ancil + sl_template ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the STARLIGHT template : ' + sl_template + ' !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        n_lines  = file_lines( loc_ancil + sl_template ) 
        temp_arr = strarr( n_lines ) 
        openr, lun, ( loc_ancil + sl_template ), /get_lun 
        readf, lun, temp_arr 
        close, lun 
        free_lun, lun 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0, ( n_spec - 1 ), 1 do begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        spec_use = strcompress( input_spec[ ii ], /remove_all ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        temp  = strsplit( spec_use, '/', /extract )
        n_seg = n_elements( temp ) 
        spec_file = temp[ n_seg - 1 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        spec_dir = loc_coadd
        if ( n_seg GT 1 ) then begin 
            for jj = 0, ( n_seg - 2 ), 1 do begin 
                spec_dir = spec_dir + temp[ jj ] + '/' 
            endfor
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        temp = strsplit( spec_file, '.', /extract ) 
        spec_prefix = temp[0] 
        out_prefix  = spec_prefix + '_' + template_prefix
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        sl_input = loc_result + out_prefix + '.in'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        temp_use = temp_arr
        temp_use = hs_string_replace( temp_use, '$DIR_OF_DATA$', spec_dir   )
        temp_use = hs_string_replace( temp_use, '$IN_SPEC$',     spec_file  )
        temp_use = hs_string_replace( temp_use, '$OUT_FILE$',    out_prefix )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        openw, lun, sl_input, /get_lun, width=500 
        for kk = 0, ( n_lines - 1 ), 1 do begin 
            printf, lun, temp_use[ kk ] 
        endfor 
        close, lun  
        free_lun, lun 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        if keyword_set( run_sl ) then begin 
            spawn, loc_sl + ' < ' + sl_input 
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

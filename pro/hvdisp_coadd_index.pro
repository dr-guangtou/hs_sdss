; + 
; NAME:
;              HVDISP_COADD_INDEX
;
; PURPOSE:
;              Measure a list of spectral index for coadded spectra in batch mode 
;
; USAGE:
;    hs_coadd_post, spec_list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_red_value, red_index 
    ;;; 
    case red_index of 
        '0' : red_value = '0.075' 
        '1' : red_value = '0.047' 
        '2' : red_value = '0.100' 
        '3' : red_value = '0.155'
        else: red_value = '-1.0'
    endcase 
    return, red_value
    ;;
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function get_sig_value, sig_index 
    ;;; 
    case sig_index of 
        '1' : sig_value = '150.0' 
        '2' : sig_value = '170.0' 
        '3' : sig_value = '190.0'
        '4' : sig_value = '210.0'
        '5' : sig_value = '230.0'
        '6' : sig_value = '250.0'
        '7' : sig_value = '275.0'
        '8' : sig_value = '310.0'
        else: sig_value = '-1.0' 
    endcase 
    return, sig_value
    ;;
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_coadd_index, coadd_list, index_list=index_list, $
    hvdisp_home=hvdisp_home, suffix=suffix, save_csv=save_csv 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_result   = hvdisp_home + 'coadd/results/'
    loc_indexlis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    comma = ' , '
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check and read in the input spectra list
    if NOT file_test( coadd_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file : ' + coadd_list + ' !!!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        n_spec = file_lines( coadd_list ) 
        inputs = strarr( n_spec )
        openr, lun, coadd_list, /get_lun 
        readf, lun, inputs
        close, lun 
        free_lun, lun
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp  = strsplit( coadd_list, './', /extract )
    n_seg = n_elements( temp ) 
    if ( n_seg LE 2 ) then begin 
        coadd_prefix = temp[0] 
    endif else begin 
        coadd_prefix = temp[ n_seg - 2 ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Default index list
    index_default = 'hs_index_all.lis'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Index list file 
    if keyword_set( index_list ) then begin
        index_list = strcompress( index_list, /remove_all ) 
        if NOT file_test( loc_indexlis + index_list ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the index list : ' + index_list + ' !!!!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif 
    endif else begin 
        index_list = index_default
        if NOT file_test( loc_indexlis + index_default ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the index list : ' + index_default + ' !!!!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif  
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_prefix = index_list
    strreplace, index_prefix, '.lis', '' 
    strreplace, index_prefix, 'hs_', ''
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Prefix for output 
    output_prefix = coadd_prefix + '_' + index_prefix 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Array for the results 
    index_strarr = strarr( n_spec ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0, ( n_spec - 1 ), 1 do begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        spec_input = strcompress( inputs[ ii ], /remove_all ) 
        if NOT file_test( loc_coadd + spec_input ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the spectrum file : ' + spec_input + ' !!!!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin  
            ;; Read in the spectrum 
            readcol, ( loc_coadd + spec_input ), spec_wave, spec_flux, $
                spec_error, spec_flag, format='F,D,D,I', comment='#', $
                delimiter=' ', /silent 
            index_results = hs_spec_index_batch( spec_wave, spec_flux, $
                snr=600, /toair, index_line=index_line, index_list=index_list, $
                header_line=header_line, /silent ) 
        endelse
        ;;
        temp = strsplit( spec_input,   '/', /extract )
        hvdisp_index = temp[0] 
        ;;
        temp = strsplit( hvdisp_index, '_', /extract )
        ;;
        red_index = temp[0] 
        strreplace, red_index, 'z', '' 
        red_value = get_red_value( red_index )
        if ( float( red_value ) LE 0.0 ) then begin 
            message, ' Something wrong with the redshift index !!'
        endif 
        ;; 
        sig_index = strmid( temp[1], 1, 1 ) 
        sig_value = get_sig_value( sig_index )
        if ( float( sig_value ) LE 0.0 ) then begin 
            message, ' Something wrong with the velocity dispersion index !!'
        endif 
        ;; 
        grp_index = strmid( temp[1], 2, 1 )
        ;; 
        if keyword_set( suffix ) then begin 
            suffix = strcompress( suffix ) 
        endif else begin 
            suffix = 'original'
        endelse
        ;;
        index_line = hvdisp_index + comma + $
            red_index + comma + red_value + comma + $
            sig_index + comma + sig_value + comma + $
            grp_index + comma + suffix + comma + index_line
        ;; 
        index_strarr[ ii ] = index_line

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    strreplace, header_line, '#', ''
    header_line = '#hvdisp_index , red_index , redshift , sig_index , ' + $ 
        'veldisp , grp_index , suffix , ' + header_line
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( save_csv ) then begin 
        csv_output = loc_result + output_prefix + '.csv' 
        openw,  lun, csv_output, /get_lun, width=8000 
        printf, lun, header_line 
        for jj = 0, ( n_spec - 1 ), 1 do begin 
            printf, lun, index_strarr[ jj ] 
        endfor 
        close, lun 
        free_lun, lun 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

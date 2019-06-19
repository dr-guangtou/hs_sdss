pro index_cvd12, index_list=index_list  

    if NOT file_test( 'cvd12_ssp_s350.fits' ) then begin  
        ssp_cvd12
    endif else begin 
        cvd12_ssp = mrdfits( 'cvd12_ssp_s350.fits', 1 ) 
        n_spec = n_elements( cvd12_ssp.ssp_str )
    endelse

    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
        if NOT file_test( index_list ) then begin 
            message, 'Can not find the index_list file: ' + index_list + ' !!!'
        endif 
    endif else begin 
        index_list = 'hs_index_all.lis'
    endelse

    ;;
    index_str = str_replace( index_list, '.lis', '' ) 
    output = 'cvd12_' + index_str + '.csv' 
    openw, lun, output, /get_lun, width=8000

    for i = 0, ( n_spec - 1 ), 1 do begin 

        ;;
        wave   = cvd12_ssp[i].wave 
        flux   = cvd12_ssp[i].flux_conv
        prefix = ( cvd12_ssp[i].ssp_str + '_' + index_str )
        ;; Wavelength to AIR 
        vactoair, wave, wave_air
        ;; 
        cvd_head = ' , SLOPE , IMF_INDEX , AGE , AFE ' 
        cvd_line = ' , ' + cvd12_ssp[i].imf_str + ' , ' + $ 
            string( cvd12_ssp[i].imf_index ) + ' , ' + $ 
            string( cvd12_ssp[i].age ) + ' , ' + $ 
            string( cvd12_ssp[i].afe ) 

        index_struc = hs_list_measure_index( flux, wave_air, snr=500.0, $
            /silent, header_line=header_line, index_line=index_line, $
            index_list=index_list, /save_csv, prefix=prefix )

        if ( i EQ 0 ) then begin 
            printf, lun, header_line + cvd_head  
        endif 
        printf, lun, index_line + cvd_line

    endfor 

    close, lun

end

pro ssp_cvd12

    spawn, 'ls *_sig350.ssp', list 
    n_ssp = n_elements( list ) 

    ;; read one ssp file 
    readcol, list[0], wave_arr, flux_temp, format='F,F', comment='#', $
        delimiter=' ', /silent 
    n_pix = n_elements( wave_arr ) 

    ;; make the structures
    cvd12_ssp = { ssp_str:'', imf_str:'', imf_index:0L, age:0.0, afe:0.0, $
        age_str:'', afe_str:'', $
        wave:fltarr( n_pix ), flux:fltarr( n_pix ), flux_conv:fltarr( n_pix ) }
    cvd12_ssp = replicate( cvd12_ssp, n_ssp ) 

    ;; 
    for i = 0, ( n_ssp - 1 ), 1 do begin 

        ssp_s350 = strcompress( list[i], /remove_all )
        ;; The string for this 
        ssp_str = str_replace( ssp_s350, '_sig350.ssp', '' ) 
        print, '###############################################################'
        print, ' SSP : ' + ssp_str 
        print, '###############################################################'
        ;; SSP information 
        temp = strsplit( ssp_str, '_', /extract ) 
        imf_str = temp[1] 
        age_str = temp[2] 
        afe_str = temp[3] 
        age_val = long( strmid( age_str, 1, 2 ) ) 
        afe_val = long( strmid( afe_str, 3, 2 ) ) 
        ;; SSP file in original resolution 
        ssp_file = ssp_str + '.ssp'
        ;; Read in SSP 1 
        if NOT file_test( ssp_s350 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the SSP file : ' + ssp_s350 + ' !!!!!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            readcol, ssp_s350, wave_s350, flux_s350, format='F,F', comment='#', $
                delimiter=' ', /silent 
        endelse
        ;; Read in SSP 2 
        if NOT file_test( ssp_file ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the SSP file : ' + ssp_file + ' !!!!!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            readcol, ssp_file, wave_file, flux_file, format='F,F', comment='#', $
                delimiter=' ', /silent 
        endelse
        ;; 
        if ( n_elements( wave_s350 ) NE n_elements( wave_file ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something is wrong !!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif 

        ;; 
        cvd12_ssp[i].ssp_str   = ssp_str
        cvd12_ssp[i].imf_str   = imf_str
        cvd12_ssp[i].age_str   = age_str
        cvd12_ssp[i].age       = age_val
        cvd12_ssp[i].afe_str   = afe_str
        cvd12_ssp[i].afe       = afe_val
        cvd12_ssp[i].wave      = wave_s350 
        cvd12_ssp[i].flux      = flux_file  
        cvd12_ssp[i].flux_conv = flux_s350  
        ;; 
        case imf_str of 
            'btl': cvd12_ssp[i].imf_index = 1
            'cha': cvd12_ssp[i].imf_index = 2 
            'x23': cvd12_ssp[i].imf_index = 3 
            'x30': cvd12_ssp[i].imf_index = 4 
            'x35': cvd12_ssp[i].imf_index = 5 
            else : message, '????'
        endcase 

    endfor

    ;; Save the file 
    mwrfits, cvd12_ssp, 'cvd12_ssp_s350.fits', /create 

end

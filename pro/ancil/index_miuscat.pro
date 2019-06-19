pro index_miuscat, index_list=index_list, imf_type=imf_type 

    if NOT file_test( 'miuscat_ssp_s350.fits' ) then begin  
        message, 'Can not find MIUSCAT_SSP_S350.fits file !!!'
    endif else begin 
        master_ssp = mrdfits( 'miuscat_ssp_s350.fits', 1 ) 
        master_ssp.imf = strcompress( master_ssp.imf, /remove_all )
        
        if keyword_set( imf_type ) then begin 
            imf_type = strcompress( imf_type ) 
            case imf_type of
                'un' : miuscat_ssp = master_ssp[where( master_ssp.imf EQ 'un' )] 
                'bi' : miuscat_ssp = master_ssp[where( master_ssp.imf EQ 'bi' )] 
                'ku' : miuscat_ssp = master_ssp[where( master_ssp.imf EQ 'ku' )] 
                'kb' : miuscat_ssp = master_ssp[where( master_ssp.imf EQ 'kb' )] 
                else : message, 'Something wrong with the IMF choice !!'
            endcase 
        endif else begin 
            imf_type = 'un' 
            miuscat_ssp = master_ssp[where( master_ssp.imf EQ 'un' )]
        endelse
        n_spec = n_elements( miuscat_ssp.name )
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
    output = 'miuscat_' + imf_type +'_' + index_str + '.csv' 
    openw, lun, output, /get_lun, width=9000

    for i = 0, ( n_spec - 1 ), 1 do begin 
    ;for i = 0, 1, 1 do begin 

        ;;
        wave   = miuscat_ssp[i].wave 
        flux   = miuscat_ssp[i].flux
        prefix = ( miuscat_ssp[i].name + '_' + index_str )
        ;; 
        cvd_head = ' , IMF , IMF_INDEX , SLOPE , AGE , MET ' 
        cvd_line = ' , ' + $
            miuscat_ssp[i].imf             + ' , ' + $
            miuscat_ssp[i].imf_string      + ' , ' + $
            string( miuscat_ssp[i].slope ) + ' , ' + $ 
            string( miuscat_ssp[i].age )   + ' , ' + $ 
            string( miuscat_ssp[i].metal ) 

        index_struc = hs_list_measure_index( flux, wave, snr=500.0, $
            /silent, header_line=header_line, index_line=index_line, $
            index_list=index_list, prefix=prefix )

        if ( i EQ 0 ) then begin 
            printf, lun, header_line + cvd_head  
        endif 
        printf, lun, index_line + cvd_line

    endfor 

    close, lun

end

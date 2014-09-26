; + 
; NAME:
;              HS_SPEC_INDEX_BATCH
;
; PURPOSE:
;              Measure the spectral index in batch mode 
;
; USAGE:
;    struc=hs_spec_index_batch( wave, flux, index_list=index_list )
;              
; OUTPUT
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_SPEC
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_spec_index_batch, wave, flux, index_list=index_list, $
    error=error, snr=snr, plot=plot, prefix=prefix, silent=silent, $
    save_fits=save_fits, toair=toair, $
    header_line=header_line, index_line=index_line, hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( n_elements( flux ) NE n_elements( wave ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The flux and wavelength array should have the same size !!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    tab   = '   '
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Index list file 
    if keyword_set( index_list ) then begin
        index_list = strcompress( index_list, /remove_all ) 
        if file_test( index_list ) then begin 
            index_list = index_list 
        endif else begin 
            if file_test( loc_indexlis + index_list ) then begin 
                index_list = loc_indexlis + index_list 
            endif else begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find the index list : ' + index_list + ' !!!!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endelse
        endelse
    endif else begin 
        index_list = loc_indexlis + 'hs_index_all.lis' 
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
    ;; Get the structure for index 
    index_struc = hs_read_index_list( index_list )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( ( tag_indx( index_struc, 'name' ) EQ -1 ) OR $
        ( tag_indx( index_struc, 'type' ) EQ -1 ) OR $ 
        ( tag_indx( index_struc, 'lam0' ) EQ -1 ) OR $ 
        ( tag_indx( index_struc, 'lam1' ) EQ -1 ) OR $ 
        ( tag_indx( index_struc, 'blue0' ) EQ -1 ) OR $ 
        ( tag_indx( index_struc, 'blue1' ) EQ -1 ) OR $ 
        ( tag_indx( index_struc, 'red0' ) EQ -1 ) OR $ 
        ( tag_indx( index_struc, 'red1' ) EQ -1 ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The index structure has incompatible tag !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        n_index = n_elements( index_struc.name )
        ;; ---- First Output ----
        output_array = { name:'', value:0.0, error:0.0, type:'', $
            lam0:0.0, lam1:0.0, blue0:0.0, blue1:0.0, red0:0.0, $
            red1:0.0 }
        output_array = replicate( output_array, n_index ) 
        ;; ---- Second Output ----
        output_struc = { spectrum:'' } 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( error ) then begin 
        use_error = 1 
        error = error 
        if ( n_elements( error ) NE n_elements( wave ) ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' The number of elements in the error array should be the '
            print, '  same with the wavelength array! No Error is used !!!'
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            use_error = 0 
        endif
    endif else begin 
        use_error = 0 
        if keyword_set( snr ) then begin 
            snr = float( snr ) 
        endif else begin 
            snr = 200.0 
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Translate the wavelength array into air if possible 
    if keyword_set( toair ) then begin 
        vactoair, wave, wave_air 
        wave = wave_air 
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start the iteration 
    for ii = 0, ( n_index - 1 ), 1 do begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if NOT keyword_set( silent ) then begin 
            print, '###########################################################'
            print, ' Measure index: ' + index_struc[ii].name 
            print, '###########################################################'
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        index_measure = index_struc[ii]
        index_name    = strcompress( index_measure.name, /remove_all )  
        index_errname = ( index_name + '_err' )
        index_type    = index_measure.type
        index_lam0    = index_measure.lam0
        index_lam1    = index_measure.lam1
        index_blue0   = index_measure.blue0
        index_blue1   = index_measure.blue1
        index_red0    = index_measure.red0
        index_red1    = index_measure.red1
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        output_array[ii].name  = index_measure.name 
        output_array[ii].type  = index_measure.type
        output_array[ii].lam0  = index_measure.lam0
        output_array[ii].lam1  = index_measure.lam1
        output_array[ii].blue0 = index_measure.blue0
        output_array[ii].blue1 = index_measure.blue1
        output_array[ii].red0  = index_measure.red0
        output_array[ii].red1  = index_measure.red1
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( plot ) then begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if keyword_set( prefix ) then begin 
                plot_name = prefix + '_' + $
                    strcompress( index_measure.name, /remove_all ) + '.eps'
            endif else begin 
                plot_name = strcompress( index_measure.name, /remove_all ) + $
                    '.eps'
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Actual measurement 
            if ( use_error EQ 1 ) then begin 
                output_index = hs_spec_index_measure( wave, flux, $
                    index_measure, error=error, /plot, eps_name=plot_name, $
                    /silent ) 
            endif else begin 
                output_index = hs_spec_index_measure( wave, flux, $
                    index_measure, snr=snr, /plot, eps_name=plot_name, /silent ) 
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        endif else begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( use_error EQ 1 ) then begin 
                output_index = hs_spec_index_measure( wave, flux, $
                    index_measure, error=error, /silent ) 
            endif else begin 
                output_index = hs_spec_index_measure( wave, flux, $
                    index_measure, snr=snr, /silent ) 
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( prefix ) then begin 
            output_struc.spectrum = prefix
        endif else begin 
            output_struc.spectrum = 'spec' 
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        struct_add_field, output_struc, index_name,    output_index.value  
        struct_add_field, output_struc, index_errname, output_index.error  
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        output_array[ii].value = output_index.value 
        output_array[ii].error = output_index.error 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save a fits version of output 
    if keyword_set( save_fits ) then begin 
        if keyword_set( prefix ) then begin 
            output_fits = prefix + '_index.fits'
        endif else begin 
            output_fits = 'list_index.fits'
        endelse 
        ;; ---- First Extension ----
        mwrfits, output_array, output_fits, /create, /silent 
        ;; ---- Second Extension ----
        mwrfits, output_struc, output_fits, /silent 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; define the header line 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    header_line = '# spectrum  '
    name_list   = output_array.name
    for ii = 0, ( n_index - 1 ), 1 do begin 
        header_line = header_line + comma + name_list[ii] + comma + $
            name_list[ii] + '_err'
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; line for output
    if keyword_set( prefix ) then begin 
        index_line = prefix 
    endif else begin 
        index_line = 'spec ' 
    endelse
    for jj = 0, ( n_index - 1 ), 1 do begin 
        index_value = string( output_array[jj].value, format='(F10.5)' )
        index_error = string( output_array[jj].error, format='(F10.5)' )
        index_line = index_line + comma + index_value + comma + $
            index_error
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    return, output_struc
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

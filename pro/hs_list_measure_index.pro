function index_list2struc, list_file 

    list_file = strcompress( list_file, /remove_all ) 

    if NOT file_test( list_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file: ' + list_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        n_index = file_lines( list_file ) 
        index_struc = { name:'', type:0, lam0:0.0, lam1:0.0, $
            blue0:0.0, blue1:0.0, red0:0.0, red1:0.0 }
        index_struc = replicate( index_struc, n_index ) 
        ;; read in the list file 
        readcol, list_file, name, lam0, lam1, blue0, blue1, $
            red0, red1, type, format='A,F,F,F,F,F,F,I', comment='#', $
            delimiter=' ', /silent
        for ii = 0, ( n_index - 1 ), 1 do begin 
            index_struc[ii].name = name[ii]
            index_struc[ii].type = type[ii] 
            index_struc[ii].lam0 = lam0[ii]
            index_struc[ii].lam1 = lam1[ii]
            index_struc[ii].red0 = red0[ii]
            index_struc[ii].red1 = red1[ii]
            index_struc[ii].blue0 = blue0[ii]
            index_struc[ii].blue1 = blue1[ii]
        endfor
    endelse

    ;; 
    return, index_struc 

end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_list_measure_index, flux, wave, index_list=index_list, $
    error=error, snr=snr, plot=plot, prefix=prefix, silent=silent, $
    save_fits=save_fits, save_csv=save_csv, toair=toair, $
    header_line=header_line, index_line=index_line

    if ( n_elements( flux ) NE n_elements( wave ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The flux and wavelength array should have the same size !!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 

    index_default = 'hs_index_all.lis' 
    ;spawn, 'locate ' + index_default, loc 
    ;if ( loc[0] EQ '' ) then begin 
    if NOT file_test( index_default ) then begin 
        default_find = 0 
    endif else begin 
        default_find = 1 
        index_default = strcompress( index_default, /remove_all ) 
    endelse
        
    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
        if NOT file_test( index_list ) then begin 
            if ( default_find EQ 0 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find useful index list file: ' + index_list + '  !!! ' 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1
            endif else begin 
                index_list = index_default 
            endelse
        endif else begin 
            index_list = index_list 
        endelse
    endif else begin 
        if ( default_find EQ 1 ) then begin 
            index_list = index_default  
        endif else begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find useful index list file: ' + index_default + ' !!! ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1
        endelse
    endelse

    ;; Get the structure for index 
    index_struc = index_list2struc( index_list )

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
        output_struc = { name:'', value:0.0, error:0.0, type:'', $
            lam0:0.0, lam1:0.0, blue0:0.0, blue1:0.0, red0:0.0, $
            red1:0.0 }
        output_struc = replicate( output_struc, n_index ) 
    endelse

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

    ;; Translate the wavelength array into air if possible 
    if keyword_set( toair ) then begin 
        vactoair, wave, wave_air 
        wave = wave_air 
    endif

    ;; Start the iteration 
    for ii = 0, ( n_index - 1 ), 1 do begin 

        if NOT keyword_set( silent ) then begin 
            print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
            print, ' Measure index: ' + index_struc[ii].name 
            print, '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        endif

        index_measure = index_struc[ii]
        output_struc[ii].name  = index_measure.name 
        output_struc[ii].type  = index_measure.type
        output_struc[ii].lam0  = index_measure.lam0
        output_struc[ii].lam1  = index_measure.lam1
        output_struc[ii].blue0 = index_measure.blue0
        output_struc[ii].blue1 = index_measure.blue1
        output_struc[ii].red0  = index_measure.red0
        output_struc[ii].red1  = index_measure.red1

        if keyword_set( plot ) then begin 

            if keyword_set( prefix ) then begin 
                plot_name = prefix + '_' + $
                    strcompress( index_measure.name, /remove_all ) + '.eps'
            endif else begin 
                plot_name = strcompress( index_measure.name, /remove_all ) + $
                    '.eps'
            endelse

            if ( use_error EQ 1 ) then begin 
                output_index = hs_measure_index( wave, flux, index_measure, $ 
                    error=error, /plot, eps_name=plot_name, /silent ) 
            endif else begin 
                output_index = hs_measure_index( wave, flux, index_measure, $ 
                    snr=snr, /plot, eps_name=plot_name, /silent ) 
            endelse

        endif else begin 

            if ( use_error EQ 1 ) then begin 
                output_index = hs_measure_index( wave, flux, index_measure, $ 
                    error=error, /silent ) 
            endif else begin 
                output_index = hs_measure_index( wave, flux, index_measure, $ 
                    snr=snr, /silent ) 
            endelse

        endelse

        ;; 
        output_struc[ii].value = output_index.value 
        output_struc[ii].error = output_index.error 

    endfor

    ;; Save a fits version of output 
    if keyword_set( save_fits ) then begin 
        if keyword_set( prefix ) then begin 
            output_fits = prefix + '_index.fits'
        endif else begin 
            output_fits = 'list_index.fits'
        endelse 
        mwrfits, output_struc, output_fits, /create, /silent 
    endif 

    ;; define the header line 
    tab   = '   '
    comma = ' , '
    header_line = '#Spectrum  '
    name_list   = output_struc.name
    for ii = 0, ( n_index - 1 ), 1 do begin 
        header_line = header_line + comma + name_list[ii] + comma + $
            name_list[ii] + '_err'
    endfor
    ;; line for output
    if keyword_set( prefix ) then begin 
        index_line = prefix 
    endif else begin 
        index_line = 'spec ' 
    endelse
    for jj = 0, ( n_index - 1 ), 1 do begin 
        index_value = string( output_struc[jj].value, format='(F10.5)' )
        index_error = string( output_struc[jj].error, format='(F10.5)' )
        index_line = index_line + comma + index_value + comma + $
            index_error
    endfor

    ;; Save a csv version of the output
    if keyword_set( save_csv ) then begin 
        if keyword_set( prefix ) then begin 
            output_csv = prefix + '_index.csv'
        endif else begin 
            output_csv = 'list_index.csv'
        endelse 
        ;; open the output file 
        openw,  20, output_csv, width=7000  
        printf, 20, header_line 
        printf, 20, index_line 
        close,  20
    endif 

    ;; 
    return, output_struc

end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro list_test 

    struc = mrdfits( 'lowz_test_sigma350_boot.fits', 1, /silent ) 
    wave = struc.wave 
    flux = struc.med_boot 
    error = struc.sig_boot 

    list_file = '~/Dropbox/work/project/sdss_spectra_imf/hs_index.lis'
    index_struc = index_list2struc( list_file ) 

    output = hs_list_measure_index( flux, wave, index_list='hs_index.lis', $
        error=error, /save_fits, /save_csv, prefix='lowz_test_sigma350_boot', $
        header_line=header_line, index_line=index_line, /toair )
    ;print, index_line

    ;output_file = 'lowz_test_sigma350_boot_index.fits'
    ;mwrfits, output, output_file, /create, /silent

end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro list_mius_index, spec_list, index_list=index_list

    if keyword_set( index_list ) then begin
        list_file = strcompress( index_list, /remove_all ) 
        if NOT file_test( index_list ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
            print, 'Can not find the index list : ' + list_file 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
            message, ' '
        endif
    endif else begin 
        list_file = '~/Dropbox/work/project/sdss_spectra_imf/hs_index.lis'
    endelse
    ;; index list
    index_struc = index_list2struc( list_file ) 
    ;; number of index 
    n_index = n_elements( index_struc.name ) 
    ;; name of the index 
    name_list = strcompress( index_struc.name, /remove_all )

    if NOT file_test( spec_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        print, ' Can not find list file : ' + spec_list 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        message, ' '
    endif else begin 
        ;; number of spectra 
        n_spec = file_lines( spec_list ) 
        ;; read in the spectra list 
        spectra = strarr( n_spec ) 
        openr, 10, spec_list 
        readf, 10, spectra 
        close, 10 
    endelse

    ;; output file 
    temp = strsplit( spec_list, '. ', /extract ) 
    output_file = temp[0] + '_index.csv'
    tab   = '    '
    comma = ' , '
    ;; open the output file 
    openw, 20, output_file, width=6000  
    ;; define the header line 
    header_line = '#Spectrum  '
    for ii = 0, ( n_index - 1 ), 1 do begin 
        header_line = header_line + comma + name_list[ii] + comma + $
            name_list[ii] + '_err'
    endfor
    printf, 20, header_line 

    ;;; Start the main iteration 
    for ii = 0, ( n_spec - 1 ), 1 do begin 

        spec_file = spectra[ii]
        if NOT file_test( spec_file ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the spectrum : ' + spec_file
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, '' 
        endif else begin 
            temp = strsplit( spec_file, '/', /extrac ) 
            ;; name of the spectrum 
            spec_name = temp[ n_elements( temp ) - 1 ]
            print, '##', ( ii + 1 ), '  ', spec_name
            ;; initialize the output line
            index_line = spec_name + tab 
            ;; read in the spectrum 
            flux = mrdfits( spec_file, 0, head, /silent, status=status )
            if ( status NE 0 ) then begin  
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the fits file: ' + spec_file 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, '' 
            endif
            ;; get the wavelength array 
            n_pix = fxpar( head, 'NAXIS1' ) 
            wave0 = fxpar( head, 'CRVAL1' ) 
            dwave = fxpar( head, 'CDELT1' ) 
            wave = wave0 + findgen( n_pix ) * dwave 
            ;; error spectrum 
            error = ( flux / 100.0 ) 
            ;; measure the index 
            output_struc = hs_list_measure_index( flux, wave, index_struc, $
                error=error, /silent )  ;;, /plot, prefix='example' ) 
            for jj = 0, ( n_index - 1 ), 1 do begin 
                index_value = string( output_struc[jj].value, format='(F9.4)' )
                index_error = string( output_struc[jj].error, format='(F8.4)' )
                index_line = index_line + comma + index_value + comma + $
                    index_error
            endfor
            ;; print output 
            printf, 20, index_line 
        endelse

    endfor

    ;;
    close, 20
    
end 

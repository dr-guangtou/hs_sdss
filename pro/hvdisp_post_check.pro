;; + 
;; hvdisp_post_check 
;; 14/06/04 SH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_plate_dir, plate_list, locspec, write_list=write_list, $
    silent=silent

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_plate = n_elements( plate_list ) 
    plate_list = strcompress( string( plate_list ), /remove_all ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( write_list ) then begin 
        openw, lun, 'hvdisp_plate.lis', /get_lun
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    plate_not_found = 0
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0L, ( n_plate - 1 ), 1 do begin 
        plate_dir = locspec + plate_list[ ii ] 
        if ( dir_exist( plate_dir ) EQ 1 ) then begin 
            if NOT keyword_set( silent ) then begin 
                print, '#######################################################'
                print, ' ' + plate_dir + ' has already existed !!'
            endif 
        endif else begin 
            if NOT keyword_set( silent ) then begin 
                print, '#######################################################'
                print, ' Make new directory : ' + plate_dir 
            endif
            plate_not_found += 1
            spawn, 'mkdir ' + plate_dir 
        endelse
        if keyword_set( write_list ) then begin 
            printf, lun, plate_list[ ii ] 
        endif 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( write_list ) then begin 
        close, lun 
        free_lun, lun
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( plate_not_found EQ 0 ) then begin 
        print, '###############################################################'
        print, ' Directories for all PLATE have been found !!! '
        print, '###############################################################'
    endif else begin 
        print, '###############################################################'
        print, ' There are ', plate_not_found, ' PLATES have not been found !!' 
        print, '###############################################################'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_check_spec, spec_list, sample, spec_found, count_missing, $
    silent=silent 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_spec = n_elements( spec_list ) 
    print, '###################################################################'
    print, ' SAMPLE : ', sample 
    print, ' There are ', n_spec, ' spectra in total !' 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spec_found = lonarr( n_spec ) + 1 
    spec_fits  = strarr( n_spec )
    count_missing = 0
    help, spec_found, spec_list
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0L, ( n_spec - 1 ), 1 do begin 
        spec_file = strcompress( spec_list[ ii ], /remove_all ) 
        ;; 
        temp = strsplit( spec_file, '/', /extract ) 
        spec_fits[ ii ] = temp[ n_elements( temp ) - 1 ]
        ;;
        if NOT file_test( spec_file ) then begin 
            if NOT keyword_set( silent ) then begin 
                print, '#######################################################'
                print, ' Can not find : ' + spec_file 
            endif 
            spec_found[ ii ] = 0 
            count_missing += 1L
        endif 
    endfor 
    print, count_missing
    help, spec_found 
    print, n_elements( where( spec_found EQ 0 ) )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( count_missing NE n_elements( where( spec_found EQ 0 ) ) ) then begin 
        message, ' Something wrong about the counting !! '
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, ' There are ', count_missing, ' spectra have not been downloaded !'
    print, '###################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    missing_file = spec_fits[ where( spec_found EQ 0 ) ]
    openw, lun, sample + '_missing.lis', /get_lun, width=200 
    for jj = 0L, ( count_missing - 1 ), 1 do begin 
        printf, lun, missing_file[ jj ] 
    endfor 
    close,    lun 
    free_lun ,lun
    ;; 

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_post_check, hvdisp_home=hvdisp_home, data_home=data_home, $
    check_dir=check_dir, check_spec=check_spec 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location for the csv file 
    loccsv  = hvdisp_home + 'csv/' 
    ;; Location for the html file 
    lochtml = hvdisp_home + 'html/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location where the spectra files are stored 
    if NOT keyword_set( data_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        data_home = strcompress( data_home, /remove_all )
    endelse
    locspec = data_home + 'spec/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in three spectra list 
    ;; Z_1
    readcol, ( loccsv + 'hvdisp_z1_spec.csv' ), $
        z1_fits, z1_plate, z1_mjd, z1_fiber, z1_vdisp, format='(A,I,I,I,F)', $
        delimiter=',', comment='#', /silent, count=z1_num
    ;; Z_2
    readcol, ( loccsv + 'hvdisp_z2_spec.csv' ), $
        z2_fits, z2_plate, z2_mjd, z2_fiber, z2_vdisp, format='(A,I,I,I,F)', $
        delimiter=',', comment='#', /silent, count=z2_num
    ;; Z_3 
    readcol, ( loccsv + 'hvdisp_z3_spec.csv' ), $
        z3_fits, z3_plate, z3_mjd, z3_fiber, z3_vdisp, format='(A,I,I,I,F)', $
        delimiter=',', comment='#', /silent, count=z3_num
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the html list
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; List of Plate  
    plate_list = [ z1_plate, z2_plate, z3_plate ]
    plate_list = plate_list[ uniq( plate_list, sort( plate_list ) ) ]
    print, '###################################################################'
    print, ' There are ', n_elements( plate_list ), ' plates in total '
    if keyword_set( check_dir ) then begin 
        hvdisp_plate_dir, plate_list, locspec, /write_list, /silent 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    z1_plate = strcompress( string( z1_plate ), /remove_all )
    z1_file  = locspec + z1_plate + '/' + z1_fits 
    z1_fits  = strcompress( z1_fits,  /remove_all )
    if keyword_set( check_spec ) then begin 
        hvdisp_check_spec, z1_file, 'hvdisp_z1', z1_found, z1_missing, /silent 
    endif 
    ;;
    z2_plate = strcompress( string( z2_plate ), /remove_all )
    z2_file  = locspec + z2_plate + '/' + z2_fits 
    z2_fits  = strcompress( z2_fits,  /remove_all )
    if keyword_set( check_spec ) then begin 
        hvdisp_check_spec, z2_file, 'hvdisp_z2', z2_found, z2_missing, /silent 
    endif 
    ;;
    z3_plate = strcompress( string( z3_plate ), /remove_all )
    z3_file  = locspec + z3_plate + '/' + z3_fits 
    z3_fits  = strcompress( z3_fits,  /remove_all )
    if keyword_set( check_spec ) then begin 
        hvdisp_check_spec, z3_file, 'hvdisp_z3', z3_found, z3_missing, /silent 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_extra_check 

    hvdisp_location, hvdisp_home, data_home
    data_home = data_home + 'spec/'
    list_file = hvdisp_home + 'sample/hvdisp_all_spec.lis'
    list_nosl = 'spec_nosl.lis'

    spawn, 'ls ' + data_home + '*/spec-????-?????-????.fits > ' + list_file  

    readcol, list_file, spec_list, format='A', delimiter=' ', /silent

    n_spec = n_elements( spec_list ) 
    print, '###################################################################'
    print, ' There are ', n_spec, ' spectra in total !! '
    print, '###################################################################'

    spawn, 'touch ' + list_nosl

    ;for ii = 0, 1, 1 do begin 
    for ii = 0L, ( n_spec - 1 ), 1 do begin 

        spec_file = spec_list[ ii ] 
        
        temp = strsplit( spec_file, '.', /extract ) 
        prefix = temp[ n_elements( temp ) - 2 ]
        spec_txt = prefix + '_sl.txt'

        if NOT file_test( spec_txt ) then begin 
            spawn, 'echo ' + spec_file + ' >> ' + list_nosl 
        endif 

    endfor 

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

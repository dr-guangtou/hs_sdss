; + 
; NAME:
;              HS_STELLAR_LIBRARY_INDEX
;
; PURPOSE:
;              Measure the spectral index for certain stellar library  
;
; USAGE:
;     hs_stellar_library_index, stelib_file, index_list=index_list, 
;           save_fits=save_fits, silent=silent, toair=toair
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/22 - First version 
;-
; CATEGORY:   HS_STELLAR
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro hs_stellar_library_index, stelib_file, index_list=index_list, $
    save_fits=save_fits, silent=silent, toair=toair, plot=plot

    ;; Stellar library file 
    stelib_file = strcompress( stelib_file, /remove_all )

    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( stelib_file, '/ ', /extract ) 
    base_stelib = temp[ n_elements( temp ) - 1 ]

    ;; Check the file 
    if NOT file_test( stelib_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + stelib_file
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_stelib
        endif 

        ;; Read in the spectra 
        stelib = mrdfits( stelib_file, 1, head, /silent )
        ;; Number of spectra 
        n_stars = n_elements( stelib.teff ) 

    endelse

     ;; Check the input index array 
     index_default = 'hs_index_all.lis' 
     if file_test( index_default ) then begin 
         find_default = 1 
     endif else begin 
         find_default = 0 
     endelse
     if keyword_set( index_list ) then begin 
         index_list = strcompress( index_list, /remove_all ) 
         if file_test( index_list ) then begin 
             index_list = index_list 
         endif else if ( find_default EQ 1 ) then begin 
             index_list = index_default 
         endif else begin 
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             print, ' Can not find a useful index list !! '
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             message, ' ' 
         endelse
     endif else begin 
         if ( find_default EQ 1 ) then begin 
             index_list = index_default 
         endif else begin 
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             print, ' Can not find a useful index list !! '
             print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
             message, ' ' 
         endelse 
     endelse

     ;; Define the output file structure 
     csv_file  = hs_string_replace( stelib_file, '.fits', '_index.csv'  ) 
     fits_file = hs_string_replace( stelib_file, '.fits', '_index.fits' )

     ;; Open the csv file for reading 
     openw, lun, csv_file, width=6000, /get_lun

     ;; Main iteration 
     ;for ii = 0, 2, 1 do begin 
     for ii = 0, ( n_stars - 1 ), 1 do begin 

         wave = stelib[ ii ].wave 
         flux = stelib[ ii ].flux 
         name = stelib[ ii ].name 

         temp = hs_string_replace( name, '.fits', '' ) 
         prefix = hs_string_replace( name, '.txt', '' ) 

         if keyword_set( toair ) then begin 
             vactoair, wave, wave_air 
             wave = wave_air
         endif 

         ;; Get the index structure 
         if keyword_set( plot ) then begin 
             results = hs_spec_index_batch( wave, flux, snr=500.0, /silent, $
                 index_list=index_list, prefix=prefix, $
                 header_line=header_line, index_line=index_line, /plot )
         endif else begin 
             results = hs_spec_index_batch( wave, flux, snr=500.0, /silent, $
                 index_list=index_list, prefix=prefix, $
                 header_line=header_line, index_line=index_line )
         endelse

         ;; Add stellar information to the structure
         struct_add_field, results, 'teff', stelib[ ii ].teff 
         struct_add_field, results, 'logg', stelib[ ii ].logg 
         struct_add_field, results, 'feh',  stelib[ ii ].feh
         struct_add_field, results, 'afe',  stelib[ ii ].afe
         struct_add_field, results, 'name', stelib[ ii ].name

         stelib_head = ' NAME , TEFF , LOGG , FEH , AFE ' 
         stelib_line = stelib[ ii ].name + ' , ' + $
             string( stelib[ ii ].teff ) + ' , ' + $
             string( stelib[ ii ].logg ) + ' , ' + $
             string( stelib[ ii ].feh  ) + ' , ' + $
             string( stelib[ ii ].afe  )

         ;; ASCII output to a .csv file 
         if ( ii EQ 0 ) then begin 
             ;; print the header if it is the first line
             printf, lun, header_line + ' , ' + stelib_head
             printf, lun, index_line  + ' , ' + stelib_line
             ;; define the output structure 
             out_struc = replicate( results, n_stars ) 
             out_struc[ ii ] = results
         endif else begin  
             printf, lun, index_line  + ' , ' + stelib_line
             out_struc[ ii ] = results
         endelse

     endfor

     ;; Save a fits catalog as output
     if keyword_set( save_fits ) then begin 
         mwrfits, out_struc, fits_file, /create 
     endif 

     ;; close file 
     close, lun
     free_all

end

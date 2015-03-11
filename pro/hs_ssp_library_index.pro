; + 
; NAME:
;              HS_STELLAR_LIBRARY_INDEX
;
; PURPOSE:
;              Measure the spectral index for certain stellar library  
;
; USAGE:
;     hs_stellar_library_index, ssplib_file, index_list=index_list, 
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

pro hs_ssp_library_index, ssplib_file, index_list=index_list, $
    save_fits=save_fits, silent=silent, toair=toair, plot=plot

    ;; Stellar library file 
    ssplib_file = strcompress( ssplib_file, /remove_all )

    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( ssplib_file, '/ ', /extract ) 
    base_ssplib = temp[ n_elements( temp ) - 1 ]

    ;; Check the file 
    if NOT file_test( ssplib_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + ssplib_file
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_ssplib
        endif 

        ;; Read in the spectra 
        ssplib = mrdfits( ssplib_file, 1, head, /silent )
        ;; Number of spectra 
        n_ssps = n_elements( ssplib.age ) 

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
     temp = strsplit( index_list, '/ ', /extract ) 
     index_file = temp[ n_elements( temp ) - 1 ]
     temp0 = hs_string_replace( index_file, '.lis', '' )
     temp1 = hs_string_replace( temp0, '_index', '' )

     ;; Define the output file structure 
     prefix = hs_string_replace( ssplib_file, '.fits', '' ) + '_' + temp1
     fits_file = prefix + '_index.fits'

     ;; Main iteration 
     ;for ii = 0, 2, 1 do begin 
     for ii = 0, ( n_ssps - 1 ), 1 do begin 

         wave = ssplib[ ii ].wave 
         flux = ssplib[ ii ].flux 
         name = ssplib[ ii ].name 

         if NOT keyword_set( silent ) then begin 
             print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
             print, ' About to deal with SSP : ' + name 
             print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
         endif 

         temp   = hs_string_replace( name, '.fits', '' ) 
         prefix = hs_string_replace( name, '.txt', '' ) 

         if keyword_set( toair ) then begin 
             vactoair, wave, wave_air 
             wave = wave_air
         endif 

         ;; Get the index structure 
         if keyword_set( plot ) then begin 
             results = hs_spec_index_batch( wave, flux, snr=600.0, /silent, $
                 index_list=index_list, prefix=prefix, $
                 header_line=header_line, index_line=index_line, /plot )
         endif else begin 
             results = hs_spec_index_batch( wave, flux, snr=600.0, /silent, $
                 index_list=index_list, prefix=prefix, $
                 header_line=header_line, index_line=index_line )
         endelse

         ;; Add stellar information to the structure
         struct_add_field, results, 'imf',   ssplib[ ii ].imf 
         struct_add_field, results, 'slope', ssplib[ ii ].slope 
         struct_add_field, results, 'age',   ssplib[ ii ].age
         struct_add_field, results, 'metal', ssplib[ ii ].metal
         struct_add_field, results, 'afe',   ssplib[ ii ].afe
         struct_add_field, results, 'feh',   ssplib[ ii ].feh
         struct_add_field, results, 'type',  ssplib[ ii ].type

         ;; ASCII output to a .csv file 
         if ( ii EQ 0 ) then begin 
             ;; define the output structure 
             out_struc = replicate( results, n_ssps ) 
             out_struc[ ii ] = results
         endif else begin  
             out_struc[ ii ] = results
         endelse

     endfor

     ;; Save a fits catalog as output
     if keyword_set( save_fits ) then begin 
         mwrfits, out_struc, fits_file, /create 
     endif 

     ;; close file 
     free_all

end

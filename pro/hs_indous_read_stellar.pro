; + 
; NAME:
;              HS_INDOUS_READ_STELLAR
;
; PURPOSE:
;              Read the FITS binary format stellar spectrum from Indo-US library 
;
; USAGE:
;     spec = hs_indous_read_stellar( file_indous )
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/22 - First version 
;-
; CATEGORY:    HS_INDOUS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_indous_read_stellar, file_indous, silent=silent

    file_indous = strcompress( file_indous, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_indous, '/ ', /extract ) 
    base_indous = temp[ n_elements( temp ) - 1 ]

    ;; Check the file 
    if NOT file_test( file_indous ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + file_indous
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_indous 
        endif 

        ;; Read in the spectra 
        spec = mrdfits( file_indous, 1, head, /silent )

        ;; Merged spectrum 
        wave  = spec.wavelength 
        flux  = spec.spectrum
        n_pix = n_elements( wave_ori )

        ;; Deal with the GAPS 
        gaps  = fxpar( head, 'GAPS' ) 
        print, gaps
        if ( gaps NE 0 ) then begin 
            gaps = strcompress( gaps, /remove_all ) 
            temp = strsplit( gaps, ',', /extract )  
            n_seg = n_elements( temp ) 
            for jj = 0, ( n_seg - 1 ), 1 do begin 
                temp2 = strsplit( temp[jj], '-', /extract )
                if ( n_elements( temp2 ) NE 2 ) then begin 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    print, ' Something wrong with the header !!!! '
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    return, -1
                endif else begin 
                    w0 = float( temp2[0] ) 
                    w1 = float( temp2[1] ) 
                    index_gap = where( ( wave GE ( w0 - 0.4 ) ) AND $
                        ( wave LE ( w1 + 0.4 ) ) ) 
                    if ( index_gap[0] NE -1 ) then begin 
                        flux[ index_gap ] = !VALUES.F_NaN
                    endif 
                endelse 
            endfor 
        endif 
        ;; 
        min_wave = 3465.0 
        max_wave = 9469.0 
        d_wave   = 0.4 

        ;; Get the stellar parameters 
        teff = fxpar( head, 'TEFF' ) 
        logg = fxpar( head, 'LOGG' ) 
        feh  = fxpar( head, 'FEH'  )

        ;; Define the output structure 
        struc_indous = { name:base_indous, wave:wave, flux:flux, $
            d_wave:d_wave, n_pixel:n_pix, sampling:"linear", $
            min_wave:min_wave, max_wave:max_wave, $
            r_spec:4200.0, resolution:30.0, unit:'km/s', $
            teff:teff, logg:logg, feh:feh, afe:!VALUES.F_NaN, $
            comment:gaps, wavescale:'air' }

    endelse 

    return, struc_indous

end

; + 
; NAME:
;              HS_COELHO14_READ_STELLAR
;
; PURPOSE:
;              Read the synthetic stellar spectrum from Coelho (2014) 
;
; USAGE:
;     spec = hs_coelho14_read_stellar( file_coelho )
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/22 - First version 
;-
; CATEGORY:    HS_COELHO
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_coelho14_read_stellar, file_coelho, silent=silent

    file_coelho = strcompress( file_coelho, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_coelho, '/ ', /extract ) 
    base_coelho = temp[ n_elements( temp ) - 1 ]

    ;; Check the file 
    if NOT file_test( file_coelho ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + file_coelho
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_coelho 
        endif 

        ;; Read in the spectra 
        spec = mrdfits( file_coelho, 0, head, /silent )

        ;; First, get a wavelength array 
        n_pixel = long( fxpar( head, 'NAXIS1' ) )
        min_wave = float( fxpar( head, 'CRVAL1' ) ) 
        d_wave = float( fxpar( head, 'CDELT1' ) ) 
        wave = min_wave + ( findgen( n_pixel ) * d_wave ) 
        max_wave = max( wave )

        ;; Define the output structure 
        struc_coelho = { name:base_coelho, wave:wave, flux:spec, $
            d_wave:d_wave, n_pixel:n_pixel, sampling:"linear", $
            min_wave:min_wave, max_wave:max_wave, $
            r_spec:20000.0, resolution:6.4, unit:'km/s', $
            teff:0.0, logg:0.0, feh:0.0, afe:0.0, wavescale:'vac' }

        struc_coelho.teff = float( fxpar( head, 'TEFF' ) )
        struc_coelho.logg = float( fxpar( head, 'LOG_G' ) )
        struc_coelho.feh  = float( fxpar( head, 'FEH'  ) )
        struc_coelho.afe  = float( fxpar( head, 'AFE'  ) )

    endelse

    return, struc_coelho 

end

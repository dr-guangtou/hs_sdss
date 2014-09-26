; + 
; NAME:
;              HS_MILES_READ_STELLAR
;
; PURPOSE:
;              Read the stellar spectrum from MILES library
;
; USAGE:
;     spec = hs_miles_read_stellar( file_miles )
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/22 - First version 
;-
; CATEGORY:   HS_MILES
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_miles_read_stellar, file_miles, silent=silent

    file_miles = strcompress( file_miles, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_miles, '/ ', /extract ) 
    base_miles = temp[ n_elements( temp ) - 1 ]

    ;; Check the file 
    if NOT file_test( file_miles ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + file_miles
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_miles 
        endif 

        ;; Read in the spectra 
        spec = mrdfits( file_miles, 0, head, /silent )

        ;; Get the sampling method 
        tag = 'Type of sampling:' 
        sampling = hs_retrieve_para( head, tag, " '", 6 )

        ;; First, get a wavelength array 
        n_pixel  = long( fxpar( head, 'NAXIS1' ) )
        min_wave = float( fxpar( head, 'CRVAL1' ) ) 
        d_wave   = float( fxpar( head, 'CDELT1' ) ) 
        wave     = min_wave + ( findgen( n_pixel ) * d_wave ) 
        max_wave = max( wave )

        ;; Then adjust the unit for wavelength array to Angstrom
        case sampling of 
            'ln'     : wave = exp( wave )
            'log10'  : wave = 10.0D^(wave)
            'linear' : wave = wave 
            else     : begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something is wrong ! Check! '
                print, ' The allowed sampling formats are: ln, log10, linear '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
                end
        endcase

        ;; Get Min/Max Wavelength in Angstrom 
        min_wave = min( wave ) 
        max_wave = max( wave )

        ;; Define the output structure 
        struc_miles = { name:base_miles, wave:wave, flux:spec, $
            d_wave:d_wave, n_pixel:n_pixel, sampling:sampling, $
            min_wave:min_wave, max_wave:max_wave, $
            r_spec:2000.0, resolution:6.4, unit:'km/s', $
            teff:0.0, logg:0.0, feh:0.0, afe:0.0 }

        tag = 'Teff:' 
        struc_miles.teff = float( hs_retrieve_para( head, tag, " ,:'", 4 ) )
        tag = 'Log(g):' 
        struc_miles.logg = float( hs_retrieve_para( head, tag, " ,:'", 4 ) )
        tag = '[Fe/H]:' 
        struc_miles.feh  = float( hs_retrieve_para( head, tag, " ,:'", 4 ) )

        tag = 'Spectral resolution:' 
        struc_miles.resolution = float( hs_retrieve_para( head, tag, " ,:'", 5 ) )
        struc_miles.unit = hs_retrieve_para( head, tag, " ,:'()", 6 )

    endelse

    return, struc_miles

end

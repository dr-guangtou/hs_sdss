; + 
; NAME:
;              HS_COELHO07_SSP_SUMMARY
;
; PURPOSE:
;              Make a summary file of the COELHO07 SSP library 
;
; USAGE:
;     hs_coelho07_ssp_summary, loc_coelho07=loc_coelho07
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

pro hs_coelho07_ssp_summary, loc_coelho07=loc_coelho07 

    if keyword_set( loc_coelho07 ) then begin 
        loc_coelho07 = strcompress( loc_coelho07, /remove_all )
    endif else begin 
        spawn, 'uname -a', sysinfo 
        if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
            loc_coelho07 = $
                "/Users/songhuang/astro1/lib/ssp/coelho07/"
        endif else begin 
            loc_coelho07 = $
                "/home/hs/work/data/ssp/coelho07/"
                ;"/home/hs/astro1/lib/ssp/coelho07/"
        endelse
    endelse

    ;; Check the directory and find all fits files
    if ( dir_exist( loc_coelho07 ) NE 0 ) then begin 
        spawn, 'ls ' + loc_coelho07 + 'spec_*/*.fits', list_fits 
        n_fits = n_elements( list_fits )
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for COELHO07 SSP spectra: '
        print, loc_coelho07 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_coelho07_read_ssp( list_fits[0], /silent )
    ;; New structure for output 
    new_struc = replicate( struc0, n_fits ) 

    ;; Start the iteration 
    for ii = 0L, ( n_fits - 1 ), 1 do begin 

        new_struc[ ii ] = hs_coelho07_read_ssp( list_fits[ ii ], /plot )

    endfor 

    ;; Save the results to a FITS catalog 
    output = 'coelho07_ssp_fwhm_1.0.fits'
    mwrfits, new_struc, output, /create

end

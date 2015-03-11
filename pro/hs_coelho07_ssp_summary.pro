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

pro hs_coelho07_ssp_summary, sig_conv, d_wave=d_wave, $
    loc_coelho07=loc_coelho07, silent=silent

    if ( sig_conv LE 10.0 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Sorry, the sigma_conv should be larger than 10.0 km/s !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif 

    if keyword_set( loc_coelho07 ) then begin 
        loc_coelho07 = strcompress( loc_coelho07, /remove_all )
    endif else begin 
        spawn, 'uname -a', sysinfo 
        if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
            loc_coelho07 = $
                "/Users/songhuang/astro1/lib/ssp/coelho07/"
        endif else begin 
            loc_coelho07 = $
                "/home/hs/astro1/lib/ssp/coelho07/"
        endelse
    endelse

    if keyword_set( d_wave ) then begin 
        d_wave = floor( d_wave )
    endif else begin 
        d_wave = 1.0 
    endelse

    ;; Check the directory and find all fits files
    if ( dir_exist( loc_coelho07 ) NE 0 ) then begin 
        spawn, 'ls ' + loc_coelho07 + 'spec_*/*.fits', list_ssp 
        n_ssp = n_elements( list_ssp )
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for COELHO07 SSP spectra: '
        print, loc_coelho07 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_coelho07_read_ssp( list_ssp[0], /silent, sig_conv=sig_conv, $
        new_sampling=d_wave )

    ;; New structure for output 
    new_struc = replicate( struc0, n_ssp ) 

    ;; Start the iteration 
    for ii = 0L, ( n_ssp - 1 ), 1 do begin 

        new_struc[ ii ] = hs_coelho07_read_ssp( list_ssp[ ii ], $
            sig_conv=sig_conv, new_sampling=d_wave )

    endfor 

    ;; Save the results to a FITS catalog 
    sig_str = strcompress( string( sig_conv, format='(I5)' ), /remove_all ) 
    output = 'coelho07_ssp_sig' + sig_str + '.fits'
    mwrfits, new_struc, output, /create

end

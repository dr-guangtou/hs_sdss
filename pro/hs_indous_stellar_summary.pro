; + 
; NAME:
;              HS_INDOUS_STELLAR_SUMMARY
;
; PURPOSE:
;              Make a summary file of the INDOUS stellar library 
;
; USAGE:
;     hs_indous_stellar_summary, sig_conv, d_wave=d_wave, loc_indous=loc_indous
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/27 - First version 
;-
; CATEGORY:    HS_INDOUS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro hs_indous_stellar_summary, sig_conv, d_wave=d_wave, loc_indous=loc_indous, $
    silent=silent

    if ( sig_conv LE 30.0 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Sorry, the sigma_conv should be larger than 30.0 km/s !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif 

    if keyword_set( loc_indous ) then begin 
        loc_indous = strcompress( loc_indous, /remove_all )
    endif else begin 
        spawn, 'uname -a', sysinfo 
        if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
            loc_indous = $
                "/Users/songhuang/astro1/lib/stellar/indo_us/bin/"
        endif else begin 
            loc_indous = $
                "/home/hs/astro1/lib/stellar/indo_us/bin/"
        endelse
    endelse

    if keyword_set( d_wave ) then begin 
        d_wave = float( d_wave ) 
    endif else begin 
        d_wave = 1.0 
    endelse

    ;; Check the directory and find all fits files
    if ( dir_exist( loc_indous ) NE 0 ) then begin 
        spawn, 'ls ' + loc_indous + '*.fits', list_stars 
        n_stars = n_elements( list_stars )
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + string( n_stars ) + ' Spectra !' 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif 
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for Indo-us stellar spectra: '
        print, loc_indous 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_indous_read_stellar( list_stars[0], /silent, /plot, $
        sig_conv=sig_conv, new_sampling=d_wave )

    ;; New structure for output 
    new_struc = replicate( struc0, n_stars ) 

    ;; Start the iteration 
    for ii = 0L, ( n_stars - 1 ), 1 do begin 

        new_struc[ ii ] = hs_indous_read_stellar( list_stars[ ii ], /silent, $
            /plot, sig_conv=sig_conv, new_sampling=d_wave )

    endfor 

    ;; Save the results to a FITS catalog 
    sig_str = strcompress( string( sig_conv, format='(I5)' ), /remove_all ) 
    output = 'indous_stellar_sig'+ sig_str + '.fits'
    mwrfits, new_struc, output, /create

end

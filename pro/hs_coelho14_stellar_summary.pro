; + 
; NAME:
;              HS_COELHO14_STELLAR_SUMMARY
;
; PURPOSE:
;              Organize a summary file of the Coelho14 stellar library 
;
; USAGE:
;     hs_coelho14_stellar_summary, sig_conv, d_wave=d_wave, 
;           loc_coelho=loc_coelho, silent=silent
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

pro hs_coelho14_stellar_summary, sig_conv, d_wave=d_wave, $
    loc_coelho=loc_coelho, silent=silent

    if ( sig_conv LE 6.4 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Sorry, the sigma_conv should be larger than 6.4 km/s !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif 

    if keyword_set( loc_coelho ) then begin 
        loc_coelho = strcompress( loc_coelho, /remove_all )
    endif else begin 
        spawn, 'uname -a', sysinfo 
        if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
            loc_coelho = $
                "/Users/songhuang/astro1/lib/stellar/coelho/coelho14_hres/"
        endif else begin 
            loc_coelho = $
                "/home/hs/astro1/lib/stellar/coelho/coelho14_hres/"
        endelse
    endelse

    if keyword_set( d_wave ) then begin 
        d_wave = floor( d_wave )
    endif else begin 
        d_wave = 1.0 
    endelse

    ;; Check the directory and find all fits files
    if ( dir_exist( loc_coelho ) NE 0 ) then begin 
        spawn, 'ls ' + loc_coelho , list_stars 
        list_stars = loc_coelho + list_stars
        n_stars = n_elements( list_stars )
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + string( n_stars ) + ' Spectra !' 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif 
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for Coelho stellar spectra: '
        print, loc_coelho 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_coelho14_read_stellar( list_stars[0], /silent, $
        sig_conv=sig_conv, new_sampling=d_wave )

    ;; New structure for output 
    new_struc = replicate( struc0, n_stars )

    ;; Start the iteration 
    for ii = 0L, ( n_stars - 1 ), 1 do begin 

        new_struc[ ii ] = hs_coelho14_read_stellar( list_stars[ ii ], /silent, $
            sig_conv=sig_conv, new_sampling=d_wave )

    endfor 
        
    ;; Save the results to a FITS catalog 
    sig_str = strcompress( string( sig_conv, format='(I5)' ), /remove_all ) 
    output = 'coelho14_stellar_sig' + sig_str + '.fits'
    mwrfits, new_struc, output, /create

end

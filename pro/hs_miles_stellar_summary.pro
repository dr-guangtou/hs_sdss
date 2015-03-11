; + 
; NAME:
;              HS_MILES_STELLAR_SUMMARY
;
; PURPOSE:
;              Make a summary file of the MILES stellar library 
;
; USAGE:
;     hs_miles_stellar_summary, search_tag, loc_miles=loc_miles
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/22 - First version 
;             Song Huang, 2014/09/26 - Update
;-
; CATEGORY:    HS_MILES
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro hs_miles_stellar_summary, sig_conv, d_wave=d_wave, loc_miles=loc_miles, $
    silent=silent

    if keyword_set( loc_miles ) then begin 
        loc_miles = strcompress( loc_miles, /remove_all )
    endif else begin 
        spawn, 'uname -a', sysinfo 
        if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
            loc_miles = $
                "/Users/songhuang/work/data/miles/spec/"
                ;"/Users/songhuang/astro1/lib/stellar/miles/tailor/"
        endif else begin 
            loc_miles = $
                "/home/hs/astro1/lib/stellar/miles/spec/"
        endelse
    endelse

    if keyword_set( d_wave ) then begin 
        d_wave = float( d_wave ) 
    endif else begin 
        d_wave = 1.0 
    endelse

    miles_cat = loc_miles + 'miles_catalog.fits'
    if NOT file_test( miles_cat ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        print, ' Can not find the MILES_CATALOG file: ' + miles_cat + ' !' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        message, ' ' 
    endif 

    ;; Check the directory and find all fits files
    if ( dir_exist( loc_miles ) NE 0 ) then begin 
        spawn, 'ls ' + loc_miles + 'm*V', list_stars 
        n_stars = n_elements( list_stars )
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for Indo-us stellar spectra: '
        print, loc_miles 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_miles_read_stellar( list_stars[0], /silent, /plot, $
        sig_conv=sig_conv, new_sampling=d_wave, miles_cat=miles_cat )

    ;; New structure for output 
    new_struc = replicate( struc0, n_stars ) 

    ;; Start the iteration 
    for ii = 0L, ( n_stars - 1 ), 1 do begin 

        print, ' ### Read in : ' + list_stars[ ii ]

        new_struc[ ii ] = hs_miles_read_stellar( list_stars[ ii ], /silent, $
            /plot, sig_conv=sig_conv, new_sampling=d_wave, miles_cat=miles_cat )

    endfor 

    ;; Save the results to a FITS catalog 
    sig_str = strcompress( string( sig_conv, format='(I5)' ), /remove_all ) 
    output = 'miles_stellar_sig'+ sig_str + '.fits'
    mwrfits, new_struc, output, /create

end

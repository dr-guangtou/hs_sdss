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
;-
; CATEGORY:    HS_MILES
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro hs_miles_stellar_summary, search_tag, loc_miles=loc_miles, silent=silent

    if keyword_set( loc_miles ) then begin 
        loc_miles = strcompress( loc_miles, /remove_all )
    endif else begin 
        spawn, 'uname -a', sysinfo 
        if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
            loc_miles = $
                "/Users/songhuang/astro1/lib/stellar/miles/tailor/"
        endif else begin 
            loc_miles = $
                "/home/hs/work/data/stellar/miles/tailor/"
                ;"/home/hs/astro1/lib/stellar/miles/tailor/"
        endelse
    endelse

    ;; Check the directory and find all fits files
    tag = strcompress( search_tag, /remove_all )
    if ( dir_exist( loc_miles ) NE 0 ) then begin 
        spawn, 'ls ' + loc_miles + '*' + tag + '*.fits', list_fits 
        n_fits = n_elements( list_fits )
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for Indo-us stellar spectra: '
        print, loc_miles 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_miles_read_stellar( list_fits[0], /silent )
    ;; New structure for output 
    new_struc = replicate( struc0, n_fits ) 

    ;; Start the iteration 
    for ii = 0L, ( n_fits - 1 ), 1 do begin 

        new_struc[ ii ] = hs_miles_read_stellar( list_fits[ ii ] )

    endfor 

    ;; Save the results to a FITS catalog 
    output = 'miles_stellar_' + strlowcase( tag ) + '.fits'
    mwrfits, new_struc, output, /create

end

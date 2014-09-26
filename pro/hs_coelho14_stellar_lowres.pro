; + 
; NAME:
;              HS_COELHO14_STELLAR_LOWRES
;
; PURPOSE:
;              Organize a lower-resolution version of the Coelho14 stellar library 
;
; USAGE:
;     hs_coelho14_stellar_lowres, sig_conv, d_wave=d_wave, loc_coelho=loc_coelho
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

pro hs_coelho14_stellar_lowres, sig_conv, d_wave=d_wave, $
    loc_coelho=loc_coelho, silent=silent

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
        spawn, 'ls ' + loc_coelho + 't*.fits', list_fits 
        n_fits = n_elements( list_fits )
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Can not find the directory for Coelho stellar spectra: '
        print, loc_coelho 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endelse

    ;; Read in the first one 
    struc0 = hs_coelho14_read_stellar( list_fits[0], /silent )

    ;; New wavelength arrary for the low-res spectrum
    min_wave = struc0.min_wave 
    max_wave = struc0.max_wave 
    new_wave = floor( min_wave ) + d_wave * $
        findgen( round( ( max_wave - min_wave ) / d_wave ) )
    n_pixel = n_elements( new_wave )

    ;; New structure for output 
    new_struc = { index:0, wave:new_wave, flux:fltarr( n_pixel ), $
        teff:0.0, logg:0.0, feh:0.0, afe:0.0, sig_res:sig_conv, $
        comment:'' }
    new_struc = replicate( new_struc, n_fits )

    ;; Start the iteration 
    for ii = 0L, ( n_fits - 1 ), 1 do begin 

        new_struc[ ii ].index = ( ii + 1 )

        if keyword_set( silent ) then begin 
            struc_ori = hs_coelho14_read_stellar( list_fits[0], /silent )
        endif else begin 
            struc_ori = hs_coelho14_read_stellar( list_fits[0] )
        endelse

        ;; Read in the stellar parameters 
        new_struc[ ii ].teff = struc_ori.teff
        new_struc[ ii ].logg = struc_ori.logg
        new_struc[ ii ].feh  = struc_ori.feh 
        new_struc[ ii ].afe  = struc_ori.afe 
        new_struc[ ii ].comment = struc_ori.name

        ;; Convolve the high-res spectra to low-res 
        flux_conv = hs_spec_convolve( struc_ori.wave, struc_ori.flux, 6.4, $
            sig_conv )

        ;; Interpolate the low-z spectrum to a new wavelength grid 
        index_inter = findex( struc_ori.wave, new_wave )
        new_struc[ ii ].flux = interpolate( flux_conv, index_inter )

    endfor 
        
    ;; Save the results to a FITS catalog 
    output = 'coelho14_stellar_lowres_' + $
        strcompress( string( sig_conv, format='(I6)' ), /remove_all ) + '.fits'
    mwrfits, new_struc, output, /create

end

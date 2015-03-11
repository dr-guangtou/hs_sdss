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
;             Song Huang, 2014/09/26 - Include sig_conv, and new_sampling 
;-
; CATEGORY:   HS_MILES
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_miles_read_stellar, file_miles, silent=silent, plot=plot, $
    sig_conv=sig_conv, new_sampling=new_sampling, miles_cat=miles_cat

    file_miles = strcompress( file_miles, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_miles, '/ ', /extract ) 
    base_miles = temp[ n_elements( temp ) - 1 ]

    temp = hs_string_replace( base_miles, 'm', '' ) 
    star = hs_string_replace( temp, 'V', '' )
    star_num = long( star )

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
        readcol, file_miles, wave, flux, format='F,F', delimiter=' ', $
            comment='#', count=n_pixel, /silent 
        min_wave = min( wave ) 
        max_wave = max( wave ) 
        d_wave   = ( wave[1] - wave[0] )
        ;; 
        wave_ori = wave 
        flux_ori = flux

        ;; Get the stellar parameters 
        if NOT keyword_set( miles_cat ) then begin 
            miles_cat = 'miles_catalog.fits'
        endif 
        if NOT file_test( miles_cat ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find MILES_Catalog.fits file !!! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif else begin 
            cat = mrdfits( miles_cat, 1, /silent )
            index_use = where( long( cat.miles ) EQ star_num ) 
            if ( index_use[0] EQ -1 ) then begin 
                print, 'Can not find the star: ' + star + ' !!!' 
                message, ' ' 
            endif else begin 
                teff = cat[ index_use ].teff 
                logg = cat[ index_use ].logg 
                feh  = cat[ index_use ].fe_h
                comment = cat[ index_use ].name + ' / ' + $
                    cat[ index_use ].sptype
            endelse
        endelse

        ;; Convolve the spectrum into lower resolution if necessary 
        if keyword_set( sig_conv ) then begin 

            sig_conv = float( sig_conv ) 

            if keyword_set( new_sampling ) then begin 
                new_sampling = float( new_sampling ) 
            endif else begin 
                new_sampling = d_wave 
            endelse 

            ;; Convolve the high-res spectra to low-res 
            flux_conv = hs_spec_convolve( wave, flux, 63.0, sig_conv )
            ;; Interpolate it to new wavelength array
            new_wave = floor( min_wave ) + new_sampling * $
                findgen( round( ( max_wave - min_wave ) / new_sampling ) )
            n_pixel = n_elements( new_wave )
            index_inter = findex( wave, new_wave )
            new_flux = interpolate( flux_conv, index_inter )

            wave   = new_wave 
            flux   = new_flux 
            d_wave = new_sampling
            min_wave = min( wave ) 
            max_wave = max( wave )

        endif 
            
        ;; Define the output structure 
        struc_miles = { name:base_miles, wave:wave, flux:flux, $
            d_wave:d_wave, n_pixel:n_pixel, sampling:'linear', $
            min_wave:min_wave, max_wave:max_wave, $
            r_spec:2000.0, resolution:2.5, unit:'angstrom', $
            teff:teff, logg:logg, feh:feh, afe:!VALUES.F_NaN, $
            wavescale:'air', comment:comment }

        if keyword_set( sig_conv ) then begin 
            struc_miles.resolution = sig_conv 
            struc_miles.unit       = 'km/s'
        endif 

    endelse

    ;; Plot the spectrum 
    if keyword_set( plot ) then begin 

        if keyword_set( sig_conv ) then begin 
            sig_str = strcompress( string( sig_conv, format='(I4)' ), $
                /remove_all ) 
            plot_file = file_miles + '_sig' + sig_str + '.eps'
        endif else begin 
            plot_file = file_miles + '.eps'
        endelse

        psxsize=60 
        psysize=15
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 

        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        cgPlot, wave_ori, flux_ori, xstyle=1, ystyle=1, $ 
            xrange=[ min_wave, max_wave ], $ 
            xthick=8.0, ythick=8.0, charsize=2.5, charthick=8.0, $ 
            xtitle='Wavelength (Angstrom)', ytitle='Flux', $
            title=star, linestyle=0, thick=1.8, $
            position=[ 0.07, 0.14, 0.995, 0.90], yticklen=0.01
        if keyword_set( sig_conv ) then begin 
            cgOplot, wave, flux, linestyle=0, thick=1.5, $
                color=cgColor( 'Red' ) 
        endif 

        device, /close 
        set_plot, mydevice 

    endif

    return, struc_miles

end

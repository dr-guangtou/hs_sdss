; + 
; NAME:
;              HS_INDOUS_READ_STELLAR
;
; PURPOSE:
;              Read the FITS binary format stellar spectrum from Indo-US library 
;
; USAGE:
;     spec = hs_indous_read_stellar( file_indous )
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
; CATEGORY:    HS_INDOUS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_indous_read_stellar, file_indous, silent=silent, plot=plot, $
    sig_conv=sig_conv, new_sampling=new_sampling

    file_indous = strcompress( file_indous, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_indous, '/ ', /extract ) 
    base_indous = temp[ n_elements( temp ) - 1 ]
    name_str = hs_string_replace( base_indous, '.fits', '' )

    ;; Check the file 
    if NOT file_test( file_indous ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + file_indous
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_indous 
        endif 

        ;; Read in the spectra 
        spec = mrdfits( file_indous, 1, head, /silent )

        ;; Merged spectrum 
        wave    = spec.wavelength 
        flux    = spec.spectrum
        n_pixel = n_elements( wave_ori )
        min_wave = min( wave ) 
        max_wave = max( wave ) 
        d_wave   = ( wave[1] - wave[0] )

        ;; Get the stellar parameters 
        teff = float( fxpar( head, 'TEFF' ) )
        logg = float( fxpar( head, 'LOGG' ) )
        feh  = float( fxpar( head, 'FEH'  ) )

        ;; Deal with the GAPS 
        gaps  = fxpar( head, 'GAPS' ) 
        if ( ( NOT keyword_set( silent ) ) AND ( gaps NE 0 ) ) then begin 
            print, ' The spectrum has a gap between:: '
            print, gaps 
        endif 
        if ( gaps NE 0 ) then begin 
            gaps = strcompress( gaps, /remove_all ) 
            temp = strsplit( gaps, ',', /extract )  
            n_seg = n_elements( temp ) 
            for jj = 0, ( n_seg - 1 ), 1 do begin 
                temp2 = strsplit( temp[jj], '-', /extract )
                if ( n_elements( temp2 ) NE 2 ) then begin 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    print, ' Something wrong with the header !!!! '
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    return, -1
                endif else begin 
                    w0 = float( temp2[0] ) 
                    w1 = float( temp2[1] ) 
                    index_gap = where( ( wave GE ( w0 - 0.4 ) ) AND $
                        ( wave LE ( w1 + 0.4 ) ) ) 
                    if ( index_gap[0] NE -1 ) then begin 
                        flux[ index_gap ] = !VALUES.F_NaN
                    endif 
                endelse 
            endfor 
        endif 
        ;; 
        wave_ori = wave 
        flux_ori = flux

        ;; Convolve the spectrum into lower resolution if necessary 
        if keyword_set( sig_conv ) then begin 

            sig_conv = float( sig_conv ) 

            if keyword_set( new_sampling ) then begin 
                new_sampling = float( new_sampling ) 
            endif else begin 
                new_sampling = d_wave 
            endelse 

            ;; Convolve the high-res spectra to low-res 
            flux_conv = hs_spec_convolve( wave, flux, 30.0, sig_conv )
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
        if ( gaps NE 0 ) then begin 
            gaps = strcompress( gaps ) 
        endif else begin 
            gaps = ''
        endelse
        struc_indous = { name:base_indous, wave:wave, flux:flux, $
            d_wave:d_wave, n_pixel:n_pixel, sampling:"linear", $
            min_wave:min_wave, max_wave:max_wave, $
            r_spec:4200.0, resolution:30.0, unit:'km/s', $
            teff:teff, logg:logg, feh:feh, afe:!VALUES.F_NaN, $
            comment:gaps, wavescale:'air' }

        if keyword_set( sig_conv ) then begin 
            struc_indous.resolution = sig_conv 
            struc_indous.unit       = 'km/s'
        endif 

    endelse 

    ;; Plot the spectrum 
    if keyword_set( plot ) then begin 

        if keyword_set( sig_conv ) then begin 
            sig_str = strcompress( string( sig_conv, format='(I4)' ), $
                /remove_all ) 
            plot_file = hs_string_replace( file_indous, '.fits', '' ) + $ 
                '_sig' + sig_str + '.eps'
        endif else begin 
            plot_file = hs_string_replace( file_indous, '.fits', '' ) + '.eps'
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
            title=name_str, linestyle=0, thick=1.8, $
            position=[ 0.07, 0.14, 0.995, 0.90], yticklen=0.01
        if keyword_set( sig_conv ) then begin 
            cgOplot, wave, flux, linestyle=0, thick=1.5, $
                color=cgColor( 'Red' ) 
        endif 

        device, /close 
        set_plot, mydevice 

    endif


    return, struc_indous

end

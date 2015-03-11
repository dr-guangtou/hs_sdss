; + 
; NAME:
;              HS_COELHO14_READ_STELLAR
;
; PURPOSE:
;              Read the synthetic stellar spectrum from Coelho (2014) 
;
; USAGE:
;     spec = hs_coelho14_read_stellar( file_coelho )
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
; CATEGORY:    HS_COELHO
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_coelho14_read_stellar, file_coelho14, plot=plot, silent=silent, $
    sig_conv=sig_conv, new_sampling=new_sampling

    file_coelho14 = strcompress( file_coelho14, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_coelho14, '/ ', /extract ) 
    base_coelho14 = temp[ n_elements( temp ) - 1 ]
    name_str = hs_string_replace( base_coelho14, '.fits', '' )

    ;; Check the file 
    if NOT file_test( file_coelho14 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + file_coelho14
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_coelho14 
        endif 

        ;; Read in the spectra 
        flux = mrdfits( file_coelho14, 0, head, /silent )
        ;; Get stellar parameters from the header
        teff = float( fxpar( head, 'TEFF' ) )
        logg = float( fxpar( head, 'LOG_G' ) )
        feh  = float( fxpar( head, 'FEH'  ) )
        afe  = float( fxpar( head, 'AFE'  ) )

        ;; First, get a wavelength array 
        n_pixel = long( fxpar( head, 'NAXIS1' ) )
        min_wave = float( fxpar( head, 'CRVAL1' ) ) 
        d_wave = float( fxpar( head, 'CDELT1' ) ) 
        wave = min_wave + ( findgen( n_pixel ) * d_wave ) 
        max_wave = max( wave )
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
            flux_conv = hs_spec_convolve( wave, flux, 22.0, sig_conv )
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
        struc_coelho14 = { name:base_coelho14, wave:wave, flux:flux, $
            d_wave:d_wave, n_pixel:n_pixel, sampling:"linear", $
            min_wave:min_wave, max_wave:max_wave, $
            r_spec:20000.0, resolution:6.4, unit:'km/s', $
            teff:teff, logg:logg, feh:feh, afe:afe, $
            wavescale:'vac', comment:'' }

        if keyword_set( sig_conv ) then begin 
            struc_coelho14.resolution = sig_conv 
            struc_coelho14.unit       = 'km/s'
        endif 

    endelse

    ;; Plot the spectrum 
    if keyword_set( plot ) then begin 

        if keyword_set( sig_conv ) then begin 
            sig_str = strcompress( string( sig_conv, format='(I4)' ), $
                /remove_all ) 
            plot_file = hs_string_replace( file_coelho14, '.fits', '' ) + $ 
                '_sig' + sig_str + '.eps'
        endif else begin 
            plot_file = hs_string_replace( file_coelho14, '.fits', '' ) + '.eps'
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

    return, struc_coelho14 

end

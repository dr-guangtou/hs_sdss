; + 
; NAME:
;              HS_COELHO07_READ_SSP
;
; PURPOSE:
;              Read the fits format spectrum from Coelho+07 SSP model 
;
; USAGE:
;     spec = hs_coelho07_read_ssp( file_coelho07, /plot ) 
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_COELHO
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_coelho07_read_ssp, file_coelho07, plot=plot, silent=silent

    file_coelho07 = strcompress( file_coelho07, /remove_all )
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_coelho07, '/ ', /extract ) 
    base_coelho07 = temp[ n_elements( temp ) - 1 ]

    ;; Extract information from the file name
    name_str = hs_string_replace( base_coelho07, '.fits', '' )
    temp = strsplit( base_coelho07, '.', /extract )
    seg1 = temp[1] 
    seg2 = temp[2] 
    seg3 = temp[3]
    seg4 = temp[4] 

    ;; Get metallicity and [a/Fe] 
    case seg1 of 
        'm05p00' : begin 
                      afe   =  0.0
                      metal = -0.5
                      feh   = -0.5
                   end
        'm05p04' : begin 
                      afe   =  0.4
                      metal = -0.2 
                      feh   = -0.5
                   end
        'p00p00' : begin 
                      afe   =  0.0
                      metal =  0.0  
                      feh   =  0.0
                   end
        'p00p04' : begin 
                      afe   =  0.4
                      metal =  0.3  
                      feh   =  0.0
                   end
        'p02p00' : begin 
                      afe   =  0.0
                      metal =  0.2  
                      feh   =  0.2
                   end
        'p02p04' : begin 
                      afe   =  0.4
                      metal =  0.5  
                      feh   =  0.2
                   end
        else: begin 
                  print, 'Not valid COELHO07 SSP!! Check Again!! ' 
                  message, ' ' 
              end
    endcase 

    ;; Get IMF 
    imf_string = seg2 
    imf_slope  = 1.20

    ;; Get the SSP Type 
    ssp_type   = seg3 

    ;; Get the age of the SSP 
    age = float( hs_string_replace( seg4, 'gyr', '' ) ) 

    ;; Check the file 
    if NOT file_test( file_coelho07 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + file_coelho07
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_coelho07 
        endif 

        ;; Read in the spectra 
        flux = mrdfits( file_coelho07, 0, head, /silent )

        ;; First, get a wavelength array 
        n_pixel  = long(  fxpar( head, 'NAXIS1' ) )
        min_wave = float( fxpar( head, 'CRVAL1' ) ) 
        d_wave   = float( fxpar( head, 'CDELT1' ) ) 
        wave     = min_wave + ( findgen( n_pixel ) * d_wave ) 
        max_wave = max( wave )

        ;; Define the output structure 
        struc_coelho07 = { name:name_str, wave:wave, flux:flux, $
            min_wave:min_wave, max_wave:max_wave, $
            d_wave:d_wave, n_pixel:n_pixel, sampling:'linear', $ 
            imf:imf_string, slope:imf_slope, imf_string:imf_string, $
            age:age, metal:metal, afe:afe, feh:feh, $
            resolution:1.0, unit:'angstrom', redshift:0.0, $
            mass_s:0.0, mass_rs:0.0, type:ssp_type, wave_scale:'vac', $
            comment:'' } 

    endelse

    ;; Plot the spectrum 
    if keyword_set( plot ) then begin 

        plot_file = hs_string_replace( file_coelho07, '.fits', '' ) + '.eps'

        psxsize=60 
        psysize=15
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 

        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        cgPlot, wave, flux, xstyle=1, ystyle=1, $ 
            xrange=[ min_wave, max_wave ], $ 
            xthick=8.0, ythick=8.0, charsize=2.5, charthick=8.0, $ 
            xtitle='Wavelength (Angstrom)', ytitle='Flux', $
            title=name_str, linestyle=0, thick=1.8, $
            position=[ 0.07, 0.14, 0.995, 0.90], yticklen=0.01

        device, /close 
        set_plot, mydevice 

    endif
        
    return, struc_coelho07

end

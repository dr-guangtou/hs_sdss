; + 
; NAME:
;              HS_MARASTON_READ_SSP 
;
; PURPOSE:
;              Read the fits format spectrum from MIUSCAT and MILES library 
;
; USAGE:
;     spec = hs_miuscat_read_ssp( file_miuscat, /plot, mass_file=mass_file ) 
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_MIUSCAT
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function hs_miuscat_read_ssp, file_miuscat, plot=plot, silent=silent, $
    mass_file=mass_file 

    file_miuscat = strcompress( file_miuscat, /remove_all ) 
    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( file_miuscat, '/ ', /extract ) 
    file_miuscat_new = temp[ n_elements( temp ) - 1 ]

    ;; Check the file 
    if NOT file_test( file_miuscat ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the miuscat spectra : ' + file_miuscat 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' About to read in: ' + file_miuscat_new
        ;; Read in the spectra
        spec = mrdfits( file_miuscat, 0, head, /silent )

        ;; Get the sampling method 
        tag = 'Type of sampling:' 
        sampling = hs_retrieve_para( head, tag, " '", 6 )

        ;; First, get a wavelength array 
        n_pixel  = fix( fxpar( head, 'NAXIS1' ) )
        min_wave = float( fxpar( head, 'CRVAL1' ) ) 
        d_wave = float( fxpar( head, 'CDELT1' ) ) 
        wave = min_wave + ( findgen( n_pixel ) * d_wave ) 
        max_wave = max( wave )

        ;; Then adjust the unit for wavelength array to Angstrom
        case sampling of 
            'ln'     : wave = exp( wave )
            'log10'  : wave = 10.0D^(wave)
            'linear' : wave = wave 
            else     : begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something is wrong ! Check! '
                print, ' The allowed sampling formats are: ln, log10, linear '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
                end
        endcase

        ;; Get Min/Max Wavelength in Angstrom 
        min_wave = min( wave ) 
        max_wave = max( wave )

    endelse

    ;; Define the output structure 
    struc_miuscat = { name:'', wave:fltarr( n_pixel ), flux:fltarr( n_pixel ), $
        min_wave:0.0, max_wave:0.0, d_wave:0.0, n_pixel:0.0, sampling:'', $ 
        imf:'', slope:0.0, imf_string:'', age:0.0, metal:0.0, $
        resolution:0.0, unit:'', redshift:0.0, $
        mass_s:0.0, mass_rs:0.0, wavescale:'air' } 

    ;; Put basic information in 
    struc_miuscat.name = file_miuscat_new 
    struc_miuscat.wave = wave 
    struc_miuscat.flux = spec 
    struc_miuscat.min_wave = min_wave 
    struc_miuscat.max_wave = max_wave 
    struc_miuscat.sampling = sampling
    struc_miuscat.d_wave   = d_wave 
    struc_miuscat.n_pixel  = n_pixel 

    ;; Get other information about the spectra from the header 
    tag = 'IMF, Slope:' 
    struc_miuscat.imf   = hs_retrieve_para( head, tag, " ,:'", 5 )
    struc_miuscat.slope = float( hs_retrieve_para( head, tag, " ,:'", 6 ) )

    tag = 'Age, [M/H]:' 
    struc_miuscat.age   = float( hs_retrieve_para( head, tag, " ,:'", 5 ) )
    struc_miuscat.metal = float( hs_retrieve_para( head, tag, " ,:'", 6 ) )

    tag = 'Spectral resolution:' 
    struc_miuscat.resolution = float( hs_retrieve_para( head, tag, " ,:'", 5 ) )
    struc_miuscat.unit = hs_retrieve_para( head, tag, " ,:'()", 6 )

    tag = 'Redshift (z):' 
    struc_miuscat.redshift = float( hs_retrieve_para( head, tag, " ,:'", 5 ) )

    ;; Match to the MIUSCAT_MASS.fits file
    ;; Find the mass file 
    if keyword_set( mass_file ) then begin 
        mass_file = strcompress( mass_file, /remove_all ) 
        if NOT file_test( mass_file ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the MIUSCAT SSPs Mass file: ' + mass_file 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif
    endif else begin 
        spawn, 'locate miuscat_mass.fits', list 
        if ( list[0] EQ '' ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the MIUSCAT SSPs Mass file: miuscat_mass.fits' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin 
            mass_file = strcompress( list[0], /remove_all ) 
            if ( n_elements( list ) GE 2 ) then begin 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                print, ' Multiple miuscat_mass.fits found! Be Careful! '
                print, '     Only the first one is used ! '
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                return, -1 
            endif
        endelse
    endelse
    ;; Read in the mass file 
    mass_struc = mrdfits( mass_file, 1, hh, /silent )
    ;; Match the imf string, age and metallicity 
    imf_string = strcompress( struc_miuscat.imf, /remove_all ) + $
        strcompress( string( struc_miuscat.slope, format='(F4.2)' ), $
        /remove_all)
    met_string = strcompress( string( struc_miuscat.metal, format='(F6.2)' ), $
        /remove_all )
    mass_met_str = strcompress( string( mass_struc.met, format='(F6.2)' ), $
        /remove_all )
    struc_miuscat.imf_string = imf_string
    index_ssp = where( ( mass_struc.imf_str EQ imf_string ) AND $
        ( mass_met_str EQ met_string ) AND $ 
        ( mass_struc.age EQ struc_miuscat.age ) ) 
        ;( ABS( mass_struc.age - struc_miuscat.age ) LE 0.002 ) ) 
    if ( ( index_ssp[0] EQ -1 ) OR ( n_elements( index_ssp ) GT 1 ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' IMF: ' + imf_string 
        print, ' AGE: ' + string( struc_miuscat.age )  
        print, ' MET: ' + string( struc_miuscat.metal )  
        print, ' INDEX: ', index_ssp[0] 
        print, ' NUMBER:', n_elements( index_ssp )
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong! Can not find the unique matched SSP '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1  
    endif else begin 
        struc_miuscat.mass_s  = mass_struc[ index_ssp ].mcor1
        struc_miuscat.mass_rs = mass_struc[ index_ssp ].mcor2
    endelse

    ;; Plot the spectrum 
    if keyword_set( plot ) then begin 

        plot_file = file_miuscat_new + '.eps'
        psxsize=60 
        psysize=15
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        cgPlot, struc_miuscat.wave, struc_miuscat.flux, xstyle=1, ystyle=1, $ 
            xrange=[ min_wave, max_wave ], $ 
            xthick=8.0, ythick=8.0, charsize=2.5, charthick=8.0, $ 
            xtitle='Wavelength (Angstrom)', ytitle='Flux', $
            title=file_miuscat_new, linestyle=0, thick=1.8, $
            position=[ 0.07, 0.14, 0.995, 0.90], yticklen=0.01

        device, /close 
        set_plot, mydevice 

    endif
        
    return, struc_miuscat

end

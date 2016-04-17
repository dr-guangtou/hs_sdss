; + 
; NAME:
;              HS_PPXF_EMI_REMOVE
;
; PURPOSE:
;              Remove the emission line from the spectrum using pPXF fitting 
;
; USAGE:
;    hs_ppxf_emi_remove, spec_file 
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First  version 
;             Song Huang, 2014/06/12 - Second version 
;             Song Huang, 2014/06/13 - Third  version 
;             Song Huang, 2014/06/14 - Change color scheme; Allow .txt spectra 
;
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_setup_ssp_library, temp_list, velscale, fwhm_data, fwhm_libr, $ 
    stellar_templates, wave_range_temp, wave_log_temp, $ 
    dir_ssplib=dir_ssplib, n_models=n_models, quiet=quiet, $
    min_temp=min_temp, max_temp=max_temp, ssp_txt=ssp_txt

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    on_error, 2
    compile_opt idl2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( dir_ssplib ) then begin 
        dir_ssplib = strcompress( dir_ssplib, /remove_all ) 
    endif else begin 
        hvdisp_location, hvdisp_home, data_home
        if keyword_set( ssp_txt ) then begin 
            dir_ssplib = data_home + 'lib/base/'
        endif else begin 
            dir_ssplib = data_home + 'lib/miuscat/'
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    fwhm_data = float( fwhm_data )
    fwhm_libr = float( fwhm_libr )
    if ( fwhm_data GT fwhm_libr ) then begin 
        fwhm_dif = SQRT( fwhm_data^2.0 - fwhm_libr^2.0 )
    endif else begin 
        fwhm_dif = -1.0 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp_list = strcompress( temp_list, /remove_all ) 
    if NOT file_test( temp_list ) then begin 
        message, 'Can not find the templates list : ' + temp_list 
    endif else begin 
        n_models   = file_lines( temp_list ) 
        temp_files = strarr( n_models ) 
        readcol, temp_list, temp_files, format='A', comment='#', delimiter=' ', $
            /silent 
        spec_models = dir_ssplib + strcompress( temp_files, /remove_all )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the first one for wavelength range 
    if keyword_set( ssp_txt ) then begin 
        readcol, spec_models[0], wave_temp, flux_temp, format='F,D', $
            delimiter=' ', comment='#', /silent
        spec_samp = ( wave_temp[1] - wave_temp[0] )
        wave_range_temp = [ wave_temp[0], $
            wave_temp[ n_elements( wave_temp ) - 1 ] ]
    endif else begin 
        fits_read, spec_models[0], flux_temp, head_temp 
        spec_samp = sxpar( head_temp, 'CDELT1' )
        wave_range_temp = sxpar( head_temp, 'CRVAL1' ) + [ 0d, $
            sxpar( head_temp, 'CDELT1' ) * $
            ( sxpar( head_temp, 'NAXIS1' ) - 1d ) ]
    endelse
    ;; Log-rebin the SSP spectrum 
    log_rebin, wave_range_temp, flux_temp, flux_log_temp, wave_log_temp, $
        velscale=velscale 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( min_temp ) then begin 
        min_temp = float( min_temp ) 
    endif else begin 
        min_temp = wave_range_temp[0]
    endelse
    if keyword_set( max_temp ) then begin 
        max_temp = float( max_temp ) 
    endif else begin 
        max_temp = wave_range_temp[1]
    endelse
    wave_lin_temp = exp( wave_log_temp ) 
    index_use = where( wave_lin_temp GT min_temp AND wave_lin_temp LT max_temp )
    if ( index_use[0] EQ -1 ) then begin 
        message, 'Something wrong with the wavelength range for templates !!'
    endif 
    n_pix_use = n_elements( index_use )  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    stellar_templates = dblarr( n_pix_use, n_models ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Convolve the models
    if ( fwhm_dif LT 0.0 ) then begin 
        do_convolve = 0 
    endif else begin 
        do_convolve = 1 
        sigma = ( fwhm_dif / 2.355 / spec_samp )
        lsf =psf_gaussian( npixel=( 2 * ceil( 4 * sigma ) + 1 ), st_dev=sigma, $
            /norm, ndim=1 )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for kk = 0, ( n_models - 1 ), 1 do begin
        ;;
        if ~keyword_set( quiet ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, '  Read in : ' + spec_models[ kk] + '  !! '
        endif 
        ;;
        if keyword_set( ssp_txt ) then begin 
            readcol, spec_models[ kk ], wave_model, flux_model, format='F,D', $
                delimiter=' ', comment='#', /silent
        endif else begin 
            fits_read, spec_models[ kk ], flux_model
        endelse
        ;;
        if ( do_convolve EQ 1 ) then begin 
            flux_model = convol( flux_model, lsf ) 
        endif 
        ;;
        log_rebin, wave_range_temp, flux_model, flux_new, wave_new, $
            velscale=velscale
        flux_new = flux_new[ index_use ]
        stellar_templates[ *, kk ] = flux_new
        if ~keyword_set( quiet ) then begin 
            cgPlot, exp( wave_new ), flux_new, xs=1, ys=1, thick=2.0, $
                color=cgColor( 'Red' ), xtitle='Wavelength', ytitle='Flux'
        endif
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Update the parameters 
    wave_range_temp = [ min( wave_lin_temp[ index_use ] ), $ 
        max( wave_lin_temp[ index_use ] ) ]
    wave_log_temp   = wave_log_temp[ index_use ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_setup_emiline, wave, fwhm_data, emiline_templates, $
    line_name, line_wave, n_emi=n_emi

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_pix = n_elements( wave ) 
    ;; Assumes instrumental sigma is constant in Angstrom
    sigma_data = ( fwhm_data / 2.355 )
    ;; Possible emission lines
    lines = [ 3726.03, $ ; [OII]  3727 
              3728.82, $ ; [OII]  3729 
              4101.76, $ ; Hdelta 4101 
              4340.47, $ ; Hgamma 4340 
              4861.33, $ ; Hbeta  4861 
              4958.92, $ ; [OIII] 4959 
              5006.84, $ ; [OIII] 5007 
              5199.00, $ ; [NI]   5199 
              6300.30, $ ; [OI]   6300 
              6548.03, $ ; [NII]  6548 
              6583.41, $ ; [NII]  6583 
              6562.80, $ ; Halpha 6563 
              6716.47, $ ; [SII]  6717 
              6730.85  $ ; [SII]  6731 
              ]
    names = [ 'OII3727',  'OII3729',  'Hd4101',  'Hg4340',  'Hb4861', $ 
              'OIII4959', 'OIII5007', 'NI5199',  'OI6300',  'NII6548', $ 
              'NII6584',  'Ha6563',   'SII6717', 'SII6731' ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_use = where( ( lines GT min( wave ) ) AND ( lines LT max( wave ) ) )
    if ( index_use[0] EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' No useful line is found !!!!! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        n_emi     = 0
        emi_lines = dblarr( n_pix )
    endif else begin 
        n_emi     = n_elements( index_use )
        emi_lines = dblarr( n_pix, n_emi ) 
        for ii = 0, ( n_emi - 1 ), 1 do begin 
            emi_lines[ *, ii ] = $
                EXP( -0.5D * ( ( wave - lines[ index_use[ii] ] ) / $
                sigma_data )^2.0 )
        endfor 
    endelse 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    line_name = names[ index_use ] 
    line_wave = lines[ index_use ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    emiline_templates = emi_lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro make_compare_plot, fits_file, spec_loc, plot_name=plot_name, $
    hvdisp_home=hvdisp_home, second_file=second_file 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd = hvdisp_home + 'coadd/'
    loc_lis   = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spec_loc = strcompress( spec_loc, /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the file 
    if file_test( fits_file ) then begin 
        fits_file = strcompress( fits_file, /remove_all ) 
        struc_temp = mrdfits( fits_file, 1 ) 
        temp = strsplit( fits_file, '/', /extract )
        fits_name = temp[ n_elements( temp ) - 1 ]
        ;; 
        temp = strsplit( fits_name, '.', /extract )
        name_str = temp[0]
    endif else begin 
        message, ' Can not find the file : ' + fits_file + ' !!!'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Usefule data
    wave    = struc_temp.wave 
    flux    = struc_temp.flux 
    sub_arr = struc_temp.sub_arr 
    res_arr = struc_temp.res_arr 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    size_arr = size( sub_arr, /dim ) 
    n_pix  = ( size( sub_arr, /dim ) )[0]
    if ( n_elements( size_arr ) EQ 1 ) then begin 
        n_temp = 1 
    endif else begin 
        n_temp = ( size( sub_arr, /dim ) )[1]
    endelse
    emi_arr = dblarr( n_pix, n_temp )
    ;; 
    for kk = 0, ( n_temp - 1 ), 1 do begin 
        emi_arr[ *, kk ] = ( flux - sub_arr[ *, kk ] ) 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( second_file ) then begin 
        if NOT file_test( second_file ) then begin 
            plot_second = 0 
        endif else begin 
            struc_second = mrdfits( second_file, 1 )
            wave_second  = struc_second.wave
            flux_second  = struc_second.flux
            sub_second   = struc_second.sub_arr 
            res_second   = struc_second.res_arr 
            n_pix_second = ( size( sub_second, /dim ) )[0]
            size_second  = size( sub_second, /dim ) 
            emi_second   = dblarr( n_pix_second, n_temp )
            for ll = 0, ( n_temp - 1 ), 1 do begin 
                emi_second[ *, ll ] = ( flux_second - sub_second[ *, ll ] ) 
            endfor 
            plot_second = 1
        endelse
    endif else begin 
        plot_second = 0 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Index list 
    index_list = loc_lis + 'hs_index_emi.lis' 
    ;; Make a figure to compare the results
    if NOT keyword_set( plot_name ) then begin 
        if ( plot_second EQ 1) then begin 
            compare_plot = spec_loc + 'ppxf/' + name_str + '_both.eps' 
        endif else begin 
            compare_plot = spec_loc + 'ppxf/' + name_str + '.eps' 
        endelse
    endif else begin 
        compare_plot = spec_loc + 'ppxf/' + $
            strcompress( plot_name, /remove_all ) 
    endelse
    ;; Color list 
    color_file = loc_lis + 'hs_color.txt'
    color_list = [ 'HRED1', 'HTAN1', 'HBLU2', 'HGRN1', 'HORG1', 'HBLU1' ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mydevice = !d.name 
    !p.font=1
    set_plot, 'ps' 
    psxsize = 40 
    psysize = 26
    ;; Part 1 
    pos1a = [ 0.095, 0.56, 0.35, 0.99 ]
    pos1b = [ 0.095, 0.10, 0.35, 0.56 ]
    ;; Part 2
    pos2a = [ 0.355, 0.56, 0.61, 0.99 ]
    pos2b = [ 0.355, 0.10, 0.61, 0.56 ]
    ;; Part 3
    pos3a = [ 0.615, 0.56, 0.99, 0.99 ]
    pos3b = [ 0.615, 0.10, 0.99, 0.56 ]
    ;;
    wave_range_1 = [ 4020, 4480 ]
    wave_range_2 = [ 4805, 5090 ]
    wave_range_3 = [ 6120, 6920 ]
    index_wave_1 = where( ( wave GT wave_range_1[0] ) AND $ 
                          ( wave LT wave_range_1[1] ) )
    index_wave_2 = where( ( wave GT wave_range_2[0] ) AND $ 
                          ( wave LT wave_range_2[1] ) )
    index_wave_3 = where( ( wave GT wave_range_3[0] ) AND $ 
                          ( wave LT wave_range_3[1] ) )
    index_wave = [ index_wave_1, index_wave_2, index_wave_3 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    min_flux = min( flux[ index_wave ] ) 
    max_flux = max( flux[ index_wave ] ) 
    sep_flux = ( ( max_flux - min_flux ) * 0.36 )
    flux_range = [ ( min_flux - 0.05 ), ( max_flux + sep_flux ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    min_res = ( min( emi_arr ) < min( res_arr ) ) 
    max_res = ( max( emi_arr ) > max( res_arr ) )
    res_range = [ ( min_res - 0.005 ), ( max_res + 0.008 ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, filename=compare_plot, font_size=9.0, /encapsulated, $
        /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; First plot
    ;; Axis
    cgPlot, wave, flux, xs=1, ys=1, /noerase, $
        xrange=wave_range_1, yrange=flux_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos1a, $
        xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, ytitle='Normalized Flux', xticklen=0.03, yticklen=0.03
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot the features
    hs_spec_index_over, index_list, color_fill='TAN2', color_line='TAN2'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK4'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original data 
    cgOplot, wave, flux, thick=3.5, linestyle=0, color=cgColor( 'BLK6' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Stellar templates
    for ii = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, sub_arr[ *, ii ], thick=3.0, linestyle=0, $
            color=cgColor( color_list[ii], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, sub_second[ *, ii ], thick=3.0, linestyle=2, $
                color=cgColor( color_list[ii], filename=color_file )
        endif 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Label 
    hs_spec_index_over, index_list, /label_only, l_cushion=40, $
        xstep=10, ystep=16, max_overlap=7, charsize=2.2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, flux, xs=1, ys=1, /noerase, $
        xrange=wave_range_1, yrange=flux_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos1a, $
        xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xticklen=0.03, yticklen=0.03
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual & Emission line
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, emi_arr[*,0], xs=1, ys=1, /noerase, $
        xrange=wave_range_1, yrange=res_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos1b, $
        xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xtitle='Wavelength', ytitle='Emi. & Res. Flux', $
        xticklen=0.03, yticklen=0.03
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot the features
    hs_spec_index_over, index_list, color_fill='TAN2', color_line='TAN2'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK4'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual spectra 
    for ii = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, res_arr[ *, ii ], thick=2.0, linestyle=( ii + 1 ), $
            color=cgColor( 'BLK5' )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, res_second[ *, ii ], thick=2.0, $
                linestyle=( ii + 1 ), color=cgColor( 'BLU3' )
        endif
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line spectra 
    for jj = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, emi_arr[ *, jj ], thick=3.0, $
            linestyle=0, color=cgColor( color_list[jj], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, emi_second[ *, jj ], thick=3.0, linestyle=2, $
                color=cgColor( color_list[jj], filename=color_file )
        endif
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, emi_arr[*,0], xs=1, ys=1, /noerase, $
        xrange=wave_range_1, yrange=res_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos1b, $
        xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xticklen=0.03, yticklen=0.03
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Second plot
    ;; Axis
    cgPlot, wave, flux, xs=1, ys=1, /noerase, $
        xrange=wave_range_2, yrange=flux_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos2a, $
        xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, ytickformat='(A1)', xticklen=0.03, yticklen=0.03
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot the features
    hs_spec_index_over, index_list, color_fill='TAN2', color_line='TAN2'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK4'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original data 
    cgOplot, wave, flux, thick=3.5, linestyle=0, color=cgColor( 'BLK6' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Stellar templates
    for ii = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, sub_arr[ *, ii ], thick=3.0, linestyle=0, $
            color=cgColor( color_list[ii], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, sub_second[ *, ii ], thick=3.0, linestyle=2, $
                color=cgColor( color_list[ii], filename=color_file )
        endif 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Label 
    hs_spec_index_over, index_list, /label_only, l_cushion=40, $
        xstep=10, ystep=16, max_overlap=4, charsize=2.2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, flux, xs=1, ys=1, /noerase, $
        xrange=wave_range_2, yrange=flux_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos2a, $
        xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xticklen=0.03, yticklen=0.03, ytickformat='(A1)'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual & Emission line
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, emi_arr[*,0], xs=1, ys=1, /noerase, $
        xrange=wave_range_2, yrange=res_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos2b, $
        xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xtitle='Wavelength',  $
        xticklen=0.03, yticklen=0.03, ytickformat='(A1)'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot the features
    hs_spec_index_over, index_list, color_fill='TAN2', color_line='TAN2'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK4'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual spectra 
    for ii = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, res_arr[ *, ii ], thick=2.0, linestyle=( ii + 1 ), $
            color=cgColor( 'BLK5' )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, res_second[ *, ii ], thick=2.0, $
                linestyle=( ii + 1 ), color=cgColor( 'BLU3' )
        endif
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line spectra 
    for jj = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, emi_arr[ *, jj ], thick=3.0, $
            linestyle=0, color=cgColor( color_list[jj], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, emi_second[ *, jj ], thick=3.0, linestyle=2, $
                color=cgColor( color_list[jj], filename=color_file )
        endif
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, emi_arr[*,0], xs=1, ys=1, /noerase, $
        xrange=wave_range_2, yrange=res_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos2b, $
        xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xticklen=0.03, yticklen=0.03, ytickformat='(A1)'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Third plot
    ;; Axis
    cgPlot, wave, flux, xs=1, ys=1, /noerase, $
        xrange=wave_range_3, yrange=flux_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos3a, $
        xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, ytickformat='(A1)', xticklen=0.03, yticklen=0.03
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot the features
    hs_spec_index_over, index_list, color_fill='TAN2', color_line='TAN2'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK4'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original data 
    cgOplot, wave, flux, thick=3.5, linestyle=0, color=cgColor( 'BLK6' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Stellar templates
    for ii = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, sub_arr[ *, ii ], thick=3.0, linestyle=0, $
            color=cgColor( color_list[ii], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, sub_second[ *, ii ], thick=3.0, linestyle=2, $
                color=cgColor( color_list[ii], filename=color_file )
        endif 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Label 
    hs_spec_index_over, index_list, /label_only, l_cushion=40, $
        xstep=10, ystep=16, max_overlap=3, charsize=2.2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, flux, xs=1, ys=1, /noerase, $
        xrange=wave_range_3, yrange=flux_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos3a, $
        xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xticklen=0.03, yticklen=0.03, ytickformat='(A1)'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual & Emission line
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, emi_arr[*,0], xs=1, ys=1, /noerase, $
        xrange=wave_range_3, yrange=res_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos3b, $
        xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xtitle='Wavelength', $ 
        xticklen=0.03, yticklen=0.03, ytickformat='(A1)'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot the features
    hs_spec_index_over, index_list, color_fill='TAN2', color_line='TAN2'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK4'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual spectra 
    for ii = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, res_arr[ *, ii ], thick=2.0, linestyle=( ii + 1 ), $
            color=cgColor( 'BLK5' )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, res_second[ *, ii ], thick=2.0, $
                linestyle=( ii + 1 ), color=cgColor( 'BLU3' )
        endif
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line spectra 
    for jj = 0, ( n_temp - 1 ), 1 do begin 
        cgOPlot, wave, emi_arr[ *, jj ], thick=3.0, $
            linestyle=0, color=cgColor( color_list[jj], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, emi_second[ *, jj ], thick=3.0, linestyle=2, $
                color=cgColor( color_list[jj], filename=color_file )
        endif
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Axis
    cgPlot, wave, emi_arr[*,0], xs=1, ys=1, /noerase, $
        xrange=wave_range_3, yrange=res_range, thick=1.5, $
        color=cgColor( 'BLK2' ), position=pos3b, $
        xthick=8, ythick=8, charthick=4, charsize=3.0, $
        /nodata, xticklen=0.03, yticklen=0.03, ytickformat='(A1)'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, /close 
    set_plot, mydevice
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_ppxf_emi_subfull, spec_loc, name_str, ssplib_index, flux_sub, flux_res, $
    hvdisp_home=hvdisp_home, plot=plot, lib_comb=lib_comb

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd   = hvdisp_home + 'coadd/'
    loc_templis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the spectrum
    spec_file = spec_loc + name_str + '.txt'
    readcol, spec_file, wave, flux, error, flag, format='F,D,D,I', $
        comment='#', delimiter=' ', /silent
    n_pixel = n_elements( wave )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Collect all the three fitting result files
    if keyword_set( lib_comb ) then begin 
        f_file = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_f_ppxf_emirem.fits'
    endif else begin 
        f_file = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_f_ppxf_emirem.fits'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the results
    f_data = mrdfits( f_file, 1, /silent ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the emission line spectra 
    f_emiline = ( f_data.emiline * f_data.flux_norm ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the residual spectra
    f_res = ( ( f_data.data - f_data.best ) * f_data.flux_norm )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Interpolate the emission line spectra to the original wavelength grid
    f_emiinter = interpolate( f_emiline, findex( f_data.wave, wave ), /grid)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Interpolate the residual spectra to the original wavelength grid
    f_resinter = interpolate( f_res, findex( f_data.wave, wave ), /grid)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Clean the emission line spectra
    f_emiinter[ where( ( wave LT min( f_data.wave ) ) OR $
                       ( wave GT max( f_data.wave ) ) ) ] = 0.0D
    ;; Clean the residual spectra
    f_resinter[ where( ( wave LT min( f_data.wave ) ) OR $
                       ( wave GT max( f_data.wave ) ) ) ] = 0.0D
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Combine the three emission line data
    emiinter = f_emiinter 
    ;; Combine the three residual line data
    resinter = f_resinter 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; To show 
    emishow  = ( min( flux ) + 0.1 ) + emiinter 
    resshow  = ( min( flux ) + 0.1 ) + resinter 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line subtracted spectrum 
    flux_sub = ( flux - emiinter ) 
    ;; Residual spectrum output 
    flux_res = resinter 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( plot ) then begin 
        cgPlot,  wave, flux,     xs=1, ys=1, thick=1.5, color=cgColor( 'Blue' )
        cgOplot, wave, flux_sub, thick=1.5, color=cgColor( 'Red' ) 
        cgOplot, wave, resshow,  thick=1.5, color=cgColor( 'Gray' )
        cgOplot, wave, emishow,  thick=1.8, color=cgColor( 'Green' )
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the results to a new txt file  
    output = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
        '_ppxf_emirem_b.txt' 
    openw,  lun, output, width=500, /get_lun 
    printf, lun, '#Wavelength  ,  Flux  ,  Flux_Sub  ,  Emiline  '
    for jj = 0, ( n_pixel - 1 ), 1 do begin 
        printf, lun, string( wave[jj] ) + '    ' + string( flux[jj] ) + $
            '    ' + string( flux_sub[jj] ) + '    ' + string( emiinter[jj] )
    endfor
    close, lun 
    free_lun, lun
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_ppxf_emi_subtract, spec_loc, name_str, ssplib_index, flux_sub, flux_res, $
    hvdisp_home=hvdisp_home, plot=plot, lib_comb=lib_comb

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd   = hvdisp_home + 'coadd/'
    loc_templis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the spectrum
    spec_file = spec_loc + name_str + '.txt'
    readcol, spec_file, wave, flux, error, flag, format='F,D,D,I', $
        comment='#', delimiter=' ', /silent
    n_pixel = n_elements( wave )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Collect all the three fitting result files
    if keyword_set( lib_comb ) then begin 
        file1 = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_1_ppxf_emirem.fits'
        file2 = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_2_ppxf_emirem.fits'
        file3 = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_3_ppxf_emirem.fits'
    endif else begin 
        file1 = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_1_ppxf_emirem.fits'
        file2 = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_2_ppxf_emirem.fits'
        file3 = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
            '_3_ppxf_emirem.fits'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the results
    data1 = mrdfits( file1, 1, /silent ) 
    data2 = mrdfits( file2, 1, /silent )
    data3 = mrdfits( file3, 1, /silent )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the emission line spectra 
    emiline1 = ( data1.emiline * data1.flux_norm ) 
    emiline2 = ( data2.emiline * data2.flux_norm ) 
    emiline3 = ( data3.emiline * data3.flux_norm ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the residual spectra
    res1 = ( ( data1.data - data1.best ) * data1.flux_norm )
    res2 = ( ( data2.data - data2.best ) * data2.flux_norm )
    res3 = ( ( data3.data - data3.best ) * data3.flux_norm )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Interpolate the emission line spectra to the original wavelength grid
    emiinter1 = interpolate( emiline1, findex( data1.wave, wave ), /grid)
    emiinter2 = interpolate( emiline2, findex( data2.wave, wave ), /grid)
    emiinter3 = interpolate( emiline3, findex( data3.wave, wave ), /grid)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Interpolate the residual spectra to the original wavelength grid
    resinter1 = interpolate( res1, findex( data1.wave, wave ), /grid)
    resinter2 = interpolate( res2, findex( data2.wave, wave ), /grid)
    resinter3 = interpolate( res3, findex( data3.wave, wave ), /grid)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Clean the emission line spectra
    emiinter1[ where( ( wave LT min( data1.wave ) ) OR $
                      ( wave GT max( data1.wave ) ) ) ] = 0.0D
    emiinter2[ where( ( wave LT min( data2.wave ) ) OR $
                      ( wave GT max( data2.wave ) ) ) ] = 0.0D
    emiinter3[ where( ( wave LT min( data3.wave ) ) OR $
                      ( wave GT max( data3.wave ) ) ) ] = 0.0D 
    ;; Clean the residual spectra
    resinter1[ where( ( wave LT min( data1.wave ) ) OR $
                      ( wave GT max( data1.wave ) ) ) ] = 0.0D
    resinter2[ where( ( wave LT min( data2.wave ) ) OR $
                      ( wave GT max( data2.wave ) ) ) ] = 0.0D
    resinter3[ where( ( wave LT min( data3.wave ) ) OR $
                      ( wave GT max( data3.wave ) ) ) ] = 0.0D 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Combine the three emission line data
    emiinter = ( emiinter1 + emiinter2 + emiinter3 ) 
    ;; Combine the three residual line data
    resinter = ( resinter1 + resinter2 + resinter3 ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; To show 
    emishow  = ( min( flux ) + 0.1 ) + emiinter 
    resshow  = ( min( flux ) + 0.1 ) + resinter 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line subtracted spectrum 
    flux_sub = ( flux - emiinter ) 
    ;; Residual spectrum output 
    flux_res = resinter 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( plot ) then begin 
        cgPlot,  wave, flux,     xs=1, ys=1, thick=1.5, color=cgColor( 'Blue' )
        cgOplot, wave, flux_sub, thick=1.5, color=cgColor( 'Red' ) 
        cgOplot, wave, resshow,  thick=1.5, color=cgColor( 'Gray' )
        cgOplot, wave, emishow,  thick=1.8, color=cgColor( 'Green' )
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the results to a new txt file  
    output = spec_loc + 'ppxf/' + name_str + '_' + ssplib_index + $
        '_ppxf_emirem_a.txt' 
    ;;;;;
    openw,  lun, output, width=500, /get_lun 
    printf, lun, '#Wavelength  ,  Flux  ,  Flux_Sub  ,  Emiline  '
    for jj = 0, ( n_pixel - 1 ), 1 do begin 
        printf, lun, string( wave[jj] ) + '    ' + string( flux[jj] ) + $
            '    ' + string( flux_sub[jj] ) + '    ' + string( emiinter[jj] )
    endfor
    close, lun 
    free_lun, lun
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_ppxf_emi_fitting, spec_file, temp_list, $
    fwhm_data=fwhm_data, fwhm_libr=fwhm_libr, $
    min_wave=min_wave,   max_wave=max_wave, $
    spec_txt=spec_txt,   hvdisp_home=hvdisp_home, $ 
    plot_result=plot_result, save_result=save_result, $ 
    vel_guess=vel_guess,     sig_guess=sig_guess, $
    sn_ratio=sn_ratio, mdegree=mdegree, n_moments=n_moments, $
    quiet=quiet, debug=debug, ssp_txt=ssp_txt, $
    prefix=prefix, save_temp=save_temp, result_file=result_file

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    on_error, 2
    compile_opt idl2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Useful constant 
    cs = 299792.458d ; speed of light, km/s
    ;; FWHM of the input spectrum 
    if keyword_set( fwhm_data ) then begin 
        fwhm_data = float( fwhm_data ) 
    endif else begin 
        fwhm_data = 2.76  ;; Assume it's SDSS spectrum
    endelse
    ;; FWHM of the library 
    if keyword_set( fwhm_libr ) then begin 
        fwhm_libr = float( fwhm_libr ) 
    endif else begin 
        fwhm_libr = 2.51  ;; Assume it's MILES or MIUSCAT 
    endelse
    ;; Degree for the Multiplicative Polynomials for the fit 
    if keyword_set( mdegree ) then begin 
        mdegree = long( mdegree ) 
    endif else begin 
        mdegree = 10 
    endelse
    ;; Order of the Gauss-Hermite moments to fit 
    if keyword_set( n_moments ) then begin 
        n_moments = long( n_moments ) 
    endif else begin 
        n_moments = 2
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd   = hvdisp_home + 'coadd/'
    loc_templis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the input spectrum 
    spec_file = strcompress( spec_file, /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; String for the name of the spectrum
    ;; SPEC_NAME ; SPEC_LOC ; NAME_STR
    temp = strsplit( spec_file, '/', /extract )  
    nseg = n_elements( temp ) 
    spec_name = temp[ nseg - 1 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( nseg EQ 1 ) then begin 
        spec_loc = ''
    endif else begin 
        spec_loc = '/'
        for nn = 0, ( nseg - 2 ), 1 do begin 
            spec_loc = spec_loc + temp[ nn ] + '/' 
        endfor 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp = strsplit( spec_name, '.', /extract ) 
    name_str = strcompress( temp[0], /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( prefix ) then begin 
        name_str = name_str + '_' + prefix 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( spec_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input spectrum file : ' + spec_file + ' !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( spec_txt ) then begin 
        if keyword_set( error_arr ) then begin 
            readcol, spec_file, wave_ori, flux_ori, error_ori, format='F,D,D', $
                delimiter=' ', comment='#', /silent 
        endif else begin 
            readcol, spec_file, wave_ori, flux_ori, format='F,D', $
                delimiter=' ', comment='#', /silent 
        endelse
    endif else begin 
        ;; TODO: Option for FITS spectrum
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Min/Max wavelength 
    if keyword_set( min_wave ) then begin 
        min_wave = float( min_wave ) 
    endif else begin 
        min_wave = min( wave_ori ) 
    endelse 
    if keyword_set( max_wave ) then begin 
        max_wave = float( max_wave ) 
    endif else begin 
        max_wave = max( wave_ori ) 
    endelse 
    ;; Trim the template 
    min_wave_temp = ( min_wave - 100.0 ) 
    max_wave_temp = ( max_wave + 100.0 ) 
    ;; Trim the spectrum 
    index_use = where( ( wave_ori GT min_wave ) AND ( wave_ori LT max_wave ) ) 
    if ( index_use[0] EQ -1 ) then begin 
        message, ' Something wrong with the wavelength range for data !!'
    endif 
    wave_trim = wave_ori[ index_use ]
    flux_trim = flux_ori[ index_use ]
    wave_range_trim = [ min( wave_trim ), max( wave_trim ) ]
    ;; Normalize the spectrum
    flux_norm      = median( flux_ori ) 
    flux_trim_norm = ( flux_trim / flux_norm )
    ;; Log-Rebin the spectrum
    log_rebin, wave_range_trim, flux_trim_norm, flux_trim_log, wave_trim_log, $
        velscale=velscale
    wave_trim_lin = exp( wave_trim_log ) 
    ;; Data for pPXF 
    galaxy = flux_trim_log
    ;; New wavelength range 
    min_wave = min( wave_trim_lin ) 
    max_wave = max( wave_trim_lin ) 
    wave_range = [ min_wave, max_wave ]
    wave_lin = wave_trim_lin
    n_pixel  = n_elements( wave_lin ) 
    ;; Add a constant noise 
    if keyword_set( sn_ratio ) then begin 
        sn_ratio = float( sn_ratio ) 
    endif else begin 
        sn_ratio = 200.0 
    endelse
    ;; XXX TODO: Under test 
    if NOT keyword_set( error_arr ) then begin 
        ;error = median( galaxy / sn_ratio ) 
        ;noise = ( galaxy * 0 ) + error
        noise = ( SQRT( galaxy ) ) / sn_ratio
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, ' Fitting spectrum : ' + name_str 
        print, ' Wavelength range : ' + string( min_wave, format='(F7.1)' ) + $
            string( max_wave, format='(F7.1)' ) 
        print, ' Pixel numbers    : ' + string( n_pixel,  format='(I6)' ) 
        print, ' Signal / Noise   : ' + string( sn_ratio, format='(I6)' ) 
        print, ' Velscale         : ' + string( velscale, format='(F6.2)' )  + $
            '  km/s'
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Setup the stellar library 
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, '# SETUP THE STELLAR LIBRARY ...'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ssp_list = loc_templis + strcompress( temp_list, /remove_all ) 
    ;;
    if keyword_set( ssp_txt ) then begin 
        hs_setup_ssp_library, ssp_list, velscale, fwhm_data, fwhm_libr, $
            stellar_templates, wave_range_temp, wave_log_temp, $
            n_models=n_models, min_temp=min_wave_temp, max_temp=max_wave_temp, $
            /quiet, /ssp_txt
    endif else begin 
        hs_setup_ssp_library, ssp_list, velscale, fwhm_data, fwhm_libr, $
            stellar_templates, wave_range_temp, wave_log_temp, $
            n_models=n_models, min_temp=min_wave_temp, max_temp=max_wave_temp, $
            /quiet
    endelse
    ;;
    wave_lin_temp = exp( wave_log_temp )
    n_pixel_temp  = n_elements( wave_lin_temp )
    if ~keyword_set( quiet ) then begin 
        print, n_models, ' SSPs have been adopted !'
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Normalize the template 
    stellar_templates = ( stellar_templates / median( stellar_templates ) )
    num_stellar = n_models
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Setup the emission line library 
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, '# SETUP THE EMISSION LINES TEMPLATES ...'
    endif 
    ;;
    hs_setup_emiline, wave_lin_temp, fwhm_data, emiline_templates, $
        line_name, line_wave, n_emi=num_emiline 
    ;;
    ;num_emiline = ( size( emiline_templates, /dim ) )[1] 
    if ~keyword_set( quiet ) then begin 
        print, num_emiline, ' emission lines have been adopted !'
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Combine the emission line and stellar templates 
    templates = [ [ stellar_templates ], [ emiline_templates ] ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Decide the VSYST for pPXF 
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, ' #                      MIN_WAVE        MAX_WAVE      N_PIXEL   '
        print, ' For spectrum : ', wave_range[0],      wave_range[1], n_pixel 
        print, ' For template : ', wave_range_temp[0], wave_range_temp[1], $
            n_pixel_temp
        print, '###############################################################'
    endif 
    dv = ( alog( wave_range_temp[0] / wave_range[0] ) * cs )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initial guess for kinematic parameters 
    if keyword_set( vel_guess ) then begin 
        vel_guess = float( vel_guess ) 
    endif else begin 
        vel_guess = 80.0D  ; km/s
    endelse
    if keyword_set( sig_guess ) then begin 
        sig_guess = float( sig_guess ) 
    endif else begin 
        sig_guess = 340.0D ; km/s
    endelse
    ;; 
    start = [ vel_guess, sig_guess ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Assign Component=0 for stellar templates 
    ;;    and Component=1 for emission line templates
    component = [ replicate( 0, num_stellar ) , replicate( 1, num_emiline ) ]
    moments   = [ n_moments , n_moments ] ;; Fit (Vel, Sig ) for both stars and gas 
    start     = [ [ start ] , [ start ] ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Run pPXF 
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, 'START THE ACTUAL FITTING PROCEDURE ... ' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ppxf, templates, galaxy, noise, velscale, start, solutions, $
        goodpixels=goodpixels, moments=moments, degree=-1, mdegree=mdegree, $ 
        vsyst=dv,  weights=weights, temp_arr=temp_arr, $
        component=component, bestfit=bestfit, /quiet
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ~keyword_set( quiet ) then begin 
        print, ' Done !! '
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show the results 
    n_goodpix  = n_elements( goodPixels )
    nzero_temp = n_elements( where( weights GT 0.0 ) )
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Velocity of the stellar component : ' + $
        string( solutions[ 0, 0 ], format='(F8.2)' ) + ' km/s ' 
    print, ' Veldisp of the stellar component  : ' + $
        string( solutions[ 1, 0 ], format='(F8.2)' ) + ' km/s ' 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Velocity of the emission lines component : ' + $
        string( solutions[ 0, 1 ], format='(F8.2)' ) + ' km/s ' 
    print, ' Veldisp of the emission lines component  : ' + $
        string( solutions[ 1, 1 ], format='(F8.2)' ) + ' km/s ' 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Chi^2/DOF          :  ', solutions[6]
    print, ' Desired Delta Chi^2:  ', sqrt( 2 * n_goodpix )    
    print, ' Current Delta Chi^2:', ( ( solutions[6] - 1 ) * n_goodpix )
    print, ' Nonzero Templates  : ', nzero_temp 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Recover the multiplicative polynomials 
    xx = cap_range( -1d, 1d, n_elements( galaxy ) ) 
    mpoly = 1d 
    for jj = 1, mdegree, 1 do begin 
        mpoly = mpoly + ( legendre( xx, jj ) * solutions[ ( 6 + jj ), 0 ] ) 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the results 
    if keyword_set( save_result ) then begin 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( result_file ) then begin 
            result_file = spec_loc + 'ppxf/' + result_file 
        endif else begin 
            if keyword_set( ssp_txt ) then begin 
                result_file = spec_loc + 'ppxf/' + name_str + $
                    '_ppxf_emirem.fits' 
            endif else begin 
                result_file = spec_loc + 'ppxf/' + name_str + $
                    '_ppxf_emirem.fits' 
            endelse
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        print, '###############################################################'
        print, ' Save the result to : ' + result_file 
        ;; Output structure  
        spec_result = { wave:fltarr( n_pixel ), $
            data:dblarr( n_pixel ), $
            best:dblarr( n_pixel ), $
            rres:dblarr( n_pixel ), $
            mpoly:dblarr( n_pixel ),   $
            stellar:dblarr( n_pixel ), $
            emiline:dblarr( n_pixel ), $
            flux_norm:flux_norm, n_pixel:n_pixel, n_goodpix:n_goodpix, $
            sn_ratio:sn_ratio, min_wave:min_wave, max_wave:max_wave, $
            vel_ste:solutions[0,0], sig_ste:solutions[1,0], $ 
            vel_gas:solutions[0,1], sig_gas:solutions[1,1], $ 
            chi2:solutions[6,0], $
            component:component, weights:weights, $
            line_name:line_name, line_wave:line_wave }
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Get the relative and absolute residual 
        relres = ( ( ( galaxy - bestfit ) / galaxy ) * 100.0 )
        absres = ( galaxy - bestfit )
        ;; Get the final contribution for each template spectrum 
        best_temp = temp_arr # weights 
        ;; Get the best fit stellar and emission line component
        index_ste = where( component EQ 0 ) 
        index_gas = where( component EQ 1 ) 
        temp_ste = temp_arr[*,index_ste] 
        temp_gas = temp_arr[*,index_gas]
        weights_ste = weights[index_ste]
        weights_gas = weights[index_gas]
        best_ste = temp_ste # weights_ste
        best_gas = temp_gas # weights_gas
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Save the results to structures
        spec_result.wave    = wave_lin 
        spec_result.data    = galaxy 
        spec_result.best    = bestfit 
        spec_result.rres    = relres
        spec_result.mpoly   = mpoly 
        spec_result.stellar = best_ste 
        spec_result.emiline = best_gas 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; First extension is the structure for main result  
        mwrfits, spec_result, result_file, /create    ;; dimension 0  
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( save_temp ) then begin 
            ;; Second extension for whole solutions 
            mwrfits, solutions,   result_file, /silent    ;; extension 1
            ;; Third extension for the templates
            mwrfits, templates,   result_file, /silent    ;; extension 2
        endif 
        print, '###############################################################'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        res_range = [ min( absres ), ( max( absres ) > max( best_gas ) ) ]

    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Plot  
    if keyword_set( debug ) then begin 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( ssp_txt ) then begin 
            result_plot = spec_loc + 'ppxf/' + name_str + '_ppxf_debug.eps' 
        endif else begin 
            result_plot = spec_loc + 'ppxf/' + name_str + '_ppxf_debug.eps' 
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        psxsize = 28 
        psysize = 22
        pos1 = [ 0.11, 0.30, 0.99, 0.98 ]
        pos2 = [ 0.11, 0.10, 0.99, 0.30 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, filename=result_plot, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, wave_ori, ( flux_ori / flux_norm ), xs=1, ys=1, /noerase, $
            xrange=wave_range_temp, yrange=[0.12,1.19], thick=1.5, $
            color=cgColor( 'BLK2' ), position=pos1, $
            xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
            /nodata, ytitle='Norm. Flux', xticklen=0.04
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Stellar templates
        for xx = 0, ( num_stellar - 1 ), 1 do begin 
            temp = stellar_templates[*,xx]
            cgOPlot, wave_lin_temp, ( temp / max( temp ) ), $
                color=cgColor( 'BLK2' ), thick=0.6
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Emission line templates
        for yy = 0, ( num_emiline - 1 ), 1 do begin 
            cgPlots, [ line_wave[yy], line_wave[yy] ], [ 0.12, 0.22 ], $
                linestyle=0, thick=1.5, color=cgColor( 'RED5' )
            cgText, ( line_wave[yy] + 10.0 ), 0.24, $
                strcompress( line_name[yy], /remove_all ), $
                alignment=0, charsize=1.2, color=cgColor( 'RED5' ), $
                orientation=90.0
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Data 
        cgOplot, wave_lin, galaxy, color=cgColor( 'BLK7' ), thick=2.0
        ;; 
        cgOplot, wave_lin, bestfit, color=cgColor( 'BLU6' ), linestyle=0, $
            thick=1.5
        ;;
        cgOplot, wave_lin, best_ste,  color=cgColor( 'RED5' ), thick=1.5, $
            linestyle=0 
        ;;
        cgOplot, wave_lin, mpoly,   color=cgColor( 'GRN5' ), linestyle=2, $
            thick=1.5
        ;;
        cgPlot, wave_ori, ( flux_ori / flux_norm ), xs=1, ys=1, /noerase, $
            xrange=wave_range_temp, yrange=[0.12,1.19], thick=1.5, $
            color=cgColor( 'BLK2' ), position=pos1, $
            xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
            /nodata, ytitle='Norm. Flux', xticklen=0.04
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Residual
        cgPlot, wave_lin, absres, xs=1, ys=1, thick=1.5, /noerase, $
            xrange=wave_range_temp, yrange=res_range, $
            color=cgColor( 'BLK6' ), position=pos2, $
            xthick=8, ythick=8, charthick=4, charsize=3.0, /nodata, $
            xtitle='Wavelength', ytitle='Res', xticklen=0.075
        cgOPlot, !X.Crange, [ 0.0, 0.0], linestyle=2, color=cgColor( 'BLK4' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for yy = 0, ( num_emiline - 1 ), 1 do begin 
            cgPlots, [ line_wave[yy], line_wave[yy] ], $
                [ res_range[0], res_range[1] ], $
                linestyle=2, thick=1.5, color=cgColor( 'RED4' )
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgOplot, wave_lin, absres, thick=1.5, linestyle=0, $
            color=cgColor( 'BLK7' )
        cgOplot, wave_lin, best_gas,  color=cgColor( 'Blue' ), thick=1.8, $
            linestyle=0
        ;; Only for test
        ;cgOplot, wave_lin, best_diff, color=cgColor( 'Red' ),   thick=1.5, $
        ;    linestyle=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, /close 
        set_plot, mydevice 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_ppxf_emi_remove, spec_file, hvdisp_home=hvdisp_home, $
    wrange1=wrange1, wrange2=wrange2, wrange3=wrange3, wrange4=wrange4, $ 
    lib_comb=lib_comb 
  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    on_error, 2
    compile_opt idl2
    resolve_all, /quiet
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd   = hvdisp_home + 'coadd/'
    loc_templis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location for the spectra
    ;; Read in the spectrum
    spec_file = strcompress( spec_file, /remove_all ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( NOT file_test( spec_file ) ) then begin 
        message, ' Check the spectrum file: ' + spec_file + ' !!'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; String for the name of the spectrum
    ;; SPEC_NAME ; SPEC_LOC ; NAME_STR
    temp = strsplit( spec_file, '/', /extract )  
    nseg = n_elements( temp ) 
    spec_name = temp[ nseg - 1 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( nseg EQ 1 ) then begin 
        spec_loc = ''
    endif else begin 
        spec_loc = '/'
        for nn = 0, ( nseg - 2 ), 1 do begin 
            spec_loc = spec_loc + temp[ nn ] + '/' 
        endfor 
    endelse
    ;;
    if NOT dir_exist( spec_loc + 'ppxf/' ) then begin 
        spawn, 'mkdir ' + spec_loc + 'ppxf/' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp = strsplit( spec_name, '.', /extract ) 
    name_str = strcompress( temp[0], /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; WAVE, FLUX, N_PIXEL 
    readcol, spec_file, wave, flux, error, flag, format='F,D,D,I', $
        comment='#', delimiter=' ', /silent
    n_pixel = n_elements( wave )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The list of stellar templates
    ;temp_files = [ 'mius_ku13.lis', 'mius_un18.lis' ]
    if NOT keyword_set( lib_comb ) then begin 
        ;; Maybe do not need so many tests
        ;temp_files = [ 'mius_un08.lis', 'mius_ku13.lis', 'mius_un13.lis', $
        ;    'mius_un18.lis', 'mius_un20.lis', 'mius_unmix.lis' ]
        temp_files = [ 'mius_ku13.lis', 'mius_un13.lis', $
                       'mius_un18.lis', 'mius_imix.lis' ]
    endif else begin
        temp_files = [ 'comb_krch.lis', 'comb_salp.lis', $
                       'comb_bthv.lis', 'comb_imix.lis' ]
    endelse
    n_temp = n_elements( temp_files ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Three files for each template 
    n_file = ( n_temp * 3 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Array for the emission line subtracted spectra 
    sub_arr = dblarr( n_pixel, n_temp ) 
    res_arr = dblarr( n_pixel, n_temp ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sub_ful = dblarr( n_pixel, n_temp ) 
    res_ful = dblarr( n_pixel, n_temp ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the wavelength ranges for fitting
    if NOT keyword_set( wrange1 ) then begin 
        wrange1 = [ 4020.0, 4490.0 ]
    endif else begin 
        if ( n_elements( wrange1 ) NE 2 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' WRANGE1 should be in the form of : [ W1, W2 ]  !!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            wrange1 = wrange1 
        endelse 
    endelse
    if NOT keyword_set( wrange2 ) then begin 
        wrange2 = [ 4760.0, 5090.0 ]
    endif else begin 
        if ( n_elements( wrange2 ) NE 2 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' WRANGE2 should be in the form of : [ W1, W2 ]  !!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            wrange2 = wrange2 
        endelse 
    endelse
    if NOT keyword_set( wrange3 ) then begin 
        wrange3 = [ 6100.0, 6850.0 ]
    endif else begin 
        if ( n_elements( wrange3 ) NE 2 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' WRANGE3 should be in the form of : [ W1, W2 ]  !!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            wrange3 = wrange3 
        endelse 
    endelse
    if NOT keyword_set( wrange4 ) then begin 
        wrange4 = [ 4030.0, 6850.0 ]
    endif else begin 
        if ( n_elements( wrange4 ) NE 2 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' WRANGE4 should be in the form of : [ W1, W2 ]  !!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            wrange4 = wrange4 
        endelse 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0, ( n_temp - 1 ), 1 do begin 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        temp_list = strcompress( temp_files[ii], /remove_all ) 
        temp      = strsplit( temp_list, '.', /extract ) 
        ;; Index for the IMF choice
        ssplib_index = temp[0] 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; First part
        ;; H_delta & H_gamma
        if keyword_set( lib_comb ) then begin 
            result_1 = name_str + '_' + ssplib_index + '_1_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange1[0], max_wave=wrange1[1], $
                /ssp_txt, /spec_txt, /save_result, $
                prefix=ssplib_index + '_1', /debug
        endif else begin 
            result_1 = name_str + '_' + ssplib_index + '_1_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange1[0], max_wave=wrange1[1], $
                /spec_txt, /save_result, $
                prefix=ssplib_index + '_1', /debug
        endelse
        ;;;;
        if NOT file_test( spec_loc + 'ppxf/' + result_1 ) then begin 
            message, ' Can not find : ' + result_1 + ' !!!!'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Second part
        ;; H_beta, [OIII] 4959, 5007
        if keyword_set( lib_comb ) then begin 
            result_2 = name_str + '_' + ssplib_index + '_2_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange2[0], max_wave=wrange2[1], $
                /ssp_txt, /spec_txt, /save_result, $
                prefix=ssplib_index + '_2', /debug
        endif else begin 
            result_2 = name_str + '_' + ssplib_index + '_2_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange2[0], max_wave=wrange2[1], $
                /spec_txt, /save_result, $
                prefix=ssplib_index + '_2', /debug
        endelse
        ;;;;
        if NOT file_test( spec_loc + 'ppxf/' + result_2 ) then begin 
            message, ' Can not find : ' + result_2 + ' !!!!'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Third part
        ;; [OI] 6300; H_alpha, [NII], and [SII]
        if keyword_set( lib_comb ) then begin 
            result_3 = name_str + '_' + ssplib_index + '_3_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange3[0], max_wave=wrange3[1], $
                /ssp_txt, /spec_txt, /save_result, $
                prefix=ssplib_index + '_3', /debug
        endif else begin 
            result_3 = name_str + '_' + ssplib_index + '_3_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange3[0], max_wave=wrange3[1], $
                /spec_txt, /save_result, $
                prefix=ssplib_index + '_3', /debug
        endelse
        if NOT file_test( spec_loc + 'ppxf/' + result_3 ) then begin 
            message, ' Can not find : ' + result_3 + ' !!!!'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Get the emission line subtraction file 
        if keyword_set( lib_comb ) then begin 
            hs_ppxf_emi_subtract, spec_loc, name_str, ssplib_index, $
                flux_sub, flux_res, hvdisp_home=hvdisp_home, /lib_comb 
        endif else begin 
            hs_ppxf_emi_subtract, spec_loc, name_str, ssplib_index, $
                flux_sub, flux_res, hvdisp_home=hvdisp_home 
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sub_arr[ *, ii ] = flux_sub
        res_arr[ *, ii ] = flux_res
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Full spectrum fitting
        if keyword_set( lib_comb ) then begin 
            result_f = name_str + '_' + ssplib_index + '_f_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange4[0], max_wave=wrange4[1], $
                /ssp_txt, /spec_txt, /save_result, $
                prefix=ssplib_index + '_f', /debug
        endif else begin 
            result_f = name_str + '_' + ssplib_index + '_f_ppxf_emirem.fits'
            hs_ppxf_emi_fitting, spec_file, temp_list, hvdisp_home=hvdisp_home, $
                min_wave=wrange4[0], max_wave=wrange4[1], $
                /spec_txt, /save_result, $
                prefix=ssplib_index + '_f', /debug
        endelse
        if NOT file_test( spec_loc + 'ppxf/' + result_f ) then begin 
            message, ' Can not find : ' + result_f + ' !!!!'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Get the emission line subtraction file 
        if keyword_set( lib_comb ) then begin 
            hs_ppxf_emi_subfull, spec_loc, name_str, ssplib_index, $
                flux_sub_full, flux_res_full, hvdisp_home=hvdisp_home, /lib_comb 
        endif else begin 
            hs_ppxf_emi_subfull, spec_loc, name_str, ssplib_index, $
                flux_sub_full, flux_res_full, hvdisp_home=hvdisp_home
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sub_ful[ *, ii ] = flux_sub_full
        res_ful[ *, ii ] = flux_res_full
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PLOT A
    if keyword_set( lib_comb ) then begin 
        fits_temp_a = spec_loc + 'ppxf/' + name_str + '_comb_ppxf_emirem_a.fits'
        plot_a      = name_str + '_comb_ppxf_emirem_a.eps'
    endif else begin 
        fits_temp_a = spec_loc + 'ppxf/' + name_str + '_mius_ppxf_emirem_a.fits'
        plot_a      = name_str + '_mius_ppxf_emirem_a.eps'
    endelse
    struc_temp_a = { wave:wave, flux:flux, sub_arr:sub_arr, res_arr:res_arr }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mwrfits, struc_temp_a, fits_temp_a, /create 
    ;; Make the comparison plot
    make_compare_plot, fits_temp_a, spec_loc, hvdisp_home=hvdisp_home, $
        plot_name=plot_a
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PLOT B
    if keyword_set( lib_comb ) then begin 
        fits_temp_b = spec_loc + 'ppxf/' + name_str + '_comb_ppxf_emirem_b.fits'
        plot_b      = name_str + '_comb_ppxf_emirem_b.eps'
    endif else begin 
        fits_temp_b = spec_loc + 'ppxf/' + name_str + '_mius_ppxf_emirem_b.fits'
        plot_b      = name_str + '_mius_ppxf_emirem_b.eps'
    endelse
    struc_temp_b = { wave:wave, flux:flux, sub_arr:sub_ful, res_arr:res_ful }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mwrfits, struc_temp_b, fits_temp_b, /create 
    ;; Make the comparison plot
    make_compare_plot, fits_temp_b, spec_loc, hvdisp_home=hvdisp_home, $
        plot_name=plot_b
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; PLOT C
    if keyword_set( lib_comb ) then begin 
        plot_c = name_str + '_comb_ppxf_emirem_c.eps'
    endif else begin 
        plot_c = name_str + '_mius_ppxf_emirem_c.eps'
    endelse
    make_compare_plot, fits_temp_a, spec_loc, hvdisp_home=hvdisp_home, $
        second_file=fits_temp_b, plot_name=plot_c
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro ppxf_emi_remove_test, hvdisp_home=hvdisp_home, $
    test_emi=test_emi, test_plot=test_plot

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_indexlis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if keyword_set( test_emi ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; EMI_REMOVE TEST 
        ;; Example spectrum
        spec_1 = loc_coadd + 'z0_s1k/z0_s1k_robust.txt'
        spec_2 = loc_coadd + 'z0_s1k/z0_s1k_median.txt'
        spec_3 = loc_coadd + 'z3_s7l/z3_s7l_robust.txt'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hs_ppxf_emi_remove, spec_test
        hs_ppxf_emi_remove, spec_test, /lib_comb
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 

    
    if keyword_set( test_plot ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; MAKE_COMPARE_PLOT TEST
        fits_a   = loc_coadd + 'z0_s1k/ppxf/z0_s1k_robust_ppxf_emirem_a.fits'
        fits_b   = loc_coadd + 'z0_s1k/ppxf/z0_s1k_robust_ppxf_emirem_b.fits'
        spec_loc = loc_coadd + 'z0_s1k/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        make_compare_plot, fits_b, spec_loc
        make_compare_plot, fits_a, spec_loc, second_file=fits_b
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

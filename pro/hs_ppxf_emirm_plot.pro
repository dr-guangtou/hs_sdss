pro hs_ppxf_emirm_plot, fits_file, hvdisp_home=hvdisp_home, $ 
    second_file=second_file, last_one=last_one 

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
    if ( plot_second EQ 1) then begin 
        compare_plot = name_str + '_both.eps' 
    endif else begin 
        compare_plot = name_str + '.eps' 
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
    hs_spec_index_over, index_list, color_fill='TAN1', color_line='TAN1'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK2'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original data 
    cgOplot, wave, flux, thick=3.5, linestyle=0, color=cgColor( 'BLK6' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Stellar templates
    ;for ii = 0, ( n_temp - 1 ), 1 do begin 
    ii = ( n_temp - 1)
        cgOPlot, wave, sub_arr[ *, ii ], thick=4.0, linestyle=0, $
            color=cgColor( 'GG2', filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, sub_second[ *, ii ], thick=4.0, linestyle=2, $
                color=cgColor( 'YY2', filename=color_file )
        endif 
    ;endfor 
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
    hs_spec_index_over, index_list, color_fill='TAN1', color_line='TAN1'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK2'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual spectra 
    ;for ii = 0, ( n_temp - 1 ), 1 do begin 
    ii = (n_temp - 1)
        cgOPlot, wave, res_arr[ *, ii ], thick=3.0, linestyle=2, $
            color=cgColor( 'BLK4' )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, res_second[ *, ii ], thick=3.0, $
                linestyle=3, color=cgColor( 'HBLU1', filename=color_file )
        endif
    ;endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line spectra 
    ;for jj = 0, ( n_temp - 1 ), 1 do begin 
    jj = (n_temp - 1)
        cgOPlot, wave, emi_arr[ *, jj ], thick=4.0, $
            linestyle=0, color=cgColor( 'GG2', filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, emi_second[ *, jj ], thick=4.0, linestyle=0, $
                color=cgColor( 'YY2', filename=color_file )
        endif
    ;endfor 
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
    hs_spec_index_over, index_list, color_fill='TAN1', color_line='TAN1'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK2'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original data 
    cgOplot, wave, flux, thick=3.5, linestyle=0, color=cgColor( 'BLK6' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Stellar templates
    ;for ii = 0, ( n_temp - 1 ), 1 do begin 
    ii = (n_temp - 1)
        cgOPlot, wave, sub_arr[ *, ii ], thick=4.0, linestyle=0, $
            color=cgColor( 'GG2', filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, sub_second[ *, ii ], thick=4.0, linestyle=0, $
                color=cgColor( 'YY2', filename=color_file )
        endif 
    ;endfor 
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
    hs_spec_index_over, index_list, color_fill='TAN1', color_line='TAN1'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK2'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual spectra 
    ;for ii = 0, ( n_temp - 1 ), 1 do begin 
    ii = (n_temp - 1)
        cgOPlot, wave, res_arr[ *, ii ], thick=3.0, linestyle=2, $
            color=cgColor( 'BLK4' ) 
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, res_second[ *, ii ], thick=2.0, $
                linestyle=3, color=cgColor( 'HBLU1', filename=color_file )
        endif
    ;endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line spectra 
    ;for jj = 0, ( n_temp - 1 ), 1 do begin 
    jj = (n_temp - 1)
        cgOPlot, wave, emi_arr[ *, jj ], thick=4.0, $
            linestyle=0, color=cgColor( 'GG2', filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, emi_second[ *, jj ], thick=4.0, linestyle=0, $
                color=cgColor( 'YY2', filename=color_file )
        endif
    ;endfor 
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
    hs_spec_index_over, index_list, color_fill='TAN1', color_line='TAN1'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK2'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Original data 
    cgOplot, wave, flux, thick=3.5, linestyle=0, color=cgColor( 'BLK6' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Stellar templates
    ;for ii = 0, ( n_temp - 1 ), 1 do begin 
    ii = (n_temp - 1)
        cgOPlot, wave, sub_arr[ *, ii ], thick=4.0, linestyle=0, $
            color=cgColor( color_list[ii], filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, sub_second[ *, ii ], thick=4.0, linestyle=0, $
                color=cgColor( color_list[ii], filename=color_file )
        endif 
    ;endfor 
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
    hs_spec_index_over, index_list, color_fill='TAN1', color_line='TAN1'
    hs_spec_index_over, index_list, /no_fill, /no_line, /center_line, $
        color_center='BLK2'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual spectra 
    ;for ii = 0, ( n_temp - 1 ), 1 do begin 
    ii = (n_temp - 1)
        cgOPlot, wave, res_arr[ *, ii ], thick=3.0, linestyle=2, $
            color=cgColor( 'BLK4' )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, res_second[ *, ii ], thick=3.0, $
                linestyle=3, color=cgColor( 'HBLU1', filename=color_file )
        endif
    ;endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Emission line spectra 
    ;for jj = 0, ( n_temp - 1 ), 1 do begin 
    jj = (n_temp - 1)
        cgOPlot, wave, emi_arr[ *, jj ], thick=4.0, $
            linestyle=0, color=cgColor( 'GG2', filename=color_file )
        if ( plot_second EQ 1) then begin 
            cgOPlot, wave_second, emi_second[ *, jj ], thick=4.0, linestyle=0, $
                color=cgColor( 'YY2', filename=color_file )
        endif
    ;endfor 
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

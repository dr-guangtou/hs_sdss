pro hvdisp_csp_sfh_overplot, list, to_png=to_png 

    ;; Read in the CSP file list
    if file_test( list ) then begin 
        readcol, list, csp_list, format='A', comment='#', delimiter=' ', $
            /silent 
        n_csp = n_elements( csp_list ) 
    endif else begin 
        print, 'Can not find the list file: ' + list + '!!' 
    endelse

    ;; Read in the look back time and SFR array
    for ii = 0, ( n_csp - 1 ), 1 do begin 
        csp_struct = mrdfits( csp_list[ ii ], 1, /silent ) 
        if ( ii EQ 0 ) then begin 
            time_arr = csp_struct.time_lb 
            sfr_arr = fltarr( n_elements( time_arr ), n_csp ) 
            age_arr = fltarr( n_csp )
        endif 
        n_time = n_elements( csp_struct.age_mw )
        age_arr[ ii ] = csp_struct.age_mw[ n_time - 1 ]
        sfr_arr[ *, ii ] = csp_struct.sfr * age_arr[ ii ] 
    endfor 

    ;; Min and Max of SFR 
    min_age = min( age_arr ) 
    max_age = max( age_arr ) 
    age_color = long( ( ( age_arr - min_age ) / ( max_age - min_age ) ) * 252 )
    min_sfr = 0.0 
    max_sfr = max( sfr_arr ) * 1.05 

    ;; Name of the figure 
    plot_file = 'mius_csp_s13_sfh.eps' 

    ;; Set up the figure 
    mydevice = !d.name 
    !p.font = 1 
    set_plot, 'ps' 
    device, filename=plot_file, font_size=9.0, /encapsulated, /color, /bold, $
        set_font='TIMES-ROMAN', xsize=40, ysize=25
    position = [ 0.13, 0.195, 0.995, 0.992 ]
    loadct, 13

    ;; Star the plot
    cgPlot, time_arr, sfr_arr[ *, 0 ], xstyle=1, ystyle=1, /nodata, $
        xthick=12.0, ythick=12.0, charsize=6.0, charthick=10.0, $
        position=position, yrange=[min_sfr, max_sfr], $
        xtitle='Lookback Time (Gyr)', ytitle='Normalized SFR'
    for jj = 0, ( n_csp - 1 ), 1 do begin 
        cgOplot, time_arr, sfr_arr[ *, ( n_csp - jj - 1) ], linestyle=0, $
            thick=6.5, color=age_color[ n_csp - jj - 1 ] 
    endfor 
    cgPlot, time_arr, sfr_arr[ *, 0 ], xstyle=1, ystyle=1, /nodata, $
        xthick=12.0, ythick=12.0, charsize=6.0, charthick=10.0, $
        position=position, yrange=[min_sfr, max_sfr], /noerase

    ;; Close the figure 
    device, /close 
    set_plot, mydevice

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( to_png ) then begin 
        spawn, 'which convert', imagick_convert 
        plot_png = hs_string_replace( plot_file, '.eps', '.png' )
        if ( imagick_convert NE '' ) then begin 
            spawn, imagick_convert + ' -density 200 ' + plot_file + $
                ' -quality 90 -flatten ' + plot_png 
        endif
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

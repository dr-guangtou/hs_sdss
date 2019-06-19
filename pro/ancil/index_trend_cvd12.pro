pro index_trend_cvd12, index_list=index_list 

    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
        if NOT file_test( index_list ) then begin 
            message, 'Can not find the index_list file: ' + index_list + ' !!!'
        endif 
    endif else begin 
        index_list = 'hs_index_all.lis'
    endelse
    index_str = str_replace( index_list, '.lis', '' ) 
    ;; Read in the index file 
    readcol, index_list, index_name, lam0, lam1, blue0, blue1, red0, red1, type, $
        format='A,F,F,F,F,F,F,I', comment='#', delimiter=' ', /silent 
    n_index = n_elements( index_name )

    ;; Open the SSP models file 
    cvd_index_file = 'cvd12_' + index_str + '.fits'
    ssp_index = mrdfits( cvd_index_file, 1, /silent, status=status ) 
    if ( status NE 0 ) then begin 
        print, 'Something wrong with the file !'
        message, ' '
    endif 

    prefix = 'CvD12'
    tag_name = tag_names( ssp_index )

    for ii = 0, ( n_index - 1 ), 1 do begin 
    ;for ii = 0, 1, 1 do begin 

        print, '###############################################################'
        print, ' Plot the index : ' + index_name[ii] 
        ;; the index we want to plot 
        index = strcompress( index_name[ii], /remove_all ) 
        if ( tag_indx( ssp_index, index ) EQ -1 ) then begin 
            print, 'Can not find the index : ' + index 
            message, ' '
        endif

        ;; find the relevant tag in the structure 
        index_upp = strupcase( index )
        index_num = where( strcmp( tag_name, index_upp ) EQ 1 ) 
        if ( index_num EQ -1 ) then begin 
            print, 'Something wrong with the index name ! '
            message, ' '
        endif 

        ;; plot name 
        plot_file = prefix + '_' + index + '.eps' 

        ;; set uo the figure 
        position_1 = [ 0.100, 0.15, 0.395, 0.800 ]
        position_2 = [ 0.395, 0.15, 0.690, 0.800 ]
        position_3 = [ 0.690, 0.15, 0.995, 0.800 ]
        position_4 = [ 0.100, 0.80, 0.995, 0.992 ]
        psxsize = 46 
        psysize = 20 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        ;; Index range 
        index_use = where( ( ssp_index.age GE 0.99 ) AND $
            ( ssp_index.age LE 15.0 )  )
        if ( index_use[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        min_index = min( ssp_index[ index_use ].( index_num ) ) 
        max_index = max( ssp_index[ index_use ].( index_num ) )
        index_sep = ( ( max_index - min_index ) / 10.0 )
        index_range = [ ( min_index - index_sep ), ( max_index + index_sep ) ]

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; First plot, trend with age 
        age_range = [ 1.99, 13.99 ] 
        cgPlot, ssp_index.age, ssp_index.( index_num ), xstyle=1, ystyle=1, $ 
            xrange=age_range, yrange=index_range, position=position_1, $
            xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
            xtitle='Age (Gyr)', ytitle=index_upp, /nodata, /noerase 
        ;; afe=0.0
        ;; bottom-light
        index_now = where( ( ssp_index.afe EQ 0 ) AND $
            ( ssp_index.slope EQ 'btl' ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Orange' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Orange' ) 
        ;; Chabrier
        index_now = where( ( ssp_index.afe EQ 0 ) AND $
            ( ssp_index.slope EQ 'cha' ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Green' ) 
        ;; x23
        index_now = where( ( ssp_index.afe EQ 0 ) AND $
            ( ssp_index.slope EQ 'x23' ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Black' ) 
        ;; x30
        index_now = where( ( ssp_index.afe EQ 0 ) AND $
            ( ssp_index.slope EQ 'x30' ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; x35
        index_now = where( ( ssp_index.afe EQ 0 ) AND $
            ( ssp_index.slope EQ 'x35' ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Red' ) 

        ;; Label 
        ;; Alpha
        xloc = ( position_1[0] + 0.02 )
        yloc = ( position_1[3] + 0.020 ) 
        label = 'Orange : Bottom-light IMF'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Orange' )
        xloc = ( position_1[0] + 0.02 )
        yloc = ( position_1[3] + 0.055 ) 
        label = 'Green : Chabrier IMF'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Green' )
        xloc = ( position_1[0] + 0.02 )
        yloc = ( position_1[3] + 0.090 ) 
        label = 'Black : Slope=2.30'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Black' )
        xloc = ( position_1[0] + 0.02 )
        yloc = ( position_1[3] + 0.125 ) 
        label = 'Blue : Slope=3.0'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Blue' )
        xloc = ( position_1[0] + 0.02 )
        yloc = ( position_1[3] + 0.160 ) 
        label = 'Red : Slope=3.5'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Red' )

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Second plot, trend with Alpha/Fe 
        met_range = [ -0.99, 4.99 ] 
        cgPlot, ssp_index.afe, ssp_index.( index_num ), xstyle=1, ystyle=1, $ 
            xrange=met_range, yrange=index_range, position=position_2, $
            xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
            xtitle='[Alpha/Fe]', /nodata, /noerase, ytickformat='(A1)'
        ;; Bottom-Light 
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.slope EQ 'btl' ) )
        x_arr = ssp_index[ index_now ].afe 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Orange' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Orange' ) 
        ;; Chabrier
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.slope EQ 'cha' ) )
        x_arr = ssp_index[ index_now ].afe 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Green' ) 
        ;; Slope=2.3
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.slope EQ 'x23' ) )
        x_arr = ssp_index[ index_now ].afe 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Black' ) 
        ;; Slope=3.0
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.slope EQ 'x30' ) )
        x_arr = ssp_index[ index_now ].afe 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; Slope=3.5
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.slope EQ 'x35' ) )
        x_arr = ssp_index[ index_now ].afe 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Red' ) 

        ;; Label 
        ;; Alpha
        xloc = ( position_2[0] + 0.02 )
        yloc = ( position_2[3] + 0.020 ) 
        label = 'Orange : Bottom-light IMF'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Orange' )
        xloc = ( position_2[0] + 0.02 )
        yloc = ( position_2[3] + 0.055 ) 
        label = 'Green : Chabrier IMF'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Green' )
        xloc = ( position_2[0] + 0.02 )
        yloc = ( position_2[3] + 0.090 ) 
        label = 'Black : Slope=2.30'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Black' )
        xloc = ( position_2[0] + 0.02 )
        yloc = ( position_2[3] + 0.125 ) 
        label = 'Blue : Slope=3.0'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Blue' )
        xloc = ( position_2[0] + 0.02 )
        yloc = ( position_2[3] + 0.160 ) 
        label = 'Red : Slope=3.5'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Red' )

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Third plot, trend with metallicity 
        imf_range = [ 0.1, 5.9 ] 
        cgPlot, ssp_index.imf_index, ssp_index.( index_num ), xstyle=1, ystyle=1, $ 
            xrange=imf_range, yrange=index_range, position=position_3, $
            xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
            xtitle='IMF', /nodata, /noerase, ytickformat='(A1)'
        ;; Age = 13.00
        ;; aFe=0.00 
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.afe EQ 0 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Black' ) 
        ;; aFe=0.20 
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.afe EQ 2 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Black' ) 
        ;; aFe=0.30 
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.afe EQ 3 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=3, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Black' ) 
        ;; aFe=0.40 
        index_now = where( ( ssp_index.age EQ 13 ) AND $
            ( ssp_index.afe EQ 4 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=4, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Black' ) 

        ;; Age = 3 Gyr
        index_now = where( ( ssp_index.age EQ 3 ) AND $
            ( ssp_index.afe EQ 0 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Blue' ) 

        ;; Age = 5 Gyr
        index_now = where( ( ssp_index.age EQ 5 ) AND $
            ( ssp_index.afe EQ 0 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Green' ) 

        ;; Age = 7 Gyr
        index_now = where( ( ssp_index.age EQ 7 ) AND $
            ( ssp_index.afe EQ 0 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Orange' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Orange' ) 

        ;; Age = 9 Gyr
        index_now = where( ( ssp_index.age EQ 9 ) AND $
            ( ssp_index.afe EQ 0 ) )
        x_arr = ssp_index[ index_now ].imf_index 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.6, /overplot, $
            color=cgColor( 'Red' ) 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Label
        ;; Age
        cgPlots, [ position_4[0], position_4[2] ], [ position_4[1], position_4[1] ], $
            linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm
        cgPlots, [ position_4[0], position_4[2] ], [ position_4[3], position_4[3] ], $
            linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm
        cgPlots, [ position_4[0], position_4[0] ], [ position_4[1], position_4[3] ], $
            linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm 
        cgPlots, [ position_4[2], position_4[2] ], [ position_4[1], position_4[3] ], $
            linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm

        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.020 ) 
        label = 'Black:13.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Black' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.055 ) 
        label = 'Red:9.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Red' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.090 ) 
        label = 'Orange:7.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Orange' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.125 ) 
        label = 'Green:5.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Green' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.160 ) 
        label = 'Blue:3.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Blue' )

        ;; Alpha/Fe 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.020 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=0, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[a/Fe]=0.0', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.055 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=2, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[a/Fe]=0.2', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.090 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=3, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[a/Fe]=0.3', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.125 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=4, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[a/Fe]=0.4', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 

        device, /close 
        set_plot, mydevice 

    endfor

end

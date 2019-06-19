pro index_trend_miuscat, index_list=index_list, imf_type=imf_type

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

    ;; IMF type 
    if keyword_set( imf_type ) then begin 
        imf_type = strcompress( imf_type, /remove_all ) 
        if ( ( imf_type NE 'un' ) AND ( imf_type NE 'bi' ) ) then begin 
            message, 'Something wrong with the IMF type !!!' 
        endif  
    endif else begin 
        imf_type = 'un' 
    endelse

    ;; Open the SSP models file 
    miu_index_file = 'miuscat_' + imf_type + '_' + index_str + '.fits'
    ssp_index = mrdfits( miu_index_file, 1, /silent, status=status ) 
    if ( status NE 0 ) then begin 
        print, 'Something wrong with the file !'
        message, ' '
    endif 
    ;;;
    ssp_index.age   = float( ssp_index.age ) 
    ssp_index.slope = float( ssp_index.slope ) 
    ssp_index.metal = float( ssp_index.metal ) 

    prefix = 'mius_' + imf_type
    tag_name = tag_names( ssp_index )

    for ii = 0, ( n_index - 1 ), 1 do begin 
    ;for ii = 8, 10, 1 do begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, '    Plotting for : ' + index_name[ii] 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

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
        index_use = where( $
            ( ssp_index.age GE 3.0 ) AND ( ssp_index.age LE 14.9 ) AND $
            ( ssp_index.metal GE -1.0 ) AND $
            ( ssp_index.slope GE 0.7 ) AND ( ssp_index.slope LE 2.5 ) )
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
        age_range = [ 3.0, 14.99 ] 
        cgPlot, ssp_index.age, ssp_index.( index_num ), xstyle=1, ystyle=1, $ 
            xrange=age_range, yrange=index_range, position=position_1, $
            xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
            xtitle='Age (Gyr)', ytitle=index_upp, /nodata, /noerase 
        ;; metal = -0.40
        ;; 2
        index_now = where( ( ssp_index.metal EQ -0.40 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; 3
        index_now = where( ( ssp_index.metal EQ -0.40 ) AND $
            ( ssp_index.slope EQ 2.3 ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; metal = 0.00
        ;; 2
        index_now = where( ( ssp_index.metal EQ 0.00 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 
        ;; 3
        index_now = where( ( ssp_index.metal EQ 0.00 ) AND $
            ( ssp_index.slope EQ 2.0 ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 
        ;; metal = 0.22
        ;; 2
        index_now = where( ( ssp_index.metal EQ 0.22 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; 3
        index_now = where( ( ssp_index.metal EQ 0.22 ) AND $
            ( ssp_index.slope EQ 2.0 ) )
        x_arr = ssp_index[ index_now ].age 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; Label 
        ;; metallicity
        xloc = ( position_1[0] + 0.01 )
        yloc = ( position_1[3] + 0.020 ) 
        label = 'Blue:[Z/H]=-0.40'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Blue' )
        xloc = ( position_1[0] + 0.01 )
        yloc = ( position_1[3] + 0.055 ) 
        label = 'Black:[Z/H]=+0.00'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Black' )
        xloc = ( position_1[0] + 0.01 )
        yloc = ( position_1[3] + 0.090 ) 
        label = 'Red:[Z/H]=+0.22'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Red' )
        ;; IMF slope 
        xloc = ( position_1[0] + 0.145 ) 
        yloc = ( position_1[3] + 0.020 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=0, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, 'Slope=1.30', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_1[0] + 0.145 ) 
        yloc = ( position_1[3] + 0.055 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=2, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, 'Slope=2.30', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Second plot, trend with metallicity 
        met_range = [ -1.19, 0.26 ] 
        cgPlot, ssp_index.metal, ssp_index.( index_num ), xstyle=1, ystyle=1, $ 
            xrange=met_range, yrange=index_range, position=position_2, $
            xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
            xtitle='[Z/H]', /nodata, /noerase, ytickformat='(A1)'
        ;; age = 5.0119 
        ;; 2
        index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; 3
        index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
            ( ssp_index.slope EQ 2.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; age = 7.9433 
        ;; 2
        index_now = where( ( ssp_index.age EQ 7.9433 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Green' ) 
        ;; 3
        index_now = where( ( ssp_index.age EQ 7.9433 ) AND $
            ( ssp_index.slope EQ 2.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Green' ) 
        ;; age = 10.000 
        ;; 2
        index_now = where( ( ssp_index.age EQ 10.000 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; 3
        index_now = where( ( ssp_index.age EQ 10.000 ) AND $
            ( ssp_index.slope EQ 2.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; age = 12.5893 
        ;; 2
        index_now = where( ( ssp_index.age EQ 12.5893 ) AND $
            ( ssp_index.slope EQ 1.30 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 
        ;; 3
        index_now = where( ( ssp_index.age EQ 12.5893 ) AND $
            ( ssp_index.slope EQ 2.00 ) )
        x_arr = ssp_index[ index_now ].metal 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 
        ;; Label
        ;; Age
        xloc = ( position_2[0] + 0.01 )
        yloc = ( position_2[3] + 0.020 ) 
        label = 'Blue:5.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Blue' )
        xloc = ( position_2[0] + 0.01 )
        yloc = ( position_2[3] + 0.055 ) 
        label = 'Green:8.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Green' )
        xloc = ( position_2[0] + 0.01 )
        yloc = ( position_2[3] + 0.090 ) 
        label = 'Orange:10.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Red' )
        xloc = ( position_2[0] + 0.01 )
        yloc = ( position_2[3] + 0.125 ) 
        label = 'Red:12.6 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Black' )
        ;; IMF slope 
        xloc = ( position_2[0] + 0.145 ) 
        yloc = ( position_2[3] + 0.020 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=0, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, 'Slope=1.30', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_2[0] + 0.145 ) 
        yloc = ( position_2[3] + 0.055 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=2, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, 'Slope=2.30', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Third plot, trend with metallicity 
        imf_range = [ 0.75, 2.60 ] 
        cgPlot, ssp_index.slope, ssp_index.( index_num ), xstyle=1, ystyle=1, $ 
            xrange=imf_range, yrange=index_range, position=position_3, $
            xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
            xtitle='IMF Slope', /nodata, /noerase, ytickformat='(A1)'
        ;; Age = 5.0119
        ;; 2 
        index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
            ( ssp_index.metal EQ -0.40 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; 3 
        index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
            ( ssp_index.metal EQ 0.00 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; 4 
        index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
            ( ssp_index.metal EQ 0.22 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=1, thick=4.0, /overplot, $
            color=cgColor( 'Blue' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Blue' ) 
        ;; Age = 7.9433
        ;; 2 
        index_now = where( ( ssp_index.age EQ 7.9433 ) AND $
            ( ssp_index.metal EQ -0.40 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Green' ) 
        ;; 3 
        index_now = where( ( ssp_index.age EQ 7.9433 ) AND $
            ( ssp_index.metal EQ 0.00 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Green' ) 
        ;; 4 
        index_now = where( ( ssp_index.age EQ 7.9433 ) AND $
            ( ssp_index.metal EQ 0.22 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=1, thick=4.0, /overplot, $
            color=cgColor( 'Green' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Green' ) 
        ;; Age = 10.000
        ;; 2 
        index_now = where( ( ssp_index.age EQ 10.000 ) AND $
            ( ssp_index.metal EQ -0.40 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; 3 
        index_now = where( ( ssp_index.age EQ 10.000 ) AND $
            ( ssp_index.metal EQ 0.00 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; 4 
        index_now = where( ( ssp_index.age EQ 10.000 ) AND $
            ( ssp_index.metal EQ 0.22 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=1, thick=4.0, /overplot, $
            color=cgColor( 'Red' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
            color=cgColor( 'Red' ) 
        ;; Age = 12.5893
        ;; 2 
        index_now = where( ( ssp_index.age EQ 12.5893 ) AND $
            ( ssp_index.metal EQ -0.40 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=2, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 
        ;; 3 
        index_now = where( ( ssp_index.age EQ 12.5893 ) AND $
            ( ssp_index.metal EQ 0.00 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=0, thick=4.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 
        ;; 4 
        index_now = where( ( ssp_index.age EQ 12.5893 ) AND $
            ( ssp_index.metal EQ 0.22 ) )
        x_arr = ssp_index[ index_now ].slope 
        y_arr = ssp_index[ index_now ].( index_num )
        index_sort = sort( x_arr )
        x_arr = x_arr[ index_sort ]
        y_arr = y_arr[ index_sort ]
        cgPlot, x_arr, y_arr, linestyle=1, thick=5.0, /overplot, $
            color=cgColor( 'Black' ) 
        cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
            color=cgColor( 'Black' ) 

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
        label = 'Blue:5.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Blue' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.055 ) 
        label = 'Green:8.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Green' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.090 ) 
        label = 'Orange:10.0 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Red' )
        xloc = ( position_3[0] + 0.01 )
        yloc = ( position_3[3] + 0.125 ) 
        label = 'Red:12.6 Gyr'
        cgText, xloc, yloc, label, /normal, alignment=0, charsize=2.5, $
            charthick=10.0, color=cgColor( 'Black' )
        ;; Metal 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.020 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=2, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[Z/H]=-0.71', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.055 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=0, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[Z/H]=+0.00', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 
        xloc = ( position_3[0] + 0.145 ) 
        yloc = ( position_3[3] + 0.090 ) 
        cgPlots, [ xloc, ( xloc + 0.05 ) ], $
            [ ( yloc + 0.005 ), ( yloc + 0.005 ) ], /normal, $
            linestyle=1, thick=8.0
        cgText, ( xloc + 0.055 ), yloc, '[Z/H]=+0.22', /normal, $ 
            charsize=2.5, alignment=0, charthick=10.0 

        device, /close 
        set_plot, mydevice 

    endfor

end

pro list_product_test 

    index_list = 'hs_index_new.lis'

    list1 = [ 'TiO2_EW' ]
    list2 = [ 'Lick_Hd_A' ]
    ;list2 = [ 'Lick_C4668', 'Lick_Ca4455' ]

    ;readcol, 'hs_index_interest.name', list2, format='A', delimiter=' ', /silent 
    ;list2 = strcompress( list2, /remove_all )

    n_list1 = n_elements( list1 ) 
    n_list2 = n_elements( list2 ) 

    for ii = 0, ( n_list1 - 1 ), 1 do begin 
        index1 = list1[ii] 

        for jj = 0, ( n_list2 - 1 ), 1 do begin 
            index2 = list2[jj] 
            
            fac1 = 1.0
            fac2 = 1.0 
            pow1 = 1.0 
            pow2 = 1.0

            ind_product_trend_mius, index1, index2, $
                fac1=fac1, fac2=fac2, pow1=pow1, pow2=pow2, $
                index_list=index_list, /save_results, $ 
                imf_type='un'

        endfor 
    endfor
            
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro product_test 

    index_list = 'hs_index_all.lis'
    index1 = 'Lick_Mgb'
    index2 = 'Lick_Fe5270'

    fac1 = 1.0
    fac2 = 1.0 
    pow1 = 1.0 
    pow2 = 1.0

    ind_product_trend_mius, index1, index2, $
        fac1=fac1, fac2=fac2, pow1=pow1, pow2=pow2, $
        index_list=index_list, /save_results

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro ind_product_trend_mius, index1, index2, $
    fac1=fac1, fac2=fac2, pow1=pow1, pow2=pow2, $
    index_list=index_list, index_title=index_title, $
    save_results=save_results, imf_type=imf_type 

    on_error, 2
    compile_opt idl2

    if N_params() lt 1 then begin 
        print,  'Syntax - ind_product_trend_mius, index1, index2' 
        return
    endif

    ;; Input index name 
    index1 = strcompress( index1, /remove_all )
    index2 = strcompress( index2, /remove_all )
    if ( index1 EQ index2 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' INDEX1 and INDEX2 can not be the same one !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 

    ;; 
    if keyword_set( fac1 ) then begin 
        fac1 = float( fac1 ) 
    endif else begin 
        fac1 = 1.0 
    endelse 
    if keyword_set( fac2 ) then begin 
        fac2 = float( fac2 ) 
    endif else begin 
        fac2 = 1.0 
    endelse 
    if keyword_set( pow1 ) then begin 
        pow1 = float( pow1 ) 
    endif else begin 
        pow1 = 1.0 
    endelse 
    if keyword_set( pow2 ) then begin 
        pow2 = float( pow2 ) 
    endif else begin 
        pow2 = 1.0 
    endelse 

    ;; Read the index list
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
    readcol, index_list, index_name, lam0, lam1, blue0, blue1, red0, red1, $
        type, format='A,F,F,F,F,F,F,I', comment='#', delimiter=' ', /silent 
    index_name = strcompress( index_name, /remove_all )
    n_index = n_elements( name )

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
    n_ssp = n_elements( ssp_index.age )
    if ( status NE 0 ) then begin 
        print, 'Something wrong with the file !'
        message, ' '
    endif 
    ;;;
    ssp_index.age   = float( ssp_index.age ) 
    ssp_index.slope = float( ssp_index.slope ) 
    ssp_index.metal = float( ssp_index.metal ) 

    ;; Check if the measurements exist 
    index1_pos = where( index_name EQ index1 ) 
    index2_pos = where( index_name EQ index2 ) 
    if ( n_elements( index1_pos ) GE 1 ) then begin 
        index1_pos = index1_pos[0] 
    endif 
    if ( n_elements( index2_pos ) GE 1 ) then begin 
        index2_pos = index2_pos[0] 
    endif 
    if ( index1_pos EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the measurements for index1 : ' + index1 + ' !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 
    if ( index2_pos EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the measurements for index2 : ' + index2 + ' !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 
        
    ;;; Prefix 
    prefix = 'mius'
    ;; Plot name 
    if keyword_set( index_title ) then begin 
        ratio_title = index_title 
        plot_file = prefix + '_' + ratio_title + '.eps'
        csv_file  = prefix + '_' + ratio_title + '.eps'
    endif else begin 
        ratio_title = index1 + ' * ' + index2
        plot_file = prefix + '_' + index1 + '-' + index2 + '_p.eps' 
        csv_file  = prefix + '_' + index1 + '-' + index2 + '_p.csv' 
    endelse

    ;;; Positions for index1 and index2 in the structure 
    tag_name = tag_names( ssp_index )
    index1_upp = strupcase( index1 ) 
    index2_upp = strupcase( index2 )
    index1_num = where( strcmp( tag_name, index1_upp ) EQ 1 ) 
    index2_num = where( strcmp( tag_name, index2_upp ) EQ 1 ) 
    if ( index1_num EQ -1 ) then begin 
        print, 'Something wrong with the index1 name ! '
        message, ' '
    endif 
    if ( index2_num EQ -1 ) then begin 
        print, 'Something wrong with the index2 name ! '
        message, ' '
    endif 

    print, '###############################################################'
    print, ' Plot the product between the  ' + index1 + ' and ' + index2 + ' !'
    print, '###############################################################'

    ;; set uo the figure 
    position_1 = [ 0.100, 0.15, 0.395, 0.800 ]
    position_2 = [ 0.395, 0.15, 0.690, 0.800 ]
    position_3 = [ 0.690, 0.15, 0.995, 0.800 ]
    psxsize = 46 
    psysize = 24 
    mydevice = !d.name 
    !p.font=1
    set_plot, 'ps' 
    device, filename=plot_file, font_size=9.0, /encapsulated, $
        /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    ;; Index range 
    index_use = where( ( ssp_index.age GE 2.99 ) AND $
        ( ssp_index.age LE 15.0 ) AND $ 
        ( ssp_index.metal GT -0.9 ) )
    if ( index_use[0] EQ -1 ) then begin 
        print, 'Something wrong with the index array ! '
        message, ' ' 
    endif 
    ;; Get the index ratio 
    index_ratio = $
        ( ( fac1 * ssp_index.(index1_num) )^pow1 * $
          ( fac2 * ssp_index.(index2_num) )^pow2 )   
    ;; Range of the index ratio 
    min_ratio = min( index_ratio[ index_use ] ) 
    max_ratio = max( index_ratio[ index_use ] )
    ratio_sep = ( ( max_ratio - min_ratio ) / 12.0 )
    ratio_range = [ ( min_ratio - ratio_sep ), ( max_ratio + ratio_sep ) ]

    ;; Save the results 
    if keyword_set( save_results ) then begin 
        openw, 10, csv_file, width=8000
        printf, 10, '#IMF_INDEX, AGE, MET , ' + ratio_title 
        for j = 0, ( n_ssp - 1 ), 1 do begin 
            result_line = string( ssp_index[j].imf_index ) + ' , ' + $
                          string( ssp_index[j].age       ) + ' , ' + $ 
                          string( ssp_index[j].metal     ) + ' , ' + $ 
                          string( index_ratio[j] ) 
            printf, 10, result_line 
        endfor 
        close, 10
    endif 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; First plot, trend with age 
    age_range = [ 3.0, 14.99 ] 
    cgPlot, ssp_index.age, $
        ( ssp_index.( index1_num ) / ssp_index.( index2_num ) ), $
        xstyle=1, ystyle=1, $
        xrange=age_range, yrange=ratio_range, position=position_1, $
        xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
        xtitle='Age (Gyr)', ytitle=ratio_title, /nodata, /noerase 
    ;; metal = -0.40
    ;; 2
    index_now = where( ( ssp_index.metal EQ -0.40 ) AND $
        ( ssp_index.slope EQ 1.30 ) )
    x_arr = ssp_index[ index_now ].age 
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    cgPlot, ssp_index.metal, $ 
        ( ssp_index.( index1_num ) / ssp_index.( index2_num ) ), $
        xstyle=1, ystyle=1, $ 
        xrange=met_range, yrange=ratio_range, position=position_2, $
        xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
        xtitle='[Z/H]', /nodata, /noerase, ytickformat='(A1)'
    ;; age = 5.0119 
    ;; 2
    index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
        ( ssp_index.slope EQ 1.30 ) )
    x_arr = ssp_index[ index_now ].metal 
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    cgPlot, ssp_index.slope, $ 
        ( ssp_index.( index1_num ) / ssp_index.( index2_num ) ), $
        xstyle=1, ystyle=1, $ 
        xrange=imf_range, yrange=ratio_range, position=position_3, $
        xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
        xtitle='IMF Slope', /nodata, /noerase, ytickformat='(A1)'
    ;; Age = 5.0119
    ;; 2 
    index_now = where( ( ssp_index.age EQ 5.0119 ) AND $
        ( ssp_index.metal EQ -0.40 ) )
    x_arr = ssp_index[ index_now ].slope 
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
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
    ;y_arr = ssp_index[ index_now ].( index_num )
    y_arr = index_ratio[ index_now ]
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=1, thick=5.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=2.0, /overplot, $
        color=cgColor( 'Black' ) 
    ;; Label
    ;; Age
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

end

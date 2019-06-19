pro sum_test 

    index_list = 'hs_index_all.lis'
    index1 = 'Lick_Hd_A'
    index2 = 'Lick_Hg_A'

    fac1 = 1.0
    fac2 = 1.0 
    pow1 = 1.0 
    pow2 = 1.0
    ;index_title = 'HdA+HgA'

    ind_sum_trend_cvd12, index1, index2, $
        fac1=fac1, fac2=fac2, pow1=pow1, pow2=pow2, $
        index_list=index_list, /save_results 
    ;index_title=index_title, /save_results

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro ind_sum_trend_cvd12, index1, index2, $
    fac1=fac1, fac2=fac2, pow1=pow1, pow2=pow2, $
    index_list=index_list, index_title=index_title, $
    save_results=save_results

    on_error, 2
    compile_opt idl2

    if N_params() lt 1 then begin 
        print,  'Syntax - ind_sum_trend_cvd12, index1, index2' 
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

    ;; Open the SSP models file 
    cvd_index_file = 'cvd12_' + index_str + '.fits'
    ssp_index = mrdfits( cvd_index_file, 1, /silent, status=status ) 
    n_ssp = n_elements( ssp_index.age )
    if ( status NE 0 ) then begin 
        print, 'Something wrong with the file !'
        message, ' '
    endif 

    ;; Check if the measurements exist 
    index1_pos = where( index_name EQ index1 ) 
    index2_pos = where( index_name EQ index2 ) 
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
    prefix = 'CvD12'
    ;; sum title 
    if keyword_set( index_title ) then begin 
        sum_title = index_title 
        plot_file = prefix + '_' + sum_title + '.eps'
        csv_file  = prefix + '_' + sum_title + '.eps'
    endif else begin 
        sum_title = index1 + ' + ' + index2
        plot_file = prefix + '_' + index1 + '-' + index2 + '_s.eps' 
        csv_file  = prefix + '_' + index1 + '-' + index2 + '_s.csv' 
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
    print, ' Plot the summation of the  ' + index1 + ' and ' + index2 + ' !'
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
        ( ssp_index.age LE 15.0 )  )
    if ( index_use[0] EQ -1 ) then begin 
        print, 'Something wrong with the index array ! '
        message, ' ' 
    endif 
    ;; Get the index sum 
    index_sum = $
        ( ( fac1 * ssp_index.(index1_num) )^pow1 + $
          ( fac2 * ssp_index.(index2_num) )^pow2 )   
    ;; Range of the index sum 
    min_sum = min( index_sum[ index_use ] ) 
    max_sum = max( index_sum[ index_use ] )
    sum_sep = ( ( max_sum - min_sum ) / 12.0 )
    sum_range = [ ( min_sum - sum_sep ), ( max_sum + sum_sep ) ]
    ;; Save the results 
    if keyword_set( save_results ) then begin 
        openw, 20, csv_file, width=8000
        printf, 20, '#IMF_INDEX, AGE, aFe , ' + sum_title 
        for j = 0, ( n_ssp - 1 ), 1 do begin 
            result_line = string( ssp_index[j].imf_index ) + ' , ' + $
                          string( ssp_index[j].age       ) + ' , ' + $ 
                          string( ssp_index[j].afe       ) + ' , ' + $ 
                          string( index_sum[j] ) 
            printf, 20, result_line 
        endfor 
        close, 20 
    endif 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; First plot, trend with age 
    age_range = [ 1.99, 13.99 ] 
    cgPlot, ssp_index.age, $
        ( ssp_index.( index1_num ) / ssp_index.( index2_num ) ), $
        xstyle=1, ystyle=1, $ 
        xrange=age_range, yrange=sum_range, position=position_1, $
        xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
        xtitle='Age (Gyr)', ytitle=sum_title, /nodata, /noerase 
    ;; afe=0.0
    ;; bottom-light
    index_now = where( ( ssp_index.afe EQ 0 ) AND $
        ( ssp_index.slope EQ 'btl' ) )
    x_arr = ssp_index[ index_now ].age 
    y_arr = index_sum[ index_now ] 
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Orange' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Orange' ) 
    ;; Chabrier
    index_now = where( ( ssp_index.afe EQ 0 ) AND $
        ( ssp_index.slope EQ 'cha' ) )
    x_arr = ssp_index[ index_now ].age 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Green' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Green' ) 
    ;; x23
    index_now = where( ( ssp_index.afe EQ 0 ) AND $
        ( ssp_index.slope EQ 'x23' ) )
    x_arr = ssp_index[ index_now ].age 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Black' ) 
    ;; x30
    index_now = where( ( ssp_index.afe EQ 0 ) AND $
        ( ssp_index.slope EQ 'x30' ) )
    x_arr = ssp_index[ index_now ].age 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Blue' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Blue' ) 
    ;; x35
    index_now = where( ( ssp_index.afe EQ 0 ) AND $
        ( ssp_index.slope EQ 'x35' ) )
    x_arr = ssp_index[ index_now ].age 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Red' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
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
    cgPlot, ssp_index.afe, $
        ( ssp_index.( index1_num ) / ssp_index.( index2_num ) ), $
        xstyle=1, ystyle=1, $ 
        xrange=met_range, yrange=sum_range, position=position_2, $
        xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
        xtitle='[Alpha/Fe]', /nodata, /noerase, ytickformat='(A1)'
    ;; Bottom-Light 
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.slope EQ 'btl' ) )
    x_arr = ssp_index[ index_now ].afe 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Orange' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Orange' ) 
    ;; Chabrier
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.slope EQ 'cha' ) )
    x_arr = ssp_index[ index_now ].afe 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Green' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Green' ) 
    ;; Slope=2.3
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.slope EQ 'x23' ) )
    x_arr = ssp_index[ index_now ].afe 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Black' ) 
    ;; Slope=3.0
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.slope EQ 'x30' ) )
    x_arr = ssp_index[ index_now ].afe 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Blue' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Blue' ) 
    ;; Slope=3.5
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.slope EQ 'x35' ) )
    x_arr = ssp_index[ index_now ].afe 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Red' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
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
    cgPlot, ssp_index.imf_index, $
        ( ssp_index.( index1_num ) / ssp_index.( index2_num ) ), $
        xstyle=1, ystyle=1, $ 
        xrange=imf_range, yrange=sum_range, position=position_3, $
        xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
        xtitle='IMF', /nodata, /noerase, ytickformat='(A1)'
    ;; Age = 13.00
    ;; aFe=0.00 
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.afe EQ 0 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Black' ) 
    ;; aFe=0.20 
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.afe EQ 2 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=2, thick=4.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Black' ) 
    ;; aFe=0.30 
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.afe EQ 3 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=3, thick=4.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Black' ) 
    ;; aFe=0.40 
    index_now = where( ( ssp_index.age EQ 13 ) AND $
        ( ssp_index.afe EQ 4 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=4, thick=4.0, /overplot, $
        color=cgColor( 'Black' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Black' ) 

    ;; Age = 3 Gyr
    index_now = where( ( ssp_index.age EQ 3 ) AND $
        ( ssp_index.afe EQ 0 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Blue' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Blue' ) 

    ;; Age = 5 Gyr
    index_now = where( ( ssp_index.age EQ 5 ) AND $
        ( ssp_index.afe EQ 0 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Green' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Green' ) 

    ;; Age = 7 Gyr
    index_now = where( ( ssp_index.age EQ 7 ) AND $
        ( ssp_index.afe EQ 0 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Orange' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Orange' ) 

    ;; Age = 9 Gyr
    index_now = where( ( ssp_index.age EQ 9 ) AND $
        ( ssp_index.afe EQ 0 ) )
    x_arr = ssp_index[ index_now ].imf_index 
    y_arr = index_sum[ index_now ] 
    ;y_arr = ( ssp_index[ index_now ].( index1_num ) / $
    ;    ssp_index[ index_now ].( index2_num ) )
    index_sort = sort( x_arr )
    x_arr = x_arr[ index_sort ]
    y_arr = y_arr[ index_sort ]
    cgPlot, x_arr, y_arr, linestyle=0, thick=3.0, /overplot, $
        color=cgColor( 'Red' ) 
    cgPlot, x_arr, y_arr, psym=16, symsize=1.5, /overplot, $
        color=cgColor( 'Red' ) 

    ;; Label
    ;; Age
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

end

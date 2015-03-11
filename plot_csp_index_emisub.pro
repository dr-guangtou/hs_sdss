;; + 
;; plot_csp_index_emisub
;; V0.11 SH 06/01/2014

pro plot_csp_index_emisub, index_list=index_list, normalize=normalize 

    on_error, 2
    compile_opt idl2
    
    time_arr = [ 11.2965 ,  11.4326 ,  $
                 11.5687 ,  11.7047 ,  11.8408 ,  11.9769 ,  12.1130 ,  $ 
                 12.2491 ,  12.3852 ,  12.5213 ,  12.6574 ,  12.7935 ,  $
                 12.9296 ,  13.0656 ,  13.2017 ,  13.3378 ,  13.4739 ]
    n_time = n_elements( time_arr )
    time_sta = [ 11.8000 ,  12.4400 ,  13.0650 ]  
    time_range = [ 11.10, 13.60 ]
    index_norm = 13
    ;; Combined time array 
    time_comb = [ time_arr, time_sta ]
    time_sort = sort( time_comb ) 
    time_comb = time_comb[ time_sort ]

    ;;
    group_local = 'f'
    group_highz = 'd'

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = 'hs_index_interest.lis'
    endelse
    index_select = hs_read_indexlist( index_list, n_index=n_index )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_file = 'sdss_emisub_index.fits'
    ;;
    if NOT file_test( index_file ) then begin 
        message, 'Can not find the index file: ' + index_file + ' !!' 
    endif else begin 
        stack_index = mrdfits( index_file, 1, /silent, status=status ) 
        if ( status NE 0 ) then begin 
            print, 'Something wrong with the file !'
            message, ' '
        endif 
    endelse 
    tag_name = tag_names( stack_index )
    stack_index.group  = strcompress( stack_index.group,  /remove_all ) 
    stack_index.method = strcompress( stack_index.method, /remove_all ) 
    stack_index.imf    = strcompress( stack_index.imf,    /remove_all ) 
    index_z0 = where( stack_index.redshift LT 0.06 ) 
    index_z1 = where( ( stack_index.redshift LT 0.11 ) AND $
        ( stack_index.redshift GT 0.08 ) ) 
    index_z2 = where( stack_index.redshift GT 0.12 ) 
    stack_index[ index_z0 ].redshift = time_sta[2]
    stack_index[ index_z1 ].redshift = time_sta[1]
    stack_index[ index_z2 ].redshift = time_sta[0]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;for i = 0, ( n_index - 1 ), 1 do begin 
    ;;; For test
    for i = 0, 1, 1 do begin 

        index_name = strcompress( index_select[i].name, /remove_all ) 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' INDEX NAME : ' + index_name 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        temp  = strsplit( index_name, '_ ', /extrac ) 
        n_seg = n_elements( temp ) 
        show_name = str_replace( index_name, '_', '-' )

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; find the relevant tag in the structure 
        index_upp = strupcase( index_name )
        error_upp = index_upp + '_ERR'
        index_num = where( strcmp( tag_name, index_upp ) EQ 1 ) 
        if ( index_num EQ -1 ) then begin 
            print, 'Something wrong with the index name ! '
            message, ' '
        endif 
        error_num = where( strcmp( tag_name, error_upp ) EQ 1 ) 
        if ( error_num EQ -1 ) then begin 
            print, 'Something wrong with the error name ! '
            message, ' '
        endif 

        ;; Index range
        index_s8 = where( $
            ( stack_index.sigma    EQ 310.0 ) AND $
            ( stack_index.group    EQ group_highz ) AND $ 
            ( stack_index.redshift NE time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s8 ) NE 2 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_s7 = where( $
            ( stack_index.sigma    EQ 280.0 ) AND $
            ( stack_index.group    EQ group_highz ) AND $ 
            ( stack_index.redshift NE time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s7 ) NE 2 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_s6 = where( $
            ( stack_index.sigma    EQ 260.0 ) AND $
            ( stack_index.group    EQ group_highz ) AND $ 
            ( stack_index.redshift NE time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s6 ) NE 2 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_s5 = where( $
            ( stack_index.sigma    EQ 240.0 ) AND $
            ( stack_index.group    EQ group_highz ) AND $ 
            ( stack_index.redshift NE time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s5 ) NE 2 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif
        ;; Index range 
        index_s8b = where( $
            ( stack_index.sigma    EQ 310.0 ) AND $
            ( stack_index.group    EQ group_local ) AND $ 
            ( stack_index.redshift EQ time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s8b ) NE 1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_s7b = where( $
            ( stack_index.sigma    EQ 280.0 ) AND $
            ( stack_index.group    EQ group_local ) AND $ 
            ( stack_index.redshift EQ time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s7b ) NE 1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_s6b = where( $
            ( stack_index.sigma    EQ 260.0 ) AND $
            ( stack_index.group    EQ group_local ) AND $ 
            ( stack_index.redshift EQ time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s6b ) NE 1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_s5b = where( $
            ( stack_index.sigma    EQ 240.0 ) AND $
            ( stack_index.group    EQ group_local ) AND $ 
            ( stack_index.redshift EQ time_sta[2] ) AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( n_elements( index_s5b ) NE 1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif
        ;;;; 
        index_use2 = [ index_s5, index_s6, index_s7, index_s8, $
            index_s5b, index_s6b, index_s7b, index_s8b ]
        min_stack = min( stack_index[ index_use2 ].( index_num ) ) 
        max_stack = max( stack_index[ index_use2 ].( index_num ) )

        ;; For normalization 
        index_ref = where( $
            ( stack_index.sigma    EQ 310.0 ) AND $
            ( stack_index.group    EQ group_local )  AND $ 
            ( stack_index.redshift EQ time_sta[2] )  AND $ 
            ( stack_index.imf      EQ 'unmix' ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        value_ref = stack_index[ index_ref ].( index_num ) 

        ;; Lists 
        list_use = 'sfh_use.lis'
        readcol, list_use, sfh_str, format='A', delimiter=' ', /silent 
        n_sfh = n_elements( sfh_str )
        sfh_str = strcompress( sfh_str, /remove_all )
        sfh_str = sfh_str + '_n100_index.fits'

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; UN1.30 Zm04 
        prefix_csp1 = 'mius_un13z5_'
        fits_csp1   = prefix_csp1 + sfh_str 
        index_csp1  = fltarr( n_time, n_sfh )  
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            index_csp1[*,j] = csp_index_evolution( $
                strcompress( fits_csp1[j], /remove_all ), index_name ) 
            if keyword_set( normalize ) then begin 
                index_csp1[*,j] = ( index_csp1[*,j] - $
                    index_csp1[ index_norm, j ] ) + value_ref 
            endif 
        endfor 
        min_csp1 = min( index_csp1 ) 
        max_csp1 = max( index_csp1 )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; UN1.30 Zp00 
        prefix_csp2 = 'mius_un13z6_'
        fits_csp2   = prefix_csp2 + sfh_str 
        index_csp2  = fltarr( n_time, n_sfh )  
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            index_csp2[*,j] = csp_index_evolution( $
                strcompress( fits_csp2[j], /remove_all ), index_name ) 
            if keyword_set( normalize ) then begin 
                index_csp2[*,j] = ( index_csp2[*,j] - $
                    index_csp2[ index_norm, j ] ) + value_ref 
            endif 
        endfor 
        min_csp2 = min( index_csp2 ) 
        max_csp2 = max( index_csp2 )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; UN1.30 Zp02 
        prefix_csp3 = 'mius_un13z7_'
        fits_csp3   = prefix_csp3 + sfh_str 
        index_csp3  = fltarr( n_time, n_sfh )  
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            index_csp3[*,j] = csp_index_evolution( $
                strcompress( fits_csp3[j], /remove_all ), index_name ) 
            if keyword_set( normalize ) then begin 
                index_csp3[*,j] = ( index_csp3[*,j] - $
                    index_csp3[ index_norm, j ] ) + value_ref 
            endif 
        endfor 
        min_csp3 = min( index_csp3 ) 
        max_csp3 = max( index_csp3 )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; UN1.80 Zm04 
        prefix_csp4 = 'mius_un18z5_'
        fits_csp4   = prefix_csp4 + sfh_str 
        index_csp4  = fltarr( n_time, n_sfh )  
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            index_csp4[*,j] = csp_index_evolution( $
                strcompress( fits_csp4[j], /remove_all ), index_name ) 
            if keyword_set( normalize ) then begin 
                index_csp4[*,j] = ( index_csp4[*,j] - $
                    index_csp4[ index_norm, j ] ) + value_ref 
            endif
        endfor 
        min_csp4 = min( index_csp4 ) 
        max_csp4 = max( index_csp4 )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; UN1.80 Zp00           
        prefix_csp5 = 'mius_un18z6_'
        fits_csp5   = prefix_csp5 + sfh_str 
        index_csp5  = fltarr( n_time, n_sfh )  
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            index_csp5[*,j] = csp_index_evolution( $
                strcompress( fits_csp5[j], /remove_all ), index_name ) 
            if keyword_set( normalize ) then begin 
                index_csp5[*,j] = ( index_csp5[*,j] - $
                    index_csp5[ index_norm, j ] ) + value_ref 
            endif 
        endfor 
        min_csp5 = min( index_csp5 ) 
        max_csp5 = max( index_csp5 )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; UN1.80 Zp02 
        prefix_csp6 = 'mius_un18z7_'
        fits_csp6   = prefix_csp6 + sfh_str 
        index_csp6  = fltarr( n_time, n_sfh )  
        for j = 0, ( n_sfh - 1 ), 1 do begin 
            index_csp6[*,j] = csp_index_evolution( $
                strcompress( fits_csp6[j], /remove_all ), index_name ) 
            if keyword_set( normalize ) then begin 
                index_csp6[*,j] = ( index_csp6[*,j] - $
                    index_csp6[ index_norm, j ] ) + value_ref 
            endif 
        endfor 
        min_csp6 = min( index_csp6 ) 
        max_csp6 = max( index_csp6 )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;; 
        if keyword_set( normalize ) then begin 
            min_index = min_stack 
            max_index = max_stack 
            index_sep   = ( ( max_index - min_index ) / 8.0 )
            index_range = [ ( min_index - index_sep / 2.0 ), $
                ( max_index + index_sep ) ]
        endif else begin 
            min_index = min( [ min_csp2, min_csp3, min_csp5, min_csp6, $
                min_stack ] ) 
            max_index = max( [ max_csp2, max_csp3, max_csp5, max_csp6, $
                max_stack ] ) 
            index_sep = ( ( max_index - min_index ) / 8.0 )
            index_range = [ ( min_index - index_sep / 2.0 ), $
                ( max_index + index_sep ) ]
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; plot name 
        if keyword_set( normalize ) then begin 
            plot_file = 'csp_index_' + index_name + '_norm_emisub.eps' 
        endif else begin 
            plot_file = 'csp_index_' + index_name + '_emisub.eps' 
        endelse

        ;; set up the figure 
        position_1 = [ 0.14, 0.15, 0.97, 0.98 ]
        psxsize = 28 
        psysize = 28 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_s8 ].redshift, $
            stack_index[ index_s8 ].( index_num ), $
            xstyle=1, ystyle=1, xrange=time_range, yrange=index_range, $
            position=position_1, xthick=14.0, ythick=14.0, $
            charsize=5.0, charthick=12.0, $ 
            xtitle='Age of Universe', $
            /nodata, /noerase 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for k = 0, ( n_sfh - 1 ), 1 do begin 
            cgPlot, time_arr, index_csp2[*,k], /overplot, $ 
                linestyle=0, thick=2.0, color=cgColor( 'BLU3' )
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for k = 0, ( n_sfh - 1 ), 1 do begin 
            cgPlot, time_arr, index_csp3[*,k], /overplot, $ 
                linestyle=5, thick=2.0, color=cgColor( 'BLU3' )
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for k = 0, ( n_sfh - 1 ), 1 do begin 
            cgPlot, time_arr, index_csp5[*,k], /overplot, $ 
                linestyle=0, thick=2.0, color=cgColor( 'RED3' )
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for k = 0, ( n_sfh - 1 ), 1 do begin 
            cgPlot, time_arr, index_csp6[*,k], /overplot, $ 
                linestyle=5, thick=2.0, color=cgColor( 'RED3' )
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_s5 ].redshift, $
            stack_index[ index_s5 ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Blue' )
        cgPlot, stack_index[ index_s5 ].redshift, $
            stack_index[ index_s5 ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        cgPlot, stack_index[ index_s5b ].redshift, $
            stack_index[ index_s5b ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Blue' )
        cgPlot, stack_index[ index_s5b ].redshift, $
            stack_index[ index_s5b ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_s6 ].redshift, $
            stack_index[ index_s6 ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Orange' )
        cgPlot, stack_index[ index_s6 ].redshift, $
            stack_index[ index_s6 ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        cgPlot, stack_index[ index_s6b ].redshift, $
            stack_index[ index_s6b ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Orange' )
        cgPlot, stack_index[ index_s6b ].redshift, $
            stack_index[ index_s6b ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_s7 ].redshift, $
            stack_index[ index_s7 ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Dark Green' )
        cgPlot, stack_index[ index_s7 ].redshift, $
            stack_index[ index_s7 ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        cgPlot, stack_index[ index_s7b ].redshift, $
            stack_index[ index_s7b ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Dark Green' )
        cgPlot, stack_index[ index_s7b ].redshift, $
            stack_index[ index_s7b ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_s8 ].redshift, $
            stack_index[ index_s8 ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Red' )
        cgPlot, stack_index[ index_s8 ].redshift, $
            stack_index[ index_s8 ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        cgPlot, stack_index[ index_s8b ].redshift, $
            stack_index[ index_s8b ].( index_num ), /overplot, $
            psym=16,  symsize=2.5, thick=7.0, color=cgColor( 'Red' )
        cgPlot, stack_index[ index_s8b ].redshift, $
            stack_index[ index_s8b ].( index_num ), /overplot, $
            psym=9,  symsize=2.7, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_s8 ].redshift, $
            stack_index[ index_s8 ].( index_num ), $
            xstyle=1, ystyle=1, xrange=time_range, yrange=index_range, $
            position=position_1, xthick=14.0, ythick=14.0, $
            charsize=5.0, charthick=12.0, $ 
            xtitle='Age of Universe', $
            /nodata, /noerase 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgText, 0.21, 0.90, show_name, charsize=6.0, charthick=10.0, $
            color=cgColor( 'Black' ), /norm
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, /close 
        set_plot, mydevice 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor

end 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function csp_index_evolution, csp_file, index_name, $
    index_name2=index_name2, method=method 

    on_error, 2
    compile_opt idl2
    
    if N_params() lt 2  then begin 
        message,  'Syntax - structure=csp_index_evolution, csp_file, index_name ' 
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_name = strupcase( strcompress( index_name, /remove_all ) )

    if NOT file_test( csp_file ) then begin 
        message, 'Can not find the CSP_INDEX file !!!!'
    endif else begin 
        ;;
        fits_open, csp_file, temp_index
        n_time = temp_index.nextend 
        ;;
        temp_index = mrdfits( csp_file, 1, /silent ) 
        free_all
        ;;
        list_name = strupcase( strcompress( temp_index.name, /remove_all ) ) 
        index_find = where( list_name EQ index_name ) 
        if ( index_find[0] EQ -1 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, 'Can not find the index : ' + index_name 
        endif else begin 
            if ( n_elements( index_find ) GT 1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, 'WARNING : Multiple index definitions for : ' + $
                    index_name + ' !!!!!!!!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            endif 
            index_use = index_find[0] 
        endelse
    endelse

    ;; structure 
    time_evol = fltarr( n_time ) 

    ;; 
    for i = 0, ( n_time - 1 ), 1 do begin 

        n_ext = ( i + 1 ) 

        index_struc = mrdfits( csp_file, n_ext, /silent ) 
        time_evol[ i ] = index_struc[ index_use ].value 

    endfor 

    ;;
    return, time_evol

end

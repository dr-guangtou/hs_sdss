pro plot_sigma_index, index_list=index_list

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_file = 'sdss_stack_index.fits'
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
    stack_index.group  = strcompress( stack_index.group, /remove_all ) 
    stack_index.method = strcompress( stack_index.method, /remove_all ) 
    stack_index.sigstr = strcompress( stack_index.sigstr, /remove_all ) 
    ;; 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = 'hs_index_stack_old.lis'
    endelse
    ;; read the index 
    readcol, index_list, name, lam0, lam1, blue0, blue1, red0, red1, type, $
        format='A,F,F,F,F,F,F,I', comment='#', delimiter=' ', /silent 
    n_index = n_elements( name )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for i = 0, ( n_index - 1 ), 1 do begin 
    ;for i = 0, 0, 1 do begin 

        ;;
        index_name = strcompress( name[i], /remove_all ) 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' INDEX NAME : ' + index_name 
        ;; 
        temp = strsplit( index_name, '_ ', /extrac ) 
        n_seg = n_elements( temp ) 
        ;show_name = temp[ n_seg - 1 ]
        show_name = str_replace( index_name, '_', '-' )

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
        index_z0c = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'c'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0c[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0d = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'd'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0d[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0e = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'e'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0e[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0f = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'f'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0f[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0g = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'g'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0g[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0h = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'h'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0h[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0i = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'i'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0i[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0j = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'j'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0j[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0k = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'k'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0k[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z0l = where( $
            ( stack_index.redshift GT 0.03 ) AND $
            ( stack_index.redshift LT 0.05 ) AND $
            ( stack_index.group    EQ 'l'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z0l[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z1c = where( $
            ( stack_index.redshift GT 0.08 ) AND $
            ( stack_index.redshift LT 0.10 ) AND $
            ( stack_index.group    EQ 'c'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z1c[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z1d = where( $
            ( stack_index.redshift GT 0.08 ) AND $
            ( stack_index.redshift LT 0.10 ) AND $
            ( stack_index.group    EQ 'd'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z1d[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z2c = where( $
            ( stack_index.redshift GT 0.12 ) AND $
            ( stack_index.redshift LT 0.20 ) AND $
            ( stack_index.group    EQ 'c'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z2c[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 
        index_z2d = where( $
            ( stack_index.redshift GT 0.12 ) AND $
            ( stack_index.redshift LT 0.20 ) AND $
            ( stack_index.group    EQ 'd'  ) AND $ 
            ( stack_index.method   EQ 'avg' ) )
        if ( index_z2d[0] EQ -1 ) then begin 
            print, 'Something wrong with the index array ! '
            message, ' ' 
        endif 

        ;; min and max index range 
        min_index = min( stack_index.( index_num ) ) 
        max_index = max( stack_index.( index_num ) )
        index_sep = ( ( max_index - min_index ) / 18.0 )
        index_range = [ ( min_index - index_sep ), ( max_index + index_sep ) ]
        ;; min and max sigma range 
        sigma_range = [ 135.0, 330.0 ]
        print, ' Min INDEX : ' + string( min_index )
        print, ' Max INDEX : ' + string( max_index )

        ;; plot name 
        plot_file = 'stack_sigma_' + index_name + '.eps' 

        ;; set up the figure 
        position_1 = [ 0.17, 0.14, 0.992, 0.992 ]
        psxsize = 30 
        psysize = 30 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z0d ].sigma, $
            stack_index[ index_z0d ].( index_num ), $
            xstyle=1, ystyle=1, xrange=sigma_range, yrange=index_range, $
            position=position_1, xthick=14.0, ythick=14.0, $
            charsize=5.0, charthick=12.0, $ 
            xtitle='Velocity Dispersion (km/s)', $
            /nodata, /noerase 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z0c ].sigma, $
            stack_index[ index_z0c ].( index_num ), /overplot, $
            psym=9,  symsize=4.0, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z0k ].sigma, $
            stack_index[ index_z0k ].( index_num ), /overplot,  $
            psym=15, symsize=3.0, thick=5.0, color=cgColor( 'BLK4' )
        cgPlot, stack_index[ index_z0k ].sigma, $
            stack_index[ index_z0k ].( index_num ), /overplot, $
            psym=6,  symsize=3.1, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z0d ].sigma, $
            stack_index[ index_z0d ].( index_num ), /overplot,  $
            psym=16, symsize=4.0, thick=5.0, color=cgColor( 'BLK5' )
        cgPlot, stack_index[ index_z0d ].sigma, $
            stack_index[ index_z0d ].( index_num ), /overplot, $
            psym=9,  symsize=4.1, thick=9.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z0e ].sigma, $
            stack_index[ index_z0e ].( index_num ), /overplot,  $
            psym=16, symsize=3.0, thick=5.0, color=cgColor( 'Orange' )
        cgPlot, stack_index[ index_z0e ].sigma, $
            stack_index[ index_z0e ].( index_num ), /overplot, $
            psym=9,  symsize=3.1, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z0g ].sigma, $
            stack_index[ index_z0g ].( index_num ), /overplot,  $
            psym=16, symsize=3.0, thick=5.0, color=cgColor( 'Lime Green' )
        cgPlot, stack_index[ index_z0g ].sigma, $
            stack_index[ index_z0g ].( index_num ), /overplot, $
            psym=9,  symsize=3.1, thick=7.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z1d ].sigma, $
            stack_index[ index_z1c ].( index_num ), /overplot, $
            psym=15, symsize=3.0, thick=5.0, color=cgColor( 'RED3' )
        cgPlot, stack_index[ index_z1d ].sigma, $
            stack_index[ index_z1c ].( index_num ), /overplot, $
            psym=6,  symsize=3.1, thick=8.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z1d ].sigma, $
            stack_index[ index_z1d ].( index_num ), /overplot, $
            psym=16, symsize=4.0, thick=5.0, color=cgColor( 'RED5' )
        cgPlot, stack_index[ index_z1d ].sigma, $
            stack_index[ index_z1d ].( index_num ), /overplot, $
            psym=9,  symsize=4.1, thick=8.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z2d ].sigma, $
            stack_index[ index_z2c ].( index_num ), /overplot, $
            psym=15, symsize=3.0, thick=5.0, color=cgColor( 'BLU4' )
        cgPlot, stack_index[ index_z2d ].sigma, $
            stack_index[ index_z2c ].( index_num ), /overplot, $
            psym=6,  symsize=3.1, thick=8.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        xx = stack_index[ index_z2d[0] ].sigma
        yy = stack_index[ index_z2d[0] ].( index_num )
        yerr = stack_index[ index_z2d[0] ].( error_num )
        cgErrPlot, xx, ( yy + yerr ), ( yy - yerr ), color=cgColor( 'Black' ), $
            thick=7.0, width=0.03
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, stack_index[ index_z2d ].sigma, $
            stack_index[ index_z2d ].( index_num ), /overplot, $
            psym=16, symsize=4.0, thick=5.0, color=cgColor( 'BLU6' )
        cgPlot, stack_index[ index_z2d ].sigma, $
            stack_index[ index_z2d ].( index_num ), /overplot, $
            psym=9,  symsize=4.1, thick=8.0, color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        xx = stack_index[ index_z2d[0] ].sigma
        yy = stack_index[ index_z2d[0] ].( index_num )
        yerr = stack_index[ index_z2d[0] ].( error_num )
        cgErrPlot, xx, ( yy + yerr ), ( yy - yerr ), color=cgColor( 'Black' ), $
            thick=10.0, width=0.03
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        index_0 = stack_index[ index_z0c[0] ].( index_num )
        index_1 = stack_index[ index_z0c[ n_elements( index_z0c ) - 1 $
            ] ].( index_num )
        if ( index_0 LT index_1 ) then begin 
            ;; 
            cgText, 0.24, 0.89, show_name, charsize=9.0, charthick=14.0, $
                alignment=0, /normal
            ;;
            if keyword_set( caption ) then begin 
                cgPlots, 0.20, 0.94, psym=16, symsize=3.8, thick=8.0, $
                    color=cgColor( 'BLK6' ), /normal 
                cgPlots, 0.20, 0.94, psym=9,  symsize=3.9, thick=8.0, $
                    color=cgColor( 'Black' ), /normal 
                cgText, 0.21, 0.932, 'z=[0.02,0.07]', /normal, charsize=4.0, $
                    charthick=10.0
            endif 
        endif else begin 
            ;; 
            cgText, 0.24, 0.23, show_name, charsize=9.0, charthick=14.0, $
                alignment=0, /normal
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, /close 
        set_plot, mydevice 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

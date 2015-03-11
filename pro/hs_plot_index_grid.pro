pro hs_plot_index_grid, index_file, index_1, index_2, $
    para_fix, value_fix, afe_fix=afe_fix, $
    para_1=para_1, para_2=para_2, $
    min_1=min_1, max_1=max_1, min_2=min_2, max_2=max_2, $
    line_thick=line_thick, line_color=line_color, line_style=line_style, $
    debug=debug, overplot=overplot

    ;; Check the index_file 
    index_file = strcompress( index_file, /remove_all ) 
    if NOT file_test( index_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the index_file : ' + index_file + ' !!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        index_struc = mrdfits( index_file, 1, header, status=status, /silent ) 
        if ( status NE 0 ) then begin  
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the index_file !! Check !! ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, '' 
        endif 
        ;; If slope information exist  
        if ( tag_indx( index_struc, 'slope' ) NE -1 ) then begin 
            imf_exist = 1 
        endif 
        ;; if age information exist
        if ( tag_indx( index_struc, 'age' ) NE -1 ) then begin 
            age_exist = 1 
        endif 
        ;; if metal information exist
        if ( tag_indx( index_struc, 'metal' ) NE -1 ) then begin 
            met_exist = 1 
        endif 
        ;; if alpha-elements ratio information exist
        if ( tag_indx( index_struc, 'afe' ) NE -1 ) then begin 
            afe_exist = 1 
            if keyword_set( afe_fix ) then begin 
                afe_fix = float( afe_fix )
            endif else begin 
                afe_fix = 0.0 
            endelse
            tag_afe  = tag_indx( index_struc, 'afe' ) 
            parr_afe = index_struc.( tag_afe ) 
            uniq_afe = parr_afe[ uniq( parr_afe, sort( parr_afe ) ) ]
            index_afe = where( float( uniq_afe ) EQ float( afe_fix ), n_afe )
            if ( n_afe EQ 0 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The alpha/Fe value is incompatible !! Check!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif 
        endif else begin 
            afe_exist = 0 
        endelse
    endelse

    ;; Parameters for the plot 
    if keyword_set( line_style ) then begin 
        line_style = fix( line_style ) 
    endif else begin 
        line_style = 0 
    endelse
    if keyword_set( line_thick ) then begin 
        line_thick = float( line_thick ) 
    endif else begin 
        line_thick = 2.5
    endelse
    if keyword_set( line_color ) then begin 
        line_color = string( line_color ) 
    endif else begin 
        line_color = 'Red' 
    endelse

    ;; Change everything into tag number 
    index_1 = strcompress( index_1, /remove_all )
    index_2 = strcompress( index_2, /remove_all )
    ;; Tag number for the first index 
    tag_1 = tag_indx( index_struc, index_1 ) 
    if ( tag_1 EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Index: ' + index_1 + ' is not in the structure !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        ;; iarr: index array
        iarr_1 = index_struc.( tag_1 ) 
    endelse
    ;; Tag number for the second index 
    tag_2 = tag_indx( index_struc, index_2 ) 
    if ( tag_2 EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Index: ' + index_2 + ' is not in the structure !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin   
        ;; iarr: index array
        iarr_2 = index_struc.( tag_2 ) 
    endelse

    ;; Check the fixed parameter 
    para_fix = strcompress( para_fix, /remove_all ) 
    tag_fix = tag_indx( index_struc, para_fix ) 
    if ( tag_fix EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Parameter: ' + para_fix + ' is not in the structure !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        ;; parr: parameter array
        parr_fix = index_struc.( tag_fix ) 
        uniq_fix = parr_fix[ uniq( parr_fix, sort( parr_fix ) ) ]
        index_fix = where( float( uniq_fix ) EQ float( value_fix ), n_fix )
        if ( n_fix EQ 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The value of fixed parameter is incompatible !! Check!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif 
    endelse

    ;; Check the parameters for plot 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; First parameter
    if keyword_set( para_1 ) then begin 
        para_1 = strcompress( para_1, /remove_all )
    endif else begin 
        para_1 = 'age' 
    endelse
    ;; Tag for the first parameter
    tag_para1 = tag_indx( index_struc, para_1 ) 
    if ( tag_para1 EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Parameter: ' + para_para1 + ' is not in the structure !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        parr_1 = index_struc.( tag_para1 ) 
        uniq_para1 = parr_1[ uniq( parr_1, sort( parr_1 ) ) ] 
        if ( para_1 EQ para_fix ) then begin 
            num_para1 = 1 
            val_para1 = value_fix 
            min_para1 = value_fix 
            max_para1 = value_fix 
        endif else begin 
            ;; The plotting range for parameter 1 
            if keyword_set( min_1 ) then begin 
                min_para1 = float( min_1 ) 
            endif else begin 
                min_para1 = min( uniq_para1 ) 
            endelse
            if keyword_set( max_1 ) then begin 
                max_para1 = float( max_1 ) 
            endif else begin 
                max_para1 = max( uniq_para1 ) 
            endelse
            index_use_para1 = where( ( uniq_para1 GE min_para1 ) AND $
                ( uniq_para1 LE max_para1 ), num_para1 ) 
            if ( num_para1 EQ 0 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Bad choice of plotting range for PARA_1 !! Check !! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else begin 
                val_para1 = uniq_para1[ index_use_para1 ]
            endelse 
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Second parameter
    if keyword_set( para_2 ) then begin 
        para_2 = strcompress( para_2, /remove_all )
    endif else begin 
        para_2 = 'metal' 
    endelse
    ;; Tag for the first parameter
    tag_para2 = tag_indx( index_struc, para_2 ) 
    if ( tag_para2 EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Parameter: ' + para_para2 + ' is not in the structure !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        parr_2 = index_struc.( tag_para2 ) 
        uniq_para2 = parr_2[ uniq( parr_2, sort( parr_2 ) ) ] 
        if ( para_2 EQ para_fix ) then begin 
            num_para2 = 1 
            val_para2 = value_fix 
            min_para2 = value_fix 
            max_para2 = value_fix 
        endif else begin 
            ;; The plotting range for parameter 1 
            if keyword_set( min_2 ) then begin 
                min_para2 = float( min_2 ) 
            endif else begin 
                min_para2 = min( uniq_para2 ) 
            endelse
            if keyword_set( max_2 ) then begin 
                max_para2 = float( max_2 ) 
            endif else begin 
                max_para2 = max( uniq_para2 ) 
            endelse
            index_use_para2 = where( ( uniq_para2 GE min_para2 ) AND $
                ( uniq_para2 LE max_para2 ), num_para2 ) 
            if ( num_para2 EQ 0 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Bad choice of plotting range for PARA_1 !! Check !! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else begin 
                val_para2 = uniq_para2[ index_use_para2 ]
            endelse 
        endelse
    endelse

    ;; Isolate the useful part of structure 
    if ( afe_exist EQ 0 ) then begin 
        index_use = where( $
            ( float( index_struc.(tag_fix) ) EQ float( value_fix ) ) AND $ 
            ( index_struc.( tag_para1 ) GE min_para1 ) AND $
            ( index_struc.( tag_para1 ) LE max_para1 ) AND $
            ( index_struc.( tag_para2 ) GE min_para2 ) AND $
            ( index_struc.( tag_para2 ) LE max_para2 ), n_use )
    endif else begin 
        index_use = where( $
            ( float( index_struc.(tag_fix) ) EQ float( value_fix ) ) AND $ 
            ( float( index_struc.(tag_afe) ) EQ float( afe_fix ) )   AND $ 
            ( index_struc.( tag_para1 ) GE min_para1 ) AND $
            ( index_struc.( tag_para1 ) LE max_para1 ) AND $
            ( index_struc.( tag_para2 ) GE min_para2 ) AND $
            ( index_struc.( tag_para2 ) LE max_para2 ), n_use )
    endelse
    if ( n_use EQ 0 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, 'Something wrong with the parameter range !! ' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif 

    if keyword_set( debug ) then begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' N_USE   : ', n_use 
        print, ' PARA_FIX: ', para_fix, value_fix
        print, ' PARA_1  : ', para_1, num_para1, min_para1, max_para1
        print, ' PARA_2  : ', para_2, num_para2, min_para2, max_para2
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif

    ;; Define the plotting range 
    min_index1 = min( ( index_struc.( tag_1 ) )[ index_use ] )
    max_index1 = max( ( index_struc.( tag_1 ) )[ index_use ] )
    min_index2 = min( ( index_struc.( tag_2 ) )[ index_use ] )
    max_index2 = max( ( index_struc.( tag_2 ) )[ index_use ] )
    ;; Separation 
    sep_index1 = ( max_index1 - min_index1 )
    sep_index2 = ( max_index2 - min_index2 )
    ;; Plotting range 
    index1_range = [ ( min_index1 - sep_index1 / 8.0 ), $
                     ( max_index1 + sep_index1 / 8.0 ) ]
    index2_range = [ ( min_index2 - sep_index2 / 8.0 ), $
                     ( max_index2 + sep_index2 / 8.0 ) ]

    ;; Start the plot
    if NOT keyword_set( overplot ) then begin 
        cgPlot, iarr_1, iarr_2, psym=0, /nodata, /noerase, $ 
            xrange=index1_range, yrange=index2_range, xthick=8.0, ythick=8.0
    endif 

    ;; First direction 
    for ii = 0, ( num_para1 - 1 ), 1 do begin 
        use_para1 = val_para1[ii] 
        for jj = 0, ( num_para2 - 2 ), 1 do begin 
            use_para2_a = val_para2[jj]
            use_para2_b = val_para2[jj+1]
            ;; Find the index1/2 value for this SSP 
            if ( afe_exist EQ 1 ) then begin 
                index_plot_a = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_afe)) EQ float( afe_fix ) )   AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1 ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2_a ) ), $
                    n_plot_a ) 
                index_plot_b = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_afe)) EQ float( afe_fix ) )   AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1 ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2_b ) ), $
                    n_plot_b ) 
            endif else begin 
                index_plot_a = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1 ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2_a ) ), $
                    n_plot_a ) 
                index_plot_b = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1 ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2_b ) ), $
                    n_plot_b ) 
            endelse
            if keyword_set( debug ) then begin 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                print, ' USE_PARA1  : ', use_para1 
                print, ' USE_PARA2_A: ', use_para2_a
                print, ' USE_PARA2_B: ', use_para2_b
                print, ' N_PLOT_A   : ', n_plot_a
                print, ' N_PLOT_B   : ', n_plot_b
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            endif
            if ( ( n_plot_a EQ 0 ) OR ( n_plot_b EQ 0 ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the index value at this position !'
                print, ' PARA1: ', use_para1
                print, ' PARA2: ', use_para2_a, use_para2_b
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else if ( ( n_plot_a GT 1 ) OR ( n_plot_b GT 1 ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Multiple values with the index at this position ! '
                print, '   Need to constrain other parameters ! '
                print, ' PARA1: ', use_para1
                print, ' PARA2: ', use_para2_a, use_para2_b
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else begin 
                val_index1_a = ( index_struc.( tag_1 ) )[ index_plot_a ]
                val_index2_a = ( index_struc.( tag_2 ) )[ index_plot_a ]
                val_index1_b = ( index_struc.( tag_1 ) )[ index_plot_b ]
                val_index2_b = ( index_struc.( tag_2 ) )[ index_plot_b ]
            endelse
            cgPlot, [val_index1_a, val_index1_b], $
                    [val_index2_a, val_index2_b], /overplot, $
                    linestyle=line_style, thick=line_thick, $
                     color=cgColor( line_color )
        endfor
    endfor

    ;; Second direction 
    for ii = 0, ( num_para2 - 1 ), 1 do begin 
        use_para2 = val_para2[ii] 
        for jj = 0, ( num_para1 - 2 ), 1 do begin 
            use_para1_a = val_para1[jj]
            use_para1_b = val_para1[jj+1]
            ;; Find the index1/2 value for this SSP 
            if ( afe_exist EQ 1 ) then begin 
                index_plot_a = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_afe)) EQ float( afe_fix ) )   AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1_a ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2 ) ), $
                    n_plot_a ) 
                index_plot_b = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_afe)) EQ float( afe_fix ) )   AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1_b ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2 ) ), $
                    n_plot_b ) 
            endif else begin 
                index_plot_a = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1_a ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2 ) ), $
                    n_plot_a ) 
                index_plot_b = where( $
                    ( float(index_struc.(tag_fix)) EQ float( value_fix ) ) AND $ 
                    ( float(index_struc.(tag_para1)) EQ float( use_para1_b ) ) AND $ 
                    ( float(index_struc.(tag_para2)) EQ float( use_para2 ) ), $
                    n_plot_b ) 
            endelse
            if keyword_set( debug ) then begin 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                print, ' USE_PARA2  : ', use_para2 
                print, ' USE_PARA1_A: ', use_para1_a
                print, ' USE_PARA1_B: ', use_para1_b
                print, ' N_PLOT_A   : ', n_plot_a
                print, ' N_PLOT_B   : ', n_plot_b
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            endif
            if ( ( n_plot_a EQ 0 ) OR ( n_plot_b EQ 0 ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the index value at this position !'
                print, ' PARA2: ', use_para2
                print, ' PARA1: ', use_para1_a, use_para1_b
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else if ( ( n_plot_a GT 1 ) OR ( n_plot_b GT 1 ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Multiple values with the index at this position ! '
                print, '   Need to constrain other parameters ! '
                print, ' PARA2: ', use_para2
                print, ' PARA1: ', use_para1_a, use_para1_b
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else begin 
                val_index1_a = ( index_struc.( tag_1 ) )[ index_plot_a ]
                val_index2_a = ( index_struc.( tag_2 ) )[ index_plot_a ]
                val_index1_b = ( index_struc.( tag_1 ) )[ index_plot_b ]
                val_index2_b = ( index_struc.( tag_2 ) )[ index_plot_b ]
            endelse
            cgPlot, [val_index1_a, val_index1_b], $
                     [val_index2_a, val_index2_b], /overplot, $
                     linestyle=line_style, thick=line_thick, $
                     color=cgColor( line_color ) 
        endfor
    endfor

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro grid_test  

    index_file='sigma350_un_index.fits' 
    index_1 = 'S05_V6604'
    index_2 = 'LB_TiO2'
    para_fix  = 'Slope'
    value_fix1 = 2.00 
    value_fix2 = 1.30 
    para_1 = 'Age'
    para_2 = 'Metal'
    min_1  = 12.0 
    max_1  = 14.0
    min_2  = -1.45

    hs_plot_index_grid, index_file, index_1, index_2, para_fix, value_fix1, $
        para_1=para_1, para_2=para_2, min_1=min_1, max_1=max_1, min_2=min_2, $
        /debug, line_color='Red'
    hs_plot_index_grid, index_file, index_1, index_2, para_fix, value_fix2, $
        para_1=para_1, para_2=para_2, min_1=min_1, max_1=max_1, min_2=min_2, $
        /debug, line_color='Blue', /overplot

end

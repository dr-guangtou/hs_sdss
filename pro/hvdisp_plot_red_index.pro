; + 
; NAME:
;              HVDISP_PLOT_SIG_INDEX
;
; PURPOSE:
;              Plot the relation between velocity dispersion and spectral index 
;              for HVDISP index measurements
;
; USAGE:
;    hvdisp_plot_sig_index, result_file, index_name
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_plot_sig_index, result_list, index_name, suffix=suffix, $
    symbol_list=symbol_list, symbol_size=symbol_size, frame_list=frame_list, $
    red_include=red_include, plot_name=plot_name, label=label, legend=legend, $
    outline=outline, connect=connect, line_style=line_style, $
    sample_list=sample_list, loc_plot=loc_plot

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The name of the index 
    index_name = strcompress( index_name ) 
    index_show = str_replace( index_name, '_', '-' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Number of index results to be compared 
    num_list   = n_elements( result_list ) 
    if ( num_list GT 6 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The maximum number of result to show is 6 !!! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        for ii = 0, ( num_list - 1 ), 1 do begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Location/Name of the index result file
            result_file = strcompress( result_list[ ii ], /remove_all ) 
            if NOT file_test( result_file ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find the index result file : ' 
                print, ' ' + result_file 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Read in the result 
            index_result = mrdfits( result_file, 1, /silent )
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Build an structure array for structure array
            if ( ii EQ 0 ) then begin 
                index_resarr = { result:index_result } 
                index_resarr = replicate( index_resarr, num_list )
                ;; Get the tag names 
                tag_name = strupcase( tag_names( index_result ) )
            endif else begin 
                index_resarr[ ii ].result = index_result 
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        endfor 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the plot 
    if keyword_set( plot_name ) then begin 
        plot_name = strcompress( plot_name, /remove_all ) 
    endif else begin 
        if keyword_set( suffix ) then begin 
            plot_name = index_name + '_' + suffix + '.eps'
        endif else begin 
            plot_name = index_name + '_sigma_trend.eps' 
        endelse
    endelse
    plot_name = loc_plot + plot_name
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Symbol size
    if keyword_set( symbol_size ) then begin 
        s_size = float( symbol_size ) 
    endif else begin 
        s_size = 3.2 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Symbols
    if keyword_set( symbol_list ) then begin 
        n_sym = n_elements( symbol_list ) 
        if ( n_sym LT num_list ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The number of symbol types is too small !! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            s_type = symbol_list 
        endelse
    endif else begin 
        n_sym   = 6
        s_type  = [ 16, 15, 14, 17, 18, 19 ] 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Outline of the symbol 
    if keyword_set( outline ) then begin 
        if ( keyword_set( frame_list ) AND keyword_set( symbol_list ) ) then begin 
            if ( n_elements( frame_list ) NE n_sym ) then begin  
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The frame_list should have the same number of elements with ' 
                print, '  the symbol_list  !! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif else begin  
                s_frame = frame_list 
            endelse
        endif else begin 
            s_frame = [  9,  6,  4,  5, 11, 12 ]
        endelse
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( line_style ) then begin 
        l_style = long( line_style ) 
    endif else begin 
        l_style = 5 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( sample_list ) then begin 
        n_title = n_elements( sample_list ) 
        if ( n_title GT n_sym ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The N_Title should be less or equal to N_List !!' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif else begin 
            l_title = sample_list 
        endelse
    endif else begin 
        l_title = [ 'Sample 1', 'Sample 2', 'Sample 3', 'Sample 4', $ 
                    'Sample 5', 'Sample 6' ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location of the plot 
    if keyword_set( loc_plot ) then begin 
        loc_plot = strcompress( loc_plot, /remove_all ) 
    endif else begin 
        loc_plot = '' 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Symbol color
    z0_color = [ 'BLK7', 'BLK6', 'BLK5', 'BLK4', 'BLK3', 'BLK2' ]
    z1_color = [ 'RED7', 'RED6', 'RED5', 'RED4', 'RED3', 'RED2' ]
    z2_color = [ 'GRN7', 'GRN6', 'GRN5', 'GRN4', 'GRN3', 'GRN2' ]
    z3_color = [ 'BLU7', 'BLU6', 'BLU5', 'BLU4', 'BLU3', 'BLU2' ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Which redshift to include 
    if keyword_set( red_include ) then begin 
        num_include = n_elements( red_include )
        z0_find     = where( red_include EQ 0 ) 
        z1_find     = where( red_include EQ 1 ) 
        z2_find     = where( red_include EQ 2 ) 
        z3_find     = where( red_include EQ 3 ) 
        if ( z0_find NE -1 ) then begin 
            z0_include = 0 
        endif else begin 
            z0_include = -1 
        endelse
        if ( z1_find NE -1 ) then begin 
            z1_include = 1 
        endif else begin 
            z1_include = -1 
        endelse
        if ( z2_find NE -1 ) then begin 
            z2_include = 2 
        endif else begin 
            z2_include = -1 
        endelse
        if ( z3_find NE -1 ) then begin 
            z3_include = 3 
        endif else begin  
            z3_include = -1 
        endelse
    endif else begin 
        num_include = 3
        z0_include  = -1
        z1_include  = 1 
        z2_include  = 2 
        z3_include  = 3 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check if the INDEX is available 
    index_check = strupcase( index_name ) 
    error_check = index_check + '_ERR'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; And get the number of the index tag
    index_num   = where( strcmp( tag_name, index_check ) EQ 1 )
    error_num   = where( strcmp( tag_name, error_check ) EQ 1 )
    if ( ( index_num EQ -1 ) OR ( error_num EQ -1 ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the tag for the index or its error !! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Min and Max value for the index 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    use_index = where( ( index_resarr.result.red_index EQ z0_include ) OR $ 
                       ( index_resarr.result.red_index EQ z1_include ) OR $
                       ( index_resarr.result.red_index EQ z2_include ) OR $
                       ( index_resarr.result.red_index EQ z3_include ) ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    fin_index = where( $
        finite( index_resarr.result[ use_index ].( index_num ) ) EQ 1 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( n_elements( fin_index ) LE 2 ) then begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, 'No Useful Measurements for index : ' + index_show + ' !!'  
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        index_range = [ -0.99, 0.99 ]
    endif else begin 
        min_index = min( index_resarr.result[ use_index ].( index_num ) )  
        max_index = max( index_resarr.result[ use_index ].( index_num ) )  
        max_error = max( index_resarr.result[ use_index ].( error_num ) )  
        sep_index = ( max_index - min_index )
        min_show  = ( min_index - sep_index / 18.0 ) < $
            ( min_index - 1.8 * max_error )
        max_show  = ( max_index + sep_index / 15.0 ) > $
            ( max_index + 2.0 * max_error )
        index_range = [ min_show, max_show ]
    endelse
    print, index_range 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Min and Max value for sigma 
    min_sigma   = min( index_resarr.result.sig_value )
    max_sigma   = max( index_resarr.result.sig_value )
    sigma_range = [ ( min_sigma - 9.5 ), ( max_sigma + 9.9 ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the plot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    position  = [ 0.17, 0.14, 0.992, 0.992 ]
    psxsize = 30 
    psysize = 30 
    mydevice = !d.name 
    !p.font=1
    set_plot, 'ps' 
    device, filename=plot_name, font_size=9.0, /encapsulated, $
        /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
    sig_increase = 0
    num_plot     = ( num_list * num_include )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, index_resarr.result.sig_value, $
        index_resarr.result.( index_num ), $
        xstyle=1, ystyle=1, xrange=sigma_range, yrange=index_range, $
        position=position, xthick=14.0, ythick=14.0, $
        charsize=5.0, charthick=12.0, $ 
        xtitle='Velocity Dispersion (km/s)', $
        /nodata, /noerase 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for jj = 0, ( num_list - 1 ), 1 do begin 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( z0_include NE -1 ) then begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            index_z0 = where( index_resarr[ jj ].result.red_index EQ 0 )
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( index_z0[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find useful index for z0 !!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif else begin 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                num_z0 = n_elements( index_z0 )
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Connect the data points 
                if keyword_set( connect ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z0 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z0 ].( index_num ), $
                        linestyle=l_style, thick=7.5, $
                        color=cgColor( z0_color[ jj ] ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Scatter plot
                cgOPlot, index_resarr[ jj ].result[ index_z0 ].sig_value, $ 
                         index_resarr[ jj ].result[ index_z0 ].( index_num ), $
                         psym=s_type[ jj ], symsize=s_size, thick=8.0, $
                         color=cgColor( z0_color[ jj ] ) 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Outline the symbols
                if keyword_set( outline ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z0 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z0 ].( index_num ), $
                        psym=s_frame[ jj ], symsize=s_size, thick=8.0, $
                        color=cgColor( 'Black' ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Overplot error 
                if ( jj EQ ( num_list - 1 ) ) then begin 
                    xx = index_resarr[ jj ].result[ index_z0[0] ].sig_value
                    yy = index_resarr[ jj ].result[ index_z0[0] ].( index_num )
                    ye = index_resarr[ jj ].result[ index_z0[0] ].( error_num )
                    cgOPlot, [ xx ], [ yy ], /err_clip, $
                        err_color=cgColor( z0_color[0] ), $ 
                        err_thick=8.0, err_width=0.01, $
                        err_yhigh=ye, err_ylow=ye, psym=1
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get the index trend
                if ( index_resarr[jj].result[index_z0[0]].(index_num) LT $
                    index_resarr[jj].result[index_z0[num_z0-1]].(index_num ) ) $
                    then begin 
                    sig_increase += 1 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            endelse
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( z1_include NE -1 ) then begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            index_z1 = where( index_resarr[ jj ].result.red_index EQ 1 )
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( index_z1[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find useful index for z1 !!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif else begin 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                num_z1 = n_elements( index_z1 )
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Connect the data points 
                if keyword_set( connect ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z1 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z1 ].( index_num ), $
                        linestyle=l_style, thick=7.5, $
                        color=cgColor( z1_color[ jj ] ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Scatter plot
                cgOPlot, index_resarr[ jj ].result[ index_z1 ].sig_value, $ 
                         index_resarr[ jj ].result[ index_z1 ].( index_num ), $
                         psym=s_type[ jj ], symsize=s_size, thick=8.0, $
                         color=cgColor( z1_color[ jj ] ) 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Outline the symbols
                if keyword_set( outline ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z1 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z1 ].( index_num ), $
                        psym=s_frame[ jj ], symsize=s_size, thick=8.0, $
                        color=cgColor( 'Black' ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Overplot error 
                if ( jj EQ ( num_list - 1 ) ) then begin 
                    xx = index_resarr[ jj ].result[ index_z1[0] ].sig_value
                    yy = index_resarr[ jj ].result[ index_z1[0] ].( index_num )
                    ye = index_resarr[ jj ].result[ index_z1[0] ].( error_num )
                    cgOPlot, [ xx ], [ yy ], /err_clip, $
                        err_color=cgColor( z1_color[0] ), $ 
                        err_thick=8.0, err_width=0.01, $
                        err_yhigh=ye, err_ylow=ye, psym=1
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get the index trend
                if ( index_resarr[jj].result[index_z1[0]].(index_num) LT $
                    index_resarr[jj].result[index_z1[num_z1-1]].(index_num ) ) $
                    then begin 
                    sig_increase += 1 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            endelse
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( z2_include NE -1 ) then begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            index_z2 = where( index_resarr[ jj ].result.red_index EQ 2 )
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( index_z2[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find useful index for z2 !!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif else begin 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                num_z2 = n_elements( index_z2 )
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Connect the data points 
                if keyword_set( connect ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z2 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z2 ].( index_num ), $
                        linestyle=l_style, thick=7.5, $
                        color=cgColor( z2_color[ jj ] ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Scatter plot
                cgOPlot, index_resarr[ jj ].result[ index_z2 ].sig_value, $ 
                         index_resarr[ jj ].result[ index_z2 ].( index_num ), $
                         psym=s_type[ jj ], symsize=s_size, thick=8.0, $
                         color=cgColor( z2_color[ jj ] ) 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Outline the symbols
                if keyword_set( outline ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z2 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z2 ].( index_num ), $
                        psym=s_frame[ jj ], symsize=s_size, thick=8.0, $
                        color=cgColor( 'Black' ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Overplot error 
                if ( jj EQ ( num_list - 1 ) ) then begin 
                    xx = index_resarr[ jj ].result[ index_z2[0] ].sig_value
                    yy = index_resarr[ jj ].result[ index_z2[0] ].( index_num )
                    ye = index_resarr[ jj ].result[ index_z2[0] ].( error_num )
                    cgOPlot, [ xx ], [ yy ], /err_clip, $
                        err_color=cgColor( z2_color[0] ), $ 
                        err_thick=8.0, err_width=0.01, $
                        err_yhigh=ye, err_ylow=ye, psym=1
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get the index trend
                if ( index_resarr[jj].result[index_z2[0]].(index_num) LT $
                    index_resarr[jj].result[index_z2[num_z2-1]].(index_num ) ) $
                    then begin 
                    sig_increase += 1 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            endelse
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( z3_include NE -1 ) then begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            index_z3 = where( index_resarr[ jj ].result.red_index EQ 3 )
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( index_z3[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find useful index for z3 !!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif else begin 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                num_z3 = n_elements( index_z3 )
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Connect the data points 
                if keyword_set( connect ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z3 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z3 ].( index_num ), $
                        linestyle=l_style, thick=7.5, $
                        color=cgColor( z3_color[ jj ] ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Scatter plot
                cgOPlot, index_resarr[ jj ].result[ index_z3 ].sig_value, $ 
                         index_resarr[ jj ].result[ index_z3 ].( index_num ), $
                         psym=s_type[ jj ], symsize=s_size, thick=8.0, $
                         color=cgColor( z3_color[ jj ] ) 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Outline the symbols
                if keyword_set( outline ) then begin 
                    cgOPlot, index_resarr[ jj ].result[ index_z3 ].sig_value, $ 
                        index_resarr[ jj ].result[ index_z3 ].( index_num ), $
                        psym=s_frame[ jj ], symsize=s_size, thick=8.0, $
                        color=cgColor( 'Black' ) 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Overplot error 
                if ( jj EQ ( num_list - 1 ) ) then begin 
                    xx = index_resarr[ jj ].result[ index_z3[0] ].sig_value
                    yy = index_resarr[ jj ].result[ index_z3[0] ].( index_num )
                    ye = index_resarr[ jj ].result[ index_z3[0] ].( error_num )
                    cgOPlot, [ xx ], [ yy ], /err_clip, $
                        err_color=cgColor( z3_color[0] ), $ 
                        err_thick=8.0, err_width=0.01, $
                        err_yhigh=ye, err_ylow=ye, psym=1
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get the index trend
                if ( index_resarr[jj].result[index_z3[0]].(index_num) LT $
                    index_resarr[jj].result[index_z3[num_z3-1]].(index_num ) ) $
                    then begin 
                    sig_increase += 1 
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            endelse
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Put the legends on 
    if keyword_set( legend ) then begin 
        if ( sig_increase GE ( num_plot / 2 ) ) then begin 
            x_legend = 0.80 
            y_legend = ( position[1] + 0.060 ) 
        endif else begin 
            x_legend = 0.23 
            y_legend = ( position[1] + 0.060 ) 
        endelse
        x_step = 0.025 
        y_step = 0.036
        y_off  = 0.008
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for kk = 0, ( num_list - 1 ), 1 do begin 
            ;; Symbol 
            cgPlots, x_legend, ( y_legend + kk * y_step ), /normal, $
                psym=s_type[ num_list - 1 -kk ], symsize=2.8, $
                thick=8.0, color=cgColor( 'BLK6' ) 
            ;; Frame
            if keyword_set( outline ) then begin 
                cgPlots, x_legend, ( y_legend + kk * y_step ), /normal, $
                    psym=s_frame[ num_list - 1 -kk ], symsize=2.9, $
                    thick=9.0, color=cgColor( 'Black' ) 
            endif 
            ;; Text 
            cgText, ( x_legend + x_step ), ( y_legend + kk * y_step - y_off ), $
                l_title[ num_list - 1 - kk ], /normal, alignment=0,  $
                charsize=3.2, charthick=8.5, color=cgColor( 'Black' )
        endfor
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Label the name of the index
    if keyword_set( label ) then begin 
        x_label = ( ( position[0] + position[2] ) / 2.0 )
        y_label = ( position[3] - 0.08 )
        cgText, x_label, y_label, index_show, charsize=8.5, charthick=11.0, $
            alignment=0.5, /normal
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, /close 
    set_plot, mydevice 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro test_sigma_index 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    result_list = strarr(4)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;index_name = 'Lick_TiO2'
    ;index_name = 'SP_CaH1'
    index_name = 'S05_Ba4933'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_index = '/home/hs/hvdisp/coadd/results/index/'
    result_list[0] = loc_index + 'hvdisp_l_spec_robust_index_all.fits'
    result_list[1] = loc_index + 'hvdisp_k_spec_robust_index_all.fits'
    result_list[2] = loc_index + 'hvdisp_l_robust_mius_imix_index_all.fits'
    result_list[3] = loc_index + 'hvdisp_l_spec_median_index_all.fits'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_plot_sig_index, result_list, index_name, suffix='test1', $ 
        red_include=[ 0, 1, 2, 3 ], /outline, /connect, /label, /legend 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;pro hvdisp_plot_sigma_index, result_list, index_name, suffix=suffix, $
;;    symbol_list=symbol_list, symbol_size=symbol_size, frame_list=frame_list, $
;;    red_include=red_include, plot_name=plot_name, frame=frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

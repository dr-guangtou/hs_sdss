; + 
; NAME:
;              HVDISP_PLOT_RED_INDEX
;
; PURPOSE:
;              Plot the relation between redshift and spectral index 
;              for HVDISP index measurements
;
; USAGE:
;    hvdisp_plot_red_index, result_file, index_name
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;             Song Huang, 2014/09/28 - Second version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_plot_red_index, result_file, index_name, csp_list, suffix=suffix, $
    symbol_list=symbol_list, symbol_size=symbol_size, frame_list=frame_list, $
    plot_name=plot_name, label=label, legend=legend, outline=outline, $
    connect=connect, line_style=line_style, sample_list=sample_list, $
    loc_plot=loc_plot, min_sigma=min_sigma, normalize=normalize

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Time range 
    time_range = [ 11.40, 13.30 ]
    ;; Redshift arrary 
    red_arr = [ 0.075, 0.047, 0.100, 0.155 ]
    age_arr = [ 12.72, 13.08, 12.40, 11.76 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( min_sigma ) then begin 
        min_sigma = float( min_sigma ) 
    endif else begin 
        min_sigma = 240.0 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The name of the index 
    index_name = strcompress( index_name ) 
    index_show = str_replace( index_name, '_', '-' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the index results 
    if file_test( result_file ) then begin 
        index_struc = mrdfits( result_file, 1, /silent ) 
        tag_name = strupcase( tag_names( index_struc ) )
        index_num = where( strcmp( tag_name, strupcase( index_name ) ) EQ 1 ) 
        error_num = where( strcmp( tag_name, strupcase( index_name ) + $
            '_ERR' ) EQ 1 ) 
        if ( ( index_num EQ -1 ) or ( error_num EQ -1 ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the tag for the index or its error !! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif
        ;; 
        sig_array = index_struc.sig_value 
        index_tmp = where( sig_array GT min_sigma ) 
        if ( index_tmp[0] NE -1 ) then begin 
            sig_use  = sig_array[ index_tmp ] 
            sig_uniq = reverse( sig_use[ uniq( sig_use, sort( sig_use ) ) ] )
            num_sig  = n_elements( sig_uniq )
        endif else begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' There is no useful velocity dispersion !'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endelse
        ;; Min and max of the observed index value
        min_index = min( index_struc[ index_tmp ].( index_num ) ) 
        max_index = max( index_struc[ index_tmp ].( index_num ) )
        max_observe = max_index
        min_observe = min_index
        ;; Findout the reference index value 
        index_ref = where( ( index_struc.sig_value EQ max( sig_uniq ) ) AND $ 
            ( index_struc.red_index EQ 1 ) ) 
        value_ref = index_struc[ index_ref ].( index_num )
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the index result file !! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
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
        if ( n_sym LT num_sig ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The number of symbol types is too small !! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
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
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The frame_list should have the same number of elements with ' 
                print, '  the symbol_list  !! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
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
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The N_Title should be less or equal to N_List !!' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
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
    plot_name = loc_plot + plot_name
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Symbol color
    sig_color = [ 'RED6', 'BLU6', 'GRN6', 'ORG6', 'Cyan', 'BLK4' ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the CSP models
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( csp_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the CSP list : ' + csp_list + ' !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, csp_list, csp_files, format='A', comment='#', /silent 
        num_csp = n_elements( csp_files ) 
        for jj = 0, ( num_csp - 1 ), 1 do begin 
            csp_struc = mrdfits( csp_files[ jj ], 1 )
            index_tmp = where( ( csp_struc.cos_age GE time_range[0] ) AND $
                ( csp_struc.cos_age LE time_range[1] ) ) 
            if ( index_tmp[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find useful index !! Check !! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif 
            tag_csp = strupcase( tag_names( csp_struc ) )
            indcsp_num = where( strcmp( tag_csp, strupcase( index_name ) ) EQ 1 ) 
            if ( indcsp_num[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find the INDEX : ' + index_name + ' !!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif 
            csp_index  = csp_struc[ index_tmp ].( indcsp_num ) 
            csp_time   = csp_struc[ index_tmp ].cos_age 
            if ( jj EQ 0 ) then begin 
                models = { time:csp_time, index:csp_index } 
                models = replicate( models, num_csp ) 
            endif else begin 
                models[ jj ].time  = csp_time 
                models[ jj ].index = csp_index
            endelse
            if keyword_set( normalize ) then begin 
                index_min = ( n_elements( csp_time ) - 1 ) 
                models[ jj ].index = ( models[ jj ].index - $
                    csp_index[ index_min ] ) + value_ref
            endif 
        endfor 
        ;; Update the min and max of index value for plot
        min_index = min_index < min( models.index ) 
        max_index = max_index > max( models.index )
        sep_index = ( ( max_index - min_index ) / 15.0 )
        index_range = [ ( min_index - sep_index ), ( max_index + sep_index ) ]
    endelse
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
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, models[0].time, models[0].index, $
        xstyle=1, ystyle=1, xrange=time_range, yrange=index_range, $
        position=position, xthick=14.0, ythick=14.0, $
        charsize=5.0, charthick=12.0, $ 
        xtitle='Look-Back Time (Gyr)', $
        /nodata, /noerase 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for kk = 0, ( num_csp - 1 ), 1 do begin 
        cgOplot, models[ kk ].time, models[ kk ].index, linestyle=0, $
            thick=2.0, color=cgColor( 'BLK4' ) 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for mm = 0, ( num_sig - 1 ), 1 do begin 
        sig_plot = sig_uniq[ mm ] 
        index_0 = where( ( index_struc.sig_value EQ sig_plot ) AND $
            ( index_struc.red_index EQ 0 ) ) 
        if ( index_0[0] NE -1 ) then begin 
            ;cgOplot, age_arr[0], index_struc[ index_0 ].( index_num ), $
            ;    psym=s_type[ mm ], symsize=s_size, $
            ;    color=cgColor( sig_color[ mm ] ) 
        endif 
        index_1 = where( ( index_struc.sig_value EQ sig_plot ) AND $
            ( index_struc.red_index EQ 1 ) ) 
        if ( index_1[0] NE -1 ) then begin 
            cgOplot, age_arr[1], index_struc[ index_1 ].( index_num ), $
                psym=s_type[ mm ], symsize=s_size, $
                color=cgColor( sig_color[ mm ] )
        endif 
        index_2 = where( ( index_struc.sig_value EQ sig_plot ) AND $
            ( index_struc.red_index EQ 2 ) ) 
        if ( index_2[0] NE -1 ) then begin 
            cgOplot, age_arr[2], index_struc[ index_2 ].( index_num ), $
                psym=s_type[ mm ], symsize=s_size, $
                color=cgColor( sig_color[ mm ] )
        endif 
        index_3 = where( ( index_struc.sig_value EQ sig_plot ) AND $
            ( index_struc.red_index EQ 3 ) ) 
        if ( index_3[0] NE -1 ) then begin 
            cgOplot, age_arr[3], index_struc[ index_3 ].( index_num ), $
                psym=s_type[ mm ], symsize=s_size, $
                color=cgColor( sig_color[ mm ] )
        endif 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, models[0].time, models[0].index, $
        xstyle=1, ystyle=1, xrange=time_range, yrange=index_range, $
        position=position, xthick=14.0, ythick=14.0, $
        charsize=5.0, charthick=12.0, $ 
        /nodata, /noerase 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Put the legends on 
    if keyword_set( legend ) then begin 
        x_legend = 0.80 
        y_legend = ( position[1] + 0.060 ) 
        x_step = 0.025 
        y_step = 0.036
        y_off  = 0.008
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for kk = 0, ( num_sig - 1 ), 1 do begin 
            ;; Symbol 
            cgPlots, x_legend, ( y_legend + kk * y_step ), /normal, $
                psym=s_type[ num_sig - 1 -kk ], symsize=2.8, $
                thick=8.0, color=cgColor( 'BLK6' ) 
            ;; Frame
            if keyword_set( outline ) then begin 
                cgPlots, x_legend, ( y_legend + kk * y_step ), /normal, $
                    psym=s_frame[ num_sig - 1 -kk ], symsize=2.9, $
                    thick=9.0, color=cgColor( 'Black' ) 
            endif 
            ;; Text 
            cgText, ( x_legend + x_step ), ( y_legend + kk * y_step - y_off ), $
                l_title[ num_sig - 1 - kk ], /normal, alignment=0,  $
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
pro test_red_index 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_plot = '~/Downloads/fig/csp/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    result_list = strarr(1)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_name = 'LB_TiO2'
    ;index_name = 'SP_CaH1'
    ;index_name = 'S05_Ba4933'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;loc_index = '/Users/songhuang/astro1/data/hvdisp/coadd/results/index/'
    loc_index = '/home/hs/hvdisp/coadd/results/index/'
    index_result = loc_index + 'hvdisp_k_robust_mius_imix_index_all.fits'
    ;index_result = loc_index + 'hvdisp_l_spec_robust_index_all.fits'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    csp_loc = '/home/hs/hvdisp/csp/miu/'
    ;csp_loc = '/Users/songhuang/astro1/data/hvdisp/csp/miu/'
    ;csp_list = csp_loc + 'mius_csp_s13_index2.lis' 
    csp_list = csp_loc + 'aaa.lis' 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_plot_red_index, index_result, index_name, csp_list, $
        min_sigma=260.0, suffix='redtrend', /normalize, loc_plot=loc_plot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pro hvdisp_plot_sig_index, result_file, index_name, csp_list, suffix=suffix, $
;    symbol_list=symbol_list, symbol_size=symbol_size, frame_list=frame_list, $
;    red_include=red_include, plot_name=plot_name, label=label, legend=legend, $
;    outline=outline, connect=connect, line_style=line_style, $
;    sample_list=sample_list, loc_plot=loc_plot, min_sigma=min_sigma
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

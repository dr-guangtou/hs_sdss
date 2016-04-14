; + 
; NAME:
;              HS_COADD_SDSS_PLOT
;
; PURPOSE:
;              Make a summary plot for the coadded spectrum 
;
; USAGE:
;    hs_coadd_plot, sum_file, index_list=index_list, prefix=prefix
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;             Song Huang, 2014/06/10 - Minor improvements 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_coadd_sdss_plot, sum_file, index_list=index_list, prefix=prefix, $
    hvdisp_home=hvdisp_home, data_dir=data_dir, $
    avg_boot=avg_boot, test_str=test_str 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    len_1 = strlen(hvdisp_home)
    if strmid( hvdisp_home, ( len_1 - 1 ), len_1 ) NE '/' then begin 
        hvdisp_home = hvdisp_home + '/'
    endif 

    if NOT keyword_set( data_dir ) then begin 
        data_home = './'
    endif else begin 
        data_home = strcompress( data_dir, /remove_all )
    endelse
    len_2 = strlen(data_home)
    if strmid( data_home, ( len_2 - 1 ), len_2 ) NE '/' then begin 
        data_home = data_home + '/'
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( prefix ) then begin 
        tmp = strsplit( sum_file, './', /extract ) 
        if ( n_elements( tmp ) EQ 1 ) then begin 
            prefix = tmp[0] 
        endif else begin 
            prefix = tmp[ n_elements( tmp ) - 2 ] 
        endelse 
    endif else begin 
        prefix = strcompress( prefix, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_indexlis = hvdisp_home + 'pro/lis/'
    loc_coadd    = data_home + 'coadd/'
    if NOT file_test(loc_coadd, /directory) then begin 
        spawn, 'mkdir ' + loc_coadd
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check the file 
    sum_file = strcompress( sum_file, /remove_all ) 
    if NOT file_test( sum_file ) then begin 
        sum_file = loc_coadd + sum_file 
    endif 

    if NOT file_test( sum_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the file : ' + sum_file + ' !!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        coadd_struc = mrdfits( sum_file, 1, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the file: ' + file + ' !!' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif else begin 
            if ( ( tag_indx( coadd_struc, 'wave'       ) EQ -1 ) OR $
                 ( tag_indx( coadd_struc, 'n_spec'     ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'n_boot'     ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'n_pix'      ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'sig_convol' ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'frac'       ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'snr'        ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'median_arr' ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'median_sig' ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'median_mask') EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'median_min' ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'median_max' ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'robust_arr' ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'robust_mask') EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'lquar'      ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'uquar'      ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'lifen'      ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'uifen'      ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'lofen'      ) EQ -1 ) OR $ 
                 ( tag_indx( coadd_struc, 'uofen'      ) EQ -1 ) ) then begin 
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 print, ' The structure has incompatible tags !! Check !! '
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 message, ' '
             endif else begin
                 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                 ;; Information to put on the plot 
                 n_spec   = coadd_struc.n_spec 
                 n_boot   = coadd_struc.n_boot 
                 csigma   = coadd_struc.sig_convol 
                 min_norm = coadd_struc.min_norm
                 max_norm = coadd_struc.max_norm
                 min_rest = coadd_struc.min_rest
                 max_rest = coadd_struc.max_rest
                 ;; String 
                 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                 n_spec_str = strcompress( string( n_spec, format='(I9)' ), $
                     /remove_all ) 
                 n_boot_str = strcompress( string( n_boot, format='(I9)' ), $
                     /remove_all ) 
                 csigma_str = strcompress( string( csigma, format='(F6.0)' ), $
                     /remove_all ) + ' km/s' 
                 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                 ;; Array 
                 wave     = coadd_struc.wave 
                 frac     = coadd_struc.frac 
                 snr      = coadd_struc.snr 
                 if keyword_set( avg_boot ) then begin 
                     med_arr = coadd_struc.median_avg 
                 endif else begin 
                     med_arr  = coadd_struc.median_arr 
                 endelse
                 med_sig  = coadd_struc.median_sig 
                 med_min  = coadd_struc.median_min 
                 med_max  = coadd_struc.median_max 
                 med_mask = coadd_struc.median_mask 
                 rob_arr  = coadd_struc.robust_arr 
                 rob_mask = coadd_struc.robust_mask 
                 lquar    = coadd_struc.lquar
                 uquar    = coadd_struc.uquar
                 lifen    = coadd_struc.lifen
                 uifen    = coadd_struc.uifen
                 lofen    = coadd_struc.lofen
                 uofen    = coadd_struc.uofen
                 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             endelse
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the plot 
    prefix = strcompress( prefix, /remove_all ) 
    if keyword_set( test_str ) then begin 
        test_str = strcompress( test_str, /remove_all ) 
        new_prefix = prefix + '_' + test_str 
    endif else begin 
        new_prefix = prefix 
    endelse
    plot_1 = loc_coadd + new_prefix + '_coadd_1.eps'
    plot_2 = loc_coadd + new_prefix + '_coadd_2.eps'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Index to over-plot 
    if keyword_set( index_list ) then begin 
        index_list = loc_indexlis + strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = loc_indexlis + 'hs_index_plot.lis' 
    endelse
    if file_test( index_list ) then begin 
        list_find = 1 
    endif else begin 
        list_find = 0 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the index list file, Can not overplot !! '
        print, ' ' + index_list
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Prepare for the plot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Wavelength array 
    wave_range = [ min( wave ), max( wave ) ] 
    ;; "Safe" range 
    wave_safe0 = max( min_rest ) 
    wave_safe1 = min( max_rest )
    ;; Error range 
    med_upp = ( med_arr + med_sig ) 
    med_low = ( med_arr - med_sig )
    ;; "Comfortable" Wavelength range 
    index_comf = where( ( wave GE ( min( wave ) + 60 ) ) AND $
                        ( wave LE ( max( wave ) - 80 ) ) )
    wave_comf = wave[ index_comf ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    med_min_comf = med_min[ index_comf ]
    med_max_comf = med_max[ index_comf ]
    med_low_comf = med_low[ index_comf ]
    med_upp_comf = med_upp[ index_comf ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Flux array 
    index_bad_1 = where( med_mask GT 0, n_bad_1, complement=index_good_1 )  
    index_bad_2 = where( rob_mask GT 0, n_bad_2, complement=index_good_2 )  
    index_bad_3 = where( ( med_mask GT 0 ) OR ( rob_mask GT 0 ), n_bad_3, $
        complement=index_good_3 )
    index_safe = where( ( wave GE wave_safe0 ) AND ( wave LE wave_safe1 ) )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Diff array
    diff_lam = wave[ index_good_3 ]
    diff_arr = ( ( med_arr[ index_good_3 ] - rob_arr[ index_good_3 ] ) / $
        rob_arr[ index_good_3 ] ) * 100.0
    min_diff = min( diff_arr[ index_safe ] ) > ( -2.90 ) 
    min_diff = min_diff < ( -0.09 )
    max_diff = max( diff_arr[ index_safe ] )
    diff_sep = ( max_diff - min_diff ) 
    diff_range = [ ( min_diff - diff_sep / 8.0 ), $
                   ( max_diff + diff_sep / 8.0 ) ]
    ;; Ugly, Ugly method... TODO
    diff_sep += ( diff_sep / 4.0 ) 
    ;;
    if ( diff_sep LT 4.999 ) then begin 
        diff_inter = 1.0 
    endif 
    if ( diff_sep LT 2.499 ) then begin 
        diff_inter = 0.6 
    endif 
    if ( diff_sep LT 2.299 ) then begin 
        diff_inter = 0.5 
    endif 
    if ( diff_sep LT 1.999 ) then begin 
        diff_inter = 0.4 
    endif 
    if ( diff_sep LT 1.499 ) then begin 
        diff_inter = 0.3 
    endif 
    if ( diff_sep LT 0.899 ) then begin 
        diff_inter = 0.2 
    endif 
    if ( diff_sep LT 0.499 ) then begin 
        diff_inter = 0.1 
    endif 
    if ( diff_sep LT 0.249 ) then begin 
        diff_inter = 0.05 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Flux  
    min_flux_1 = min( rob_arr ) 
    max_flux_1 = max( rob_arr )
    flux_sep_1 = ( max_flux_1 - min_flux_1 ) 
    flux_range_1 = [ ( min_flux_1 - flux_sep_1 / 35.0 ), $
                     ( max_flux_1 + flux_sep_1 / 2.8  ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    min_flux_2 = min( lofen[ index_comf ] ) 
    max_flux_2 = max( uofen[ index_comf ] )
    flux_sep_2 = ( max_flux_2 - min_flux_2 ) 
    flux_range_2 = [ ( min_flux_2 - flux_sep_2 / 50.0 ), $
                     ( max_flux_2 + flux_sep_2 / 5.0  ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Fraction 
    min_frac = min( frac ) < 0.502 
    max_frac = 1.09 
    frac_range = [ min_frac, max_frac ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; S/N 
    snr = ( snr / 100.0 )
    min_snr = min( snr[ where( finite( snr ) EQ 1 ) ] )
    max_snr = max( snr[ where( finite( snr ) EQ 1 ) ] )
    med_snr = median( snr[ where( finite( snr ) EQ 1 ) ] )
    snr_sep = ( max_snr - min_snr ) 
    min_snr_show = ( min_snr - snr_sep / 10.0 ) > 0.8
    max_snr_show = ( max_snr + snr_sep /  6.0 )
    snr_range = [ min_snr_show, max_snr_show ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; FIGURE 1 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start the first figure 
    mydevice = !d.name
    !p.font=0
    set_plot, 'ps'
    psxsize = 50 
    psysize = 30
    device, filename=plot_1, font_size=8.5, /encapsulated, $
        /color, /helvetica, /bold, xsize=psxsize, ysize=psysize 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; position of the plot
    position_0 = [ 0.08, 0.45, 0.98, 0.99 ] 
    position_1 = [ 0.08, 0.33, 0.98, 0.45 ]
    position_2 = [ 0.08, 0.21, 0.98, 0.33 ]
    position_3 = [ 0.08, 0.09, 0.98, 0.21 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 1. Co-added spectra 
    cgPlot, wave, med_arr, xstyle=1, ystyle=1, position=position_0, $
        xrange=wave_range, yrange=flux_range_1, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='Flux (Normalized)', $
        xticklen=0.03, yticklen=0.01 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /center_line, line_center=0, $
            color_center='TAN3'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Shade over the bootstrap region 
    cgColorFill, [ wave_comf[0], wave_comf, reverse( wave_comf ) ], $
        [ med_min_comf[0], med_min_comf, reverse( med_max_comf ) ], $
        color=cgColor( 'BLK4' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the safe range 
    cgOPlot, [ wave_safe0, wave_safe0 ], !Y.Crange, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    cgOPlot, [ wave_safe1, wave_safe1 ], !Y.Crange, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the normalization range
    cgOPlot, [ min_norm, min_norm ], !Y.Crange, linestyle=5, $
        thick=5.0, color=cgColor( 'BLU3' )
    cgOPlot, [ max_norm, max_norm ], !Y.Crange, linestyle=5, $
        thick=5.0, color=cgColor( 'BLU3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Shade over the bootstrap sigma 
    cgColorFill, [ wave_comf[0], wave_comf, reverse( wave_comf ) ], $
        [ med_low_comf[0], med_low_comf, reverse( med_upp_comf ) ], $
        color=cgColor( 'GRN3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The median combined spectrum
    cgOPlot, wave, med_arr, linestyle=0, thick=4.2, color=cgColor( 'Blue' ) 
    ;;;;;;;;;;;;;;;;;;;22;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The PCA-average spectrum
    cgOPlot, wave[ index_good_3 ], rob_arr[ index_good_3 ], linestyle=0, $
        thick=3.8, color=cgColor( 'Red' ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /label_over, /no_fill, /no_line, $
            xstep=38, ystep=38, charsize=1.4, max_overlap=8
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave, med_arr, xstyle=1, ystyle=1, position=position_0, $
        xrange=wave_range, yrange=flux_range_1, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='Flux (Normalized)', $
        xticklen=0.03, yticklen=0.01 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 2. Difference
    cgPlot, diff_lam, diff_arr, xstyle=1, ystyle=1, position=position_1, $
        xrange=wave_range, yrange=diff_range, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=2.3, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='Diff (%)', $
        xticklen=0.10, yticklen=0.01, yminor=2, ytickinterval=diff_inter
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /center_line, line_center=2, $
            color_center='TAN5'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the safe range 
    cgPlot, [ wave_safe0, wave_safe0 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    cgPlot, [ wave_safe1, wave_safe1 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the normalization range
    cgPlot, [ min_norm, min_norm ], !Y.Crange, /overplot, linestyle=2, $
        thick=5.0, color=cgColor( 'BLU3' )
    cgPlot, [ max_norm, max_norm ], !Y.Crange, /overplot, linestyle=2, $
        thick=5.0, color=cgColor( 'BLU3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Difference 
    cgPlot, !X.Crange, [0.0,0.0], linestyle=5, thick=5.0, /overplot, $
        color=cgColor( 'Dark Gray' )
    cgPlot, diff_lam, diff_arr, linestyle=0, thick=3.0, $
        color=cgColor( 'RED' ), /overplot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, diff_lam, diff_arr, xstyle=1, ystyle=1, position=position_1, $
        xrange=wave_range, yrange=diff_range, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=2.3, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='Diff (%)', $
        xticklen=0.10, yticklen=0.01, yminor=2, ytickinterval=diff_inter
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 3. SNR 
    cgPlot, wave, snr, xstyle=1, ystyle=1, position=position_2, $
        xrange=wave_range, yrange=snr_range, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=2.3, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='(S/N)/100', $
        xticklen=0.10, yticklen=0.01, yminor=2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /center_line, line_center=2, $
            color_center='TAN5'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the safe range 
    cgPlot, [ wave_safe0, wave_safe0 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    cgPlot, [ wave_safe1, wave_safe1 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the normalization range
    cgPlot, [ min_norm, min_norm ], !Y.Crange, /overplot, linestyle=2, $
        thick=5.0, color=cgColor( 'BLU3' )
    cgPlot, [ max_norm, max_norm ], !Y.Crange, /overplot, linestyle=2, $
        thick=5.0, color=cgColor( 'BLU3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; S/N
    cgPlot, !X.Crange, [ med_snr, med_snr ], linestyle=5, thick=4.0, $
        /overplot, color=cgColor( 'DARK GRAY' )
    cgPlot, wave, snr, linestyle=0, thick=4.5, color=cgColor( 'BLU7' ), $
        /overplot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave, snr, xstyle=1, ystyle=1, position=position_2, $
        xrange=wave_range, yrange=snr_range, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=2.3, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='(S/N)/100', $
        xticklen=0.10, yticklen=0.01, yminor=2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 4. Fraction of used spectra
    cgPlot, wave, frac, xstyle=1, ystyle=1, position=position_3, $
        xrange=wave_range, yrange=frac_range, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=2.3, charthick=10.0, $ 
        xtickformat='(A1)', ytitle='Fraction', $
        xticklen=0.10, yticklen=0.01, yminor=2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /center_line, line_center=2, $
            color_center='TAN5'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the safe range 
    cgPlot, [ wave_safe0, wave_safe0 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    cgPlot, [ wave_safe1, wave_safe1 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    ;; Highlight the normalization range
    cgPlot, [ min_norm, min_norm ], !Y.Crange, /overplot, linestyle=2, $
        thick=5.0, color=cgColor( 'BLU3' )
    cgPlot, [ max_norm, max_norm ], !Y.Crange, /overplot, linestyle=2, $
        thick=5.0, color=cgColor( 'BLU3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Fraction
    cgPlot, !X.Crange, [ 1.0, 1.0 ], linestyle=5, thick=4.0, /overplot, $
        color=cgColor( 'DARK GRAY' )
    cgPlot, wave, frac, linestyle=0, thick=5.0, color=cgColor( 'BLU7' ), $
        /overplot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave, frac, xstyle=1, ystyle=1, position=position_3, $
        xrange=wave_range, yrange=frac_range, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $ 
        xtitle='Wavelength (Angstrom)', ytickformat='(A1)', $
        xticklen=0.10, yticklen=0.01, yminor=2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Make a few labels 
    x_text   = ( position_0[0] + 0.300 ) 
    y_text_0 = ( position_0[1] + 0.030 )
    y_text_1 = 0.03
    string_1 = 'Co-add ' + strcompress( string( n_spec ), /remove_all ) + $ 
        ' spectra'
    cgText, x_text, ( y_text_0 + 2.0 * y_text_1 ), string_1, $
        charsize=2.5, alignment=0, /normal, color=cgColor( 'Black' ), $
        charthick=15.0
    string_2 = 'With ' + strcompress( string( n_boot ), /remove_all ) + $ 
        ' bootstrap runs' 
    cgText, x_text, ( y_text_0 + y_text_1 ), string_2, $
        charsize=2.5, alignment=0, /normal, color=cgColor( 'Black' ), $
        charthick=15.0
    string_3 = 'Convolved to ' + $
        strcompress( string( csigma, format='(F5.1)' ), /remove_all ) + $
        ' km/s'
    cgText, x_text, y_text_0, string_3, $
        charsize=2.5, alignment=0, /normal, color=cgColor( 'Black' ), $
        charthick=15.0
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Legends 
    x_line_0 = ( ( position_0[0] + position_0[2] ) / 2.0 ) + 0.06 
    x_line_1 = ( ( position_0[0] + position_0[2] ) / 2.0 ) + 0.22 
    len_line = 0.03
    y_line_0 = ( position_0[1] + 0.035 )
    y_line_1 = 0.03
    sep_text = 0.008
    off_text = 0.007
    cgPlots, [ x_line_0, ( x_line_0 + len_line ) ], $
        [ y_line_0, y_line_0 ], $
       psym=0, linestyle=0, thick=10.0, color=cgColor( 'RED' ), /normal 
    cgText, ( x_line_0 + len_line + sep_text ), ( y_line_0 - off_text ), $
        'Robust Average', charsize=2.5, alignment=0, $
        /normal, color=cgColor( 'Black' ), charthick=12.0
    cgPlots, [ x_line_0, ( x_line_0 + len_line ) ], $
        [ ( y_line_0 + y_line_1 ), ( y_line_0 + y_line_1 ) ], $
       psym=0, linestyle=0, thick=10.0, color=cgColor( 'BLUE' ), /normal 
    cgText, ( x_line_0 + len_line + sep_text ), $
        ( y_line_0 + y_line_1 - off_text ), $
        'Median Combined ', charsize=2.5, alignment=0, $
        /normal, color=cgColor( 'Black' ), charthick=12.0
    cgPlots, [ x_line_0, ( x_line_0 + len_line ) ], $
        [ ( y_line_0 + 2.0 * y_line_1 ), ( y_line_0 + 2.0 * y_line_1 ) ], $
        psym=0, linestyle=0, thick=15.0, color=cgColor( 'BLK4' ), /normal 
    cgText, ( x_line_0 + len_line + sep_text ), $
        ( y_line_0 + 2.0 * y_line_1 - off_text ), $
        'Bootstrap Range', charsize=2.5, alignment=0, $
        /normal, color=cgColor( 'Black' ), charthick=9.0
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, /close 
    set_plot, mydevice
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; FIGURE 2 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start the second figure 
    mydevice = !d.name
    !p.font=0
    set_plot, 'ps'
    psxsize = 50 
    psysize = 22
    device, filename=plot_2, font_size=8.5, /encapsulated, $
        /color, /helvetica, /bold, xsize=psxsize, ysize=psysize 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; position of the plot
    position_0 = [ 0.08, 0.11, 0.99, 0.99 ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 1. Co-added spectra 
    cgPlot, wave, med_arr, xstyle=1, ystyle=1, position=position_0, $
        xrange=wave_range, yrange=flux_range_2, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $ 
        xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
        xticklen=0.03, yticklen=0.01 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the safe range 
    cgPlot, [ wave_safe0, wave_safe0 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    cgPlot, [ wave_safe1, wave_safe1 ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'GRN4' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the normalization range
    cgPlot, [ min_norm, min_norm ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'BLU3' )
    cgPlot, [ max_norm, max_norm ], !Y.Crange, /overplot, linestyle=5, $
        thick=5.0, color=cgColor( 'BLU3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /center_line, color_center='TAN5', $
            line_center=0
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Shade over the outer-fence region 
    cgColorFill, [ wave[ index_comf[0] ], wave[ index_comf ], $
        reverse( wave[ index_comf ] ) ], $
        [lofen[ index_comf[0] ], lofen[ index_comf ], $
        reverse( uofen[ index_comf ] ) ], color=cgColor( 'BLK3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Shade over the inner-fence region 
    cgColorFill, [ wave[ index_comf[0] ], wave[ index_comf ], $
        reverse( wave[ index_comf ] ) ], $
        [lifen[ index_comf[0] ], lifen[ index_comf ], $
        reverse( uifen[ index_comf ] ) ], color=cgColor( 'BLU3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Shade over the lower-upper quartile region 
    cgColorFill, [ wave[ index_comf[0] ], wave[ index_comf ], $
        reverse( wave[ index_comf ] ) ], $
        [lquar[ index_comf[0] ], lquar[ index_comf ], $
        reverse( uquar[ index_comf ] ) ], color=cgColor( 'RED3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Shade over the bootstrap region 
    cgColorFill, [ wave[ index_comf[0] ], wave[ index_comf ], $
        reverse( wave[ index_comf ] ) ], $
        [ med_min[ index_comf[0] ], med_min[ index_comf ], $
        reverse( med_max[ index_comf ] ) ], color=cgColor( 'GRN3' )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The median combined spectrum
    cgPlot, wave, med_arr, linestyle=0, thick=3.0, /overplot, $ 
        color=cgColor( 'Blue' ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overplot interesting index 
    if ( list_find EQ 1 ) then begin 
        hs_spec_index_over, index_list, /label_over, /no_fill, /no_line, $
            xstep=38, ystep=38, charsize=1.4
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave, med_arr, xstyle=1, ystyle=1, position=position_0, $
        xrange=wave_range, yrange=flux_range_2, /noerase, /nodata, $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $ 
        xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
        xticklen=0.03, yticklen=0.01 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, /close 
    set_plot, mydevice
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

; + 
; NAME:
;              HS_COADD_SDSS_ROBUST
;
; PURPOSE:
;              Get the Robust-averaged mean for a list of prepared SDSS spectra 
;
; USAGE:
;    hs_coadd_sdss_robust, prep_file, hvdisp_home=hvdisp_home, $
;        /plot, /error, /save_fits, niter=niter, nevec=nevec, $
;        blue_cut=blue_cut, red_cut=red_cut 
; OUTPUT: 
;    output = { wave:wave, new_wave:new_wave, $
;        mean_flux:pca_mean, evectors:pca_evectors, $
;        evalues:pca_eval, variances:pca_vars, $
;        final_nuse:final_nuse, final_frac:final_frac, $
;        final_mask:final_mask, final_s2nr:final_s2nr }
;
; AUTHOR:
;             Song Huang
; TODO: 
;    1. Repeat the VWPCA to get error ?
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;             Song Huang, 2014/06/18 - Minor improvements, add MIN_WAVE_HARD, 
;                                      MAX_WAVE_HARD keywords
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_coadd_sdss_robust, prep_file, plot=plot, error=error, $
    niter=niter, nevec=nevec, save_fits=save_fits, $
    blue_cut=blue_cut, red_cut=red_cut, hvdisp_home=hvdisp_home, $ 
    n_repeat=n_repeat, test_str=test_str, $ 
    min_wave_hard=min_wave_hard, max_wave_hard=max_wave_hard

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_indexlis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Wavelength cut at both blue and red end 
    if keyword_set( blue_cut ) then begin 
        edge0 = float( blue_cut )
    endif else begin 
        edge0 = 10.0 
    endelse
    if keyword_set( red_cut ) then begin 
        edge1 = float( red_cut )
    endif else begin 
        edge1 = 10.0 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( n_repeat ) then begin 
        n_repeat = long( n_repeat ) 
    endif else begin 
        n_repeat = 100 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; check the input file 
    prep_file = strcompress( prep_file, /remove_all ) 
    if NOT file_test( prep_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input file: ' + prep_file + '!!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        struc = mrdfits( prep_file, 1, header, status=status, /silent )
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the prepare file :' + prep_file + ' !' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin 
            n_spec = struc.n_spec
            wave = struc.wave
            flux = struc.flux_norm 
            serr = struc.serr_norm 
            ;; Useful value for output 
            final_nuse = struc.nused 
            final_frac = struc.frac 
            final_mask = struc.final_mask 
            final_s2nr = struc.final_snr
            ;; replace the NaN values 
            index_nan = where( ( finite( flux ) EQ 0 ), n_nan )
            if ( index_nan[0] NE -1 ) then begin 
                flux[ index_nan ] = 0.00 
                serr[ index_nan ] = 0.00 
            endif
            ;; Trim the data 
            min_wave = min( wave )
            max_wave = max( wave )
            if keyword_set( min_wave_hard ) then begin 
                min_wave_hard = float( min_wave_hard ) 
            endif else begin 
                min_wave_hard = min_wave 
            endelse
            if keyword_set( max_wave_hard ) then begin 
                max_wave_hard = float( max_wave_hard ) 
            endif else begin 
                max_wave_hard = max_wave 
            endelse
            new_min_wave = ( min_wave + edge0 ) > min_wave_hard
            new_max_wave = ( max_wave - edge1 ) < max_wave_hard
            index_use = where( ( wave GE new_min_wave ) AND $
                ( wave LE new_max_wave ) )
            if ( index_use[0] NE -1 ) then begin 
                new_wave = wave[ index_use ]
                flux = flux[ index_use, * ]
                serr = serr[ index_use, * ]
            endif else begin 
                new_wave = wave 
            endelse
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Prefix string for output and plot 
    temp = strsplit( prep_file, './', /extract ) 
    prefix = temp[ n_elements( temp ) - 2 ]
    strreplace, prefix, '_prep', ''
    loc_input = loc_coadd + prefix + '/' 
    if ( dir_exist( loc_input ) NE 1 ) then begin 
        print, ' XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the directory for ' + prefix + ' !!!'
        print, ' XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the output file 
    if keyword_set( test_str ) then begin 
        test_str = strcompress( test_str, /remove_all ) 
        prefix   = prefix + '_' + test_str 
    endif
    pca_output  = loc_input + prefix + '_robust.fits'
    ;; Name of the plot 
    pca_figure1 = loc_input + prefix + '_robust.eps'
    pca_figure2 = loc_input + prefix + '_robust_comp.eps'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The parameters structure for personalisation of the robust or EMPCA 
    params = { niter:0, nevec:0, nobj_init:0.0, delta:0.0, memory:0.0 }
    ;; Number of iterations 
    if keyword_set( niter ) then begin 
        params.niter = fix( niter ) 
    endif else begin 
        params.niter = 5 
    endelse
    ;; Number of PCA components to evaluate 
    if keyword_set( nevec ) then begin 
        params.nevec = fix( nevec ) 
    endif else begin 
        params.nevec = 10
    endelse
    ;; Number of objects to use in initialisation of PCA
    params.nobj_init = min( [ ( n_spec / 10.0 ), 200 ] ) < n_spec 
    ;; Control parameter for robustness (smaller=remove more outliers)
    params.delta = 0.5D 
    ;; Control parameter for convergence 
    ;;(larger=remember past; 1 = remember one iteration of dataset)
    params.memory = 1D 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Derive the mean spectra and PCA components using the Robust PCA method
    if keyword_set( error ) then begin
        pca_evectors = vwpca( flux, 6, pca_vars, pca_pcs, pca_mean, pca_eval, $
            errarr=serr, params=params, /robust ) 
    endif else begin 
        pca_evectors = vwpca( flux, 6, pca_vars, pca_pcs, pca_mean, pca_eval, $
            params=params, /robust ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; First plot 
    if keyword_set( plot ) then begin 

        psxsize = 50 
        psysize = 24 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=pca_figure1, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

        xrange = [ min_wave, max_wave ]
        yrange = [ ( min( pca_mean ) * 0.99 ), ( max( pca_mean ) * 1.20 ) ]
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_mean, xstyle=1, ystyle=1, $
            xthick=10.0, ythick=10.0, xrange=xrange, yrange=yrange, $
            xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
            position=[ 0.07, 0.12, 0.99, 0.99 ], thick=2.5, $
            charsize=3.5, charthick=9.5, xticklen=0.03, yticklen=0.01, $
            /noerase, /nodata
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;cgPlot, wave, low_mean, /overplot, thick=2.0, $
        ;    color=cgColor( 'Red' )
        ;cgPlot, wave, upp_mean, /overplot, thick=2.0, $
        ;    color=cgColor( 'Red' )
        cgPlot, new_wave, pca_mean, /overplot, thick=5.0, $
            color=cgColor( 'Black' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Label for index
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /label_only
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cgPlot, new_wave, pca_mean, xstyle=1, ystyle=1, $
            xthick=10.0, ythick=10.0, xrange=xrange, yrange=yrange, $
            xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
            position=[ 0.07, 0.12, 0.99, 0.99 ], thick=2.5, $
            charsize=3.5, charthick=9.5, xticklen=0.03, yticklen=0.01, $
            /noerase, /nodata

        device, /close 
        set_plot, mydevice 

    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Second plot 
    if keyword_set( plot ) then begin 

        psxsize = 32 
        psysize = 38 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=pca_figure2, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        pc1 = [ 0.10, 0.835, 0.99, 0.997 ]
        pc2 = [ 0.10, 0.688, 0.99, 0.835 ]
        pc3 = [ 0.10, 0.541, 0.99, 0.688 ]
        pc4 = [ 0.10, 0.394, 0.99, 0.541 ]
        pc5 = [ 0.10, 0.247, 0.99, 0.394 ]
        pc6 = [ 0.10, 0.100, 0.99, 0.247 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        min_x = min( new_wave ) 
        max_x = max( new_wave ) 
        sep_x = ( max_x - min_x )
        xrange = [ ( min_x - sep_x / 80 ), ( max_x + sep_x / 80 ) ]  
        index_check = where( ( new_wave GE ( min_wave + sep_x * 0.74 ) ) AND $
                             ( new_wave LE ( min_wave + sep_x * 0.80 ) ) )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        txt_x = 0.740 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PC 6
        min_y = min( pca_evectors[ *, 5 ] ) 
        max_y = max( pca_evectors[ *, 5 ] ) 
        sep_y = ( ( max_y - min_y ) / 4.0 )
        mid_y = ( ( max_y + min_y ) / 2.0 )
        yrange = [ ( min_y - sep_y ), ( max_y + sep_y ) ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,5], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc6, xthick=6.0, ythick=6.0, xrange=xrange, $
            charsize=2.5, charthick=6.0, xtitle='Wavelength (Angstrom)', $
            ytitle='PC6', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( median( pca_evectors[ index_check, 5 ] ) LT mid_y ) then begin 
            txt_y = pc6[ 3 ] - 0.025 
        endif else begin 
            txt_y = pc6[ 1 ] + 0.013 
        endelse
        cgText, txt_x, txt_y, $
            string( pca_eval[5], format='(F7.4)' ) + ' ' + $
            string( pca_vars[5], format='(F7.4)' ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,5], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc6, xthick=6.0, ythick=6.0, xrange=xrange, $
            charsize=2.5, charthick=6.0, xtitle='Wavelength (Angstrom)', $
            ytitle='PC6', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PC5
        min_y = min( pca_evectors[ *, 4 ] ) 
        max_y = max( pca_evectors[ *, 4 ] ) 
        sep_y = ( ( max_y - min_y ) / 4.0 )
        mid_y = ( ( max_y + min_y ) / 2.0 )
        yrange = [ ( min_y - sep_y ), ( max_y + sep_y ) ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,4], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc5, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC5', yminor=-1, $ 
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( median( pca_evectors[ index_check, 4 ] ) LT mid_y ) then begin 
            txt_y = pc5[ 3 ] - 0.025 
        endif else begin 
            txt_y = pc5[ 1 ] + 0.013 
        endelse
        cgText, txt_x, txt_y, $
            string( pca_eval[4], format='(F7.4)' ) + ' ' + $
            string( pca_vars[4], format='(F7.4)' ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,4], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc5, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC5', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PC4
        min_y = min( pca_evectors[ *, 3 ] ) 
        max_y = max( pca_evectors[ *, 3 ] ) 
        sep_y = ( ( max_y - min_y ) / 4.0 )
        mid_y = ( ( max_y + min_y ) / 2.0 )
        yrange = [ ( min_y - sep_y ), ( max_y + sep_y ) ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,3], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc4, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC4', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( median( pca_evectors[ index_check, 3 ] ) LT mid_y ) then begin 
            txt_y = pc4[ 3 ] - 0.025 
        endif else begin 
            txt_y = pc4[ 1 ] + 0.013 
        endelse
        cgText, txt_x, txt_y, $
            string( pca_eval[3], format='(F7.4)' ) + ' ' + $
            string( pca_vars[3], format='(F7.4)' ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,3], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc4, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC4', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PC3
        min_y = min( pca_evectors[ *, 2 ] ) 
        max_y = max( pca_evectors[ *, 2 ] ) 
        sep_y = ( ( max_y - min_y ) / 4.0 )
        mid_y = ( ( max_y + min_y ) / 2.0 )
        yrange = [ ( min_y - sep_y ), ( max_y + sep_y ) ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,2], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc3, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC3', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( median( pca_evectors[ index_check, 2 ] ) LT mid_y ) then begin 
            txt_y = pc3[ 3 ] - 0.025 
        endif else begin 
            txt_y = pc3[ 1 ] + 0.013 
        endelse
        cgText, txt_x, txt_y, $
            string( pca_eval[2], format='(F7.4)' ) + ' ' + $
            string( pca_vars[2], format='(F7.4)' ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,2], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc3, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC3', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PC2
        min_y = min( pca_evectors[ *, 1 ] ) 
        max_y = max( pca_evectors[ *, 1 ] ) 
        sep_y = ( ( max_y - min_y ) / 4.0 )
        mid_y = ( ( max_y + min_y ) / 2.0 )
        yrange = [ ( min_y - sep_y ), ( max_y + sep_y ) ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,1], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc2, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC2', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( median( pca_evectors[ index_check, 1 ] ) LT mid_y ) then begin 
            txt_y = pc2[ 3 ] - 0.025 
        endif else begin 
            txt_y = pc2[ 1 ] + 0.013 
        endelse
        cgText, txt_x, txt_y, $
            string( pca_eval[1], format='(F7.4)' ) + ' ' + $
            string( pca_vars[1], format='(F7.4)' ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,1], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc2, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC2', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; PC1
        min_y = min( pca_evectors[ *, 0 ] ) 
        max_y = max( pca_evectors[ *, 0 ] ) 
        sep_y = ( ( max_y - min_y ) / 4.0 )
        mid_y = ( ( max_y + min_y ) / 2.0 )
        yrange = [ ( min_y - sep_y ), ( max_y + sep_y * 2.65 ) ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,0], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc1, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC1', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line, $
            line_center=2, color_center='TAN5'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( median( pca_evectors[ index_check, 0 ] ) LT mid_y ) then begin 
            txt_y = pc1[ 3 ] - 0.045 
        endif else begin 
            txt_y = pc1[ 1 ] + 0.013 
        endelse
        cgText, txt_x, txt_y, $
            string( pca_eval[0], format='(F7.4)' ) + ' ' + $
            string( pca_vars[0], format='(F7.4)' ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Label for index
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /label_only, $
            charsize=1.1, ystep=26
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, new_wave, pca_evectors[*,0], xstyle=1, ystyle=1, yrange=yrange, $
            position=pc1, xthick=6.0, ythick=6.0, xrange=xrange,  $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC1', yminor=-1, $
            /noerase, xticklen=0.08, yticklen=0.01, thick=2.5
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        device, /close 
        set_plot, mydevice 

    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Make the output structure 
    output = { wave:wave, new_wave:new_wave, $
        mean_flux:pca_mean, evectors:pca_evectors, $
        evalues:pca_eval, variances:pca_vars, $
        final_nuse:final_nuse, final_frac:final_frac, $
        final_mask:final_mask, final_s2nr:final_s2nr }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( save_fits ) then begin 
        mwrfits, output, pca_output, /create, /silent
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    return, output 
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

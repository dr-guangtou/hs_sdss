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
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_coadd_sdss_robust, prep_file, plot=plot, error=error, $
    niter=niter, nevec=nevec, save_fits=save_fits, $
    blue_cut=blue_cut, red_cut=red_cut, hvdisp_home=hvdisp_home, $ 
    n_repeat=n_repeat, test_str=test_str

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
            index_use = where( ( wave GE ( min_wave + edge0 ) ) AND $
                ( wave LE ( max_wave - edge1 ) ) )
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
        
        cgPlot, new_wave, pca_mean, xstyle=1, ystyle=1, $
            xthick=10.0, ythick=10.0, xrange=xrange, yrange=yrange, $
            xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
            position=[ 0.07, 0.12, 0.99, 0.99 ], thick=2.5, $
            charsize=3.5, charthick=9.5, xticklen=0.03, yticklen=0.01, $
            /noerase, /nodata

        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line

        ;cgPlot, wave, low_mean, /overplot, thick=2.0, $
        ;    color=cgColor( 'Red' )
        ;cgPlot, wave, upp_mean, /overplot, thick=2.0, $
        ;    color=cgColor( 'Red' )
        cgPlot, new_wave, pca_mean, /overplot, thick=3.5, color=cgColor( 'Black' )

        ;; Label for index
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /label_only

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

        psxsize = 30 
        psysize = 30 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=pca_figure2, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
        
        ;; PC 6
        yrange = [ ( min( pca_evectors[*,5] ) * 0.99 ), $
                   ( max( pca_evectors[*,5] ) * 1.05 ) ]
        cgPlot, new_wave, pca_evectors[*,5], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.100, 0.99, 0.247 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtitle='Wavelength (Angstrom)', $
            ytitle='PC6', $
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line
        cgText, 0.650, 0.222, $
            string( pca_eval[5] ) + ' ' + string( pca_vars[5] ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        cgPlot, new_wave, pca_evectors[*,5], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.100, 0.99, 0.247 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtitle='Wavelength (Angstrom)', $
            ytitle='PC6', $
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; PC5
        yrange = [ ( min( pca_evectors[*,4] ) * 0.99 ), $
                   ( max( pca_evectors[*,4] ) * 1.05 ) ]
        cgPlot, new_wave, pca_evectors[*,4], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.247, 0.99, 0.394 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC5', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line
        cgText, 0.650, 0.369, $
            string( pca_eval[4] ) + ' ' + string( pca_vars[4] ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        cgPlot, new_wave, pca_evectors[*,4], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.247, 0.99, 0.394 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC5', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; PC4
        yrange = [ ( min( pca_evectors[*,3] ) * 0.99 ), $
                   ( max( pca_evectors[*,3] ) * 1.05 ) ]
        cgPlot, new_wave, pca_evectors[*,3], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.394, 0.99, 0.541 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC4', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line
        cgText, 0.650, 0.516, $
            string( pca_eval[3] ) + ' ' + string( pca_vars[3] ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        cgPlot, new_wave, pca_evectors[*,3], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.394, 0.99, 0.541 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC4', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; PC3
        yrange = [ ( min( pca_evectors[*,2] ) * 0.99 ), $
                   ( max( pca_evectors[*,2] ) * 1.05 ) ]
        cgPlot, new_wave, pca_evectors[*,2], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.541, 0.99, 0.688 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC3', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line
        cgText, 0.650, 0.663, $
            string( pca_eval[2] ) + ' ' + string( pca_vars[2] ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        cgPlot, new_wave, pca_evectors[*,2], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.541, 0.99, 0.688 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC3', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; PC2
        yrange = [ ( min( pca_evectors[*,1] ) * 0.99 ), $
                   ( max( pca_evectors[*,1] ) * 1.05 ) ]
        cgPlot, new_wave, pca_evectors[*,1], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.688, 0.99, 0.835 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC2', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line
        cgText, 0.650, 0.810, $
            string( pca_eval[1] ) + ' ' + string( pca_vars[1] ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        cgPlot, new_wave, pca_evectors[*,1], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.688, 0.99, 0.835 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC2', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; PC1
        yrange = [ ( min( pca_evectors[*,0] ) * 0.99 ), $
                   ( max( pca_evectors[*,0] ) * 1.50 ) ]
        cgPlot, new_wave, pca_evectors[*,0], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.835, 0.99, 0.982 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC1', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5
        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line
        cgText, 0.650, 0.957, $
            string( pca_eval[0] ) + ' ' + string( pca_vars[0] ), /normal, $
            charsize=2.5, charthick=6.0, alignment=0
        ;; Label for index
        cgPlot, new_wave, pca_evectors[*,0], xstyle=1, ystyle=1, yrange=yrange, $
            position=[ 0.10, 0.835, 0.99, 0.982 ], xthick=6.0, ythick=6.0, $
            charsize=2.5, charthick=6.0, xtickformat='(A1)', $
            ytitle='PC1', $ 
            /noerase, xticklen=0.04, yticklen=0.01, thick=2.5

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

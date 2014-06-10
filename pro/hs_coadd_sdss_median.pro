; + 
; NAME:
;              HS_COADD_SDSS_MEDIAN
;
; PURPOSE:
;              Median-combinine a list of prepared SDSS spectra 
;
; USAGE:
;    hs_coadd_sdss_boot, prep_file, hvdisp_home=hvdisp_home, $
;        /plot, /save_fits, /save_all 
; OUTPUT: 
;    output = { wave:wave, med_boot:fltarr( n_pix ), $
;        avg_boot:fltarr( n_pix ), sig_boot:fltarr( n_pix ), $
;        min_boot:fltarr( n_pix ), max_boot:fltarr( n_pix ), $ 
;        final_nuse:final_nuse, final_frac:final_frac, $
;        final_mask:final_mask, final_s2nr:final_s2nr }
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_coadd_sdss_median, prep_file, n_boot=n_boot, $
    hvdisp_home=hvdisp_home, plot=plot, save_fits=save_fits, save_all=save_all 

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
            print, ' Something wrong with the prepare file :' + prep_file 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin 
            n_spec = struc.n_spec
            n_pix  = struc.n_pix
            wave   = struc.wave
            flux   = struc.flux_norm
            mask   = struc.mask 
            ;; Useful value for output 
            final_nuse = struc.nused 
            final_frac = struc.frac 
            final_mask = struc.final_mask 
            final_s2nr = struc.final_snr
            ;; Make all masked pixel NaN 
            index_mask = where( mask GT 0.0 ) 
            if ( index_mask[0] NE -1 ) then begin 
                flux[ index_mask ] = !VALUES.F_NaN
            endif
        endelse
    endelse
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
    boot_output = loc_input + prefix + '_median.fits'
    boot_outall = loc_input + prefix + '_median_all.fits'
    ;; Name of the plot 
    boot_figure = loc_input + prefix + '_median.eps'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Number of bootstrap resample 
    if keyword_set( n_boot ) then begin 
        n_boot = fix( n_boot ) 
    endif else begin 
        n_boot = 2000 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the randomly selected sample 
    index_boot = hs_bootstrap_index( n_spec, n_boot ) 
    ;; Array for bootstap median results 
    median_boot = fltarr( n_pix, n_boot )
    ;; define the output structure 
    output = { wave:wave, med_boot:fltarr( n_pix ), $
        avg_boot:fltarr( n_pix ), sig_boot:fltarr( n_pix ), $
        min_boot:fltarr( n_pix ), max_boot:fltarr( n_pix ), $ 
        final_nuse:final_nuse, final_frac:final_frac, $
        final_mask:final_mask, final_s2nr:final_s2nr }
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Iteration 
    for ii = 0, ( n_boot - 1 ), 1 do begin 
        median_boot[ *, ii ] = median( flux[ *, index_boot[ *, ii ] ], $
            dimension=2, /even )
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the final output 
    ;; Median flux 
    output.med_boot = median( median_boot, dimension=2, /even )
    ;; Mean and Sigma 
    resistant_mean, median_boot, 5.0, avg_boot, sig_boot, $
        dimension=2, /double, /silent 
    output.avg_boot = avg_boot 
    output.sig_boot = sig_boot 
    ;; Min and Max 
    output.min_boot = min( median_boot, dimension=2 )
    output.max_boot = max( median_boot, dimension=2 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Make the plot
    if keyword_set( plot ) then begin 

        psxsize = 50 
        psysize = 24 
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=boot_figure, font_size=9.0, /encapsulated, $
            /color, /helvetica, /bold, xsize=psxsize, ysize=psysize

        yrange = [ ( min( output.min_boot ) * 0.99 ), $
            ( max( output.max_boot ) * 1.20 ) ]

        cgPlot, wave, output.med_boot, xstyle=1, ystyle=1, $
            xthick=10.0, ythick=10.0, $
            xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
            position=[ 0.07, 0.12, 0.99, 0.99 ], thick=2.5, yrange=yrange, $
            charsize=3.5, charthick=9.5, xticklen=0.03, yticklen=0.01, $
            /noerase, /nodata

        ;; Overplot interesting index 
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /center_line

        cgPlot, wave, output.min_boot, /overplot, thick=2.0, $
            color=cgColor( 'Dark Gray' )
        cgPlot, wave, output.max_boot, /overplot, thick=2.0, $
            color=cgColor( 'Dark Gray' )
        cgPlot, wave, ( output.avg_boot - output.sig_boot ), /overplot, $
            thick=2.0, color=cgColor( 'Orange' )
        cgPlot, wave, ( output.avg_boot + output.sig_boot ), /overplot, $
            thick=2.0, color=cgColor( 'Orange' )
        cgPlot, wave, output.avg_boot, /overplot, thick=2.5, $
            color=cgColor( 'Red' )
        cgPlot, wave, output.med_boot, /overplot, thick=2.0, $
            color=cgColor( 'Blue' )

        ;; Label for index
        hs_spec_index_over, loc_indexlis + 'hs_index_plot.lis', /label_only

        cgPlot, wave, output.med_boot, xstyle=1, ystyle=1, $
            xthick=10.0, ythick=10.0, $
            xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
            position=[ 0.07, 0.12, 0.99, 0.99 ], thick=2.5, yrange=yrange, $
            charsize=3.5, charthick=9.5, xticklen=0.03, yticklen=0.01, $
            /noerase, /nodata

        device, /close 
        set_plot, mydevice 
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( save_fits ) then begin 
        mwrfits, output, boot_output, /create, /silent
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( save_all ) then begin 
        all_struc = { wave:wave, spec_boot:median_boot, $
            final_nuse:final_nuse, final_frac:final_frac, $
            final_mask:final_mask, final_s2nr:final_s2nr }
        mwrfits, all_struc, boot_outall, /create, /silent 
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    return, output
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

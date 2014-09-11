function hs_spec_polynorm, wave, spec, n_poly, $
    mask=mask, plot=plot, norm0=norm0, norm1=norm1, $
    find_peak=find_peak, n_pos=n_pos, n_neg=n_neg, eps_name=eps_name, $ 
    medwidth=medwidth, smoothing=smoothing, prefix=prefix, $ 
    save_fits=save_fits, index_plot=index_plot, robust=robust 
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 11.10, 2013
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on_error, 2
compile_opt idl2

if N_params() lt 3 then begin 
    print,  'Syntax - hs_spec_polynorm, wave, spec, n_poly, mask=mask, $'
    print,  '            norm0 = norm0, norm1=norm1, $' 
    print,  '            find_peak=find_peak, n_pos=n_pos, n_neg=n_neg '
    return, -1 
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ___ _   _ ____  _   _ _____   ;;
;;  |_ _| \ | |  _ \| | | |_   _|  ;;
;;   | ||  \| | |_) | | | | | |    ;;
;;   | || |\  |  __/| |_| | | |    ;;
;;  |___|_| \_|_|    \___/  |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check the number of pixels in Wavelength and flux array
n_pixel_wave = n_elements( wave ) 
n_pixel_spec = n_elements( spec ) 
if ( n_pixel_wave NE n_pixel_spec ) then begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, ' The WAVE and SPEC array should have the same number of elements '
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    return, -1 
endif else begin 
    min_wave = min( wave ) 
    max_wave = max( wave ) 
    wave_range = [ min_wave, max_wave ]
    wave_sep   = fix( max_wave - min_wave )
    ;; Normalize the spectrum first
    spec = ( spec / max( spec ) ) 
    min_spec = min( spec ) 
    max_spec = max( spec ) 
    spec_sep = ( max_spec - min_spec )
    flux = spec
endelse

;; Order of the polynomial function
n_poly = long( n_poly ) 
if ( n_poly GT 6 ) then begin 
    print, '#############################################################'
    print, ' BE CAREFUL ! The order of the polynomial is very LARGE !  '
    print, '#############################################################'
endif 

;; 
index_default = 'hs_index_plot.lis' 
if NOT file_test( index_default ) then begin 
    print, 'Can not find the default index_plot.lis file !!'
    default_find = 0
endif else begin 
    index_default = index_default 
    default_find = 1
endelse
if keyword_set( index_plot ) then begin 
    index_plot = strcompress( index_plot, /remove_all )
    if NOT file_test( index_plot ) then begin 
        if ( default_find EQ 1 ) then begin 
            index_plot = index_default 
        endif else begin 
            index_plot = '' 
        endelse
    endif 
endif else begin 
    if ( default_find EQ 1 ) then begin 
        index_plot = index_default 
    endif else begin 
        index_plot = ''
    endelse
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   _  _________   ____        _____  ____  ____  ____    ;;
;;  | |/ / ____\ \ / /\ \      / / _ \|  _ \|  _ \/ ___|   ;;
;;  | ' /|  _|  \ V /  \ \ /\ / / | | | |_) | | | \___ \   ;;
;;  | . \| |___  | |    \ V  V /| |_| |  _ <| |_| |___) |  ;;
;;  |_|\_\_____| |_|     \_/\_/  \___/|_| \_\____/|____/   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mask Array 
if ( n_elements( mask ) NE 0 ) then begin 
    n_pixel_mask = n_elements( mask ) 
    if ( n_pixel_mask NE n_pixel_wave ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The pixel number of MASK is not the same with WAVE ! '
        print, '   Replace it with an empty array '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        mask = fltarr( n_pixel_wave ) 
    endif else begin 
        mask = mask 
    endelse
endif else begin 
    mask = fltarr( n_pixel_wave ) 
endelse

;; Wavelength for normalization
if keyword_set( norm0 ) then begin 
    norm0 = norm0 > min_wave 
endif else begin 
    norm0 = ( min_wave + 1.0 )
endelse
if keyword_set( norm1 ) then begin 
    norm1 = norm1 < max_wave 
endif else begin 
    norm1 = ( max_wave + 1.0 )
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____    _  _____  _      ____  ____  _____ ____   _    ____  _____   ;;
;;  |  _ \  / \|_   _|/ \    |  _ \|  _ \| ____|  _ \ / \  |  _ \| ____|  ;;
;;  | | | |/ _ \ | | / _ \   | |_) | |_) |  _| | |_) / _ \ | |_) |  _|    ;;
;;  | |_| / ___ \| |/ ___ \  |  __/|  _ <| |___|  __/ ___ \|  _ <| |___   ;;
;;  |____/_/   \_\_/_/   \_\ |_|   |_| \_\_____|_| /_/   \_\_| \_\_____|  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Good pixels
index_good = where( mask EQ 0 ) 
if ( index_good[0] EQ -1 ) then begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
    print, ' Something wrong with the spectrum, too little good pixels !!!X'
    return, -1 
endif else begin 
    n_good = n_elements( index_good ) 
endelse

;; First smooth the spectrum using median box-car smoothing method 
if keyword_set( medwidth ) then begin 
    medwidth = float( medwidth ) 
endif else begin 
    medwidth = fix( wave_sep / 25 ) 
endelse
if keyword_set( smoothing ) then begin 
    smoothing = float( smoothing ) 
endif else begin 
    smoothing = ( fix( wave_sep / 80 ) < ( n_good - 1L ) )
endelse

;; Adopted from im_fitcontinuum 
;; Median box-car smoothing 
temp = smooth( djs_median( flux[ index_good ], width=medwidth ), smoothing, $
    /edge_truncate )
med_continuum = interpol( temp, wave[ index_good ], wave )
med_normflux  = ( flux / med_continuum )

;; B-Spline fitting to continuum 
xwidth  = smoothing
boxstat = 'MAX' 
bsorder = ( fix( wave_sep / 500.0 ) > 5 ) 
bkpt_res = ( wave_sep / bsorder )
bkpt     = findgen( bsorder ) * bkpt_res + min_wave 
cont     = dkboxstats( flux[ index_good ], xwidth=xwidth, boxstat=boxstat ) 
sset     = bspline_iterfit( wave[ index_good ], flux[ index_good ], bkpt=bkpt, $
              yfit=yfit, nord=4, lower=0.1, upper=0.1, /silent ) 
bsp_continuum = bspline_valu( wave, sset ) 
bsp_normflux  = ( flux / bsp_continuum )

;; Isolate the part inside the normalization window
index_poly = where( ( wave GE norm0 ) AND ( wave LE norm1 ) AND $
    ( mask EQ 0 ) )
if ( index_poly[0] NE -1 ) then begin 
    wave_good = wave[ index_poly ]
    flux_good = flux[ index_poly ] 
    norm_good = med_normflux[ index_poly ]
    mask_good = ( wave_good * 0L ) 
    min_wave_good = min( wave_good )
    max_wave_good = max( wave_good )
    sep_wave_good = ( max_wave_good - min_wave_good )
    n_pixel_good = n_elements( wave_good ) 
endif else begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, '  Something wrong with the normalization range !! '
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    return, -1 
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   _____ ___ _   _ ____    ____  _____    _    _  __  ;;
;;  |  ___|_ _| \ | |  _ \  |  _ \| ____|  / \  | |/ /  ;;
;;  | |_   | ||  \| | | | | | |_) |  _|   / _ \ | ' /   ;;
;;  |  _|  | || |\  | |_| | |  __/| |___ / ___ \| . \   ;;
;;  |_|   |___|_| \_|____/  |_|   |_____/_/   \_\_|\_\  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define the number of emission and absorption lines to be found 
if keyword_set( find_peak ) then begin 
    ;; Positive peaks 
    if keyword_set( n_pos ) then begin 
        n_pos = ( round( n_pos ) > 1L ) 
    endif else begin 
        n_seg = round( sep_wave_good / 400 ) 
        if ( n_seg LE 1 ) then begin 
            n_pos = 1 
        endif else begin 
            n_pos = ( 1 * n_seg )
        endelse 
    endelse 
    ;; Negative peaks
    if keyword_set( n_neg ) then begin 
        n_neg = ( round( n_neg ) > 1L ) 
    endif else begin 
        n_seg = round( sep_wave_good / 300 ) 
        if ( n_seg LE 1 ) then begin 
            n_neg = 3 
        endif else begin 
            n_neg = ( 3 * n_seg )
        endelse 
    endelse 
    ;; width and smooth scale for the positive and negative peaks 
    ;; # TODO: How to choose these parameters wisely
    w_pos = 20 
    s_pos = 20 
    w_neg = 25 
    s_neg = 25 
    ;; Find positive peaks 
    pos_peaks = find_npeaks( norm_good, wave_good, nfind=n_pos, width=w_pos, $
      minsep=60 )
    ;; Find negative peaks 
    norm_reve = ( -1.0 * ( norm_good + min( -1.0 * norm_good ) ) )
    neg_peaks = find_npeaks( norm_reve, wave_good, nfind=n_neg, width=w_neg, $
      minsep=60 )
    ;; Mask out the positive and negative peaks
    mask_p = mask_good 
    mask_n = mask_good 
    if ( pos_peaks[0] NE -1 ) then begin 
        n_pos_peaks = n_elements( pos_peaks )
        for n = 0, ( n_pos_peaks - 1 ), 1 do begin 
            peak_center = pos_peaks[n] 
            peak_diff = abs( wave_good - peak_center ) 
            min_diff = min( peak_diff ) 
            peak_index = where( peak_diff EQ min_diff ) 
            mask_p[ peak_index ] = 1 
        endfor 
        mask_p = smooth( float( mask_p ), s_pos ) 
        mask_p[ where( mask_p GT 0.0 ) ] = 1 
        mask_good[ where( mask_p EQ 1 ) ] = 1L   
    endif else begin 
        mask_p = fltarr( n_pixel_good ) 
    endelse
    if ( neg_peaks[0] NE -1 ) then begin 
        n_neg_peaks = n_elements( neg_peaks )
        for n = 0, ( n_neg_peaks - 1 ), 1 do begin 
            peak_center = neg_peaks[n] 
            peak_diff = abs( wave_good - peak_center ) 
            min_diff = min( peak_diff ) 
            peak_index = where( peak_diff EQ min_diff ) 
            mask_n[ peak_index ] = 1 
        endfor 
        mask_n = smooth( float( mask_n ), s_neg ) 
        mask_n[ where( mask_n GT 0.0 ) ] = 1 
        mask_good[ where( mask_n EQ 1 ) ] = 1L   
    endif else begin 
        mask_n = fltarr( n_pixel_good ) 
    endelse
    ;; Mask out the pixels that affected by these peaks 
    index_mask_peaks = where( mask_good NE 1 ) 
    if ( index_mask_peaks[0] NE -1 ) then begin 
        wave_better = wave_good[ index_mask_peaks ]
        flux_better = flux_good[ index_mask_peaks ]
    endif else begin 
        wave_better = wave_good 
        flux_better = flux_good 
    endelse
endif else begin 
    wave_better = wave_good 
    flux_better = flux_good 
    n_pos = 0 
    n_neg = 0
endelse 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____   ___  _  __   __    _____ ___ _____   ;;
;;  |  _ \ / _ \| | \ \ / /   |  ___|_ _|_   _|  ;;
;;  | |_) | | | | |  \ V /____| |_   | |  | |    ;;
;;  |  __/| |_| | |___| |_____|  _|  | |  | |    ;;
;;  |_|    \___/|_____|_|     |_|   |___| |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Fit a n order polynormial to the rest region
if NOT keyword_set( robust ) then begin 
    result_poly = poly_fit( wave_better, flux_better, n_poly, /double )
endif else begin 
    result_poly = robust_poly_fit( wave_better, flux_better, n_poly, /double )
endelse
poly_component = findgen( n_pixel_wave, ( n_poly + 1 ) )
;; Build the pseudo continuum
poly_cont = findgen( n_pixel_wave )
for l=0L, ( n_poly ), 1 do begin 
    poly_component[*,l] = result_poly[l] * ( wave^float(l) )
endfor 
for l=0L, ( n_pixel_wave - 1 ), 1 do begin 
    poly_cont[l] = total( poly_component[l,*] ) 
endfor
;; Normalized the coadd spectrum with this continuum
spec_norm = ( spec / poly_cont ) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Plot 
if keyword_set( plot ) then begin 

    if keyword_set( eps_name ) then begin 
        eps_name = strcompress( eps_name, /remove_all ) 
    endif else begin 
        if keyword_set( prefix ) then begin 
            eps_name = strcompress( prefix, /remove_all ) + '_polynorm.eps'
        endif else begin 
            eps_name = 'poly_norm.eps'
        endelse
    endelse

    mydevice = !d.name 
    !p.font=0
    set_plot, 'ps' 
    psxsize=50 
    psysize=28 
    device, filename=eps_name, font_size=9.0, /encapsulated, $
        /color, /helvetica, /bold, xsize=psxsize, ysize=psysize

    index_norm = where( ( wave GE norm0 ) AND ( wave LE norm1 ) )
    if ( index_norm[0] EQ -1 ) then begin 
        print, ' Something wrong with the Wavelength Range !!!'
        return, -1
    endif
    ;; Wavelength range 
    wave_range = [ min_wave, max_wave ]
    ;; Flux range 
    min_flux = min( spec_norm[ index_norm ] - 0.15 ) < min( spec - 0.15 ) 
    max_flux = max( bsp_normflux[ index_good ] ) > max( med_normflux[ index_good ] )
    flux_sep = ( max_flux - min_flux )
    flux_range = [ ( min_flux - ( flux_sep / 40.0 ) ), $ 
                   ( max_flux + ( flux_sep / 8.0  ) ) ]

    cgPlot, wave, spec, xstyle=1, ystyle=1, $ 
        xrange=wave_range, yrange=flux_range, /nodata, /noerase, $
        xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $
        position=[ 0.08, 0.10, 0.99, 0.992 ]

    ;; Overplot interesting index 
    if ( index_plot NE '' ) then begin 
        hs_spec_index_over, index_plot, /center_line
    endif

    cgPlot, wave, ( poly_cont - 0.15 ), /overplot, linestyle=2, thick=5.0, $
        color=cgColor( 'GRN7' )
    cgPlot, wave, ( med_continuum - 0.15 ), /overplot, linestyle=4, thick=5.0, $
        color=cgColor( 'GRN5' )
    cgPlot, wave, ( bsp_continuum - 0.15 ), /overplot, linestyle=3, thick=5.0, $
        color=cgColor( 'GRN3' )
    cgPlot, wave, ( spec - 0.15 ), /overplot, linestyle=0, thick=5.0, $
        color=cgColor( 'Dark Gray' )
    cgPlot, wave_better, ( flux_better - 0.15 ), psym=1, symsize=0.5, /overplot, $
        color=cgColor( 'Orange' )
    cgPlot, wave, med_normflux, /overplot, linestyle=0, thick=4.0, $
        color=cgColor( 'BLU5' )
    cgPlot, wave, bsp_normflux, /overplot, linestyle=0, thick=4.0, $
        color=cgColor( 'BLU2' )
    cgPlot, wave[ index_norm ], spec_norm[ index_norm ], /overplot, thick=4.0, $
        color=cgColor( 'NAVY' )

    ;; The wavelength range of the polynomial fitting region
    cgPlot, [ norm0, norm0 ], !Y.CRange, linestyle=2, thick=9.0, $
        color=cgColor( 'RED5' ), /overplot
    cgPlot, [ norm1, norm1 ], !Y.CRange, linestyle=2, thick=9.0, $
        color=cgColor( 'RED5' ), /overplot

    ;; Label for index 
    if ( index_plot NE '' ) then begin 
        hs_spec_index_over, index_plot, /label_only
    endif 

    cgPlot, wave, spec, xstyle=1, ystyle=1, $ 
        xrange=wave_range, yrange=flux_range, /nodata, /noerase, $
        xtitle='Wavelength (Angstrom)', ytitle='Flux (Normalized)', $
        xthick=12.0, ythick=12.0, charsize=3.0, charthick=10.0, $
        position=[ 0.08, 0.10, 0.99, 0.992 ]

    device, /close
    set_plot, mydevice

endif 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the output structure 
output = { wave:wave, spec:spec, poly_cont:poly_cont, spec_norm:spec_norm, $ 
    med_cont:med_continuum, med_norm:med_normflux, $
    bsp_cont:bsp_continuum, bsp_norm:bsp_normflux, $
    wave_better:wave_better, spec_better:flux_better, $
    n_poly:n_poly, n_pos:n_pos, n_neg:n_neg, $
    medwidth:medwidth, medsmooth:smoothing, $
    min_norm:norm0, max_norm:norm1 }

;; Save the results into a fits structure 
if keyword_set( save_fits ) then begin 
    if keyword_set( prefix ) then begin 
        fits_file = strcompress( prefix, /remove_all ) + '_norm.fits' 
    endif else begin 
        fits_file = 'poly_norm.eps' 
    endelse
    mwrfits, output, fits_file, /create, /silent 
endif

;;
return, output

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro poly_test 

    struc = mrdfits( 'lowz_test_prepare_boot.fits', 1, /silent ) 
    wave = struc.wave 
    spec = struc.med_boot 
    mask = struc.final_mask 

    output = hs_spec_polynorm( wave, spec, 4, mask=mask, /plot, $
        eps_name='lowz_test_prepare_boot_polynorm.eps', $
        norm0=3700.0, norm1=8500.0, /find_peak, $
        /save_fits, prefix='lowz_test_prepare_boot', $
        medwidth=500.0, smoothing=300.0 ) ;;, n_pos=1, n_neg=10 )

    print, n_elements( output.poly_cont ) 
    print, n_elements( output.med_cont )
    print, n_elements( output.bsp_cont )

end

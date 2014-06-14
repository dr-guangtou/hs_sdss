pro hs_spec_polynorm, wave, spec, n_poly, $
  spec_norm, poly_cont, mask=mask, $
  min_norm=min_norm, max_norm=max_norm, $
  find_peak=find_peak, n_pos=n_pos, n_neg=n_neg 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on_error, 2
compile_opt idl2

if N_params() lt 5 then begin 
    print,  'Syntax - hs_spec_polynorm, wave, spec, n_poly, mask=mask, $'
    print,  '            min_norm = min_norm, max_norm=max_norm, $' 
    print,  '            find_peak=find_peak, n_pos=n_pos, n_neg=n_neg '
    return
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ___ _   _ ____  _   _ _____   ;;
;;  |_ _| \ | |  _ \| | | |_   _|  ;;
;;   | ||  \| | |_) | | | | | |    ;;
;;   | || |\  |  __/| |_| | | |    ;;
;;  |___|_| \_|_|    \___/  |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

n_pixel_wave = n_elements( wave ) 
n_pixel_spec = n_elements( spec ) 
if ( n_pixel_wave NE n_pixel_spec ) then begin 
  print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  print, ' The WAVE and SPEC array should have the same number of elements '
  print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  message, ' '
endif else begin 
  min_wave = min( wave ) 
  max_wave = max( wave ) 
  spec = ( spec / max( spec ) ) 
  min_spec = min( wave ) 
  max_spec = max( wave ) 
endelse

;; Order of the polynomial function
n_poly = long( n_poly ) 
if ( n_poly GT 7 ) then begin 
  print, '#############################################################'
  print, ' BE CAREFUL ! The order of the polynomial is very LARGE !  '
  print, '#############################################################'
endif 

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
if keyword_set( min_norm ) then begin 
  min_norm = min_norm > min_wave 
endif else begin 
  min_norm = ( min_wave + 1.0 )
endelse
if keyword_set( max_norm ) then begin 
  max_norm = max_norm > max_wave 
endif else begin 
  max_norm = ( max_wave + 1.0 )
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____    _  _____  _      ____  ____  _____ ____   _    ____  _____   ;;
;;  |  _ \  / \|_   _|/ \    |  _ \|  _ \| ____|  _ \ / \  |  _ \| ____|  ;;
;;  | | | |/ _ \ | | / _ \   | |_) | |_) |  _| | |_) / _ \ | |_) |  _|    ;;
;;  | |_| / ___ \| |/ ___ \  |  __/|  _ <| |___|  __/ ___ \|  _ <| |___   ;;
;;  |____/_/   \_\_/_/   \_\ |_|   |_| \_\_____|_| /_/   \_\_| \_\_____|  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

index_good = where( mask EQ 0 ) 
if ( index_good[0] NE -1 ) then begin 
    wave_temp = wave[ index_good ] 
    flux_temp = spec[ index_good ]
endif else begin 
    wave_temp = wave
    flux_temp = spec 
endelse

index_poly = where( ( wave_temp GE min_norm ) AND ( wave_temp LE max_norm ) )
if ( index_poly[0] NE -1 ) then begin 
  wave_good = wave_temp[ index_poly ]
  flux_good = flux_temp[ index_poly ] 
  mask_good = ( wave_good * 0L ) 
endif else begin 
  print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  print, '  Something wrong with the normalization range !! '
  print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  message, '  '
endelse

min_wave_good = min( wave_good )
max_wave_good = max( wave_good )
sep_wave_good = ( max_wave_good - min_wave_good )
n_pixel_good = n_elements( wave_good ) 

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
    n_seg = round( sep_wave_good / 40 ) 
    if ( n_seg LE 1 ) then begin 
      n_pos = 2 
    endif else begin 
      n_pos = ( 2 * n_seg )
    endelse 
  endelse 
  ;; Negative peaks
  if keyword_set( n_neg ) then begin 
    n_neg = ( round( n_neg ) > 1L ) 
  endif else begin 
    n_seg = round( sep_wave_good / 40 ) 
    if ( n_seg LE 1 ) then begin 
      n_neg = 2 
    endif else begin 
      n_neg = ( 2 * n_seg )
    endelse 
  endelse 
  ;; width and smooth scale for the positive and negative peaks 
  w_pos = 15 
  w_neg = 15 
  s_pos = 20 
  s_neg = 30 
  ;; Find positive peaks 
  pos_peaks = find_npeaks( flux_good, wave_good, nfind=n_pos, width=w_pos, $
    minsep=20 )
  ;; Find negative peaks 
  neg_peaks = find_npeaks( flux_good, wave_good, nfind=n_neg, width=w_neg, $
    minsep=15 )
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
endelse 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____   ___  _  __   __    _____ ___ _____   ;;
;;  |  _ \ / _ \| | \ \ / /   |  ___|_ _|_   _|  ;;
;;  | |_) | | | | |  \ V /____| |_   | |  | |    ;;
;;  |  __/| |_| | |___| |_____|  _|  | |  | |    ;;
;;  |_|    \___/|_____|_|     |_|   |___| |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Fit a n order polynormial to the rest region
result_poly = poly_fit( wave_better, flux_better, n_poly, /double )
poly_component = findgen( n_pixel_wave, ( n_poly + 1 ) )
poly_cont = findgen( n_pixel_wave )
for l=0L, ( n_poly ), 1 do begin 
    poly_component[*,l] = result_poly[l] * ( wave^float(l) )
endfor 
for l=0L, ( n_pixel_wave - 1 ), 1 do begin 
    poly_cont[l] = total( poly_component[l,*] ) 
endfor
;; Normalized the coadd spectrum with this continuum
spec_norm = ( spec / poly_cont ) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spec_norm = spec_norm 
poly_cont = poly_cont 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

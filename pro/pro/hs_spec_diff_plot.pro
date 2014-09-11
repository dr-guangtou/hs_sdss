pro hs_spec_diff_plot, spec_struc, $
    min_window=min_window, max_window=max_window, $
    eps_name=eps_name, png=png, $
    poly_norm=poly_norm, n_poly=n_poly, offset=offset, $
    psxsize=psxsize, psysize=psysize, $
    min_norm=min_norm, max_norm=max_norm, method_norm=method_norm, $
    feature_over=feature_over, feature_list=feature_list, $
    label_over=label_over, feature_file=feature_file, $ 
    num_ref=num_ref, save_diff=save_diff, $
    slabel_x=slabel_x, slabel_y=slabel_y, slsize=slsize
    
on_error, 2
compile_opt idl2

if N_params() lt 1 then begin 
    print,  'Syntax - HS_spec_diff_plot, spec_struc, ' 
    print,  '       min_window=min_window, max_window=max_window, '
    print,  '       index_plot=index_plot           '
    return
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                        _                  ;;
;;   _ __   __ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __ ___   ;;
;;  | '_ \ / _` | '__/ _` | '_ ` _ \ / _ \ __/ _ \ '__/ __|  ;;
;;  | |_) | (_| | | | (_| | | | | | |  __/ ||  __/ |  \__ \  ;;
;;  | .__/ \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  |___/  ;;
;;  |_|                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Parameters that control the offset for display
spec_off_factor = 1.2
diff_off_factor = 2.8
;; Parameters that control the blank area for display
spec_blank_factor = 20.0
diff_blank_factor = 40.0
;; Parameters that control the x/y step size  
x_step_factor = 50.0  
y_step_factor = 20.0
;; Position of each plots 
pos_1 = [ 0.11, 0.11, 0.95, 0.49 ] 
pos_2 = [ 0.11, 0.49, 0.95, 0.87 ]
;; Thickness of the axes 
xthick = 11.0 
ythick = 11.0
a_charsize  = 3.5 
a_charthick = 8.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  | | _____ _   ___      _____  _ __ __| |___   ;;
;;  | |/ / _ \ | | \ \ /\ / / _ \| '__/ _` / __|  ;;
;;  |   <  __/ |_| |\ V  V / (_) | | | (_| \__ \  ;;
;;  |_|\_\___|\__, | \_/\_/ \___/|_|  \__,_|___/  ;;
;;            |___/                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Files that contains the information of the spectral features
if ( n_elements( feature_file ) NE 0 ) then begin 
    feature_file = strcompress( feature_file, /remove_all ) 
endif else begin 
    feature_file = 'hs_sdss_feature.fits' 
endelse

;; Check the n_poly keyword 
if keyword_set( n_poly ) then begin 
    n_poly = long( n_poly ) 
endif else begin 
    n_poly = 2 
endelse

;; Check the name of the .eps file 
if keyword_set( eps_name ) then begin 
    eps_name = strcompress( eps_name, /remove_all ) 
    temp = strsplit( eps_name, '.', /extract )
    eps_string = strcompress( temp[0], /remove_all )
    if keyword_set( png ) then begin 
        png_name = eps_string + '.png' 
    endif 
endif else begin 
    eps_name = 'output.eps' 
    if keyword_set( png ) then begin 
        png_name = 'output.png'
    endif 
endelse

;; PS plot size 
if keyword_set( psxsize ) then begin 
    psxsize = float( psxisze ) 
endif else begin 
    psxsize = 44
endelse
if keyword_set( psysize ) then begin 
    psysize = float( psyisze ) 
endif else begin 
    psysize = 28
endelse
;; Color List 
;color_list = [ 'Red', 'Blue', 'Dark Green', 'Orange', $
;    'Brown', 'Salmon', 'Sea Green', 'Green Yellow', $
;    'Gold', 'Pink', 'Maroon', 'Lavender', 'Pale Green' ]
color_list = [ 'Black', 'Red', 'Navy', 'Dark Green', 'Brown', 'Orange', $
    'Maroon', 'Gold', 'Sea Green', 'Green Yellow', 'Pale Green' ] 

;; Method for normalization 
if keyword_set( method_norm ) then begin 
    method_norm = strcompress( method_norm, /remove_all ) 
    case method_norm of 
        "max"    : norm_code = 0 
        "median" : norm_code = 1
        "poly"   : norm_code = 2 
        "linfit" : norm_code = 3 
        "none"   : norm_code = 4 
        else: begin 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            print, ' The available options for normalizations are: ' 
            print, ' MAX, MEDIAN, POLY, LINFIT                     '
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            message, ' ' 
        end 
    endcase
endif else begin 
    norm_code = 0 
endelse

;; Parameters that control the position of the spectral label
if keyword_set( slabel_x ) then begin 
    slabel_x_factor = float( slabel_x ) 
endif else begin 
    slabel_x_factor = 4.2
endelse
if keyword_set( slabel_y ) then begin 
    slabel_y_factor = float( slabel_y ) 
endif else begin 
    slabel_y_factor = -3.0
endelse
if keyword_set( slsize ) then begin 
    slabel_charsize = float( slsize )
endif else begin 
    slabel_charsize = 2.3
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   _                   _     ;;
;;  (_)_ __  _ __  _   _| |_   ;;
;;  | | '_ \| '_ \| | | | __|  ;;
;;  | | | | | |_) | |_| | |_   ;;
;;  |_|_| |_| .__/ \__,_|\__|  ;;
;;          |_|                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check the structure 
;; TAG: Index
status = tag_exist( spec_struc, 'index', /quiet )
if ( status NE 1 ) then begin 
    print, '############################################################'
    print, '   Can not find tag: INDEX in the structure, Check!!    '
    print, '############################################################'
    message, '  '
endif else begin 
    n_spec = n_elements( spec_struc.index ) 
    if ( ( n_spec mod 2 ) EQ 0 ) then begin 
        temp_ref = ( n_spec / 2 ) - 1  
    endif else begin 
        temp_ref = ( ( n_spec + 1 ) / 2 ) 
    endelse
    if keyword_set( num_ref ) then begin 
        if ( num_ref LE n_spec ) then begin 
            index_ref = ( num_ref - 1 ) 
        endif else begin 
            print, '###########################################################'
            print, '  Be careful, the reference number is larger than the '
            print, '     number of spectra used in comparison !  '
            print, '###########################################################'
            index_ref = temp_ref 
        endelse
    endif else begin  
        index_ref = temp_ref 
    endelse
endelse
;; TAG: Wave
status = tag_exist( spec_struc, 'wave', /quiet )
if ( status NE 1 ) then begin 
    print, '############################################################'
    print, '   Can not find tag: WAVE in the structure, Check!!    '
    print, '############################################################'
    message, '  '
endif else begin 
    n_pixel_wave = n_elements( spec_struc[0].wave ) 
    wave_array = spec_struc[0].wave 
    min_wave = min( wave_array )
    max_wave = max( wave_array )
endelse
;; TAG: Flux 
status = tag_exist( spec_struc, 'flux', /quiet )
if ( status NE 1 ) then begin 
    print, '############################################################'
    print, '   Can not find tag: FLUX in the structure, Check!!    '
    print, '############################################################'
    message, '  '
endif else begin 
    n_pixel_flux = n_elements( spec_struc[0].flux ) 
    if ( n_pixel_flux NE n_pixel_wave ) then begin 
        print, '###############################################################'
        print, '  The WAVE and FLUX array should have same number of pixels!   '
        print, '###############################################################'
        message, '  '
    endif
endelse
;; TAG: Mask 
status = tag_exist( spec_struc, 'mask', /quiet )
if ( status NE 1 ) then begin 
    print, '############################################################'
    print, '   Can not find tag: MASK in the structure, Check!!    '
    print, '############################################################'
    message, '  '
endif else begin 
    n_pixel_mask = n_elements( spec_struc[0].mask ) 
    if ( n_pixel_mask NE n_pixel_wave ) then begin 
        print, '###############################################################'
        print, '  The WAVE and MASK array should have same number of pixels!   '
        print, '###############################################################'
        message, '  '
    endif
endelse
;; TAG: ERR_FRAC 
status = tag_exist( spec_struc, 'err_frac', /quiet )
if ( status NE 1 ) then begin 
    print, '############################################################'
    print, '   Can not find tag: ERR_FRAC in the structure, Check!!    '
    print, '############################################################'
    message, '  '
endif else begin 
    n_pixel_frac = n_elements( spec_struc[0].err_frac ) 
    if ( n_pixel_frac NE n_pixel_wave ) then begin 
        print, '###############################################################'
        print, '  The WAVE and ERR_FRAC array should have same number of pixels!   '
        print, '###############################################################'
        message, '  '
    endif
endelse
;; TAG: line_color 
status = tag_exist( spec_struc, 'line_color', /quiet )
if ( status NE 1 ) then begin 
    print, '############################################################'
    print, '   Can not find tag: line_color in the structure, Check!!    '
    print, '############################################################'
    message, '  '
endif 
;; XXX For FUTURE
;; TAG: smin 
;status = tag_exist( spec_struc, 'smin', /quiet )
;if ( status NE 1 ) then begin 
;    print, '############################################################'
;    print, '   Can not find tag: smin in the structure, Check!!    '
;    print, '############################################################'
;    message, '  '
;endif else begin 
;endelse
;;; TAG: smax 
;status = tag_exist( spec_struc, 'smax', /quiet )
;if ( status NE 1 ) then begin 
;    print, '############################################################'
;    print, '   Can not find tag: smax in the structure, Check!!    '
;    print, '############################################################'
;    message, '  '
;endif else begin 
;endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                           _                  _   _       ;;
;;  __      ____ ___   _____| | ___ _ __   __ _| |_| |__    ;;
;;  \ \ /\ / / _` \ \ / / _ \ |/ _ \ '_ \ / _` | __| '_ \   ;;
;;   \ V  V / (_| |\ V /  __/ |  __/ | | | (_| | |_| | | |  ;;
;;    \_/\_/ \__,_| \_/ \___|_|\___|_| |_|\__, |\__|_| |_|  ;;
;;                                        |___/             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check the input wavelength window keywords 
if keyword_set( min_window ) then begin 
    min_window = float( min_window ) 
endif else begin 
    min_window = min_wave 
endelse
if keyword_set( max_window ) then begin 
    max_window = float( max_window ) 
endif else begin 
    max_window = max_wave 
endelse
;; Set up the window for display
if ( ( min_window GE max_wave ) OR ( max_window LE min_wave ) ) then begin 
    print, '#######################################################'
    print, '   Check the wavelength window for display !   '
    print, '#######################################################'
    message, ' ' 
endif 
index_window = where( ( wave_array GE min_window ) AND $
    ( wave_array LE max_window ) ) 
if ( index_window[0] EQ -1 ) then begin 
    print, '#######################################################'
    print, '  Funny, something wrong about the wavelength window ! '
    print, '#######################################################' 
    message, '  '
endif else begin 
    n_pixel_window = n_elements( index_window )
    wave_range = [ min_window, max_window ]
endelse 

;; Set up the wavelength range for normalization 
norm_sep = 5 
if keyword_set( min_norm ) then begin 
    min_norm = float( min_norm ) 
    if ( min_norm lt min_window ) then begin 
        min_norm = ( min_window + norm_sep )
        print, '####################################################'
        print, ' MIN_NORM should be larger than MIN_WINDOW ! '
        print, '   Use MIN_WINDOW as MIN_NORM instead     '
        print, '####################################################'
    endif else begin 
        if ( min_norm GE max_window ) then begin 
            print, '###################################################'
            print, ' MIN_NORM can not be larger than MAX_WINDOW !  ' 
            print, '###################################################' 
            message, ' ' 
        endif
    endelse
endif else begin 
    min_norm = ( min_window + norm_sep )  
    max_norm = ( max_window - norm_sep )
endelse
if NOT keyword_set( max_norm ) then begin 
    if keyword_set( min_norm ) then begin 
        max_norm = ( max_window - norm_sep )
        print, '##################################################'
        print, '  You should provide both MIN_NORM and MAX_NORM ! '
        print, '##################################################'
    endif 
    max_norm = ( max_window - norm_sep ) 
endif else begin 
    max_norm = float( max_norm ) 
    if ( max_norm gt max_window ) then begin 
        max_norm = ( max_window - norm_sep )
        print, '###################################################' 
        print, ' MAX_NORM should be smaller than MAX_WINDOW !  '
        print, '   Use MAX_WINDOW as MAX_NORM instead          '
        print, '###################################################'
    endif else begin 
        if ( max_norm le min_window ) then begin 
            print, '##################################################' 
            print, ' MAX_NORM can not be smaller than the MIN_NORM !  '
            print, '##################################################'
            message, ' ' 
        endif 
    endelse
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       _       _                                                ;;
;;    __| | __ _| |_ __ _   _ __  _ __ ___ _ __   __ _ _ __ ___   ;;
;;   / _` |/ _` | __/ _` | | '_ \| '__/ _ \ '_ \ / _` | '__/ _ \  ;;
;;  | (_| | (_| | || (_| | | |_) | | |  __/ |_) | (_| | | |  __/  ;;
;;   \__,_|\__,_|\__\__,_| | .__/|_|  \___| .__/ \__,_|_|  \___|  ;;
;;                         |_|            |_|                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Set up the array to plot
;; Array for spectra: 
wave_arr = fltarr( n_pixel_window )
spec_arr = fltarr( n_pixel_window, n_spec ) 
errf_arr = fltarr( n_pixel_window, n_spec )
diff_arr = fltarr( n_pixel_window, n_spec ) 
;; XXX FUTURE USE
;smin_arr = fltarr( n_pixel_window, n_spec )
;smax_arr = fltarr( n_pixel_window, n_spec )

;; For the flux array
for j = 0, ( n_spec - 1 ), 1 do begin 
     
    ;; Input data 
    spec_index = spec_struc[j].index  
    wave_temp  = spec_struc[j].wave
    flux_temp  = spec_struc[j].flux
    mask_temp  = spec_struc[j].mask
    errf_temp  = spec_struc[j].err_frac
    ;smin_temp = spec_struc[j].smin
    ;smax_temp = spec_struc[j].smax

    ;; Mask out the bad pixels 
    index_nan = where( mask_temp GT 0 )
    if ( index_nan[0] NE -1 ) then begin 
       flux_temp[ index_nan ] = !VALUES.F_NAN 
       wave_temp[ index_nan ] = !VALUES.F_NAN 
       errf_temp[ index_nan ] = !VALUES.F_NAN 
       ;smin_temp[ index_nan ] = !VALUES.F_NAN
       ;smax_temp[ index_nan ] = !VALUES.F_NAN
    endif 

    ;; Normalize the spectrum using the selected method 
    min_norm = ( min_norm > ( min_window + norm_sep ) )
    max_norm = ( max_norm < ( max_window - norm_sep ) ) 
    case norm_code of  
        0 : index_norm = where( ( wave_temp GE min_norm ) AND $
            ( wave_temp LE max_norm ) ) 
        1 : index_norm = where( ( wave_temp GE min_norm ) AND $
            ( wave_temp LE max_norm ) ) 
        2 : index_norm = where( ( wave_temp GE min_norm ) AND $
            ( wave_temp LE max_norm ) ) 
        3 : begin 
            n_l = [ ( min_norm - norm_sep ), ( min_norm + norm_sep ) ]
            n_r = [ ( max_norm - norm_sep ), ( max_norm + norm_sep ) ]
            index_l = where( ( wave_temp GE n_l[0] ) AND $
                ( wave_temp LE n_l[1] ) )
            if ( index_l[0] EQ -1 ) then begin 
                print, '######################################################'
                print, ' Something wrong with the left normalization window '
                print, n_l
                print, '######################################################'
                message, ' '
            endif
            index_r = where( ( wave_temp GE n_r[0] ) AND $
                ( wave_temp LE n_r[1] ) )
            if ( index_r[0] EQ -1 ) then begin 
                print, '######################################################'
                print, ' Something wrong with the right normalization window '
                print, n_r
                print, '######################################################'
                message, ' '
            endif
            index_norm = [ index_l, index_r ]
            end 
        4 : index_norm = where( ( wave_temp GE min_norm ) AND $
            ( wave_temp LE max_norm ) )
    endcase
    if ( index_norm[0] EQ -1 ) then begin 
        print, '###################################################' 
        print, ' Something wrong with the normalization window !   '
        print, '###################################################' 
        message, ' '
    endif

    ;; Normalize the spectrum using the maximum value
    if ( norm_code eq 0 ) then begin 
        flux_norm = flux_temp[ index_norm ]
        flux_norm = max( flux_norm ) 
        flux_temp = ( flux_temp / flux_norm )
    endif  

    ;; Normalize the spectrum using the median value 
    if ( norm_code eq 1 ) then begin 
        flux_norm = flux_temp[ index_norm ]
        flux_norm = median( flux_norm ) 
        flux_temp = ( flux_temp / flux_norm )
    endif

    ;; Normalize the spectrum using polynomial
    if ( norm_code eq 2 ) then begin 
        wave_norm = wave_temp[ index_norm ]
        flux_norm = flux_temp[ index_norm ]
        result_poly = poly_fit( wave_norm, flux_norm, n_poly, /double )
        poly_component = findgen( n_pixel_window, ( n_poly + 1 ) )
        continuum_poly = findgen( n_pixel_window )
        for l=0L, ( n_poly ), 1 do begin 
            poly_component[*,l] = result_poly[l] * ( wave_array^float(l) )
        endfor 
        for l=0L, ( n_pixel_window - 1 ), 1 do begin 
            continuum_poly[l] = total( poly_component[l,*] ) 
        endfor
        ;; Normalized the coadd spectrum with this continuum
        flux_poly = ( flux_temp / continuum_poly ) 
        flux_temp = flux_poly 
    endif 

    ;; Normalized the spectrum using linear-fit between the two windows 
    if ( norm_code eq 3 ) then begin 
        wave_norm = wave_temp[ index_norm ]
        flux_norm = flux_temp[ index_norm ]
        lin_result = linfit( wave_norm, flux_norm ) 
        continuum_lin = lin_result[0] + lin_result[1] * wave_temp 
        flux_temp = ( flux_temp / continuum_lin )
    endif 

    ;; Save the data in arrays
    wave_arr = wave_temp[ index_window ]
    spec_arr[ *, j ] = flux_temp[ index_window ]
    errf_arr[ *, j ] = errf_temp[ index_window ]
endfor 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        _       _                                           ;;
;;  _ __ | | ___ | |_   _ __  _ __ ___ _ __   __ _ _ __ ___   ;;
;; | '_ \| |/ _ \| __| | '_ \| '__/ _ \ '_ \ / _` | '__/ _ \  ;;
;; | |_) | | (_) | |_  | |_) | | |  __/ |_) | (_| | | |  __/  ;;
;; | .__/|_|\___/ \__| | .__/|_|  \___| .__/ \__,_|_|  \___|  ;;
;; |_|                 |_|            |_|                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Offset the spectra for display 
if keyword_set( offset ) then begin 
    min_flux = min( spec_arr )
    max_flux = max( spec_arr )
    spec_offset = ( ( max_flux - min_flux ) / spec_off_factor ) 
    ;; Only for sanity check 
    ;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    ;print, ' spec ', min_flux, max_flux, spec_offset
    ;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif else begin 
    spec_offset = 0.0
endelse
spec_new = spec_arr
for j = 0, ( n_spec - 1 ), 1 do begin 
    spec_new[*,j] = spec_arr[*,j] - ( j * spec_offset ) 
endfor

;; Define the display range for spectra 
min_spec = min( spec_new ) 
max_spec = max( spec_new )
spec_blank = ( ( max_spec - min_spec ) / spec_blank_factor ) 
spec_range = [ ( min_spec - ( 1.1 * spec_blank ) ), $
    ( max_spec + ( 1.1 * spec_blank ) ) ]

;; For the difference array 
spec_ref = spec_arr[ *, index_ref ]
for i = 0, ( n_spec - 1 ), 1 do begin 
    diff_arr[ *, i ] = ( ( spec_arr[ *, i ] / spec_ref ) - 1.0 ) * 100.0
endfor
;for k = 0, ( n_spec - 1 ), 1 do begin 
;    diff_arr[ *, k ] = ( ( spec_arr[ *, k ] / spec_arr[ *, index_ref ] ) $
;        - 1.0 ) * 100.0 
    ;; try something
    ;median_corr = median( diff_arr[ *, k ] ) 
    ;print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    ;print, (k+1), '  ', median_corr
    ;diff_arr[ *, k ] = diff_arr[ *, k ] - median_corr 
;endfor

;; Offset the differential spectra for display
if keyword_set( offset ) then begin 
    min_diff = min( diff_arr )
    max_diff = max( diff_arr ) 
    diff_offset = ( ( max_diff - min_diff ) / diff_off_factor ) 
endif else begin 
    diff_blank  = 0.6
    diff_offset = 0.000
endelse
;; 
diff_new = diff_arr
n_offset = 0
for k = 0, ( n_spec - 1 ), 1 do begin 
    if ( k NE index_ref ) then begin 
        diff_new[*,k] = diff_arr[*,k] - ( n_offset * diff_offset ) 
        n_offset = n_offset + 1 
    endif 
endfor

;; Change the difference level into %
;diff_arr = ( diff_arr * 100.0 )
errf_arr = ( errf_arr * 100.0 )

;; Define the display range for difference 
min_diff = min( diff_new ) 
max_diff = max( diff_new ) 
diff_blank = ( ( max_diff - min_diff ) / diff_blank_factor )  
diff_range = [ ( min_diff - diff_blank ), ( max_diff + diff_blank ) ]

;; For the wavelength array 
wave_array = wave_arr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          __            _                         ;;
;;   ___ _ __   ___  ___   / _| ___  __ _| |_ _   _ _ __ ___  ___   ;;
;;  / __| '_ \ / _ \/ __| | |_ / _ \/ _` | __| | | | '__/ _ \/ __|  ;;
;;  \__ \ |_) |  __/ (__  |  _|  __/ (_| | |_| |_| | | |  __/\__ \  ;;
;;  |___/ .__/ \___|\___| |_|  \___|\__,_|\__|\__,_|_|  \___||___/  ;;
;;      |_|                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Read in the index or emission line features to be highlighted 
feature_file = 'hs_sdss_feature.fits' 
if keyword_set( feature_over ) then begin 
    if NOT file_test( feature_file ) then begin 
        print, '##########################################################'
        print, ' Can not find the spectral feature list file:   ' 
        print, '  ' + feature_file + '           ' 
        print, '##########################################################'
        message, ' '
    endif else begin 
        features = mrdfits( feature_file, 1, status=status )
        if ( status ne 0 ) then begin 
            print, '########################################################'
            print, ' Something wrong with the feature_file file !!! '
            print, '########################################################' 
            message, ' ' 
        endif 
        n_features = n_elements( features.name )
        features_name = strcompress( features.name, /remove_all )
        ;; Sort these features according to their wavelength 
        wave_start = features.wave0
        index_wave_sort = sort( wave_start ) 
        features_sort = features[ index_wave_sort ]
        features = features_sort
        ;; select the features within the window 
        if ( n_elements( feature_list ) NE 0 ) then begin 
            name_list = strcompress( features.name, /remove_all )
            feature_list = strcompress( feature_list, /remove_all )
            n_flist = n_elements( feature_list ) 
            is_within = intarr( n_flist )
            for k = 0, ( n_flist - 1 ), 1 do begin 
                temp = where( name_list EQ feature_list[k] )
                if ( temp[0] EQ -1 ) then begin 
                    is_within[k] = 0L 
                endif else begin 
                    fwave0 = features[temp[0]].wave0
                    fwave1 = features[temp[0]].wave1
                    if ( ( fwave0 GE min_window ) AND ( fwave1 LE max_window ) ) $
                        then begin 
                        is_within[k] = temp[0] 
                    endif else begin 
                        is_within[k] = 0L 
                    endelse
                endelse
            endfor
            index_within = is_within[ where( is_within GT 0 ) ]
            if ( index_within[0] NE -1 ) then begin 
                n_within = n_elements( index_within ) 
                features_within = features[ index_within ]
            endif else begin 
                n_within = 0 
                features_within = features[0] 
            endelse
        endif else begin 
            index_within = where( ( features.wave0 GE min_window ) AND $
                ( features.wave1 LE max_window ) )
            if ( index_within[0] NE -1 ) then begin 
                n_within = n_elements( index_within )
                features_within = features[ index_within ]
            endif else begin 
                n_within = 0 
                features_within = features[ 0 ]
            endelse
        endelse
    endelse
endif else begin 
    features_within = '' 
endelse
;;;  
features = features_within

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   _                _       _         ;;
;;   _ __ ___   __ _| | _____   _ __ | | ___ | |_ ___   ;;
;;  | '_ ` _ \ / _` | |/ / _ \ | '_ \| |/ _ \| __/ __|  ;;
;;  | | | | | | (_| |   <  __/ | |_) | | (_) | |_\__ \  ;;
;;  |_| |_| |_|\__,_|_|\_\___| | .__/|_|\___/ \__|___/  ;;
;;                             |_|                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Set up the figure 
mydevice = !d.name 
!p.font = 0 
set_plot, 'PS' 
;; Start the plot 
device, filename=eps_name, font_size=8.5, /encapsulated, /color, /bold, $
    set_font='TIMES-ROMAN', xsize=psxsize, ysize=psysize
;; The spectra plot 
cgPlot, wave_array, spec_arr[*,0], xrange=wave_range, yrange=spec_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle='Flux (Normalized)', /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    position=pos_2, xtickformat="(A1)", xthick=xthick, ythick=ythick, $
    yticklen=0.015, xticklen=0.05, $
    xminor=5, yminor=5, /nodata, color=cgColor('Black')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                             __            _                         ;;
;;    _____   _____ _ __      / _| ___  __ _| |_ _   _ _ __ ___  ___   ;;
;;   / _ \ \ / / _ \ '__|____| |_ / _ \/ _` | __| | | | '__/ _ \/ __|  ;;
;;  | (_) \ V /  __/ | |_____|  _|  __/ (_| | |_| |_| | | |  __/\__ \  ;;
;;   \___/ \_/ \___|_|       |_|  \___|\__,_|\__|\__,_|_|  \___||___/  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; First put the highlighted features on the background: 
;; Define a small step size in data unit for fine tuning the plot 
x_step = ( ( wave_range[1] - wave_range[0] ) / x_step_factor )
y_step = ( ( spec_range[1] - spec_range[0] ) / x_step_factor )
;; Find the best location on X-axis for the label
wave_sep  = ceil( wave_range[1] - wave_range[0] )
x_binsize = floor( wave_sep / n_within )
l_pre_x1  = ( wave_range[0] - 0.5 * x_step ) 
;; Decide the charsize and the angle of the label
if ( n_within GE 25 ) then begin 
    l_charsize = 1.7 
    l_angle = 45.0
    l_align = 0
    x_start = ( wave_range[0] - 0.6 * x_step )
    y1_factor = 5.0
endif else begin
    if ( n_within LE 10 ) then begin 
        l_charsize = 3.0
        l_angle = 0.0
        l_align = 0.5 
        x_start = ( wave_range[0] + 1.6 * x_step ) 
        y1_factor = 1.6
    endif else begin 
        l_charsize = 2.0
        l_angle = 25.0
        l_align = 0.0
        x_start = ( wave_range[0] + 1.6 * x_step )
        y1_factor = 3.6
    endelse
endelse

if ( keyword_set( feature_over ) AND ( n_within NE 0 ) ) then begin 
    for j = 0, ( n_within - 1 ), 1 do begin 
        ;; decide the color of the lines around the features 
        if ( features[j].ind EQ 1 ) then begin 
            lcolor = 'Medium Gray' 
            tcolor = 'Black'
        endif 
        if ( features[j].abs EQ 1 ) then begin 
            lcolor = 'Tan' 
            tcolor = 'Red'
        endif 
        if ( features[j].emi EQ 1 ) then begin 
            lcolor = 'Goldenrod' 
            tcolor = 'Blue'
        endif 
        f_name = strcompress( features[j].name, /remove_all )
        f_lam0 = features[j].wave0
        f_lam1 = features[j].wave1
        y0 = spec_range[0] 
        y1 = spec_range[1]
        if ( features[j].ind EQ 1 ) then begin 
            polygon_x = [ f_lam0, f_lam1, f_lam1, f_lam0, f_lam0 ]
            polygon_y = [ y0, y0, y1, y1, y0 ]
            polyfill, polygon_x, polygon_y, /data, $
                color=cgColor( 'Wheat' ), linestyle=0, thick=3.0
        endif 
        cgPlot, [ f_lam0, f_lam0 ], !Y.Crange, psym=0, $
            linestyle=0, thick=3.5, $
            color=cgColor( lcolor ), /overplot
        cgPlot, [ f_lam1, f_lam1 ], !Y.Crange, psym=0, $
            linestyle=0, thick=3.5, $
            color=cgColor( lcolor ), /overplot
        ;; Put label on 
        if keyword_set( label_over ) then begin 
            l_pos_x0 = ( ( f_lam0 + f_lam1 ) / 2.0 ) 
            if ( n_within GE 10 ) then begin 
                l_pos_x1 = ( x_start + ( j * x_binsize ) )
            endif else begin 
                ;l_pos_x1 = ( l_pos_x0 - x_step )
                l_pos_x1 = l_pos_x0
                while ( ( l_pos_x1 - l_pre_x1 ) LE ( 2.3 * x_step ) ) do begin 
                    l_pos_x1 = l_pos_x1 + x_step 
                endwhile
                l_pre_x1 = l_pos_x1
            endelse
            l_pos_y0 = spec_range[1]
            l_pos_y1 = ( spec_range[1] + y1_factor * y_step )
            l_pos_xt = ( l_pos_x1 + 0.00 * x_step )
            l_pos_yt = ( l_pos_y1 + 0.50 * y_step )
            cgPlots, [ l_pos_x0, l_pos_x1], [ l_pos_y0, l_pos_y1], $
                linestyle=0, thick=2.5, $
                color=cgColor( tcolor ), /data 
            cgText, l_pos_xt, l_pos_yt, f_name, $
                charsize=l_charsize, alignment=l_align, charthick=11.0, $
                orientation=l_angle, color=cgColor( tcolor ), /data
        endif 
    endfor
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____  ____  _____ ____   ____  _     ___ _____   ;;
;;  / ___||  _ \| ____/ ___| |  _ \| |   / _ \_   _|  ;;
;;  \___ \| |_) |  _|| |     | |_) | |  | | | || |    ;;
;;   ___) |  __/| |__| |___  |  __/| |__| |_| || |    ;;
;;  |____/|_|   |_____\____| |_|   |_____\___/ |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Label the spectra 
x_label = ( wave_range[0] + slabel_x_factor * x_step )
;; Plot the spectra
for i = 0, ( n_spec - 1 ), 1 do begin  
    if ( i EQ index_ref ) then begin 
        lthick = 12.0
        lstyle = 2
    endif else begin 
        lstyle = 0
        lthick = 6.5 
    endelse
    if ( n_spec gt n_elements( color_list ) ) then begin
        loadct, 39
        cgPlot, wave_array, spec_new[*,i], linestyle=lstyle, thick=lthick, $
            /overplot, color=spec_struc[i].line_color 
    endif else begin 
        cgPlot, wave_array, spec_new[*,i], linestyle=lstyle, thick=lthick, $
            /overplot, color=cgColor( color_list[i] ) 
    endelse 
    ;; Y-location of the label 
    ind_temp = where( ( wave_array GE ( x_label - 2 ) ) AND $
        ( wave_array LE ( x_label + 2 ) ) ) 
    if ( ind_temp[0] NE -1 ) then begin 
        if NOT keyword_set( offset ) then begin 
            y_label = min( spec_new[ ind_temp, * ] ) + ( 0.1 * y_step ) - $
                ( i * ( 4.0 * y_step ) )
        endif else begin 
            y_label = min( spec_new[ ind_temp, i ] ) + ( 0.05 * y_step ) + $
                ( slabel_y_factor * y_step )
        endelse
        s_label = strcompress( spec_struc[i].comment, /remove_all ) 
        if NOT keyword_set( offset ) then begin 
            cgText, x_label, y_label, s_label, alignment=0, $
                charsize=slabel_charsize, $
                charthick=5.0, /data, color=cgColor( color_list[i] ) 
        endif else begin 
            cgText, x_label, y_label, s_label, alignment=0, $
                charsize=slabel_charsize, $
                charthick=5.0, /data, color=cgColor( 'Black' ) 
        endelse
    endif else begin 
        print, '##############################################################' 
        print, '  Something wrong with the wavelength range ! Check ! '
        print, '##############################################################' 
        message, ' ' 
    endelse
endfor

;; Replot the axis again: 
cgPlot, wave_array, spec_arr[*,0], xrange=wave_range, yrange=spec_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle='Flux (Normalized)', /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    position=pos_2, xtickformat="(A1)", xthick=xthick, ythick=ythick, $
    yticklen=0.015, xticklen=0.05, $
    xminor=5, yminor=5, /nodata, color=cgColor('Black')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The plot of the difference 
cgPlot, wave_array, diff_arr[*,0], xrange=wave_range, yrange=diff_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle='Relative Diff. (%)', /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    xtitle='Wavelength (Angstrom)', $
    position=pos_1, xthick=xthick, ythick=ythick, $
    yticklen=0.015, xticklen=0.05, $
    xminor=5, yminor=5, /nodata, color=cgColor('Black') 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                             __            _                         ;;
;;    _____   _____ _ __      / _| ___  __ _| |_ _   _ _ __ ___  ___   ;;
;;   / _ \ \ / / _ \ '__|____| |_ / _ \/ _` | __| | | | '__/ _ \/ __|  ;;
;;  | (_) \ V /  __/ | |_____|  _|  __/ (_| | |_| |_| | | |  __/\__ \  ;;
;;   \___/ \_/ \___|_|       |_|  \___|\__,_|\__|\__,_|_|  \___||___/  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; First put the highlighted features on the background: 
;; Define a small step size in data unit for fine tuning the plot 
x_step = ( ( wave_range[1] - wave_range[0] ) / x_step_factor )
y_step = ( ( diff_range[1] - diff_range[0] ) / y_step_factor )
l_pre_x1 = ( wave_range[0] - 0.5 * x_step ) 

if ( keyword_set( feature_over ) AND ( n_within NE 0 ) ) then begin 
    for j = 0, ( n_within - 1 ), 1 do begin 
        ;; decide the color of the lines around the features 
        if ( features[j].ind EQ 1 ) then begin 
            lcolor = 'Medium Gray' 
            tcolor = 'Black'
        endif 
        if ( features[j].abs EQ 1 ) then begin 
            lcolor = 'Tan' 
            tcolor = 'Red'
        endif 
        if ( features[j].emi EQ 1 ) then begin 
            lcolor = 'Goldenrod' 
            tcolor = 'Blue'
        endif 
        f_name = strcompress( features[j].name, /remove_all )
        f_lam0 = features[j].wave0
        f_lam1 = features[j].wave1
        y0 = diff_range[0] 
        y1 = diff_range[1]
        if ( features[j].ind EQ 1 ) then begin 
            polygon_x = [ f_lam0, f_lam1, f_lam1, f_lam0, f_lam0 ]
            polygon_y = [ y0, y0, y1, y1, y0 ]
            polyfill, polygon_x, polygon_y, /data, $
                color=cgColor( 'Wheat' ), linestyle=0, thick=3.0
        endif 
        cgPlot, [ f_lam0, f_lam0 ], !Y.Crange, psym=0, $
            linestyle=0, thick=3.5, $
            color=cgColor( lcolor ), /overplot
        cgPlot, [ f_lam1, f_lam1 ], !Y.Crange, psym=0, $
            linestyle=0, thick=3.5, $
            color=cgColor( lcolor ), /overplot
    endfor
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____ ___ _____ _____   ____  _     ___ _____   ;;
;;  |  _ \_ _|  ___|  ___| |  _ \| |   / _ \_   _|  ;;
;;  | | | | || |_  | |_    | |_) | |  | | | || |    ;;
;;  | |_| | ||  _| |  _|   |  __/| |__| |_| || |    ;;
;;  |____/___|_|   |_|     |_|   |_____\___/ |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The Fraction of the Error 
for i = 0, ( n_spec - 2 ), 1 do begin 
    zero_level = ( -1.0 * i * diff_offset )
    cgPlots, [ min_window, max_window ], [ zero_level, zero_level ], $
        linestyle=0, thick=4.5, color=cgColor( 'Black' )
    errf_1 = ( zero_level + (  1.0 * $
        SQRT( errf_arr[*,i]^2.0 + errf_arr[*,(i+1)]^2.0 ) ) )
    errf_2 = ( zero_level + ( -1.0 * $
        SQRT( errf_arr[*,i]^2.0 + errf_arr[*,(i+1)]^2.0 ) ) )
    cgPlot, wave_array, errf_1, linestyle=1, thick=3.0, $
        color=cgColor( 'Charcoal' ), /overplot
    cgPlot, wave_array, errf_2, linestyle=1, thick=3.0, $
        color=cgColor( 'Charcoal' ), /overplot
endfor
                                              
;; Plot the relative differece 
for i = 0, ( n_spec - 1 ), 1 do begin 
    if ( i NE index_ref ) then begin 
        if ( n_spec gt n_elements( color_list ) ) then begin
            loadct, 39
            cgPlot, wave_array, diff_new[*,i], linestyle=0, thick=4.5, /overplot, $
                color=spec_struc[i].line_color
        endif else begin 
            cgPlot, wave_array, diff_new[*,i], linestyle=0, thick=4.5, /overplot, $
                color=cgColor( color_list[i] ) 
        endelse 
    endif 
endfor

;; Plot the axes again 
cgPlot, wave_array, diff_arr[*,0], xrange=wave_range, yrange=diff_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle='Relative Diff. (%)', /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    xtitle='Wavelength (Angstrom)', $
    position=pos_1, xthick=xthick, ythick=ythick, $
    yticklen=0.015, xticklen=0.05, $
    xminor=5, yminor=5, /nodata, color=cgColor('Black') 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   _____       ____  _   _  ____   ;;
;;  |_   _|__   |  _ \| \ | |/ ___|  ;;
;;    | |/ _ \  | |_) |  \| | |  _   ;;
;;    | | (_) | |  __/| |\  | |_| |  ;;
;;    |_|\___/  |_|   |_| \_|\____|  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Convert the eps file into png format
if keyword_set( png ) then begin 
    if file_test( eps_name ) then begin 
        spawn, 'which convert', convert 
        if ( convert[0] eq '' ) then begin 
            print, '#########################################################'
            print, ' Can not find convert command from ImageMagick!   '
            print, '#########################################################'
        endif else begin 
            spawn, 'sleep 3s'
            spawn, convert + ' -density 200 ' + eps_name + $
                ' -quality 90 -flatten ' + png_name 
        endelse
    endif else begin 
        print, '###########################################################'
        print, ' Can not find the .eps file ! '
        print, '###########################################################'
    endelse 
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____    ___     _______   _____ ___ _     _____   ;;
;;  / ___|  / \ \   / / ____| |  ___|_ _| |   | ____|  ;;
;;  \___ \ / _ \ \ / /|  _|   | |_   | || |   |  _|    ;;
;;   ___) / ___ \ V / | |___  |  _|  | || |___| |___   ;;
;;  |____/_/   \_\_/  |_____| |_|   |___|_____|_____|  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                                 
if keyword_set( save_diff ) then begin 
    nspec_string = strcompress( string( n_spec ), /remove_all )
    norm_string = strcompress( method_norm, /remove_all )
    wave0_string = $
        strcompress( string( wave_range[0], format='(I6)' ), /remove_all ) 
    wave1_string = $
        strcompress( string( wave_range[1], format='(I6)' ), /remove_all ) 
    if keyword_set( eps_name ) then begin 
        diff_file = eps_string + '.csv'
    endif else begin 
        diff_file = 'output_diff_' + nspec_string + '_spec_' + $ 
            wave0_string + '_' + wave1_string + '_' + norm_string + '_norm.csv' 
    endelse
    openw, 10, diff_file, width=900 
    printf, 10, '## Results from hs_spec_diff_plot' 
    printf, 10, '# The number of spectra for comparison ' + nspec_string 
    printf, 10, '# The reference number is ' + $
        strcompress( string( index_ref + 1 ), /remove_all )  
    printf, 10, '# The method for normalization : ' + norm_string
    printf, 10, '# The index and comment of spectra: '
    for i = 0, ( n_spec - 1 ), 1 do begin 
        printf, 10, '#  ' + string( i + 1, format='(I3)' ) + ' : ' + $
            spec_struc[i].index + '   ' + spec_struc[i].comment  
    endfor  
    printf, 10, '####################################################'
    print_temp = strarr( n_pixel_window ) 
    for i = 0, ( n_pixel_window - 1 ), 1 do begin 
        print_temp[i] = string( wave_array[i], format='(F12.5)' ) + '  ,  '
        for j = 0, ( n_spec - 1 ), 1 do begin 
            print_temp[i] = print_temp[i] + $
                string( spec_new[ i, j ], format='(F12.5)' ) + '  ,  '
        endfor 
        for k = 0, ( n_spec - 1 ), 1 do begin 
            print_temp[i] = print_temp[i] + $ 
                string( diff_new[ i, k ], format='(F12.5)' ) 
            if ( k NE ( n_spec - 1 ) ) then begin 
                print_temp[i] = print_temp[i] + '  ,  ' 
            endif 
        endfor
        printf, 10, print_temp[i] 
    endfor
    close, 10
endif

device, /close 
set_plot, mydevice
;;;;

end 

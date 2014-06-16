; + 
; NAME:
;              HS_STARLIGHT_READ_OUTPUT
;
; PURPOSE:
;              Parse the output file of Starlight.V04 into IDL structures 
;
; USAGE:
;    hs_starlight_read_output, out_file, sl_struc, base_struc, spec_struc, $ 
;          /save_fits, /save_txt, /quiet, base_dir=base_dir, /is_fxk
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;             Song Huang, 2014/06/15 - Minor improvements; Remove AIC/BIC 
;-
; CATEGORY:    HS_STARLIGHT
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_starlight_plot_out, sl_output, index_list=index_list, $
    hvdisp_home=hvdisp_home,   base_vdisp=base_vdisp, $
    feature_over=feature_over, sig_over=sig_over, $
    zoomin=zoomin, window1=window1, window2=window2, window3=window3, $
    psxsize=psxsize, psysize=psysize, relative_res=relative_res, $
    include_mask_ori=include_mask_ori, exclude_mask_res=exclude_mask_res, $
    met_label=met_label, met_title=met_title, topng=topng

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Constant 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    met_sun       = 0.020
    use_threshold = 0.020
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sig_color_list = [ 'ORG7', 'TAN7', 'YGB7', 'TG5', 'GRN4', $
        'PUR4', 'BLK5', 'BLK3', 'BLK1' ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd  = hvdisp_home + 'coadd/'
    loc_index  = hvdisp_home + 'pro/lis/'
    loc_ancil  = hvdisp_home + 'pro/ancil/'
    loc_result = hvdisp_home + 'coadd/results/starlight/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;  ___ _   _ ____  _   _ _____ ;;
    ;; |_ _| \ | |  _ \| | | |_   _|;;
    ;;  | ||  \| | |_) | | | | | |  ;;
    ;;  | || |\  |  __/| |_| | | |  ;;
    ;; |___|_| \_|_|    \___/  |_|  ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check the input file 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( sl_output ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input file: ' + sl_output 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        temp       = strsplit( sl_output, '/', /extract )
        n_seg      = n_elements( temp ) 
        if ( n_seg EQ 1 ) then begin 
            loc_output = '' 
        endif else begin 
            loc_output = '/'
            for ii = 0, ( n_seg - 2 ), 1 do begin 
                loc_output = loc_output + temp[ ii ] + '/' 
            endfor 
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Name of the output file
        out_file   = temp[ n_seg - 1 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; String of the prefix of the output 
        temp       = strsplit( out_file, '.', /extract ) 
        out_string = strcompress( temp[0], /remove_all ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Name of the summary file 
        res_file   = loc_output + out_string + '.fits' 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if file_test( res_file ) then begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Read three structures from the result files 
            spec_struc = mrdfits( res_file, 1, status=status1, /silent )
            sl_struc   = mrdfits( res_file, 2, status=status2, /silent ) 
            base_struc = mrdfits( res_file, 3, status=status3, /silent )
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( ( status1 NE 0 ) OR ( status2 NE 0 ) OR ( status3 NE 0 ) ) $
                then begin  
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the result file: ' + sl_output 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        endif else begin 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; ---- If the summary file is not there, generate it ----
            hs_starlight_read_out, sl_output, sl_struc, base_struc, spec_struc, $
                /quiet, /save_fits, /save_txt 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        endelse 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the plot 
    plot_file = loc_output + out_string + '.eps'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the zoom-in window 
    if keyword_set( window1 ) then begin 
        if ( ( n_elements( window1 ) EQ 2 ) AND ( window1[0] LT window1[1] ) ) $
            then begin 
            wrange1 = [ window1[0], window1[1] ] 
        endif else begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The window parameter should have the following format: '
            print, '  WINDOW1/2/3 = [ WAVE_LOW, WAVE_UPP ]  '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endelse 
    endif else begin 
        wrange1 = [ 4101.0, 4449.0 ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( window2 ) then begin 
        if ( ( n_elements( window2 ) EQ 2 ) AND ( window2[0] LT window2[1] ) ) $
            then begin 
            wrange2 = [ window2[0], window2[1] ] 
        endif else begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The window parameter should have the following format: '
            print, '  window1/2/3 = [ WAVE_LOW, WAVE_UPP ]  '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endelse 
    endif else begin 
        wrange2 = [ 5001.0, 5449.0 ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( window3 ) then begin 
        if ( ( n_elements( window3 ) EQ 2 ) AND ( window3[0] LT window3[1] ) ) $
            then begin 
            wrange3 = [ window3[0], window3[1] ] 
        endif else begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The window parameter should have the following format: '
            print, '  window1/2/3 = [ WAVE_LOW, WAVE_UPP ]  '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endelse 
    endif else begin 
        wrange3 = [ 6801.0, 7399.0 ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ____  ____  _____ ____   _____ _____    _  _____ _   _ ____  _____ ____   ;;
;; / ___||  _ \| ____/ ___| |  ___| ____|  / \|_   _| | | |  _ \| ____/ ___|  ;;
;; \___ \| |_) |  _|| |     | |_  |  _|   / _ \ | | | | | | |_) |  _| \___ \  ;;
;;  ___) |  __/| |__| |___  |  _| | |___ / ___ \| | | |_| |  _ <| |___ ___) | ;;
;; |____/|_|   |_____\____| |_|   |_____/_/   \_\_|  \___/|_| \_\_____|____/  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Index to over-plot 
    if keyword_set( index_list ) then begin 
        index_list = loc_index + strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = loc_index + 'hs_index_plot.lis' 
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
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;  ____  ____  _____ ____   _    ____  _____   ____    _  _____  _    ;;
    ;; |  _ \|  _ \| ____|  _ \ / \  |  _ \| ____| |  _ \  / \|_   _|/ \   ;;
    ;; | |_) | |_) |  _| | |_) / _ \ | |_) |  _|   | | | |/ _ \ | | / _ \  ;;
    ;; |  __/|  _ <| |___|  __/ ___ \|  _ <| |___  | |_| / ___ \| |/ ___ \ ;;
    ;; |_|   |_| \_\_____|_| /_/   \_\_| \_\_____| |____/_/   \_\_/_/   \_\;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_base      = n_elements( base_struc.xj )
    xj_sum      = sl_struc.xj_sum 
    mini_sum    = total( base_struc.mini ) 
    mcor_sum    = total( base_struc.mcor )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; min and max value for different spectra
    min_lam     = min( spec_struc.spec_lam )
    max_lam     = max( spec_struc.spec_lam )
    min_obs     = min( spec_struc.spec_obs )
    max_obs     = max( spec_struc.spec_obs )
    min_syn     = min( spec_struc.spec_syn )
    max_syn     = max( spec_struc.spec_syn )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; pixel value at the wavelength for normalization for synthetic spectrum 
    l_base_norm = sl_struc.l_norm 
    index_lnorm = where( ( spec_struc.spec_lam GE ( l_base_norm - 2 ) ) AND $
        ( spec_struc.spec_lam LE ( l_base_norm + 2 ) ) ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( index_lnorm[0] EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something weird just happened!  Check!!  '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        spec_syn_norm = median( spec_struc[ index_lnorm ].spec_syn ) 
    endelse 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The number of useful SSPs 
    index_ssp_use = where( base_struc.ssp_use EQ 1 ) 
    if ( index_ssp_use[0] NE -1 ) then begin 
        n_ssp_use = n_elements( index_ssp_use ) 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, 'There are ', n_ssp_use, ' SSPs with >2% contribution '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' There is something wrong with this STARLIGHT run ! '
        print, ' There seems to be no SSP with more than 2% contribution' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endelse  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; The number of significant SSPs
    index_ssp_sig = where( base_struc.ssp_sig EQ 1 ) 
    if ( index_ssp_sig[0] NE -1 ) then begin 
        n_ssp_sig = n_elements( index_ssp_sig ) 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, 'There are ', n_ssp_sig, ' SSPs with >8% contribution '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Sort the base_struc according to the normalized contribution of each SSP 
    index_sort_ssp  = reverse( sort( base_struc.xj_norm ) )
    base_struc_sort = base_struc[ index_sort_ssp ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Identify the unique age and metallicity 
    index_uniq_age  = uniq( base_struc.age, sort( base_struc.age ) ) 
    index_uniq_met  = uniq( base_struc.metal, sort( base_struc.metal ) ) 
    ssp_age_arr     = base_struc[ index_uniq_age ].age
    ssp_met_arr     = base_struc[ index_uniq_met ].metal 
    n_uniq_age      = n_elements( index_uniq_age )
    n_uniq_met      = n_elements( index_uniq_met )
    age_log_arr     = alog10( ssp_age_arr ) 
    age_gyr_arr     = ( ssp_age_arr / 1.0D9 )
    age_ind_arr     = base_struc[ index_uniq_age ].age_index 
    age_str_arr     = base_struc[ index_uniq_age ].age_str
    met_sun_arr     = ( ssp_met_arr / met_sun ) 
    met_m2h_arr     = alog10( met_sun_arr )
    met_ind_arr     = base_struc[ index_uniq_met ].met_index 
    met_str_arr     = base_struc[ index_uniq_met ].met_str
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Summarize the contribution of xj_norm and m_cor for SSPs of the same 
    ;;   Age and Metallicity 
    flux_norm_age   = fltarr( n_uniq_age ) 
    flux_norm_met   = fltarr( n_uniq_met ) 
    mcor_norm_age   = fltarr( n_uniq_age ) 
    mcor_norm_met   = fltarr( n_uniq_met ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 1. For stellar ages 
    for i = 0, ( n_uniq_age - 1 ), 1 do begin 
        index_age = where( base_struc.age EQ ssp_age_arr[i] ) 
        if ( index_age[0] EQ -1 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something weird just happened!  Check again!! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            flux_norm_age[i] = total( base_struc[ index_age ].xj_norm )
            mcor_norm_age[i] = total( base_struc[ index_age ].mcor_norm )
        endelse 
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 2. For stellar metallicity 
    for i = 0, ( n_uniq_met - 1 ), 1 do begin 
        index_met = where( base_struc.metal EQ ssp_met_arr[i] ) 
        if ( index_met[0] EQ -1 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something weird just happened!  Check again!! '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            messmet, ' ' 
        endif else begin 
            flux_norm_met[i] = total( base_struc[ index_met ].xj_norm )
            mcor_norm_met[i] = total( base_struc[ index_met ].mcor_norm )
        endelse 
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Define the range for age and metallicity for plotting
    min_age   = min( age_log_arr )
    max_age   = max( age_log_arr )
    min_met   = min( met_m2h_arr )
    max_met   = max( met_m2h_arr )
    age_grid  = range( min_age, max_age, n_uniq_age ) 
    met_grid  = range( min_met, max_met, n_uniq_met )
    age_range = [ min_age * 0.8, max_age * 1.30 ]
    met_range = [ min_met * 0.5, max_met * 1.50 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the convolution kernel for the SSP spectra 
    if NOT keyword_set( base_vdisp ) then begin 
        base_vdisp = 65.0 ;; km/s 
    endif else begin 
        base_vdisp = float( base_vdisp ) 
    endelse 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    syn_vdisp = float( sl_struc.vd_min ) 
    if ( syn_vdisp LE base_vdisp ) then begin 
        vdisp_diff = 0.1 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' The synthetic spectrum has the same or smaller sigma '
        print, '   compared with the SSP models! Be careful ! '
        print, '            NO CONVOLUTION WILL BE APPLIED !!!                '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        vdisp_diff = SQRT( syn_vdisp^2.0 - base_vdisp^2.0 )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;   ____  _     ___ _____   ;;
    ;;  |  _ \| |   / _ \_   _|  ;;
    ;;  | |_) | |  | | | || |    ;;
    ;;  |  __/| |__| |_| || |    ;;
    ;;  |_|   |_____\___/ |_|    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; page size 
    if keyword_set( psxsize ) then begin 
        psxsize = float( psxsize ) 
    endif else begin 
        if keyword_set( zoomin ) then begin 
            psxsize=46 
        endif else begin 
            psxsize=46 
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( psysize ) then begin 
        psysize = float( psysize ) 
    endif else begin 
        if keyword_set( zoomin ) then begin 
            psysize=40 
        endif else begin 
            psysize=33 
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Start the actual plotting
    mydevice = !d.name 
    !p.font=1
    set_plot, 'ps' 
    device, filename=plot_file, font_size=9.0, /encapsulated, $
        /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( zoomin ) then begin 
        ;; position for the main spectral plot 
        position_1 = [ 0.070, 0.160, 0.995, 0.485 ]
        ;; position for the residual plot 
        position_2 = [ 0.070, 0.065, 0.995, 0.160 ]
        ;; position for three zoom-in window 
        position_3 = [ 0.070, 0.508, 0.360, 0.660 ]
        position_4 = [ 0.385, 0.508, 0.670, 0.660 ]
        position_5 = [ 0.695, 0.508, 0.995, 0.660 ]
        ;; position for information panel 
        position_6 = [ 0.070, 0.700, 0.360, 0.992 ]
        ;; position for the SFH plot
        position_7 = [ 0.425, 0.700, 0.710, 0.840 ]
        position_8 = [ 0.710, 0.700, 0.995, 0.840 ]
        position_9 = [ 0.425, 0.840, 0.710, 0.940 ]
        position_10= [ 0.710, 0.840, 0.995, 0.940 ]
    endif else begin 
        ;; position for the main spectral plot 
        position_1 = [ 0.070, 0.220, 0.995, 0.620 ]
        ;; position for the residual plot 
        position_2 = [ 0.070, 0.075, 0.995, 0.220 ]
        ;; position for information panel 
        position_6 = [ 0.070, 0.640, 0.360, 0.930 ]
        ;; position for the SFH plot
        position_7 = [ 0.425, 0.640, 0.710, 0.810 ]
        position_8 = [ 0.710, 0.640, 0.995, 0.810 ]
        position_9 = [ 0.425, 0.810, 0.710, 0.930 ]
        position_10= [ 0.710, 0.810, 0.995, 0.930 ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the array for spectral plot 
    wave       = spec_struc.spec_lam 
    mask       = spec_struc.final_mask 
    spec_obs   = spec_struc.spec_obs
    spec_syn   = spec_struc.spec_syn
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( relative_res ) then begin 
        spec_res = ( ( spec_struc.spec_res / spec_struc.spec_obs ) * 100.0 )
    endif else begin 
        spec_res = spec_struc.spec_res 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spec_wei   = spec_struc.spec_wei 
    pixel_mask = spec_struc.pixel_mask 
    pixel_flag = spec_struc.pixel_flag
    pixel_clip = spec_struc.pixel_clip
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Total flux for synthetic spectrum 
    flux_tot_syn = int_tabulated( wave, spec_syn, /double )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Remove the masked pixels from the synthetic spectrum
    index_final = where( mask GT 0 ) 
    wave_nan    = wave 
    obs_nan     = spec_obs 
    syn_nan     = spec_syn 
    res_nan     = spec_res 
    wei_nan     = spec_wei 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( index_final[0] NE -1 ) then begin 
        wave_nan[ index_final ] = !VALUES.F_NaN
        obs_nan[ index_final ]  = !VALUES.F_NaN
        syn_nan[ index_final ]  = !VALUES.F_NaN
        res_nan[ index_final ]  = !VALUES.F_NaN
        wei_nan[ index_final ]  = !VALUES.F_NaN
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( exclude_mask_res ) then begin 
        min_res = min( res_nan )
        max_res = max( res_nan )
        med_res = median( res_nan )
    endif else begin 
        min_res = min( spec_res )
        max_res = max( spec_res )
        med_res = median( spec_res )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Identify the problematic pixels 
    index_mask = where( pixel_mask EQ 1 )
    index_flag = where( pixel_flag EQ 1 )
    index_clip = where( pixel_clip EQ 1 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( index_mask[0] NE -1 ) then begin 
        wave_mask = wave[ index_mask ]
        res_mask = spec_res[ index_mask ] 
    endif else begin 
        wave_mask = [ 0.0 ]
        res_mask = [ !VALUES.F_NaN ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( index_clip[0] NE -1 ) then begin 
        wave_clip = wave[ index_clip ]
        res_clip = spec_res[ index_clip ] 
    endif else begin 
        wave_clip = [ 0.0 ]
        res_clip = [ !VALUES.F_NaN ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( index_flag[0] NE -1 ) then begin 
        wave_flag = wave[ index_flag ]
        res_flag = spec_res[ index_flag ] 
    endif else begin 
        wave_flag = [ 0.0 ]
        res_flag = [ !VALUES.F_NaN ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the plot range 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Wavelength range 
    wave_range = [ min_lam, max_lam ]  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Flux range 
    if keyword_set( include_mask_ori ) then begin 
        min_flux = min( spec_obs ) < min( spec_syn ) 
        max_flux = max( spec_obs ) > max( spec_syn )
    endif else begin 
        min_flux = min( obs_nan ) < min( syn_nan ) 
        max_flux = max( obs_nan ) > max( syn_nan )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    min_flux = min_flux < spec_syn_norm 
    sep_flux = ( ( max_flux - min_flux ) / 60.0 ) 
    if keyword_set( sig_over ) then begin 
        min_flux = min_flux - ( n_ssp_sig * sep_flux * 10.0 ) 
    endif 
    flux_range = [ min_flux, ( max_flux + 4.0 * sep_flux ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Make sure the zoomin windows are reasonabel 
    wrange1[0] = wrange1[0] > ( min_lam + 3.0 )
    wrange2[0] = wrange2[0] > ( min_lam + 3.0 )
    wrange3[0] = wrange3[0] > ( min_lam + 3.0 )
    wrange1[1] = wrange1[1] < ( max_lam - 3.0 )
    wrange2[1] = wrange2[1] < ( max_lam - 3.0 )
    wrange3[1] = wrange3[1] < ( max_lam - 3.0 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Residual range 
    sep_res  = ( ( max_res - min_res ) / 40.0 ) 
    if keyword_set( relative_res ) then begin 
        min_res = ( min_res - sep_res ) > ( -9.99 ) 
        max_res = ( max_res + sep_res ) < 9.99
        res_inter = ceil( ceil( ( max_res - min_res ) / 0.51 ) / 4.0 ) * 0.5
    endif else begin 
        min_res = ( min_res - sep_res ) > ( -0.299 ) 
        max_res = ( max_res + sep_res ) < 0.299 
        res_inter = ceil( ceil( ( max_res - min_res ) / 0.051 ) / 4.0 ) * 0.05
    endelse
    res_range  = [ min_res, max_res ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Plot the observed and synthetic spectra
    cgPlot, wave, spec_obs, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Dark Gray' ), thick=3.0, charsize=3.0, $
        ytitle='Flux (Normalized)', charthick=8.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, yminor=5, $
        xtickformat="(A1)", /nodata, xrange=wave_range, yrange=flux_range, $
        xticklen=0.05, yticklen=0.010
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the wavelength window for normalization
    cgPlot, [ sl_struc.llow_norm, sl_struc.llow_norm ], !Y.Crange, linestyle=2,$
        thick=4.5, color=cgColor( 'Cyan' ), /overplot
    cgPlot, [ sl_struc.lupp_norm, sl_struc.lupp_norm ], !Y.Crange, linestyle=2,$
        thick=4.5, color=cgColor( 'Cyan' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight interesting spectral features 
    if keyword_set( feature_over ) then begin 
        hs_spec_index_over, index_list, /center_line
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Observed spectra 
    cgPlot, wave, spec_obs, linestyle=0, thick=3.0, $
        color=cgColor( 'Charcoal' ), /overplot
    med_obs = median( spec_obs )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Overlay the ssps with significatn constribution
    f_sig_temp = 0.0
    if keyword_set( sig_over ) then begin 
        for j = 0, ( n_ssp_sig - 1 ), 1 do begin 
            if ( base_struc_sort[j].ssp_find EQ 1 ) then begin 
                s_sig = base_struc_sort[j].ssp_loc 
                file  = base_struc_sort[j].ssp_file
                frac  = base_struc_sort[j].xj_norm 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                print, ' Read in the SSP: ' + s_sig 
                print, '   ' + file + ' ' + string( frac, format='(F6.3)' )
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                readcol, s_sig, w_sig, f_sig, FORMAT='F,D', /silent, $
                    comment='#', delimiter=' ' 
                f_sig = ( f_sig / median( f_sig ) )
                ;; convolve the SSP into the same vdisp with the synthetic spectrum 
                ;; 0. Interpolate the SSP spectra into the same wavelength array 
                w_sig_inter = wave 
                f_sig_inter = interpol( f_sig, w_sig, w_sig_inter, /spline )
                ;; 1. First, log-rebin the SSP to certain velocity scale 
                lam_range = [ min_lam, max_lam ]
                log_rebin, lam_range, f_sig_inter, f_sig_log, loglam, $
                    /oversample, velscale=velscale 
                w_sig_log = exp( loglam ) 
                ;; 2. Set up the kernel for convolution 
                smoothing = ( vdisp_diff / velscale ) 
                n_kernel_pixel = round( 4.0 * smoothing + 1.0 ) * 2.0 
                kernel_lam = findgen( n_kernel_pixel ) - $
                    float( n_kernel_pixel ) / 2.0 
                kernel = exp( -1.0 * kernel_lam^2.0 / ( 2.0 * smoothing^2.0 ) )
                kernel = kernel / total( kernel ) 
                ;; 3. Do the convolution 
                if ( vdisp_diff GT 0.1 ) then begin 
                    f_sig_conv = convol( f_sig_log, kernel, /edge_truncate ) 
                endif else begin 
                    f_sig_conv = f_sig_log 
                endelse
                w_sig_conv = w_sig_log 
                ;; Properly normalize the spectra 
                index_temp = where( ( w_sig_conv GE ( l_base_norm - 2 ) ) AND $
                    ( w_sig_conv LE ( l_base_norm + 2 ) ) ) 
                if ( index_temp[0] EQ -1 ) then begin 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    print, ' Something weird just happened!  Check!!  '
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    message, ' ' 
                endif else begin 
                    fnorm_temp = median( f_sig_conv[ index_temp ] ) 
                endelse 
                f_sig_norm = ( f_sig_conv / max( f_sig_conv ) )   
                flux_tot_ssp = int_tabulated( w_sig_conv, f_sig_conv, /double )
                f_sig_norm = ( f_sig_norm / flux_tot_ssp ) * flux_tot_syn 
                med_sig = median( f_sig_norm )
                med_diff = ( med_obs - med_sig - ( sep_flux * 15.0 ) ) 
                f_sig_norm = ( f_sig_norm + med_diff - ( j + 1 ) * $
                    ( sep_flux * 11.0 ) )
                cgPlot, w_sig_conv, f_sig_norm, linestyle=0, thick=3.0, $
                    color=cgColor( sig_color_list[j] ), /overplot 
            endif 
        endfor
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Synthetic spectra 
    cgPlot, wave_nan, syn_nan, linestyle=0, thick=4.5, $
        color=cgColor( 'Red' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Re-draw the axis
    cgPlot, wave, spec_obs, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Dark Gray' ), thick=3.0, charsize=3.0, $
        ytitle='Flux (Normalized)', charthick=8.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, yminor=5, $
        xtickformat="(A1)", /nodata, xrange=wave_range, yrange=flux_range, $
        xticklen=0.05, yticklen=0.005
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Put some information on 
    ;; Label 1
    x_pos = position_1[0] + 0.55 
    y_pos = position_1[1] + 0.06
    x_step = 0.04 
    label = 'Observed'
    cgPlots, [ x_pos, (x_pos+x_step) ], [ y_pos, y_pos ], linestyle=0, $
        thick=10.0, color=cgColor( 'Gray' ), /normal
    cgText, ( x_pos + 1.2 * x_step ), ( y_pos * 0.97 ), label, alignment=0, $
        charsize=3.5, charthick=10.0, color=cgColor( 'Black' ), /normal
    ;; Label 2
    x_pos = position_1[0] + 0.55 
    y_pos = position_1[1] + 0.03
    x_step = 0.04 
    label = 'Synthetic'
    cgPlots, [ x_pos, (x_pos+x_step) ], [ y_pos, y_pos ], linestyle=0, $
        thick=13.0, color=cgColor( 'Red' ), /normal
    cgText, ( x_pos + 1.2 * x_step ), ( y_pos * 0.97 ), label, alignment=0, $
        charsize=3.5, charthick=10.0, color=cgColor( 'Black' ), /normal
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Plot the residual spectra
    cgPlot, wave, spec_res, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Red' ), thick=3.0, charsize=3.0, $
        xtitle='Wavelength (' + cgSymbol('Angstrom') + ')', $
        charthick=8.0, ytickformat='(A1)', $
        xthick=12.0, ythick=12.0, /noerase, yminor=-1, $
        position=position_2, /nodata, $ 
        xticklen=0.18, yticklen=0.008, $
        xrange=wave_range, yrange=res_range, ytickinterval=res_inter 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the wavelength window for normalization
    cgPlot, [ sl_struc.llow_norm, sl_struc.llow_norm ], !Y.Crange, linestyle=2,$
        thick=4.5, color=cgColor( 'Cyan' ), /overplot
    cgPlot, [ sl_struc.lupp_norm, sl_struc.lupp_norm ], !Y.Crange, linestyle=2,$
        thick=4.5, color=cgColor( 'Cyan' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight interesting spectral features 
    if keyword_set( feature_over ) then begin 
        hs_spec_index_over, index_list, /center_line
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Plot the residual spectra 
    cgPlot, wave, spec_res, linestyle=0, $
        color=cgColor( 'Red' ), thick=4.0, /overplot  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight masked out pixels 
    cgPlot, wave_mask, res_mask, psym=14, symsize=1.4, thick=2.0, $
        symcolor=cgColor( 'Dark Gray' ), /overplot 
    cgPlot, wave_clip, res_clip, psym=16, symsize=1.0, thick=3.0, $
        symcolor=cgColor( 'Green' ), /overplot  
    cgPlot, wave_flag, res_flag, psym=17, symsize=1.5, thick=2.0, $
        symcolor=cgColor( 'Blue' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Highlight the zero-redsidual line 
    cgPlot, !X.Crange, [ 0.0, 0.0 ], linestyle=2, thick=5.5, $
        color=cgColor( 'Black' ), /overplot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave, spec_res, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Red' ), thick=3.0, charsize=3.0, $
        ytitle='Residual', xtickformat='(A1)', $
        charthick=8.0, $
        xthick=12.0, ythick=12.0, /noerase, yminor=-1, $
        position=position_2, /nodata, $ 
        xticklen=0.10, yticklen=0.008, $
        xrange=wave_range, yrange=res_range, ytickinterval=res_inter
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Plot the zoom-in window 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( zoomin ) then begin 
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; window 1
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        index_w1 = where( ( wave GE wrange1[0] ) AND ( wave LE wrange1[1] ) ) 
        min_f = min( spec_obs[ index_w1 ] ) < min( spec_syn[ index_w1 ] )
        max_f = max( spec_obs[ index_w1 ] ) > max( spec_syn[ index_w1 ] )
        frange1 = [ min_f * 0.95, max_f * 1.08 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        x1 = ( ( wrange1[0] - wave_range[0] ) / $
            ( wave_range[1] - wave_range[0] ) * $ 
            ( position_1[2] - position_1[0] ) + position_1[0] )
        x2 = position_3[0] 
        y1 = position_1[3] 
        y2 = position_3[1] 
        cgPlots, [x1,x2], [y1,y2], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        y3 = ( ( max( spec_obs[ where( ( wave GE ( wrange1[0] - 3 ) ) AND $
            ( wave LE ( wrange1[0] + 3 ) ) ) ] ) + 0.01 ) - flux_range[0] ) / $ 
            ( flux_range[1] - flux_range[0] ) * $
            ( position_1[3] - position_1[1] ) + position_1[1]
        cgPlots, [x1,x1], [y1,y3], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        x1 = ( ( wrange1[1] - wave_range[0] ) / $
            ( wave_range[1] - wave_range[0] ) * $ 
            ( position_1[2] - position_1[0] ) + position_1[0] )
        x2 = position_3[2] 
        y1 = position_1[3] 
        y2 = position_3[1] 
        cgPlots, [x1,x2], [y1,y2], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        y3 = ( ( max( spec_obs[ where( ( wave GE ( wrange1[1] - 3 ) ) AND $
            ( wave LE ( wrange1[1] + 3 ) ) ) ] ) + 0.01 ) - flux_range[0] ) / $ 
            ( flux_range[1] - flux_range[0] ) * $
            ( position_1[3] - position_1[1] ) + position_1[1]
        cgPlots, [x1,x1], [y1,y3], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, wave, spec_obs, xstyle=1, ystyle=1, charthick=8.0, $
            charsize=2.0, xthick=12.0, ythick=12.0, /noerase, $
            position=position_3, /nodata, xrange=wrange1, yrange=frange1, $
            xticklen=0.07, yticklen=0.02, yminor=-1, xtickformat='(A1)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; XXX
        ;cgAxis, yaxis=0.0, ystyle=1, ythick=12.0, ytitle='Flux (Normalized)', $
        ;    yrange=frange1, ytickformat='(A1)', charsize=3.0, charthick=10.0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; First put the highlighted features on the background: 
        if keyword_set( feature_over ) then begin 
            hs_spec_index_over, index_list, /center_line
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgAxis, xaxis=0.0, xrange=wrange1, xstyle=1, charsize=2.5, xthick=10.0, $
            xtickformat='(A1)', xticklen=0.05
        cgAxis, xaxis=1.0, xrange=wrange1, xstyle=1, charsize=2.5, xthick=10.0, $
            xticklen=0.05
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, wave, spec_obs, linestyle=0, thick=2.0, $
            color=cgColor('Dark Gray'), /overplot 
        cgPlot, wave, spec_syn, linestyle=0, thick=6.0, color=cgColor('Red'), $ 
            /overplot 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( feature_over ) then begin 
            hs_spec_index_over, index_list, /label_over, /no_fill, /no_line, $
                xstep=30, ystep=10, charsize=2.0
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, wave, spec_obs, xstyle=1, ystyle=1, charthick=8.0, $
            charsize=2.0, xthick=12.0, ythick=12.0, /noerase, $
            position=position_3, /nodata, xrange=wrange1, yrange=frange1, $
            xticklen=0.07, yticklen=0.02, yminor=-1, xtickformat='(A1)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; window 2
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        index_w2 = where( ( wave GE wrange2[0] ) AND ( wave LE wrange2[1] ) ) 
        min_f = min( spec_obs[ index_w2 ] ) < min( spec_syn[ index_w2 ] )
        max_f = max( spec_obs[ index_w2 ] ) > max( spec_syn[ index_w2 ] )
        frange2 = [ min_f * 0.95, max_f * 1.08 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        x1 = ( ( wrange2[0] - wave_range[0] ) / $
            ( wave_range[1] - wave_range[0] ) * $ 
            ( position_1[2] - position_1[0] ) + position_1[0] )
        x2 = position_4[0] 
        y1 = position_1[3] 
        y2 = position_4[1] 
        cgPlots, [x1,x2], [y1,y2], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        y3 = ( ( max( spec_obs[ where( ( wave GE ( wrange2[0] - 3 ) ) AND $
            ( wave LE ( wrange2[0] + 3 ) ) ) ] ) + 0.01 ) - flux_range[0] ) / $ 
            ( flux_range[1] - flux_range[0] ) * $
            ( position_1[3] - position_1[1] ) + position_1[1]
        cgPlots, [x1,x1], [y1,y3], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        x1 = ( ( wrange2[1] - wave_range[0] ) / $
            ( wave_range[1] - wave_range[0] ) * $ 
            ( position_1[2] - position_1[0] ) + position_1[0] )
        x2 = position_4[2] 
        y1 = position_1[3] 
        y2 = position_4[1] 
        cgPlots, [x1,x2], [y1,y2], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        y3 = ( ( max( spec_obs[ where( ( wave GE ( wrange2[1] - 3 ) ) AND $
            ( wave LE ( wrange2[1] + 3 ) ) ) ] ) + 0.01 ) - flux_range[0] ) / $ 
            ( flux_range[1] - flux_range[0] ) * $
            ( position_1[3] - position_1[1] ) + position_1[1]
        cgPlots, [x1,x1], [y1,y3], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        cgPlot, wave, spec_obs, xstyle=1, ystyle=1, charthick=8.0, $
            charsize=2.0, xthick=12.0, ythick=12.0, /noerase, $
            position=position_4, /nodata, xrange=wrange2, yrange=frange2, $
            xticklen=0.07, yticklen=0.02, yminor=-1, xtickformat='(A1)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        ;; First put the highlighted features on the background: 
        if keyword_set( feature_over ) then begin 
            hs_spec_index_over, index_list, /center_line
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        cgPlot, wave, spec_obs, linestyle=0, thick=2.0, $
            color=cgColor('Dark Gray'), /overplot 
        cgPlot, wave, spec_syn, linestyle=0, thick=6.0, $
            color=cgColor('Red'), /overplot 
        cgPlot, wave, spec_obs, linestyle=0, thick=2.0, $
            color=cgColor('Dark Gray'), /overplot 
        cgPlot, wave, spec_syn, linestyle=0, thick=6.0, $
            color=cgColor('Red'), /overplot 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        cgAxis, xaxis=0.0, xrange=wrange2, xstyle=1, charsize=2.5, $
            xthick=10.0, xtickformat='(A1)', xticklen=0.05
        cgAxis, xaxis=1.0, xrange=wrange2, xstyle=1, charsize=2.5, $
            xthick=10.0, xticklen=0.05
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        if keyword_set( feature_over ) then begin 
            hs_spec_index_over, index_list, /label_over, /no_fill, /no_line, $
                xstep=30, ystep=10, charsize=2.0
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        cgPlot, wave, spec_obs, xstyle=1, ystyle=1, charthick=8.0, $
            charsize=2.0, xthick=12.0, ythick=12.0, /noerase, $
            position=position_4, /nodata, xrange=wrange2, yrange=frange2, $
            xticklen=0.07, yticklen=0.02, yminor=-1, xtickformat='(A1)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        ;; window 3
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        index_w3 = where( ( wave GE wrange3[0] ) AND ( wave LE wrange3[1] ) ) 
        min_f = min( spec_obs[ index_w3 ] ) < min( spec_syn[ index_w3 ] )
        max_f = max( spec_obs[ index_w3 ] ) > max( spec_syn[ index_w3 ] )
        frange3 = [ min_f * 0.95, max_f * 1.08 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        x1 = ( ( wrange3[0] - wave_range[0] ) / $
            ( wave_range[1] - wave_range[0] ) * $ 
            ( position_1[2] - position_1[0] ) + position_1[0] )
        x2 = position_5[0] 
        y1 = position_1[3] 
        y2 = position_5[1] 
        cgPlots, [x1,x2], [y1,y2], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        y3 = ( ( max( spec_obs[ where( ( wave GE ( wrange3[0] - 3 ) ) AND $
            ( wave LE ( wrange3[0] + 3 ) ) ) ] ) + 0.01 ) - flux_range[0] ) / $ 
            ( flux_range[1] - flux_range[0] ) * $
            ( position_1[3] - position_1[1] ) + position_1[1]
        cgPlots, [x1,x1], [y1,y3], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        x1 = ( ( wrange3[1] - wave_range[0] ) / $
            ( wave_range[1] - wave_range[0] ) * $ 
            ( position_1[2] - position_1[0] ) + position_1[0] )
        x2 = position_5[2] 
        y1 = position_1[3] 
        y2 = position_5[1] 
        cgPlots, [x1,x2], [y1,y2], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        y3 = ( ( max( spec_obs[ where( ( wave GE ( wrange3[1] - 3 ) ) AND $
            ( wave LE ( wrange3[1] + 3 ) ) ) ] ) + 0.01 ) - flux_range[0] ) / $ 
            ( flux_range[1] - flux_range[0] ) * $
            ( position_1[3] - position_1[1] ) + position_1[1]
        cgPlots, [x1,x1], [y1,y3], linestyle=2, thick=12.0, $
            color=cgColor('Dark Gray'), /normal
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        cgPlot, wave, spec_obs, xstyle=1, ystyle=1, charthick=8.0, $
            charsize=2.0, xthick=12.0, ythick=12.0, /noerase, $
            position=position_5, /nodata, xrange=wrange3, yrange=frange3, $
            xticklen=0.07, yticklen=0.02, yminor=-1, xtickformat='(A1)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        ;; First put the highlighted features on the background: 
        if keyword_set( feature_over ) then begin 
            hs_spec_index_over, index_list, /center_line
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        cgPlot, wave, spec_obs, linestyle=0, thick=2.0, $
            color=cgColor('Dark Gray'), /overplot 
        cgPlot, wave, spec_syn, linestyle=0, thick=6.0, $
            color=cgColor('Red'), /overplot 
        cgPlot, wave, spec_obs, linestyle=0, thick=2.0, $
            color=cgColor('Dark Gray'), /overplot 
        cgPlot, wave, spec_syn, linestyle=0, thick=6.0, $
            color=cgColor('Red'), /overplot 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        cgAxis, xaxis=0.0, xrange=wrange3, xstyle=1, charsize=2.5, $
            xthick=10.0, xtickformat='(A1)', xticklen=0.05
        cgAxis, xaxis=1.0, xrange=wrange3, xstyle=1, charsize=2.5, $
            xthick=10.0, xticklen=0.05
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        if keyword_set( feature_over ) then begin 
            hs_spec_index_over, index_list, /label_over, /no_fill, /no_line, $
                xstep=30, ystep=10, charsize=2.0
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        cgPlot, wave, spec_obs, xstyle=1, ystyle=1, charthick=8.0, $
            charsize=2.0, xthick=12.0, ythick=12.0, /noerase, $
            position=position_5, /nodata, xrange=wrange3, yrange=frange3, $
            xticklen=0.07, yticklen=0.02, yminor=-1, xtickformat='(A1)'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Information panel 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    polygon_x = [ position_6[0], position_6[2], position_6[2], position_6[0], $
        position_6[0] ]
    polygon_y = [ position_6[1], position_6[1], position_6[3], position_6[3], $
        position_6[1] ]
    polyfill, polygon_x, polygon_y, /normal,$
        color=cgColor( 'BLK2' ), linestyle=0, thick=12.0
    cgPlots, polygon_x, polygon_y, linestyle=0, thick=12.0, $
        color=cgColor('Black'), /normal
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    left  = position_6[0]
    right = position_6[2]
    lower = position_6[1]
    upper = position_6[3] - 0.006
    xmiddle = ( ( position_6[0] + position_6[2] ) / 2.0 ) 
    xstep = 0.012 
    ystep = 0.025 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Input spectrum 
    xloc = xmiddle
    yloc = upper - ( ystep * 0.8 ) 
    label = 'IN: ' + sl_struc.spec_name 
    cgText, xloc, yloc, label, charsize=3.0, charthick=10.0, $
        color=cgColor('Black'), alignment=0.5, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Output spectrum 
    xloc = xmiddle
    yloc = upper - ( ystep * 1.8 ) 
    output_name = sl_struc.output_name 
    strreplace, output_name, '.out', '' 
    label = 'OUT: ' + output_name 
    out_len = strlen( output_name )
    if ( out_len GT 30 ) then begin
        cgText, xloc, yloc, label, charsize=2.8, charthick=10.0, $
            color=cgColor('Black'), alignment=0.5, /normal 
    endif else begin 
        cgText, xloc, yloc, label, charsize=3.0, charthick=10.0, $
            color=cgColor('Black'), alignment=0.5, /normal 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Base name  
    xloc = xmiddle
    yloc = upper - ( ystep * 2.8 ) 
    label = 'BASES: ' + strlowcase( sl_struc.base_name ) + '/' + $
        strcompress( string( sl_struc.n_base ), /remove_all ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=10.0, $
        color=cgColor('Black'), alignment=0.5, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the configuration file   
    xloc = xmiddle
    yloc = upper - ( ystep * 3.8 ) 
    label = 'CONFIG: ' + $
        strcompress( sl_struc.config_name, /remove_all ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=10.0, $
        color=cgColor('Black'), alignment=0.5, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the mask file   
    xloc = left + ( xstep * 1.5 ) 
    yloc = upper - ( ystep * 5.0 ) 
    label = 'Mask: ' + $
        strcompress( sl_struc.mask_name, /remove_all ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Extinction name  
    xloc = xmiddle - ( xstep * 0.2 ) 
    yloc = upper - ( ystep * 5.0 ) 
    label = 'Reddening: ' + strlowcase( sl_struc.red_law )
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Recuded_chi^2 name  
    xloc = left + ( xstep * 1.5 )
    yloc = upper - ( ystep * 6.0 ) 
    label = 'Chi2/N: ' + $
        strcompress( string( sl_struc.reduced_chi2, format='(F9.3)' ), $
        /remove_all ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Adev  
    xloc = xmiddle - ( xstep * 0.2 )
    yloc = upper - ( ystep * 6.0 ) 
    label = 'Adev: ' + $
        strcompress( string( sl_struc.adev, format='(F9.3)' ), /remove_all ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; AIC  
    ;xloc = left + ( xstep * 1.5 )
    ;yloc = upper - ( ystep * 7.0 ) 
    ;label = 'AIC: ' + $
    ;    strcompress( string( sl_struc.aic, format='(E12.5)' ), /remove_all ) 
    ;cgText, xloc, yloc, label, charsize=2.6, charthick=9.0, $
    ;    color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; BIC  
    ;xloc = xmiddle - ( xstep * 0.2 )
    ;yloc = upper - ( ystep * 7.0 ) 
    ;label = 'BIC: ' + $
    ;    strcompress( string( sl_struc.bic, format='(E12.5)' ), /remove_all ) 
    ;cgText, xloc, yloc, label, charsize=2.6, charthick=9.0, $
    ;    color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; av   
    xloc = left + ( xstep * 1.5 )
    yloc = upper - ( ystep * 8.0 ) 
    label = 'Av:' + string( sl_struc.av_min, format='(F7.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; v0_min   
    xloc = left + ( xstep * 1.5 )
    yloc = upper - ( ystep * 9.0 ) 
    label = 'V0:' + string( sl_struc.v0_min, format='(F7.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; vd_min   
    xloc = left + ( xstep * 1.5 )
    yloc = upper - ( ystep * 10.0 ) 
    label = 'Vd:' + string( sl_struc.vd_min, format='(F7.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; sn_window   
    xloc = left + ( xstep * 1.5 )
    yloc = upper - ( ystep * 11.0 ) 
    label = 'SN:' + string( sl_struc.sn_window, format='(F7.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; at_flux    
    xloc = xmiddle - ( xstep * 0.2 )
    yloc = upper - ( ystep * 8.0 ) 
    label = 'age_flux:' + string( ( sl_struc.at_flux / 1.0D9 ), $
        format='(F8.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; at_mass   
    xloc = xmiddle - ( xstep * 0.2 )
    yloc = upper - ( ystep * 9.0 ) 
    label = 'age_mass:' + string( ( sl_struc.at_mass / 1.0D9 ), $
        format='(F7.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; am_flux    
    xloc = xmiddle - ( xstep * 0.2 )
    yloc = upper - ( ystep * 10.0 ) 
    label = 'met_flux:' + string( sl_struc.am_flux, format='(F8.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; am_mass   
    xloc = xmiddle - ( xstep * 0.2 )
    yloc = upper - ( ystep * 11.0 ) 
    label = 'met_mass:' + string( sl_struc.am_mass, format='(F7.2)' ) 
    cgText, xloc, yloc, label, charsize=3.0, charthick=9.0, $
        color=cgColor('Black'), alignment=0.0, /normal 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    age_range = [ ( min( age_ind_arr ) - 1.30 ), ( max( age_ind_arr ) + 1.30 ) ]
    met_range = [ ( min( met_ind_arr ) - 1.30 ), ( max( met_ind_arr ) + 1.30 ) ]
    frac_range = [ 0.02,( max( flux_norm_age ) > max( mcor_norm_age ) ) + 0.09 ]
    frac_inter = ceil( ceil( ( frac_range[1] - frac_range[0] ) / 0.1 ) / 4.0 ) $
        * 0.1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Tick and Label for metallicity and other stuff
    if keyword_set( met_label ) then begin 
        met_str_arr = met_label 
    endif else begin 
        met_str_arr = met_str_arr 
    endelse
    if keyword_set( met_title ) then begin 
        met_title = strcompress( met_title, /remove_all )
    endif else begin 
        met_title = '[M/H]'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_met = n_elements( met_str_arr ) 
    temp = strarr( n_met + 2 ) 
    temp[0] = '  '
    temp[n_met+1] = '  ' 
    for i = 0, ( n_met - 1 ), 1 do begin 
        temp[i+1] = met_str_arr[i] 
    endfor
    met_str_arr = temp
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Tick and label for age 
    n_age = n_elements( age_str_arr ) 
    temp = strarr( n_age + 2 ) 
    temp[0] = '  '
    temp[n_age+1] = '  ' 
    for i = 0, ( n_age - 1 ), 1 do begin 
        temp[i+1] = age_str_arr[i] 
    endfor
    age_str_arr = temp
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Luminosity fraction 
    cgPlot, age_ind_arr, met_ind_arr, xstyle=1, ystyle=1, position=position_7, $
        xrange=age_range, yrange=met_range, xthick=12.0, ythick=12.0, $
        /nodata, /noerase, xtickformat='(A1)', $ ;ytickformat='(A1)', $ 
        xticklen=0.03, yticklen=0.02, xminor=-1, yminor=-1, $ 
        xtickinterval=1, ytickinterval=1, $
        ytickname=met_str_arr, ytitle=met_title, charsize=2.6, charthick=10.0 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for i = 0, ( n_base - 1 ), 1 do begin 
        ind_x = base_struc_sort[i].age_index 
        ind_y = base_struc_sort[i].met_index
        flux = base_struc_sort[i].xj_norm 
        if ( flux GT use_threshold ) then begin 
            if ( ( i + 1 ) LE n_ssp_sig ) then begin 
                cgPlot, ind_x, ind_y, psym=16, $
                    symcolor=cgColor( sig_color_list[i]  ), $
                    symsize=( flux * 15.0 ), /overplot 
                cgPlot, ind_x, ind_y, psym=9, $
                    symcolor=cgColor( 'Dark Gray'  ), thick=5.0, $
                    symsize=( flux * 15.0 + 0.2 ), /overplot 
            endif else begin 
                cgPlot, ind_x, ind_y, psym=16, $
                    symcolor=cgColor( 'Black'  ), $
                    symsize=( flux * 15.0 ), /overplot 
            endelse
        endif
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, age_ind_arr, flux_norm_age, xstyle=1, ystyle=1, $
        position=position_9, xrange=age_range, yrange=frac_range, xthick=12.0, $
        ythick=12.0, /nodata, /noerase, xtickformat='(A1)', $ 
        xticklen=0.03, yticklen=0.02, xminor=-1, yminor=-1, $ 
        xtickinterval=1, ytickinterval=frac_inter, ytitle='Fraction', $
        charsize=2.6, charthick=10.0
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, age_ind_arr, flux_norm_age, psym=16, symsize=2.0, thick=6.0, $
        color=cgColor( 'Gray' ), /overplot
    cgPlot, age_ind_arr, flux_norm_age, psym=9,  symsize=2.2, thick=6.0, $
        color=cgColor( 'Black' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for i = 0, ( n_uniq_age + 1 ), 1 do begin 
        str = age_str_arr[i] 
        x_loc = i
        y_loc = ( frac_range[1] + 0.02 ) 
        if ( ( n_uniq_age LE 25 ) OR ( ( i mod 2 ) EQ 0 ) ) then begin 
            cgText, x_loc, y_loc, str, alignment=0.0, orientation=78.0, /data, $
                charsize=2.0, charthick=5.0, color=cgColor( 'Black' ) 
        endif
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, !X.Crange, [0.1,0.1], linestyle=2, thick=5.5, $
        color=cgColor('Red'), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Mass fraction
    age_range = [ ( min( age_ind_arr ) - 1.30 ), ( max( age_ind_arr ) + 1.30 ) ]
    met_range = [ ( min( met_ind_arr ) - 1.30 ), ( max( met_ind_arr ) + 1.30 ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, age_ind_arr, met_ind_arr, xstyle=1, ystyle=1, position=position_8, $
        xrange=age_range, yrange=met_range, xthick=12.0, ythick=12.0, $
        /nodata, /noerase, xtickformat='(A1)', ytickformat='(A1)', $ 
        xticklen=0.03, yticklen=0.02, xminor=-1, yminor=-1, $ 
        xtickinterval=1, ytickinterval=1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for i = 0, ( n_base - 1 ), 1 do begin 
        ind_x = base_struc_sort[i].age_index 
        ind_y = base_struc_sort[i].met_index
        flux = base_struc_sort[i].mcor_norm 
        if ( flux GT 0.01 ) then begin 
            if ( ( i + 1 ) LE n_ssp_sig ) then begin 
                cgPlot, ind_x, ind_y, psym=16, $
                    symcolor=cgColor( sig_color_list[i]  ), $
                    symsize=( flux * 15.0 ), /overplot 
                cgPlot, ind_x, ind_y, psym=9, $
                    symcolor=cgColor( 'Dark Gray'  ), thick=5.0, $
                    symsize=( flux * 15.0 + 0.2 ), /overplot 
            endif else begin 
                cgPlot, ind_x, ind_y, psym=16, $
                    symcolor=cgColor( 'Black'  ), $
                    symsize=( flux * 15.0 ), /overplot 
            endelse
        endif
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, age_ind_arr, mcor_norm_age, xstyle=1, ystyle=1, $
        position=position_10, xrange=age_range, yrange=frac_range, $
        xthick=12.0, ythick=12.0, /nodata, /noerase, $
        ytickformat='(A1)', xtickformat='(A1)', $ 
        xticklen=0.03, yticklen=0.02, xminor=-1, yminor=-1, $ 
        xtickinterval=1, ytickinterval=frac_inter, charsize=2.5, charthick=8.0
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, age_ind_arr, mcor_norm_age, psym=16, symsize=2.0, thick=6.0, $
        color=cgColor( 'Gray' ), /overplot
    cgPlot, age_ind_arr, mcor_norm_age, psym=9,  symsize=2.2, thick=6.0, $
        color=cgColor( 'Black' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for i = 0, ( n_uniq_age + 1 ), 1 do begin 
        str = age_str_arr[i] 
        x_loc = i
        y_loc = ( frac_range[1] + 0.02 ) 
        if ( ( n_uniq_age LE 25 ) OR ( ( i mod 2 ) EQ 0 ) ) then begin 
            cgText, x_loc, y_loc, str, alignment=0.0, orientation=78.0, /data, $
                charsize=2.0, charthick=5.0, color=cgColor( 'Black' ) 
        endif
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, !X.Crange, [0.1,0.1], linestyle=2, thick=5.5, color=cgColor('Red'), $
        /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, /close 
    set_plot, mydevice 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( topng ) then begin 
        spawn, 'which convert', imagick_convert 
        strreplace, plot_file, '.eps', '.png'
        if ( imagick_convert NE '' ) then begin 
            spawn, imagick_convert + ' -density 200 ' + plot_file + $
                ' -quality 90 -flatten ' + plot_png 
        endif
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

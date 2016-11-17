; + 
; NAME:
;              HS_STARLIGHT_COMP_OUT
;
; PURPOSE:
;              Compare the outputs of different STARLIGHT runs for the same spectrum 
;
; USAGE:
;    hs_starlight_comp_out, list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_STARLIGHT
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_starlight_comp_out, list, feature_over=feature_over, $
    min_window=min_window, max_window=max_window, $ 
    text_over=text_over, ytitle=ytitle, offset=offset, $ 
    text_0=text_0, text_1=text_1, topng=topng, summary=summary, $
    compare_repeat=compare_repeat, index_list=index_list

;; List file 
list = strcompress( list, /remove_all ) 
if NOT file_test( list ) then begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, '  Can not find the list file :' + list  
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    message, ' '
endif else begin 
    n_compare = file_lines( list ) 
    sl_list = strarr( n_compare )
    openr, 10, list 
    readf, 10, sl_list 
    close, 10 
endelse

;; Index to over-plot 
if keyword_set( index_list ) then begin 
    index_list = strcompress( index_list, /remove_all ) 
endif else begin 
    index_list = 'hs_index_plot_air.lis' 
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

;; Color list 
if ( n_compare GT 6 ) then begin 
    color_list = [ 'Navy', 'Purple', 'Blue', 'Cyan', 'Green', 'Green Yellow', $
        'Tan', 'Orange', 'Magenta', 'Red', 'Pink' ]
endif else begin 
    color_list = [ 'Black', 'Red', 'Blue', 'Green', 'Orange', 'Tan' ]
endelse
;; Symbol List
sym1_list = [ 16, 15, 14, 17, 46, 34, 9, 6, 4, 5, 2, 7, 45, 34, 35, 36 ] 
sym2_list = [ 16, 15, 14, 17, 46, 34, 9, 6, 4, 5, 2, 7, 45, 34, 35, 36 ] 

;; Find the proper wavelength range  
if file_test( sl_list[0] ) then begin 
    spec_struc = mrdfits( sl_list[0], 1, status=status, /silent ) 
    if ( status NE 0 ) then begin 
        print, 'Something wrong with the starlight output file' 
        message, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    endif else begin 
        wave = spec_struc.spec_lam 

        min_wave = min( wave ) 
        max_wave = max( wave ) 
        if keyword_set( min_window ) then begin 
            if ( min_window GE min_wave ) then begin 
                min_window = min_window 
            endif else begin 
                min_window = min_wave 
            endelse 
        endif else begin 
            min_window = min_wave 
        endelse 
        if keyword_set( max_window ) then begin 
            if ( max_window LE max_wave ) then begin 
                max_window = max_window 
            endif else begin 
                max_window = max_wave 
            endelse 
        endif else begin 
            max_window = max_wave 
        endelse 

        index_window = where( ( spec_struc.spec_lam GE min_window ) AND $
            ( ( spec_struc.spec_lam LE max_window ) ) ) 
        if ( index_window[0] EQ -1 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
            print, ' Huh? That is weird! Check! ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
            message, ' '
        endif 

        min_flux = min( spec_struc[index_window].spec_obs ) < $
            min( spec_struc[index_window].spec_syn ) 
        max_flux = max( spec_struc[index_window].spec_obs ) < $
            max( spec_struc[index_window].spec_syn ) 
        min_res  = min( spec_struc[index_window].spec_res ) 
        max_res  = max( spec_struc[index_window].spec_res ) 
    endelse 
endif else begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, ' Can not find the starlight output file: ' + sl_list[0] 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    message, ' ' 
endelse 

;; Construc a new structure for the plot 
n_pixel = ( max_window - min_window + 1 ) 
new_wave = min_window + findgen( n_pixel )
new_struc = { name:'', $
    spec_file:'', base_file:'', mask_file:'', config_file:'', $
    wave:fltarr(n_pixel), obs:fltarr(n_pixel), syn:fltarr(n_pixel), $
    err:fltarr(n_pixel), res:fltarr(n_pixel), $
    chi2:0.0, adev:0.0, nl_eff:0, n_base:0, av:0.0, v0:0.0, vd:0.0, $
    at_flux:0.0, at_mass:0.0, am_flux:0.0, am_mass:0.0, $
    aic:0.0, bic:0.0, n_ex0s_base:0, $
    max_age:0.0, max_fflux:0.0, max_fmcor:0.0 }
new_struc = replicate( new_struc, n_compare )

for i = 0, ( n_compare - 1 ), 1 do begin 

    sl_file = strcompress( sl_list[i], /remove_all ) 
    temp = strsplit( sl_file, '.', /extract ) 
    sl_str = strcompress( temp[0], /remove_all )

    if NOT file_test( sl_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the Starlight output file: ' + sl_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        spec_struc = mrdfits( sl_file, 1, status=status1, /silent )
        sl_struc   = mrdfits( sl_file, 2, status=status2, /silent ) 
        base_struc = mrdfits( sl_file, 3, status=status3, /silent ) 

        if ( ( status1 NE 0 ) AND ( status2 NE 0 ) AND ( status3 NE 0 ) ) $
            then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, 'Something wrong with the Starlight output file! '
        endif 
        
        new_struc[i].name = sl_str 
        new_struc[i].spec_file   = sl_struc.spec_name 
        new_struc[i].base_file   = sl_struc.base_name 
        new_struc[i].mask_file   = sl_struc.mask_name 
        new_struc[i].config_file = sl_struc.config_name 

        new_struc[i].chi2 = sl_struc.reduced_chi2 
        new_struc[i].adev = sl_struc.adev1
        new_struc[i].av   = sl_struc.av_min 
        new_struc[i].v0   = sl_struc.v0_min 
        new_struc[i].vd   = sl_struc.vd_min 
        new_struc[i].at_flux = ( sl_struc.at_flux / 1.0D9 )
        new_struc[i].at_mass = ( sl_struc.at_mass / 1.0D9 )
        new_struc[i].am_flux = sl_struc.am_flux 
        new_struc[i].am_mass = sl_struc.am_mass 
        new_struc[i].aic     = sl_struc.adev2
        new_struc[i].bic     = sl_struc.avg_delta
        new_struc[i].nl_eff  = sl_struc.nl_eff
        new_struc[i].n_base  = sl_struc.n_base
        new_struc[i].n_ex0s_base  = sl_struc.n_ex0s_base

        obs_inter = interpol( spec_struc.spec_obs, spec_struc.spec_lam, $
            new_wave, /spline )
        syn_inter = interpol( spec_struc.spec_syn, spec_struc.spec_lam, $
            new_wave, /spline )
        err_inter = interpol( (1.0 / spec_struc.spec_wei), spec_struc.spec_lam, $
            new_wave, /spline )

        new_struc[i].wave = new_wave 
        new_struc[i].obs  = obs_inter 
        new_struc[i].syn  = syn_inter  
        new_struc[i].err  = err_inter
        new_struc[i].res  = (obs_inter - syn_inter) / err_inter

        index_use = where((new_wave > min(new_wave) + 100.0) AND $ 
                          (new_wave < max(new_wave) - 100.0))

        min_flux = min( obs_inter[index_use] ) < min_flux  
        min_flux = min( syn_inter[index_use] ) < min_flux  
        max_flux = max( obs_inter[index_use] ) > max_flux  
        max_flux = max( syn_inter[index_use] ) > max_flux  

        min_res = min( (obs_inter[index_use] - syn_inter[index_use] ) / $
            err_inter[index_use] ) < min_res 
        max_res = max( (obs_inter[index_use] - syn_inter[index_use] ) / $
            err_inter[index_use] ) > max_res 

        index_uniq_age = uniq( base_struc.age, sort( base_struc.age ) ) 
        ssp_age_arr = base_struc[ index_uniq_age ].age
        n_uniq_age = n_elements( index_uniq_age )
        age_gyr_arr = ( ssp_age_arr / 1.0D9 )
        age_ind_arr = base_struc[ index_uniq_age ].age_index 
        age_str_arr = base_struc[ index_uniq_age ].age_str

        flux_norm_age = fltarr( n_uniq_age ) 
        mcor_norm_age = fltarr( n_uniq_age ) 
        ;; 1. For stellar ages 
        for j = 0, ( n_uniq_age - 1 ), 1 do begin 
            index_age = where( base_struc.age EQ ssp_age_arr[j] ) 
            if ( index_age[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something weird just happened!  Check again!! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif else begin 
                flux_norm_age[j] = total( base_struc[ index_age ].xj_norm )
                mcor_norm_age[j] = total( base_struc[ index_age ].mcor_norm )
            endelse 
        endfor

        new_struc[i].max_age   = max( age_gyr_arr ) 
        new_struc[i].max_fflux = max( flux_norm_age ) 
        new_struc[i].max_fmcor = max( mcor_norm_age ) 

    endelse 
endfor 

if keyword_set( compare_repeat ) then begin 
    n_uniq_age = n_uniq_age 
    frac_flux = fltarr( n_uniq_age, n_compare ) 
    frac_mcor = fltarr( n_uniq_age, n_compare ) 
endif

;; Median/Mean/And standard deviation
median_chi2 = median( new_struc.chi2 )
median_adev = median( new_struc.adev ) 
median_aic  = median( new_struc.aic )
median_bic  = median( new_struc.bic )
median_av   = median( new_struc.av )
median_v0   = median( new_struc.v0 )
median_vd   = median( new_struc.vd )
median_at_flux = median( new_struc.at_flux )
median_at_mass = median( new_struc.at_mass )
median_am_flux = median( new_struc.am_flux )
median_am_mass = median( new_struc.am_mass )
resistant_mean, new_struc.chi2, 6.0, mean_chi2, sig_chi2
resistant_mean, new_struc.adev, 6.0, mean_adev, sig_adev
resistant_mean, new_struc.aic,  6.0, mean_aic,  sig_aic,  /double
resistant_mean, new_struc.bic,  6.0, mean_bic,  sig_bic,  /double
resistant_mean, new_struc.av,   6.0, mean_av,   sig_av
resistant_mean, new_struc.v0,   6.0, mean_v0,   sig_v0
resistant_mean, new_struc.vd,   6.0, mean_vd,   sig_vd
resistant_mean, new_struc.at_flux, 6.0, mean_at_flux, sig_at_flux
resistant_mean, new_struc.am_flux, 6.0, mean_am_flux, sig_am_flux
resistant_mean, new_struc.at_mass, 6.0, mean_at_mass, sig_at_mass
resistant_mean, new_struc.am_mass, 6.0, mean_am_mass, sig_am_mass

;; Normalize the AIC and BIC 
aic_norm = new_struc.aic / new_struc[0].aic 
bic_norm = new_struc.bic / new_struc[0].bic 
bic_plot = ( bic_norm - 0.002 ) 
chi2_norm = new_struc.chi2 / new_struc[0].chi2
adev_norm = new_struc.adev / new_struc[0].adev
adev_plot = ( adev_norm - 0.002 )

wave_range = [ min_window, max_window ]
flux_sep = ( max_flux - min_flux ) 
flux_offset = ( ( max_flux - min_flux ) /  7.0 )
if NOT keyword_set( offset ) then begin 
    flux_range = [ ( min_flux - flux_sep * 0.005 ), $
        ( max_flux + flux_sep * 0.015 ) ] 
endif else begin 
    flux_range = [ ( min_flux - ( n_compare - 1 ) * flux_offset ), $
        ( max_flux + flux_sep * 0.015 ) ] 
endelse

res_sep = ( max_res - min_res ) 
res_range = [ ( min_res - 0.1 ), ( max_res + 0.05 ) ]

;; Name of the figure 
temp = strsplit( list, '.', /extract ) 
plot_string = strcompress( temp[0], /remove_all ) + '_' + $
    strcompress( string( floor( min_window ) ), /remove_all ) + '-' + $ 
    strcompress( string( ceil( max_window ) ), /remove_all ) 
plot_compare = plot_string + '.eps'
file_compare = strcompress( temp[0], /remove_all ) + '_compare.fits'
;; 
sum_string = strcompress( temp[0], /remove_all )
plot_sum = sum_string + '_sum.eps'
file_sum = strcompress( temp[0], /remove_all ) + '_sum.csv'

;; Save the spectra comparison file 
mwrfits, new_struc, file_compare, /create, /silent 
;; Save the summary file 
openw, 10, file_sum, width=1500 
comma = ' , '
printf, 10, 'Name, Spec_File, Base_File, Mask_File, Config_File, N_Base, ' + $
    'N_EX0s_Base, NL_EFF, Chi2, ADev, AIC, BIC, A_V, V_0, V_d, ' + $
    'AT_Flux, AT_Mass, AM_Flux, AM_Mass'
for i = 0, ( n_compare - 1 ), 1 do begin 
    printf, 10, new_struc[i].name + comma + new_struc[i].spec_file + comma + $ 
        new_struc[i].base_file + comma + new_struc[i].mask_file + comma + $ 
        new_struc[i].config_file + comma + $
        string( new_struc[i].n_base ) + comma + $
        string( new_struc[i].n_ex0s_base ) + comma + $
        string( new_struc[i].nl_eff ) + comma + $
        string( new_struc[i].chi2 ) + comma + $
        string( new_struc[i].adev ) + comma + $
        string( new_struc[i].aic ) + comma + $
        string( new_struc[i].bic ) + comma + $
        string( new_struc[i].av ) + comma + $
        string( new_struc[i].v0 ) + comma + $
        string( new_struc[i].vd ) + comma + $
        string( new_struc[i].at_flux ) + comma + $
        string( new_struc[i].at_mass ) + comma + $
        string( new_struc[i].am_flux ) + comma + $
        string( new_struc[i].am_mass )
endfor
close, 10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____  _     ___ _____   ;;
;;  |  _ \| |   / _ \_   _|  ;;
;;  | |_) | |  | | | || |    ;;
;;  |  __/| |__| |_| || |    ;;
;;  |_|   |_____\___/ |_|    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

position_1 = [ 0.08, 0.48, 0.97, 0.99 ]
position_2 = [ 0.08, 0.12, 0.97, 0.48 ]

mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 28 
set_plot, 'ps' 
device, filename=plot_compare, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

;; Observed and Synthetic spectra
if keyword_set( ytitle ) then begin 
    cgPlot, new_struc[0].wave, new_struc[0].obs, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.0, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=wave_range, yrange=flux_range, $
        xticklen=0.03, yticklen=0.02
endif else begin 
    cgPlot, new_struc[0].wave, new_struc[0].obs, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.0, $
        charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=wave_range, yrange=flux_range, $
        xticklen=0.03, yticklen=0.02
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Highlight interesting spectral features 
if keyword_set( feature_over ) then begin 
    hs_spec_index_over, index_list, /label_over, /no_fill, /no_line, $
        xstep=30, ystep=10, charsize=2.0
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cgPlot, new_struc[0].wave, new_struc[0].obs, linestyle=0, thick=5.0, $
    color=cgColor( 'Dark Gray' ), /overplot 
for i = 0, ( n_compare - 1 ), 1 do begin 
    if keyword_set( compare_repeat ) then begin 
        cgPlot, new_struc[i].wave, new_struc[i].syn, linestyle=0, thick=2.5, $
            color=cgColor( 'Red' ), /overplot 
        xloc = ( position_1[0] + 0.06 ) 
        yloc = ( position_1[3] - 0.07 ) 
        cgText, xloc, yloc, 'n_repeat:' + $
            strcompress( string( n_compare ), /remove_all ), /normal, $
            charsize=4.0, charthick=12.0, color=cgColor( 'Black' )
    endif else begin 
        cgPlot, new_struc[i].wave, new_struc[i].syn, linestyle=0, thick=3.0, $
            color=cgColor( color_list[i] ), /overplot 
        if keyword_set( offset ) then begin 
            cgPlot, new_struc[i].wave, ( new_struc[i].syn - ( i + 1 ) * $
                flux_offset ), linestyle=1, thick=7.5, $
                color=cgColor( color_list[i] ), /overplot 
        endif 
    endelse
endfor 

if keyword_set( text_over ) then begin 
    if keyword_set( text_0 ) then begin 
        t_left = float( text_0 ) 
    endif else begin 
        t_left = ( position_1[0] * 1.2 )
    endelse
    if keyword_set( text_1 ) then begin 
        t_top = float( text_1 ) 
    endif else begin 
        t_top = ( position_1[3] - 0.06 )
    endelse
    xstep = 0.02 
    ystep = 0.032
    for k = 0, ( n_compare - 1 ), 1 do begin 
        ;; line 
        xstart = t_left 
        xend   = ( t_left + xstep * 2.2 ) 
        ystart = ( t_top - ( k * ystep ) ) 
        cgPlots, [ xstart, xend ], [ ystart, ystart ], linestyle=0, thick=7.0, $ 
            color=cgColor( color_list[k] ), /normal 
        ;; label 
        xstart = ( xend + xstep * 0.4 ) 
        ystart = ( ystart - ystep * 0.05 ) 
        label = strcompress( new_struc[k].name, /remove_all ) 
        cgText, xstart, ystart, label, charthick=7.0, charsize=2.0, $
            color=cgColor( 'Black' ), /normal
    endfor 
endif 
cgPlot, new_struc[0].wave, new_struc[0].obs, xstyle=1, ystyle=1, $
    linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.0, $
    charthick=9.0, xthick=12.0, ythick=12.0, $
    /noerase, position=position_1, $
    xtickformat="(A1)", /nodata, xrange=wave_range, yrange=flux_range, $
    xticklen=0.03, yticklen=0.02

;; Residual spectra
if keyword_set( ytitle ) then begin 
    cgPlot, new_struc[0].wave, new_struc[0].res, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.0, $
        ytitle='Residual', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, yminor=-1, $
        xtitle='Wavelength (' + cgSymbol( 'Angstrom' ) + ')', $
        xtickformat="(A1)", /nodata, xrange=wave_range, yrange=res_range, $
        xticklen=0.1, yticklen=0.015
endif else begin 
    cgPlot, new_struc[0].wave, new_struc[0].res, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.0, $
        charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, yminor=-1, $
        xtitle='Wavelength (' + cgSymbol( 'Angstrom' ) + ')', $
        xtickformat="(A1)", /nodata, xrange=wave_range, yrange=res_range, $
        xticklen=0.1, yticklen=0.015
endelse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Highlight interesting spectral features 
if keyword_set( feature_over ) then begin 
    hs_spec_index_over, index_list, /center_line
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if keyword_set( compare_repeat ) then begin 
    for i = 0, ( n_compare - 1 ), 1 do begin 
        cgPlot, new_struc[i].wave, new_struc[i].res, $
            linestyle=0, thick=2.0, color=cgColor( 'Red' ), /overplot 
        if i NE 0 then begin 
            cgPlot, new_struc[i].wave, new_struc[i].res, $
                linestyle=0, thick=2.0, color=cgColor( color_list[i] ), $
                /overplot 
        endif 
    endfor 
endif else begin 
    for i = 0, ( n_compare - 1 ), 1 do begin 
        cgPlot, new_struc[i].wave, new_struc[i].res, $
            linestyle=0, thick=2.5, color=cgColor( color_list[i] ), /overplot 
    endfor 
endelse

cgPlot, !X.Crange, [0.0, 0.0], linestyle=2, thick=6.0, /overplot, $
    color=cgColor( 'Black' )
cgPlot, new_struc[0].wave, new_struc[0].res, $
    xstyle=1, ystyle=1, $
    linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.0, $
    charthick=9.0, xthick=12.0, ythick=12.0, $
    /noerase, position=position_2, yminor=-1, $
    /nodata, xrange=wave_range, yrange=res_range, $
    xticklen=0.1, yticklen=0.015

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
device, /close 
set_plot, mydevice 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( summary ) then begin 

    ;; Positions
    psxsize = 54 
    psysize = 26 
    position_1 = [ 0.08, 0.12, 0.37, 0.55 ]
    position_2 = [ 0.08, 0.55, 0.37, 0.98 ]

    position_3 = [ 0.43, 0.12, 0.59, 0.44 ]
    position_4 = [ 0.66, 0.12, 0.82, 0.44 ]
    position_5 = [ 0.82, 0.12, 0.98, 0.44 ]

    position_6 = [ 0.43, 0.55, 0.705, 0.98 ]
    position_7 = [ 0.705, 0.55, 0.98, 0.98 ]

    ;; Index Array 
    index_arr = ( indgen( n_compare ) + 1 )
    index_range = [ 0.5, ( n_compare + 0.5 ) ]

    ;; Min/Max_AIC/BIC 
    min_aic = min( aic_norm ) 
    min_bic = min( bic_plot ) 
    max_aic = max( aic_norm ) 
    max_bic = max( bic_plot ) 
    min_y1 = ( min_aic < min_bic ) 
    max_y1 = ( max_aic > max_bic ) 
    y1_sep = ( max_y1 - min_y1 ) 
    if ( y1_sep GE 5.0 ) then begin 
        aic_norm = alog10( aic_norm ) 
        bic_norm = alog10( bic_norm ) 
        min_aic = min( aic_norm ) 
        min_bic = min( bic_plot ) 
        max_aic = max( aic_norm ) 
        max_bic = max( bic_plot ) 
        min_y1 = ( min_aic < min_bic ) 
        max_y1 = ( max_aic > max_bic ) 
        y1_sep = ( max_y1 - min_y1 ) 
        y1_title = 'Log(AIC or BIC) [Norm]'
        y1_csize = 3.0 
    endif else begin 
        y1_title = 'AIC or BIC [Norm]'
        y1_csize = 3.2 
    endelse
    y1_range = [ ( min_y1 - y1_sep / 4.0 ), ( max_y1 + y1_sep / 7.0) ]

    ;; Min/Max_Chi2/ADev
    min_chi2 = min( chi2_norm )
    max_chi2 = max( chi2_norm )
    min_adev = min( adev_plot )
    max_adev = max( adev_plot )
    min_y2 = ( min_chi2 < min_adev ) 
    max_y2 = ( max_chi2 > max_adev )
    y2_sep = ( max_y2 - min_y2 ) 
    if ( y1_sep GE 5.0 ) then begin 
        chi2_norm = alog10( chi2_norm ) 
        adev_norm = alog10( adev_norm )
        min_chi2 = min( chi2_norm )
        max_chi2 = max( chi2_norm )
        min_adev = min( adev_plot )
        max_adev = max( adev_plot )
        min_y2 = ( min_chi2 < min_adev ) 
        max_y2 = ( max_chi2 > max_adev )
        y2_sep = ( max_y2 - min_y2 ) 
        y2_title = 'Log(Chi2/n or Adev) [Norm]'
        y2_csize = 3.0
    endif else begin 
        y2_title = 'Chi2/n or Adev [Norm]'
        y2_csize = 3.2
    endelse
    y2_range = [ ( min_y2 - y2_sep / 4.0 ), ( max_y2 + y2_sep / 7.0) ]

    ;; Min/Max_Age/Metal 
    min_age1 = min( new_struc.at_flux ) 
    max_age1 = max( new_struc.at_flux )
    age1_sep = ( max_age1 - min_age1 ) 
    age_range1 = [ ( min_age1 - age1_sep / 6.0 ), ( max_age1 + age1_sep / 6.0 ) ]
    min_age2 = min( new_struc.at_mass ) 
    max_age2 = max( new_struc.at_mass )
    age2_sep = ( max_age2 - min_age2 ) 
    age_range2 = [ ( min_age2 - age2_sep / 6.0 ), ( max_age2 + age2_sep / 6.0 ) ]
    min_met = ( min( new_struc.am_flux ) < min( new_struc.am_mass ) ) 
    max_met = ( max( new_struc.am_flux ) > max( new_struc.am_mass ) ) 
    met_sep = ( max_met - min_met ) 
    met_range = [ ( min_met - met_sep / 6.0 ), ( max_met + met_sep / 2.6 ) ]

    ;; Min/Max_Vd/AV 
    min_av = min( new_struc.av ) 
    max_av = max( new_struc.av )
    av_sep = ( max_av - min_av ) 
    av_range = [ ( min_av - av_sep / 6.0 ), ( max_av + av_sep / 6.0) ]
    min_vd = min( new_struc.vd )  
    max_vd = max( new_struc.vd )  
    vd_sep = ( max_vd - min_vd ) 
    vd_range = [ ( min_vd - vd_sep / 6.0 ), ( max_vd + vd_sep / 6.0) ]

    ;; Max_Age/FFlux/Fmcor 
    max_age = max( new_struc.max_age )
    max_fflux = max( new_struc.max_fflux )
    max_fmcor = max( new_struc.max_fmcor )
    max_frac = ( max_fflux > max_fmcor ) 
    frac_sep = ( max_frac - 0.025 ) 
    frac_range = [ 0.025, ( max_frac + frac_sep / 12.0 ) ]
    age_range3 = [ -0.3, ( max_age * 1.1 ) ]  ;; Gyr
  
    mydevice = !d.name 
    !p.font=1
    set_plot, 'ps' 
    device, filename=plot_sum, font_size=9.0, /encapsulated, $
        /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    ;; Plot1
    ;; AIC 
    cgPlot, index_arr, aic_norm, xstyle=1, ystyle=1, $
        xrange=index_range, yrange=y1_range, xthick=12.0, ythick=12.0, $
        charsize=y1_csize, charthick=12.0, position=position_1, $ 
        xtitle='Index', ytitle=y1_title, /nodata, /noerase, $ 
        xticklen=0.035, yticklen=0.03, color=cgColor( 'Black' ), $
        xminor=5, yminor=5
    cgPlot, index_arr, aic_norm, linestyle=0, thick=5.0, $
        color=cgColor( 'Dark Gray' ), /overplot 
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, index_arr[k], aic_norm[k], symsize=2.5, thick=9.0, $
                psym=16, symcolor=cgColor( 'Black' ) 
        endif else begin 
            cgPlots, index_arr[k], aic_norm[k], symsize=3.0, thick=9.0, $
                psym=sym2_list[k], symcolor=cgColor( color_list[k] ) 
        endelse
    endfor
    cgPlot, index_arr, bic_plot, linestyle=2, thick=8.0, $
        color=cgColor( 'Dark Gray' ), /overplot 
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, index_arr[k], bic_plot[k], symsize=1.5, thick=9.0, $
                psym=9, symcolor=cgColor( 'Black' ) 
        endif else begin 
            cgPlots, index_arr[k], bic_plot[k], symsize=3.0, thick=9.0, $
                psym=sym1_list[k], symcolor=cgColor( color_list[k] ) 
        endelse
    endfor
    xloc = ( position_1[0] + 0.02 ) 
    yloc = ( position_1[1] + 0.025 ) 
    cgText, xloc, yloc, 'Solid:BIC', /normal, charsize=3.0, charthick=11.0, $
        color=cgColor( 'Black' ), alignment=0.0 
    xloc = ( position_1[0] + 0.10 ) 
    yloc = ( position_1[1] + 0.025 ) 
    cgText, xloc, yloc, 'Dash:AIC', /normal, charsize=3.0, charthick=11.0, $
        color=cgColor( 'Black' ), alignment=0.0 

    ;; Plot2
    ;; Chi2/Adev 
    cgPlot, index_arr, chi2_norm, xstyle=1, ystyle=1, $
        xrange=index_range, yrange=y2_range, xthick=12.0, ythick=12.0, $
        charsize=y2_csize, charthick=12.0, position=position_2, $ 
        xtickformat='(A1)', ytitle=y2_title, $
        /nodata, /noerase, xminor=5, yminor=5, $ 
        xticklen=0.035, yticklen=0.03, color=cgColor( 'Black' )
    cgPlot, index_arr, chi2_norm, linestyle=0, thick=6.0, $
        color=cgColor( 'Dark Gray' ), /overplot 
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, index_arr[k], chi2_norm[k], symsize=2.5, thick=9.0, $
                psym=16, symcolor=cgColor( 'Black' ) 
        endif else begin 
            cgPlots, index_arr[k], chi2_norm[k], symsize=3.0, thick=9.0, $
                psym=sym2_list[k], symcolor=cgColor( color_list[k] ) 
        endelse
    endfor
    cgPlot, index_arr, adev_plot, linestyle=2, thick=6.0, $
        color=cgColor( 'Dark Gray' ), /overplot 
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, index_arr[k], adev_plot[k], symsize=1.5, thick=9.0, $
                psym=9, symcolor=cgColor( 'Black' ) 
        endif else begin 
            cgPlots, index_arr[k], adev_plot[k], symsize=3.0, thick=9.0, $
                psym=sym1_list[k], symcolor=cgColor( color_list[k] ) 
        endelse
    endfor
    xloc = ( position_2[0] + 0.02 ) 
    yloc = ( position_2[1] + 0.025 ) 
    cgText, xloc, yloc, 'Solid:Chi2/n', /normal, charsize=3.0, $
        charthick=11.0, color=cgColor( 'Black' ), alignment=0.0 
    xloc = ( position_2[0] + 0.10 ) 
    yloc = ( position_2[1] + 0.025 ) 
    cgText, xloc, yloc, 'Dash:Adev', /normal, charsize=3.0, charthick=11.0, $
        color=cgColor( 'Black' ), alignment=0.0

    ;; Plot3
    cgPlot, new_struc.av, new_struc.vd, xstyle=1, ystyle=1, $
        xrange=av_range, yrange=vd_range, xthick=12.0, ythick=12.0, $
        charsize=2.8, charthick=12.0, position=position_3, $ 
        ytitle='Velocity Disperson (km/s)', xtitle='Av (mag)', $
        xtickformat='(A1)', $
        xminor=2, yminor=2, /nodata, /noerase, xticklen=0.03, yticklen=0.04, $
        color=cgColor( 'Black' ) 
    cgAxis, xaxis=0, xstyle=1, ystyle=1, xrange=av_range, yrange=vd_range, $
        xthick=12.0, ythick=12.0, charsize=2.2, charthick=12.0, xminor=2
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, new_struc[k].av, new_struc[k].vd, $
                psym=9, thick=10.0, symsize=2.5, symcolor=cgColor( 'Dark Gray' )
            cgPlots, mean_av, mean_vd, psym=16, symsize=2.6, $ 
                symcolor=cgColor( 'Black' )
            cgPlot, mean_av, mean_vd, pysm=16, symsize=2.6, $ 
                symcolor=cgColor( 'Black' ), $
                err_xlow=sig_av, err_xhigh=sig_av, $
                err_ylow=sig_vd, err_yhigh=sig_vd, /overplot
            cgPlots, median_av, median_vd, psym=46, symsize=3.5, $ 
                symcolor=cgColor( 'Red' )
        endif else begin 
            cgPlots, new_struc[k].av, new_struc[k].vd, thick=9.0, $
                psym=sym1_list[k], symsize=3.0, symcolor=cgColor( color_list[k] )
        endelse
    endfor

    ;; Plot4
    cgPlot, new_struc.at_flux, new_struc.am_flux, xstyle=1, ystyle=1, $
        xrange=age_range1, yrange=met_range, xthick=12.0, ythick=12.0, $
        charsize=2.8, charthick=12.0, position=position_4, $ 
        xtitle='<Age/Gyr>', ytitle='<[Z/H]>', xminor=2, yminor=2, $
        /nodata, /noerase, xticklen=0.03, yticklen=0.04, $
        color=cgColor( 'Black' ), xtickformat='(A1)' 
    cgAxis, xaxis=0, xstyle=1, ystyle=1, xrange=age_range1, yrange=met_range, $
        xthick=12.0, ythick=12.0, charsize=2.2, charthick=12.0, xminor=2
    cgPlot, !X.Crange, [ 0.02, 0.02 ], linestyle=2, thick=8.0, $
        color=cgColor( 'Dark Gray' ), /overplot
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, new_struc[k].at_flux, new_struc[k].am_flux, $
                psym=9, thick=10.0, symsize=2.5, symcolor=cgColor( 'Dark Gray' )
            cgPlots, mean_at_flux, mean_am_flux, psym=16, symsize=2.6, $ 
                symcolor=cgColor( 'Black' )
            cgPlot, mean_at_flux, mean_am_flux, pysm=16, symsize=2.6, $ 
                symcolor=cgColor( 'Black' ), $
                err_xlow=sig_at_flux, err_xhigh=sig_at_flux, $
                err_ylow=sig_am_flux, err_yhigh=sig_am_flux, /overplot
            cgPlots, median_at_flux, median_am_flux, psym=46, symsize=3.5, $ 
                symcolor=cgColor( 'Red' )
        endif else begin 
            cgPlots, new_struc[k].at_flux, new_struc[k].am_flux, thick=9.0, $
                psym=sym1_list[k], symsize=3.0, symcolor=cgColor( color_list[k] )
        endelse
    endfor
    xloc = ( position_4[0] + 0.055 )
    yloc = ( position_4[3] - 0.045 )
    cgText, xloc, yloc, 'Flux Weighted', /normal, charsize=3.0, $
        charthick=12.0, color=cgColor( 'Black' )

    ;; Plot5
    cgPlot, new_struc.at_mass, new_struc.am_mass, xstyle=1, ystyle=1, $
        xrange=age_range2, yrange=met_range, xthick=12.0, ythick=12.0, $
        charsize=2.8, charthick=12.0, position=position_5, $ 
        xtitle='<Age/Gyr>', ytickformat='(A1)', xtickformat='(A1)', $
        /nodata, /noerase, xticklen=0.03, yticklen=0.04, $
        color=cgColor( 'Black' ), xminor=2, yminor=2 
    cgAxis, xaxis=0, xstyle=1, ystyle=1, xrange=age_range2, yrange=met_range, $
        xthick=12.0, ythick=12.0, charsize=2.2, charthick=12.0, xminor=2
    cgPlot, !X.Crange, [ 0.02, 0.02 ], linestyle=2, thick=8.0, $
        color=cgColor( 'Dark Gray' ), /overplot
    for k = 0, ( n_compare - 1 ), 1 do begin 
        if keyword_set( compare_repeat ) then begin 
            cgPlots, new_struc[k].at_mass, new_struc[k].am_mass, $
                psym=9, thick=10.0, symsize=2.5, symcolor=cgColor( 'Dark Gray' )
            cgPlots, mean_at_mass, mean_am_mass, psym=16, symsize=2.6, $ 
                symcolor=cgColor( 'Black' )
            cgPlot, mean_at_mass, mean_am_mass, pysm=16, symsize=2.6, $ 
                symcolor=cgColor( 'Black' ), $
                err_xlow=sig_at_mass, err_xhigh=sig_at_mass, $
                err_ylow=sig_am_mass, err_yhigh=sig_am_mass, /overplot
            cgPlots, median_at_mass, median_am_mass, psym=46, symsize=3.5, $ 
                symcolor=cgColor( 'Red' )
        endif else begin 
            cgPlots, new_struc[k].at_mass, new_struc[k].am_mass, thick=9.0, $
                psym=sym1_list[k], symsize=3.0, symcolor=cgColor( color_list[k] )
        endelse
    endfor
    xloc = ( position_5[0] + 0.055 )
    yloc = ( position_5[3] - 0.045 )
    cgText, xloc, yloc, 'Mass Weighted', /normal, charsize=3.0, $
        charthick=12.0, color=cgColor( 'Black' )

    ;; Plot 6
    cgPlot, new_struc.at_mass, new_struc.am_mass, xstyle=1, ystyle=1, $
        xrange=age_range3, yrange=frac_range, xthick=12.0, ythick=12.0, $
        charsize=2.8, charthick=12.0, position=position_6, $ 
        xtitle='<Age/Gyr>', ytitle='Fraction', $
        /nodata, /noerase, xticklen=0.035, yticklen=0.03, $
        color=cgColor( 'Black' ), xminor=5, yminor=5
    xloc = ( position_6[0] + 0.025 )
    yloc = ( position_6[3] - 0.050 )
    cgText, xloc, yloc, 'Flux Weighted', /normal, charsize=3.5, $
        charthick=12.0, color=cgColor( 'Black' )

    ;; Plot 7
    cgPlot, new_struc.at_mass, new_struc.am_mass, xstyle=1, ystyle=1, $
        xrange=age_range3, yrange=frac_range, xthick=12.0, ythick=12.0, $
        charsize=2.8, charthick=12.0, position=position_7, $ 
        xtitle='<Age/Gyr>', ytickformat='(A1)', $
        /nodata, /noerase, xticklen=0.035, yticklen=0.03, $
        color=cgColor( 'Black' ), xminor=5, yminor=5
    xloc = ( position_7[0] + 0.025 )
    yloc = ( position_7[3] - 0.050 )
    cgText, xloc, yloc, 'Mass Weighted', /normal, charsize=3.5, $
        charthick=12.0, color=cgColor( 'Black' )

    for i = 0, ( n_compare - 1 ), 1 do begin 
    
        sl_file = strcompress( sl_list[i], /remove_all ) 
        base_struc = mrdfits( sl_file, 3, /silent ) 

        index_uniq_age = uniq( base_struc.age, sort( base_struc.age ) ) 
        ssp_age_arr = base_struc[ index_uniq_age ].age
        n_uniq_age = n_elements( index_uniq_age )
        age_gyr_arr = ( ssp_age_arr / 1.0D9 )
        age_ind_arr = base_struc[ index_uniq_age ].age_index 
        age_str_arr = base_struc[ index_uniq_age ].age_str
    
        flux_norm_age = fltarr( n_uniq_age ) 
        mcor_norm_age = fltarr( n_uniq_age ) 

        for j = 0, ( n_uniq_age - 1 ), 1 do begin 
            index_age = where( base_struc.age EQ ssp_age_arr[j] ) 
            if ( index_age[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something weird just happened!  Check again!! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' ' 
            endif else begin 
                flux_norm_age[j] = total( base_struc[ index_age ].xj_norm )
                mcor_norm_age[j] = total( base_struc[ index_age ].mcor_norm )
                if keyword_set( compare_repeat ) then begin 
                    frac_flux[j,i] = flux_norm_age[j]
                    frac_mcor[j,i] = mcor_norm_age[j]
                endif 
            endelse 
        endfor

        if keyword_set( compare_repeat ) then begin 

            cgPlot, age_gyr_arr, flux_norm_age, xstyle=4, ystyle=4, $
                xrange=age_range3, yrange=frac_range, $
                psym=9, symsize=1.8, thick=8.0, /noerase, $
                color=cgColor( 'Dark Gray' ), position=position_6
            cgPlot, !X.Crange, [0.1,0.1], linestyle=2, thick=8.0, $
                color=cgColor('Red'), /overplot
    
            cgPlot, age_gyr_arr, mcor_norm_age, xstyle=4, ystyle=4, $
                xrange=age_range3, yrange=frac_range, $
                psym=9, symsize=1.8, thick=8.0, /noerase, $
                color=cgColor( 'Dark Gray' ), position=position_7
            cgPlot, !X.Crange, [0.1,0.1], linestyle=2, thick=8.0, $
                color=cgColor('Red'), /overplot

        endif else begin 

            cgPlot, age_gyr_arr, flux_norm_age, xstyle=4, ystyle=4, $
                xrange=age_range3, yrange=frac_range, $
                position=position_6, /noerase, psym=0, $
                linestyle=0, thick=2.5, color=cgColor( color_list[i] )
            cgPlot, !X.Crange, [0.1,0.1], linestyle=2, thick=8.0, $
                color=cgColor('Gray'), /overplot
            cgPlot, age_gyr_arr, flux_norm_age, $
                psym=sym1_list[i], symsize=2.2, /overplot, thick=6.0, $
                color=cgColor( color_list[i] )
    
            cgPlot, age_gyr_arr, mcor_norm_age, xstyle=4, ystyle=4, $
                xrange=age_range3, yrange=frac_range, $
                position=position_7, /noerase, $
                linestyle=0, thick=2.5, color=cgColor( color_list[i] )
            cgPlot, !X.Crange, [0.1,0.1], linestyle=2, thick=8.0, $
                color=cgColor('Gray'), /overplot
            cgPlot, age_gyr_arr, mcor_norm_age, $
                psym=sym1_list[i], symsize=2.2, /overplot, thick=6.0, $
                color=cgColor( color_list[i] )
        endelse
    
    endfor 

    if keyword_set( compare_repeat ) then begin 
        median_frac_flux = fltarr( n_uniq_age ) 
        mean_frac_flux = fltarr( n_uniq_age ) 
        sig_frac_flux = fltarr( n_uniq_age ) 
        median_frac_mass = fltarr( n_uniq_age ) 
        mean_frac_mass = fltarr( n_uniq_age ) 
        sig_frac_mass = fltarr( n_uniq_age ) 

        for i = 0, ( n_uniq_age - 1 ), 1 do begin 
            median_frac_flux[i] = median( frac_flux[i,*] )
            median_frac_mass[i] = median( frac_mcor[i,*] )
            resistant_mean, frac_flux[i,*], 6.0, a, b
            mean_frac_flux[i] = a 
            sig_frac_flux[i]  = b
            resistant_mean, frac_mcor[i,*], 6.0, a, b
            mean_frac_mass[i] = a 
            sig_frac_mass[i]  = b
        endfor

        cgPlot, age_gyr_arr, mean_frac_flux, xstyle=4, ystyle=4, $
            xrange=age_range3, yrange=frac_range, $
            psym=16, symsize=2.5, symcolor=cgColor( 'Black' ), $
            position=position_6, /noerase 
        cgErrPlot, age_gyr_arr, ( mean_frac_flux - sig_frac_flux ), $ 
                ( mean_frac_flux + sig_frac_flux ), color=cgColor( 'Black' ), $
                thick=9.0, width=0.03
        cgPlot, age_gyr_arr, median_frac_flux, xstyle=4, ystyle=4, $
            xrange=age_range3, yrange=frac_range, $
            psym=46, symsize=3.0, symcolor=cgColor( 'Red' ), $
            position=position_6, /noerase 

        cgPlot, age_gyr_arr, mean_frac_mass, xstyle=4, ystyle=4, $
            xrange=age_range3, yrange=frac_range, $
            psym=16, symsize=2.5, symcolor=cgColor( 'Black' ), $
            position=position_7, /noerase 
        cgErrPlot, age_gyr_arr, ( mean_frac_mass - sig_frac_mass ), $ 
            ( mean_frac_mass + sig_frac_mass ), color=cgColor( 'Black' ), $
            thick=9.0, width=0.03
        cgPlot, age_gyr_arr, median_frac_mass, xstyle=4, ystyle=4, $
            xrange=age_range3, yrange=frac_range, $
            psym=46, symsize=3.0, symcolor=cgColor( 'Red' ), $
            position=position_7, /noerase 

    endif

    cgPlot, new_struc.at_mass, new_struc.am_mass, xstyle=1, ystyle=1, $
        xrange=age_range3, yrange=frac_range, xthick=12.0, ythick=12.0, $
        charsize=2.5, charthick=12.0, position=position_6, $ 
        /nodata, /noerase, xticklen=0.03, yticklen=0.03, $
        color=cgColor( 'Black' ), xminor=5, yminor=5, $
        xtickformat='(A1)', ytickformat='(A1)'
    cgPlot, new_struc.at_mass, new_struc.am_mass, xstyle=1, ystyle=1, $
        xrange=age_range3, yrange=frac_range, xthick=12.0, ythick=12.0, $
        charsize=2.5, charthick=12.0, position=position_7, $ 
        /nodata, /noerase, xticklen=0.03, yticklen=0.03, $
        color=cgColor( 'Black' ), xminor=5, yminor=5, $ 
        xtickformat='(A1)', ytickformat='(A1)'

    device, /close 
    set_plot, mydevice 

endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

if keyword_set( topng ) then begin 
    spawn, 'which convert', imagick_convert 

    plot_png = plot_string + '.png' 
    spawn, imagick_convert + ' -density 200 ' + plot_compare + $
        ' -quality 90 -flatten ' + plot_png 

    sum_png = sum_string + '.png' 
    spawn, imagick_convert + ' -density 200 ' + plot_sum + $
        ' -quality 90 -flatten ' + sum_png 
endif 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end 

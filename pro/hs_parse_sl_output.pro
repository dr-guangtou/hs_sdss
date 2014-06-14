function hs_retrieve_para, chunk, tag, sep, num

    line = hs_string_extract( chunk, tag )
    if ( n_elements( line ) EQ 1 ) then begin 
        if ( line[0] NE '' ) then begin 
            temp = strsplit( line, sep, /extract ) 
            n_seg = n_elements( temp ) 
            if ( num GT ( n_seg - 1) ) then begin 
                para = !VALUES.F_NaN 
            endif else begin 
                para = strcompress( temp[ num ], /remove_all ) 
            endelse
        endif else begin 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            print, ' Can not find line that include: ' + tag + ' ! ' 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            para = !VALUES.F_NaN
        endelse
    endif else begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, '  Be careful, there are more than one line that includes: ' + tag 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        para = !VALUES.F_NaN
    endelse

    return, para

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro hs_parse_sl_output, file, sl_struc, base_struc, spec_struc, $
    save_fits=save_fits, save_txt=save_txt, quiet=quiet, base_dir=base_dir, $ 
    is_fxk=is_fxk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;    Read and parse the output file from STARLIGHT v4, put the results   ;;;
;;;     into a IDL structure 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; constant 
met_sun = 0.020

;; Exam and read in the output file 
file = strcompress( file, /remove_all ) 
if NOT file_test( file ) then begin 
    print, '############################################################'
    print, '  Can not find ' + file + ' ! Please Check ! '
    print, '############################################################'
    message, ' '
endif else begin
    ;; Pull out the string that identifies this output file 
    out_string = strsplit( file, ' .', /extract )
    out_string = strcompress( out_string[0], /remove_all )
    ;; Read in the output file into a string array 
    num_lines = file_lines( file ) 
    sl_out = strarr( num_lines ) 
    openr, 10, file 
    readf, 10, sl_out 
    close, 10 
    ;; Check if this is a real STARLIGHT output file 
    ;; So, remember that DO NOT modify the first two lines of output file
    check_array = '## OUTPUT of StarlightChains_v04.for'
    check_posit = strpos( sl_out, check_array )
    check_exist = where( check_posit NE -1 )
    if ( check_exist[0] EQ -1 ) then begin 
        print, '############################################################'
        print, '  Sorry, but this is not a real Starlight output, Right ?   '
        print, '############################################################'
        message, ' '
    endif 
endelse

;; Check option: BASE_DIR 
if keyword_set( base_dir ) then begin 
    base_dir = strcompress( base_dir, /remove_all ) 
    use_base = 1 
endif else begin 
    use_base = 0 
endelse 

;; Define a IDL structure that includes all information from this file 
sl_struc = { output_name:'', spec_name:'', base_name:'', mask_name:'', $
    config_name:'', n_base:0L, n_yav:0L, power_law:0L, power_alpha:0.0, $
    red_law:'', q_norm:0.0, $          ;; input information 
    l_ini:0.0, l_fin:0.0, dl:0.0, $    ;; resamplig parameters 
    l_norm:0.0, llow_norm:0.0, lupp_norm:0.0, fobs_norm:0.0D, $ ;; normalization
    llow_sn:0.0, lupp_sn:0.0, sn_window:0.0, sn_norm:0.0, snerr_window:0.0, $
    snerr_norm:0.0, fscale_chi2:0.0, $ ;; signal-to-noise ratio information 
    nol_eff:0L, nl_eff:0L, ntot_cliped:0L, clip_method:'', ntot_steps:0L, $
    n_chains:0L, n_ex0s_base:0L, n_clip_bug:0L, n_rc_crash:0L, $
    n_burnin_warning:0L, n_censored_wei:0L, wei_nsig_threshold:0.0, $
    wei_limits:0.0D, time_all:0.0D, $  ;; misc
    reduced_chi2:0.0D, adev:0.0D, xj_sum:0.0D, flux_tot:0.0D, $
    mini_tot:0.0D, mcor_tot:0.0D, v0_min:0.0, vd_min:0.0, av_min:0.0, $
    yav:0.0, $  ;; synthesis results 
    n_ssp_use:0, n_ssp_sig:0, $ ;; number of useful stellar population
    at_flux:0.0, am_flux:0.0, at_mass:0.0,  am_mass:0.0, $ ;; aveage properties
    n_free:0, aic:0.0D, bic:0.0D $ 
    }
sl_struc.output_name = file 

if NOT keyword_set( quiet ) then begin 
    print, '##################################################################'
    print, '  Read in STARLIGHT v4 output file: ' + file 
    print, '##################################################################'
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Separate the first chunk, which is the summary of the input, configuration ;;
;;   settings, and the results                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The starting and ending line number of the first chunk 
;; This should be the same for all Starlight runs 
;; Again, do not alter the original output file before this! 
check_0 = "Some input info" 
posit_0 = strpos( sl_out, check_0 ) 
exist_0 = where( posit_0 NE -1 ) 
if ( exist_0[0] EQ -1 ) then begin 
    print, " Somthing wrong with the output file, Check ! " 
    print, " Can not find any line that includes: " + check_0 + ' !' 
    message, ' '
endif else begin 
    sum_chunk_0 = exist_0[0]
endelse
check_1 = "# j     x_j(%)      Mini_j(%)     Mcor_j(%)" 
posit_1 = strpos( sl_out, check_1 ) 
exist_1 = where( posit_1 NE -1 ) 
if ( exist_1[0] EQ -1 ) then begin 
    print, " Somthing wrong with the output file, Check ! " 
    print, " Can not find any line that includes: " + check_1 + ' !' 
    message, ' '
endif else begin 
    sum_chunk_1 = ( exist_1[0] - 1 )
endelse
;; Extract the summary chunk 
sum_chunk = sl_out[ sum_chunk_0 : sum_chunk_1 ]
;; Read all summary information into the structure 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A) Input information 
if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Summary of the input: ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif
;;   a) Name of the input spectrum: 
tag = '[arq_obs]' 
sl_struc.spec_name = hs_retrieve_para( sum_chunk, tag, ' ', 0 )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   SPEC_NAME   :  ' + sl_struc.spec_name 
endif
    ;; Check the existence of the file 
    if NOT file_test( sl_struc.spec_name ) then begin 
        print, '###########################################################'
        print, '  Can not find the file for input spectrum ! '
        print, '###########################################################'
    endif 
;;   b) Name of the base file: 
tag = '[arq_base]'
sl_struc.base_name = hs_retrieve_para( sum_chunk, tag, ' ', 0 )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   BASE_NAME   :  ' + sl_struc.base_name 
endif
    ;; Check the existence of the file 
    if NOT file_test( sl_struc.base_name ) then begin 
        print, '###########################################################'
        print, '  Can not find the file for input bases ! '
        print, '###########################################################'
    endif 
;;   c) Name of the mask file: 
tag = '[arq_masks]'
sl_struc.mask_name = hs_retrieve_para( sum_chunk, tag, ' ', 0 )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   MASK_NAME   :  ' + sl_struc.mask_name
endif
    ;; Check the existence of the file 
    if NOT file_test( sl_struc.mask_name ) then begin 
        print, '###########################################################'
        print, '  Can not find the file for input masks ! '
        print, '###########################################################'
    endif 
;;   d) Name of the configuration file: 
tag = '[arq_config]'
sl_struc.config_name = hs_retrieve_para( sum_chunk, tag, ' ', 0 )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  CONFIG_NAME  :  ' + sl_struc.config_name
endif
    ;; Check the existence of the file 
    if NOT file_test( sl_struc.config_name ) then begin 
        print, '###########################################################'
        print, '  Can not find the configuration file ! '
        print, '###########################################################'
    endif 
;;   e) Number of the SSP bases used in fitting: 
tag = '[N_base]'
sl_struc.n_base = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
n_base = sl_struc.n_base
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    N_BASES    :  ' + strcompress( string( sl_struc.n_base ), $
        /remove_all )
endif
;;   f) Number of the SSP bases with YAV component: 
tag = '[N_YAV_components'
sl_struc.n_yav = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   N_YAV_COMP  :  ' + strcompress( string( sl_struc.n_yav ), $
        /remove_all )
endif
;;   g) Is power-law continuum included? : 
tag = '[i_FitPowerLaw (1/0 = Yes/No)]'
sl_struc.power_law = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   POWER_LAW   :  ' + strcompress( $
        string( sl_struc.power_law ), /remove_all )
endif
;;   h) The slope of the power-law spectrum : 
tag = '[alpha_PowerLaw]'
sl_struc.power_alpha = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  POWER_ALPHA  :  ' + strcompress( $
        string( sl_struc.power_alpha ), /remove_all )
endif
;;   i) The name of the selected extinction law : 
tag = '[red_law_option]'
sl_struc.red_law = hs_retrieve_para( sum_chunk, tag, ' ', 0 )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##     RED_LAW   :  ' + strcompress( $
        string( sl_struc.red_law ), /remove_all )
endif
;;   j) The extinction value at the wavelength of normalization 
tag = '[q_norm = A(l_norm)/A(V)]'
sl_struc.q_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##     Q_NORM    :  ' + strcompress( $
        string( sl_struc.q_norm ), /remove_all )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; B) Sampling Parameters
if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Sampling Parameters : ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif
;;   a) Initial wavelength 
tag = '[l_ini (A)]'
sl_struc.l_ini = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##     L_INI     :  ' + strcompress( $
        string( sl_struc.l_ini ), /remove_all )
endif
;;   b) Final wavelength 
tag = '[l_fin (A)]'
sl_struc.l_fin = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##     L_FIN     :  ' + strcompress( $
        string( sl_struc.l_fin ), /remove_all )
endif
;;   c) Wavelength step  
tag = '[dl    (A)]'
sl_struc.dl = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##       D_L     :  ' + strcompress( $
        string( sl_struc.dl ), /remove_all )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C) Normalization Parameters
if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Normalization Parameters : ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif
;;   a) Normalization wavelength for base file 
tag = '[l_norm (A)'
sl_struc.l_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  L_NORM_BASE  :  ' + strcompress( $
        string( sl_struc.l_norm ), /remove_all )
endif
;;   b) Lower normalization window for observed spectra
tag = '[llow_norm (A)'
sl_struc.llow_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## LLOW_NORM_OBS :  ' + strcompress( $
        string( sl_struc.llow_norm ), /remove_all )
endif
;;   c) Upper normalization window for observed spectra
tag = '[lupp_norm (A)'
sl_struc.lupp_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## LUPP_NORM_OBS :  ' + strcompress( $
        string( sl_struc.lupp_norm ), /remove_all )
endif
;;   d) Flux for normalization 
tag = '[fobs_norm (in input units)]'
sl_struc.fobs_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   FOBS_NORM   :  ' + strcompress( $
        string( sl_struc.fobs_norm ), /remove_all )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; D) Signal-to-Noise Ratio Information
if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Signal-to-Noise Ratio: ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif
;;   a) Lower wavelength window for S/N 
tag = '[llow_SN (A)'
sl_struc.llow_sn = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    LLOW_SN   :  ' + strcompress( $
        string( sl_struc.llow_sn ), /remove_all )
endif
;;   b) Upper wavelength window for S/N 
tag = '[lupp_SN (A)'
sl_struc.lupp_sn = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    LUPP_SN   :  ' + strcompress( $
        string( sl_struc.lupp_sn ), /remove_all )
endif
;;   c) S/N in the S/N window  
tag = '[S/N in S/N window]'
sl_struc.sn_window = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   SN_WINDOW  :  ' + strcompress( $
        string( sl_struc.sn_window ), /remove_all )
endif
;;   d) S/N in the normalization window  
tag = '[S/N in norm. window]'
sl_struc.sn_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    SN_NORM   :  ' + strcompress( $
        string( sl_struc.sn_norm ), /remove_all )
endif
;;   e) S/N err in the S/N window  
tag = '[S/N_err in S/N window]'
sl_struc.snerr_window = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   SN_ERR_SN  :  ' + strcompress( $
        string( sl_struc.snerr_window ), /remove_all )
endif
;;   f) S/N err in the normalization window  
tag = '[S/N_err in S/N window]'
sl_struc.snerr_norm = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  SN_ERR_NORM :  ' + strcompress( $
        string( sl_struc.snerr_norm ), /remove_all )
endif
;;   g) Fscale_chi2 
tag = '[fscale_chi2]'
sl_struc.fscale_chi2 = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  FSCALE_CHI2 :  ' + strcompress( $
        string( sl_struc.fscale_chi2 ), /remove_all )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; E) Misc 
if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Misc ... : ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif
;;   a) NOl_eff 
tag = '[NOl_eff]'
sl_struc.nol_eff = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   NOL_EFF   :  ' + strcompress( $
        string( sl_struc.nol_eff ), /remove_all )
endif
;;   b) Nl_eff 
tag = '[Nl_eff]'
sl_struc.nl_eff = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   NL_EFF    :  ' + strcompress( $
        string( sl_struc.nl_eff ), /remove_all )
endif
;;   c) Ntot_cliped
tag = '[Ntot_cliped & clip_method]'
sl_struc.ntot_cliped = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## NTOT_CLIPED :  ' + strcompress( $
        string( sl_struc.ntot_cliped ), /remove_all )
endif
;;   d) Clip_method
tag = '[Ntot_cliped & clip_method]'
sl_struc.clip_method = hs_retrieve_para( sum_chunk, tag, ' ', 1 )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## CLIP_METHOD :  ' + strcompress( $
        string( sl_struc.clip_method ), /remove_all )
endif
;;   e) Ntot_steps
tag = '[Nglobal_steps]'
sl_struc.ntot_steps = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  NTOT_STEPS :  ' + strcompress( $
        string( sl_struc.ntot_steps ), /remove_all )
endif
;;   f) N_chains
tag = '[N_chains]'
sl_struc.n_chains = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   N_CHAINS  :  ' + strcompress( $
        string( sl_struc.n_chains ), /remove_all )
endif
;;   g) NEX0s_base
tag = '[NEX0s_base = N_base in EX0s-fits]'
sl_struc.n_ex0s_base = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  NEX0S_BASE :  ' + strcompress( $
        string( sl_struc.n_ex0s_base ), /remove_all )
endif
;;   h) Number of Clip-Bug 
tag = '[Clip-Bug, RC-Crash & Burn-In warning-flags, '
sl_struc.n_clip_bug = long( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  N_CLIP_BUG :  ' + strcompress( $
        string( sl_struc.n_clip_bug ), /remove_all )
endif
;;   i) Number of RC-Crash 
tag = '[Clip-Bug, RC-Crash & Burn-In warning-flags, '
sl_struc.n_rc_crash = long( hs_retrieve_para( sum_chunk, tag, ' ', 1 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  N_RC-CRASH :  ' + strcompress( $
        string( sl_struc.n_rc_crash ), /remove_all )
endif
;;   j) Number of Burn-in Warning 
tag = '[Clip-Bug, RC-Crash & Burn-In warning-flags, '
sl_struc.n_burnin_warning = long( hs_retrieve_para( sum_chunk, tag, ' ', 2 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## N_BURN-IN W :  ' + strcompress( $
        string( sl_struc.n_burnin_warning ), /remove_all )
endif
;;   k) Number of censored weights 
tag = '[Clip-Bug, RC-Crash & Burn-In warning-flags, '
sl_struc.n_censored_wei = long( hs_retrieve_para( sum_chunk, tag, ' ', 3 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## N_CENSORED  :  ' + strcompress( $
        string( sl_struc.n_censored_wei ), /remove_all )
endif
;;   l) Wei_NSIG_THRESHOLD 
tag = '[Clip-Bug, RC-Crash & Burn-In warning-flags, '
sl_struc.wei_nsig_threshold = float( hs_retrieve_para( sum_chunk, tag, ' ', 4 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## N_NSIG_THR  :  ' + strcompress( $
        string( sl_struc.wei_nsig_threshold ), /remove_all )
endif
;;   m) Weights limits 
tag = '[Clip-Bug, RC-Crash & Burn-In warning-flags, '
sl_struc.wei_limits = float( hs_retrieve_para( sum_chunk, tag, ' ', 5 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##  WEI_LIMIT  :  ' + strcompress( $
        string( sl_struc.wei_limits ), /remove_all )
endif
;;   n) Time All 
tag = '[idt_all, wdt_TotTime, wdt_UsrTime & '
sl_struc.time_all = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   TIME_ALL  :  ' + strcompress( $
        string( sl_struc.time_all ), /remove_all )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; F) Synthesis Results 
if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Synthesis Results - Best Model : ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif
;;   a) Reduced chi2 
tag = '[chi2/Nl_eff]'
sl_struc.reduced_chi2 = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ## CHI2_NLEFF  :  ' + strcompress( $
        string( sl_struc.reduced_chi2 ), /remove_all )
endif
;;   b) Absolute Deviation  
tag = '[adev (%)]'
sl_struc.adev = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##     ADEV    :  ' + strcompress( $
        string( sl_struc.adev ), /remove_all )
endif
;;   c) Sum. of x 
tag = '[sum-of-x (%)]'
sl_struc.xj_sum = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   XJ_SUM    :  ' + strcompress( $
        string( sl_struc.xj_sum ), /remove_all )
endif
;;   d) Flux_tot  
tag = '[Flux_tot (units of'
sl_struc.flux_tot = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   FLUX_TOT  :  ' + strcompress( $
        string( sl_struc.flux_tot ), /remove_all )
endif
;;   e) Mini_tot 
tag = '[Mini_tot ('
sl_struc.mini_tot = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   MINI_TOT  :  ' + strcompress( $
        string( sl_struc.mini_tot ), /remove_all )
endif
;;   f) Mcor_tot 
tag = '[Mcor_tot ('
sl_struc.mcor_tot = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   MCOR_TOT  :  ' + strcompress( $
        string( sl_struc.mcor_tot ), /remove_all )
endif
;;   g) v0_min 
tag = '[v0_min  (km/s)]'
sl_struc.v0_min = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    V0_MIN   :  ' + strcompress( $
        string( sl_struc.v0_min ), /remove_all )
endif
;;   h) v0_min 
tag = '[vd_min  (km/s)]'
sl_struc.vd_min = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    VD_MIN   :  ' + strcompress( $
        string( sl_struc.vd_min ), /remove_all )
endif
;;   i) AV_min 
tag = '[AV_min  (mag)]'
sl_struc.av_min = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##    AV_MIN   :  ' + strcompress( $
        string( sl_struc.av_min ), /remove_all )
endif
;;   j) AV_min 
tag = '[YAV_min (mag)]'
sl_struc.yav = float( hs_retrieve_para( sum_chunk, tag, ' ', 0 ) )
if NOT keyword_set( QUIET ) then begin 
    print, ' ##   YAV_MIN   :  ' + strcompress( $
        string( sl_struc.yav ), /remove_all )
endif

;; Get the number of the total freedom parameters: 
if keyword_set( is_fxk ) then begin 
    sl_struc.n_free = sl_struc.n_base + 1 + sl_struc.n_yav  ;; 1: Av  
endif else begin 
    sl_struc.n_free = sl_struc.n_base + 3 + sl_struc.n_yav  ;; 1: Av  
endelse
;; Get the total chi^2
total_chi2 = sl_struc.reduced_chi2 * sl_struc.nl_eff
sl_struc.aic = total_chi2 + ( ( 2.0 * sl_struc.n_free ) / $
    ( 1.0 - ( ( sl_struc.n_free - 1.0 ) / sl_struc.nl_eff ) ) )
sl_struc.bic = total_chi2 + ( sl_struc.n_free * alog( sl_struc.nl_eff ) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Separate the second chunk, which is the summary of best model results
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_0 = "# j     x_j(%)      Mini_j(%)     Mcor_j(%)" 
posit_0 = strpos( sl_out, check_0 ) 
exist_0 = where( posit_0 NE -1 ) 
if ( exist_0[0] EQ -1 ) then begin 
    print, " Somthing wrong with the output file, Check ! " 
    print, " Can not find any line that includes: " + check_0 + ' !' 
    message, ' '
endif else begin 
    base_chunk_0 = ( exist_0[0] + 1 )
endelse
base_chunk_1 = ( base_chunk_0 + n_base )
;; Extract the summary chunk 
base_chunk = sl_out[ base_chunk_0 : base_chunk_1 ]

if NOT keyword_set( quiet ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, '  ## Summary of results for all the bases : ' 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, ' #  Index   Component     Age    Metal    x_j (%)   '
endif
;; Make a structure that store all the model results
base_struc = { num:0L, xj:0.0, mini:0.0, mcor:0.0, age:0.0, metal:0.0, $
    l2m:0.0, yav:0L, mstar:0.0, comp:'', a_fe:0.0, chi2r:0.0, $ 
    adev:0.0, av:0.0, ssp_x:0.0, xj_norm:0.0, mini_norm:0.0, mcor_norm:0.0, $
    ssp_use:0, ssp_sig:0, ssp_file:'', ssp_loc:'', ssp_find:0, $ 
    ssp_fnorm:0.0, age_log:0.0, age_gyr:0.0, met_sun:0.0, met_m2h:0.0, $
    age_index:0, age_str:'', met_index:0, met_str:'' }
base_struc = replicate( base_struc, n_base )
;; Parse the results to the structure 
for i = 0, ( n_base - 1 ), 1 do begin 
    base_line = base_chunk[i]
    temp = strsplit( base_line, ' ', /extract )
    base_struc[i].num  = long( temp[0] )
    base_struc[i].xj   = double( temp[1] ) 
    base_struc[i].mini = double( temp[2] )
    base_struc[i].mcor = double( temp[3] )
    base_struc[i].age  = double( temp[4] )
    base_struc[i].metal = double( temp[5] )
    base_struc[i].l2m   = double( temp[6] )
    base_struc[i].yav   = float( temp[7] ) 
    base_struc[i].mstar = double( temp[8] )
    base_struc[i].comp  = string( temp[9] )
    base_struc[i].a_fe  = float( temp[10] )
    base_struc[i].chi2r = double( temp[11] )
    base_struc[i].adev  = double( temp[12] )
    base_struc[i].av    = double( temp[13] )
    base_struc[i].ssp_x = double( temp[14] )
    ;; Unit conversion for age 
    base_struc[i].age_log = alog10( base_struc[i].age ) 
    base_struc[i].age_gyr = ( base_struc[i].age / 1.0D9 ) 
    ;; Unit conversion for metallicity 
    base_struc[i].met_sun = ( base_struc[i].metal / met_sun ) 
    base_struc[i].met_m2h = alog10( base_struc[i].met_sun ) 
    ;; Normalize the luminosity contribution 
    base_struc[i].xj_norm = ( base_struc[i].xj / sl_struc.xj_sum ) 
    ;; If the contribution is larger than 2%, call it useful 
    if ( base_struc[i].xj_norm GE 0.02 ) then begin 
        base_struc[i].ssp_use = 1 
    endif else begin 
        base_struc[i].ssp_use = 0 
    endelse 
    ;; If the contribution is larger than 10%, call it useful 
    if ( base_struc[i].xj_norm GE 0.08 ) then begin 
        base_struc[i].ssp_sig = 1 
    endif else begin 
        base_struc[i].ssp_sig = 0 
    endelse 
    if NOT keyword_set( quiet ) then begin 
        print, ' # ', i, ' ', temp[9], ' ', temp[4], ' ', temp[5], ' ', temp[1]
    endif 
endfor
;; Also normalize the stellar mass contribution 
mini_sum = total( base_struc.mini ) 
mcor_sum = total( base_struc.mcor )
base_struc.mini_norm = ( base_struc.mini / mini_sum )
base_struc.mcor_norm = ( base_struc.mcor / mcor_sum )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Separate the third chunk, which is the synthetic spectrum 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_0 = "## Synthetic spectrum (Best Model) ##l_obs f_obs f_syn wei" 
posit_0 = strpos( sl_out, check_0 ) 
exist_0 = where( posit_0 NE -1 ) 
if ( exist_0[0] EQ -1 ) then begin 
    print, " Somthing wrong with the output file, Check ! " 
    print, " Can not find any line that includes: " + check_0 + ' !' 
    message, ' '
endif else begin 
    spec_chunk_0 = ( exist_0[0] + 1 )
endelse
nlobs_line = sl_out[ spec_chunk_0 ] 
temp = strsplit( nlobs_line, ' ', /extract ) 
nlobs = long( temp[0] ) 
spec_chunk_1 = ( spec_chunk_0 + 1 )
spec_chunk_2 = ( spec_chunk_0 + nlobs )
;; Extract the summary chunk 
spec_chunk = sl_out[ spec_chunk_1 : spec_chunk_2 ]

;; Make a structure that store the spectrum 
spec_struc = { spec_lam:0.0, spec_obs:0.0, spec_syn:0.0, spec_wei:0.0, $
    spec_res:0.0, pixel_mask:0, pixel_flag:0, pixel_clip:0, final_mask:0 } 
spec_struc = replicate( spec_struc, nlobs )

for i = 0, ( nlobs - 1 ), 1 do begin 
    spec_line = spec_chunk[i]
    temp = strsplit( spec_line, ' ', /extract )
    spec_struc[i].spec_lam = float( temp[0] )
    spec_struc[i].spec_obs = float( temp[1] ) 
    spec_struc[i].spec_syn = float( temp[2] )
    spec_struc[i].spec_wei = float( temp[3] )
    spec_struc[i].spec_res = ( spec_struc[i].spec_obs - spec_struc[i].spec_syn ) 
    weight = long( temp[3] ) 
    if ( weight EQ 0 ) then begin 
        spec_struc[i].pixel_mask = 1 
        spec_struc[i].final_mask = 1 
    endif 
    if ( weight EQ -1 ) then begin 
        spec_struc[i].pixel_clip = 1 
        spec_struc[i].final_mask = 1 
    endif 
    if ( weight EQ -2 ) then begin 
        spec_struc[i].pixel_flag = 1 
        spec_struc[i].final_mask = 1 
    endif 
endfor

;; Min and Max  
min_lam = min( spec_struc.spec_lam )
max_lam = max( spec_struc.spec_lam )
min_obs = min( spec_struc.spec_obs )
max_obs = max( spec_struc.spec_obs )
min_syn = min( spec_struc.spec_syn )
max_syn = max( spec_struc.spec_syn )
min_res = min( spec_struc.spec_res )
max_res = max( spec_struc.spec_res )
med_res = median( spec_struc.spec_res )

;; l_norm; llow_norm;; lupp_norm 
l_base_norm = sl_struc.l_norm 
index_lnorm = where( ( spec_struc.spec_lam GE ( l_base_norm - 2 ) ) AND $
    ( spec_struc.spec_lam LE ( l_base_norm + 2 ) ) ) 
if ( index_lnorm[0] EQ -1 ) then begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, ' Something weird just happened!  Check!!  '
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    message, ' ' 
endif else begin 
    spec_syn_norm = median( spec_struc[ index_lnorm ].spec_syn ) 
endelse 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Parse the input base file  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
;; The number of significant SSPs
index_ssp_sig = where( base_struc.ssp_sig EQ 1 ) 
if ( index_ssp_sig[0] NE -1 ) then begin 
    n_ssp_sig = n_elements( index_ssp_sig ) 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, 'There are ', n_ssp_sig, ' SSPs with >8% contribution '
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif 
sl_struc.n_ssp_use = n_ssp_use
sl_struc.n_ssp_sig = n_ssp_sig

base_file = strcompress( sl_struc.base_name, /remove_all ) 
if NOT file_test( base_file ) then begin 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, ' Can not find the input BASE file: ' + base_file 
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
endif else begin 
    n_lines = file_lines( base_file ) 
    ssp_bases = strarr( n_lines ) 
    openr, 10, base_file
    readf, 10, ssp_bases
    close, 10 
    chunk = ssp_bases[ 1:n_base ]
    for i = 0, ( n_base - 1 ), 1 do begin 
        temp_line = chunk[i]
        temp = strsplit( temp_line, ' ', /extract )
        base_struc[i].ssp_file = strcompress( temp[0], /remove_all ) 
        if ( base_struc[i].ssp_use EQ 1 ) then begin 
            if ( use_base EQ 1 ) then begin 
                base_struc[i].ssp_loc = base_dir + '/' + base_struc[i].ssp_file 
                if file_test( base_struc[i].ssp_loc ) then begin 
                    base_struc[i].ssp_find = 1 
                endif else begin 
                    base_struc[i].ssp_find = 0
                endelse
            endif
            if ( base_struc[i].ssp_find EQ 0 ) then begin 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                print, ' Looking for : ' + base_struc[i].ssp_file 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                spawn, 'locate ' + base_struc[i].ssp_file, temp 
                n_find = n_elements( temp ) 
                print, temp
                print, ' Find ' + string( n_find )
                if ( n_find GT 1 ) then begin 
                    for k = 0, ( n_find - 1 ), 1 do begin 
                        file = strlowcase( strcompress( temp[k], /remove_all ) )
                        print, file 
                        isfits = strpos( file, '.fits' )
                        if ( ( isfits EQ -1 ) AND $
                            ( base_struc[i].ssp_find EQ 0 ) ) then begin 
                            base_struc[i].ssp_loc = strcompress( temp[k], $
                                /remove_all ) 
                            base_struc[i].ssp_find = 1 
                            print, 'XXX', (i+1), ' Find:', base_struc[i].ssp_loc 
                        endif else begin 
                            print, 'XXX Not the useful one'
                        endelse
                    endfor
                endif else begin 
                    if ( temp[0] NE '' ) then begin 
                        base_struc[i].ssp_loc = strcompress( temp[0], /remove_all ) 
                        base_struc[i].ssp_find = 1 
                        print, 'XXX', (i+1), ' Find:', base_struc[i].ssp_loc 
                    endif else begin 
                        base_struc[i].ssp_loc = ''
                        base_struc[i].ssp_find = 0 
                    endelse 
                endelse
            endif 
        endif
        base_struc[i].ssp_fnorm = ( spec_syn_norm * base_struc[i].xj_norm ) 
    endfor 
endelse

;; Sort the base_struc according to the normalized contribution of each SSP 
index_sort_ssp = reverse( sort( base_struc.xj_norm ) )
base_struc_sort = base_struc[ index_sort_ssp ] 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculate the luminosity and mass weighted age and metallicity 
;; 1. Luminosity weighted age and metallicity  
avg_age_flux = total( base_struc.xj_norm * base_struc.age ) 
avg_met_flux = total( base_struc.xj_norm * base_struc.metal ) 
;; 2. Stellar mass weighted age and metallicity 
avg_age_mcor = total( base_struc.mcor_norm * base_struc.age ) 
avg_met_mcor = total( base_struc.mcor_norm * base_struc.metal )
print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
print, ' The luminosity weighted stellar age: ', avg_age_flux 
print, ' The luminosity weighted stellar metallicity: ', avg_met_flux 
print, ' The stellar mass weighted stellar age: ', avg_age_mcor 
print, ' The stellar mass weighted stellar metallicity: ', avg_met_mcor 
print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
sl_struc.at_flux = avg_age_flux 
sl_struc.am_flux = avg_met_flux 
sl_struc.at_mass = avg_age_mcor 
sl_struc.am_mass = avg_met_mcor 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Identify the unique age and metallicity 
index_uniq_age = uniq( base_struc.age, sort( base_struc.age ) ) 
index_uniq_met = uniq( base_struc.metal, sort( base_struc.metal ) ) 
ssp_age_arr = base_struc[ index_uniq_age ].age
ssp_met_arr = base_struc[ index_uniq_met ].metal 
n_uniq_age = n_elements( index_uniq_age )
n_uniq_met = n_elements( index_uniq_met )
age_index_arr = indgen( n_uniq_age ) + 0.5  
met_index_arr = indgen( n_uniq_met ) + 0.5
;; 
age_log_arr = alog10( ssp_age_arr ) 
age_gyr_arr = ( ssp_age_arr / 1.0D9 )
met_sun_arr = ( ssp_met_arr / met_sun ) 
met_m2h_arr = alog10( met_sun_arr )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Summarize the contribution of xj_norm and m_cor for SSPs of the same 
;;   Age and Metallicity 
flux_norm_age = fltarr( n_uniq_age ) 
flux_norm_met = fltarr( n_uniq_met ) 
mcor_norm_age = fltarr( n_uniq_age ) 
mcor_norm_met = fltarr( n_uniq_met ) 
;; 1. For stellar ages 
for i = 0, ( n_uniq_age - 1 ), 1 do begin 
    index_age = where( base_struc.age EQ ssp_age_arr[i] ) 
    if ( ssp_age_arr[i] GE 1.0D8 ) then begin 
        age_str = strcompress( string( ( ssp_age_arr[i] / 1.0D9 ), $
            format='(F4.1)' ), /remove_all ) + 'Gyr'
    endif else begin 
        age_str = strcompress( string( ( ssp_age_arr[i] / 1.0D6 ), $
            format='(F4.1)' ), /remove_all ) + 'Myr'
    endelse
    if ( index_age[0] EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something weird just happened!  Check again!! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        base_struc[ index_age ].age_index = round( i + 1 ) 
        base_struc[ index_age ].age_str   = age_str 
        flux_norm_age[i] = total( base_struc[ index_age ].xj_norm )
        mcor_norm_age[i] = total( base_struc[ index_age ].mcor_norm )
    endelse 
endfor
;; 2. For stellar metallicity 
for i = 0, ( n_uniq_met - 1 ), 1 do begin 
    index_met = where( base_struc.metal EQ ssp_met_arr[i] ) 
    met_str = string( met_m2h_arr[i], format='(F4.1)' )
    if ( index_met[0] EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something weird just happened!  Check again!! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        messmet, ' ' 
    endif else begin 
        base_struc[ index_met ].met_index = round( i + 1 ) 
        base_struc[ index_met ].met_str   = met_str 
        flux_norm_met[i] = total( base_struc[ index_met ].xj_norm )
        mcor_norm_met[i] = total( base_struc[ index_met ].mcor_norm )
    endelse 
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____    ___     _______   _____ ___ _     _____   ;;
;;  / ___|  / \ \   / / ____| |  ___|_ _| |   | ____|  ;;
;;  \___ \ / _ \ \ / /|  _|   | |_   | || |   |  _|    ;;
;;   ___) / ___ \ V / | |___  |  _|  | || |___| |___   ;;
;;  |____/_/   \_\_/  |_____| |_|   |___|_____|_____|  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save the spec to a fits file 
if keyword_set( save_fits ) then begin 
    spec_fits = out_string + '_result.fits' 
    mwrfits, spec_struc, spec_fits, /silent, /create 
    mwrfits, sl_struc, spec_fits, /silent 
    mwrfits, base_struc, spec_fits, /silent
endif 

if keyword_set( save_txt ) then begin 
    spec_txt = out_string + '_spec.txt' 
    comma = ' , '
    openw, 20, spec_txt, width=600 
    printf, 20, '#Wavelength , Spec_OBS , Spec_SYN , Spec_RED , Spec_WEI , ' + $
        'Final_Mask , Pixel_Mask , Pixel_Clip , Pixel_Flag '
    for i = 0, ( nlobs - 1 ), 1 do begin 
        printf, 20, $
            spec_struc[i].spec_lam , comma , $ 
            spec_struc[i].spec_obs , comma , $ 
            spec_struc[i].spec_syn , comma , $ 
            spec_struc[i].spec_res , comma , $ 
            spec_struc[i].spec_wei , comma , $ 
            spec_struc[i].final_mask , comma , $ 
            spec_struc[i].pixel_mask , comma , $ 
            spec_struc[i].pixel_clip , comma , $ 
            spec_struc[i].pixel_flag 
    endfor
    close, 20 
endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

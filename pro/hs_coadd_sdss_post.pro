; + 
; NAME:
;              HS_COADD_SDSS_POST
;
; PURPOSE:
;              Post-reduce the coadded spectra 
;
; USAGE:
;    hs_coadd_post, spec_list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_coadd_sdss_post, prefix 

    ;; Make sure the following files have already been generated 
    ;;  1.  prefix + _boot.fits 
    ;;  2.  prefix + _pca.fits 
    ;;  3.  prefix + _boot_all.fits

    prefix = strcompress( prefix, /remove_all ) 
    ;; Three input file 
    fits_prep     = prefix + '.fits'
    fits_boot     = prefix + '_boot.fits' 
    fits_boot_all = prefix + '_boot_all.fits'
    fits_pca      = prefix + '_pca.fits'
    ;; Index list file 
    ;index_list = 'hs_index_all.lis'
    index_list = 'hs_index_fun.lis'

    ;; Check the file and read in 
    ;; 0 Preparation file 
    if file_test( fits_prep ) then begin 
        struc_0 = mrdfits( fits_prep, 1, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, 'Something weird with the file: ' + fits_prep 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            if ( ( tag_indx( struc_0, 'wave' ) EQ -1 ) OR $
                 ( tag_indx( struc_0, 'frac' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'snr'  ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'lquar' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'uquar' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'lifen' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'uifen' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'lofen' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'uofen' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'n_spec' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'min_rest' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'max_rest' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'min_norm' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'max_norm' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_0, 'sigma_convol' ) EQ -1 ) ) then begin 
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 print, ' The Preparation structure is incompatible !! Check !! '
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 message, ' ' 
             endif else begin 
                 n_spec       = struc_0.n_spec 
                 sigma_convol = struc_0.sigma_convol
                 min_rest     = struc_0.min_rest 
                 max_rest     = struc_0.max_rest 
                 min_norm     = struc_0.min_norm 
                 max_norm     = struc_0.max_norm
                 prep_wave    = struc_0.wave 
                 prep_lquar   = struc_0.lquar
                 prep_uquar   = struc_0.uquar
                 prep_lifen   = struc_0.lifen 
                 prep_uifen   = struc_0.uifen 
                 prep_lofen   = struc_0.lofen 
                 prep_uofen   = struc_0.uofen 
                 final_frac   = struc_0.frac
                 final_s2nr   = struc_0.final_snr 
                 n_pix_prep   = n_elements( prep_wave ) 
             endelse 
         endelse
     endif else begin 
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         print, ' Can not find the Preparation output file : ' + fits_prep
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         message, ' '
     endelse

    ;; Check the file and read in 
    ;; 1 Bootstrap output
    if file_test( fits_boot ) then begin 
        struc_1 = mrdfits( fits_boot, 1, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, 'Something weird with the file: ' + fits_boot 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            if ( ( tag_indx( struc_1, 'wave' ) EQ -1 ) OR $
                 ( tag_indx( struc_1, 'med_boot' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_1, 'avg_boot' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_1, 'sig_boot' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_1, 'min_boot' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_1, 'max_boot' ) EQ -1 ) OR $ 
                 ( tag_indx( struc_1, 'final_mask' ) EQ -1 ) ) then begin 
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 print, ' The Bootstrap structure is incompatible !! Check !! '
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 message, ' ' 
             endif else begin 
                 boot_lam = struc_1.wave 
                 boot_med = struc_1.med_boot 
                 boot_avg = struc_1.avg_boot 
                 boot_sig = struc_1.sig_boot 
                 boot_min = struc_1.min_boot 
                 boot_max = struc_1.max_boot 
                 final_mask = struc_1.final_mask 
                 n_pix_boot = n_elements( boot_lam ) 
                 if ( n_pix_boot NE n_pix_prep ) then begin 
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     print, ' Something wrong with the wavelength array '
                     print, fits_boot 
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     message, ' '
                 endif
             endelse 
         endelse
     endif else begin 
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         print, ' Can not find the Bootstrap output file : ' + fits_boot
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         message, ' '
     endelse

    ;; 2 All Bootstrap Runs
    if file_test( fits_boot_all ) then begin 
        struc_2 = mrdfits( fits_boot_all, 1, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, 'Something weird with the file: ' + fits_boot_all 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            if ( ( tag_indx( struc_2, 'wave' ) EQ -1 ) OR $
                 ( tag_indx( struc_2, 'spec_boot' ) EQ -1 ) ) then begin 
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 print, ' The Bootstrap structure is incompatible !! Check !! '
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 message, ' ' 
             endif else begin 
                 boot_lam_all = struc_2.wave
                 boot_all     = struc_2.spec_boot 
                 if ( n_elements( boot_lam_all ) NE n_pix_boot ) then begin 
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     print, ' Something wrong with the wavelength array '
                     print, fits_boot_all 
                     print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                     message, ' '
                 endif
                 n_boot = ( size( boot_all, /dimen ) )[1] 
             endelse 
         endelse
     endif else begin 
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         print, ' Can not find the all Bootstrap output file : ' + fits_boot_all
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         message, ' '
     endelse

    ;; 3 VWPCA output
    if file_test( fits_pca ) then begin 
        struc_3 = mrdfits( fits_pca, 1, status=status, /silent ) 
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, 'Something weird with the file: ' + fits_pca 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif else begin 
            if ( ( tag_indx( struc_3, 'new_wave' ) EQ -1 ) OR $
                 ( tag_indx( struc_3, 'mean_flux' ) EQ -1 ) ) then begin 
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 print, ' The VWPCA structure is incompatible !! Check !! '
                 print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                 message, ' ' 
             endif else begin 
                 pca_lam = struc_3.new_wave
                 pca_avg = struc_3.mean_flux 
                 n_pix_pca = n_elements( pca_lam ) 
             endelse 
         endelse
     endif else begin 
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         print, ' Can not find the VWPCA output file : ' + fits_pca
         print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
         message, ' '
     endelse

     ;; Wavelength range 
     wave = boot_lam
     min_lam_boot = min( boot_lam ) 
     max_lam_boot = max( boot_lam ) 
     min_lam_pca  = min( pca_lam )
     max_lam_pca  = max( pca_lam )
     min_lam = ( min_lam_boot < max_lam_boot )
     ;; Index for wavelength difference 
     index_b = where( boot_lam LE min_lam_pca, n_b )
     index_r = where( boot_lam GE max_lam_pca, n_r )
     ;; Index of bad pixels 
     index_bad = where( final_mask GT 0, n_pix_bad, complement=index_good, $
         ncomplement=n_pix_good ) 

     ;; Interpolate the pca spectra from NEW_WAVE to WAVE 
     index_inter = findex( pca_lam, boot_lam ) 
     pca_avg_inter = interpolate( pca_avg, index_inter )
     pca_mask = final_mask 
     if ( n_b NE 0 ) then begin 
         pca_mask[ index_b ] = 1 
     endif 
     if ( n_r NE 0 ) then begin 
         pca_mask[ index_r ] = 1 
     endif 
     pca_avg = pca_avg_inter 
     ;; 
     pca_avg_tmp  = pca_avg 
     boot_med_tmp = boot_med
     

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Save the STARLIGHT file 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     sl_1 = prefix + '_avg.txt'
     hs_spec_tosl, boot_lam, pca_avg_tmp,  sl_1, error=boot_sig, mask=pca_mask 
     sl_2 = prefix + '_med.txt'
     hs_spec_tosl, boot_lam, boot_med_tmp, sl_2, error=boot_sig, mask=final_mask 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Normalize the spectrum  
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; 1. The bootstrap median ones 
     ;; a: Full wavelength range, n_poly=2
     boot_norm_plot_1 = prefix + '_boot_norm_1.eps'
     boot_norm_1 = hs_spec_polynorm( wave, boot_med_tmp, 2, mask=final_mask, $
         /plot, /find_peak, eps_name=boot_norm_plot_1, $ 
         medwidth=200.0, smoothing=150.0, n_neg=10 )
     boot_norm_index_1 = hs_list_measure_index( boot_norm_1.spec_norm, $
         boot_norm_1.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=boot_line_1, $
         index_list=index_list )
     ;; b: Full wavelength range, n_poly=4
     boot_norm_plot_2 = prefix + '_boot_norm_2.eps'
     boot_norm_2 = hs_spec_polynorm( wave, boot_med_tmp, 4, mask=final_mask, $
         /plot, /find_peak, eps_name=boot_norm_plot_2, $ 
         medwidth=200.0, smoothing=150.0, n_neg=10 )
     boot_norm_index_2 = hs_list_measure_index( boot_norm_2.spec_norm, $
         boot_norm_2.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=boot_line_2, $
         index_list=index_list )
     ;; c: Full wavelength range, n_poly=6
     boot_norm_plot_3 = prefix + '_boot_norm_3.eps'
     boot_norm_3 = hs_spec_polynorm( wave, boot_med_tmp, 6, mask=final_mask, $
         /plot, /find_peak, eps_name=boot_norm_plot_3, $ 
         medwidth=200.0, smoothing=150.0, n_neg=10 )
     boot_norm_index_3 = hs_list_measure_index( boot_norm_3.spec_norm, $
         boot_norm_3.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=boot_line_3, $
         index_list=index_list )
     ;; d: Longer than 4050 Angstrom, n_poly=2
     boot_norm_plot_4 = prefix + '_boot_norm_4.eps'
     boot_norm_4 = hs_spec_polynorm( wave, boot_med_tmp, 2, mask=final_mask, $
         /plot, /find_peak, eps_name=boot_norm_plot_4, $ 
         medwidth=200.0, smoothing=150.0, norm0=4050.0, n_neg=10 )
     boot_norm_index_4 = hs_list_measure_index( boot_norm_4.spec_norm, $
         boot_norm_4.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=boot_line_4, $
         index_list=index_list )
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; 1. The PCA average ones 
     ;; a: Full wavelength range, n_poly=2
     pca_norm_plot_1 = prefix + '_pca_norm_1.eps'
     pca_norm_1 = hs_spec_polynorm( wave, pca_avg_tmp, 2, mask=pca_mask, $
         /plot, /find_peak, eps_name=pca_norm_plot_1, $ 
         medwidth=200.0, smoothing=150.0, n_neg=10 )
     pca_norm_index_1 = hs_list_measure_index( pca_norm_1.spec_norm, $
         pca_norm_1.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=pca_line_1, $
         index_list=index_list )
     ;; b: Full wavelength range, n_poly=4
     pca_norm_plot_2 = prefix + '_pca_norm_2.eps'
     pca_norm_2 = hs_spec_polynorm( wave, pca_avg_tmp, 4, mask=pca_mask, $
         /plot, /find_peak, eps_name=pca_norm_plot_2, $ 
         medwidth=200.0, smoothing=150.0, n_neg=10 )
     pca_norm_index_2 = hs_list_measure_index( pca_norm_2.spec_norm, $
         pca_norm_2.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=pca_line_2, $
         index_list=index_list )
     ;; c: Full wavelength range, n_poly=6
     pca_norm_plot_3 = prefix + '_pca_norm_3.eps'
     pca_norm_3 = hs_spec_polynorm( wave, pca_avg_tmp, 6, mask=pca_mask, $
         /plot, /find_peak, eps_name=pca_norm_plot_3, $ 
         medwidth=200.0, smoothing=150.0, n_neg=10 )
     pca_norm_index_3 = hs_list_measure_index( pca_norm_3.spec_norm, $
         pca_norm_3.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=pca_line_3, $
         index_list=index_list )
     ;; d: Longer than 4050 Angstrom, n_poly=2
     pca_norm_plot_4 = prefix + '_pca_norm_4.eps'
     pca_norm_4 = hs_spec_polynorm( wave, pca_avg_tmp, 2, mask=pca_mask, $
         /plot, /find_peak, eps_name=pca_norm_plot_4, $ 
         medwidth=200.0, smoothing=150.0, norm0=4050.0, n_neg=10 )
     pca_norm_index_4 = hs_list_measure_index( pca_norm_4.spec_norm, $
         pca_norm_4.wave, snr=800.0, /toair, /silent, $
         header_line=header_line, index_line=pca_line_4, $
         index_list=index_list )
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     norm_index_file = prefix + '_norm_index.csv' 
     openw, lun, norm_index_file, /get_lun 
     printf, lun, header_line 
     printf, lun, boot_line_1
     printf, lun, boot_line_2
     printf, lun, boot_line_3
     printf, lun, boot_line_4
     printf, lun, pca_line_1
     printf, lun, pca_line_2
     printf, lun, pca_line_3
     printf, lun, pca_line_4
     close, lun
     free_lun, lun
     ;; Convert into a fits file 
     norm_index_struc = hs_csv_tostruc( norm_index_file, /save_fits, $
         /replace_nan, nan_string='NaN', nan_value=-99999.9 )
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; XXX
     ;pca_avg[ index_bad ] = !VAlUES.F_NaN
     ;pca_avg[ index_b ]   = !VALUES.F_NaN
     ;pca_avg[ index_r ]   = !VALUES.F_NaN
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Summarize the output 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     coadd_file = prefix + '_coadd.fits'
     coadd_struc = { n_spec:n_spec, n_boot:n_boot, n_pix:n_pix_boot, $
         sigma_convol:sigma_convol, $ 
         min_rest:min_rest, max_rest:max_rest, $ 
         min_norm:min_norm, max_norm:max_norm, $
         wave:boot_lam, frac:final_frac, snr:final_s2nr, $ 
         boot_med:boot_med, boot_avg:boot_avg, boot_sig:boot_sig, $ 
         boot_mask:final_mask, boot_min:boot_min, boot_max:boot_max, $ 
         pca_avg:pca_avg, pca_mask:pca_mask, $ 
         lquar:prep_lquar, uquar:prep_uquar, $
         lifen:prep_lifen, uifen:prep_uifen, $
         lofen:prep_lofen, uofen:prep_uofen, $
         boot_norm_1:boot_norm_1.spec_norm, boot_norm_2:boot_norm_2.spec_norm, $
         boot_norm_3:boot_norm_3.spec_norm, boot_norm_4:boot_norm_4.spec_norm, $
         pca_norm_1:pca_norm_1.spec_norm, pca_norm_2:pca_norm_2.spec_norm, $
         pca_norm_3:pca_norm_3.spec_norm, pca_norm_4:pca_norm_4.spec_norm }
     mwrfits, coadd_struc, coadd_file, /create, /silent 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Make a summary plot 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;hs_coadd_sdss_plot, coadd_file, plot_list='hs_index_plot.lis'
     ;hs_coadd_sdss_plot, coadd_file, plot_list='hs_index_plot1.lis', $
     ;    prefix=prefix+'_coadd_a' 
     ;hs_coadd_sdss_plot, coadd_file, plot_list='hs_index_plot2.lis', $ 
     ;    prefix=prefix+'_coadd_b'
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     sys_time = systime(1)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Index Measurements for all bootstrap runs 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     boot_index_file = prefix + '_boot_all_index.csv' 
     stat_index_file = prefix + '_boot_all_index_stat.fits' 
     openw, lun, boot_index_file, /get_lun 
     for ii = 0, 10, 1 do begin 
         boot_all_index = hs_list_measure_index( struc_2.spec_boot[*,ii], $
             struc_2.wave, /silent, snr=600.0, /toair, $
             header_line=header_line, index_line=all_line, $ 
             index_list=index_list )
         if ( ii EQ 0 ) then begin 
             printf, lun, header_line 
         endif 
         printf, lun, all_line 
     endfor
     close, lun
     free_lun, lun
     ;; Convert into a fits file 
     all_index_struc = hs_csv_tostruc( boot_index_file, /save_fits, $
         /replace_nan, nan_string='NaN', nan_value=-99999.9 )
     name_index = get_tags( all_index_struc )
     num_index = ( n_elements( name_index ) - 1 )

     ;; Define a new structure to store the statistical results
     stat_index_struc = { index:'', med_ind:0.0, lqu_ind:0.0, uqu_ind:0.0, $ 
         min_ind:0.0, max_ind:0.0, avg_ind:0.0, sig_ind:0.0 }
     stat_index_struc = replicate( stat_index_struc, num_index )

     for jj = 1, num_index, 1 do begin 
         rstat, all_index_struc.(jj), med_ind, lqu_ind, uqu_ind, $
             lif_ind, uif_ind, lof_ind, uof_ind, min_ind, max_ind, /noprint
         resistant_mean, all_index_struc.(jj), 5.0, avg_ind, sig_ind, /double, $
             /silent 
         stat_index_struc[jj-1].index = ( strsplit( name_index[jj], '.', $
             /extract ) )[0] 
         stat_index_struc[jj-1].med_ind = med_ind
         stat_index_struc[jj-1].lqu_ind = lqu_ind
         stat_index_struc[jj-1].uqu_ind = uqu_ind
         stat_index_struc[jj-1].min_ind = min_ind
         stat_index_struc[jj-1].max_ind = max_ind
         stat_index_struc[jj-1].avg_ind = avg_ind
         stat_index_struc[jj-1].sig_ind = sig_ind
     endfor
     mwrfits, stat_index_struc, stat_index_file, /create, /silent
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;print, ( systime(1) - sys_time ), ' Seconds'

     ;; XXXX Still need to be organized !!!! 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;; Index Measurements for the PCA robust mean runs 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     mean_index_file = prefix + '_mean_index.csv' 
     openw, lun, mean_index_file, /get_lun 
     ;; Original one 
     mean_index = hs_list_measure_index( coadd_struc.pca_avg, $
             coadd_struc.wave, /silent, snr=600.0, /toair, $
             header_line=header_line, index_line=all_line, $ 
             index_list=index_list )
     printf, lun, header_line 
     printf, lun, all_line 
     ;; Normalization 1 
     mean_index = hs_list_measure_index( coadd_struc.pca_norm_1, $
             coadd_struc.wave, /silent, snr=600.0, /toair, $
             header_line=header_line, index_line=all_line, $ 
             index_list=index_list, /plot, prefix=prefix )
     printf, lun, all_line 
     ;;
     close, lun
     free_lun, lun
     ;; Convert into a fits file 
     mean_index_struc = hs_csv_tostruc( mean_index_file, /save_fits, $
         /replace_nan, nan_string='NaN', nan_value=-99999.9 )
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

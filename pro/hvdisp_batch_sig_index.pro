; + 
; NAME:
;              HVDISP_BATCH_SIG_INDEX
;
; PURPOSE:
;              Plot the relation between velocity dispersion and spectral index 
;              for HVDISP index measurements in batch mode 
;
; USAGE:
;    hvdisp_batch_sig_index, index_list=index_list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/14 - First version 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_batch_sig_index, index_list=index_list, $
    hvdisp_home=hvdisp_home 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd    = hvdisp_home + 'coadd/'
    loc_result   = hvdisp_home + 'coadd/results/index/'
    loc_indexlis = hvdisp_home + 'pro/lis/'
    loc_plot     = hvdisp_home + 'coadd/results/index/fig/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = 'hs_index_all.lis'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_list = loc_indexlis + index_list 
    if NOT file_test( index_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        print, ' Can not find the index list file: ' 
        print, index_list + '  !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        message, ' '
    endif else begin 
        index_struc = hs_read_index_list( index_list ) 
        index_names = index_struc.name
        num_index   = n_elements( index_names )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    file1 = loc_result + 'hvdisp_l_spec_robust_index_all.fits'
    file2 = loc_result + 'hvdisp_l_spec_median_index_all.fits'
    file3 = loc_result + 'hvdisp_k_spec_robust_index_all.fits'
    file4 = loc_result + 'hvdisp_k_spec_median_index_all.fits'
    file5 = loc_result + 'hvdisp_l_robust_comb_krch_index_all.fits'
    file6 = loc_result + 'hvdisp_l_median_comb_krch_index_all.fits'
    file7 = loc_result + 'hvdisp_k_robust_comb_krch_index_all.fits'
    file8 = loc_result + 'hvdisp_k_median_comb_krch_index_all.fits'
    erem1 = loc_result + 'hvdisp_l_robust_mius_ku13_index_all.fits'
    erem2 = loc_result + 'hvdisp_l_robust_mius_un13_index_all.fits'
    erem3 = loc_result + 'hvdisp_l_robust_mius_un18_index_all.fits'
    erem4 = loc_result + 'hvdisp_l_robust_mius_imix_index_all.fits'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;for ii = 0, ( num_index - 1 ), 1 do begin 
    ;; For test
    for ii = 0, 30, 1 do begin 
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        index_plot = strcompress( index_names[ ii ], /remove_all ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Group 1
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        result1 = [ file5, file1, file2 ] 
        reduse1 = [ 1, 2, 3 ]
        suffix1 = 'l_comp1'
        sample1 = [ 'PCA-Emi', 'PCA', 'MED' ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_plot_sig_index, result1, index_plot, suffix=suffix1, $ 
            red_include=reduse1, /outline, /connect, /label, /legend, $
            sample_list=sample1, loc_plot=loc_plot
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

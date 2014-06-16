; + 
; NAME:
;              HVDISP_ROBSUT_CHECK
;
; PURPOSE:
;              Tests the effect of different parameters 
;
; USAGE:
;    hvdisp_robust_check, html_list
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/10 - First version 
;
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_robust_check, html_list   

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( html_list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file : ' + html_list + ' !!!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Default parameters 
    hs_coadd_sdss_pipe, html_list, /create, /post, /avg_boot 
    ;; Default parameters, but use median
    hs_coadd_sdss_pipe, html_list, /create, /post, test_str='med' 
    ;; Robust test: niter=6 
    hs_coadd_sdss_pipe, html_list, /create, /post, /avg_boot, test_str='a', $ 
        n_boot=600, niter=6 
    ;; Robust test: niter=10 
    hs_coadd_sdss_pipe, html_list, /create, /post, /avg_boot, test_str='b', $ 
        n_boot=600, niter=10 
    ;; Robust test: nevec=8 
    hs_coadd_sdss_pipe, html_list, /create, /post, /avg_boot, test_str='c', $ 
        n_boot=600, nevec=8 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

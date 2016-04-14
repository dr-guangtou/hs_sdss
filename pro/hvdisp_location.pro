; + 
; NAME:
;              HVDISP_LOCATION
;
; PURPOSE:
;              Get the directory for HVDISP working place 
;
; USAGE:
;    hvdisp_location, hvdisp_home, data_home
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/07 - First version 
;             Song Huang, 2014/06/10 - Add path to the MIUSCAT library 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_location, hvdisp_home, data_home, mius_home=mius_home 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spawn, 'uname -a', sysinfo  
    if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
        hvdisp_home = '/Users/songhuang/Dropbox/work/project/hs_sdssspec/'
        data_home = '/Users/songhuang/Dropbox/work/project/hs_sdssspec/'
    endif else begin 
        ;; 
        hvdisp_home = '/media/hs/Astro2/hvdisp/'
        data_home   = '/media/hs/Astro2/hvdisp/'
        ;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

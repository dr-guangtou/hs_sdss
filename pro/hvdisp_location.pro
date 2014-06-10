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
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_location, hvdisp_home, data_home 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spawn, 'uname -a', sysinfo  
    if ( strpos( sysinfo, 'Darwin' ) NE -1 ) then begin 
        hvdisp_home = '/Volumes/Astro1/data/hvdisp/'
        data_home   = '/Volumes/Astro1/data/hvdisp/'
    endif else begin 
        ;; 
        hvdisp_home = '/media/hs/Astro1/data/hvdisp/'
        data_home   = '/media/hs/Astro1/data/hvdisp/'
        ;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

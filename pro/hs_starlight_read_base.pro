; + 
; NAME:
;              HS_STARLIGHT_READ_BASE
;
; PURPOSE:
;              Read in a STARLIGHT Base file
;
; USAGE:
;    base_struc = hs_starlight_read_base( base_file )
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/15 - First version 
;-
; CATEGORY:    HS_SPEC
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_starlight_read_base, base_file, dir_ssplib=dir_ssplib

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( dir_ssplib ) then begin 
        dir_ssplib = strcompress( dir_ssplib, /remove_all ) 
    endif else begin 
        dir_ssplib = '' 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    base_file = strcompress( base_file, /remove_all ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( base_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the base file: ' + base_file + ' !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Read in the mask file
        readcol, base_file, ssp_file, ssp_age, ssp_metal, ssp_index, ssp_mass, $
            ssp_yav, ssp_afe, format='A,D,F,A,F,I,F', delimiter=' ', $
            comment='#', skipline=1, count=n_ssp, /silent
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        base_struc = { file:'', age:0.0D, log_age:0.0D, metal:0.0, index:'', $
            mass:0.0, yav:0L, afe:0.0 }
        base_struc = replicate( base_struc, n_ssp )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Make the mask 
        for ii = 0, ( n_ssp - 1 ), 1 do begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            base_struc[ ii ].file    = dir_ssplib + ssp_file[ ii ]
            base_struc[ ii ].age     = ssp_age[ ii ]
            base_struc[ ii ].log_age = alog10( ssp_age[ ii ] )
            base_struc[ ii ].metal   = ssp_metal[ ii ]
            base_struc[ ii ].index   = ssp_index[ ii ]
            base_struc[ ii ].mass    = ssp_mass[ ii ]
            base_struc[ ii ].yav     = ssp_yav[ ii ]
            base_struc[ ii ].afe     = ssp_afe[ ii ]
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        endfor 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    return, base_struc
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end

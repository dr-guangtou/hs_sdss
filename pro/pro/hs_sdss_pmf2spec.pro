;+
; NAME:
;              HS_SDSS_PMF2SPEC
;
; PURPOSE:
;              Get the spectrum file name based on PLATE, MJD, and FIBERID 
;
; USAGE:
;      list_spec = hs_sdss_pmf2spec( list_plate, list_mjd, list_fiber ) 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First Version 
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

function hs_sdss_pmf2spec, list_plate, list_mjd, list_fiber 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_plate = n_elements( list_plate ) 
    n_mjd   = n_elements( list_mjd ) 
    n_fiber = n_elements( list_fiber ) 
    if ( ( n_plate NE n_mjd ) OR ( n_plate NE n_fiber ) OR $
        ( n_mjd NE n_fiber ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The three arrays should have the same number of elemetns !! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    list_spec = strarr( n_plate ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for ii = 0, ( n_plate - 1 ), 1 do begin 

        plate_str = strcompress( string( list_plate[ ii ] ), /remove_all ) 
        mjd_str   = strcompress( string( list_mjd[ ii ] ), /remove_all ) 
        fiber_str = strcompress( string( list_fiber[ ii ] ), /remove_all ) 
        ;; 
        p_len = strlen( plate_str ) 
        case p_len of 
            2 : plate_str = '00' + plate_str 
            3 : plate_str = '0'  + plate_str 
        endcase 
        ;; 
        f_len = strlen( fiber_str ) 
        case f_len of 
            1 : fiber_str = '000' + fiber_str 
            2 : fiber_str = '00'  + fiber_str 
            3 : fiber_str = '0'   + fiber_str 
        endcase 
        ;; 
        list_spec[ ii ] = 'spec-' + plate_str + '-' + mjd_str + '-' + $
            fiber_str + '.fits'

    endfor 

    ;;
    return, list_spec

end

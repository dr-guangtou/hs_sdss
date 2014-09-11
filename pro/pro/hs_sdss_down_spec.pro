; + 
; 
; NAME:
;              HS_DOWN_SDSS_SPEC
;
; PURPOSE:
;              Download a list of SDSS DR10 spectra
;
; USAGE:
;    hs_down_sdss_spec, list_file, /html, /wget, locspec=locspec, /run_download 
;
; ARGUMENTS:
;    list_file: 
;
;                                                            
; KEYWORDS:
;
; OUTPUT:
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/04 -- First version
;             Song Huang, 2014/06/05 -- Support html list as input 
; TODO LIST: 
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

pro hs_sdss_down_spec, list_file, html=html, pmf=pmf, $
    wget=wget, data_home=data_home, run_download=run_download

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp = strsplit( list_file, '.', /extract ) 
    prefix = temp[0] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location where the spectra files are stored 
    if NOT keyword_set( locspec ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        data_home = strcompress( data_home, /remove_all ) 
    endelse
    locspec = data_home + 'spec/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( pmf ) then begin 
        readcol, list_file, list_spec, format='A', delimiter=' ', /silent  
    endif else begin 
        readcol, list_file, list_plate, list_mjd, list_fiber, format='I,I,I', $
            delimiter=' ', /silent 
        list_spec = hs_sdss_pmf2spec( list_plate, list_mjd, list_fiber )
    endelse
    n_spec = n_elements( list_spec )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( wget ) then begin 
        spawn, 'which wget', download 
    endif else begin 
        spawn, 'which axel', download 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spawn, 'which parallel', parallel
    if ( parallel EQ '' ) then begin 
        no_para = 1 
    endif else begin 
        no_para = 0
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( html ) then begin 
        list_html = strarr( n_spec )
        list_loca = strarr( n_spec )
        ;;
        head = 'http://data.sdss3.org/sas/dr10/sdss/spectro/redux/26/spectra/'
        ;;
        for ii = 0L, ( n_spec - 1 ), 1 do begin 
            spec_file = list_spec[ ii ] 
            temp = strsplit( spec_file, '-.', /extract ) 
            plate = temp[1]
            ;; 
            list_html[ ii ] = head + plate + '/' + spec_file 
            ;;
            plate_str = strcompress( string( long( plate ) ), /remove_all ) 
            list_loca[ ii ] = locspec + plate_str + '/'
        endfor 
    endif else begin 
        list_html = list_spec
        list_loca = strarr( n_spec )
        list_spec = strarr( n_spec )
        ;;
        for ii = 0L, ( n_spec - 1 ), 1 do begin 
            temp = strsplit( list_html[ ii ], '/', /extract ) 
            file = temp[ ( n_elements( temp ) - 1 ) ]
            temp = strsplit( file, '-.', /extract ) 
            plate = temp[1]
            plate_str = strcompress( string( long( plate ) ), /remove_all ) 
            ;; 
            list_spec[ ii ] = file 
            list_loca[ ii ] = locspec + plate_str + '/' 
        endfor 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    openw, lun, prefix + '_down.sh', /get_lun, width=500
    for jj = 0L, ( n_spec - 1 ), 1 do begin 
        if keyword_set( wget ) then begin 
            printf, lun, 'wget ' + list_html[ jj ]
        endif else begin 
            printf, lun, 'axel ' + list_html[ jj ]
        endelse
    endfor 
    close, lun 
    free_lun, lun 
    spawn, 'chmod +x ' + prefix + '_down.sh'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    openw, lun, prefix + '_move.sh', /get_lun, width=500
    for kk = 0L, ( n_spec - 1 ), 1 do begin 
        printf, lun, 'mv ' + list_spec[ kk ] + ' ' + list_loca[ kk ]
    endfor 
    close, lun 
    free_lun, lun 
    spawn, 'chmod +x ' + prefix + '_move.sh'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( run_download ) then begin 
        if ( no_para EQ 0 ) then begin 
            spawn, parallel + ' -j+0 < ' + prefix + '_down.sh' 
        endif else begin 
            for mm = 0L, ( n_spec - 1 ), 1 do begin 
                spawn, download + ' ' + list_html[ mm ] 
            endfor 
        endelse
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

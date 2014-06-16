; + 
; NAME:
;              HS_SPEC_INDEX_OVER
;
; PURPOSE:
;              Overplot a list of spectral features on the plot 
;
; USAGE:
;    hs_spec_index_over, index_list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;             Song Huang, 2014/06/09 - Make sure the label for index is not 
;                                      overlapped with the axis 
;             Song Huang, 2014/06/09 - Correct a small typo
;             Song Huang, 2014/06/13 - Fix a small bug related to color 
;-
; CATEGORY:    HS_HVDISP
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function index_list2struc, list_file 

    list_file = strcompress( list_file, /remove_all ) 

    if NOT file_test( list_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file: ' + list_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        n_index = file_lines( list_file ) 
        index_struc = { name:'', type:0, lam0:0.0, lam1:0.0, $
            blue0:0.0, blue1:0.0, red0:0.0, red1:0.0 }
        index_struc = replicate( index_struc, n_index ) 
        ;; read in the list file 
        readcol, list_file, name, lam0, lam1, blue0, blue1, $
            red0, red1, type, format='A,F,F,F,F,F,F,I', comment='#', $
            delimiter=' ', /silent
        for ii = 0, ( n_index - 1 ), 1 do begin 
            index_struc[ii].name = name[ii]
            index_struc[ii].type = type[ii] 
            index_struc[ii].lam0 = lam0[ii]
            index_struc[ii].lam1 = lam1[ii]
            index_struc[ii].red0 = red0[ii]
            index_struc[ii].red1 = red1[ii]
            index_struc[ii].blue0 = blue0[ii]
            index_struc[ii].blue1 = blue1[ii]
        endfor
    endelse

    ;; 
    return, index_struc 

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_spec_index_over, list, label_over=label_over, $
    no_fill=no_fill, no_line=no_line, center_line=center_line, $
    color_line=color_line, color_fill=color_fill, color_char=color_char, $
    short_bar=short_bar, label_only=label_only, charsize=charsize, $
    xstep=xstep, ystep=ystep, max_overlap=max_overlap, l_cushion=l_cushion, $
    color_center=color_center

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check input list 
    list = strcompress( list, /remove_all ) 
    if NOT file_test( list ) then begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' Can not find the input list file : ' + list 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        ;; try to replace it with a default one 
        spawn, 'locate hs_index_plot.lis', loc 
        if ( loc[0] EQ '' ) then begin 
            print, ' Can not find the default index list either !'
            message, ' '
        endif else begin 
            list = loc[0]
        endelse
    endif 
    ;; Get the structure 
    struc_index = index_list2struc( list ) 

    ;; Check the wavelength array 
    ;min_wave = min( wave ) 
    ;max_wave = max( wave ) 
    min_wave = ( !X.Crange )[0]
    max_wave = ( !X.Crange )[1]
    wave_range = ( max_wave - min_wave )
    ;; 
    if keyword_set( l_cushion ) then begin 
        l_cushion = float( l_cushion ) 
    endif else begin 
        l_cushion = 80.0 
    endelse
    cushion = ( wave_range / l_cushion )
    ;; Check the flux range 
    min_flux = ( !Y.Crange )[0]
    max_flux = ( !Y.Crange )[1]
    flux_range = ( max_flux - min_flux )

    ;; Set the colors 
    if keyword_set( color_line ) then begin 
        color_line = string( color_line ) 
    endif else begin 
        color_line = 'TAN4'
    endelse
    if keyword_set( color_fill ) then begin 
        color_fill = string( color_fill ) 
    endif else begin 
        color_fill = 'TAN2'
    endelse
    if keyword_set( color_char ) then begin 
        color_char = string( color_char ) 
    endif else begin 
        color_char = 'Black'
    endelse
    if keyword_set( color_center ) then begin 
        color_center = string( color_center ) 
    endif else begin 
        color_center = 'BLK5'
    endelse
    ;; Set the charsize 
    if keyword_set( charsize ) then begin 
        charsize = float( charsize ) 
    endif else begin 
        charsize = 1.7
    endelse

    ;; Find the index that are covered by this wavelength range
    index_use = where( ( struc_index.lam0 GE ( min_wave + cushion ) ) AND $
                       ( struc_index.lam1 LE ( max_wave - cushion ) ) )

    if ( index_use[0] EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' No index is covered by this wavelength range !!!!!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    endif else begin  
        struc_use = struc_index[ index_use ]
        ;; Number of useful index 
        n_use = n_elements( struc_use.name ) 
        ;; Sort the index in the increasing order of LAM0
        struc_use = struc_use[ sort( struc_use.lam0 ) ]

        ;; Initialize the parameters to determine if the index is overlap 
        ;; with the previous one
        if keyword_set( xstep ) then begin 
            dw_overlap = ( wave_range / float( xstep ) ) ;; Angstrom 
        endif else begin 
            dw_overlap = ( wave_range / 50.0 ) ;; Angstrom 
        endelse
        lam_last = 0.0
        if keyword_set( ystep ) then begin 
            y_step = ( flux_range / float( ystep ) ) 
        endif else begin 
            y_step = ( flux_range / 40.0 ) 
        endelse
        y_over = 0
        if keyword_set( max_overlap ) then begin 
            y_max  = fix( max_overlap )
        endif else begin 
            y_max  = 8
        endelse

        for ii = 0, ( n_use - 1 ), 1 do begin 

            lam0 = struc_use[ii].lam0
            lam1 = struc_use[ii].lam1
            name = struc_use[ii].name
            type = struc_use[ii].type

            ;; Check if the index is overlap and decide the yposition 
            if ( ii NE 0 ) then begin 
                if ( lam0 LE ( lam_last + dw_overlap ) ) then begin 
                    y_over = y_over + 1 
                    y_pos = max_flux - ( ( ( y_over mod y_max ) + 1 ) * y_step )
                endif else begin 
                    y_over = 0 
                    y_pos = max_flux - y_step
                endelse
            endif else begin 
                y_over = 0 
                y_pos = max_flux - y_step 
            endelse
            lam_last = lam1

            if NOT keyword_set( label_only ) then begin 

                if NOT keyword_set( short_bar ) then begin 
                    ;; Color filled region
                    if NOT keyword_set( no_fill ) then begin 
                        x_fill = [ lam0, lam1, lam1, lam0, lam0 ]
                        y_fill = [ min_flux, min_flux, max_flux, max_flux, $
                            min_flux ]
                        cgColorFill, x_fill, y_fill, /data, $
                            color=cgColor( color_fill )
                    endif
                    ;; Boarder lines 
                    if NOT keyword_set( no_line ) then begin 
                        cgPlots, [ lam0, lam0 ], !Y.Crange, /data, $
                            linestyle=0, color=cgColor( color_line ), thick=1.8
                        cgPlots, [ lam1, lam1 ], !Y.Crange, /data, $
                            linestyle=0, color=cgColor( color_line ), thick=1.8
                    endif
                    ;; Central wavelength 
                    if keyword_set( center_line ) then begin 
                        lam_cen = ( ( lam0 + lam1 ) / 2.0 )
                        cgPlots, [ lam_cen, lam_cen ], !Y.Crange, /data, $
                            linestyle=2, color=cgColor( color_center ), $ 
                            thick=2.0
                    endif
                endif else begin 
                    cgPlots, [ lam0, lam1 ], [ y_pos, y_pos ], /data, $
                        linestyle=0, thick=10.0, color=cgColor( 'Dark Gray' )
                endelse

                if keyword_set( label_over ) then begin 
                    x_loc = ( lam0 + lam1 ) / 2.0 
                    y_loc = ( y_pos - ( flux_range / 55.0 ) )
                    label = strcompress( name, /remove_all ) 
                    cgText, x_loc, y_loc, label, charsize=charsize, $
                        charthick=5.0, color=cgColor( color_char ), $ 
                        /data, alignment=0.5 
                endif

            endif else begin 

                x_loc = ( ( lam0 + lam1 ) / 2.0 )
                y_loc = ( y_pos - ( flux_range / 55.0 ) )
                label = strcompress( name, /remove_all ) 
                if ( x_loc LE ( min_wave + dw_overlap ) ) then begin 
                    cgText, x_loc, y_loc, label, charsize=charsize, $
                        charthick=9.0, color=cgColor( color_char ), $ 
                        /data, alignment=0.0 
                endif else if ( x_loc GE ( max_wave - dw_overlap ) ) then begin 
                    cgText, x_loc, y_loc, label, charsize=charsize, $
                        charthick=9.0, color=cgColor( color_char ), $ 
                        /data, alignment=1.0 
                endif else begin 
                    cgText, x_loc, y_loc, label, charsize=charsize, $
                        charthick=9.0, color=cgColor( color_char ), $ 
                        /data, alignment=0.5
                endelse

            endelse

        endfor 

    endelse

end

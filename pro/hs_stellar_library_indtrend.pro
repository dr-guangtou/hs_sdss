; + 
; NAME:
;              HS_STELLAR_LIBRARY_INDTREND
;
; PURPOSE:
;              Plot the index trend with Teff, logg, [Fe/H] for certain 
;                stellar library
;
; USAGE:
;     hs_stellar_library_indtrend, steindex, index_list
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/09/27 - First version 
;-
; CATEGORY:   HS_STELLAR
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro hs_stellar_library_indtrend, steindex_file, index_list=index_list, $
    to_png=to_png, silent=silent, plot_afe=plot_afe

    ;; Stellar library file 
    steindex_file = strcompress( steindex_file, /remove_all )

    ;; Adjust the file name in case the input is an adress 
    temp = strsplit( steindex_file, '/ ', /extract ) 
    base_steindex = temp[ n_elements( temp ) - 1 ]
    ;; 
    prefix = hs_string_replace( steindex_file, '.fits', '' )

    ;; Read the index list into a structure 
    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = 'hs_index_all.lis' 
    endelse
    index_struc = hs_read_index_list( index_list )
    index_names = index_struc.name
    num_index   = n_elements( index_names )

    ;; Check the file 
    if NOT file_test( steindex_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, '  Can not find the spectrum : ' + steindex_file
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        if NOT keyword_set( silent ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' About to read in: ' + base_steindex
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif 

        ;; Read in the spectra 
        steindex = mrdfits( steindex_file, 1, head, /silent )

        index_good = where( ( steindex.logg GT 0.1 ) AND $
            ( steindex.teff GT 1000.0 ) ) 
        steindex_good = steindex[ index_good ]
        tags = strlowcase( tag_names( steindex_good ) )
        logt_good = alog10( steindex_good.teff )
        logg_good = steindex_good.logg 
        logf_good = steindex_good.feh

        t_range = [ ( min( logt_good ) - 0.2 ), ( max( logt_good ) + 0.2 ) ]
        g_range = [ ( min( logg_good ) - 0.2 ), ( max( logg_good ) + 0.2 ) ]
        f_range = [ ( min( logf_good ) - 0.1 ), ( max( logf_good ) + 0.1 ) ]

        if keyword_set( plot_afe ) then begin 
            afe_good = steindex_good.afe 
            afe_uniq = afe_good[ uniq( afe_good, sort( afe_good ) ) ]
            afe_num  = n_elements( afe_uniq )
            afe_color = [ 'BLU4', 'RED4', 'GRN4', 'ORG4' ]
            afe_psize = [ 1.2, 1.6, 2.0, 2.4 ]
        endif else begin 
            afe_num = 1
        endelse

        ;; set uo the figure 
        position_1 = [ 0.100, 0.18, 0.395, 0.960 ]
        position_2 = [ 0.395, 0.18, 0.690, 0.960 ]
        position_3 = [ 0.690, 0.18, 0.995, 0.960 ]

        psxsize = 46 
        psysize = 22 

        for jj = 0, ( num_index - 1 ), 1 do begin 
        ;for jj = 4, 4, 1 do begin 

            index_use = strlowcase( index_names[ jj ] )
            index_upp = strupcase( index_use )

            index_pos = where( strcmp( tags, index_use ) EQ 1 ) 
            if ( index_pos EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Can not find the index: ' + index_use + ' !!'
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                message, ' '
            endif 

            ;; plot name 
            plot_file = prefix + '_' + index_use + '.eps' 
            ;; set up the figure
            mydevice = !d.name 
            !p.font=1
            set_plot, 'ps' 
            device, filename=plot_file, font_size=9.0, /encapsulated, $
                /color, set_font='TIMES-ROMAN', /bold, $
                xsize=psxsize, ysize=psysize

            index_val = steindex_good.( index_pos )

            frac_good = ( n_elements( where( finite( index_val ) EQ 1 ) ) ) / $
                float( n_elements( index_val ) )
            if ( frac_good LT 0.5 ) then begin 
                continue 
            endif 
            
            if NOT keyword_set( silent ) then begin 
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                print, ' ' + index_upp + ' ' + string( frac_good )
                print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            endif 

            min_index = min( index_val )
            max_index = max( index_val ) 
            sep_index = ( ( max_index - min_index ) / 20.0 )
            i_range = [ ( min_index - sep_index ), ( max_index + sep_index ) ]

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; First plot, trend with age 
            cgPlot, logg_good, index_val, xstyle=1, ystyle=1, $ 
                xrange=g_range, yrange=i_range, position=position_1, $
                xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
                xtitle='log( g )', ytitle=index_upp, /nodata, /noerase 
            if ( keyword_set( plot_afe ) AND ( afe_num GT 1 ) ) then begin 
                cgOPlot, logg_good, index_val, psym=16, symsize=1.4, $
                    color=cgColor( 'BLK4' ), thick=2.0 
                for kk = 0, ( afe_num - 1 ), 1 do begin 
                    index_afe_use = where( afe_good EQ afe_uniq[ kk ] ) 
                    cgOplot, logg_good[ index_afe_use ], $
                        index_val[ index_afe_use ], psym=9, $
                        symsize=afe_psize[ kk ], $
                        color=cgColor( afe_color[ kk ] ), $
                        thick=2.5
                endfor 
            endif else begin  
                cgOPlot, logg_good, index_val, psym=16, symsize=1.6, $
                    color=cgColor( 'BLU4' ) 
                cgOPlot, logg_good, index_val, psym=9, symsize=1.6, $
                    color=cgColor( 'BLK5' )
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Second plot, trend with age 
            cgPlot, logt_good, index_val, xstyle=1, ystyle=1, $ 
                xrange=t_range, yrange=i_range, position=position_2, $
                xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
                xtitle='log( Teff/K )', ytickformat='(A1)', /nodata, /noerase 
            if ( keyword_set( plot_afe ) AND ( afe_num GT 1 ) ) then begin 
                cgOPlot, logt_good, index_val, psym=16, symsize=1.4, $
                    color=cgColor( 'BLK4' ), thick=2.0 
                for kk = 0, ( afe_num - 1 ), 1 do begin 
                    index_afe_use = where( afe_good EQ afe_uniq[ kk ] ) 
                    cgOplot, logt_good[ index_afe_use ], $
                        index_val[ index_afe_use ], psym=9, $
                        symsize=afe_psize[ kk ], $
                        color=cgColor( afe_color[ kk ] ), $
                        thick=2.5
                endfor 
            endif else begin  
                cgOPlot, logt_good, index_val, psym=16, symsize=1.6, $
                    color=cgColor( 'BLU4' ) 
                cgOPlot, logt_good, index_val, psym=9, symsize=1.6, $
                    color=cgColor( 'BLK5' )
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; Third plot, trend with age 
            cgPlot, logf_good, index_val, xstyle=1, ystyle=1, $ 
                xrange=f_range, yrange=i_range, position=position_3, $
                xthick=11.0, ythick=11.0, charsize=4.0, charthick=12.0, $ 
                xtitle='[Fe/H]', ytickformat='(A1)', /nodata, /noerase 
            if ( keyword_set( plot_afe ) AND ( afe_num GT 1 ) ) then begin 
                cgOPlot, logf_good, index_val, psym=16, symsize=1.4, $
                    color=cgColor( 'BLK4' ), thick=2.0 
                for kk = 0, ( afe_num - 1 ), 1 do begin 
                    index_afe_use = where( afe_good EQ afe_uniq[ kk ] ) 
                    cgOplot, logf_good[ index_afe_use ], $
                        index_val[ index_afe_use ], psym=9, $
                        symsize=afe_psize[ kk ], $
                        color=cgColor( afe_color[ kk ] ), $
                        thick=2.5
                endfor 
            endif else begin  
                cgOPlot, logf_good, index_val, psym=16, symsize=1.6, $
                    color=cgColor( 'BLU4' ) 
                cgOPlot, logf_good, index_val, psym=9, symsize=1.6, $
                    color=cgColor( 'BLK5' )
            endelse
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            device, /close 
            set_plot, mydevice 
            free_all

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if keyword_set( to_png ) then begin 
                spawn, 'which convert', imagick_convert 
                png_file = hs_string_replace( plot_file, '.eps', '.png' )
                if ( imagick_convert NE '' ) then begin 
                    spawn, imagick_convert + ' -density 200 ' + plot_file + $
                        ' -quality 90 -flatten ' + png_file 
                endif
            endif 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        endfor 

    endelse

end

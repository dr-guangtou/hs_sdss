;; + 
;; hvdisp_sample_select 
;; 14/06/05 SH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro save_catalog, data, index_arr, cat_name, $
    save_html=save_html, save_spec=save_spec, hvdisp_home=hvdisp_home 

    ;; 
    cat_name  = strcompress( cat_name, /remove_all ) 
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;
    fits_name = hvdisp_home + 'sample/'  + cat_name + '.fits'  
    html_name = hvdisp_home + 'html/'    + cat_name + '_html.lis'
    spec_name = hvdisp_home + 'csv/'     + cat_name + '_spec.csv'
    ;;
    if ( n_elements( index_arr ) GE 1 )  then begin 
        if ( index_arr[0] NE -1 ) then begin 
            n_save = n_elements( index_arr )
            data_save = data[ index_arr ] 
            ;; Save 
            mwrfits, data_save, fits_name, /create 
            ;; Save the html list 
            if keyword_set( save_html ) then begin 
                spec_html = strcompress( data_save.spec_html, /remove_all )
                ;;
                openw, lun, html_name, width=500, /get_lun 
                for ii = 0L, ( n_save - 1 ), 1 do begin 
                    printf, lun, spec_html[ii]
                endfor 
                close,    lun 
                free_lun, lun
            endif 
            ;; Save the spec list 
            if keyword_set( save_spec ) then begin 
                spec_html = strcompress( data_save.spec_html, /remove_all )
                par1 = strcompress( string( data_save.plate, format='(I8)' ), $
                    /remove_all )
                par2 = strcompress( string( data_save.mjd,   format='(I8)' ), $
                    /remove_all )
                par3 = strcompress( string( data_save.fiberid, format='(I8)' ), $
                    /remove_all )
                par4 = strcompress( string( data_save.veldisp_corr_ossy, $
                    format='(F10.2)' ), /remove_all )
                openw, lun, spec_name, width=900, /get_lun 
                for jj = 0L, ( n_save - 1 ), 1 do begin 
                    temp = strsplit( spec_html[jj], '/', /extract ) 
                    nseg = n_elements( temp ) 
                    spec = temp[ nseg - 1 ] 
                    printf, lun, spec + ' , ' + par1[jj] + ' , ' + par2[jj] + $
                        ' , ' + par3[jj] + ' , ' + par4[jj] 
                endfor 
                close, lun 
                free_lun, lun 
            endif 
        endif else begin 
            message, 'No useful element in the index array!! Check please !!'
        endelse 
    endif else begin 
        message, 'The index arrary is not valid !! Check please !! ' 
    endelse 

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function index_between, data, keyword, min_val, max_val, $
    n_found=n_found, lower_gt=lower_gt, upper_le=upper_le 

    on_error, 2
    compile_opt idl2

    ;;
    keyword = strcompress( keyword, /remove_all ) 
    min_val = float( min_val ) 
    max_val = float( max_val )
    ;;
    tag_key = tag_indx( data, keyword ) 
    if ( tag_key EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Keyword: ' + keyword + ' is not in the structure !!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        if keyword_set( lower_gt ) then begin 
            if keyword_set( lower_le ) then begin 
                index_use = where( ( data.( tag_key ) GT min_val ) AND $ 
                    ( data.( tag_key ) LE max_val ) )
            endif else begin  
                index_use = where( ( data.( tag_key ) GT min_val ) AND $ 
                    ( data.( tag_key ) LT max_val ) )
            endelse 
        endif else begin 
            if keyword_set( upper_le ) then begin 
                index_use = where( ( data.( tag_key ) GE min_val ) AND $ 
                    ( data.( tag_key ) LE max_val ) )
            endif else  begin 
                index_use = where( ( data.( tag_key ) GE min_val ) AND $ 
                    ( data.( tag_key ) LT max_val ) )
            endelse
        endelse
        n_found = n_elements( index_use )
        return, index_use 
    endelse

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_group_red, hvdisp_home=hvdisp_home 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( hvdisp_home ) then begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endif else begin 
        hvdisp_location, hvdisp_home, data_home
    endelse
    loccat    = hvdisp_home + 'cat/'
    locsample = hvdisp_home + 'sample/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the master catalog 
    print, '##################################################################'
    print, ' Read in hvdisp_master.fits '
    master = mrdfits( loccat + 'hvdisp_master.fits', 1, /silent )
    print, '##################################################################'
    print, ' Read in hvdisp_master_short.fits '
    short  = mrdfits( loccat + 'hvdisp_master_short.fits', 1, /silent )
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    red_a = 0.018 
    red_b = 0.075 
    red_c = 0.125 
    red_d = 0.185
    red_e = 0.045 
    red_f = 0.090
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Group the sample into different redshift bins
    index_z1 = where( ( master.z GT red_a ) AND ( master.z LE red_b ) AND $ 
                      ( master.LogMt_d_gim2d GE 10.2 ) )
    index_z2 = where( ( master.z GT red_b ) AND ( master.z LE red_c ) AND $ 
                      ( master.LogMt_d_gim2d GE 10.2 ) )
    index_z3 = where( ( master.z GT red_c ) AND ( master.z LE red_d ) AND $ 
                      ( master.LogMt_d_gim2d GE 10.2 ) )
    index_z0 = where( ( master.z GT red_e ) AND ( master.z LE red_f ) AND $ 
                      ( master.LogMt_d_gim2d GE 10.2 ) )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, red_a, ' < z <= ', red_b, ' --> ', n_elements( index_z1 ), $
        format='( F6.3, A, F6.3, A, I6 )'
    print, red_b, ' < z <= ', red_c, ' --> ', n_elements( index_z2 ), $
        format='( F6.3, A, F6.3, A, I6 )'
    print, red_c, ' < z <= ', red_d, ' --> ', n_elements( index_z3 ), $
        format='( F6.3, A, F6.3, A, I6 )'
    print, red_e, ' < z <= ', red_f, ' --> ', n_elements( index_z0 ), $
        format='( F6.3, A, F6.3, A, I6 )'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the catalog 
    save_catalog, master, index_z0, 'hvdisp_z0', /save_html, $
        hvdisp_home=hvdisp_home
    save_catalog, master, index_z1, 'hvdisp_z1', /save_html, $
        hvdisp_home=hvdisp_home
    save_catalog, master, index_z2, 'hvdisp_z2', /save_html, $
        hvdisp_home=hvdisp_home
    save_catalog, master, index_z3, 'hvdisp_z3', /save_html, $
        hvdisp_home=hvdisp_home
    ;;
    save_catalog, short , index_z0, 'hvdisp_z0_short', /save_html, $
        hvdisp_home=hvdisp_home
    save_catalog, short , index_z1, 'hvdisp_z1_short', /save_html, $
        hvdisp_home=hvdisp_home
    save_catalog, short , index_z2, 'hvdisp_z2_short', /save_html, $
        hvdisp_home=hvdisp_home
    save_catalog, short , index_z3, 'hvdisp_z3_short', /save_html, $
        hvdisp_home=hvdisp_home
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    free_all

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_group_vdp, hvdisp_home=hvdisp_home 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( hvdisp_home ) then begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endif else begin 
        hvdisp_location, hvdisp_home, data_home
    endelse
    loccat = hvdisp_home + 'sample/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the four catalogs 
    print, '##################################################################'
    z0 = mrdfits( loccat + 'hvdisp_z0.fits', 1, /silent )
    print, ' Read in hvdisp_z0.fits '
    z1 = mrdfits( loccat + 'hvdisp_z1.fits', 1, /silent )
    print, ' Read in hvdisp_z1.fits '
    z2 = mrdfits( loccat + 'hvdisp_z2.fits', 1, /silent )
    print, ' Read in hvdisp_z2.fits '
    z3 = mrdfits( loccat + 'hvdisp_z3.fits', 1, /silent )
    print, ' Read in hvdisp_z3.fits '
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; z0
    ;; Basic groups using velocity dispersion
    vdisp_key = 'veldisp_corr_ossy'
    print, ' HVDISP_Z0 Sample' 
    print, ' sample_name , n_gal , s/n expected in r-band '
    index_z0_s1 = index_between( z0, vdisp_key, 140.0, 160.0, n_found=n_z0_s1 ) 
    index_z0_s2 = index_between( z0, vdisp_key, 160.0, 180.0, n_found=n_z0_s2 ) 
    index_z0_s3 = index_between( z0, vdisp_key, 180.0, 200.0, n_found=n_z0_s3 ) 
    index_z0_s4 = index_between( z0, vdisp_key, 200.0, 220.0, n_found=n_z0_s4 ) 
    index_z0_s5 = index_between( z0, vdisp_key, 220.0, 240.0, n_found=n_z0_s5 ) 
    index_z0_s6 = index_between( z0, vdisp_key, 240.0, 260.0, n_found=n_z0_s6 ) 
    index_z0_s7 = index_between( z0, vdisp_key, 260.0, 290.0, n_found=n_z0_s7 ) 
    index_z0_s8 = index_between( z0, vdisp_key, 290.0, 330.0, n_found=n_z0_s8 ) 
    print, 'z0_s1', n_z0_s1, ( sqrt( n_z0_s1 ) * $
        median( z0[index_z0_s1].snMedian_r ) )
    print, 'z0_s2', n_z0_s2, ( sqrt( n_z0_s2 ) * $
        median( z0[index_z0_s2].snMedian_r ) )
    print, 'z0_s3', n_z0_s3, ( sqrt( n_z0_s3 ) * $
        median( z0[index_z0_s3].snMedian_r ) ) 
    print, 'z0_s4', n_z0_s4, ( sqrt( n_z0_s4 ) * $
        median( z0[index_z0_s4].snMedian_r ) )
    print, 'z0_s5', n_z0_s5, ( sqrt( n_z0_s5 ) * $
        median( z0[index_z0_s5].snMedian_r ) ) 
    print, 'z0_s6', n_z0_s6, ( sqrt( n_z0_s6 ) * $
        median( z0[index_z0_s6].snMedian_r ) )
    print, 'z0_s7', n_z0_s7, ( sqrt( n_z0_s7 ) * $
        median( z0[index_z0_s7].snMedian_r ) )
    print, 'z0_s8', n_z0_s8, ( sqrt( n_z0_s8 ) * $
        median( z0[index_z0_s8].snMedian_r ) )
    ;; Save the catalog 
    save_catalog, z0, index_z0_s1, 'z0_s1', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s2, 'z0_s2', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s3, 'z0_s3', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s4, 'z0_s4', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s5, 'z0_s5', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s6, 'z0_s6', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s7, 'z0_s7', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_s8, 'z0_s8', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    
    ;; Basic groups using stellar mass 
    lmass_key = 'logMt_d_gim2d'
    index_z0_m1 = index_between( z0, lmass_key, 10.4, 10.6, n_found=n_z0_m1 )
    index_z0_m2 = index_between( z0, lmass_key, 10.6, 10.8, n_found=n_z0_m2 )
    index_z0_m3 = index_between( z0, lmass_key, 10.8, 10.9, n_found=n_z0_m3 )
    index_z0_m4 = index_between( z0, lmass_key, 10.9, 11.0, n_found=n_z0_m4 )
    index_z0_m5 = index_between( z0, lmass_key, 11.0, 11.2, n_found=n_z0_m5 )
    index_z0_m6 = index_between( z0, lmass_key, 11.2, 11.4, n_found=n_z0_m6 )
    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    print, 'z0_m1', n_z0_m1, ( sqrt( n_z0_m1 ) * $
        median( z0[index_z0_m1].snMedian_r ) )
    print, 'z0_m2', n_z0_m2, ( sqrt( n_z0_m2 ) * $
        median( z0[index_z0_m2].snMedian_r ) )
    print, 'z0_m3', n_z0_m3, ( sqrt( n_z0_m3 ) * $ 
        median( z0[index_z0_m3].snMedian_r ) )
    print, 'z0_m4', n_z0_m4, ( sqrt( n_z0_m4 ) * $ 
        median( z0[index_z0_m4].snMedian_r ) )
    print, 'z0_m5', n_z0_m5, ( sqrt( n_z0_m5 ) * $ 
        median( z0[index_z0_m5].snMedian_r ) )
    print, 'z0_m6', n_z0_m6, ( sqrt( n_z0_m6 ) * $
        median( z0[index_z0_m6].snMedian_r ) )
    ;; Save catalogs 
    save_catalog, z0, index_z0_m1, 'z0_m1', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_m2, 'z0_m2', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_m3, 'z0_m3', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_m4, 'z0_m4', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_m5, 'z0_m5', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z0, index_z0_m6, 'z0_m6', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; z1
    ;; Basic groups using velocity dispersion
    vdisp_key = 'veldisp_corr_ossy'
    print, ' HVDISP_Z1 Sample' 
    print, ' sample_name , n_gal , s/n expected in r-band '
    index_z1_s1 = index_between( z1, vdisp_key, 140.0, 160.0, n_found=n_z1_s1 ) 
    index_z1_s2 = index_between( z1, vdisp_key, 160.0, 180.0, n_found=n_z1_s2 ) 
    index_z1_s3 = index_between( z1, vdisp_key, 180.0, 200.0, n_found=n_z1_s3 ) 
    index_z1_s4 = index_between( z1, vdisp_key, 200.0, 220.0, n_found=n_z1_s4 ) 
    index_z1_s5 = index_between( z1, vdisp_key, 220.0, 240.0, n_found=n_z1_s5 ) 
    index_z1_s6 = index_between( z1, vdisp_key, 240.0, 260.0, n_found=n_z1_s6 ) 
    index_z1_s7 = index_between( z1, vdisp_key, 260.0, 290.0, n_found=n_z1_s7 ) 
    index_z1_s8 = index_between( z1, vdisp_key, 290.0, 330.0, n_found=n_z1_s8 ) 
    print, 'z1_s1', n_z1_s1, ( sqrt( n_z1_s1 ) * $
        median( z1[index_z1_s1].snMedian_r ) )
    print, 'z1_s2', n_z1_s2, ( sqrt( n_z1_s2 ) * $
        median( z1[index_z1_s2].snMedian_r ) )
    print, 'z1_s3', n_z1_s3, ( sqrt( n_z1_s3 ) * $
        median( z1[index_z1_s3].snMedian_r ) ) 
    print, 'z1_s4', n_z1_s4, ( sqrt( n_z1_s4 ) * $
        median( z1[index_z1_s4].snMedian_r ) )
    print, 'z1_s5', n_z1_s5, ( sqrt( n_z1_s5 ) * $
        median( z1[index_z1_s5].snMedian_r ) ) 
    print, 'z1_s6', n_z1_s6, ( sqrt( n_z1_s6 ) * $
        median( z1[index_z1_s6].snMedian_r ) )
    print, 'z1_s7', n_z1_s7, ( sqrt( n_z1_s7 ) * $
        median( z1[index_z1_s7].snMedian_r ) )
    print, 'z1_s8', n_z1_s8, ( sqrt( n_z1_s8 ) * $
        median( z1[index_z1_s8].snMedian_r ) )
    ;; Save the catalog 
    save_catalog, z1, index_z1_s1, 'z1_s1', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s2, 'z1_s2', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s3, 'z1_s3', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s4, 'z1_s4', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s5, 'z1_s5', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s6, 'z1_s6', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s7, 'z1_s7', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z1, index_z1_s8, 'z1_s8', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; z2
    ;; Basic groups using velocity dispersion
    vdisp_key = 'veldisp_corr_ossy'
    print, ' HVDISP_Z2 Sample' 
    print, ' sample_name , n_gal , s/n expected in r-band '
    index_z2_s2 = index_between( z2, vdisp_key, 160.0, 180.0, n_found=n_z2_s2 ) 
    index_z2_s3 = index_between( z2, vdisp_key, 180.0, 200.0, n_found=n_z2_s3 ) 
    index_z2_s4 = index_between( z2, vdisp_key, 200.0, 220.0, n_found=n_z2_s4 ) 
    index_z2_s5 = index_between( z2, vdisp_key, 220.0, 240.0, n_found=n_z2_s5 ) 
    index_z2_s6 = index_between( z2, vdisp_key, 240.0, 260.0, n_found=n_z2_s6 ) 
    index_z2_s7 = index_between( z2, vdisp_key, 260.0, 290.0, n_found=n_z2_s7 ) 
    index_z2_s8 = index_between( z2, vdisp_key, 290.0, 330.0, n_found=n_z2_s8 ) 
    print, 'z2_s2', n_z2_s2, ( sqrt( n_z2_s2 ) * $
        median( z2[index_z2_s2].snMedian_r ) )
    print, 'z2_s3', n_z2_s3, ( sqrt( n_z2_s3 ) * $
        median( z2[index_z2_s3].snMedian_r ) ) 
    print, 'z2_s4', n_z2_s4, ( sqrt( n_z2_s4 ) * $
        median( z2[index_z2_s4].snMedian_r ) )
    print, 'z2_s5', n_z2_s5, ( sqrt( n_z2_s5 ) * $
        median( z2[index_z2_s5].snMedian_r ) ) 
    print, 'z2_s6', n_z2_s6, ( sqrt( n_z2_s6 ) * $
        median( z2[index_z2_s6].snMedian_r ) )
    print, 'z2_s7', n_z2_s7, ( sqrt( n_z2_s7 ) * $
        median( z2[index_z2_s7].snMedian_r ) )
    print, 'z2_s8', n_z2_s8, ( sqrt( n_z2_s8 ) * $
        median( z2[index_z2_s8].snMedian_r ) )
    ;; Save the catalog 
    save_catalog, z2, index_z2_s2, 'z2_s2', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z2, index_z2_s3, 'z2_s3', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z2, index_z2_s4, 'z2_s4', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z2, index_z2_s5, 'z2_s5', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z2, index_z2_s6, 'z2_s6', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z2, index_z2_s7, 'z2_s7', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z2, index_z2_s8, 'z2_s8', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; z3
    ;; Basic groups using velocity dispersion
    vdisp_key = 'veldisp_corr_ossy'
    print, ' HVDISP_Z3 Sample' 
    print, ' sample_name , n_gal , s/n expected in r-band '
    index_z3_s3 = index_between( z3, vdisp_key, 180.0, 200.0, n_found=n_z3_s3 ) 
    index_z3_s4 = index_between( z3, vdisp_key, 200.0, 220.0, n_found=n_z3_s4 ) 
    index_z3_s5 = index_between( z3, vdisp_key, 220.0, 240.0, n_found=n_z3_s5 ) 
    index_z3_s6 = index_between( z3, vdisp_key, 240.0, 260.0, n_found=n_z3_s6 ) 
    index_z3_s7 = index_between( z3, vdisp_key, 260.0, 290.0, n_found=n_z3_s7 ) 
    index_z3_s8 = index_between( z3, vdisp_key, 290.0, 330.0, n_found=n_z3_s8 ) 
    print, 'z3_s3', n_z3_s3, ( sqrt( n_z3_s3 ) * $
        median( z3[index_z3_s3].snMedian_r ) ) 
    print, 'z3_s4', n_z3_s4, ( sqrt( n_z3_s4 ) * $
        median( z3[index_z3_s4].snMedian_r ) )
    print, 'z3_s5', n_z3_s5, ( sqrt( n_z3_s5 ) * $
        median( z3[index_z3_s5].snMedian_r ) ) 
    print, 'z3_s6', n_z3_s6, ( sqrt( n_z3_s6 ) * $
        median( z3[index_z3_s6].snMedian_r ) )
    print, 'z3_s7', n_z3_s7, ( sqrt( n_z3_s7 ) * $
        median( z3[index_z3_s7].snMedian_r ) )
    print, 'z3_s8', n_z3_s8, ( sqrt( n_z3_s8 ) * $
        median( z3[index_z3_s8].snMedian_r ) )
    ;; Save the catalog 
    save_catalog, z3, index_z3_s3, 'z3_s3', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z3, index_z3_s4, 'z3_s4', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z3, index_z3_s5, 'z3_s5', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z3, index_z3_s6, 'z3_s6', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z3, index_z3_s7, 'z3_s7', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    save_catalog, z3, index_z3_s8, 'z3_s8', /save_html, /save_spec, $
        hvdisp_home=hvdisp_home 
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Basic sub-sample list 
    locsample = hvdisp_home + 'sample/'
    spawn, 'ls ' + locsample + 'z?_[ms]?.fits > ' + locsample + $ 
        'hvdisp_subsample.lis'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 
    free_all

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_group_etg, hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    locsample = hvdisp_home + 'sample/'
    ;; Read in the list
    readcol, locsample + 'hvdisp_subsample.lis', files, format='A', $
        delimiter=' ', comment='#', /silent 
    n_file = n_elements( files )
    ;; 
    for ii = 0L, ( n_file - 1 ), 1 do begin 
        temp = strsplit( files[ii], '/.', /extract ) 
        pref = strcompress( temp[ n_elements( temp ) - 2 ], /remove_all ) 
        temp = strsplit( files[ii], '/', /extract ) 
        file = strcompress( temp[ n_elements( temp ) - 1 ], /remove_all ) 
        print, '##############################################################'
        print, ' Subsample : ' + pref 
        print, '##############################################################'
        ;;
        group = mrdfits( locsample + file, 1, /silent ) 
        ;; 
        ;; Early / Late -type subsample 
        ;; Morph2010 ETG/LTG
        print, '##############################################################'
        ;;;;;;;
        index_a = where( group.probaE_morph GT 0.70 ) 
        n_temp =  n_elements( index_a )
        print, pref+'_a (ETG/Morph) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_a].snMedian_r ) ) 
        ;;;;;;;
        index_b = where( group.probaE_morph LE 0.70 ) 
        n_temp =  n_elements( index_b )
        print, pref+'_b (LTG/Morph) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_b].snMedian_r ) ) 
        ;;;;;;;
        index_l = where( group.probaEll_morph GT 0.60 ) 
        n_temp =  n_elements( index_l )
        print, pref+'_l (ELL/Morph) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_l].snMedian_r ) ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; GalaxyZoo ETG/LTG
        index_c = where( group.p_e_zoo GT 0.50 ) 
        n_temp =  n_elements( index_c )
        print, pref+'_c (ETG/GZoo)  ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_c].snMedian_r ) ) 
        ;;;;;;;
        index_d = where( group.p_e_zoo LE 0.50 ) 
        n_temp =  n_elements( index_d )
        print, pref+'_d (LTG/GZoo)  ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_d].snMedian_r ) ) 
        print, '##############################################################'
        ;;;;;;;
        save_catalog, group, index_a, pref+'a', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home
        save_catalog, group, index_b, pref+'b', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        save_catalog, group, index_c, pref+'c', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        save_catalog, group, index_d, pref+'d', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        save_catalog, group, index_l, pref+'l', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor 
    print, '##############################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    spawn, 'ls ' + locsample + 'z?_*[abcdl].fits > ' + locsample + $
        'hvdisp_morph.lis '
    ;;
    free_all

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_group_emi, hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    locsample = hvdisp_home + 'sample/'
    ;; Read in the list
    readcol, locsample + 'hvdisp_subsample.lis', files, format='A', $
        delimiter=' ', comment='#', /silent 
    n_file = n_elements( files )
    ;; 
    for ii = 0L, ( n_file - 1 ), 1 do begin 
        ;;
        temp = strsplit( files[ii], './', /extract ) 
        pref = strcompress( temp[ n_elements( temp ) - 2 ], /remove_all ) 
        temp = strsplit( files[ii], '/', /extract ) 
        file = strcompress( temp[ n_elements( temp ) - 1 ], /remove_all ) 
        print, '##############################################################'
        print, ' Subsample : ' + pref 
        print, '##############################################################'
        ;;
        group = mrdfits( locsample + file, 1, /silent ) 
        ;; 
        group.bpt_port = strcompress( strupcase( group.bpt_port ), /remove_all )
        ;; 
        ;; Based on BPT diagram
        print, '##############################################################'
        ;;;;;;; Port
        index_e = where( ( group.bpt_port NE 'STARFORMING' ) AND $ 
                         ( group.bpt_port NE 'SEYFERT'     ) ) 
        n_temp =  n_elements( index_e )
        print, pref+'_e (BPT/Port) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_e].snMedian_r ) ) 
        ;;;;;;; MPA
        index_f = where( ( group.bpt_mpa NE 1 ) AND $ 
                         ( group.bpt_mpa NE 4 ) ) 
        n_temp =  n_elements( index_f )
        print, pref+'_f (BPT/MPA ) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_f].snMedian_r ) ) 
        ;;
        ;; Based on AON of emission lines
        index_g = where( ( group.aon_ha6562_ossy   LE 5.0 ) AND $ 
                         ( group.aon_oiii4958_ossy LE 3.5 ) AND $
                         ( group.aon_hb4861_ossy   LE 3.5 ) ) 
        n_temp =  n_elements( index_g )
        print, pref+'_g (AON / 3 ) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_g].snMedian_r ) ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        save_catalog, group, index_e, pref+'e', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        save_catalog, group, index_f, pref+'f', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home
        save_catalog, group, index_g, pref+'g', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home  
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor 
    print, '##############################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; 
    spawn, 'ls ' + locsample + 'z?_*[efg].fits > ' + locsample + $
        'hvdisp_emiline.lis '
    ;;
    free_all

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_group_fin, hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    locsample = hvdisp_home + 'sample/'
    ;; Read in the list
    readcol, locsample + 'hvdisp_subsample.lis', files, format='A', $
        delimiter=' ', comment='#', /silent 
    n_file = n_elements( files )
    ;; 
    for ii = 0L, ( n_file - 1 ), 1 do begin 
        temp = strsplit( files[ii], '/.', /extract ) 
        pref = strcompress( temp[ n_elements( temp ) - 2 ], /remove_all ) 
        temp = strsplit( files[ii], '/', /extract ) 
        file = strcompress( temp[ n_elements( temp ) - 1 ], /remove_all ) 
        print, '##############################################################'
        print, ' Subsample : ' + pref 
        print, '##############################################################'
        ;;
        group = mrdfits( locsample + file, 1, /silent ) 
        ;; 
        ;; Early Type and No Emission Line
        print, '##############################################################'
        ;;;;;;;
        index_h = where( ( group.p_e_zoo GT 0.50 ) AND $
                         ( group.bpt_port NE 'STARFORMING' ) AND $ 
                         ( group.bpt_port NE 'SEYFERT'     ) )
        n_temp =  n_elements( index_h )
        print, pref+'_h (Zoo_ETG + BPT_Port) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_h].snMedian_r ) ) 
        ;;;;;;;
        index_i = where( ( group.probaE_morph GT 0.70 ) AND $ 
                         ( group.bpt_port NE 'STARFORMING' ) AND $ 
                         ( group.bpt_port NE 'SEYFERT'     ) )
        n_temp =  n_elements( index_i )
        print, pref+'_i (Morph_ETG+BPT_Port) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_i].snMedian_r ) ) 
        ;;;;;;;
        index_j = where( ( group.p_e_zoo GT 0.50 ) AND $ 
                         ( group.aon_ha6562_ossy   LE 5.0 ) AND $ 
                         ( group.aon_oiii4958_ossy LE 3.5 ) AND $
                         ( group.aon_hb4861_ossy   LE 3.5 ) ) 
        n_temp =  n_elements( index_j )
        print, pref+'_j (Zoo_ETG + AON_Ossy) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_j].snMedian_r ) ) 
        ;;;;;;;
        index_k = where( ( group.probaE_morph GT 0.7 ) AND $ 
                         ( group.aon_ha6562_ossy   LE 5.0 ) AND $ 
                         ( group.aon_oiii4958_ossy LE 3.5 ) AND $
                         ( group.aon_hb4861_ossy   LE 3.5 ) ) 
        n_temp =  n_elements( index_k )
        print, pref+'_k (Morph_ETG+AON_Ossy) ', n_temp, $
            ( sqrt( n_temp ) * median( group[index_k].snMedian_r ) ) 
        print, '##############################################################'
        ;;;;;;;
        save_catalog, group, index_h, pref+'h', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home
        save_catalog, group, index_i, pref+'i', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        save_catalog, group, index_j, pref+'j', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home
        save_catalog, group, index_k, pref+'k', /save_html, /save_spec, $
            hvdisp_home=hvdisp_home 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endfor 
    print, '##############################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    spawn, 'ls ' + locsample + 'z?_*[hijk].fits > ' + locsample + $
        'hvdisp_final.lis '
    ;;
    free_all

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_post_stats, hvdisp_home=hvdisp_home, mass_cut=mass_cut

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location for the fits file 
    locsample = hvdisp_home + 'sample/'
    spawn, 'ls ' + locsample + 'z?_*.fits', list_files 
    n_files = n_elements( list_files )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location for the stats file 
    locstats = hvdisp_home + 'stats/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; List of interesting quantities 
    keywords = [ 'z' , 'snMedian_r', 'scale', $
        'veldisp_corr_ossy', 'veldisp_corr', 'veldisp_corr_port', $ 
        'p_e_zoo', 'probaE_morph', $  ;; Morphology
        'logMs_p_port', 'logMs_mpa', 'logMs_d_gim2d', 'LogMt_d_gim2d', $ ;; Mass
        'devRadc_r', 'devAB_r', 'petroR50c_g', $
        'rec_r_ser_gim2d', 'e_ser_gim2d', 'rec_r_bpd_gim2d', $
        'grcolor_ser_gim2d', 'n_ser_gim2d', 'grcolor_bpd_gim2d', $
        'ngal_tempel', 'den_4mpc_tempel', 'logM_group_yang', 'logMh_mas_yang' ]
    keywords = strupcase( keywords )
    n_keywords = n_elements( keywords )

    ;; Output strcture 
    stats = { key:'', num:0.0, min:0.0, max:0.0, $
        avg:0.0, med:0.0, sig:0.0, adv:0.0, var:0.0, skw:0.0, kur:0.0, $
        lquar:0.0, uquar:0.0, lifen:0.0, lofen:0.0, uifen:0.0, uofen:0.0 }
    stats = replicate( stats, n_keywords ) 
    ;; 
    results = { sample:'', stats:stats } 
    results = replicate( results, n_files )

    ;; 
    if keyword_set( mass_cut ) then begin 
        prefix = 'hvdisp_sample_bstat_m'
    endif else begin 
        prefix = 'hvdisp_sample_bstat'
    endelse

    openw,  lun, locstats + prefix + '.dat', /get_lun, width=400 
    printf, lun, '#      PARAMETER      AVG      MED      SIG      ADEV   '  
    ;; 
    for ii = 0, ( n_files - 1 ), 1 do begin 

        fits_file = strcompress( list_files[ ii ], /remove_all )
        ;; 
        temp = strsplit( fits_file, './', /extract ) 
        sample = temp[ n_elements( temp ) - 2 ]
        
        data = mrdfits( fits_file, 1, /silent ) 

        ;; Mass limit ?
        if keyword_set( mass_cut ) then begin 
            index_use = where( data.logMt_d_gim2d GT 11.0 ) 
            n_use = n_elements( index_use ) 
            if ( n_use GT 50 ) then begin 
                sample = sample + '_m'
                data = data[ index_use ]
            endif 
        endif 

        ;; Sample name
        results[ ii ].sample = sample 
        print, '##############################################################'
        print, ' SAMPLE : ' + sample
        print, '##############################################################'

        ;; Tag names
        tags = strcompress( tag_names( data ), /remove_all )
        tags = strupcase( tags )

        printf, lun, '#########################################################'
        printf, lun, ' Sample : ' + sample + ' ' + string( n_elements( data.z ) )
        printf, lun, '#########################################################'

        for jj = 0, ( n_keywords - 1 ), 1 do begin 

            key = strcompress( keywords[ jj ], /remove_all ) 
            results[ ii ].stats[ jj ].key = key
            
            index_num = where( strcmp( tags, key ) EQ 1 ) 
            if ( index_num EQ -1 ) then begin 
                print, 'Something wrong with the keyword ! '
                message, ' '
            endif 

            para = data.( index_num )

            output = hs_basic_stats( para, sig_cut=3.0 ) 
            results[ ii ].stats[ jj ].num = output.num 
            results[ ii ].stats[ jj ].min = output.min 
            results[ ii ].stats[ jj ].max = output.max 
            results[ ii ].stats[ jj ].avg = output.avg 
            results[ ii ].stats[ jj ].med = output.med 
            results[ ii ].stats[ jj ].sig = output.sig 
            results[ ii ].stats[ jj ].adv = output.adv 
            results[ ii ].stats[ jj ].var = output.var 
            results[ ii ].stats[ jj ].lquar = output.lquar 
            results[ ii ].stats[ jj ].uquar = output.uquar 
            results[ ii ].stats[ jj ].lifen = output.lifen 
            results[ ii ].stats[ jj ].lofen = output.lofen 
            results[ ii ].stats[ jj ].uifen = output.uifen 
            results[ ii ].stats[ jj ].uofen = output.uofen 

            ;; 
            printf, lun, key, output.avg, output.med, output.sig, output.adv, $
                format='( A20 , 4F10.3 )'

        endfor 
        printf, lun, '##########################################################'
        printf, lun, ' '

    endfor 

    ;; 
    close, lun 
    free_lun, lun

    ;; Save the results 
    save, results, filename=( locstats + prefix + '.sav' )

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_plot_scale, sav_file, plot_name, xtitle, ytitle, $
    x_bin=x_bin, y_bin=y_bin, hvdisp_home=hvdisp_home
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Restore the IDL_SAVE file 
    restore, sav_file 
    ;; Location for the figure 
    locfig = hvdisp_home + 'fig/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Set up the figure 
    pos1 = [ 0.07, 0.16, 0.37, 0.98 ]
    pos2 = [ 0.37, 0.16, 0.67, 0.98 ]
    pos3 = [ 0.67, 0.16, 0.97, 0.98 ]
    psxsize = 72
    psysize = 27 
    mydevice = !d.name 
    !p.font=1
    set_plot, 'ps' 
    device, filename=( locfig + plot_name ), font_size=9.0, /encapsulated, $
        /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; X/Y-range
    min_x = min( [ min( z1_x_new ), min( z3_x_new ) ] )
    max_x = max( [ max( z1_x_new ), max( z3_x_new ) ] )
    min_y = min( [ min( z1_y_new ), min( z3_y_new ) ] )
    max_y = max( [ max( z1_y_new ), max( z3_y_new ) ] )
    xrange = [ min_x*0.99, max_x*1.01 ]
    yrange = [ min_y*0.99, max_y*1.01 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z1 
    cgLoadCT, 0
    hogg_scatterplot, z1_x_new, z1_y_new, exponent=0.8, /nocontour, $
        outpsym=2, outcolor=cgColor( 'BLK4' ), $
        outsymsize=1.3, xnpix=50.0, ynpix=50.0, $
        xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=pos1, $
        xthick=13.0, ythick=13.0, xtitle=xtitle, ytitle=ytitle, $
        charsize=5.0, charthick=6.0, /internal_weight, /outliers, darkest=100, $
        /noerase, xticklen=0.03, yticklen=0.03

    xx   = !X.CRange 
    yy_0 = ( z0_par[0] + z0_par[1] * ( xx - pivot_z0 ) ) 
    yy_1 = ( z1_par[0] + z1_par[1] * ( xx - pivot_z1 ) ) 
    yy_2 = ( z2_par[0] + z2_par[1] * ( xx - pivot_z2 ) ) 
    yy_3 = ( z3_par[0] + z3_par[1] * ( xx - pivot_z3 ) ) 

    ;;
    cgOplot, xx, yy_0, linestyle=5, thick=12.0, color=cgColor( 'BLK7' ) 
    cgOplot, xx, ( yy_0 - z0_rms ), linestyle=1, thick=6.0, $
        color=cgColor( 'BLK6' ) 
    cgOplot, xx, ( yy_0 + z0_rms ), linestyle=1, thick=6.0, $
        color=cgColor( 'BLK6' ) 

    ;;
    cgOplot, xx, yy_1, linestyle=0, thick=10.0, color=cgColor( 'Green' ) 
    cgOplot, xx, ( yy_1 - z1_rms ), linestyle=2, thick=10.0, $
        color=cgColor( 'Lime Green' ) 
    cgOplot, xx, ( yy_1 + z1_rms ), linestyle=2, thick=10.0, $
        color=cgColor( 'Lime Green' ) 

    ;; Put text 
    if ( z1_par[1] GT 0.0 ) then begin 
        xt = ( !X.CRange[1] - ( ( !X.CRange[1] - !X.CRange[0] ) * 0.43 ) )
        dy = ( !Y.CRange[1] - !Y.CRange[0] ) * 0.05
        yt = ( !Y.CRange[0] + ( 3.2 * dy ) )
    endif else begin 
        xt = ( !X.CRange[1] - ( ( !X.CRange[1] - !X.CRange[0] ) * 0.43 ) )
        dy = ( !Y.CRange[1] - !Y.CRange[0] ) * 0.05
        yt = ( !Y.CRange[1] - ( 1.1 * dy ) )
    endelse
    ;;
    txt = ['a = ', 'b = ', textoidl('\varepsilon_y = ')]
    for j = 0, 2, 1 do begin  
        txt[j] = txt[j] + string( z1_par[j], FORMAT='(F6.3)' ) + $
            textoidl(' \pm ') + string( z1_parsig[j], FORMAT='(F6.3)' )
        cgText, xt, yt, txt[j], charsize=4.0, charthick=6.0 
        yt = ( yt - dy )
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z2 
    cgLoadCT, 0
    hogg_scatterplot, z2_x_new, z2_y_new, exponent=1.0, satfrac=0.01, $
        outpsym=2, outcolor=cgColor( 'BLK4' ), $
        outsymsize=1.3, xnpix=60.0, ynpix=60.0, $
        xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=pos2, $
        xthick=13.0, ythick=13.0, xtitle=xtitle, ytickformat='(A1)', $
        charsize=5.0, charthick=6.0, /internal_weight, /outliers, darkest=100, $
        /noerase, xticklen=0.03, yticklen=0.03

    ;;
    cgOplot, xx, yy_0, linestyle=5, thick=12.0, color=cgColor( 'BLK7' ) 
    cgOplot, xx, ( yy_0 - z0_rms ), linestyle=1, thick=6.0, $
        color=cgColor( 'BLK6' ) 
    cgOplot, xx, ( yy_0 + z0_rms ), linestyle=1, thick=6.0, $
        color=cgColor( 'BLK6' ) 

    ;;
    cgOplot, xx, yy_2, linestyle=0, thick=10.0, color=cgColor( 'Red' ) 
    cgOplot, xx, ( yy_2 - z2_rms ), linestyle=2, thick=10.0, $
        color=cgColor( 'Red' ) 
    cgOplot, xx, ( yy_2 + z2_rms ), linestyle=2, thick=10.0, $
        color=cgColor( 'Red' ) 

    ;; Put text 
    if ( z2_par[1] GT 0.0 ) then begin 
        xt = ( !X.CRange[1] - ( ( !X.CRange[1] - !X.CRange[0] ) * 0.45 ) )
        dy = ( !Y.CRange[1] - !Y.CRange[0] ) * 0.05
        yt = ( !Y.CRange[0] + ( 3.2 * dy ) )
    endif else begin 
        xt = ( !X.CRange[1] - ( ( !X.CRange[1] - !X.CRange[0] ) * 0.45 ) )
        dy = ( !Y.CRange[1] - !Y.CRange[0] ) * 0.05
        yt = ( !Y.CRange[1] - ( 1.1 * dy ) )
    endelse
    ;;
    txt = ['a = ', 'b = ', textoidl('\varepsilon_y = ')]
    for j = 0, 2, 1 do begin  
        txt[j] = txt[j] + string( z2_par[j], FORMAT='(F7.3)' ) + $
            textoidl(' \pm ') + string( z2_parsig[j], FORMAT='(F7.3)' )
        cgText, xt, yt, txt[j], charsize=4.0, charthick=6.0 
        yt = ( yt - dy )
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z3 
    cgLoadCT, 0
    hogg_scatterplot, z3_x_new, z3_y_new, exponent=1.0, $
        outpsym=2, outcolor=cgColor( 'BLK4' ), $
        outsymsize=1.3, xnpix=60.0, ynpix=60.0, $
        xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=pos3, $
        xthick=13.0, ythick=13.0, xtitle=xtitle, ytickformat='(A1)', $
        charsize=5.0, charthick=6.0, /internal_weight, /outliers, darkest=100, $
        /noerase, xticklen=0.03, yticklen=0.03

    ;;
    cgOplot, xx, yy_0, linestyle=5, thick=12.0, color=cgColor( 'BLK7' ) 
    cgOplot, xx, ( yy_0 - z0_rms ), linestyle=1, thick=6.0, $
        color=cgColor( 'BLK6' ) 
    cgOplot, xx, ( yy_0 + z0_rms ), linestyle=1, thick=6.0, $
        color=cgColor( 'BLK6' ) 

    ;;
    cgOplot, xx, yy_3, linestyle=0, thick=10.0, color=cgColor( 'Blue' ) 
    cgOplot, xx, ( yy_3 - z3_rms ), linestyle=2, thick=10.0, $
        color=cgColor( 'Blue' ) 
    cgOplot, xx, ( yy_3 + z3_rms ), linestyle=2, thick=10.0, $
        color=cgColor( 'Blue' ) 

    ;; Put text 
    if ( z3_par[1] GT 0.0 ) then begin 
        xt = ( !X.CRange[1] - ( ( !X.CRange[1] - !X.CRange[0] ) * 0.43 ) )
        dy = ( !Y.CRange[1] - !Y.CRange[0] ) * 0.05
        yt = ( !Y.CRange[0] + ( 3.2 * dy ) )
    endif else begin 
        xt = ( !X.CRange[1] - ( ( !X.CRange[1] - !X.CRange[0] ) * 0.43 ) )
        dy = ( !Y.CRange[1] - !Y.CRange[0] ) * 0.05
        yt = ( !Y.CRange[1] - ( 1.1 * dy ) )
    endelse
    ;;
    txt = ['a = ', 'b = ', textoidl('\varepsilon_y = ')]
    for j = 0, 2, 1 do begin  
        txt[j] = txt[j] + string( z3_par[j], FORMAT='(F6.3)' ) + $
            textoidl(' \pm ') + string( z3_parsig[j], FORMAT='(F6.3)' )
        cgText, xt, yt, txt[j], charsize=4.0, charthick=6.0 
        yt = ( yt - dy )
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    device, /close 
    set_plot, mydevice 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_post_scale, z0_x, z0_y, z0_xe, z0_ye, $
                       z1_x, z1_y, z1_xe, z1_ye, $
                       z2_x, z2_y, z2_xe, z2_ye, $
                       z3_x, z3_y, z3_xe, z3_ye, $
                       xtitle, ytitle, prefix, $
                       min_x, max_x, min_y, max_y, $
                       plot=plot, same_pivot=same_pivot, bayes=bayes, $
                       hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Location for the stats file 
    locstats = hvdisp_home + 'stats/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_z0 = where( ( z0_x GE min_x ) AND ( z0_x LE max_x ) AND $ 
                      ( z0_y GE min_y ) AND ( z0_y LE max_y ) )
    index_z1 = where( ( z1_x GE min_x ) AND ( z1_x LE max_x ) AND $ 
                      ( z1_y GE min_y ) AND ( z1_y LE max_y ) )
    index_z2 = where( ( z2_x GE min_x ) AND ( z2_x LE max_x ) AND $ 
                      ( z2_y GE min_y ) AND ( z2_y LE max_y ) )
    index_z3 = where( ( z3_x GE min_x ) AND ( z3_x LE max_x ) AND $ 
                      ( z3_y GE min_y ) AND ( z3_y LE max_y ) )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_z0 = n_elements( index_z0 )
    n_z1 = n_elements( index_z1 )
    n_z2 = n_elements( index_z2 )
    n_z3 = n_elements( index_z3 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    z0_x_new  = z0_x[ index_z0 ]
    z0_y_new  = z0_y[ index_z0 ]
    z0_xe_new = z0_xe[ index_z0 ]
    z0_ye_new = z0_ye[ index_z0 ]
    z1_x_new  = z1_x[ index_z1 ]
    z1_y_new  = z1_y[ index_z1 ]
    z1_xe_new = z1_xe[ index_z1 ]
    z1_ye_new = z1_ye[ index_z1 ]
    z2_x_new  = z2_x[ index_z2 ]
    z2_y_new  = z2_y[ index_z2 ]
    z2_xe_new = z2_xe[ index_z2 ]
    z2_ye_new = z2_ye[ index_z2 ]
    z3_x_new  = z3_x[ index_z3 ]
    z3_y_new  = z3_y[ index_z3 ]
    z3_xe_new = z3_xe[ index_z3 ]
    z3_ye_new = z3_ye[ index_z3 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( same_pivot ) then begin 
        pivot_z0 = median( z0_x_new, /even )
        pivot_z1 = median( z0_x_new, /even )
        pivot_z2 = median( z0_x_new, /even )
        pivot_z3 = median( z0_x_new, /even )
        prefix   = prefix + '_same' 
    endif else begin 
        pivot_z0 = median( z0_x_new, /even )
        pivot_z1 = median( z1_x_new, /even )
        pivot_z2 = median( z2_x_new, /even )
        pivot_z3 = median( z3_x_new, /even )
        prefix = prefix 
    endelse
    if keyword_set( bayes ) then begin 
        prefix = prefix + '_bayes'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    xtitle = xtitle 
    ytitle = ytitle 
    prefix = prefix
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, '###################################################################'
    print, ' Z_0 : ', xtitle, ' v.s. ', ytitle, n_z0 
    ;; 
    if keyword_set( bayes ) then begin 
        lts_linefit, z0_x_new, z0_y_new, z0_xe_new, z0_ye_new, $
            z0_par, z0_parsig, z0_chisq, /bayes, pivot=pivot_z0, rms=z0_rms
    endif else begin 
        lts_linefit, z0_x_new, z0_y_new, z0_xe_new, z0_ye_new, $
            z0_par, z0_parsig, z0_chisq, pivot=pivot_z0, rms=z0_rms
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, '###################################################################'
    print, ' Z_1 : ', xtitle, ' v.s. ', ytitle, n_z1 
    ;; 
    if keyword_set( bayes ) then begin 
        lts_linefit, z1_x_new, z1_y_new, z1_xe_new, z1_ye_new, $
            z1_par, z1_parsig, z1_chisq, /bayes, pivot=pivot_z1, rms=z1_rms
    endif else begin 
        lts_linefit, z1_x_new, z1_y_new, z1_xe_new, z1_ye_new, $
            z1_par, z1_parsig, z1_chisq, pivot=pivot_z1, rms=z1_rms
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, '###################################################################'
    print, ' Z_2 : ', xtitle, ' v.s. ', ytitle, n_z2 
    ;; 
    if keyword_set( bayes ) then begin 
        lts_linefit, z2_x_new, z2_y_new, z2_xe_new, z2_ye_new, $
            z2_par, z2_parsig, z2_chisq, /bayes, pivot=pivot_z2, rms=z2_rms
    endif else begin 
        lts_linefit, z2_x_new, z2_y_new, z2_xe_new, z2_ye_new, $
            z2_par, z2_parsig, z2_chisq, pivot=pivot_z2, rms=z2_rms
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    print, '###################################################################'
    print, ' Z_3 : ', xtitle, ' v.s. ', ytitle, n_z3 
    ;; 
    if keyword_set( bayes ) then begin 
        lts_linefit, z3_x_new, z3_y_new, z3_xe_new, z3_ye_new, $
            z3_par, z3_parsig, z3_chisq, /bayes, pivot=pivot_z3, rms=z3_rms
    endif else begin 
        lts_linefit, z3_x_new, z3_y_new, z3_xe_new, z3_ye_new, $
            z3_par, z3_parsig, z3_chisq, pivot=pivot_z3, rms=z3_rms
    endelse
    ;; 
    print, '###################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save result
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    openw,  lun, locstats + prefix + '.txt', /get_lun, width=300
    printf, lun, '##############################################################'
    printf, lun, '# ' + ytitle + ' = a + b * ( ' + xtitle + ' - PIVOT ) '
    printf, lun, '#z  a  sig_a  b  sig_b  c  sig_c  pivot  chi2  rms  num '
    printf, lun, 'z0', z0_par[0], z0_parsig[0], z0_par[1], z0_parsig[1], $ 
                       z0_par[2], z0_parsig[2], pivot_z0, $
                       z0_chisq, z0_rms, n_z0, $
                       format='(A, 9F11.3, I6)'
    printf, lun, 'z1', z1_par[0], z1_parsig[0], z1_par[1], z1_parsig[1], $ 
                       z1_par[2], z1_parsig[2], pivot_z1, $
                       z1_chisq, z1_rms, n_z1, $
                       format='(A, 9F11.3, I6)'
    printf, lun, 'z2', z2_par[0], z2_parsig[0], z2_par[1], z2_parsig[1], $ 
                       z2_par[2], z2_parsig[2], pivot_z2, $
                       z2_chisq, z2_rms, n_z2, $
                       format='(A, 9F11.3, I6)'
    printf, lun, 'z3', z3_par[0], z3_parsig[0], z3_par[1], z3_parsig[1], $ 
                       z3_par[2], z3_parsig[2], pivot_z3, $
                       z3_chisq, z3_rms, n_z3, $
                       format='(A, 9F11.3, I6)'
    printf, lun, '##############################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the results 
    sav_file = ( locstats + prefix + '.sav' )
    save, /variables, filename=sav_file
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Make a plot
    if keyword_set( plot ) then begin 
        plot_name = ( prefix + '.eps' )
        hvdisp_plot_scale, sav_file, plot_name, xtitle, ytitle  
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_list_scale, hvdisp_home=hvdisp_home, $
    vdsp_cut=vdsp_cut, mass_cut=mass_cut, pzoo_cut=pzoo_cut, $
    mass_comp=mass_comp, vdsp_comp=vdsp_comp, logr_comp=logr_comp, $
    mass_size=mass_size, vdsp_size=vdsp_size, mass_vdsp=mass_vdsp, $
    same_pivot=same_pivot

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    locsample = hvdisp_home + 'sample/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the four catalogs 
    print, '##################################################################'
    z0 = mrdfits( locsample + 'hvdisp_z0.fits', 1 )
    print, ' Read in hvdisp_z0.fits '
    z1 = mrdfits( locsample + 'hvdisp_z1.fits', 1 )
    print, ' Read in hvdisp_z1.fits '
    z2 = mrdfits( locsample + 'hvdisp_z2.fits', 1 )
    print, ' Read in hvdisp_z2.fits '
    z3 = mrdfits( locsample + 'hvdisp_z3.fits', 1 )
    print, ' Read in hvdisp_z3.fits '
    print, '##################################################################'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Velocity dispersion cut
    if NOT keyword_set( vdsp_cut ) then begin 
        vdsp_cut = 170.0  ;; km/s 
    endif else begin 
        vdsp_cut = float( vdsp_cut )
    endelse
    ;; Mass cut
    if NOT keyword_set( mass_cut ) then begin 
        mass_cut = 10.85 
    endif else begin 
        mass_cut = float( mass_cut )
    endelse
    ;; P_E_Zoo cut 
    if NOT keyword_set( pzoo_cut ) then begin 
        pzoo_cut = 0.5 
    endif else begin 
        pzoo_cut = float( pzoo_cut )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mass_str = strcompress( string( mass_cut, format='(F6.2)' ), /remove_all )
    mass_str = 'm' + mass_str
    vdsp_str = strcompress( string( vdsp_cut, format='(I4)'   ), /remove_all )
    vdsp_str = 'v' + vdsp_str
    pzoo_str = strcompress( string( pzoo_cut, format='(F4.1)' ), /remove_all )
    pzoo_str = 'z' + pzoo_str
    sample_str = mass_str + '_' + vdsp_str + '_' + pzoo_str
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    z0_use = where( ( z0.veldisp_corr_ossy GT vdsp_cut ) AND $ 
                    ( z0.logMs_d_gim2d     GT mass_cut ) AND $
                    ( z0.p_e_zoo           GT pzoo_cut ) AND $
                    ( z0.aon_ha6562_ossy   LE 5.0      ) AND $ 
                    ( z0.aon_oiii4958_ossy LE 3.5      ) ) 
    ;;;;;;
    z1_use = where( ( z1.veldisp_corr_ossy GT vdsp_cut ) AND $ 
                    ( z1.logMs_d_gim2d     GT mass_cut ) AND $
                    ( z1.p_e_zoo           GT pzoo_cut ) AND $
                    ( z1.aon_ha6562_ossy   LE 5.0      ) AND $ 
                    ( z1.aon_oiii4958_ossy LE 3.5      ) ) 
    ;;;;;;
    z2_use = where( ( z2.veldisp_corr_ossy GT vdsp_cut ) AND $ 
                    ( z2.logMs_d_gim2d     GT mass_cut ) AND $
                    ( z2.p_e_zoo           GT pzoo_cut ) AND $
                    ( z2.aon_ha6562_ossy   LE 5.0      ) AND $ 
                    ( z2.aon_oiii4958_ossy LE 3.5      ) ) 
    ;;;;;;
    z3_use = where( ( z3.veldisp_corr_ossy GT vdsp_cut ) AND $ 
                    ( z3.logMs_d_gim2d     GT mass_cut ) AND $
                    ( z3.p_e_zoo           GT pzoo_cut ) AND $
                    ( z3.aon_ha6562_ossy   LE 5.0      ) AND $ 
                    ( z3.aon_oiii4958_ossy LE 3.5      ) ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    z0 = z0[ z0_use ]
    z1 = z1[ z1_use ]
    z2 = z2[ z2_use ]
    z3 = z3[ z3_use ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z0
    ;; vdsp
    z0_vdsp_a     = alog10( z0.veldisp_corr_ossy )
    z0_vdsp_a_err = alog10( z0.veldisp_corr_ossy + z0.veldisperr_ossy ) - $
        z0_vdsp_a
    z0_vdsp_b     = alog10( z0.veldisp_corr_port )
    z0_vdsp_b_err = alog10( z0.veldisp_corr_port + z0.veldisperr_port ) - $
        z0_vdsp_b
    z0_vdsp_c     = alog10( z0.veldisp_corr )
    z0_vdsp_c_err = alog10( z0.veldisp_corr + z0.veldisperr ) - z0_vdsp_c
    ;; mass 
    z0_mass_a     = z0.logMs_d_gim2d  
    z0_mass_a_err = ( z0_mass_a * 0.0 ) + 0.10
    z0_mass_b     = z0.logMt_d_gim2d  
    z0_mass_b_err = ( z0_mass_b * 0.0 ) + 0.10
    z0_mass_c     = z0.logMs_mpa 
    z0_mass_c_err = z0.logMsErr_mpa
    z0_mass_d     = z0.logMs_p_port 
    z0_mass_d_err = z0.logMsErr_p_port
    ;; re 
    z0_logr_a     = alog10( z0.rec_r_ser_gim2d )
    z0_logr_a_err = ( z0_logr_a * 0.0 ) + 0.06 
    z0_logr_b     = alog10( z0.rec_r_bpd_gim2d )
    z0_logr_b_err = ( z0_logr_b * 0.0 ) + 0.06 
    z0_logr_c     = alog10( z0.devRadc_r ) 
    z0_logr_c_err = ( z0_logr_c * 0.0 ) + 0.06 
    z0_logr_d     = alog10( z0.petroR50c_g ) 
    z0_logr_d_err = ( z0_logr_d * 0.0 ) + 0.06
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z1
    ;; vdsp
    z1_vdsp_a     = alog10( z1.veldisp_corr_ossy )
    z1_vdsp_a_err = alog10( z1.veldisp_corr_ossy + z1.veldisperr_ossy ) - $
        z1_vdsp_a
    z1_vdsp_b     = alog10( z1.veldisp_corr_port )
    z1_vdsp_b_err = alog10( z1.veldisp_corr_port + z1.veldisperr_port ) - $
        z1_vdsp_b
    z1_vdsp_c     = alog10( z1.veldisp_corr )
    z1_vdsp_c_err = alog10( z1.veldisp_corr + z1.veldisperr ) - z1_vdsp_c
    ;; mass 
    z1_mass_a     = z1.logMs_d_gim2d  
    z1_mass_a_err = ( z1_mass_a * 0.0 ) + 0.10
    z1_mass_b     = z1.logMt_d_gim2d  
    z1_mass_b_err = ( z1_mass_b * 0.0 ) + 0.10
    z1_mass_c     = z1.logMs_mpa 
    z1_mass_c_err = z1.logMsErr_mpa
    z1_mass_d     = z1.logMs_p_port 
    z1_mass_d_err = z1.logMsErr_p_port
    ;; re 
    z1_logr_a     = alog10( z1.rec_r_ser_gim2d )
    z1_logr_a_err = ( z1_logr_a * 0.0 ) + 0.06 
    z1_logr_b     = alog10( z1.rec_r_bpd_gim2d )
    z1_logr_b_err = ( z1_logr_b * 0.0 ) + 0.06 
    z1_logr_c     = alog10( z1.devRadc_r ) 
    z1_logr_c_err = ( z1_logr_c * 0.0 ) + 0.06 
    z1_logr_d     = alog10( z1.petroR50c_g ) 
    z1_logr_d_err = ( z1_logr_d * 0.0 ) + 0.06
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z2
    ;; vdsp
    z2_vdsp_a     = alog10( z2.veldisp_corr_ossy )
    z2_vdsp_a_err = alog10( z2.veldisp_corr_ossy + z2.veldisperr_ossy ) - $
        z2_vdsp_a
    z2_vdsp_b     = alog10( z2.veldisp_corr_port )
    z2_vdsp_b_err = alog10( z2.veldisp_corr_port + z2.veldisperr_port ) - $
        z2_vdsp_b
    z2_vdsp_c     = alog10( z2.veldisp_corr )
    z2_vdsp_c_err = alog10( z2.veldisp_corr + z2.veldisperr ) - z2_vdsp_c
    ;; mass 
    z2_mass_a     = z2.logMs_d_gim2d  
    z2_mass_a_err = ( z2_mass_a * 0.0 ) + 0.10
    z2_mass_b     = z2.logMt_d_gim2d  
    z2_mass_b_err = ( z2_mass_b * 0.0 ) + 0.10
    z2_mass_c     = z2.logMs_mpa 
    z2_mass_c_err = z2.logMsErr_mpa
    z2_mass_d     = z2.logMs_p_port 
    z2_mass_d_err = z2.logMsErr_p_port
    ;; re 
    z2_logr_a     = alog10( z2.rec_r_ser_gim2d )
    z2_logr_a_err = ( z2_logr_a * 0.0 ) + 0.06 
    z2_logr_b     = alog10( z2.rec_r_bpd_gim2d )
    z2_logr_b_err = ( z2_logr_b * 0.0 ) + 0.06 
    z2_logr_c     = alog10( z2.devRadc_r ) 
    z2_logr_c_err = ( z2_logr_c * 0.0 ) + 0.06
    z2_logr_d     = alog10( z2.petroR50c_g ) 
    z2_logr_d_err = ( z2_logr_d * 0.0 ) + 0.06
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Z3
    ;; vdsp
    z3_vdsp_a     = alog10( z3.veldisp_corr_ossy )
    z3_vdsp_a_err = alog10( z3.veldisp_corr_ossy + z3.veldisperr_ossy ) - $
        z3_vdsp_a
    z3_vdsp_b     = alog10( z3.veldisp_corr_port )
    z3_vdsp_b_err = alog10( z3.veldisp_corr_port + z3.veldisperr_port ) - $
        z3_vdsp_b
    z3_vdsp_c     = alog10( z3.veldisp_corr )
    z3_vdsp_c_err = alog10( z3.veldisp_corr + z3.veldisperr ) - z3_vdsp_c
    ;; mass 
    z3_mass_a     = z3.logMs_d_gim2d  
    z3_mass_a_err = ( z3_mass_a * 0.0 ) + 0.10
    z3_mass_b     = z3.logMt_d_gim2d  
    z3_mass_b_err = ( z3_mass_b * 0.0 ) + 0.10
    z3_mass_c     = z3.logMs_mpa 
    z3_mass_c_err = z3.logMsErr_mpa
    z3_mass_d     = z3.logMs_p_port 
    z3_mass_d_err = z3.logMsErr_p_port
    ;; re 
    z3_logr_a     = alog10( z3.rec_r_ser_gim2d )
    z3_logr_a_err = ( z3_logr_a * 0.0 ) + 0.06 
    z3_logr_b     = alog10( z3.rec_r_bpd_gim2d )
    z3_logr_b_err = ( z3_logr_b * 0.0 ) + 0.06 
    z3_logr_c     = alog10( z3.devRadc_r ) 
    z3_logr_c_err = ( z3_logr_c * 0.0 ) + 0.06 
    z3_logr_d     = alog10( z3.petroR50c_g ) 
    z3_logr_d_err = ( z3_logr_d * 0.0 ) + 0.06
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( mass_size ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Mass-Size
    if keyword_set( same_pivot ) then begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_a, z0_mass_a_err, z0_logr_a_err, $ 
                           z1_mass_a, z1_logr_a, z1_mass_a_err, z1_logr_a_err, $ 
                           z2_mass_a, z2_logr_a, z2_mass_a_err, z2_logr_a_err, $ 
                           z3_mass_a, z3_logr_a, z3_mass_a_err, z3_logr_a_err, $ 
                           'logMt_d_gim2d', 'logRec_ser_gim2d', $
                           'hvdisp_logm_logr_1_' + sample_str, $
                           mass_cut, 11.99, -0.25, 2.00, /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_b, z0_mass_a_err, z0_logr_b_err, $ 
                           z1_mass_a, z1_logr_b, z1_mass_a_err, z1_logr_b_err, $ 
                           z2_mass_a, z2_logr_b, z2_mass_a_err, z2_logr_b_err, $ 
                           z3_mass_a, z3_logr_b, z3_mass_a_err, z3_logr_b_err, $ 
                           'logMt_d_gim2d', 'logRec_bpt_gim2d', $
                           'hvdisp_logm_logr_2_' + sample_str, $
                           mass_cut, 11.99, -0.25, 2.00, /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_c, z0_mass_a_err, z0_logr_c_err, $ 
                           z1_mass_a, z1_logr_c, z1_mass_a_err, z1_logr_c_err, $ 
                           z2_mass_a, z2_logr_c, z2_mass_a_err, z2_logr_c_err, $ 
                           z3_mass_a, z3_logr_c, z3_mass_a_err, z3_logr_c_err, $ 
                           'logMt_d_gim2d', 'logDevRadc_r', $
                           'hvdisp_logm_logr_3_' + sample_str, $ 
                           mass_cut, 11.99, -0.25, 2.00, /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_d, z0_mass_a_err, z0_logr_d_err, $ 
                           z1_mass_a, z1_logr_d, z1_mass_a_err, z1_logr_d_err, $ 
                           z2_mass_a, z2_logr_d, z2_mass_a_err, z2_logr_d_err, $ 
                           z3_mass_a, z3_logr_d, z3_mass_a_err, z3_logr_d_err, $ 
                           'logMt_d_gim2d', 'logPrtroR50c_g', $
                           'hvdisp_logm_logr_4_' + sample_str, $ 
                           mass_cut, 11.99, -0.25, 2.00, /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif else begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_a, z0_mass_a_err, z0_logr_a_err, $ 
                           z1_mass_a, z1_logr_a, z1_mass_a_err, z1_logr_a_err, $ 
                           z2_mass_a, z2_logr_a, z2_mass_a_err, z2_logr_a_err, $ 
                           z3_mass_a, z3_logr_a, z3_mass_a_err, z3_logr_a_err, $ 
                           'logMt_d_gim2d', 'logRec_ser_gim2d', $
                           'hvdisp_logm_logr_1_' + sample_str, $
                           mass_cut, 11.99, -0.25, 2.00, /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_b, z0_mass_a_err, z0_logr_b_err, $ 
                           z1_mass_a, z1_logr_b, z1_mass_a_err, z1_logr_b_err, $ 
                           z2_mass_a, z2_logr_b, z2_mass_a_err, z2_logr_b_err, $ 
                           z3_mass_a, z3_logr_b, z3_mass_a_err, z3_logr_b_err, $ 
                           'logMt_d_gim2d', 'logRec_bpt_gim2d', $
                           'hvdisp_logm_logr_2_' + sample_str, $
                           mass_cut, 11.99, -0.25, 2.00, /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_c, z0_mass_a_err, z0_logr_c_err, $ 
                           z1_mass_a, z1_logr_c, z1_mass_a_err, z1_logr_c_err, $ 
                           z2_mass_a, z2_logr_c, z2_mass_a_err, z2_logr_c_err, $ 
                           z3_mass_a, z3_logr_c, z3_mass_a_err, z3_logr_c_err, $ 
                           'logMt_d_gim2d', 'logDevRadc_r', $
                           'hvdisp_logm_logr_3_' + sample_str, $ 
                           mass_cut, 11.99, -0.25, 2.00, /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_logr_d, z0_mass_a_err, z0_logr_d_err, $ 
                           z1_mass_a, z1_logr_d, z1_mass_a_err, z1_logr_d_err, $ 
                           z2_mass_a, z2_logr_d, z2_mass_a_err, z2_logr_d_err, $ 
                           z3_mass_a, z3_logr_d, z3_mass_a_err, z3_logr_d_err, $ 
                           'logMt_d_gim2d', 'logPrtroR50c_g', $
                           'hvdisp_logm_logr_4_' + sample_str, $ 
                           mass_cut, 11.99, -0.25, 2.00, /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( vdsp_size ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Vdsp-Size
    if keyword_set( same_pivot ) then begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_a, z0_vdsp_a_err, z0_logr_a_err, $ 
                           z1_vdsp_a, z1_logr_a, z1_vdsp_a_err, z1_logr_a_err, $ 
                           z2_vdsp_a, z2_logr_a, z2_vdsp_a_err, z2_logr_a_err, $ 
                           z3_vdsp_a, z3_logr_a, z3_vdsp_a_err, z3_logr_a_err, $ 
                           'logVdispc_ossy', 'logRec_ser_gim2d', $
                           'hvdisp_logvd_logr_1_' + sample_str, $
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $
                           /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_b, z0_vdsp_a_err, z0_logr_b_err, $ 
                           z1_vdsp_a, z1_logr_b, z1_vdsp_a_err, z1_logr_b_err, $ 
                           z2_vdsp_a, z2_logr_b, z2_vdsp_a_err, z2_logr_b_err, $ 
                           z3_vdsp_a, z3_logr_b, z3_vdsp_a_err, z3_logr_b_err, $ 
                           'logVdispc_ossy', 'logRec_bpt_gim2d', $
                           'hvdisp_logvd_logr_2_' + sample_str, $
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $
                           /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_c, z0_vdsp_a_err, z0_logr_c_err, $ 
                           z1_vdsp_a, z1_logr_c, z1_vdsp_a_err, z1_logr_c_err, $ 
                           z2_vdsp_a, z2_logr_c, z2_vdsp_a_err, z2_logr_c_err, $ 
                           z3_vdsp_a, z3_logr_c, z3_vdsp_a_err, z3_logr_c_err, $ 
                           'logVdispc_ossy', 'logDevRadc_r', $
                           'hvdisp_logvd_logr_3_' + sample_str, $ 
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $ 
                           /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_d, z0_vdsp_a_err, z0_logr_d_err, $ 
                           z1_vdsp_a, z1_logr_d, z1_vdsp_a_err, z1_logr_d_err, $ 
                           z2_vdsp_a, z2_logr_d, z2_vdsp_a_err, z2_logr_d_err, $ 
                           z3_vdsp_a, z3_logr_d, z3_vdsp_a_err, z3_logr_d_err, $ 
                           'logVdispc_ossy', 'logPetroR50c_g', $
                           'hvdisp_logvd_logr_4_' + sample_str, $ 
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $
                           /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif else begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_a, z0_vdsp_a_err, z0_logr_a_err, $ 
                           z1_vdsp_a, z1_logr_a, z1_vdsp_a_err, z1_logr_a_err, $ 
                           z2_vdsp_a, z2_logr_a, z2_vdsp_a_err, z2_logr_a_err, $ 
                           z3_vdsp_a, z3_logr_a, z3_vdsp_a_err, z3_logr_a_err, $ 
                           'logVdispc_ossy', 'logRec_ser_gim2d', $
                           'hvdisp_logvd_logr_1_' + sample_str, $
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $
                           /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_b, z0_vdsp_a_err, z0_logr_b_err, $ 
                           z1_vdsp_a, z1_logr_b, z1_vdsp_a_err, z1_logr_b_err, $ 
                           z2_vdsp_a, z2_logr_b, z2_vdsp_a_err, z2_logr_b_err, $ 
                           z3_vdsp_a, z3_logr_b, z3_vdsp_a_err, z3_logr_b_err, $ 
                           'logVdispc_ossy', 'logRec_bpt_gim2d', $
                           'hvdisp_logvd_logr_2_' + sample_str, $
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $
                           /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_c, z0_vdsp_a_err, z0_logr_c_err, $ 
                           z1_vdsp_a, z1_logr_c, z1_vdsp_a_err, z1_logr_c_err, $ 
                           z2_vdsp_a, z2_logr_c, z2_vdsp_a_err, z2_logr_c_err, $ 
                           z3_vdsp_a, z3_logr_c, z3_vdsp_a_err, z3_logr_c_err, $ 
                           'logVdispc_ossy', 'logDevRadc_r', $
                           'hvdisp_logvd_logr_3_' + sample_str, $ 
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $ 
                           /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_vdsp_a, z0_logr_d, z0_vdsp_a_err, z0_logr_d_err, $ 
                           z1_vdsp_a, z1_logr_d, z1_vdsp_a_err, z1_logr_d_err, $ 
                           z2_vdsp_a, z2_logr_d, z2_vdsp_a_err, z2_logr_d_err, $ 
                           z3_vdsp_a, z3_logr_d, z3_vdsp_a_err, z3_logr_d_err, $ 
                           'logVdispc_ossy', 'logPetroR50c_g', $
                           'hvdisp_logvd_logr_4_' + sample_str, $ 
                           alog10( vdsp_cut ), 2.54, -0.25, 2.00, $
                           /plot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( mass_vdsp ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; mass_vdsp
    if keyword_set( same_pivot ) then begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_vdsp_a, z0_mass_a_err, z0_vdsp_a_err, $ 
                           z1_mass_a, z1_vdsp_a, z1_mass_a_err, z1_vdsp_a_err, $ 
                           z2_mass_a, z2_vdsp_a, z2_mass_a_err, z2_vdsp_a_err, $ 
                           z3_mass_a, z3_vdsp_a, z3_mass_a_err, z3_vdsp_a_err, $ 
                           'logMs_d_gim2d', 'logVdsp_corr_ossy', $
                           'hvdisp_logm_logvd_1_' + sample_str, $
                           alog10( mass_cut ), 11.99, alog10( vdsp_cut ), 2.54, $
                           /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_b, z0_vdsp_a, z0_mass_b_err, z0_vdsp_a_err, $ 
                           z1_mass_b, z1_vdsp_a, z1_mass_b_err, z1_vdsp_a_err, $ 
                           z2_mass_b, z2_vdsp_a, z2_mass_b_err, z2_vdsp_a_err, $ 
                           z3_mass_b, z3_vdsp_a, z3_mass_b_err, z3_vdsp_a_err, $ 
                           'logMt_d_gim2d', 'logVdsp_corr_ossy', $
                           'hvdisp_logm_logvd_2_' + sample_str, $
                           alog10( mass_cut ), 11.99, alog10( vdsp_cut ), 2.54, $
                           /plot, /same_pivot 
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif else begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_a, z0_vdsp_a, z0_mass_a_err, z0_vdsp_a_err, $ 
                           z1_mass_a, z1_vdsp_a, z1_mass_a_err, z1_vdsp_a_err, $ 
                           z2_mass_a, z2_vdsp_a, z2_mass_a_err, z2_vdsp_a_err, $ 
                           z3_mass_a, z3_vdsp_a, z3_mass_a_err, z3_vdsp_a_err, $ 
                           'logMs_d_gim2d', 'logVdsp_corr_ossy', $
                           'hvdisp_logm_logvd_1_' + sample_str, $
                           alog10( mass_cut ), 11.99, alog10( vdsp_cut ), 2.54, $
                           /plot
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hvdisp_post_scale, z0_mass_b, z0_vdsp_a, z0_mass_b_err, z0_vdsp_a_err, $ 
                           z1_mass_b, z1_vdsp_a, z1_mass_b_err, z1_vdsp_a_err, $ 
                           z2_mass_b, z2_vdsp_a, z2_mass_b_err, z2_vdsp_a_err, $ 
                           z3_mass_b, z3_vdsp_a, z3_mass_b_err, z3_vdsp_a_err, $ 
                           'logMt_d_gim2d', 'logVdsp_corr_ossy', $
                           'hvdisp_logm_logvd_2_' + sample_str, $
                           alog10( mass_cut ), 11.99, alog10( vdsp_cut ), 2.54, $
                           /plot
        free_all
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( mass_comp ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Mass compare 
    hvdisp_post_scale, z0_mass_a, z0_mass_b, z0_mass_a_err, z0_mass_b_err, $ 
                       z1_mass_a, z1_mass_b, z1_mass_a_err, z1_mass_b_err, $ 
                       z2_mass_a, z2_mass_b, z2_mass_a_err, z2_mass_b_err, $ 
                       z3_mass_a, z3_mass_b, z3_mass_a_err, z3_mass_b_err, $ 
                       'logMs_d_gim2d', 'logMt_d_gim2d', $
                       'hvdisp_mass_compare_1_' + sample_str, $ 
                       mass_cut, 11.99, mass_cut, 11.99, /plot 
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_post_scale, z0_mass_a, z0_mass_c, z0_mass_a_err, z0_mass_c_err, $ 
                       z1_mass_a, z1_mass_c, z1_mass_a_err, z1_mass_c_err, $ 
                       z2_mass_a, z2_mass_c, z2_mass_a_err, z2_mass_c_err, $ 
                       z3_mass_a, z3_mass_c, z3_mass_a_err, z3_mass_c_err, $ 
                       'logMs_d_gim2d', 'logMs_mpa', $
                       'hvdisp_mass_compare_2_' + sample_str, $ 
                       mass_cut, 11.99, mass_cut, 11.99, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_post_scale, z0_mass_a, z0_mass_d, z0_mass_a_err, z0_mass_d_err, $ 
                       z1_mass_a, z1_mass_d, z1_mass_a_err, z1_mass_d_err, $ 
                       z2_mass_a, z2_mass_d, z2_mass_a_err, z2_mass_d_err, $ 
                       z3_mass_a, z3_mass_d, z3_mass_a_err, z3_mass_d_err, $ 
                       'logMs_d_gim2d', 'logMs_p_port', $
                       'hvdisp_mass_dompare_3_' + sample_str, $ 
                       mass_cut, 11.99, mass_cut, 11.99, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( vdsp_comp ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Vdsp compare 
    hvdisp_post_scale, z0_vdsp_a, z0_vdsp_b, z0_vdsp_a_err, z0_vdsp_b_err, $ 
                       z1_vdsp_a, z1_vdsp_b, z1_vdsp_a_err, z1_vdsp_b_err, $ 
                       z2_vdsp_a, z2_vdsp_b, z2_vdsp_a_err, z2_vdsp_b_err, $ 
                       z3_vdsp_a, z3_vdsp_b, z3_vdsp_a_err, z3_vdsp_b_err, $ 
                       'logVdsp_corr_ossy', 'logVdsp_corr_port', $
                       'hvdisp_vdsp_compare_1_' + sample_str, $ 
                       alog10( vdsp_cut ), 2.54, alog10( vdsp_cut ), 2.54, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_post_scale, z0_vdsp_a, z0_vdsp_c, z0_vdsp_a_err, z0_vdsp_c_err, $ 
                       z1_vdsp_a, z1_vdsp_c, z1_vdsp_a_err, z1_vdsp_c_err, $ 
                       z2_vdsp_a, z2_vdsp_c, z2_vdsp_a_err, z2_vdsp_c_err, $ 
                       z3_vdsp_a, z3_vdsp_c, z3_vdsp_a_err, z3_vdsp_c_err, $ 
                       'logVdsp_corr_ossy', 'logVdsp_corr_sdss', $
                       'hvdisp_vdsp_compare_2_' + sample_str, $ 
                       alog10( vdsp_cut ), 2.54, alog10( vdsp_cut ), 2.54, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( logr_comp ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; LogRe_compare
    hvdisp_post_scale, z0_logr_a, z0_logr_b, z0_logr_a_err, z0_logr_b_err, $ 
                       z1_logr_a, z1_logr_b, z1_logr_a_err, z1_logr_b_err, $ 
                       z2_logr_a, z2_logr_b, z2_logr_a_err, z2_logr_b_err, $ 
                       z3_logr_a, z3_logr_b, z3_logr_a_err, z3_logr_b_err, $ 
                       'logRc_ser_gim2d', 'logRc_bpd_gim2d', $
                       'hvdisp_logr_compare_1_' + sample_str, $ 
                       -0.249, 1.99, -0.249, 1.99, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_post_scale, z0_logr_a, z0_logr_c, z0_logr_a_err, z0_logr_c_err, $ 
                       z1_logr_a, z1_logr_c, z1_logr_a_err, z1_logr_c_err, $ 
                       z2_logr_a, z2_logr_c, z2_logr_a_err, z2_logr_c_err, $ 
                       z3_logr_a, z3_logr_c, z3_logr_a_err, z3_logr_c_err, $ 
                       'logRc_ser_gim2d', 'logRc_DeV_sdss', $
                       'hvdisp_logr_compare_2_' + sample_str, $ 
                       -0.249, 1.99, -0.249, 1.99, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hvdisp_post_scale, z0_logr_a, z0_logr_d, z0_logr_a_err, z0_logr_d_err, $ 
                       z1_logr_a, z1_logr_d, z1_logr_a_err, z1_logr_d_err, $ 
                       z2_logr_a, z2_logr_d, z2_logr_a_err, z2_logr_d_err, $ 
                       z3_logr_a, z3_logr_d, z3_logr_a_err, z3_logr_d_err, $ 
                       'logRc_ser_gim2d', 'logRc_Petro_sdss', $
                       'hvdisp_logr_dompare_3_' + sample_str, $ 
                       -0.249, 1.99, -0.249, 1.99, /plot
    free_all
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hvdisp_sample_select, step0=step0, step1=step1, step2=step2, step3=step3, $
    step4=step4, step5=step5, step6=step6, step7=step7, hvdisp_home=hvdisp_home

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( hvdisp_home ) then begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endif else begin 
        hvdisp_location, hvdisp_home, data_home
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step0 ) then begin 
        print, '##############################################################'
        print, ' Group the sample into different redshift bins !! '
        hvdisp_group_red, hvdisp_home=hvdisp_home 
        print, '##############################################################'
        print, ' Group the sample into different velocity dispersion bins !! '
        hvdisp_group_vdp, hvdisp_home=hvdisp_home 
    endif  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step1 ) then begin 
        print, '##############################################################'
        print, ' Group the sample into different morphology bins !! '
        hvdisp_group_etg, hvdisp_home=hvdisp_home
        print, '##############################################################'
        print, ' Group the sample into different emission-line bins !! '
        hvdisp_group_emi, hvdisp_home=hvdisp_home
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step2 ) then begin 
        print, '##############################################################'
        print, ' Group the sample based on both morphology and emission line !'
        hvdisp_group_fin, hvdisp_home=hvdisp_home
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step3 ) then begin 
        print, '##############################################################'
        print, ' Get the basic statistics of all the subsamples !! ' 
        hvdisp_post_stats, hvdisp_home=hvdisp_home 
        ;; Mass cut
        hvdisp_post_stats, hvdisp_home=hvdisp_home, /mass_cut 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step4 ) then begin 
        print, '##############################################################'
        print, ' Check some important scaling relations !! ' 
        ;;
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.40, pzoo_cut=0.7, /vdsp_comp
        print, '##############################################################'
        ;;
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.40, pzoo_cut=0.7, /mass_comp
        print, '##############################################################'
        ;; 
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.40, pzoo_cut=0.7, /logr_comp
        print, '##############################################################'
        ;;
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.40, pzoo_cut=0.4, /vdsp_comp
        print, '##############################################################'
        ;;
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.40, pzoo_cut=0.4, /mass_comp
        print, '##############################################################'
        ;; 
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.40, pzoo_cut=0.4, /logr_comp
        print, '##############################################################'
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step5 ) then begin 
        print, '##############################################################'
        print, ' Check the mass-size scaling relations !! ' 
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.50, pzoo_cut=0.7, /mass_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=180.0, mass_cut=10.50, pzoo_cut=0.7, /mass_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=180.0, mass_cut=11.00, pzoo_cut=0.7, /mass_size
        print, '##############################################################'
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.50, pzoo_cut=0.4, /mass_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=180.0, mass_cut=10.50, pzoo_cut=0.4, /mass_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=180.0, mass_cut=11.00, pzoo_cut=0.4, /mass_size
        print, '##############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step6 ) then begin 
        print, '##############################################################'
        print, ' Check the vdsp-size scaling relations !! ' 
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.50, pzoo_cut=0.7, /vdsp_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.90, pzoo_cut=0.7, /vdsp_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=180.0, mass_cut=11.00, pzoo_cut=0.7, /vdsp_size
        print, '##############################################################'
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.50, pzoo_cut=0.4, /vdsp_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.90, pzoo_cut=0.4, /vdsp_size
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=180.0, mass_cut=11.00, pzoo_cut=0.4, /vdsp_size
        print, '##############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( step7 ) then begin 
        print, '##############################################################'
        print, ' Check the mass-vdsp scaling relations !! ' 
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.20, pzoo_cut=0.7, /mass_vdsp
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.90, pzoo_cut=0.7, /mass_vdsp
        print, '##############################################################'
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.20, pzoo_cut=0.4, /mass_vdsp
        hvdisp_list_scale, hvdisp_home=hvdisp_home, $
            vdsp_cut=140.0, mass_cut=10.90, pzoo_cut=0.4, /mass_vdsp
        print, '##############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

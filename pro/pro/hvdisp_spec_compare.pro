pro stack_compare 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Regions
reg_l = [ 3800.0, 3990.0, 4480.0, 4920.0, 4480.0, 5350.0, 5820.0, $
    6050.0, 6580.0, 7030.0, 7530.0, 7530.0 ]
reg_r = [ 4020.0, 4580.0, 5000.0, 5380.0, 5365.0, 5850.0, 6080.0, $
    6550.0, 7060.0, 7550.0, 7850.0, 8300.0 ]
nm1_l = [ 3804.0, 4015.0, 4615.0, 4942.0, 4615.0, 5374.0, 5824.0, $
    6106.0, 6614.0, 7034.0, 7540.0, 7540.0 ] 
nm1_r = [ 3814.0, 4025.0, 4625.0, 4952.0, 4625.0, 5386.0, 5836.0, $
    6118.0, 6626.0, 7046.0, 7552.0, 7552.0 ]
nm2_l = [ 4005.0, 4504.0, 4944.0, 5354.0, 5354.0, 5824.0, 6066.0, $
    6528.0, 7036.0, 7468.0, 7811.0, 8240.0 ]
nm2_r = [ 4015.0, 4514.0, 4954.0, 5364.0, 5364.0, 5836.0, 6078.0, $
    6540.0, 7048.0, 7480.0, 7823.0, 8250.0 ]

n_reg = n_elements( reg_l ) 
for i = 1, ( n_reg - 1 ), 1 do begin 
;for i = 0, 0, 1 do begin  
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, '   ' + string( i + 1 ) + '  !!'
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    region = [ reg_l[i], reg_r[i] ] 
    norm1  = [ nm1_l[i], nm1_r[i] ] 
    norm2  = [ nm2_l[i], nm2_r[i] ] 

    g_input = [ 'd', 'd', 'f', 'k' ]
    m_input = [ 'med', 'avg', 'avg', 'avg' ]

    for k = 0, ( n_elements( g_input ) - 1 ), 1 do begin 

        spec_stack_compare, region, norm1, norm2, /over_feature, $
            /hori_norm, /blue_fill, /red_fill, $ 
            reference=1, g_input=g_input[k], m_input=m_input[k]
    
        spec_stack_compare, region, norm1, norm2, /over_feature, $
            /hori_norm, /blue_fill, /red_fill, $ 
            reference=3, g_input=g_input[k], m_input=m_input[k]
    
        spec_stack_compare, region, norm1, norm2, /over_feature, $
            /hori_norm, /blue_fill, /red_fill, $ 
            reference=1, /over_model, $
            g_input=g_input[k], m_input=m_input[k]
    
;        spec_stack_compare, region, norm1, norm2, /over_feature, $
;            /hori_norm, /blue_fill, /red_fill, $ 
;            reference=2, /over_model, $
;            g_input=g_input[k], m_input=m_input[k]
    
        spec_stack_compare, region, norm1, norm2, /over_feature, $
            /hori_norm, /blue_fill, /red_fill, $ 
            reference=3, /over_model, $
            g_input=g_input[k], m_input=m_input[k]
    
;        spec_stack_compare, region, norm1, norm2, /over_feature, $
;            /hori_norm, /blue_fill, /red_fill, $ 
;            reference=4, /over_model, $
;            g_input=g_input[k], m_input=m_input[k]
    
;        spec_stack_compare, region, norm1, norm2, /over_feature, $
;            /hori_norm, /blue_fill, /red_fill, $ 
;            reference=1, /over_model, /same_ref, $
;            g_input=g_input[k], m_input=m_input[k]
    
;        spec_stack_compare, region, norm1, norm2, /over_feature, $
;            /hori_norm, /blue_fill, /red_fill, $ 
;            reference=2, /over_model, /same_ref, $
;            g_input=g_input[k], m_input=m_input[k]

;        spec_stack_compare, region, norm1, norm2, /over_feature, $
;            /hori_norm, /blue_fill, /red_fill, $ 
;            reference=3, /over_model, /same_ref, $
;            g_input=g_input[k], m_input=m_input[k]
    
    endfor

endfor

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro index_compare, index_list=index_list 

    if keyword_set( index_list ) then begin 
        index_list = strcompress( index_list, /remove_all ) 
    endif else begin 
        index_list = 'hs_index_stack.lis'
    endelse
    ;; read the index 
    readcol, index_list, name, lam0, lam1, blue0, blue1, red0, red1, type, $
        format='A,F,F,F,F,F,F,I', comment='#', delimiter=' ', /silent 
    n_index = n_elements( name )

    for i = 0, ( n_index - 1 ), 1 do begin 
    ;for i = 0, 0, 1 do begin 
        index_name = strcompress( name[i], /remove_all ) 

        prefix = index_name 
        psxsize = 36
        psysize = 36 
        region = [ ( blue0[ i ] - 1.0 ), ( red1[ i ] + 1.0 ) ]
        norm1  = [ blue0[ i ], blue1[ i ] ]
        norm2  = [ red0[ i ],  red1[ i ] ]
        line1  = lam0[i] 
        line2  = lam1[i]
    
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' INDEX: ' + prefix 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

        g_input = [ 'd', 'd', 'f', 'k' ]
        m_input = [ 'med', 'avg', 'avg', 'avg' ]
    
        for k = 0, ( n_elements( g_input ) - 1 ), 1 do begin 

            spec_stack_compare, region, norm1, norm2, prefix=prefix, $
                psxsize=psxisze, psysize=psysize, title=prefix, $ 
                line1=line1, line2=line2, /red_norm, /blue_norm, $ 
                /blue_fill, /red_fill, /region_fill, /over_feature, $
                reference=1, g_input=g_input[k], m_input=m_input[k]
    
            spec_stack_compare, region, norm1, norm2, prefix=prefix, $
                psxsize=psxisze, psysize=psysize, title=prefix, $ 
                line1=line1, line2=line2, /red_norm, /blue_norm, $ 
                /blue_fill, /red_fill, /region_fill, /over_feature, $
                reference=3, g_input=g_input[k], m_input=m_input[k]
    
            spec_stack_compare, region, norm1, norm2, prefix=prefix, $
                psxsize=psxisze, psysize=psysize, title=prefix, $ 
                line1=line1, line2=line2, /red_norm, /blue_norm, $ 
                /blue_fill, /red_fill, /region_fill, /over_feature, $
                reference=1, /over_model, $
                g_input=g_input[k], m_input=m_input[k]
    
            spec_stack_compare, region, norm1, norm2, prefix=prefix, $
                psxsize=psxisze, psysize=psysize, title=prefix, $ 
                line1=line1, line2=line2, /red_norm, /blue_norm, $ 
                /blue_fill, /red_fill, /region_fill, /over_feature, $
                reference=3, /over_model, $
                g_input=g_input[k], m_input=m_input[k]
    
;            spec_stack_compare, region, norm1, norm2, prefix=prefix, $
;                psxsize=psxisze, psysize=psysize, title=prefix, $ 
;                line1=line1, line2=line2, /red_norm, /blue_norm, $ 
;                /blue_fill, /red_fill, /region_fill, /over_feature, $
;                reference=1, /over_model, /same_ref, $
;                g_input=g_input[k], m_input=m_input[k]
;    
;            spec_stack_compare, region, norm1, norm2, prefix=prefix, $
;                psxsize=psxisze, psysize=psysize, title=prefix, $ 
;                line1=line1, line2=line2, /red_norm, /blue_norm, $ 
;                /blue_fill, /red_fill, /region_fill, /over_feature, $
;                reference=3, /over_model, /same_ref, $
;                g_input=g_input[k], m_input=m_input[k]

        endfor

    endfor

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro spec_stack_compare, region, norm1, norm2, $
    prefix=prefix, psxsize=psxsize, psysize=psysize, $
    index_list=index_list, title=title, $
    line1=line1, line2=line2, over_feature=over_feature, $ 
    blue_norm=blue_norm, red_norm=red_norm, hori_norm=hori_norm, $ 
    blue_fill=blue_fill, red_fill=red_fill, region_fill=region_fill, $
    reference=reference, over_model=over_model, same_ref=same_ref, $ 
    g_input=g_input, m_input=m_input

on_error, 2
compile_opt idl2

if N_params() lt 3  then begin 
    print,  'Syntax - spec_ref_compare ' 
    return
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( g_input ) then begin 
    g_input = strcompress( g_input, /remove_all )
endif else begin 
    g_input = 'd' 
endelse
if keyword_set( m_input ) then begin 
    m_input = strcompress( m_input, /remove_all )
endif else begin 
    m_input = 'avg' 
endelse
;; Size of the figure 
if keyword_set( psxsize ) then begin 
    psxsize = long( psxsize ) 
endif else begin 
    psxsize = 40 
endelse 
if keyword_set( psysize ) then begin 
    psysize = long( psysize ) 
endif else begin 
    psysize = 36
endelse
;; Position of each plots 
if keyword_set( over_model ) then begin 
    pos_1 = [ 0.10, 0.09, 0.98, 0.49 ] 
    pos_2 = [ 0.10, 0.49, 0.98, 0.87 ]
    pos_3 = [ 0.10, 0.88, 0.98, 0.99 ]
endif else begin 
    pos_1 = [ 0.10, 0.10, 0.98, 0.58 ] 
    pos_2 = [ 0.10, 0.58, 0.98, 0.96 ]
endelse
;; Thickness of the axes 
xthick = 11.0 
ythick = 11.0
a_charsize  = 3.5 
a_charthick = 8.0
if keyword_set( index_list ) then begin 
    index_list = strcompress( index_list, /remove_all ) 
endif else begin 
    index_list = 'hs_index_stack.lis' 
endelse 
if NOT file_test( index_list ) then begin 
    message, 'Can not find the index list: ' + index_list + '  !!' 
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in the model spectra file 
;; Common wavelength range : 3465 - 9140 
struc_model    = mrdfits( 'spec_compare.fits', 1 ) 
min_wave_model = min( struc_model[0].wave )
max_wave_model = max( struc_model[0].wave )
wave_model     = struc_model[0].wave 
n_pix_model    = n_elements( wave_model )
n_model        = n_elements( struc_model.age )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in the stack spectra file 
struc_stack    = mrdfits( 'sdss_stack.fits', 1 ) 
min_wave_stack = 3540.0
max_wave_stack = 8250.0
wave_stack     = struc_stack[0].wave 
n_pix_stack    = n_elements( wave_stack )
n_stack        = n_elements( struc_stack.redshift )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Organize the string
struc_model.spec_str = strcompress( struc_model.spec_str, /remove_all )
struc_model.ssp      = strcompress( struc_model.ssp,      /remove_all )
struc_stack.group    = strcompress( struc_stack.group,    /remove_all )
struc_stack.method   = strcompress( struc_stack.method,   /remove_all )
struc_stack.z_str    = strcompress( struc_stack.z_str,    /remove_all )
struc_stack.s_str    = strcompress( struc_stack.s_str,    /remove_all )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if ( n_elements( region ) EQ 2 ) then begin 
    index_region = where( ( wave_model GE region[0] ) AND $
        ( wave_model LE region[1] ) )
    stack_region = where( ( wave_stack GE region[0] ) AND $
        ( wave_stack LE region[1] ) )
    if ( ( index_region[0] EQ -1 ) OR ( stack_region[0] EQ -1 ) ) then begin 
        message, 'Something wrong with REGION !!' 
    endif 
endif else begin 
    message, 'Something wrong with REGION !!' 
endelse
;;;;;;;
if ( n_elements( norm1 ) EQ 2 ) then begin 
    index_norm1 = where( ( wave_model GE norm1[0] ) AND $
        ( wave_model LE norm1[1] ) )
    stack_norm1 = where( ( wave_stack GE norm1[0] ) AND $
        ( wave_stack LE norm1[1] ) )
    if ( ( index_norm1[0] EQ -1 ) OR ( stack_norm1[0] EQ -1 ) ) then begin 
        message, 'Something wrong with NORM1 !!' 
    endif 
endif else begin 
    message, 'Something wrong with NORM1 !!' 
endelse
;;;;;;;
if ( n_elements( norm2 ) EQ 2 ) then begin 
    index_norm2 = where( ( wave_model GE norm2[0] ) AND $
        ( wave_model LE norm2[1] ) )
    stack_norm2 = where( ( wave_stack GE norm2[0] ) AND $
        ( wave_stack LE norm2[1] ) )
    if ( ( index_norm2[0] EQ -1 ) OR ( stack_norm2[0] EQ -1 ) ) then begin 
        message, 'Something wrong with NORM2 !!' 
    endif 
endif else begin 
    message, 'Something wrong with NORM2 !!' 
endelse
index_norm = [ index_norm1, index_norm2 ] 
stack_norm = [ stack_norm1, stack_norm2 ] 
;; Region for deciding the range of plot 
index_region_plot = where( ( wave_model GE norm1[1] ) AND $ 
    ( wave_model LE norm2[0] ) )
stack_region_plot = where( ( wave_stack GE norm1[1] ) AND $ 
    ( wave_stack LE norm2[0] ) )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; normalize the model spectra 
for i = 0, ( n_model - 1 ), 1 do begin 
    wave_norm = wave_model[ index_norm ]
    flux_norm = struc_model[i].flux[ index_norm ]
    ;;
    lin_result = linfit( wave_norm, flux_norm ) 
    continuum_lin = lin_result[0] + lin_result[1] * wave_model 
    ;;
    struc_model[i].flux = ( struc_model[i].flux / continuum_lin )
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; normalize the stacked spectra 
for i = 0, ( n_stack - 1 ), 1 do begin 
    ;; 
    wave_norm_stack = wave_stack[ stack_norm ]
    flux_norm_stack = struc_stack[i].flux[ stack_norm ]
    ;;
    lin_result_stack = linfit( wave_norm_stack, flux_norm_stack ) 
    continuum_lin_stack = lin_result_stack[0] + lin_result_stack[1] * wave_stack 
    ;;
    struc_stack[i].flux = ( struc_stack[i].flux / continuum_lin_stack )
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Select the stacking spectra for comparison
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
index_stack_select = where( $
    ( struc_stack.z_str EQ 'z0' ) AND $
    ( struc_stack.group  EQ g_input  ) AND $
    ( struc_stack.method EQ m_input ) $
    )
if ( index_stack_select[0] EQ -1 ) then begin 
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, ' Something wrong with the stack spectra summary file !!'
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    message, ' ' 
endif  
;; 
n_select_stack = n_elements( index_stack_select )
;;
group_stack = struc_stack[ index_stack_select ]
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spec_cvd_ref   = struc_model[ where( struc_model.spec_str EQ 'cvd_ref' ) ].flux 
spec_miu_ref   = struc_model[ where( struc_model.spec_str EQ 'miu_ref' ) ].flux 
spec_stack_ref = group_stack[ where( group_stack.sigma EQ 200.0 ) ].flux
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
min_spec_stack = min( group_stack.flux[ stack_region_plot ] )
max_spec_stack = max( group_stack.flux[ stack_region_plot ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ratio for CVD model
;;
stack_flux_inter_1 = interpol( $
    group_stack[ where( group_stack.sigma EQ 160.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_2 = interpol( $
    group_stack[ where( group_stack.sigma EQ 180.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_3 = interpol( $
    group_stack[ where( group_stack.sigma EQ 200.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_4 = interpol( $
    group_stack[ where( group_stack.sigma EQ 220.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_5 = interpol( $
    group_stack[ where( group_stack.sigma EQ 240.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_6 = interpol( $
    group_stack[ where( group_stack.sigma EQ 260.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_7 = interpol( $
    group_stack[ where( group_stack.sigma EQ 280.0 ) ].flux, $
    wave_stack, wave_model ) 
stack_flux_inter_8 = interpol( $
    group_stack[ where( group_stack.sigma EQ 310.0 ) ].flux, $
    wave_stack, wave_model ) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reference spectra
if keyword_set( reference ) then begin 
    case reference of 
        1 : spec_ref = stack_flux_inter_1
        2 : spec_ref = stack_flux_inter_2
        3 : spec_ref = stack_flux_inter_3
        4 : spec_ref = stack_flux_inter_4
        5 : spec_ref = stack_flux_inter_5
        6 : spec_ref = stack_flux_inter_6
        7 : spec_ref = stack_flux_inter_7
        8 : spec_ref = spec_miu_ref
        9 : spec_ref = spec_cvd_ref
        else : message, 'XXXXX Wrong reference option !!!! XXXXX'
    endcase
endif else begin 
    spec_ref = stack_flux_inter_2 
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stack_ratio_1 = ( stack_flux_inter_1 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_2 = ( stack_flux_inter_2 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_3 = ( stack_flux_inter_3 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_4 = ( stack_flux_inter_4 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_5 = ( stack_flux_inter_5 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_6 = ( stack_flux_inter_6 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_7 = ( stack_flux_inter_7 - spec_ref ) / spec_ref * 100.0
;;
stack_ratio_8 = ( stack_flux_inter_8 - spec_ref ) / spec_ref * 100.0
;;;
min_stack_ratio = min( [ $
    min( stack_ratio_1[ index_region_plot ] ), $ 
    min( stack_ratio_2[ index_region_plot ] ), $ 
    min( stack_ratio_3[ index_region_plot ] ), $ 
    min( stack_ratio_4[ index_region_plot ] ), $ 
    min( stack_ratio_5[ index_region_plot ] ), $ 
    min( stack_ratio_6[ index_region_plot ] ), $ 
    min( stack_ratio_7[ index_region_plot ] ), $ 
    min( stack_ratio_8[ index_region_plot ] ) ] )  
max_stack_ratio = max( [ $
    max( stack_ratio_1[ index_region_plot ] ), $ 
    max( stack_ratio_2[ index_region_plot ] ), $ 
    max( stack_ratio_3[ index_region_plot ] ), $ 
    max( stack_ratio_4[ index_region_plot ] ), $ 
    max( stack_ratio_5[ index_region_plot ] ), $ 
    max( stack_ratio_6[ index_region_plot ] ), $ 
    max( stack_ratio_7[ index_region_plot ] ), $ 
    max( stack_ratio_8[ index_region_plot ] ) ] )  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wave_range = [ ( region[0] - 2 ), ( region[1] + 2 ) ] 
index_cvd = where( struc_model.ssp EQ 'CvD12' ) 
index_miu = where( struc_model.ssp EQ 'MIUSCAT' )
min_spec_cvd = min( struc_model[ index_cvd ].flux[ index_region_plot ] )
max_spec_cvd = max( struc_model[ index_cvd ].flux[ index_region_plot ] )
min_spec_miu = min( struc_model[ index_miu ].flux[ index_region_plot ] )
max_spec_miu = max( struc_model[ index_miu ].flux[ index_region_plot ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( same_ref ) then begin 
    cvd_imf1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_imf1' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_imf2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_imf2' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_imf3_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_imf3' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_age1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_age1' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_age2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_age2' ) ].flux - $
        spec_ref ) / spec_ref * 100.0 
    cvd_afe1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_afe1' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_afe2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_afe2' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_afe3_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_afe3' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    cvd_imf1_ratio2 = ( spec_ref - $
        struc_model[ where( struc_model.spec_str EQ 'cvd_imf1' ) ].flux ) / $
        spec_ref * 100.0
endif else begin 
    cvd_imf1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_imf1' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_imf2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_imf2' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_imf3_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_imf3' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_age1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_age1' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_age2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_age2' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0 
    cvd_afe1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_afe1' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_afe2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_afe2' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_afe3_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'cvd_afe3' ) ].flux - $
        spec_cvd_ref ) / spec_cvd_ref * 100.0
    cvd_imf1_ratio2 = ( spec_cvd_ref - $
        struc_model[ where( struc_model.spec_str EQ 'cvd_imf1' ) ].flux ) / $
        spec_cvd_ref * 100.0
endelse
min_cvd_ratio1 = min( [ $
    min( cvd_imf2_ratio1[ index_region_plot ] ), $
    min( cvd_imf3_ratio1[ index_region_plot ] ), $
    min( cvd_age2_ratio1[ index_region_plot ] ), $
    min( cvd_afe1_ratio1[ index_region_plot ] ) ] )
min_cvd_ratio2 = min( [ $
    min( cvd_imf2_ratio1[ index_region_plot ] ), $
    min( cvd_imf3_ratio1[ index_region_plot ] ), $
    min( cvd_age2_ratio1[ index_region_plot ] ), $
    min( cvd_afe1_ratio1[ index_region_plot ] ) ] )
max_cvd_ratio1 = max( [ $
    max( cvd_imf2_ratio1[ index_region_plot ] ), $
    max( cvd_imf3_ratio1[ index_region_plot ] ), $
    max( cvd_age2_ratio1[ index_region_plot ] ), $
    max( cvd_afe1_ratio1[ index_region_plot ] ) ] )
max_cvd_ratio2 = max( [ $
    max( cvd_imf2_ratio1[ index_region_plot ] ), $
    max( cvd_imf3_ratio1[ index_region_plot ] ), $
    max( cvd_age2_ratio1[ index_region_plot ] ), $
    max( cvd_afe1_ratio1[ index_region_plot ] ) ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( same_ref ) then begin 
    miu_imf1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf1' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_imf2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf2' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_imf3_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf3' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_imf4_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf4' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_imf5_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf5' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_imf6_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf6' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_age1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_age1' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_age2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_age2' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_met1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_met1' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_met2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_met2' ) ].flux - $
        spec_ref ) / spec_ref * 100.0
    miu_imf1_ratio2 = ( spec_ref - $
        struc_model[ where( struc_model.spec_str EQ 'miu_imf1' ) ].flux ) / $
        spec_ref * 100.0
    miu_imf4_ratio2 = ( spec_ref - $
        struc_model[ where( struc_model.spec_str EQ 'miu_imf4' ) ].flux ) / $
        spec_ref * 100.0
    miu_met1_ratio2 = ( spec_ref - $
        struc_model[ where( struc_model.spec_str EQ 'miu_met1' ) ].flux ) / $
        spec_ref * 100.0
endif else begin 
    miu_imf1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf1' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_imf2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf2' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_imf3_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf3' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_imf4_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf4' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_imf5_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf5' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_imf6_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_imf6' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_age1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_age1' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_age2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_age2' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_met1_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_met1' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_met2_ratio1 = $
        ( struc_model[ where( struc_model.spec_str EQ 'miu_met2' ) ].flux - $
        spec_miu_ref ) / spec_miu_ref * 100.0
    miu_imf1_ratio2 = ( spec_miu_ref - $
        struc_model[ where( struc_model.spec_str EQ 'miu_imf1' ) ].flux ) / $
        spec_miu_ref * 100.0
    miu_imf4_ratio2 = ( spec_miu_ref - $
        struc_model[ where( struc_model.spec_str EQ 'miu_imf4' ) ].flux ) / $
        spec_miu_ref * 100.0
    miu_met1_ratio2 = ( spec_miu_ref - $
        struc_model[ where( struc_model.spec_str EQ 'miu_met1' ) ].flux ) / $
        spec_miu_ref * 100.0
endelse
min_miu_ratio1 = min( [ $
    min( miu_imf2_ratio1[ index_region_plot ] ), $
    min( miu_imf3_ratio1[ index_region_plot ] ), $
    min( miu_imf5_ratio1[ index_region_plot ] ), $
    min( miu_imf6_ratio1[ index_region_plot ] ), $
    min( miu_age2_ratio1[ index_region_plot ] ), $
    min( miu_met1_ratio1[ index_region_plot ] ), $
    min( miu_met2_ratio1[ index_region_plot ] ) ] )
min_miu_ratio2 = min( [ $
    min( miu_imf2_ratio1[ index_region_plot ] ), $
    min( miu_imf3_ratio1[ index_region_plot ] ), $
    min( miu_imf5_ratio1[ index_region_plot ] ), $
    min( miu_imf6_ratio1[ index_region_plot ] ), $
    min( miu_age2_ratio1[ index_region_plot ] ), $
    min( miu_met1_ratio2[ index_region_plot ] ), $
    min( miu_met2_ratio1[ index_region_plot ] ) ] )
max_miu_ratio1 = max( [ $
    max( miu_imf2_ratio1[ index_region_plot ] ), $
    max( miu_imf3_ratio1[ index_region_plot ] ), $
    max( miu_imf5_ratio1[ index_region_plot ] ), $
    max( miu_imf6_ratio1[ index_region_plot ] ), $
    max( miu_age2_ratio1[ index_region_plot ] ), $
    max( miu_met1_ratio1[ index_region_plot ] ), $
    max( miu_met2_ratio1[ index_region_plot ] ) ] )
max_miu_ratio2 = max( [ $
    max( miu_imf2_ratio1[ index_region_plot ] ), $
    max( miu_imf3_ratio1[ index_region_plot ] ), $
    max( miu_imf5_ratio1[ index_region_plot ] ), $
    max( miu_imf6_ratio1[ index_region_plot ] ), $
    max( miu_age2_ratio1[ index_region_plot ] ), $
    max( miu_met1_ratio2[ index_region_plot ] ), $
    max( miu_met2_ratio1[ index_region_plot ] ) ] )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
region_str = strcompress( string( long( region[0] ) ), /remove_all ) + '_' + $
    strcompress( string( long( region[1] ) ), /remove_all )
if keyword_set( reference ) then begin 
    ref_str = strcompress( string( reference ), /remove_all )
endif else begin 
    ref_str = strcompress( string( 2 ), /remove_all ) 
endelse
if keyword_set( same_ref ) then begin 
    ref_str = 's' + ref_str
endif 
if keyword_set( over_model ) then begin 
    ref_str = ref_str + 'm'
endif
ref_str = ref_str + '_' + g_input + '_' + m_input 
;; Name of the plot 
if keyword_set ( prefix ) then begin 
    prefix = strcompress( prefix, /remove_all ) 
    fig1_name = prefix + '_scomp_1_'     + ref_str + '.eps'
endif else begin 
    fig1_name = 'scomp_1_'     + region_str + '_' + ref_str + '.eps' 
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FIGURE 1: Stack Compare 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mydevice = !d.name 
!p.font = 0 
set_plot, 'PS'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;if keyword_set( over_model ) then begin 
;    min_spec = min( [ min_spec_cvd, min_spec_miu, min_spec_stack ] )
;    max_spec = max( [ max_spec_cvd, max_spec_miu, max_spec_stack ] )
;endif else begin 
min_spec = min_spec_stack
max_spec = max_spec_stack
;endelse
offset = ( ( max_spec - min_spec ) / 2.8 )
;;;
if keyword_set( over_model ) then begin 
    min_ratio = min( [ min_cvd_ratio1, min_miu_ratio1, min_stack_ratio ] )
    max_ratio = max( [ max_cvd_ratio1, max_miu_ratio1, max_stack_ratio ] )
endif else begin 
    min_ratio = min_stack_ratio 
    max_ratio = max_stack_ratio
endelse
;;;
spec_range  = [ ( min_spec  - 0.005 ), ( max_spec  + offset ) ]
ratio_range = [ ( min_ratio - 0.10 ), ( max_ratio + 0.10 ) ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
device, filename=fig1_name, font_size=8.5, /encapsulated, /color, /bold, $
    /helvetica, xsize=psxsize, ysize=psysize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The spectra plot 
cgPlot, wave_model, $
    struc_model[ where( struc_model.spec_str EQ 'cvd_ref' ) ].flux, $
    xrange=wave_range, yrange=spec_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle='Flux (Normalized)', /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    position=pos_2, xtickformat="(A1)", xthick=xthick, ythick=ythick, $
    yticklen=0.012, xticklen=0.03, $
    xminor=10, yminor=5, /nodata, color=cgColor('Black')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( over_feature ) then begin 
    if NOT keyword_set( region_fill ) then begin
        if keyword_set( over_model ) then begin 
            hs_spec_index_over, index_list, color_fill='BLK1',$
                color_line='TAN4'
        endif else begin 
            hs_spec_index_over, index_list, color_fill='BLK1', $
                color_line='TAN4'
        endelse
    endif else begin 
        hs_spec_index_over, index_list, /no_line, /no_fill
    endelse
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( blue_fill ) then begin 
    x_fill = [ norm1[0], norm1[1], norm1[1], norm1[0], norm1[0] ]
    y_fill = [ spec_range[0], spec_range[0], spec_range[1], $
        spec_range[1], spec_range[0] ]
    cgColorFill, x_fill, y_fill, /data, $
        color=cgColor( 'BLU1'  )
endif 
if keyword_set( red_fill ) then begin 
    x_fill = [ norm2[0], norm2[1], norm2[1], norm2[0], norm2[0] ]
    y_fill = [ spec_range[0], spec_range[0], spec_range[1], $
        spec_range[1], spec_range[0] ]
    cgColorFill, x_fill, y_fill, /data, $
        color=cgColor( 'RED1'  )
endif 
if ( keyword_set( line1 ) AND keyword_set( line2 ) AND $
    keyword_set( region_fill ) ) then begin 
    x_fill = [ line1, line2, line2, line1, line1 ]
    y_fill = [ spec_range[0], spec_range[0], spec_range[1], $
        spec_range[1], spec_range[0] ]
    cgColorFill, x_fill, y_fill, /data, $
        color=cgColor( 'TAN1'  )
endif 
if keyword_set( blue_norm ) then begin 
    cgPlots, [ norm1[0], norm1[0] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'BLU3' )
    cgPlots, [ norm1[1], norm1[1] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'BLU3' )
endif else begin  
    cgPlots, [ norm1[0], norm1[0] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
    cgPlots, [ norm1[1], norm1[1] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
endelse
if keyword_set( red_norm ) then begin 
    cgPlots, [ norm2[0], norm2[0] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'RED3' )
    cgPlots, [ norm2[1], norm2[1] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'RED3' )
endif else begin  
    cgPlots, [ norm2[0], norm2[0] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
    cgPlots, [ norm2[1], norm2[1] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
endelse
if keyword_set( line1 ) then begin 
    cgPlots, [ line1, line1 ], !Y.Crange, /data, linestyle=0, thick=8.0, $ 
        color=cgColor( 'TAN3' )
endif 
if keyword_set( line2 ) then begin 
    cgPlots, [ line2, line2 ], !Y.Crange, /data, linestyle=0, thick=8.0, $ 
        color=cgColor( 'TAN3' )
endif 
if keyword_set( hori_norm ) then begin 
    cgPlots, !X.Crange, [ 1.0, 1.0 ], /data, linestyle=2, thick=9.0, $ 
        color=cgColor( 'BLK6' )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( over_model ) then begin 
    ;;;;;;;;;;;;;;;; OLD VERSION ;;;;;;;;;;;;;;;;
;    cgPlot, wave_model, stack_flux_inter_1, $
;        linestyle=0, thick=6.0, color=cgColor( 'GRN6' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_2, $
;        linestyle=0, thick=6.0, color=cgColor( 'Green' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_3, $
;        linestyle=0, thick=6.0, color=cgColor( 'Green Yellow' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_4, $
;        linestyle=0, thick=6.0, color=cgColor( 'Yellow' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_5, $
;        linestyle=0, thick=6.0, color=cgColor( 'Gold' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_6, $
;        linestyle=0, thick=6.0, color=cgColor( 'ORG4' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_7, $
;        linestyle=0, thick=6.0, color=cgColor( 'RED4' ), /overplot 
;    cgPlot, wave_model, stack_flux_inter_8, $
;        linestyle=0, thick=6.0, color=cgColor( 'Maroon' ), /overplot 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave_model, stack_flux_inter_1, $
        linestyle=0, thick=6.0, color=cgColor( 'BLK3' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_2, $
        linestyle=1, thick=6.0, color=cgColor( 'BLK3' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_3, $
        linestyle=0, thick=6.0, color=cgColor( 'BLK4' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_4, $
        linestyle=1, thick=6.0, color=cgColor( 'BLK4' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_5, $
        linestyle=0, thick=6.0, color=cgColor( 'BLK5' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_6, $
        linestyle=1, thick=6.0, color=cgColor( 'BLK5' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_7, $
        linestyle=0, thick=6.0, color=cgColor( 'BLK6' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_8, $
        linestyle=0, thick=6.0, color=cgColor( 'BLK7' ), /overplot 
endif else begin 
    cgPlot, wave_model, stack_flux_inter_1, $
        linestyle=0, thick=7.0, color=cgColor( 'Navy' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_2, $
        linestyle=0, thick=7.0, color=cgColor( 'Blue' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_3, $
        linestyle=0, thick=7.0, color=cgColor( 'Cyan' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_4, $
        linestyle=0, thick=7.0, color=cgColor( 'Green' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_5, $
        linestyle=0, thick=7.0, color=cgColor( 'Gold' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_6, $
        linestyle=0, thick=7.0, color=cgColor( 'Orange' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_7, $
        linestyle=0, thick=7.0, color=cgColor( 'Red' ), /overplot 
    cgPlot, wave_model, stack_flux_inter_8, $
        linestyle=0, thick=7.0, color=cgColor( 'RED7' ), /overplot 
endelse
;if keyword_set( over_model ) then begin 
;   ;; CvD model 
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'cvd_imf3' ) ].flux, $
;       linestyle=2, thick=4.0, color=cgColor( 'TAN' ), /overplot
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'cvd_afe1' ) ].flux, $
;       linestyle=2, thick=4.0, color=cgColor( 'TAN' ), /overplot
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'cvd_age2' ) ].flux, $
;       linestyle=2, thick=4.0, color=cgColor( 'TAN' ), /overplot
;   ;; MIU model 
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'miu_imf3' ) ].flux, $
;       linestyle=0, thick=4.0, color=cgColor( 'BLK5' ), /overplot
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'miu_imf6' ) ].flux, $
;       linestyle=3, thick=4.0, color=cgColor( 'BLK5' ), /overplot
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'miu_met1' ) ].flux, $
;       linestyle=0, thick=4.0, color=cgColor( 'BLK5' ), /overplot
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'miu_met2' ) ].flux, $
;       linestyle=0, thick=4.0, color=cgColor( 'BLK5' ), /overplot
;   cgPlot, wave_model, $
;       struc_model[ where( struc_model.spec_str EQ 'miu_age2' ) ].flux, $
;       linestyle=0, thick=4.0, color=cgColor( 'BLK5' ), /overplot
;endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( over_feature ) then begin 
    hs_spec_index_over, index_list, /label_only, $
        xstep=50, ystep=19, max_overlap=5, charsize=2.0
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cgPlot, wave_model, $
    struc_model[ where( struc_model.spec_str EQ 'cvd_ref' ) ].flux, $
    xrange=wave_range, yrange=spec_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle='Flux (Normalized)', /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    position=pos_2, xtickformat="(A1)", xthick=xthick, ythick=ythick, $
    yticklen=0.012, xticklen=0.03, $
    xminor=10, yminor=5, /nodata, color=cgColor('Black')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The ratio plot 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ratio_title = textoidl( "\Delta Flux/Flux_{ref} (%)" )
cgPlot, wave_model, cvd_imf1_ratio1, $
    xrange=wave_range, yrange=ratio_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle=ratio_title, /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    position=pos_1, xtitle='Wavelength ($\Angstrom$)', $
    xthick=xthick, ythick=ythick, $
    yticklen=0.012, xticklen=0.03, $
    xminor=10, yminor=5, /nodata, color=cgColor('Black')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( over_feature ) then begin 
    if NOT keyword_set( region_fill ) then begin 
        if keyword_set( over_model ) then begin 
            hs_spec_index_over, index_list, color_fill='BLK1', $
                color_line='TAN4'
        endif else begin 
            hs_spec_index_over, index_list, color_fill='BLK1', $
                color_line='TAN4'
        endelse
    endif else begin 
        hs_spec_index_over, index_list, /no_line, /no_fill
    endelse
endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cgPlots, !X.Crange, [ 0.0, 0.0 ], /data, linestyle=0, thick=6.0, $ 
    color=cgColor( 'BLK5' )
;;;;;;;;;;;;;;;;;;;
if keyword_set( blue_fill ) then begin 
    x_fill = [ norm1[0], norm1[1], norm1[1], norm1[0], norm1[0] ]
    y_fill = [ ratio_range[0], ratio_range[0], ratio_range[1], $
        ratio_range[1], ratio_range[0] ]
    cgColorFill, x_fill, y_fill, /data, $
        color=cgColor( 'BLU1'  )
endif 
if keyword_set( red_fill ) then begin 
    x_fill = [ norm2[0], norm2[1], norm2[1], norm2[0], norm2[0] ]
    y_fill = [ ratio_range[0], ratio_range[0], ratio_range[1], $
        ratio_range[1], ratio_range[0] ]
    cgColorFill, x_fill, y_fill, /data, $
        color=cgColor( 'RED1'  )
endif 
if ( keyword_set( line1 ) AND keyword_set( line2 ) AND $
    keyword_set( region_fill ) ) then begin 
    x_fill = [ line1, line2, line2, line1, line1 ]
    y_fill = [ ratio_range[0], ratio_range[0], ratio_range[1], $
        ratio_range[1], ratio_range[0] ]
    cgColorFill, x_fill, y_fill, /data, $
        color=cgColor( 'TAN1'  )
endif 
if keyword_set( blue_norm ) then begin 
    cgPlots, [ norm1[0], norm1[0] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'BLU3' )
    cgPlots, [ norm1[1], norm1[1] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'BLU3' )
endif else begin  
    cgPlots, [ norm1[0], norm1[0] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
    cgPlots, [ norm1[1], norm1[1] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
endelse
if keyword_set( red_norm ) then begin 
    cgPlots, [ norm2[0], norm2[0] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'RED3' )
    cgPlots, [ norm2[1], norm2[1] ], !Y.Crange, /data, linestyle=0, thick=6.0, $
        color=cgColor( 'RED3' )
endif else begin  
    cgPlots, [ norm2[0], norm2[0] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
    cgPlots, [ norm2[1], norm2[1] ], !Y.Crange, /data, linestyle=2, thick=10.0, $
        color=cgColor( 'BLK6' )
endelse
if keyword_set( line1 ) then begin 
    cgPlots, [ line1, line1 ], !Y.Crange, /data, linestyle=0, thick=8.0, $ 
        color=cgColor( 'TAN3' )
endif 
if keyword_set( line2 ) then begin 
    cgPlots, [ line2, line2 ], !Y.Crange, /data, linestyle=0, thick=8.0, $ 
        color=cgColor( 'TAN3' )
endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( over_model ) then begin 
    ;;;;;;;;;;; OLD VERSION ;;;;;;;;;;;;
;    cgPlot, wave_model, stack_ratio_1, $
;        linestyle=0, thick=10.0, color=cgColor( 'GRN6' ), /overplot
;    cgPlot, wave_model, stack_ratio_2, $
;        linestyle=0, thick=10.0, color=cgColor( 'Green' ), /overplot
;    cgPlot, wave_model, stack_ratio_3, $
;        linestyle=0, thick=10.0, color=cgColor( 'Green Yellow' ), /overplot
;    cgPlot, wave_model, stack_ratio_4, $
;        linestyle=0, thick=10.0, color=cgColor( 'Yellow' ), /overplot
;    cgPlot, wave_model, stack_ratio_5, $
;        linestyle=0, thick=10.0, color=cgColor( 'Gold' ), /overplot
;    cgPlot, wave_model, stack_ratio_6, $
;        linestyle=0, thick=10.0, color=cgColor( 'ORG4' ), /overplot
;    cgPlot, wave_model, stack_ratio_7, $
;        linestyle=0, thick=10.0, color=cgColor( 'RED4' ), /overplot
;    cgPlot, wave_model, stack_ratio_8, $
;        linestyle=0, thick=10.0, color=cgColor( 'Maroon' ), /overplot
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cgPlot, wave_model, stack_ratio_1, $
        linestyle=0, thick=10.0, color=cgColor( 'BLK3' ), /overplot
    cgPlot, wave_model, stack_ratio_2, $
        linestyle=1, thick=10.0, color=cgColor( 'BLK3' ), /overplot
    cgPlot, wave_model, stack_ratio_3, $
        linestyle=0, thick=10.0, color=cgColor( 'BLK4' ), /overplot
    cgPlot, wave_model, stack_ratio_4, $
        linestyle=1, thick=10.0, color=cgColor( 'BLK4' ), /overplot
    cgPlot, wave_model, stack_ratio_5, $
        linestyle=0, thick=10.0, color=cgColor( 'BLK5' ), /overplot
    cgPlot, wave_model, stack_ratio_6, $
        linestyle=1, thick=10.0, color=cgColor( 'BLK5' ), /overplot
    cgPlot, wave_model, stack_ratio_7, $
        linestyle=0, thick=10.0, color=cgColor( 'BLK6' ), /overplot
    cgPlot, wave_model, stack_ratio_8, $
        linestyle=0, thick=10.0, color=cgColor( 'BLK7' ), /overplot
endif else begin 
    cgPlot, wave_model, stack_ratio_1, $
        linestyle=0, thick=7.0, color=cgColor( 'Navy' ), /overplot
    cgPlot, wave_model, stack_ratio_2, $
        linestyle=0, thick=7.0, color=cgColor( 'Blue' ), /overplot
    cgPlot, wave_model, stack_ratio_3, $
        linestyle=0, thick=7.0, color=cgColor( 'Cyan' ), /overplot
    cgPlot, wave_model, stack_ratio_4, $
        linestyle=0, thick=7.0, color=cgColor( 'Green' ), /overplot
    cgPlot, wave_model, stack_ratio_5, $
        linestyle=0, thick=7.0, color=cgColor( 'Gold' ), /overplot
    cgPlot, wave_model, stack_ratio_6, $
        linestyle=0, thick=7.0, color=cgColor( 'Orange' ), /overplot
    cgPlot, wave_model, stack_ratio_7, $
        linestyle=0, thick=7.0, color=cgColor( 'Red' ), /overplot
    cgPlot, wave_model, stack_ratio_8, $
        linestyle=0, thick=7.0, color=cgColor( 'RED7' ), /overplot
endelse
if keyword_set( over_model ) then begin 
    ;; Age 
    cgPlot, wave_model, cvd_age2_ratio1, $
        linestyle=5, thick=6.0, color=cgColor( 'Lime Green' ), /overplot
    cgPlot, wave_model, miu_age2_ratio1, $
        linestyle=3, thick=6.0, color=cgColor( 'Lime Green' ), /overplot
    ;; MIU model ratio 
    cgPlot, wave_model, miu_met1_ratio1, $
        linestyle=2, thick=6.0, color=cgColor( 'Cyan' ), /overplot
    cgPlot, wave_model, miu_met2_ratio1, $
        linestyle=2, thick=11.0, color=cgColor( 'Magenta' ), /overplot
    cgPlot, wave_model, cvd_afe1_ratio1, $
        linestyle=5, thick=11.0, color=cgColor( 'RED5' ), /overplot
    ;; IMF
    cgPlot, wave_model, cvd_imf2_ratio1, $
        linestyle=5, thick=11.0, color=cgColor( 'BLU6' ), /overplot
    cgPlot, wave_model, cvd_imf3_ratio1, $
        linestyle=3, thick=8.0, color=cgColor( 'BLU5' ), /overplot
    cgPlot, wave_model, miu_imf3_ratio1, $
        linestyle=2, thick=8.0, color=cgColor( 'BLU5' ), /overplot
endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cgPlot, wave_model, cvd_imf1_ratio1, $
    xrange=wave_range, yrange=ratio_range, $
    xstyle=1, ystyle=1, linestyle=0, ytitle=ratio_title, /noerase, $ 
    charsize=a_charsize, charthick=a_charthick, $
    position=pos_1, $
    xthick=xthick, ythick=ythick, $
    yticklen=0.012, xticklen=0.03, $
    xminor=10, yminor=5, /nodata, color=cgColor('Black')
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Caption
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if keyword_set( over_model ) then begin 
    cgPlots, [ pos_3[0], pos_3[2] ], [ pos_3[1], pos_3[1] ], $
        linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm
    cgPlots, [ pos_3[0], pos_3[2] ], [ pos_3[3], pos_3[3] ], $
        linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm
    cgPlots, [ pos_3[0], pos_3[0] ], [ pos_3[1], pos_3[3] ], $
        linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm 
    cgPlots, [ pos_3[2], pos_3[2] ], [ pos_3[1], pos_3[3] ], $
        linestyle=0, thick=12.0, color=cgColor( 'Black' ), /norm
    ;;
    if keyword_set( title ) then begin 
        cgText, ( pos_3[0] + 0.113 ), ( pos_3[1] + 0.065 ), title, $
            charsize=4.2, charthick=9.0, alignment=0.5, /norm
        cgText, ( pos_3[0] + 0.113 ), ( pos_3[1] + 0.018 ), 'CvD v.s MIU', $ 
            charsize=3.5, charthick=8.0, alignment=0.5, /norm
    endif else begin 
        cgText, ( pos_3[0] + 0.12 ), ( pos_3[1] + 0.067 ), 'CvD 12', $
            charsize=4.0, charthick=8.0, alignment=0.5, /norm
        cgText, ( pos_3[0] + 0.12 ), ( pos_3[1] + 0.043 ), ' v.s.', $ 
            charsize=3.0, charthick=5.0, alignment=0.5, /norm
        cgText, ( pos_3[0] + 0.12 ), ( pos_3[1] + 0.013 ), 'MIUSCAT', $ 
            charsize=4.0, charthick=8.0, alignment=0.5, /norm
    endelse
    ;; IMF
    cgPlots, [ ( pos_3[0] + 0.23 ), ( pos_3[0] + 0.291 ) ], $
        [ ( pos_3[1] + 0.02 ), ( pos_3[1] + 0.02 ) ], $
        linestyle=5, thick=14.0, color=cgColor( 'BLU6' ), /norm
    cgText, ( pos_3[0] + 0.30 ), ( pos_3[1] + 0.074 ), 'IMF:CvD x23', $
        charsize=2.5, charthick=4.0, color=cgColor( 'Black' ), /norm
    ;;
    cgPlots, [ ( pos_3[0] + 0.23 ), ( pos_3[0] + 0.29 ) ], $
        [ ( pos_3[1] + 0.05 ), ( pos_3[1] + 0.05 ) ], $
        linestyle=3, thick=14.0, color=cgColor( 'BLU5' ), /norm
    cgText, ( pos_3[0] + 0.30 ), ( pos_3[1] + 0.044 ), 'IMF:CvD x30', $
        charsize=2.5, charthick=4.0, color=cgColor( 'Black' ), /norm
    ;;
    cgPlots, [ ( pos_3[0] + 0.23 ), ( pos_3[0] + 0.29 ) ], $
        [ ( pos_3[1] + 0.08 ), ( pos_3[1] + 0.08 ) ], $
        linestyle=2, thick=14.0, color=cgColor( 'BLU5' ), /norm
    cgText, ( pos_3[0] + 0.30 ), ( pos_3[1] + 0.014 ), 'IMF:MIU un1.8', $
        charsize=2.5, charthick=4.0, color=cgColor( 'Black' ), /norm
    ;; Age
    cgPlots, [ ( pos_3[0] + 0.44 ), ( pos_3[0] + 0.50 ) ], $
        [ ( pos_3[1] + 0.08 ), ( pos_3[1] + 0.08 ) ], $
        linestyle=5, thick=14.0, color=cgColor( 'Lime Green' ), /norm
    cgText, ( pos_3[0] + 0.51 ), ( pos_3[1] + 0.074 ), 'Age:CvD 9Gyr', $
        charsize=2.5, charthick=4.0, color=cgColor( 'Black' ), /norm
    ;; 
    cgPlots, [ ( pos_3[0] + 0.44 ), ( pos_3[0] + 0.50 ) ], $
        [ ( pos_3[1] + 0.05 ), ( pos_3[1] + 0.05 ) ], $
        linestyle=3, thick=14.0, color=cgColor( 'Lime Green' ), /norm
    cgText, ( pos_3[0] + 0.51 ), ( pos_3[1] + 0.044 ), 'Age:MIU 9Gyr', $
        charsize=2.5, charthick=4.0, color=cgColor( 'Black' ), /norm
    ;; aFe; Met
    cgPlots, [ ( pos_3[0] + 0.65 ), ( pos_3[0] + 0.712 ) ], $
        [ ( pos_3[1] + 0.08 ), ( pos_3[1] + 0.08 ) ], $
        linestyle=5, thick=14.0, color=cgColor( 'RED5' ), /norm
    cgText, ( pos_3[0] + 0.72 ), ( pos_3[1] + 0.074 ), $
        '[' + textoidl( "\alpha" ) + '/Fe]=+0.2 CvD', charsize=2.5, $
        charthick=4.0, color=cgColor( 'Black' ), /norm
    ;;
    cgPlots, [ ( pos_3[0] + 0.65 ), ( pos_3[0] + 0.711 ) ], $
        [ ( pos_3[1] + 0.05 ), ( pos_3[1] + 0.05 ) ], $
        linestyle=2, thick=14.0, color=cgColor( 'Magenta' ), /norm
    cgText, ( pos_3[0] + 0.72 ), ( pos_3[1] + 0.044 ), $
        '[M/H]=+0.2 MIU', charsize=2.5, $
        charthick=4.0, color=cgColor( 'Black' ), /norm
    ;;
    cgPlots, [ ( pos_3[0] + 0.65 ), ( pos_3[0] + 0.71 ) ], $
        [ ( pos_3[1] + 0.02 ), ( pos_3[1] + 0.02 ) ], $
        linestyle=2, thick=14.0, color=cgColor( 'Cyan' ), /norm
    cgText, ( pos_3[0] + 0.72 ), ( pos_3[1] + 0.014 ), $
        '[M/H]=-0.4 MIU', charsize=2.5, $
        charthick=4.0, color=cgColor( 'Black' ), /norm
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
device, /close 
set_plot, mydevice
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

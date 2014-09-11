pro cvd_ssp_prepare, cvd_struc 

    ;;;;;;;; Convolved to 350 km/s 
    sig_conv = 350.0 ; km/s 

    mass_file = 'mass_ssp.dat'
    if NOT file_test( mass_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP mass file: ' + mass_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, mass_file, imf_type, $
            m_now_1, m_now_2, m_now_3, m_now_4, m_now_5, m_now_6, $
            format='A,F,F,F,F,F,F', $
            comment='#', /silent, delimiter=' '
    endelse 

    n_age = 6
    n_imf = 5 
    n_afe = 4 
    n_ssp = ( n_age * n_imf * n_afe )

    ;; age 
    age_arr = [ 3.0, 5.0, 7.0, 9.0, 11.0, 13.5 ]
    age_str = [ 'T03.0', 'T05.0', 'T07.0', 'T09.0', 'T11.0', 'T13.5' ]
    age_yr  = ( age_arr * 1.0D9 )
    ;; imf 
    imf_str = [ 'imf_23', 'imf_30', 'imf_35', 'imf_cb', 'imf_bl' ]
    ;; aFe 
    afe_arr = [ 0.0, 0.2, 0.3, 0.4 ]
    afe_str = [ 'afe00', 'afe02', 'afe03', 'afe04' ]

    min_wave = 3200 
    max_wave = 9200 
    n_pixel = ( max_wave - min_wave ) 
    wave_inter = min_wave + findgen( n_pixel ) * 1.0

    ;; make the structure 
    cvd_struc = { file:'', index:'', metal:0.0, age:0.0, imf:'', afe:0.0, $
        wave:fltarr( n_pixel ), flux:fltarr( n_pixel ), $ 
        flux_conv:fltarr( n_pixel ), ssp_line:'' } 
    cvd_struc = replicate( cvd_struc, n_ssp )
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t03.0_solar.ssp
    index = 0
    n_index = 5
    ssp1 = 't03.0_solar.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 3.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.0 
        cvd_struc[index+0].index = 'x35_t03_afe00'
        cvd_struc[index+0].file  = 'cvd12_x35_t03_afe00.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t03_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+0].index + '   0.987    0    0.000'

        ;; x=3.0
        cvd_struc[index+1].age   = 3.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.0 
        cvd_struc[index+1].index = 'x30_t03_afe00'
        cvd_struc[index+1].file  = 'cvd12_x30_t03_afe00.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t03_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+1].index + '   0.957    0    0.000'

        ;; x=2.3
        cvd_struc[index+2].age   = 3.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.0 
        cvd_struc[index+2].index = 'x23_t03_afe00'
        cvd_struc[index+2].file  = 'cvd12_x23_t03_afe00.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t03_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+2].index + '   0.765    0    0.000'

        ;; Chabrier
        cvd_struc[index+3].age   = 3.0 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.0 
        cvd_struc[index+3].index = 'cha_t03_afe00'
        cvd_struc[index+3].file  = 'cvd12_cha_t03_afe00.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t03_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+3].index + '   0.616    0    0.000'

        ;; Bottom-light
        cvd_struc[index+4].age   = 3.0 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.0 
        cvd_struc[index+4].index = 'btl_t03_afe00'
        cvd_struc[index+4].file  = 'cvd12_btl_t03_afe00.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t03_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+4].index + '   0.267    0    0.000'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t05.0_solar.ssp
    index = 5
    n_index = 5
    ssp1 = 't05.0_solar.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 5.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.0 
        cvd_struc[index+0].index = 'x35_t05_afe00'
        cvd_struc[index+0].file  = 'cvd12_x35_t05_afe00.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t05_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+0].index + '   0.985    0    0.000'

        ;; x=3.0
        cvd_struc[index+1].age   = 5.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.0 
        cvd_struc[index+1].index = 'x30_t05_afe00'
        cvd_struc[index+1].file  = 'cvd12_x30_t05_afe00.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t05_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+1].index + '   0.952    0    0.000'

        ;; x=2.3
        cvd_struc[index+2].age   = 5.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.0 
        cvd_struc[index+2].index = 'x23_t05_afe00'
        cvd_struc[index+2].file  = 'cvd12_x23_t05_afe00.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t05_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+2].index + '   0.752    0    0.000'

        ;; Chabrier
        cvd_struc[index+3].age   = 5.0 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.0 
        cvd_struc[index+3].index = 'cha_t05_afe00'
        cvd_struc[index+3].file  = 'cvd12_cha_t05_afe00.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t05_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+3].index + '   0.597    0    0.000'

        ;; Bottom-light
        cvd_struc[index+4].age   = 5.0 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.0 
        cvd_struc[index+4].index = 'btl_t05_afe00'
        cvd_struc[index+4].file  = 'cvd12_btl_t05_afe00.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t05_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+4].index + '   0.262    0    0.000'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t07.0_solar.ssp
    index = 10
    n_index = 5
    ssp1 = 't07.0_solar.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 7.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.0 
        cvd_struc[index+0].index = 'x35_t07_afe00'
        cvd_struc[index+0].file  = 'cvd12_x35_t07_afe00.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t07_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+0].index + '   0.984    0    0.000'

        ;; x=3.0
        cvd_struc[index+1].age   = 7.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.0 
        cvd_struc[index+1].index = 'x30_t07_afe00'
        cvd_struc[index+1].file  = 'cvd12_x30_t07_afe00.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t07_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+1].index + '   0.949    0    0.000'

        ;; x=2.3
        cvd_struc[index+2].age   = 7.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.0 
        cvd_struc[index+2].index = 'x23_t07_afe00'
        cvd_struc[index+2].file  = 'cvd12_x23_t07_afe00.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t07_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+2].index + '   0.744    0    0.000'

        ;; Chabrier
        cvd_struc[index+3].age   = 7.0 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.0 
        cvd_struc[index+3].index = 'cha_t07_afe00'
        cvd_struc[index+3].file  = 'cvd12_cha_t07_afe00.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t07_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+3].index + '   0.585    0    0.000'

        ;; Bottom-light
        cvd_struc[index+4].age   = 7.0 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.0 
        cvd_struc[index+4].index = 'btl_t07_afe00'
        cvd_struc[index+4].file  = 'cvd12_btl_t07_afe00.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t07_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+4].index + '   0.259    0    0.000'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t09.0_solar.ssp
    index = 15
    n_index = 5
    ssp1 = 't09.0_solar.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 9.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.0 
        cvd_struc[index+0].index = 'x35_t09_afe00'
        cvd_struc[index+0].file  = 'cvd12_x35_t09_afe00.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t09_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+0].index + '   0.983    0    0.000'

        ;; x=3.0
        cvd_struc[index+1].age   = 9.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.0 
        cvd_struc[index+1].index = 'x30_t09_afe00'
        cvd_struc[index+1].file  = 'cvd12_x30_t09_afe00.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t09_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+1].index + '   0.947    0    0.000'

        ;; x=2.3
        cvd_struc[index+2].age   = 9.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.0 
        cvd_struc[index+2].index = 'x23_t09_afe00'
        cvd_struc[index+2].file  = 'cvd12_x23_t09_afe00.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t09_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+2].index + '   0.740    0    0.000'

        ;; Chabrier
        cvd_struc[index+3].age   = 9.0 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.0 
        cvd_struc[index+3].index = 'cha_t09_afe00'
        cvd_struc[index+3].file  = 'cvd12_cha_t09_afe00.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t09_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+3].index + '   0.579    0    0.000'

        ;; Bottom-light
        cvd_struc[index+4].age   = 9.0 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.0 
        cvd_struc[index+4].index = 'btl_t09_afe00'
        cvd_struc[index+4].file  = 'cvd12_btl_t09_afe00.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t09_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+4].index + '   0.258    0    0.000'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t11.0_solar.ssp
    index = 20
    n_index = 5
    ssp1 = 't11.0_solar.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 11.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.0 
        cvd_struc[index+0].index = 'x35_t11_afe00'
        cvd_struc[index+0].file  = 'cvd12_x35_t11_afe00.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t11_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+0].index + '   0.982    0    0.000'

        ;; x=3.0
        cvd_struc[index+1].age   = 11.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.0 
        cvd_struc[index+1].index = 'x30_t11_afe00'
        cvd_struc[index+1].file  = 'cvd12_x30_t11_afe00.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t11_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+1].index + '   0.944    0    0.000'

        ;; x=2.3
        cvd_struc[index+2].age   = 11.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.0 
        cvd_struc[index+2].index = 'x23_t11_afe00'
        cvd_struc[index+2].file  = 'cvd12_x23_t11_afe00.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t11_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+2].index + '   0.736    0    0.000'

        ;; Chabrier
        cvd_struc[index+3].age   = 11.0 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.0 
        cvd_struc[index+3].index = 'cha_t11_afe00'
        cvd_struc[index+3].file  = 'cvd12_cha_t11_afe00.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t11_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+3].index + '   0.572    0    0.000'

        ;; Bottom-light
        cvd_struc[index+4].age   = 11.0 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.0 
        cvd_struc[index+4].index = 'btl_t11_afe00'
        cvd_struc[index+4].file  = 'cvd12_btl_t11_afe00.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t11_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+4].index + '   0.256    0    0.000'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t13.5_solar.ssp
    index = 25
    n_index = 5
    ssp1 = 't13.5_solar.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 13.5 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.0 
        cvd_struc[index+0].index = 'x35_t13_afe00'
        cvd_struc[index+0].file  = 'cvd12_x35_t13_afe00.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t13_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+0].index + '   0.982    0    0.000'

        ;; x=3.0
        cvd_struc[index+1].age   = 13.5 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.0 
        cvd_struc[index+1].index = 'x30_t13_afe00'
        cvd_struc[index+1].file  = 'cvd12_x30_t13_afe00.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t13_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+1].index + '   0.943    0    0.000'

        ;; x=2.3
        cvd_struc[index+2].age   = 13.5 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.0 
        cvd_struc[index+2].index = 'x23_t13_afe00'
        cvd_struc[index+2].file  = 'cvd12_x23_t13_afe00.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t13_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+2].index + '   0.736    0    0.000'

        ;; Chabrier
        cvd_struc[index+3].age   = 13.5 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.0 
        cvd_struc[index+3].index = 'cha_t13_afe00'
        cvd_struc[index+3].file  = 'cvd12_cha_t13_afe00.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t13_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+3].index + '   0.572    0    0.000'

        ;; Bottom-light
        cvd_struc[index+4].age   = 13.5 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.0 
        cvd_struc[index+4].index = 'btl_t13_afe00'
        cvd_struc[index+4].file  = 'cvd12_btl_t13_afe00.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t13_afe00.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.0000   ' + cvd_struc[index+4].index + '   0.256    0    0.000'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t13.5_afe+0.2.ssp
    index = 30
    n_index = 5
    ssp1 = 't13.5_afe+0.2.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 13.5 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x35_t13_afe02'
        cvd_struc[index+0].file  = 'cvd12_x35_t13_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t13_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.982    0    0.000'
        afe02_x35 = ( flux_inter / cvd_struc[25].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[25].file 
        print, 'aFe+0.2/x=3.5 ', min( afe02_x35 ), max( afe02_x35 )

        ;; x=3.0
        cvd_struc[index+1].age   = 13.5 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.2 
        cvd_struc[index+1].index = 'x30_t13_afe02'
        cvd_struc[index+1].file  = 'cvd12_x30_t13_afe02.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t13_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+1].index + '   0.943    0    0.000'
        afe02_x30 = ( flux_inter / cvd_struc[26].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[26].file 
        print, 'aFe+0.2/x=3.0 ', min( afe02_x30 ), max( afe02_x30 )

        ;; x=2.3
        cvd_struc[index+2].age   = 13.5 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.2 
        cvd_struc[index+2].index = 'x23_t13_afe02'
        cvd_struc[index+2].file  = 'cvd12_x23_t13_afe02.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t13_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+2].index + '   0.736    0    0.000'
        afe02_x23 = ( flux_inter / cvd_struc[27].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[27].file 
        print, 'aFe+0.2/x=2.3 ', min( afe02_x23 ), max( afe02_x23 )

        ;; Chabrier
        cvd_struc[index+3].age   = 13.5 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.2 
        cvd_struc[index+3].index = 'cha_t13_afe02'
        cvd_struc[index+3].file  = 'cvd12_cha_t13_afe02.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t13_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+3].index + '   0.572    0    0.000'
        afe02_cha = ( flux_inter / cvd_struc[28].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[28].file 
        print, 'aFe+0.2/x=chab ', min( afe02_cha ), max( afe02_cha )

        ;; Bottom-light
        cvd_struc[index+4].age   = 13.5 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.2 
        cvd_struc[index+4].index = 'btl_t13_afe02'
        cvd_struc[index+4].file  = 'cvd12_btl_t13_afe02.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t13_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+4].index + '   0.256    0    0.000'
        afe02_btl = ( flux_inter / cvd_struc[29].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[29].file 
        print, 'aFe+0.2/x=btl ', min( afe02_btl ), max( afe02_btl )

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t13.5_afe+0.3.ssp
    index = 35
    n_index = 5
    ssp1 = 't13.5_afe+0.3.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 13.5 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.3 
        cvd_struc[index+0].index = 'x35_t13_afe03'
        cvd_struc[index+0].file  = 'cvd12_x35_t13_afe03.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t13_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+0].index + '   0.982    0    0.000'
        afe03_x35 = ( flux_inter / cvd_struc[25].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[25].file 
        print, 'aFe+0.3/x=3.5 ', min( afe03_x35 ), max( afe03_x35 )

        ;; x=3.0
        cvd_struc[index+1].age   = 13.5 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x30_t13_afe03'
        cvd_struc[index+1].file  = 'cvd12_x30_t13_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t13_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.943    0    0.000'
        afe03_x30 = ( flux_inter / cvd_struc[26].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[26].file 
        print, 'aFe+0.3/x=3.0 ', min( afe03_x30 ), max( afe03_x30 )

        ;; x=2.3
        cvd_struc[index+2].age   = 13.5 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.3 
        cvd_struc[index+2].index = 'x23_t13_afe03'
        cvd_struc[index+2].file  = 'cvd12_x23_t13_afe03.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t13_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+2].index + '   0.736    0    0.000'
        afe03_x23 = ( flux_inter / cvd_struc[27].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[27].file 
        print, 'aFe+0.3/x=2.3 ', min( afe03_x23 ), max( afe03_x23 )

        ;; Chabrier
        cvd_struc[index+3].age   = 13.5 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.3 
        cvd_struc[index+3].index = 'cha_t13_afe03'
        cvd_struc[index+3].file  = 'cvd12_cha_t13_afe03.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t13_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+3].index + '   0.572    0    0.000'
        afe03_cha = ( flux_inter / cvd_struc[28].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[28].file 
        print, 'aFe+0.3/x=chab ', min( afe03_cha ), max( afe03_cha )

        ;; Bottom-light
        cvd_struc[index+4].age   = 13.5 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.3 
        cvd_struc[index+4].index = 'btl_t13_afe03'
        cvd_struc[index+4].file  = 'cvd12_btl_t13_afe03.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t13_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+4].index + '   0.256    0    0.000'
        afe03_btl = ( flux_inter / cvd_struc[29].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[29].file 
        print, 'aFe+0.3/x=btl ', min( afe03_btl ), max( afe03_btl )

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; t13.5_afe+0.4.ssp
    index = 40
    n_index = 5
    ssp1 = 't13.5_afe+0.4.ssp'
    if NOT file_test( ssp1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the SSP file: ' + ssp1 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        readcol, ssp1, lambda, flux1, flux2, flux3, flux4, flux5, $
            comment='#', delimiter=' ', /silent

        ;; x=3.5
        cvd_struc[index+0].age   = 13.5 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.4 
        cvd_struc[index+0].index = 'x35_t13_afe04'
        cvd_struc[index+0].file  = 'cvd12_x35_t13_afe04.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        flux_inter  = interpol( flux1, lambda, wave_inter, /spline )
        cvd_struc[index+0].flux  = flux_inter
        openw, 10, 'cvd12_x35_t13_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+0].index + '   0.982    0    0.000'
        afe04_x35 = ( flux_inter / cvd_struc[25].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[25].file 
        print, 'aFe+0.4/x=35 ', min( afe04_x35 ), max( afe04_x35 )

        ;; x=3.0
        cvd_struc[index+1].age   = 13.5 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.4 
        cvd_struc[index+1].index = 'x30_t13_afe04'
        cvd_struc[index+1].file  = 'cvd12_x30_t13_afe04.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        flux_inter  = interpol( flux2, lambda, wave_inter, /spline )
        cvd_struc[index+1].flux  = flux_inter
        openw, 10, 'cvd12_x30_t13_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+1].index + '   0.943    0    0.000'
        afe04_x30 = ( flux_inter / cvd_struc[26].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[26].file 
        print, 'aFe+0.4/x=30 ', min( afe04_x30 ), max( afe04_x30 )

        ;; x=2.3
        cvd_struc[index+2].age   = 13.5 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x23_t13_afe04'
        cvd_struc[index+2].file  = 'cvd12_x23_t13_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        flux_inter  = interpol( flux3, lambda, wave_inter, /spline )
        cvd_struc[index+2].flux  = flux_inter
        openw, 10, 'cvd12_x23_t13_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.736    0    0.000'
        afe04_x23 = ( flux_inter / cvd_struc[27].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[27].file 
        print, 'aFe+0.4/x=23 ', min( afe04_x23 ), max( afe04_x23 )

        ;; Chabrier
        cvd_struc[index+3].age   = 13.5 
        cvd_struc[index+3].metal = 0.02
        cvd_struc[index+3].imf   = 'cha'
        cvd_struc[index+3].afe   = 0.4 
        cvd_struc[index+3].index = 'cha_t13_afe04'
        cvd_struc[index+3].file  = 'cvd12_cha_t13_afe04.ssp' 
        cvd_struc[index+3].wave  = wave_inter 
        flux_inter  = interpol( flux4, lambda, wave_inter, /spline )
        cvd_struc[index+3].flux  = flux_inter
        openw, 10, 'cvd12_cha_t13_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+3].ssp_line = cvd_struc[index+3].file + '   ' + $ 
            string( ( cvd_struc[index+3].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+3].index + '   0.572    0    0.000'
        afe04_cha = ( flux_inter / cvd_struc[28].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[28].file 
        print, 'aFe+0.4/chab ', min( afe04_cha ), max( afe04_cha )

        ;; Bottom-light
        cvd_struc[index+4].age   = 13.5 
        cvd_struc[index+4].metal = 0.02
        cvd_struc[index+4].imf   = 'btl'
        cvd_struc[index+4].afe   = 0.4 
        cvd_struc[index+4].index = 'btl_t13_afe04'
        cvd_struc[index+4].file  = 'cvd12_btl_t13_afe04.ssp' 
        cvd_struc[index+4].wave  = wave_inter 
        flux_inter  = interpol( flux5, lambda, wave_inter, /spline )
        cvd_struc[index+4].flux  = flux_inter
        openw, 10, 'cvd12_btl_t13_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+4].ssp_line = cvd_struc[index+4].file + '   ' + $ 
            string( ( cvd_struc[index+4].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+4].index + '   0.256    0    0.000'
        afe04_btl = ( flux_inter / cvd_struc[29].flux )
        print, '###############################################################'
        print, 'Based on : ', cvd_struc[29].file 
        print, 'aFe+0.4/btl ', min( afe04_btl ), max( afe04_btl )
        print, '###############################################################'

    endelse

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; afe+0.2/0.3/0.4 for age03
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, ' Age = 03.0 Gyr '
    index = 45
    n_index = 15 

        ;; x=3.5 afe+0.2
        cvd_struc[index+0].age   = 3.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x35_t03_afe02'
        cvd_struc[index+0].file  = 'cvd12_x35_t03_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[0].flux * afe02_x35 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[0].index, ' aFe02_x35'
        openw, 10, 'cvd12_x35_t03_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.987    0    0.000'

        ;; x=3.5 afe+0.3
        cvd_struc[index+1].age   = 3.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x35'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x35_t03_afe03'
        cvd_struc[index+1].file  = 'cvd12_x35_t03_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[0].flux * afe03_x35 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[0].index, ' aFe03_x35'
        openw, 10, 'cvd12_x35_t03_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.987    0    0.000'

        ;; x=3.5 afe+0.4
        cvd_struc[index+2].age   = 3.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x35'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x35_t03_afe04'
        cvd_struc[index+2].file  = 'cvd12_x35_t03_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[0].flux * afe04_x35 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[0].index, ' aFe04_x35'
        openw, 10, 'cvd12_x35_t03_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.987    0    0.000'
        index = index + 3

        ;; x=3.0 afe+0.2
        cvd_struc[index+0].age   = 3.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x30'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x30_t03_afe02'
        cvd_struc[index+0].file  = 'cvd12_x30_t03_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[1].flux * afe02_x30 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[1].index, ' aFe02_x30'
        openw, 10, 'cvd12_x30_t03_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.957    0    0.000'

        ;; x=3.0 afe+0.3
        cvd_struc[index+1].age   = 3.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x30_t03_afe03'
        cvd_struc[index+1].file  = 'cvd12_x30_t03_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[1].flux * afe03_x30 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[1].index, ' aFe03_x30'
        openw, 10, 'cvd12_x30_t03_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.957    0    0.000'

        ;; x=3.0 afe+0.4
        cvd_struc[index+2].age   = 3.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x30'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x30_t03_afe04'
        cvd_struc[index+2].file  = 'cvd12_x30_t03_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[1].flux * afe04_x30 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[1].index, ' aFe04_x30'
        openw, 10, 'cvd12_x30_t03_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.957    0    0.000'
        index = index + 3


        ;; x=2.35 afe+0.2
        cvd_struc[index+0].age   = 3.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x23'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x23_t03_afe02'
        cvd_struc[index+0].file  = 'cvd12_x23_t03_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[2].flux * afe02_x23 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[2].index, ' aFe02_x23'
        openw, 10, 'cvd12_x23_t03_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.765    0    0.000'

        ;; x=2.35 afe+0.3
        cvd_struc[index+1].age   = 3.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x23'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x23_t03_afe03'
        cvd_struc[index+1].file  = 'cvd12_x23_t03_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[2].flux * afe03_x23 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[2].index, ' aFe03_x23'
        openw, 10, 'cvd12_x23_t03_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.765    0    0.000'

        ;; x=2.35 afe+0.4
        cvd_struc[index+2].age   = 3.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x23_t03_afe04'
        cvd_struc[index+2].file  = 'cvd12_x23_t03_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[2].flux * afe04_x23 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[2].index, ' aFe04_x23'
        openw, 10, 'cvd12_x23_t03_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.765    0    0.000'
        index = index + 3

        ;; Chabrier afe+0.2
        cvd_struc[index+0].age   = 3.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'cha'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'cha_t03_afe02'
        cvd_struc[index+0].file  = 'cvd12_cha_t03_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[3].flux * afe02_cha )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[3].index, ' aFe02_cha'
        openw, 10, 'cvd12_cha_t03_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.616    0    0.000'

        ;; Chabrier afe+0.3
        cvd_struc[index+1].age   = 3.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'cha'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'cha_t03_afe03'
        cvd_struc[index+1].file  = 'cvd12_cha_t03_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[3].flux * afe03_cha )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[3].index, ' aFe03_cha'
        openw, 10, 'cvd12_cha_t03_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.616    0    0.000'

        ;; Chabrier afe+0.4
        cvd_struc[index+2].age   = 3.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'cha'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'cha_t03_afe04'
        cvd_struc[index+2].file  = 'cvd12_cha_t03_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[3].flux * afe04_cha )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[3].index, ' aFe04_cha'
        openw, 10, 'cvd12_cha_t03_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.616    0    0.000'
        index = index + 3


        ;; Bottom-light afe+0.2
        cvd_struc[index+0].age   = 3.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'btl'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'btl_t03_afe02'
        cvd_struc[index+0].file  = 'cvd12_btl_t03_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[4].flux * afe02_btl )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[4].index, ' aFe02_btl'
        openw, 10, 'cvd12_btl_t03_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.267    0    0.000'

        ;; btlbrier afe+0.3
        cvd_struc[index+1].age   = 3.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'btl'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'btl_t03_afe03'
        cvd_struc[index+1].file  = 'cvd12_btl_t03_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[4].flux * afe03_btl )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[4].index, ' aFe03_btl'
        openw, 10, 'cvd12_btl_t03_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.267    0    0.000'

        ;; btlbrier afe+0.4
        cvd_struc[index+2].age   = 3.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'btl'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'btl_t03_afe04'
        cvd_struc[index+2].file  = 'cvd12_btl_t03_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[4].flux * afe04_btl )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[4].index, ' aFe04_btl'
        openw, 10, 'cvd12_btl_t03_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.267    0    0.000'
        index = index + 3


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; afe+0.2/0.3/0.4 for age05
    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    print, ' Age = 05.0 Gyr '
    index = 60
    n_index = 15 

        ;; x=3.5 afe+0.2
        cvd_struc[index+0].age   = 5.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x35_t05_afe02'
        cvd_struc[index+0].file  = 'cvd12_x35_t05_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[5].flux * afe02_x35 )
        print, '###############################################################'
        print, ' Based on ', cvd_struc[5].index, ' aFe02_x35'
        openw, 10, 'cvd12_x35_t05_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.985    0    0.000'
        ;; x=3.5 afe+0.3
        cvd_struc[index+1].age   = 5.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x35'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x35_t05_afe03'
        cvd_struc[index+1].file  = 'cvd12_x35_t05_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[5].flux * afe03_x35 )
        openw, 10, 'cvd12_x35_t05_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.985    0    0.000'
        ;; x=3.5 afe+0.4
        cvd_struc[index+2].age   = 5.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x35'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x35_t05_afe04'
        cvd_struc[index+2].file  = 'cvd12_x35_t05_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[5].flux * afe04_x35 )
        openw, 10, 'cvd12_x35_t05_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.985    0    0.000'
        index = index + 3

        ;; x=3.0 afe+0.2
        cvd_struc[index+0].age   = 5.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x30'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x30_t05_afe02'
        cvd_struc[index+0].file  = 'cvd12_x30_t05_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[6].flux * afe02_x30 )
        openw, 10, 'cvd12_x30_t05_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.952    0    0.000'
        ;; x=3.0 afe+0.3
        cvd_struc[index+1].age   = 5.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x30_t05_afe03'
        cvd_struc[index+1].file  = 'cvd12_x30_t05_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[6].flux * afe03_x30 )
        openw, 10, 'cvd12_x30_t05_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.952    0    0.000'
        ;; x=3.0 afe+0.4
        cvd_struc[index+2].age   = 5.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x30'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x30_t05_afe04'
        cvd_struc[index+2].file  = 'cvd12_x30_t05_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[6].flux * afe04_x30 )
        openw, 10, 'cvd12_x30_t05_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.952    0    0.000'
        index = index + 3


        ;; x=2.35 afe+0.2
        cvd_struc[index+0].age   = 5.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x23'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x23_t05_afe02'
        cvd_struc[index+0].file  = 'cvd12_x23_t05_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[7].flux * afe02_x23 )
        openw, 10, 'cvd12_x23_t05_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.752    0    0.000'
        ;; x=2.35 afe+0.3
        cvd_struc[index+1].age   = 5.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x23'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x23_t05_afe03'
        cvd_struc[index+1].file  = 'cvd12_x23_t05_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[7].flux * afe03_x23 )
        openw, 10, 'cvd12_x23_t05_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.752    0    0.000'
        ;; x=2.35 afe+0.4
        cvd_struc[index+2].age   = 5.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x23_t05_afe04'
        cvd_struc[index+2].file  = 'cvd12_x23_t05_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[7].flux * afe04_x23 )
        openw, 10, 'cvd12_x23_t05_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.752    0    0.000'
        index = index + 3

        ;; Chabrier afe+0.2
        cvd_struc[index+0].age   = 5.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'cha'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'cha_t05_afe02'
        cvd_struc[index+0].file  = 'cvd12_cha_t05_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[8].flux * afe02_cha )
        openw, 10, 'cvd12_cha_t05_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.597    0    0.000'
        ;; Chabrier afe+0.3
        cvd_struc[index+1].age   = 5.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'cha'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'cha_t05_afe03'
        cvd_struc[index+1].file  = 'cvd12_cha_t05_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[8].flux * afe03_cha )
        openw, 10, 'cvd12_cha_t05_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.597    0    0.000'
        ;; Chabrier afe+0.4
        cvd_struc[index+2].age   = 5.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'cha'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'cha_t05_afe04'
        cvd_struc[index+2].file  = 'cvd12_cha_t05_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[8].flux * afe04_cha )
        openw, 10, 'cvd12_cha_t05_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.597    0    0.000'
        index = index + 3


        ;; Bottom-light afe+0.2
        cvd_struc[index+0].age   = 5.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'btl'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'btl_t05_afe02'
        cvd_struc[index+0].file  = 'cvd12_btl_t05_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[9].flux * afe02_btl )
        openw, 10, 'cvd12_btl_t05_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.262    0    0.000'
        ;; btlbrier afe+0.3
        cvd_struc[index+1].age   = 5.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'btl'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'btl_t05_afe03'
        cvd_struc[index+1].file  = 'cvd12_btl_t05_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[9].flux * afe03_btl )
        openw, 10, 'cvd12_btl_t05_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.262    0    0.000'
        ;; btlbrier afe+0.4
        cvd_struc[index+2].age   = 5.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'btl'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'btl_t05_afe04'
        cvd_struc[index+2].file  = 'cvd12_btl_t05_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[9].flux * afe04_btl )
        openw, 10, 'cvd12_btl_t05_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.262    0    0.000'
        index = index + 3


    ;; afe+0.2/0.3/0.4 for age07
    index = 75
    n_index = 15 

        ;; x=3.5 afe+0.2
        cvd_struc[index+0].age   = 7.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x35_t07_afe02'
        cvd_struc[index+0].file  = 'cvd12_x35_t07_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[10].flux * afe02_x35 )
        openw, 10, 'cvd12_x35_t07_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.984    0    0.000'
        ;; x=3.5 afe+0.3
        cvd_struc[index+1].age   = 7.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x35'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x35_t07_afe03'
        cvd_struc[index+1].file  = 'cvd12_x35_t07_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[10].flux * afe03_x35 )
        openw, 10, 'cvd12_x35_t07_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.984    0    0.000'
        ;; x=3.5 afe+0.4
        cvd_struc[index+2].age   = 7.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x35'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x35_t07_afe04'
        cvd_struc[index+2].file  = 'cvd12_x35_t07_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[10].flux * afe04_x35 )
        openw, 10, 'cvd12_x35_t07_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.984    0    0.000'
        index = index + 3

        ;; x=3.0 afe+0.2
        cvd_struc[index+0].age   = 7.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x30'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x30_t07_afe02'
        cvd_struc[index+0].file  = 'cvd12_x30_t07_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[11].flux * afe02_x30 )
        openw, 10, 'cvd12_x30_t07_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.949    0    0.000'
        ;; x=3.0 afe+0.3
        cvd_struc[index+1].age   = 7.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x30_t07_afe03'
        cvd_struc[index+1].file  = 'cvd12_x30_t07_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[11].flux * afe03_x30 )
        openw, 10, 'cvd12_x30_t07_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.949    0    0.000'
        ;; x=3.0 afe+0.4
        cvd_struc[index+2].age   = 7.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x30'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x30_t07_afe04'
        cvd_struc[index+2].file  = 'cvd12_x30_t07_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[11].flux * afe04_x30 )
        openw, 10, 'cvd12_x30_t07_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.949    0    0.000'
        index = index + 3


        ;; x=2.35 afe+0.2
        cvd_struc[index+0].age   = 7.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x23'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x23_t07_afe02'
        cvd_struc[index+0].file  = 'cvd12_x23_t07_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[12].flux * afe02_x23 )
        openw, 10, 'cvd12_x23_t07_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.744    0    0.000'
        ;; x=2.35 afe+0.3
        cvd_struc[index+1].age   = 7.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x23'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x23_t07_afe03'
        cvd_struc[index+1].file  = 'cvd12_x23_t07_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[12].flux * afe03_x23 )
        openw, 10, 'cvd12_x23_t07_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.744    0    0.000'
        ;; x=2.35 afe+0.4
        cvd_struc[index+2].age   = 7.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x23_t07_afe04'
        cvd_struc[index+2].file  = 'cvd12_x23_t07_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[12].flux * afe04_x23 )
        openw, 10, 'cvd12_x23_t07_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.744    0    0.000'
        index = index + 3

        ;; Chabrier afe+0.2
        cvd_struc[index+0].age   = 7.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'cha'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'cha_t07_afe02'
        cvd_struc[index+0].file  = 'cvd12_cha_t07_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[13].flux * afe02_cha )
        openw, 10, 'cvd12_cha_t07_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.585    0    0.000'
        ;; Chabrier afe+0.3
        cvd_struc[index+1].age   = 7.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'cha'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'cha_t07_afe03'
        cvd_struc[index+1].file  = 'cvd12_cha_t07_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[13].flux * afe03_cha )
        openw, 10, 'cvd12_cha_t07_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.585    0    0.000'
        ;; Chabrier afe+0.4
        cvd_struc[index+2].age   = 7.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'cha'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'cha_t07_afe04'
        cvd_struc[index+2].file  = 'cvd12_cha_t07_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[13].flux * afe04_cha )
        openw, 10, 'cvd12_cha_t07_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.585    0    0.000'
        index = index + 3


        ;; Bottom-light afe+0.2
        cvd_struc[index+0].age   = 7.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'btl'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'btl_t07_afe02'
        cvd_struc[index+0].file  = 'cvd12_btl_t07_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[14].flux * afe02_btl )
        openw, 10, 'cvd12_btl_t07_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.259    0    0.000'
        ;; btlbrier afe+0.3
        cvd_struc[index+1].age   = 7.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'btl'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'btl_t07_afe03'
        cvd_struc[index+1].file  = 'cvd12_btl_t07_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[14].flux * afe03_btl )
        openw, 10, 'cvd12_btl_t07_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.259    0    0.000'
        ;; btlbrier afe+0.4
        cvd_struc[index+2].age   = 7.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'btl'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'btl_t07_afe04'
        cvd_struc[index+2].file  = 'cvd12_btl_t07_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[14].flux * afe04_btl )
        openw, 10, 'cvd12_btl_t07_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.259    0    0.000'
        index = index + 3


    ;; afe+0.2/0.3/0.4 for age09
    index = 90
    n_index = 15 

        ;; x=3.5 afe+0.2
        cvd_struc[index+0].age   = 9.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x35_t09_afe02'
        cvd_struc[index+0].file  = 'cvd12_x35_t09_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[15].flux * afe02_x35 )
        openw, 10, 'cvd12_x35_t09_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.983    0    0.000'
        ;; x=3.5 afe+0.3
        cvd_struc[index+1].age   = 9.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x35'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x35_t09_afe03'
        cvd_struc[index+1].file  = 'cvd12_x35_t09_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[15].flux * afe03_x35 )
        openw, 10, 'cvd12_x35_t09_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.983    0    0.000'
        ;; x=3.5 afe+0.4
        cvd_struc[index+2].age   = 9.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x35'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x35_t09_afe04'
        cvd_struc[index+2].file  = 'cvd12_x35_t09_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[15].flux * afe04_x35 )
        openw, 10, 'cvd12_x35_t09_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.983    0    0.000'
        index = index + 3

        ;; x=3.0 afe+0.2
        cvd_struc[index+0].age   = 9.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x30'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x30_t09_afe02'
        cvd_struc[index+0].file  = 'cvd12_x30_t09_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[16].flux * afe02_x30 )
        openw, 10, 'cvd12_x30_t09_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.947    0    0.000'
        ;; x=3.0 afe+0.3
        cvd_struc[index+1].age   = 9.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x30_t09_afe03'
        cvd_struc[index+1].file  = 'cvd12_x30_t09_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[16].flux * afe03_x30 )
        openw, 10, 'cvd12_x30_t09_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.947    0    0.000'
        ;; x=3.0 afe+0.4
        cvd_struc[index+2].age   = 9.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x30'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x30_t09_afe04'
        cvd_struc[index+2].file  = 'cvd12_x30_t09_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[16].flux * afe04_x30 )
        openw, 10, 'cvd12_x30_t09_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.947    0    0.000'
        index = index + 3


        ;; x=2.35 afe+0.2
        cvd_struc[index+0].age   = 9.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x23'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x23_t09_afe02'
        cvd_struc[index+0].file  = 'cvd12_x23_t09_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[17].flux * afe02_x23 )
        openw, 10, 'cvd12_x23_t09_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.740    0    0.000'
        ;; x=2.35 afe+0.3
        cvd_struc[index+1].age   = 9.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x23'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x23_t09_afe03'
        cvd_struc[index+1].file  = 'cvd12_x23_t09_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[17].flux * afe03_x23 )
        openw, 10, 'cvd12_x23_t09_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.740    0    0.000'
        ;; x=2.35 afe+0.4
        cvd_struc[index+2].age   = 9.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x23_t09_afe04'
        cvd_struc[index+2].file  = 'cvd12_x23_t09_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[17].flux * afe04_x23 )
        openw, 10, 'cvd12_x23_t09_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.740    0    0.000'
        index = index + 3

        ;; Chabrier afe+0.2
        cvd_struc[index+0].age   = 9.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'cha'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'cha_t09_afe02'
        cvd_struc[index+0].file  = 'cvd12_cha_t09_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[18].flux * afe02_cha )
        openw, 10, 'cvd12_cha_t09_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.579    0    0.000'
        ;; Chabrier afe+0.3
        cvd_struc[index+1].age   = 9.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'cha'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'cha_t09_afe03'
        cvd_struc[index+1].file  = 'cvd12_cha_t09_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[18].flux * afe03_cha )
        openw, 10, 'cvd12_cha_t09_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.579    0    0.000'
        ;; Chabrier afe+0.4
        cvd_struc[index+2].age   = 9.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'cha'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'cha_t09_afe04'
        cvd_struc[index+2].file  = 'cvd12_cha_t09_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[18].flux * afe04_cha )
        openw, 10, 'cvd12_cha_t09_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.579    0    0.000'
        index = index + 3


        ;; Bottom-light afe+0.2
        cvd_struc[index+0].age   = 9.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'btl'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'btl_t09_afe02'
        cvd_struc[index+0].file  = 'cvd12_btl_t09_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[19].flux * afe02_btl )
        openw, 10, 'cvd12_btl_t09_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.258    0    0.000'
        ;; btlbrier afe+0.3
        cvd_struc[index+1].age   = 9.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'btl'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'btl_t09_afe03'
        cvd_struc[index+1].file  = 'cvd12_btl_t09_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[19].flux * afe03_btl )
        openw, 10, 'cvd12_btl_t09_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.258    0    0.000'
        ;; btlbrier afe+0.4
        cvd_struc[index+2].age   = 9.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'btl'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'btl_t09_afe04'
        cvd_struc[index+2].file  = 'cvd12_btl_t09_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[19].flux * afe04_btl )
        openw, 10, 'cvd12_btl_t09_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.258    0    0.000'
        index = index + 3


    ;; afe+0.2/0.3/0.4 for age11
    index = 105
    n_index = 15 

        ;; x=3.5 afe+0.2
        cvd_struc[index+0].age   = 11.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x35'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x35_t11_afe02'
        cvd_struc[index+0].file  = 'cvd12_x35_t11_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[20].flux * afe02_x35 )
        openw, 10, 'cvd12_x35_t11_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.982    0    0.000'
        ;; x=3.5 afe+0.3
        cvd_struc[index+1].age   = 11.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x35'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x35_t11_afe03'
        cvd_struc[index+1].file  = 'cvd12_x35_t11_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[20].flux * afe03_x35 )
        openw, 10, 'cvd12_x35_t11_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.982    0    0.000'
        ;; x=3.5 afe+0.4
        cvd_struc[index+2].age   = 11.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x35'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x35_t11_afe04'
        cvd_struc[index+2].file  = 'cvd12_x35_t11_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[20].flux * afe04_x35 )
        openw, 10, 'cvd12_x35_t11_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.982    0    0.000'
        index = index + 3

        ;; x=3.0 afe+0.2
        cvd_struc[index+0].age   = 11.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x30'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x30_t11_afe02'
        cvd_struc[index+0].file  = 'cvd12_x30_t11_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[21].flux * afe02_x30 )
        openw, 10, 'cvd12_x30_t11_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.944    0    0.000'
        ;; x=3.0 afe+0.3
        cvd_struc[index+1].age   = 11.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x30'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x30_t11_afe03'
        cvd_struc[index+1].file  = 'cvd12_x30_t11_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[21].flux * afe03_x30 )
        openw, 10, 'cvd12_x30_t11_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.944    0    0.000'
        ;; x=3.0 afe+0.4
        cvd_struc[index+2].age   = 11.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x30'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x30_t11_afe04'
        cvd_struc[index+2].file  = 'cvd12_x30_t11_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[21].flux * afe04_x30 )
        openw, 10, 'cvd12_x30_t11_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.944    0    0.000'
        index = index + 3


        ;; x=2.35 afe+0.2
        cvd_struc[index+0].age   = 11.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'x23'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'x23_t11_afe02'
        cvd_struc[index+0].file  = 'cvd12_x23_t11_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[22].flux * afe02_x23 )
        openw, 10, 'cvd12_x23_t11_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.736    0    0.000'
        ;; x=2.35 afe+0.3
        cvd_struc[index+1].age   = 11.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'x23'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'x23_t11_afe03'
        cvd_struc[index+1].file  = 'cvd12_x23_t11_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[22].flux * afe03_x23 )
        openw, 10, 'cvd12_x23_t11_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.736    0    0.000'
        ;; x=2.35 afe+0.4
        cvd_struc[index+2].age   = 11.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'x23'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'x23_t11_afe04'
        cvd_struc[index+2].file  = 'cvd12_x23_t11_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[22].flux * afe04_x23 )
        openw, 10, 'cvd12_x23_t11_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.736    0    0.000'
        index = index + 3

        ;; Chabrier afe+0.2
        cvd_struc[index+0].age   = 11.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'cha'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'cha_t11_afe02'
        cvd_struc[index+0].file  = 'cvd12_cha_t11_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[23].flux * afe02_cha )
        openw, 10, 'cvd12_cha_t11_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.572    0    0.000'
        ;; Chabrier afe+0.3
        cvd_struc[index+1].age   = 11.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'cha'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'cha_t11_afe03'
        cvd_struc[index+1].file  = 'cvd12_cha_t11_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[23].flux * afe03_cha )
        openw, 10, 'cvd12_cha_t11_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.572    0    0.000'
        ;; Chabrier afe+0.4
        cvd_struc[index+2].age   = 11.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'cha'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'cha_t11_afe04'
        cvd_struc[index+2].file  = 'cvd12_cha_t11_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[23].flux * afe04_cha )
        openw, 10, 'cvd12_cha_t11_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.572    0    0.000'
        index = index + 3


        ;; Bottom-light afe+0.2
        cvd_struc[index+0].age   = 11.0 
        cvd_struc[index+0].metal = 0.02
        cvd_struc[index+0].imf   = 'btl'
        cvd_struc[index+0].afe   = 0.2 
        cvd_struc[index+0].index = 'btl_t11_afe02'
        cvd_struc[index+0].file  = 'cvd12_btl_t11_afe02.ssp' 
        cvd_struc[index+0].wave  = wave_inter 
        cvd_struc[index+0].flux  = ( cvd_struc[24].flux * afe02_btl )
        openw, 10, 'cvd12_btl_t11_afe02.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+0].ssp_line = cvd_struc[index+0].file + '   ' + $ 
            string( ( cvd_struc[index+0].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.2000   ' + cvd_struc[index+0].index + '   0.256    0    0.000'
        ;; btlbrier afe+0.3
        cvd_struc[index+1].age   = 11.0 
        cvd_struc[index+1].metal = 0.02
        cvd_struc[index+1].imf   = 'btl'
        cvd_struc[index+1].afe   = 0.3 
        cvd_struc[index+1].index = 'btl_t11_afe03'
        cvd_struc[index+1].file  = 'cvd12_btl_t11_afe03.ssp' 
        cvd_struc[index+1].wave  = wave_inter 
        cvd_struc[index+1].flux  = ( cvd_struc[24].flux * afe03_btl )
        openw, 10, 'cvd12_btl_t11_afe03.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+1].ssp_line = cvd_struc[index+1].file + '   ' + $ 
            string( ( cvd_struc[index+1].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.3000   ' + cvd_struc[index+1].index + '   0.256    0    0.000'
        ;; btlbrier afe+0.4
        cvd_struc[index+2].age   = 11.0 
        cvd_struc[index+2].metal = 0.02
        cvd_struc[index+2].imf   = 'btl'
        cvd_struc[index+2].afe   = 0.4 
        cvd_struc[index+2].index = 'btl_t11_afe04'
        cvd_struc[index+2].file  = 'cvd12_btl_t11_afe04.ssp' 
        cvd_struc[index+2].wave  = wave_inter 
        cvd_struc[index+2].flux  = ( cvd_struc[24].flux * afe04_btl )
        openw, 10, 'cvd12_btl_t11_afe04.ssp', width=300 
        for i = 0, ( n_pixel - 1 ), 1 do begin 
            printf, 10, strcompress( string( wave_inter[i] ), /remove_all ) + $
                '   ' + strcompress( string( flux_inter[i] ), /remove_all ) 
        endfor 
        close, 10 
        cvd_struc[index+2].ssp_line = cvd_struc[index+2].file + '   ' + $ 
            string( ( cvd_struc[index+2].age * 1.0D9 ), format='(E12.4)' ) + $
            '    0.4000   ' + cvd_struc[index+2].index + '   0.256    0    0.000'
        index = index + 3


    ;; Convolve the spectra to 350 km/s 
    for k = 0, ( n_ssp - 1 ), 1 do begin 
        cvd_struc[k].flux_conv = hs_spec_convolve( $
            cvd_struc[k].wave, cvd_struc[k].flux, 58.0, sig_conv ) 
    endfor

    ;; Save file 
    sig_string = strcompress( string( long( sig_conv ) ), /remove_all )
    cvd_fits = 'cvd12_ssps_s' + sig_string + '.fits' 
    mwrfits, cvd_struc, cvd_fits, /create, /silent 

    ;; Save the base file
    base_file = 'cvd12_x35.base'
    index_base = where( cvd_struc.imf EQ 'x35' ) 
    n_base = n_elements( index_base ) 
    if ( n_base NE 24 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the X35 base file !'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        openw, 10, base_file, width=400 
        printf, 10, strcompress( string( n_base ), /remove_all ) + '    [N_base]'
        for j = 0, ( n_base - 1 ), 1 do begin 
            printf, 10, cvd_struc[ index_base[j] ].ssp_line 
        endfor 
    endelse
    close, 10

    base_file = 'cvd12_x30.base'
    index_base = where( cvd_struc.imf EQ 'x30' ) 
    n_base = n_elements( index_base ) 
    if ( n_base NE 24 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the X30 base file !'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        openw, 10, base_file, width=400 
        printf, 10, strcompress( string( n_base ), /remove_all ) + '    [N_base]'
        for j = 0, ( n_base - 1 ), 1 do begin 
            printf, 10, cvd_struc[ index_base[j] ].ssp_line 
        endfor 
    endelse
    close, 10

    base_file = 'cvd12_x23.base'
    index_base = where( cvd_struc.imf EQ 'x23' ) 
    n_base = n_elements( index_base ) 
    if ( n_base NE 24 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the X23 base file !'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        openw, 10, base_file, width=400 
        printf, 10, strcompress( string( n_base ), /remove_all ) + '    [N_base]'
        for j = 0, ( n_base - 1 ), 1 do begin 
            printf, 10, cvd_struc[ index_base[j] ].ssp_line 
        endfor 
    endelse
    close, 10

    base_file = 'cvd12_cha.base'
    index_base = where( cvd_struc.imf EQ 'cha' ) 
    n_base = n_elements( index_base ) 
    if ( n_base NE 24 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the CHA base file !'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        openw, 10, base_file, width=400 
        printf, 10, strcompress( string( n_base ), /remove_all ) + '    [N_base]'
        for j = 0, ( n_base - 1 ), 1 do begin 
            printf, 10, cvd_struc[ index_base[j] ].ssp_line 
        endfor 
    endelse
    close, 10

    base_file = 'cvd12_btl.base'
    index_base = where( cvd_struc.imf EQ 'btl' ) 
    n_base = n_elements( index_base ) 
    if ( n_base NE 24 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Something wrong with the BTL base file !'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin 
        openw, 10, base_file, width=400 
        printf, 10, strcompress( string( n_base ), /remove_all ) + '    [N_base]'
        for j = 0, ( n_base - 1 ), 1 do begin 
            printf, 10, cvd_struc[ index_base[j] ].ssp_line 
        endfor 
    endelse
    close, 10




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
position_1 = [ 0.12, 0.502, 0.995, 0.94 ]
position_2 = [ 0.12, 0.06, 0.995, 0.498 ]
xrange1 = [ 3500, 5450 ]
xrange2 = [ 5450, 7400 ]

plot_file = 'cvd_age3_x35.eps'
mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 42 
set_plot, 'ps' 
device, filename=plot_file, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    index_use = where( ( cvd_struc.age EQ 3.0 ) AND ( cvd_struc.imf EQ 'x35' ) )
    n_use = n_elements( index_use )
    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=xrange1, $
        xticklen=0.03, yticklen=0.02
    cgAxis, xaxis=1.0, xrange=xrange1, xstyle=1, charsize=4.5, xthick=12.0, $
        xticklen=0.05
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, $
        /nodata, xrange=xrange2, $
        xticklen=0.03, yticklen=0.02
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

device, /close 
set_plot, mydevice 


plot_file = 'cvd_age5_x30.eps'
mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 42 
set_plot, 'ps' 
device, filename=plot_file, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    index_use = where( ( cvd_struc.age EQ 5.0 ) AND ( cvd_struc.imf EQ 'x30' ) )
    n_use = n_elements( index_use )
    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=xrange1, $
        xticklen=0.03, yticklen=0.02
    cgAxis, xaxis=1.0, xrange=xrange1, xstyle=1, charsize=4.5, xthick=12.0, $
        xticklen=0.05
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, $
        /nodata, xrange=xrange2, $
        xticklen=0.03, yticklen=0.02
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

device, /close 
set_plot, mydevice 



plot_file = 'cvd_age7_x23.eps'
mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 42 
set_plot, 'ps' 
device, filename=plot_file, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    index_use = where( ( cvd_struc.age EQ 7.0 ) AND ( cvd_struc.imf EQ 'x23' ) )
    n_use = n_elements( index_use )
    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=xrange1, $
        xticklen=0.03, yticklen=0.02
    cgAxis, xaxis=1.0, xrange=xrange1, xstyle=1, charsize=4.5, xthick=12.0, $
        xticklen=0.05
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, $
        /nodata, xrange=xrange2, $
        xticklen=0.03, yticklen=0.02
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

device, /close 
set_plot, mydevice 


plot_file = 'cvd_age9_cha.eps'
mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 42 
set_plot, 'ps' 
device, filename=plot_file, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    index_use = where( ( cvd_struc.age EQ 9.0 ) AND ( cvd_struc.imf EQ 'cha' ) )
    n_use = n_elements( index_use )
    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=xrange1, $
        xticklen=0.03, yticklen=0.02
    cgAxis, xaxis=1.0, xrange=xrange1, xstyle=1, charsize=4.5, xthick=12.0, $
        xticklen=0.05
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, $
        /nodata, xrange=xrange2, $
        xticklen=0.03, yticklen=0.02
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

device, /close 
set_plot, mydevice 



plot_file = 'cvd_age11_btl.eps'
mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 42 
set_plot, 'ps' 
device, filename=plot_file, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    index_use = where( ( cvd_struc.age EQ 11.0 ) AND ( cvd_struc.imf EQ 'btl' ) )
    n_use = n_elements( index_use )
    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, $
        xtickformat="(A1)", /nodata, xrange=xrange1, $
        xticklen=0.03, yticklen=0.02
    cgAxis, xaxis=1.0, xrange=xrange1, xstyle=1, charsize=4.5, xthick=12.0, $
        xticklen=0.05
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

    cgPlot, cvd_struc[index_use[0]].wave, cvd_struc[index_use[0]].flux, $
        xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.0, charsize=4.5, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, $
        /nodata, xrange=xrange2, $
        xticklen=0.03, yticklen=0.02
    for i = 0, ( n_use - 1 ), 1 do begin 
        if ( cvd_struc[index_use[i]].afe EQ 0.0 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.5, color=cgColor('Black') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.2 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Red') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.3 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Blue') 
        endif 
        if ( cvd_struc[index_use[i]].afe EQ 0.4 ) then begin 
            cgPlot, cvd_struc[index_use[i]].wave, cvd_struc[index_use[i]].flux, $
                /overplot, linestyle=0, thick=3.0, color=cgColor('Brown') 
        endif 
    endfor 

device, /close 
set_plot, mydevice 


;;; Plot sections
position_1 = [ 0.120, 0.690, 0.995, 0.990 ]
position_2 = [ 0.120, 0.360, 0.995, 0.660 ]
position_3 = [ 0.120, 0.030, 0.995, 0.330 ]
xrange1 = [ 3500, 4800 ]
xrange2 = [ 4800, 6100 ]
xrange3 = [ 6100, 7400 ]

for i = 0, 119, 1 do begin 

plot_file = cvd_struc[i].index + '.eps'
mydevice = !d.name 
!p.font=1
psxsize = 48 
psysize = 44 
set_plot, 'ps' 
device, filename=plot_file, font_size=9.0, /encapsulated, $
    /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize

    cgPlot, cvd_struc[i].wave, cvd_struc[i].flux, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.5, charsize=2.0, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_1, xrange=xrange1, $
        xticklen=0.03, yticklen=0.02

    cgPlot, cvd_struc[i].wave, cvd_struc[i].flux, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.5, charsize=2.0, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_2, xrange=xrange2, $
        xticklen=0.03, yticklen=0.02

    cgPlot, cvd_struc[i].wave, cvd_struc[i].flux, xstyle=1, ystyle=1, $
        linestyle=0, color=cgColor( 'Black' ), thick=3.5, charsize=2.0, $
        ytitle='Flux (Normalized)', charthick=9.0, xthick=12.0, ythick=12.0, $
        /noerase, position=position_3, xrange=xrange3, $
        xticklen=0.03, yticklen=0.02

device, /close 
set_plot, mydevice 

endfor

end 

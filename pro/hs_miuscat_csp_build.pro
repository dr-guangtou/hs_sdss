function hs_miuscat_csp_build, miuscat_file, imf=imf, metal=metal, $
    ts=ts, np=np, tau=tau, tr=tr, t_cosmos=t_cosmos, n_time=n_time, $
    debug=debug, save_fits=save_fits, log_age=log_age

    t0 = systime(1) 
    ;; Check the miuscat_file 
    if NOT file_test( miuscat_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the miuscat SSP file: ' + miuscat_file 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif else begin 
        ;; Read in the miuscat SSPs file
        miuscat_ssps = mrdfits( miuscat_file, 1, status=status, /silent )
        if ( status NE 0 ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Something wrong with the miuscat SSP file '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin 
            ;; Check the tags of the MIUSCAT SSPs file 
            if ( ( tag_indx( miuscat_ssps, 'wave' )      EQ -1 ) OR $
                ( tag_indx( miuscat_ssps, 'imf_string' ) EQ -1 ) OR $ 
                ( tag_indx( miuscat_ssps, 'metal' )      EQ -1 ) OR $
                ( tag_indx( miuscat_ssps, 'resolution' ) EQ -1 ) OR $
                ( tag_indx( miuscat_ssps, 'unit' )       EQ -1 ) OR $ 
                ( tag_indx( miuscat_ssps, 'age' )        EQ -1 ) OR $
                ( tag_indx( miuscat_ssps, 'flux' )       EQ -1 ) OR $ 
                ( tag_indx( miuscat_ssps, 'mass_s' )     EQ -1 ) ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The MIUSCAT SSPs structure has incompatible tags ! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif else begin 
                ;; Define the wavelength array for the SSP 
                wave_arr = miuscat_ssps[0].wave
                ;; Number of pixels in the wavelength array
                n_pix = n_elements( wave_arr ) 
            endelse
        endelse
    endelse
    if keyword_set( debug ) then begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' Read in SSPs: ', ( systime(1) - t0 ), ' seconds'
    endif

    ;; Define the string array for uniq IMF types 
    imf_types = miuscat_ssps.imf_string 
    imf_uniq  = imf_types[ uniq( imf_types, sort( imf_types ) ) ]
    n_imf_uniq = n_elements( imf_uniq ) 

    ;; Define the float array for unique metallicity 
    met_value = [ -2.32, -1.71, -1.31, -0.71, -0.40, 0.00, 0.22 ]
    ;; Also the string labels for metallicity for the output file
    met_uniq = [ 'z1', 'z2', 'z3', 'z4', 'z5', 'z6', 'z7' ]
    n_met_uniq = 7
    
    ;;  Costant: Hubble time
    if NOT keyword_set( t_cosmos ) then begin 
        t_cosmos = 14.2    ;; Gyr 
    endif else begin 
        t_cosmos = float( t_cosmos ) 
    endelse
    ;;  Costant: N_Time : number of time frames for SFH 
    if NOT keyword_set( n_time ) then begin 
        n_time = 50    
    endif else begin 
        n_time = fix( n_time ) 
    endelse

    ;; Start checking the input parameters 
    ;; 1. IMF type
    if ( n_elements( imf ) EQ 0 ) then begin 
        ;; If no input for IMF, use un1.30 as default 
        imf   = 'un1.30'
        n_imf = 1 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' You did not select any IMF type, default un1.30 is used ! '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        ;; Number of selected imf type 
        n_imf = n_elements( imf ) 
        imf = imf[ uniq( imf, sort( imf ) ) ]
        for i = 0, ( n_imf - 1 ), 1 do begin 
            imf[i] = strcompress( string( imf[i] ), /remove_all ) 
            if ( where( imf_uniq EQ imf[i] ) EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The IMF type format is wrong, please select from: '
                print, imf_uniq 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif 
        endfor
    endelse

    ;; 2. Metallicity value
    if ( n_elements( metal ) EQ 0 ) then begin 
        ;; If no input for met, use un1.30 as default 
        met   = 0.00     ;; Solar metallicity
        metal = [ 'z6' ]
        n_met = 1 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' You did not select any metallicity, Solar value is used ! '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        ;; Number of selected metallicity  
        n_met = n_elements( metal ) 
        metal = metal[ uniq( metal, sort( metal ) ) ]
        for i = 0, ( n_met - 1 ), 1 do begin 
            if ( where( met_uniq EQ metal[i] ) EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' The metallicity value is wrong, please select from: '
                print,  met_uniq 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif 
        endfor
        met = met_value( where( met_uniq EQ metal ) )
    endelse

    ;; 3. SFH parameters 
    ;; 3a. T_start in Gyr : the starting age, in look-back time 
    if NOT keyword_set( ts ) then begin 
        ts = ( t_cosmos - 0.1 ) 
        n_ts = 1 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' You did not select any T_start! The default value is used ! '
        print, '    T_start = ' + string( ts, format='(F5.2)' ) + ' (Gyrs)'
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        ;; Number of input T_start values, this defines the number of SFH for 
        ;;   the CSP generation
        n_ts = n_elements( ts ) 
        if ( ( where( ( ts LE 0.1 ) OR ( ts GE t_cosmos ) ) )[0] NE -1 ) $ 
            then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The starting look-back time should be within: '
            print, '    0.1 Gyr < T_start < ' + $
                string( t_cosmos, format='(F5.2)' )
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif 
    endelse
    ;; 3b. N_power : the power law index for the power-law increasing of SFR 
    ;;               in the begining phase.  The lower of N_power, the faster 
    ;;               the SFR starts to decline. 
    if NOT keyword_set( np ) then begin 
        np = 0.5 
        n_np = 1 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' You did not select any N_Power! The default value is used ! '
        print, '    N_Power = 0.5 '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        n_np = n_elements( np ) 
        ;; Check the number of elements in the np array 
        if ( ( n_np NE 1 ) AND ( n_np NE n_ts ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The number of elements in the np array should be either 1 '
            print, '    or equal to the number of elements in ts array ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif 
    endelse
    ;; If the n_np=1 and n_ts> 1, then simply expand the np array assuming that 
    ;;     all the ts value corresponds to the same np value 
    if ( ( n_np EQ 1 ) AND ( n_ts GT 1 ) ) then begin 
        n_np = n_ts 
        np = replicate( np, n_ts ) 
    endif 
    ;; 3c. Tau : The e-folding time scale for the exponential declining phase 
    if NOT keyword_set( tau ) then begin 
        tau = 1.0 
        n_tau = 1 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' You did not select any Tau! The default value is used ! '
        print, '    Tau = 1.0 '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        n_tau = n_elements( tau ) 
        ;; Check the number of elements in the tau array 
        if ( ( n_tau NE 1 ) AND ( n_tau NE n_ts ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The number of elements in the tau array should be either 1 '
            print, '    or equal to the number of elements in ts array ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif 
    endelse
    ;; If the n_tau=1 and n_ts>1, then simply expand the tau array assuming that 
    ;;     all the ts value corresponds to the same tau value 
    if ( ( n_tau EQ 1 ) AND ( n_ts GT 1 ) ) then begin 
        n_tau = n_ts 
        tau = replicate( tau, n_ts ) 
    endif 
    ;; 3d. T_Truncation : The look-back time for the truncation of SFR 
    if NOT keyword_set( tr ) then begin 
        n_tr = 0 
        tr   = -1.0
        do_truncation = 0L
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' You did not select any T_truncation! '
        print, '    So, no truncation of SFR will be applied! '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        n_tr = n_elements( tr ) 
        do_truncation = 1L
        ;; Check the number of elements in the tr array 
        if ( ( n_tr NE 1 ) AND ( n_tr NE n_ts ) ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' The number of elements in the tr array should be either 1 '
            print, '    or equal to the number of elements in ts array ' 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif 
    endelse
    ;; If the n_tr=1 and n_ts>1, then simply expand the tr array assuming that 
    ;;     all the ts value corresponds to the same tr value 
    if ( ( n_tr EQ 1 ) AND ( n_ts GT 1 ) ) then begin 
        n_tr = n_ts 
        tr = replicate( tr, n_ts ) 
        do_truncation = 1L
    endif 
    if keyword_set( debug ) then begin 
        print, ' Prepare the parameters: ', ( systime(1) - t0 ), ' seconds'
    endif

    ;; Number of total CSPs that will be generated  
    n_csp = ( n_imf * n_met * n_ts ) 
    ;; Number of total Spectra that will be generated 
    n_tot_spec = ( n_csp * n_time ) 
    if keyword_set( debug ) then begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' There will be ' + string( n_csp, '(I9)' ) + $
            ' CSP in the output'
        print, ' There will be ' + string( n_tot_spec, '(I9)' ) + $
            ' spectra in the output'
    endif

    ;; Define the output CSPs structure 
    csp_output = { imf:'', met:0.0, ts:0.0, np:0.0, tau:0.0, tr:0.0, $ 
        n_time:0, t_cosmos:0.0, resolution:0.0, unit:'', n_pix:0, $
        wave:fltarr( n_pix ), flux:fltarr( n_pix, n_time ), $ 
        time:fltarr( n_time ), time_lb:fltarr( n_time ), $
        sfr:fltarr( n_time ), mstar:fltarr( n_time ), $
        age_mw:fltarr( n_time ), age_lw:fltarr( n_time ), $
        filename:'' }
    csp_output = replicate( csp_output, n_csp ) 

    if keyword_set( debug ) then begin 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' The resolution of the spectra is: ' + $ 
            string( miuscat_ssps[0].resolution ) + ' ' + miuscat_ssps[0].unit
    endif

    ;; Start the iteration to generate the CSPs 
    mm = 0  ;; Outside index for the entire iterations

    ;; 1. IMF level 
    for ii = 0, ( n_imf - 1 ), 1 do begin 
        imf_now = imf[ ii ]
        temp = strsplit( imf_now, '.', /extract ) 
        imf_str = temp[0] + strmid( temp[1], 0, 1 )
        ;; 2. Metallicity level 
        for jj = 0, ( n_met - 1 ), 1 do begin 
            met_now = met[ jj ]
            met_str = met_uniq[ where( met_uniq EQ metal[ jj ] ) ]
            ;; 3. SFH level
            for kk = 0, ( n_ts - 1 ), 1 do begin 
                ;; New time stamp
                t1 = systime(1)
                
                ;; Find the matched SSPs
                index_use = where( ( miuscat_ssps.imf_string EQ imf_now ) AND $
                    ( miuscat_ssps.metal EQ met_now ) ) 
                if ( index_use[0] EQ -1 ) then begin 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    print, ' Did not find any matched SSP !! Check! '
                    print, ' IMF : ' + imf_now 
                    print, ' MET : ' + string( met_now ) 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    return, -1 
                endif 
                ;; Number of used SSPs 
                n_use = n_elements( index_use )
                ;; Extract the useful SSPs 
                miuscat_use = miuscat_ssps[ index_use ]
                ;; Sort the useful SSPs according to the age [Just in case]
                miuscat_use = miuscat_use[ sort( miuscat_use.age ) ]

                ;; Put some basic information in the result
                csp_output[mm].n_time     = n_time 
                csp_output[mm].t_cosmos   = t_cosmos
                csp_output[mm].resolution = miuscat_ssps[0].resolution
                csp_output[mm].unit       = miuscat_ssps[0].unit
                csp_output[mm].wave       = wave_arr
                csp_output[mm].n_pix      = n_pix
                ;; The IMF and Metallicity for this CSP  
                csp_output[mm].imf = imf_now 
                csp_output[mm].met = met_now 
                ;; The SFH parameters for this CSP 
                csp_output[mm].ts  = ts[kk]
                csp_output[mm].np  = np[kk]
                csp_output[mm].tau = tau[kk]
                if ( do_truncation EQ 1 ) then begin 
                    csp_output[mm].tr = tr[kk]
                endif else begin 
                    csp_output[mm].tr = 0.0
                endelse

                ;; Basic information about this iteration
                if keyword_set( debug ) then begin 
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    print, ' CSP : ' + string( mm + 1 ) 
                    print, ' IMF :      ' + imf_now 
                    print, ' MET : ' + string( met_now ) 
                    print, ' T_S : ' + string( ts[kk] )
                    print, ' N_P : ' + string( np[kk] )
                    print, ' TAU : ' + string( tau[kk] )
                    print, ' T_R : ' + string( csp_output[mm].tr )
                    print, ' N_USED :' + string( n_use )
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                endif 

                ;; Generate the SFH structure for input 
                if ( do_truncation EQ 0 ) then begin 
                    if keyword_set( log_age ) then begin 
                        sfh_struc = hs_sfh_generate_exppower( ts[kk], np[kk], $
                            tau[kk], n_time=n_time, t_cosmos=t_cosmos, /plot, $
                            /log_age ) 
                    endif else begin 
                        sfh_struc = hs_sfh_generate_exppower( ts[kk], np[kk], $
                            tau[kk], n_time=n_time, t_cosmos=t_cosmos, /plot ) 
                    endelse
                endif else begin 
                    if keyword_set( log_age ) then begin 
                        sfh_struc = hs_sfh_generate_exppower( ts[kk], np[kk], $
                            tau[kk], t_trunc=tr[kk], n_time=n_time, $
                            t_cosmos=t_cosmos, /plot, /log_age ) 
                    endif else begin 
                        sfh_struc = hs_sfh_generate_exppower( ts[kk], np[kk], $
                            tau[kk], t_trunc=tr[kk], n_time=n_time, $
                            t_cosmos=t_cosmos, /plot ) 
                    endelse
                endelse
                ;; Put the SFH into output structure 
                csp_output[mm].time     = sfh_struc.time  
                csp_output[mm].sfr      = sfh_struc.sfr  
                csp_output[mm].time_lb  = ( t_cosmos - sfh_struc.time ) 

                ;; Generate the SSP structure for input 
                ssp_struc = { age:fltarr( n_use ), mstar:fltarr( n_use ), $
                    wave:fltarr( n_pix ), flux:fltarr( n_pix, n_use ) }
                ssp_struc.wave  = wave_arr 
                ssp_struc.age   = miuscat_use.age 
                ssp_struc.mstar = miuscat_use.mass_s 
                for ll = 0, ( n_use - 1 ), 1 do begin 
                    ssp_struc.flux[*,ll] = miuscat_use[ll].flux 
                endfor

                ;; Time check 1 
                if keyword_set( debug ) then begin 
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    print, ' CSP Number :    ' + $
                        strcompress( string( mm + 1 ), /remove_all )
                    print, ' Time: ', ( systime(1) - t1 ), ' seconds'
                    print, '  Before the actual CSP generation '
                    t2 = systime(1)
                endif
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Get the CSP ! 
                csp_temp = hs_convolve_sfh( ssp_struc, sfh_struc ) 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Time check 2 
                if keyword_set( debug ) then begin 
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    print, ' Time: ', ( systime(1) - t2 ), ' seconds'
                endif
                ;; Put the results in the output structure 
                csp_output[mm].mstar  = csp_temp[0].mass
                csp_output[mm].age_mw = csp_temp[0].age_mw 
                csp_output[mm].age_lw = csp_temp[0].age_lw 
                csp_output[mm].flux   = csp_temp[0].flux

                ;; Save the CSP to a fits file 
                ;; String for each component 
                ts_str  = 's' + strcompress( string( ts[kk], $
                    format='(F4.1)' ), /remove_all )
                np_str  = 'n' + strcompress( string( np[kk], $
                    format='(F4.1)' ), /remove_all )
                tau_str = 't' + strcompress( string( tau[kk], $
                    format='(F4.1)' ), /remove_all )
                ntime_str = 'n' + strcompress( string( n_time, $
                    format='(I6)' ), /remove_all ) 
                if ( do_truncation EQ 1 ) then begin 
                    tr_str = 'r' + strcompress( string( tr[kk], $
                        format='(F4.1)' ), /remove_all )
                endif else begin 
                    tr_str = 'r0.0'
                endelse
                ;; Name of the output fits file 
                csp_fits = 'mius_' + imf_str + met_str + '_' + $
                    ts_str + np_str + tau_str + tr_str + '_' + $
                    ntime_str + '.fits'
                if keyword_set( debug ) then begin 
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                    print, ' About to save this CSP into: '
                    print, '    ' + csp_fits 
                    print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                endif 
                csp_output[mm].filename = csp_fits 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; Save the result
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                if keyword_set( save_fits ) then begin 
                    mwrfits, csp_output[mm], csp_fits, /create, /silent
                endif 
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ;; Modified the outside iteration index 
                mm = ( mm + 1 )

                free_all 

            endfor
        endfor
    endfor

    return, csp_output

end

; + 
; NAME:
;              HS_PPXF_SPEC_FIT
;
; PURPOSE:
;              Fit a spectrum using a libary of stellar population models 
;
; USAGE:
;    hs_ppxf_spec_fit, spec_file 
;
; OUTPUT: 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/21 - First  version 
;
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_setup_ssp_library, base_file, velscale, fwhm_data, fwhm_libr, $ 
    stellar_templates, wave_range_temp, wave_log_temp, base_struc, $ 
    lib_location=lib_location, n_models=n_models, quiet=quiet, $
    min_temp=min_temp, max_temp=max_temp 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    on_error, 2
    compile_opt idl2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Get the location for the stellar population bases  
    ;; Use the stellar population base file from STARLIGHT, so only TXT model 
    ;; spectra are allowed at this point
    if keyword_set( lib_location ) then begin 
        lib_location = strcompress( lib_location, /remove_all ) 
    endif else begin 
        hvdisp_location, hvdisp_home, data_home
        lib_location = data_home + 'lib/base/'
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Resolution of the data
    fwhm_data = float( fwhm_data )
    ;; Resolution of the model 
    fwhm_libr = float( fwhm_libr )
    ;; Convolve the model spectra into the same resolution with the data 
    if ( fwhm_data GT fwhm_libr ) then begin 
        fwhm_dif = SQRT( fwhm_data^2.0 - fwhm_libr^2.0 )
    endif else begin 
        fwhm_dif = -1.0 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    base_file = strcompress( base_file, /remove_all ) 
    if NOT file_test( base_file ) then begin 
        message, 'Can not find the templates list : ' + base_file 
    endif else begin 
        ;; Read the information of the base file into a structure
        base_struc = hs_starlight_read_base, base_file, $
            lib_location=lib_location
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Name of the spectral models
    spec_models = base_struc.file
    ;; Number of stellar population models 
    n_models    = n_elements( spec_models ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the first one for wavelength range 
    readcol, spec_models[0], wave_temp, flux_temp, format='F,D', $
        delimiter=' ', comment='#', /silent
    ;; Since its model spectrum for STARLIGHT, the wavelength sampling should be 
    ;; uniform 
    spec_samp = ( wave_temp[1] - wave_temp[0] )
    ;; The wavelength range of the model spectrum 
    wave_range_temp = [ wave_temp[0], wave_temp[ n_elements( wave_temp ) - 1 ] ]
    ;; Log-rebin the SSP spectrum 
    log_rebin, wave_range_temp, flux_temp, flux_log_temp, wave_log_temp, $
        velscale=velscale 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Trim the model spectrum if necessary
    if keyword_set( min_temp ) then begin 
        min_temp = float( min_temp ) 
    endif else begin 
        min_temp = wave_range_temp[0]
    endelse
    if keyword_set( max_temp ) then begin 
        max_temp = float( max_temp ) 
    endif else begin 
        max_temp = wave_range_temp[1]
    endelse
    ;; Linear sampling of the wavelength array
    wave_lin_temp = exp( wave_log_temp ) 
    index_use = where( wave_lin_temp GT min_temp AND wave_lin_temp LT max_temp )
    if ( index_use[0] EQ -1 ) then begin 
        message, 'Something wrong with the wavelength range for templates !!'
    endif 
    ;; Number of useful pixels
    n_pix_use = n_elements( index_use )  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Create a two dimensional array for stellar templates 
    ;; TODO: Allow 3-d array to use the REGUL feature of pPXF
    stellar_templates = dblarr( n_pix_use, n_models ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Convolve the models
    if ( fwhm_dif LT 0.0 ) then begin 
        do_convolve = 0 
    endif else begin 
        do_convolve = 1 
        sigma = ( fwhm_dif / 2.355 / spec_samp )
        lsf =psf_gaussian( npixel=( 2 * ceil( 4 * sigma ) + 1 ), st_dev=sigma, $
            /norm, ndim=1 )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    for kk = 0, ( n_models - 1 ), 1 do begin
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ~keyword_set( quiet ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, '  Read in : ' + spec_models[ kk] + '  !! '
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Read in the model spectrum
        readcol, spec_models[ kk ], wave_model, flux_model, format='F,D', $
            delimiter=' ', comment='#', /silent
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Convolve the model spectrum if necessary 
        if ( do_convolve EQ 1 ) then begin 
            flux_model = convol( flux_model, lsf ) 
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Log-rebin the model spectrum 
        log_rebin, wave_range_temp, flux_model, flux_new, wave_new, $
            velscale=velscale
        flux_new = flux_new[ index_use ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Put the model spectrum in the template array
        stellar_templates[ *, kk ] = flux_new
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ~keyword_set( quiet ) then begin 
            cgPlot, exp( wave_new ), flux_new, xs=1, ys=1, thick=2.0, $
                color=cgColor( 'Red' ), xtitle='Wavelength', ytitle='Flux'
        endif
    endfor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Update the parameters 
    wave_range_temp = [ min( wave_lin_temp[ index_use ] ), $ 
        max( wave_lin_temp[ index_use ] ) ]
    wave_log_temp   = wave_log_temp[ index_use ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_setup_emiline, wave, fwhm_data, emiline_templates, $
    line_name, line_wave, n_emi=n_emi

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    n_pix = n_elements( wave ) 
    ;; Assumes instrumental sigma is constant in Angstrom
    sigma_data = ( fwhm_data / 2.355 )
    ;; Possible emission lines
    lines = [ 3726.03, $ ; [OII]  3727 
              3728.82, $ ; [OII]  3729 
              4101.76, $ ; Hdelta 4101 
              4340.47, $ ; Hgamma 4340 
              4861.33, $ ; Hbeta  4861 
              4958.92, $ ; [OIII] 4959 
              5006.84, $ ; [OIII] 5007 
              5199.00, $ ; [NI]   5199 
              6300.30, $ ; [OI]   6300 
              6548.03, $ ; [NII]  6548 
              6583.41, $ ; [NII]  6583 
              6562.80, $ ; Halpha 6563 
              6716.47, $ ; [SII]  6717 
              6730.85  $ ; [SII]  6731 
              ]
    names = [ 'OII3727',  'OII3729',  'Hd4101',  'Hg4340',  'Hb4861', $ 
              'OIII4959', 'OIII5007', 'NI5199',  'OI6300',  'NII6548', $ 
              'NII6584',  'Ha6563',   'SII6717', 'SII6731' ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_use = where( ( lines GT min( wave ) ) AND ( lines LT max( wave ) ) )
    if ( index_use[0] EQ -1 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' No useful line is found !!!!! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        n_emi     = 0
        emi_lines = dblarr( n_pix )
    endif else begin 
        n_emi     = n_elements( index_use )
        emi_lines = dblarr( n_pix, n_emi ) 
        for ii = 0, ( n_emi - 1 ), 1 do begin 
            emi_lines[ *, ii ] = $
                EXP( -0.5D * ( ( wave - lines[ index_use[ii] ] ) / $
                sigma_data )^2.0 )
        endfor 
    endelse 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    line_name = names[ index_use ] 
    line_wave = lines[ index_use ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    emiline_templates = emi_lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_ppxf_spec_fit, spec_file, base_file, $
    fwhm_data=fwhm_data, fwhm_libr=fwhm_libr, $
    min_wave=min_wave,   max_wave=max_wave, $
    hvdisp_home=hvdisp_home, $ 
    vel_guess=vel_guess,     sig_guess=sig_guess, $
    sn_ratio=sn_ratio, mdegree=mdegree, n_moments=n_moments, $
    quiet=quiet, debug=debug, suffix=suffix, $
    save_temp=save_temp, result_file=result_file, $
    plot_result=plot_result, save_result=save_result, $
    include_emission=include_emission, mask_file=mask_file, $ 
    regul=regul, is_flag=is_flag, is_error=is_error

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    on_error, 2
    compile_opt idl2
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Useful constant 
    cs = 299792.458d ; speed of light, km/s
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; FWHM of the input spectrum 
    if keyword_set( fwhm_data ) then begin 
        fwhm_data = float( fwhm_data ) 
    endif else begin 
        fwhm_data = 2.76  ;; Assume it's SDSS spectrum
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; FWHM of the library 
    if keyword_set( fwhm_libr ) then begin 
        fwhm_libr = float( fwhm_libr ) 
    endif else begin 
        fwhm_libr = 2.51  ;; Assume it's MILES or MIUSCAT 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Degree for the Multiplicative Polynomials for the fit 
    if keyword_set( mdegree ) then begin 
        mdegree = long( mdegree ) 
    endif else begin 
        mdegree = 10 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Order of the Gauss-Hermite moments to fit 
    if keyword_set( n_moments ) then begin 
        n_moments = long( n_moments ) 
    endif else begin 
        n_moments = 2
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( hvdisp_home ) then begin 
        hvdisp_location, hvdisp_home, data_home
    endif else begin 
        hvdisp_home = strcompress( hvdisp_home, /remove_all ) 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    loc_coadd   = hvdisp_home + 'coadd/'
    loc_templis = hvdisp_home + 'pro/lis/'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check the spectrum file
    spec_file = strcompress( spec_file, /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( spec_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input spectrum file : ' + spec_file + ' !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Check the stellar population base file 
    base_file = strcompress( base_file, /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT file_test( base_file ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the input spectrum file : ' + base_file + ' !!!' 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; String for the name of the spectrum
    ;; SPEC_NAME ; SPEC_LOC ; NAME_STR
    temp = strsplit( spec_file, '/', /extract )  
    nseg = n_elements( temp ) 
    spec_name = temp[ nseg - 1 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( nseg EQ 1 ) then begin 
        spec_loc = ''
    endif else begin 
        spec_loc = '/'
        for nn = 0, ( nseg - 2 ), 1 do begin 
            spec_loc = spec_loc + temp[ nn ] + '/' 
        endfor 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp      = strsplit( spec_name, '.', /extract ) 
    name_str  = strcompress( temp[0], /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; String for the name of the base file 
    temp      = strsplit( base_file, '/', /extract )  
    nseg      = n_elements( temp ) 
    base_name = temp[ nseg - 1 ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp      = strsplit( base_name, '.', /extract ) 
    base_str  = strcompress( temp[0], /remove_all )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( suffix ) then begin 
        name_str = name_str + '_' + base_str + '_' + suffix 
    endif else begin 
        name_str = name_str + '_' + base_str 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( is_error ) then begin 
        if keyword_set( is_flag ) then begin 
            readcol, spec_file, wave_ori, flux_ori, error_ori, flag_ori, $
                format='F,D,D', delimiter=' ', comment='#', /silent 
        endif else begin 
            readcol, spec_file, wave_ori, flux_ori, error_ori, format='F,D,D', $
                delimiter=' ', comment='#', /silent 
        endelse
    endif else begin 
        readcol, spec_file, wave_ori, flux_ori, format='F,D', $
            delimiter=' ', comment='#', /silent 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Min/Max wavelength 
    if keyword_set( min_wave ) then begin 
        min_wave = float( min_wave ) 
    endif else begin 
        min_wave = min( wave_ori ) 
    endelse 
    if keyword_set( max_wave ) then begin 
        max_wave = float( max_wave ) 
    endif else begin 
        max_wave = max( wave_ori ) 
    endelse 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Trim the template 
    min_wave_temp = ( min_wave - 100.0 ) 
    max_wave_temp = ( max_wave + 100.0 ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Trim the spectrum 
    index_use = where( ( wave_ori GT min_wave ) AND ( wave_ori LT max_wave ) ) 
    if ( index_use[0] EQ -1 ) then begin 
        message, ' Something wrong with the wavelength range for data !!'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wave_trim = wave_ori[ index_use ]
    flux_trim = flux_ori[ index_use ]
    if keyword_set( is_error ) then begin 
        error_trim = error_ori[ index_use ]
    endif
    if keyword_set( is_flag ) then begin 
        flag_trim = flag_ori[ index_use ]
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wave_range_trim = [ min( wave_trim ), max( wave_trim ) ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Normalize the spectrum
    flux_norm       = median( flux_ori ) 
    flux_trim_norm  = ( flux_trim / flux_norm )
    error_trim_norm = ( error_trim / flux_norm )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Log-Rebin the spectrum
    log_rebin, wave_range_trim, flux_trim_norm, flux_trim_log, wave_trim_log, $
        velscale=velscale
    wave_trim_lin = exp( wave_trim_log ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Log-Rebin the error 
    if keyword_set( is_error ) then begin 
        log_rebin, wave_range_trim, ( error_trim_norm^2.0 ), error_temp_log, $
            wave_trim_log, velscale=velscale
        error_trim_log = SQRT( error_temp_log ) 
    endif 
    ;; Prepare the mask array 
    mask_arr = ( flux_trim_log * 0L ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Log-Rebin the flag 
    if keyword_set( is_flag ) then begin 
        log_rebin, wave_range_trim, flag_trim, flag_log, wave_trim_log, $
            velscale=velscale
        ;; TODO: Not sure if this is the best way
        index_flag = where( flag_log GT 0.8 )
        if ( index_flag[0] NE -1 ) then begin  
            mask_arr[ goodpixels ] = 1L
        endif 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Data for pPXF 
    galaxy     = flux_trim_log
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; New wavelength range 
    min_wave   = min( wave_trim_lin ) 
    max_wave   = max( wave_trim_lin ) 
    wave_range = [ min_wave, max_wave ]
    wave_lin   = wave_trim_lin
    n_pixel    = n_elements( wave_lin ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( is_error ) then begin 
        ;; Add a constant noise 
        if keyword_set( sn_ratio ) then begin 
            sn_ratio = float( sn_ratio ) 
        endif else begin 
            sn_ratio = 100.0 
        endelse
        ;; TODO: Empirical way, not sure if it is the best
        noise = ( SQRT( galaxy ) ) / sn_ratio
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, ' Fitting spectrum : ' + name_str 
        print, ' Wavelength range : ' + string( min_wave, format='(F7.1)' ) + $
            string( max_wave, format='(F7.1)' ) 
        print, ' Pixel numbers    : ' + string( n_pixel,  format='(I6)' ) 
        print, ' Signal / Noise   : ' + string( sn_ratio, format='(I6)' ) 
        print, ' Velscale         : ' + string( velscale, format='(F6.2)' )  + $
            '  km/s'
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Setup the stellar library 
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, '# SETUP THE STELLAR LIBRARY ...'
        print, '  Use the stellar population models from ' + base_file + ' !' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    base_file = loc_templis + strcompress( base_file, /remove_all ) 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    hs_setup_ssp_library, base_file, velscale, fwhm_data, fwhm_libr, $
        stellar_templates, wave_range_temp, wave_log_temp, base_struc, $
        n_models=n_models, min_temp=min_wave_temp, max_temp=max_wave_temp, $
        /quiet
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    wave_lin_temp = exp( wave_log_temp )
    n_pixel_temp  = n_elements( wave_lin_temp )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ~keyword_set( quiet ) then begin 
        print, n_models, ' SSPs have been adopted !'
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Normalize the template 
    stellar_templates = ( stellar_templates / median( stellar_templates ) )
    num_stellar       = n_models
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( regul ) then begin 
        ;; Please make sure the base file is appropriate !!! 
        age_arr  = base_struc.age 
        met_arr  = base_struc.met
        age_uniq = age_arr[ uniq( age_arr, sort( age_arr ) ) ] 
        met_uniq = met_arr[ uniq( met_arr, sort( met_arr ) ) ] 
        age_num  = n_elements( age_uniq ) 
        met_num  = n_elements( met_uniq ) 
        new_stellar_templates = dblarr( n_pixel_temp, age_num, met_num )
        if ( ( age_num * met_num ) NE n_models ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' To use the REGUL option, make sure that :   '
            print, '  N_models = N_Age X N_Metallicty            '
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' ' 
        endif 
        if NOT keyword_set( quiet ) then begin 
            print, '###############################################################'
            print, ' The REGUL option is on .... '
            print, ' There are ' + string( age_num ) + ' unique ages '
            print, ' There are ' + string( met_num ) + ' unique metallicity '
            print, '###############################################################'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Asign the templates into a three dimensional arrays, and make sure 
        ;; that the age and metallicity is in increasing order 
        for ll = 0, ( met_num - 1 ), 1 do begin 
            for nn = 0, ( age_num - 1 ), 1 do begin 
                ssp_use = where( ( base_struc.age EQ age_uniq[ nn ] ) AND $ 
                                 ( base_struc.met EQ met_uniq[ ll ] ) ) 
                if ( ( ssp_use[0] EQ -1 ) OR ( n_elements( ssp_use ) GT 1 ) ) $
                    then begin 
                    message, ' XXXX Something weird just happended !!! XXXX ' 
                endif else begin 
                    new_stellar_templates[ *, nn, ll ] = $
                        stellar_templates[ ssp_use ]
                endelse
            endfor  
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        stellar_templates = new_stellar_templates
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( include_emission ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Setup the emission line library 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ~keyword_set( quiet ) then begin 
            print, '###########################################################'
            print, '# SETUP THE EMISSION LINES TEMPLATES ...'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        hs_setup_emiline, wave_lin_temp, fwhm_data, emiline_templates, $
            line_name, line_wave, n_emi=num_emiline 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ~keyword_set( quiet ) then begin 
            print, num_emiline, ' emission lines have been adopted !'
            print, '###########################################################'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Combine the emission line and stellar templates 
        templates = [ [ stellar_templates ], [ emiline_templates ] ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif else begin 
        if ~keyword_set( quiet ) then begin 
            print, '###########################################################'
            print, '# No emission line is included ... ' 
            print, '###########################################################'
        endif 
        templates = [ stellar_templates ]
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( mask_file ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Mask some pixels out
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mask_file = strcompress( mask_file, /remove_all ) 
        if NOT file_test( mask_file ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the mask file : ' + mask_file + '!!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        endif else begin 
            mask_arr_extra = hs_starlight_read_mask( wave_lin, mask_file ) 
            mask_index     = where( mask_arr_extra EQ 0 ) 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            if ( mask_index[0] NE -1 ) then begin 
                mask_arr[ mask_index ] = 1L 
                n_bad = n_elements( mask_index ) 
            endif else begin 
                n_bad = 0 
            endelse
            if ~keyword_set( quiet ) then begin 
                print, '###########################################################'
                print, '# There are : ' + string( n_bad ) + ' pixels ' + $ 
                    'have been masked out !!'
                print, '###########################################################'
            endif 
        endelse
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Define the goodpixels
    goodpixels = where( mask_arr EQ 0 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Decide the VSYST for pPXF 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, ' #                      MIN_WAVE        MAX_WAVE      N_PIXEL  '
        print, ' For spectrum : ', wave_range[0],      wave_range[1], n_pixel 
        print, ' For template : ', wave_range_temp[0], wave_range_temp[1], $
            n_pixel_temp
        print, '###############################################################'
    endif 
    dv = ( alog( wave_range_temp[0] / wave_range[0] ) * cs )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Initial guess for kinematic parameters 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( vel_guess ) then begin 
        vel_guess = float( vel_guess ) 
    endif else begin 
        vel_guess = 80.0D  ; km/s
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if keyword_set( sig_guess ) then begin 
        sig_guess = float( sig_guess ) 
    endif else begin 
        sig_guess = 340.0D ; km/s
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    start = [ vel_guess, sig_guess ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Assign Component=0 for stellar templates 
    ;;    and Component=1 for emission line templates
    component = [ replicate( 0, num_stellar ) , replicate( 1, num_emiline ) ]
    moments   = [ n_moments , n_moments ] ;; Fit (Vel, Sig ) for both stars and gas 
    start     = [ [ start ] , [ start ] ]
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Run pPXF 
    if ~keyword_set( quiet ) then begin 
        print, '###############################################################'
        print, 'START THE ACTUAL FITTING PROCEDURE ... ' 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ppxf, templates, galaxy, noise, velscale, start, solutions, $
        goodpixels=goodpixels, moments=moments, degree=-1, mdegree=mdegree, $ 
        vsyst=dv,  weights=weights, temp_arr=temp_arr, $
        component=component, bestfit=bestfit, /quiet
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ~keyword_set( quiet ) then begin 
        print, ' Done !! '
        print, '###############################################################'
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show the results 
    n_goodpix  = n_elements( goodPixels )
    nzero_temp = n_elements( where( weights GT 0.0 ) )
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Velocity of the stellar component : ' + $
        string( solutions[ 0, 0 ], format='(F8.2)' ) + ' km/s ' 
    print, ' Veldisp of the stellar component  : ' + $
        string( solutions[ 1, 0 ], format='(F8.2)' ) + ' km/s ' 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Velocity of the emission lines component : ' + $
        string( solutions[ 0, 1 ], format='(F8.2)' ) + ' km/s ' 
    print, ' Veldisp of the emission lines component  : ' + $
        string( solutions[ 1, 1 ], format='(F8.2)' ) + ' km/s ' 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Chi^2/DOF          :  ', solutions[6]
    print, ' Desired Delta Chi^2:  ', sqrt( 2 * n_goodpix )    
    print, ' Current Delta Chi^2:', ( ( solutions[6] - 1 ) * n_goodpix )
    print, ' Nonzero Templates  : ', nzero_temp 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Recover the multiplicative polynomials 
    xx = cap_range( -1d, 1d, n_elements( galaxy ) ) 
    mpoly = 1d 
    for jj = 1, mdegree, 1 do begin 
        mpoly = mpoly + ( legendre( xx, jj ) * solutions[ ( 6 + jj ), 0 ] ) 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save the results 
    if keyword_set( save_result ) then begin 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( result_file ) then begin 
            result_file = spec_loc + 'ppxf/' + result_file 
        endif else begin 
            if keyword_set( ssp_txt ) then begin 
                result_file = spec_loc + 'ppxf/' + name_str + $
                    '_ppxf_emirem.fits' 
            endif else begin 
                result_file = spec_loc + 'ppxf/' + name_str + $
                    '_ppxf_emirem.fits' 
            endelse
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        print, '###############################################################'
        print, ' Save the result to : ' + result_file 
        ;; Output structure  
        spec_result = { wave:fltarr( n_pixel ), $
            data:dblarr( n_pixel ), $
            best:dblarr( n_pixel ), $
            rres:dblarr( n_pixel ), $
            mpoly:dblarr( n_pixel ),   $
            stellar:dblarr( n_pixel ), $
            emiline:dblarr( n_pixel ), $
            flux_norm:flux_norm, n_pixel:n_pixel, n_goodpix:n_goodpix, $
            sn_ratio:sn_ratio, min_wave:min_wave, max_wave:max_wave, $
            vel_ste:solutions[0,0], sig_ste:solutions[1,0], $ 
            vel_gas:solutions[0,1], sig_gas:solutions[1,1], $ 
            chi2:solutions[6,0], $
            component:component, weights:weights, $
            line_name:line_name, line_wave:line_wave }
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Get the relative and absolute residual 
        relres = ( ( ( galaxy - bestfit ) / galaxy ) * 100.0 )
        absres = ( galaxy - bestfit )
        ;; Get the final contribution for each template spectrum 
        best_temp = temp_arr # weights 
        ;; Get the best fit stellar and emission line component
        index_ste = where( component EQ 0 ) 
        index_gas = where( component EQ 1 ) 
        temp_ste = temp_arr[*,index_ste] 
        temp_gas = temp_arr[*,index_gas]
        weights_ste = weights[index_ste]
        weights_gas = weights[index_gas]
        best_ste = temp_ste # weights_ste
        best_gas = temp_gas # weights_gas
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Save the results to structures
        spec_result.wave    = wave_lin 
        spec_result.data    = galaxy 
        spec_result.best    = bestfit 
        spec_result.rres    = relres
        spec_result.mpoly   = mpoly 
        spec_result.stellar = best_ste 
        spec_result.emiline = best_gas 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; First extension is the structure for main result  
        mwrfits, spec_result, result_file, /create    ;; dimension 0  
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( save_temp ) then begin 
            ;; Second extension for whole solutions 
            mwrfits, solutions,   result_file, /silent    ;; extension 1
            ;; Third extension for the templates
            mwrfits, templates,   result_file, /silent    ;; extension 2
        endif 
        print, '###############################################################'
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        res_range = [ min( absres ), ( max( absres ) > max( best_gas ) ) ]

    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Plot  
    if keyword_set( debug ) then begin 

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if keyword_set( ssp_txt ) then begin 
            result_plot = spec_loc + 'ppxf/' + name_str + '_ppxf_debug.eps' 
        endif else begin 
            result_plot = spec_loc + 'ppxf/' + name_str + '_ppxf_debug.eps' 
        endelse
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        psxsize = 28 
        psysize = 22
        pos1 = [ 0.11, 0.30, 0.99, 0.98 ]
        pos2 = [ 0.11, 0.10, 0.99, 0.30 ]
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, filename=result_plot, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgPlot, wave_ori, ( flux_ori / flux_norm ), xs=1, ys=1, /noerase, $
            xrange=wave_range_temp, yrange=[0.12,1.19], thick=1.5, $
            color=cgColor( 'BLK2' ), position=pos1, $
            xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
            /nodata, ytitle='Norm. Flux', xticklen=0.04
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Stellar templates
        for xx = 0, ( num_stellar - 1 ), 1 do begin 
            temp = stellar_templates[*,xx]
            cgOPlot, wave_lin_temp, ( temp / max( temp ) ), $
                color=cgColor( 'BLK2' ), thick=0.6
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Emission line templates
        for yy = 0, ( num_emiline - 1 ), 1 do begin 
            cgPlots, [ line_wave[yy], line_wave[yy] ], [ 0.12, 0.22 ], $
                linestyle=0, thick=1.5, color=cgColor( 'RED5' )
            cgText, ( line_wave[yy] + 10.0 ), 0.24, $
                strcompress( line_name[yy], /remove_all ), $
                alignment=0, charsize=1.2, color=cgColor( 'RED5' ), $
                orientation=90.0
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Data 
        cgOplot, wave_lin, galaxy, color=cgColor( 'BLK7' ), thick=2.0
        ;; 
        cgOplot, wave_lin, bestfit, color=cgColor( 'BLU6' ), linestyle=0, $
            thick=1.5
        ;;
        cgOplot, wave_lin, best_ste,  color=cgColor( 'RED5' ), thick=1.5, $
            linestyle=0 
        ;;
        cgOplot, wave_lin, mpoly,   color=cgColor( 'GRN5' ), linestyle=2, $
            thick=1.5
        ;;
        cgPlot, wave_ori, ( flux_ori / flux_norm ), xs=1, ys=1, /noerase, $
            xrange=wave_range_temp, yrange=[0.12,1.19], thick=1.5, $
            color=cgColor( 'BLK2' ), position=pos1, $
            xtickformat='(A1)', xthick=8, ythick=8, charthick=4, charsize=3.0, $
            /nodata, ytitle='Norm. Flux', xticklen=0.04
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Residual
        cgPlot, wave_lin, absres, xs=1, ys=1, thick=1.5, /noerase, $
            xrange=wave_range_temp, yrange=res_range, $
            color=cgColor( 'BLK6' ), position=pos2, $
            xthick=8, ythick=8, charthick=4, charsize=3.0, /nodata, $
            xtitle='Wavelength', ytitle='Res', xticklen=0.075
        cgOPlot, !X.Crange, [ 0.0, 0.0], linestyle=2, color=cgColor( 'BLK4' )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        for yy = 0, ( num_emiline - 1 ), 1 do begin 
            cgPlots, [ line_wave[yy], line_wave[yy] ], $
                [ res_range[0], res_range[1] ], $
                linestyle=2, thick=1.5, color=cgColor( 'RED4' )
        endfor 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cgOplot, wave_lin, absres, thick=1.5, linestyle=0, $
            color=cgColor( 'BLK7' )
        cgOplot, wave_lin, best_gas,  color=cgColor( 'Blue' ), thick=1.8, $
            linestyle=0
        ;; Only for test
        ;cgOplot, wave_lin, best_diff, color=cgColor( 'Red' ),   thick=1.5, $
        ;    linestyle=0
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        device, /close 
        set_plot, mydevice 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





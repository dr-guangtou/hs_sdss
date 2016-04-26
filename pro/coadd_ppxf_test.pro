pro coadd_ppxf_test

    ;; Location of the hs_sdssspec package 
    hvdisp_home = '/Users/songhuang/Dropbox/work/hs_sdssspec/'
    ;; Data directory 
    data_dir = './'
    ;; Input spec txt file 
    spec_file = 'spec-4349-55803-0985_sl.txt'
    ; spec_file = 'coadd_median.txt'
    ;; Base file 
    base_file = 'mius_ku13.base'
    ;; Base directory 
    base_dir = 'mius_base/'

    ;; Wavelength range to fit  
    wMin = 3900.0
    wMax = 7300.0

    ;; Instrumental resolution of the data (FWHM / Angstrom)
    fwhm_data = 2.76 
    ;; Instrumental resolution of the base (FWHM / Angstrom) 
    fwhm_base = 2.51

    ;; Initial guess of velocity (km / s)
    vel_guess = 10.0 
    ;; Initial guess of the velocity dispersion (km / s)
    sig_guess = 350.0

    ;; Degree of *multiplicative* Legendre Polynomial used for continuum "correction" 
    mdegree = 6
    ;; !! Instead of this, ppxf also allows to include a REDDENING curve into the 
    ;; fitting; let me know if you want to explore this option, I can easily make 
    ;; it available in the code.

    ;; In case you want to fit h3/h4, set: 
    ;; moments=4

    ;; Right now, the full function for plot is not available.  
    ;; The /debug option will shows a simple diagnostic figure.

    ;; For now, the emission line templates are fixed.  
    ;; Please adjust the lines: 162:179 in hs_ppxf_spec_fit.pro  
    ;; In the future, I want to use a template file to include emission lines

    ;; Spec fit using ppXF
    hs_ppxf_spec_fit, spec_file, base_file, $
        fwhm_data=fwhm_data, fwhm_libr=fwhm_base, $
        min_wave=wMin, max_wave=wMax, $
        hvdisp_home=hvdisp_home, $
        data_home=data_dir, dir_ssplib=base_dir,$ 
        vel_guess=vel_guess, sig_guess=sig_guess, $
        mdegree=mdegree, $
        /debug, /save_result, /save_template, $
        /is_flag, /is_error

        ;/include_emission, $

    ;include_emission=include_emission, $
    ;mask_file=mask_file, $ 
    ;regul=regul, error_reg=error_reg, $
    ;is_flag=is_flag, is_error=is_error

end 

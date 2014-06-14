function hs_spec_convolve, wave, flux, sigma_in, sigma_out 

    if ( n_elements( wave ) NE n_elements( flux ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        print, ' The wave and flux array should have the same length !! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' 
        return, -1 
    endif 

    if ( sigma_in GE sigma_out ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' The input velocity dispersion is greater than the output one!'
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1
    endif else begin 
        ;; Get the difference in velocity dispersion
        sigma_diff = SQRT( sigma_out^2.0 - sigma_in^2.0 ) 
    endelse
        
    min_wave = min( wave ) 
    max_wave = max( wave ) 

    cs = 299792.458d  ;;light of speed (km/s) 
    ;; Wavelength separation for log10-rebin spectra 
    dlogwave = ( 1.0D-4 )
    ;; The velocity scale 
    velscale = ( dlogwave * cs * alog( 10.0D ) )
    smoothing = ( sigma_diff / velscale )  ;; in pixel

    ;; Define a new wavelength array
    logwave0 = alog10( min_wave ) 
    logwave1 = alog10( max_wave ) 
    n_pix    = ( ( logwave1 - logwave0 ) / dlogwave ) * 2.0
    logwave  = logwave0 + findgen( n_pix ) * dlogwave 
    wave_conv = ( 10.0^logwave )
    wave_conv = wave_conv[ where( wave_conv LE max_wave ) ] 

    ;; Interpolate the spectrum to the log10-rebinned wavelength grid
    index_new = findex( wave, wave_conv ) 
    flux_new  = interpolate( flux, index_new )

    ;; Do the convolution
    flux_conv = gconv( flux_new, smoothing )

    ;; Interpolate the spectrum back to linear sampling
    index_inter = findex( wave_conv, wave )
    flux_conv_inter = interpolate( flux_conv, index_inter )

    ;; 
    return, flux_conv_inter

end

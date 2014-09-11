function hs_disturb_spectrum, flux, error=error, sn=sn, n_repeat=n_repeat, $
    debug=debug  
    
    ;; Based on arm_addnoise
     
    ;; Number of pixels in flux 
    n_pix = n_elements( flux ) 

    if ( ( NOT keyword_set( error ) ) AND ( NOT keyword_set( sn ) ) ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Should at least provide an error array or an expected s/n '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1
    endif 

    ;; if error array is provided 
    if keyword_set( error ) then begin 
        ;; Number of pixels in the error aray 
        if ( n_elements( error ) NE n_pix ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, 'The number of elements should be the same for flux and error!'
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            return, -1 
        endif else begin  
            err_arr = ( flux / 3000.0D ) 
            snr_arr = ( flux / error )
        endelse
    endif else begin  
        ;; if s/n is provided 
        if keyword_set( sn ) then begin 
            ;; if only one value is provided, then apply a uniform s/n to the 
            ;; entire spectrum 
            if ( n_elements( sn ) EQ 1 ) then begin 
                snr_arr = ( flux * 0.0 ) + ( sn * 1.0 )
                err_arr = ( flux / 3000.0D )
            endif else begin 
                ;; if an array is provided, use the S/N array 
                if ( n_elements( sn ) EQ n_pix ) then begin 
                    snr_arr = sn 
                    err_arr = ( flux / 3000.0D ) 
                endif else begin 
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    print, 'The number of elements in the S/N array should be '
                    print, '  either one or equal to the N_pix '
                    print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                    return, -1 
                endelse
            endelse
        endif 
    endelse

    ;; Number of disturbed spectra need be generated 
    if keyword_set( n_repeat ) then begin 
        n_repeat = fix( n_repeat ) 
    endif else begin 
        n_repeat = 1 
    endelse 

    ;; Output structure
    output = { flux:fltarr( n_pix ), error:fltarr( n_pix ) } 
    output = replicate( output, n_repeat ) 
    ;; 
    snr_output = fltarr( n_repeat ) 

    ;; Start the iterations
    for i = 0, ( n_repeat - 1 ), 1 do begin 
        ;; disturb the spectra
        arm_addnoise, flux, err_arr, snr_arr, $
            signal_new=flux_new, $
            noise_new=error_new 
        ;snr_output[i] = der_snr( flux_new ) 
        snr_output[i] = median( flux_new / error_new ) 
        output[i].flux  = flux_new 
        output[i].error = error_new
    endfor
            
    ;; Debug
    if keyword_set( debug ) then begin 
        cgPlot, flux, xstyle=1, ystyle=1, xrange=[2000,2300], $
        ;cgPlot, output[0].error, xstyle=1, ystyle=1, xrange=[2000,2500], $
            linestyle=0, thick=1.5, color=cgColor( 'Dark Gray' ), $
            position=[0.08, 0.08, 0.99, 0.99], /nodata
        for i = 0, ( n_repeat - 1 ), 1 do begin 
            cgPlot, output[i].flux, /overplot, color=cgColor( 'Red4' ), $ 
                linestyle=0, thick=1.2
            print, snr_output[i]
        endfor
        cgPlot, flux, /overplot, $
            linestyle=0, thick=1.0, color=cgColor( 'Black' )
    endif 

    ;; Output
    return, output 

end

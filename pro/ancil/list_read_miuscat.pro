pro list_read_miuscat, list 

    ;; Read in the list 
    list = strcompress( list, /remove_all ) 
    if NOT file_test( list ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find the list file: ' + list 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' ' 
    endif else begin 
        n_ssp = file_lines( list ) 
        spec_lis = strarr( n_ssp ) 
        openr, 10, list 
        readf, 10, spec_lis 
        close, 10 
        ;; Test the existence of the SSP files 
        if ( fix( total( file_test( spec_lis ) ) ) NE n_ssp ) then begin 
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            print, ' Can not find the following SSP files: '
            print, spec_lis[ where( ( file_test( spec_lis ) EQ 0 ) ) ]
            print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            message, ' '
        endif else begin 
            ssp0 = hs_read_miuscat( spec_lis[0] )
            wave = ssp0.wave
            n_pix = ssp0.n_pixel
        endelse
    endelse 

    ;; Define the output structure 
    struc_miuscat = { name:'', wave:fltarr( n_pix ), flux:fltarr( n_pix ), $
        min_wave:0.0, max_wave:0.0, d_wave:0.0, n_pixel:0.0, sampling:'', $ 
        imf:'', slope:0.0, imf_string:'', age:0.0, metal:0.0, $
        resolution:0.0, unit:'', redshift:0.0, $
        mass_s:0.0, mass_rs:0.0 } 
    struc_miuscat = replicate( struc_miuscat, n_ssp )

    ;; Define the output file 
    temp = strsplit( list, '.', /extract )
    fits_miuscat = temp[0] + '.fits' 

    ;; Read in each SSP 
    for i = 0, ( n_ssp - 1 ), 1 do begin 

        ssp_file = strcompress( spec_lis[i], /remove_all )
        print, '~~~~~~~~~~~~' + string( i, format='(I5)' ) + '~~~~~~~~~~~~~~'

        struc_miuscat[i] = hs_read_miuscat( ssp_file ) 
        
    endfor

    ;; Output 
    mwrfits, struc_miuscat, fits_miuscat, /create 

end

pro wave_test 

    spawn, 'ls *.fits', stars 
    n_stars = n_elements( stars ) 

    for i = 0, ( n_stars - 1 ), 1 do begin 

        file = stars[i] 

        data = mrdfits( file, 1, hdr, /silent ) 

        objname = string( file, format='(10A)' ) 
        naxis1  = string( n_elements( data.wavelength ) )
        p1 = string( fxpar( hdr, 'TEFF' ) ) 
        p2 = string( fxpar( hdr, 'LOGG' ) ) 
        p3 = string( fxpar( hdr, 'FEH'  ) )
        ;cover   = fxpar( hdr, 'COVERAGE' ) 
        ;gaps    = fxpar( hdr, 'GAPS' ) 

        print, objname + ' ' + naxis1 + ' ' + p1 + ' ' + p2 + ' ' + p3 

    endfor 

end

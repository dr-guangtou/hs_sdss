pro hs_sfh_exppower_library 

    t_cosmos = 15.0 
    t_start  = 14.0 
    n_power  = [ 0.0, 0.4, 0.8, 1.0, 1.2, 1.6, 2.0, 2.5, 3.0, 4.0 ]
    tau      = [ 0.2, 0.4, 0.6, 0.8, 1.0, 1.2, 1.5, 2.0, 2.5 ] 

    n1 = n_elements( n_power ) 
    n2 = n_elements( tau ) 
    
    for ii = 0, ( n1 - 1 ), 1 do begin 

        p = n_power[ii] 

        for jj = 0, ( n2 - 1 ), 1 do begin 

            t = tau[jj] 

            sfh_struct = hs_sfh_generate_exppower( t_start, p, t, n_time=100, $
                t_cosmos=t_cosmos, /plot, peak_time=peak_time ) 

            print, string( p, format='(F5.1)' ) + '  ' + $
                   string( t, format='(F5.1)' ) + '  ' + $ 
                   string( peak_time, format='(F8.2)' ) 
               
           endfor 
       endfor 

end            

pro compAll_gc

    name = ['NGC5286_a_1', 'NGC6522_a_1', 'NGC6528_c_1']
    model = ['fA', 'fB', 'fC', 'fD', 'fE']
    
    for ii = 0, 2, 1 do begin 
        gc = name[ii] 
        outFile = gc + '_test.lis'
        spawn, 'ls ' + gc +'_f[ABCDE].fits > ' + outFile, listOut 
        nOut = n_elements(listOut)

        hs_starlight_comp_out, outFile, /feature_over, /summary, /topng, $
            min_window=3650, max_window=5970

    endfor

end

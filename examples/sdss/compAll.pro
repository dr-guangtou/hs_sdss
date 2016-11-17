pro compAll

    name = ['spec-0528-52022-0137', 'spec-2095-53474-0355', 'spec-2515-54180-0377', 'spec-2618-54506-0310']
    model = ['fA', 'fB', 'fC', 'fD', 'fE']
    
    for ii = 0, 3, 1 do begin 
        galaxy = name[ii] 
        outFile = galaxy + '_test.lis'
        spawn, 'ls output/' + galaxy +'_f[ABCDE].fits > ' + outFile, listOut 
        nOut = n_elements(listOut)

        hs_starlight_comp_out, outFile, /feature_over, /summary, /topng, $
            min_window=3800

    endfor

end

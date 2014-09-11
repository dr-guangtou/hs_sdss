pro test_plot_sl 

    locaction = '/home/hs/hvdisp/coadd/results/starlight/'
    name1 = locaction + 'z0_s1l_median_erem1_comb_mix1.out' 
    ;name2 = locaction + 'z0_s1l_median_erem2_comb_mix1.out' 
    ;name3 = locaction + 'z0_s1l_median_eremf_comb_mix1.out' 

    hs_starlight_plot_out, name1, /zoomin, /feature_over, $
        window1=[4040, 4200], $
        window2=[4220, 4500], $
        window3=[4650, 5080], $
        /relative_res

    ;hs_starlight_plot_out, name2, /zoomin, /feature_over, $
    ;    window1=[6210, 6390], $
    ;    window2=[6450, 6600], $
    ;    window3=[6650, 6800], $
    ;    /relative_res

    ;hs_starlight_plot_out, name3, /zoomin, /feature_over, $
    ;    window1=[4040, 4200], $
    ;    window2=[4650, 5080], $
    ;    window3=[6450, 6650], $
    ;    /relative_res

end 

pro test_plot_sl, input_list 

    if file_test( input_list ) then begin 
        readcol, input_list, out_list, format='A', delimiter=' ', comment='#', $
            /silent, count=n_out 
    endif else begin 
        message, 'Can not find the list file : ' + input_list + ' !!!' 
    endelse 

    for ii = 0, ( n_out - 1 ), 1 do begin 
    
    ;for ii = 0, 4, 1 do begin 

        out_loca = strcompress( out_list[ ii ], /remove_all ) 
        ;; 
        temp = strsplit( out_loca, '/', /extract ) 
        out_name = temp[ n_elements( temp ) - 1 ]
        ;; 
        if ( strpos( out_name, 'erem1' ) NE -1 ) then begin 
            hs_starlight_plot_out, out_loca, /zoomin, /feature_over, $
                window1=[4040, 4200], $
                window2=[4220, 4500], $
                window3=[4650, 5080], $
                /relative_res
        endif 
        ;; 
        if ( strpos( out_name, 'erem2' ) NE -1 ) then begin 
            hs_starlight_plot_out, out_loca, /zoomin, /feature_over, $
                window1=[6120, 6290], $
                window2=[6340, 6450], $
                window3=[6510, 6690], $
                /relative_res
        endif 
        ;; 
        if ( strpos( out_name, 'eremf' ) NE -1 ) then begin 
            hs_starlight_plot_out, out_loca, /zoomin, /feature_over, $
                window1=[4050, 4410], $
                window2=[4820, 5020], $
                window3=[6420, 6650], $
                /relative_res
        endif 
        ;; 
        if ( strpos( out_name, 'full1' ) NE -1 ) then begin 
            hs_starlight_plot_out, out_loca, /zoomin, /feature_over, $
                window1=[4710, 5020], $
                window2=[5402, 5800], $
                window3=[6020, 6450], $
                /relative_res
        endif 
        ;; 
        if ( strpos( out_name, 'full2' ) NE -1 ) then begin 
            hs_starlight_plot_out, out_loca, /zoomin, /feature_over, $
                window1=[4710, 5020], $
                window2=[5402, 5800], $
                window3=[6020, 6450], $
                /relative_res
        endif 

        ;; 
    endfor 

    ;locaction = '/home/hs/hvdisp/coadd/results/starlight/'
    ;name1 = locaction + 'z0_s1l_median_erem1_comb_mix1.out' 
    ;name2 = locaction + 'z0_s1l_median_erem2_comb_mix1.out' 
    ;name3 = locaction + 'z0_s1l_median_eremf_comb_mix1.out' 

    ;hs_starlight_plot_out, name1, /zoomin, /feature_over, $
    ;    window1=[4040, 4200], $
    ;    window2=[4220, 4500], $
    ;    window3=[4650, 5080], $
    ;    /relative_res

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

pro plotAll_gc, sig_over=sig_over 

    spawn, 'ls *.out', listOut 
    nOut = n_elements(listOut)

    for ii = 0, (nOut - 1), 1 do begin
        if keyword_set( sig_over ) then begin 
            hs_starlight_plot_out, listOut[ii], $
                base_vdisp=70.0, /feature_over, /zoomin, /sig_over, $
                index_list='hs_index_plot_air.lis', /topng, /exclude_mask_res, $
                window1=[4200, 4400], window2=[4750 ,4950], window3=[5120,5350], $
                /put_label
        endif else begin 
            hs_starlight_plot_out, listOut[ii], $
                base_vdisp=70.0, /feature_over, /zoomin, /relative_res, $
                index_list='hs_index_plot_air.lis', /topng, /exclude_mask_res, $
                window1=[4200, 4400], window2=[4750, 4950], window3=[5120,5350], $
                /put_label
        endelse
    endfor 

end

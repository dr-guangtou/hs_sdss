pro slPlot, suffix=suffix 

    if keyword_set( suffix ) then begin 
        suffix = strcompress(suffix, /remove_all)
    endif else begin 
        suffix = 'mius_ku13_fA'
    endelse

    hs_starlight_plot_out, 'output/spec-0528-52022-0137_' + suffix + '.out', $
        base_vdisp=70.0, /feature_over, /zoomin, /sig_over, $
        index_list='hs_index_plot_air.lis', /topng, /exclude_mask_res

    hs_starlight_plot_out, 'output/spec-2095-53474-0355_' + suffix + '.out', $
        base_vdisp=70.0, /feature_over, /zoomin, /sig_over, $
        index_list='hs_index_plot_air.lis', /topng, /exclude_mask_res

    hs_starlight_plot_out, 'output/spec-2515-54180-0377_' + suffix + '.out', $
        base_vdisp=70.0, /feature_over, /zoomin, /sig_over, $
        index_list='hs_index_plot_air.lis', /topng, /exclude_mask_res

    hs_starlight_plot_out, 'output/spec-2618-54506-0310_' + suffix + '.out', $
        base_vdisp=70.0, /feature_over, /zoomin, /sig_over, $
        index_list='hs_index_plot_air.lis', /topng, /exclude_mask_res

end

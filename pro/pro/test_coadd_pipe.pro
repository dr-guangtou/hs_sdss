pro test_coadd_pipe, input_list

    input_list = strcompress( input_list, /remove_all ) 
    if NOT file_test( input_list ) then begin 
        message, ' Can not find the input list : ' + input_list + ' !!!'
    endif

    ;; Test A 
    hs_coadd_sdss_pipe, input_list, /create, /post, /avg_boot, $
        n_boot=500, sig_cut=3.5, f_cushion=6.0, $
        test_str='fcushion5' ;;, /new_prep

end

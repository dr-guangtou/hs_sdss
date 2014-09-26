function hs_sfh_generate_exppower, t_start, n_power, tau, $
    t_trunc=t_trunc, $
    time_arr=time_arr, n_time=n_time, t_cosmos=t_cosmos, $
    log_age=log_age, plot=plot, eps_file=eps_file, $
    mass_total=mass_total, peak_time=peak_time

    ;; The SFH is described by exponential declining SFR plus an additional 
    ;;    powerlaw increase in the begining: 
    ;;  SFR(t) = ( ( t_start - t ) / t_start )^n_power * 
    ;;           exp( -1.0 * ( t_start - t ) / tau )  
    ;;  t_start and t here are in Gyr, and is the look-back time
   
    ;; Number of output time frames
    if keyword_set( n_time ) then begin 
        n_time = fix( n_time ) 
    endif else begin 
        n_time = 80
    endelse

    ;; Cosmic age 
    if keyword_set( t_cosmos ) then begin 
        t_cosmos = float( t_cosmos ) 
        if ( t_cosmos GT 18.0 ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, '  Are you serious about this ?? '
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif  
    endif else begin 
        t_cosmos = 13.6   ;; Gyr 
    endelse

    ;; Adjust t_start if its too large 
    if ( t_start GT t_cosmos ) then begin 
        t_start = ( t_cosmos - 0.1 ) 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' The start age has been adjusted to cosmic age !! '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif

    ;; n_power should not be negative 
    if ( n_power LT 0.0 ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Please make sure n_power >= 0.0 ! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        return, -1 
    endif 

    ;; Build the time_arr --> This is not the lookback time 
    if keyword_set( time_arr ) then begin 
        time_arr = time_arr 
        if ( max( time_arr GT t_cosmos ) ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' The input time array has been truncated ! '
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            index_useful = where( time_arr LE t_cosmos )  
            if ( index_useful[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something wrong with the input time array ! '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif else begin 
                time_arr = time_arr[ index_useful ]
            endelse
            d_time = ( ( max( time_arr ) - min( time_arr ) ) / 1D4 )
            refined_arr = ( findgen( 1D4 ) * d_time )
        endif
        n_time = n_elements( time_arr )  
    endif else begin 
        if keyword_set( log_age ) then begin 
            t_logcos = alog10( t_cosmos * 1.0D9 )
            d_time = ( ( t_logcos - 5.0 ) / n_time )
            time_arr = t_cosmos - reverse( 10.0D^( 5.0 + findgen( n_time ) * $
                d_time ) / 1.0D9 )
            ;; Refined array
            d_refined = ( ( t_logcos - 5.0 ) / 1.0D4 )
            refined_arr = t_cosmos - reverse( 10.0D^( 5.0 + findgen( 1D4 ) * $
                d_refined ) / 1.0D9 )
        endif else begin 
            d_time = ( t_cosmos / n_time )
            time_arr = ( findgen( n_time ) * d_time + 1D-5 )
            ;; Refined array
            d_refined = ( t_cosmos / 1D4 )
            refined_arr = ( findgen( 1D4 ) * d_refined + 1D-5 )
        endelse
    endelse

    ;; Turn it into look back time arr 
    time_lookback    = ( t_cosmos - time_arr ) 
    refined_lookback = ( t_cosmos - refined_arr ) 

    ;; Make a refined SFH first 
    refined_sfr = ( ( t_start - refined_lookback ) / t_start )^( n_power ) * $ 
        exp( -1.0D * ( t_start - refined_lookback ) / tau )

    ;; Trim the SFH 
    index_zero = where( refined_sfr LT 0.0 ) 
    if ( index_zero[0] NE -1 ) then begin
        refined_sfr[ index_zero ] = 0.0 
    endif 
    index_out  = where( refined_lookback GT t_start ) 
    if ( index_out[0] NE -1 ) then begin 
        refined_sfr[ index_out ] = 0.0 
    endif 

    ;; Truncate the SFH if there is an input t_trunc
    if keyword_set( t_trunc ) then begin 
        if ( t_trunc GE t_cosmos ) then begin 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' The truncation age is too large! No truncation is done! ' 
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif else begin 
            index_trunc = where( refined_lookback LT t_trunc ) 
            if ( index_trunc[0] EQ -1 ) then begin 
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                print, ' Something weird about the truncation age! Check!  '
                print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
                return, -1 
            endif else begin 
                refined_sfr[ index_trunc ] = 0.0 
            endelse
        endelse
    endif else begin 
        t_trunc = 0.0 
    endelse

    ;; Normalize the SFH 
    refined_sfr = ( refined_sfr / max( refined_sfr ) )

    ;; Check if the SFR is not finite at certain time 
    index_nan = where( finite( refined_sfr, /NaN ) EQ 1 ) 
    if ( index_nan[0] NE -1 ) then begin 
        refined_sfr[ index_nan ] = 0.00 
    endif 

    ;; Find out when did the SFR peak 
    peak_time = refined_lookback[ where( $ 
        abs( refined_sfr - max( refined_sfr ) ) LT 1E-8 ) ]

    ;; Interpolate the refined array to the time array 
    sfr_arr = interpolate( refined_sfr, $
        findex( refined_lookback, time_lookback ) )  

    ;; Get total SFR
    mass_total = int_tabulated( ( time_arr * 1.0D9 ), reverse( sfr_arr ), /double )

    ;; Define the output structure 
    sfh_struc = { time:fltarr( n_time ), sfr:fltarr( n_time ) } 
    sfh_struc.time = time_arr 
    sfh_struc.sfr  = sfr_arr 

    if keyword_set( plot ) then begin 

        if keyword_set( eps_file ) then begin 
            plot_file = strcompress( eps_file, /remove_all ) 
        endif else begin 
            ts_string = 'ts' + strcompress( string( t_start, format='(F4.1)' ),$
                /remove_all )
            n_string = 'n' + strcompress( string( n_power, format='(F4.1)' ), $
                /remove_all )
            ta_string = 'ta' + strcompress( string( tau, format='(F4.1)' ),$
                /remove_all )
            tr_string = 'tr' + strcompress( string( t_trunc, format='(F4.1)' ),$
                /remove_all )
            plot_file = 'mius_' + ts_string + n_string + ta_string + $
                tr_string + '.eps'
        endelse

        psxsize=28 
        psysize=20
        mydevice = !d.name 
        !p.font=1
        set_plot, 'ps' 
        device, filename=plot_file, font_size=9.0, /encapsulated, $
            /color, set_font='TIMES-ROMAN', /bold, xsize=psxsize, ysize=psysize
        position = [ 0.12, 0.16, 0.99, 0.99 ]

        cgPlot, refined_lookback, refined_sfr, xstyle=1, ystyle=1, $
            xtitle='Look-back Time (Gyr)', ytitle='SFR (Msun/yr)', $ 
            linestyle=2, thick=5.0, color=cgColor( 'Black' ), $
            xthick=12.0, ythick=12.0, charsize=4.0, charthick=10.0, $ 
            yrange=[-0.01, 1.10], position=position, /noerase
        cgPlot, time_lookback, sfr_arr, /overplot, $ 
            psym=16, symsize=1.5, symcolor=cgColor( 'Red' )  

        ;; Label
        xloc = position[0] + 0.03 
        yloc = position[3] - 0.07 
        cgText, xloc, yloc, 'T_start=' + strcompress( $
            string( t_start, format='(F6.3)' ), /remove_all ), /normal, $
            charsize=2.9, charthick=10.0, alignment=0.0
        xloc = position[0] + 0.03 
        yloc = ( yloc - 0.04 ) 
        cgText, xloc, yloc, 'n_power=' + strcompress( $
            string( n_power, format='(F6.3)' ), /remove_all ), /normal, $
            charsize=2.9, charthick=10.0, alignment=0.0
        xloc = position[0] + 0.03 
        yloc = ( yloc - 0.04 ) 
        cgText, xloc, yloc, 'tau=' + strcompress( $
            string( tau, format='(F6.3)' ), /remove_all ), /normal, $
            charsize=2.9, charthick=10.0, alignment=0.0
        xloc = position[0] + 0.03 
        yloc = ( yloc - 0.04 ) 
        cgText, xloc, yloc, 'T_trunc=' + strcompress( $
            string( t_trunc, format='(F6.3)' ), /remove_all ), /normal, $
            charsize=2.9, charthick=10.0, alignment=0.0
        xloc = position[0] + 0.03 
        yloc = ( yloc - 0.04 ) 
        cgText, xloc, yloc, 'N_time=' + strcompress( $
            string( n_time, format='(I7)' ), /remove_all ), /normal, $
            charsize=2.9, charthick=10.0, alignment=0.0
        xloc = position[0] + 0.03 
        yloc = ( yloc - 0.04 ) 
        cgText, xloc, yloc, 'T_Peak=' + strcompress( $
            string( peak_time, format='(F6.1)' ), /remove_all ), /normal, $
            charsize=2.9, charthick=10.0, alignment=0.0

        cgPlot, refined_lookback, refined_sfr, xstyle=1, ystyle=1, $
            xtitle='Look-back Time (Gyr)', ytitle='SFR (Msun/yr)', $ 
            linestyle=2, thick=5.0, color=cgColor( 'Black' ), $
            xthick=12.0, ythick=12.0, charsize=4.0, charthick=10.0, $ 
            yrange=[-0.01, 1.10], position=position, /noerase, /nodata

        device, /close 
        set_plot, mydevice

    endif

    return, sfh_struc

end 

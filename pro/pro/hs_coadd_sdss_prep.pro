; + 
; NAME:
;              HS_COADD_SDSS_PREP
;
; PURPOSE:
;              Prepare SDSS DR8/9 spectra for co-add analysis
;
; USAGE:
;    hs_coadd_sdss_prep, list_file, data_home=data_home, $
;        norm0=norm0, norm1=norm1, csigma=csigma, output=output, $
;        /mask_all, /add_random, /debug, /quiet 
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_coadd_sdss_prep, list_file, data_home=data_home, $
    norm0=norm0, norm1=norm1, csigma=csigma, output=output, $
    mask_all=mask_all, add_random=add_random, $
    debug=debug, quiet=quiet 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on_error, 2
compile_opt idl2

if N_params() lt 1 then begin 
    print,  'Syntax - HS_coadd_SDSS_spec, list_file, csigma, ' 
    return
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____   _    ____      _    __  __ _____ _____ _____ ____  ____    ;;
;;  |  _ \ / \  |  _ \    / \  |  \/  | ____|_   _| ____|  _ \/ ___|   ;;
;;  | |_) / _ \ | |_) |  / _ \ | |\/| |  _|   | | |  _| | |_) \___ \   ;;
;;  |  __/ ___ \|  _ <  / ___ \| |  | | |___  | | | |___|  _ < ___) |  ;;
;;  |_| /_/   \_\_| \_\/_/   \_\_|  |_|_____| |_| |_____|_| \_\____/   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Speed of light 
cs = 299792.458d  ;; km/s
;; Velocity scale of SDSS spectrum 
velscale_sdss = ( 0.0001D * cs * alog( 10.0D ) ) 
;; SDSS instrument resolution FWHM 
fwhm_sdss = 2.76  ;; Angstrom
;; Factor to reject pixels that are affected by sky emission lines 
sky_factor = 2.0
;; The wavelength separation for the coadded spectrum 
dw = 1.0  ;; Angstrom
;; Cushion factor: define the wavelength range you want to hide at both short 
;; and long wavelength end; The smaller the value of this factor, the more 
;; you hide.  Normally 2.0-5.0 should be fine
f_cushion = 2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Location of the _hs.fits files 
if keyword_set( data_home ) then begin 
    hvdisp_location, hvdisp_home, data_home
endif else begin 
    data_home = '/media/hs/Elements/data/spectra/spec/'
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check the list file 
list_file = strcompress( list_file, /remove_all ) 
if NOT file_test( list_file ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, '  Can not find the following list file, please check!'
    print, '  ' + list_file 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif else begin 
    readcol, list_file, list_temp, format='A', /silent 
    ;; Number of spectra that need to be combined
    n_spec = n_elements( list_temp ) 
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the prefix of output files 
temp = strsplit( list_file, '.', /extract ) 
list_string = strcompress( temp[0], /remove_all )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read the MIN_REST and MAX_REST from the header; find the common 
;; wavelength coverage 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
list_spec    = strarr( n_spec ) 
list_loca    = strarr( n_spec )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
min_rest_arr = fltarr( n_spec ) 
max_rest_arr = fltarr( n_spec ) 
veldisp_arr  = fltarr( n_spec )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go through the spectra list
for ii = 0L, ( n_spec - 1 ), 1 do begin 
    ;; 
    temp = strsplit( list_temp[ ii ], '/.', /extract )
    spec_name = temp[ n_elements( temp ) - 2 ] + '_hs.fits'
    list_spec[ ii ] = spec_name 
    ;; 
    temp = strsplit( spec_name, '.-', /extract ) 
    plate_str = strcompress( string( long( temp[ 1 ] ) ), /remove_all )
    spec_hs = data_home + plate_str + '/' + spec_name 
    list_loca[ ii ] = spec_hs
    ;;
    if NOT file_test( spec_hs ) then begin 
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        print, ' Can not find ' + spec_hs + ' !!! '
        print, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        message, ' '
    endif else begin   
        spec_header = headfits( spec_hs, exten=0, errmsg=errmsg, /silent ) 
        if ( n_elements( errmsg ) gt 1 ) then begin 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            print, '  Can not read in the header of the following spectrum!' 
            print, '  ' + spec_hs 
            print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
            message, ' '
        endif else begin 
            min_rest_arr[ ii ] = float( sxpar( spec_header, 'MIN_REST' ) )
            max_rest_arr[ ii ] = float( sxpar( spec_header, 'MAX_REST' ) )
            veldisp_arr[ ii ]  = float( sxpar( spec_header, 'VDISP' ) )
        endelse
    endelse
endfor 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Find the common coverage in wavelength 
l_edge_0 = min( min_rest_arr ) 
l_edge_1 = max( min_rest_arr ) 
r_edge_0 = min( max_rest_arr ) 
r_edge_1 = max( max_rest_arr ) 
l_coadd_cushion = ( ( l_edge_1 - l_edge_0 ) / f_cushion )
r_coadd_cushion = ( ( r_edge_1 - r_edge_0 ) / f_cushion )
wave_0 = long( l_edge_0 + l_coadd_cushion )
wave_1 = long( r_edge_1 - r_coadd_cushion )
wave_sep = ( wave_1 - wave_0 )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Number of pixels in the new wavelength array 
n_pixel_inter = long( wave_1 - wave_0 + 1 )
;; The new array for linear wavelength 
wave_inter = wave_0 + findgen( n_pixel_inter ) * dw 
wave_0 = min( wave_inter ) 
wave_1 = max( wave_inter )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the window of normalization
;; Short wavelength end 
if ( n_elements( norm0 ) ne 0 ) then begin 
    norm_wave_0 = float( norm0 ) 
endif else begin 
    norm_wave_0 = 4200.0 ;; Angstrom 
endelse 
;; Long wavelength end
if ( n_elements( norm1 ) ne 0 ) then begin 
    norm_wave_1 = float( norm1 ) 
endif else begin 
    norm_wave_1 = 4300.0 ;; Angstrom 
endelse 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check if the normalization range is within the wavelength range 
if ( norm_wave_0 LT wave_0 ) then begin 
    if ( norm_wave_1 GT wave_1 ) then begin 
        norm_wave_0 = ( ( wave_1 + wave_0 ) / 2 ) - 50
        norm_wave_1 = ( ( wave_1 + wave_0 ) / 2 ) + 50
        print, '###########################################################'
        print, ' Watch out ! The normalization window has been re-asigned '
        print, ' The new window is: ' + string( norm_wave_0 ) + ' --> ' + $
            string( norm_wave_1 )
        print, '###########################################################'
    endif else begin 
        print, '###########################################################'
        print, ' Watch out ! The norm_wave_0 has been re-asigned to wave_0 ! '
        print, '###########################################################'
        norm_wave_0 = ( wave_0 + 1 )
    endelse 
endif else begin 
    if ( norm_wave_1 GT wave_1 ) then begin 
        print, '###########################################################'
        print, ' Watch out ! The norm_wave_1 has been re-asigned to wave_1 ! '
        print, '###########################################################'
        norm_wave_1 = ( wave_1 - 1 )
    endif 
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if NOT keyword_set( QUIET ) then begin 
    print, '##############################################################'
    print, ' Will Coadd ' + string( n_spec, format='(I6)' ) + '   Spectra ' 
    print, '##############################################################'
    print, ' The Spectra will be normalized using the median value between: ' 
    print, '    ' + string( norm_wave_0, format='(F7.2)' ) + ' -- ' + $ 
        string( norm_wave_1, format='(F7.2)' ) 
    print, '##############################################################'
    print, ' The Wavelength Coverage of the Co-added Spectrum: '
    print, ' ' + string( wave_0, format='(F7.2)' ) + ' -- ' + $
        string( wave_1, format='(F7.2)' )
    print, '##############################################################'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the common velocity dispersion value for the coadd spectrum
if ( n_elements( csigma ) ne 0 ) then begin 
    if ( csigma gt 350.0 ) then begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, ' BE CAREFUL, THE COMMON VELOCITY DISPERSION > 350 km/s !!!'
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    endif
    sigma_convol = float( csigma < 350.00 ) ;; km/s 
endif else begin 
    sigma_convol = ceil( max( veldisp_arr ) + 2 ) 
endelse
if NOT keyword_set( QUIET ) then begin 
    print, ' The Co-Added Spectrum will have a Velocity Dispersion of: '
    print, ' ' + string( sigma_convol, format='(F7.2)' )
    print, '##############################################################'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   ____    _  _____  _      ____  ____  _____ ____   _    ____  _____   ;;
;;  |  _ \  / \|_   _|/ \    |  _ \|  _ \| ____|  _ \ / \  |  _ \| ____|  ;;
;;  | | | |/ _ \ | | / _ \   | |_) | |_) |  _| | |_) / _ \ | |_) |  _|    ;;
;;  | |_| / ___ \| |/ ___ \  |  __/|  _ <| |___|  __/ ___ \|  _ <| |___   ;;
;;  |____/_/   \_\_/_/   \_\ |_|   |_| \_\_____|_| /_/   \_\_| \_\_____|  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the output file 
if keyword_set( output ) then begin 
    output_file = output 
endif else begin 
    output_file = list_string + '_coadd_sigma' + strcompress( $
        string( sigma_convol, format='(I5)' ), /remove_all ) + '.fits'
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define the structure for output 
output_struc = { name:strarr( n_spec ), n_spec:n_spec, n_pix:n_pixel_inter, $
    veldisp:veldisp_arr, min_rest:min_rest_arr, max_rest:max_rest_arr, $ 
    min_wave:wave_0,      max_wave:wave_1, $
    min_norm:norm_wave_0, max_norm:norm_wave_1, $
    sigma_convol:sigma_convol, $
    wave:wave_inter, $
    norm_value:fltarr( n_spec ), $
    flux:fltarr( n_pixel_inter, n_spec ), serr:fltarr( n_pixel_inter, n_spec ), $
    mask:fltarr( n_pixel_inter, n_spec ), wdsp:fltarr( n_pixel_inter, n_spec ), $
    flux_norm:fltarr( n_pixel_inter, n_spec ), $
    serr_norm:fltarr( n_pixel_inter, n_spec ), $
    snr:fltarr( n_pixel_inter, n_spec ), $ 
    nused:fltarr( n_pixel_inter ), frac:fltarr( n_pixel_inter ), $
    mean_flux:fltarr( n_pixel_inter ), median_flux:fltarr( n_pixel_inter ), $
    lquar:fltarr( n_pixel_inter ), uquar:fltarr( n_pixel_inter ), $ 
    lifen:fltarr( n_pixel_inter ), uifen:fltarr( n_pixel_inter ), $
    lofen:fltarr( n_pixel_inter ), uofen:fltarr( n_pixel_inter ), $
    median_snr:fltarr( n_pixel_inter ), median_wsdp:fltarr( n_pixel_inter ), $
    final_mask:fltarr( n_pixel_inter ), final_wdsp:fltarr( n_pixel_inter ), $ 
    final_snr:fltarr( n_pixel_inter ) $
    }
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
for jj = 0L, ( n_spec - 1 ), 1 do begin 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    spec_file = list_loca[ jj ] 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Read in the spectrum again
    data = mrdfits( spec_file, 0, spec_header, /silent, status=status )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if NOT keyword_set( QUIET ) then begin 
        print, '                                      '
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' Spectrum ' + string( ( jj + 1 ), format='(I6)' ) + ' :  ' + $
            spec_file 
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( status ne 0 ) then begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        print, ' Could not find a valid HDU 0 in ' + spec_name 
        message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    endif else begin 
        ;; Read in the information from the spectrum 
        wave = data[ *, 0 ]
        flux = data[ *, 1 ]
        serr = data[ *, 3 ]
        skye = data[ *, 4 ]
        wdsp = data[ *, 9 ] 
        if keyword_set( mask_all ) then begin 
            mask = data[ *, 6 ]
        endif else begin 
            mask = data[ *, 7 ]
        endelse
        ;; Number of pixels 
        n_pixel = n_elements( wave )
        ;; And the header 
        vdisp     = float( sxpar( spec_header, 'vdisp' ) )
        vdisp_err = float( sxpar( spec_header, 'vdisp_er' ) ) 
        coeff0    = float( sxpar( spec_header, 'coeff0' ) )
        coeff1    = float( sxpar( spec_header, 'coeff1' ) )
        ;; Min and Max of Wave 
        min_wave = ceil(  min( wave ) )
        max_wave = floor( max( wave ) )
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Convolve the spectrum into the target velocity dispersion value 
    ;; Includes random error in veolocity dispersion 
    if keyword_set( add_random ) then begin 
        frac_random = 1.02 
        while ( abs( frac_random ) GT 1.0 ) do begin
            frac_random = randomn( systemtime, /normal ) 
        endwhile
        vdisp_rand = ( vdisp + ( frac_random * vdisp_err ) )
        if ( vdisp_rand ge sigma_convol ) then begin 
            vdisp_rand = sigma_convol
        endif else begin 
            vdisp_rand = float( vdisp_rand )
        endelse
    endif else begin 
        vdisp_rand = vdisp 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Calculate the difference in velocity dispersion 
    vdisp_diff = sqrt( sigma_convol^2.0 - vdisp_rand^2.0 )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( vdisp_diff gt 0.0 ) then begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        smoothing = ( vdisp_diff / velscale_sdss )  ;; sigma in pixel 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; adopted from gconv.pro from Yanmei Chen
        n_kernel_pixel = round( 4.0 * smoothing + 1.0 ) * 2.0 
        kernel_lam = findgen( n_kernel_pixel ) - float( n_kernel_pixel ) / 2.0 
        kernel = exp( -1.0 * kernel_lam^2.0 / ( 2.0 * smoothing^2.0 ) )
        kernel = kernel / total( kernel )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        flux_conv = convol( flux, kernel, /edge_truncate )
        mask_conv = convol( mask, kernel, /edge_truncate )
        serr_conv = sqrt( convol( ( serr^2.0D ), kernel, /edge_truncate ) )
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; Compare the spectrum before and after convolution 
        if ( keyword_set( debug ) AND ( jj EQ 1 ) ) then begin 
            cgPlot, wave, flux, xstyle=1, ystyle=1, xrange=[3900,7200], $
                linestyle=0, thick=3.0, color=cgColor( 'Dark Gray' ) 
            cgPlot, wave, flux_conv, /overplot, $ 
                linestyle=0, thick=2.0, color=cgColor( 'Red' ) 
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if NOT keyword_set( QUIET ) then begin 
            print, '    ***************************************************   '
            print, '    Spectrum has been convolved to ', sigma_convol, $
                ' km/s', format='(A,F5.0,A)' 
            print, '    The velocity dispersion is ', vdisp, ' +/- ', $
                vdisp_err, ' km/s', format='(A,F6.2,A,F5.2,A)'
            print, '    The velscale is ', velscale_sdss, format='(A,F5.2)' 
            print, '    ***************************************************   '
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endif else begin 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        flux_conv = flux 
        mask_conv = mask 
        serr_conv = serr
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if NOT keyword_set( QUIET ) then begin 
            print, '   ************************************   '
            print, '   Spectrum has not been convolved !! '
            print, '   ************************************   '
        endif
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_0 = where( mask_conv ge 0.5 )
    index_1 = where( mask_conv lt 0.5 )
    if ( index_0[0] NE -1 ) then begin 
        mask_conv[ index_0 ] = 1 
    endif else begin 
        print, '###########################################################'
        print, '   Be careful !! NO MASK is found !!!!!!'
        print, '###########################################################'
    endelse
    if ( index_1[0] NE -1 ) then begin 
        mask_conv[ index_1 ] = 0 
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Interpolate the spectrum to WAVE_INTER
    index_inter = findex( wave, wave_inter )
    flux_conv_inter = interpolate( flux_conv, index_inter, /grid )
    mask_conv_inter = interpolate( mask_conv, index_inter, /grid )
    wdsp_inter      = interpolate( wdsp, index_inter, /grid )
    serr_conv_inter = sqrt( interpolate( ( serr_conv^2.0D ), index_inter, $
        /grid ) )
    snr_conv_inter  = ( flux_conv_inter / serr_conv_inter )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Make a new mask 
    index_1 = where( mask_conv_inter ge 0.5 ) 
    index_2 = where( mask_conv_inter lt 0.5 ) 
    if ( index_1[0] ne -1 ) then begin 
        mask_conv_inter[ index_1 ] = 1
        if ( index_2[0] ne -1 ) then begin 
            mask_conv_inter[ index_2 ] = 0 
        endif 
    endif else begin 
        mask_conv_inter[ index_2 ] = 0 
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Mask out the region outside the restframe wavelength range 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_out_1 = where( wave_inter lt min_wave ) 
    if ( index_out_1[0] ne -1 ) then begin 
        mask_conv_inter[ index_out_1 ] = 1
        flux_conv_inter[ index_out_1 ] = !VALUES.F_NaN
        serr_conv_inter[ index_out_1 ] = !VALUES.F_NaN
        snr_conv_inter[ index_out_1 ]  = 0 
        wdsp_inter[ index_out_1 ]      = !VALUES.F_NaN
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_out_2 = where( wave_inter gt max_wave )
    if ( index_out_2[0] ne -1 ) then begin 
        mask_conv_inter[ index_out_2 ] = 1 
        flux_conv_inter[ index_out_2 ] = !VALUES.F_NaN
        serr_conv_inter[ index_out_2 ] = !VALUES.F_NaN
        snr_conv_inter[ index_out_2 ]  = 0 
        wdsp_inter[ index_out_2 ]      = !VALUES.F_NaN
    endif 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Nomalize the spectrum 
    norm_index = where( ( wave_inter ge norm_wave_0 ) AND $
                        ( wave_inter le norm_wave_1 ) ) 
    if ( norm_index[0] eq - 1 ) then begin 
        print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' 
        print, '  The Normalization Window is Out of Range! Check! ' 
        print, '  Please set the window between : ' + $
            string( min( wave_inter ), format='(F7.2)' ) + ' -- ' + $
            string( max( wave_inter ), format='(F7.2)' ) 
        message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!' 
    endif else begin 
        norm_factor = median( flux_conv_inter[ norm_index ] )
    endelse
    flux_norm = ( flux_conv_inter / norm_factor ) 
    serr_norm = ( serr_conv_inter / norm_factor )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Save results to the output structure 
    output_struc.name[ jj ]   = spec_file 
    output_struc.flux[*, jj ] = flux_conv_inter 
    output_struc.serr[*, jj ] = serr_conv_inter 
    output_struc.mask[*, jj ] = mask_conv_inter 
    output_struc.wdsp[*, jj ] = wdsp_inter
    output_struc.snr[*, jj ]  = snr_conv_inter
    output_struc.flux_norm[*, jj ] = flux_norm 
    output_struc.serr_norm[*, jj ] = serr_norm 
    output_struc.norm_value[ jj ]  = norm_factor
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Number of masked pixels: 
    n_masked = n_elements( where( mask_conv_inter eq 1 ) ) 
    if NOT keyword_set( QUIET ) then begin 
        print, '###############################################################'
        print, ' ', n_masked, ' pixels have been masked out', $
            format='(A,I5,A)'
        print, '###############################################################'
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic statistics
for k = 0L, ( n_pixel_inter - 1 ), 1 do begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Find the useful pixels: finite and not masked out 
    index_use = where( ( output_struc.mask[ k, * ] EQ 0 ) AND $
        ( finite( output_struc.flux_norm[ k, * ] ) EQ 1 ) AND $ 
        ( finite( output_struc.serr_norm[ k, * ] ) EQ 1 ) AND $ 
        ( finite( output_struc.snr[ k, * ] ) EQ 1 ) )
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if ( index_use[0] EQ -1 ) then begin 
        output_struc.nused[k]       = 0 
        output_struc.frac[k]        = 0
        output_struc.mean_flux[k]   = !VALUES.F_NaN 
        output_struc.median_flux[k] = !VALUES.F_NaN 
        output_struc.lquar[k]       = !VALUES.F_NaN
        output_struc.uquar[k]       = !VALUES.F_NaN
        output_struc.lifen[k]       = !VALUES.F_NaN
        output_struc.uifen[k]       = !VALUES.F_NaN
        output_struc.lofen[k]       = !VALUES.F_NaN
        output_struc.uofen[k]       = !VALUES.F_NaN
        output_struc.final_mask[k]  = 1 
        output_struc.final_snr[k]   = 0
        output_struc.final_wdsp[k]  = median( output_struc.wdsp[k,*] )  
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        print, ' Probematic Pixel at : ', output_struc.wave[k]
        print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    endif else begin 
        output_struc.nused[k]       = n_elements( index_use ) 
        output_struc.frac[k]        = ( n_elements( index_use ) * 1.0 ) / n_spec
        output_struc.mean_flux[k]   = mean( output_struc.flux_norm[k,index_use] ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; get the basic statistics 
        rstat, output_struc.flux_norm[k,index_use], med_flux, lquar, uquar, $
            lifen, uifen, lofen, uofen, minvalue, maxvalue, /noprint 
        output_struc.median_flux[k] = med_flux 
        output_struc.lquar[k]       = lquar
        output_struc.uquar[k]       = uquar
        output_struc.lifen[k]       = lifen
        output_struc.uifen[k]       = uifen
        output_struc.lofen[k]       = lofen
        output_struc.uofen[k]       = uofen
        output_struc.final_wdsp[k]  = median( output_struc.wdsp[k,*] )  
        output_struc.final_snr[k]   = SQRT( $
            TOTAL( ( output_struc.snr[k,index_use] )^2.0 ) ) 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( finite( output_struc.final_snr[k] ) NE 1 ) then begin  
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
            print, ' SNR is NaN at : ', output_struc.wave[k]  
            print, '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        endif 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if ( output_struc.frac[k] LE 0.5 ) then begin 
            output_struc.final_mask[k] = 1 
        endif else begin 
            output_struc.final_mask[k] = 0 
        endelse
    endelse
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save the output file 
mwrfits, output_struc, output_file, /create, /silent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
free_all 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

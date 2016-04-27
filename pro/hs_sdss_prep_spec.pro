;+
; NAME:
;              HS_SDSS_PREP_SPEC
;
; PURPOSE:
;              Prepare SDSS DR8/9 spectra for further analysis
;
; USAGE:
;    hs_sdss_prep_spec, spec_file, /PLOT, /QUIET 
;
; ARGUMENTS:
;    spec_file: 
;       Name or location of the SDSS DR8/9 spectrum.
;
;       For example: 
;           hs_sdss_prep_spec, 'spec-1925-53327-0623.fits'
;
;                                                            
; KEYWORDS:
;    PLOT:      Input.  Optional 
;               Whether make a plot that summaries the information of the 
;               spectra
;
;    QUIET:     Input
;               Verbosity control. By default the function prints
;               some information about the data it reads.
;
; OUTPUT:
;    A new fits file which includes the spectral information in a binary table 
;    and several useful keywords in the header
;
; DESCRIPTION:
;   Read a spectrum from a FITS file, including possibly the associated
;   noise and a mask to exclude the bad regions, shift it back to the 
;   restframe (if SG is given) and rebin it to a logarithmic
;   wavelength scale (if VELSCALE is given).
;
;   ;; The conversion of vacuum wave. part is from ULY_SPECT_READ   
;   Note about the conversion of vacuum wavelengths:
;     The IAU definition for the conversion between Air and Vacuum
;     wavelength, respectively (VAC) and (AIR) is:
;       VAC = AIR * 1 + 6.4328D-5 + 2.94981D-2/(146 - sigma2) + 
;             2.5540D-4/(41 - sigma2)
;       where sigma2 = 1/AIR^2 (the wavelengths are in Angstrom)
;     This formula is cited in Morton 1991 ApJS 77, 119
;
;     So, approximately in the visible range: AIR = VAC / 1.00028
;     (i.e. a shift of 84 km/s).
;     ULY_SPECT_READ applies this approximate conversion to the WCS, to avoid
;     a resampling. The IDL function VACTOAIR shall be used if a higher
;     precision is required.
;
;     The wavelength calibration of the SDSS spectra is in Heliocentric 
;     VACUUM wavelength.
;
; EXAMPLE:
;     Read a spectrum, and plot it:
;     hs_sdss_prep_spec, 'spec-1925-53327-0623.fits', /PLOT
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2013/06/14 - reading SDSS DR9 format
;             Song Huang, 2014/06/05 - provide new velocity dispersion or other 
;                                      information into the header
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro hs_sdss_prep_spec, spec_file, suffix=suffix, $
    plot=plot, quiet=quiet, no_extcorr=no_extcorr, $ 
    save_indexf=save_indexf, save_ulyss=save_ulyss, save_sl=save_sl, $
    ccm=ccm, odl=odl, save_ez=save_ez, ipath=ipath, new_vdp=new_vdp, $
    and_mask=and_mask, pg10=pg10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on_error, 2
compile_opt idl2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if N_params() lt 1 then begin 
    print,  'Syntax - HS_prepare_SDSS_spec, spec_file, /plot, /quiet, '
    print,  '       /save_indexf, /save_ulyss, /save_sl, /save_ez, '
    print,  '       /CCM, /ODL, /save_ez, ipath=ipath, new_vdp=new_vdp '
    return
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Location of the dust data 
if NOT keyword_set( ipath ) then begin 
    ipath= getenv( 'DUST_DIR' )
    if strmid(ipath, strlen(ipath) - 1, 1) NE '/' then begin 
        ipath = ipath + '/'
    endif
    if ipath EQ '' then begin 
        print, 'Can not find the DUST_DIR parameter!!'
        ipath = './'
    endif 
endif else begin 
    ipath = strcompress( ipath, /remove_all ) 
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Suffix of the output file 
if keyword_set( suffix ) then begin 
    suffix = strcompress( suffix, /remove_all )
endif else begin
    suffix = 'hs'
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in spectra from SDSS DR8/DR9.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check if the file is there
spec_file = strcompress( spec_file, /remove_all ) 
if NOT file_test( spec_file ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, '  Can not find the following spectrum, please check!'
    print, '  ' + spec_file 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get the name of the spectrum, and the string of: 
;;   spec-PLATE-MJD-FIBER
temp = strsplit( spec_file, '/', /extract ) 
if ( n_elements( temp) gt 1 ) then begin 
    spec_name = strcompress( temp[ n_elements( temp ) - 1 ], /remove_all )
endif else begin 
    spec_name = spec_file 
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
temp = strsplit( spec_name, '.', /extract )
spec_string = strcompress( temp[0], /remove_all )
temp = strsplit( spec_name, '-.', /extract ) 
if ( n_elements( temp ) ne 5 ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, '  This is not a SDSS DR8/DR9 spectrum, please check!'
    print, '  ' + spec_file 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if NOT keyword_set( QUIET ) then begin 
    print, '##############################################################'
    print, ' About to read in : ' + spec_name 
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in the HDU 0
img_null = mrdfits( spec_file, 0, header0, /silent, STATUS=status )
if ( status ne 0 ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Could not find a valid HDU 0 in ' + spec_name 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
;; Read in useful keywords from HUD 0
;;  Plate, MJD, FiberID and Spec_ID
plate     = sxpar( header0, 'PLATEID' )
mjd       = sxpar( header0, 'MJD' )
fiberid   = sxpar( header0, 'FIBERID' )
spec_id   = sxpar( header0, 'SPEC_ID' )  ;; string
;;  RA and DEC of the fiber
ra_plug   = sxpar( header0, 'PLUG_RA' ) 
dec_plug  = sxpar( header0, 'PLUG_DEC' ) 
;;  Wavelength calibration
coeff0    = double( sxpar( header0, 'COEFF0' ) )
coeff1    = double( sxpar( header0, 'COEFF1' ) )
;;  Check if this is a real SDSS spectrum 
if ( ( plate eq 0 ) or ( mjd eq 0 ) or ( fiberid eq 0 ) ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, '  This is not a SDSS DR8/DR9 spectrum, please check!'
    print, '  ' + spec_file 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in the HDU 1 : The coadded spectrum 
spec_struc = mrdfits( spec_file, 1, header1, /silent, STATUS=status )
if ( status ne 0 ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Could not find a valid HDU 1 in ' + spec_name 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
;; Read useful information from the structure 
llam = spec_struc.loglam   ;; alog10( wavelength/Angstrom ) 
flux = spec_struc.flux     ;; flux in 10^(-17) erg/s/cm^2/Angstrom
ivar = spec_struc.ivar     ;; inverse variance of flux 
if keyword_set( and_mask ) then begin 
    mask = spec_struc.and_mask ;; AND mask 
endif else begin 
    mask = spec_struc.or_mask  ;; OR mask 
endelse
wdsp = spec_struc.wdisp    ;; wavelength dispersion in pixel=dloglam units 
skye = spec_struc.sky      ;; subtracted sky flux  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read in the HDU 2 : Information about the spectrum 
spec_table = mrdfits( spec_file, 2, header2, /silent, STATUS=status )
if ( status ne 0 ) then begin 
    print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    print, ' Could not find a valid HDU 2 in ' + spec_name 
    message, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
endif
;; Read useful information from the structure 
z      = spec_table.z 
z_err  = spec_table.z_err
sn_all = spec_table.sn_median_all 
sn_arr = spec_table.sn_median 
sn_r   = sn_arr[2] 
sn_i   = sn_arr[3]
vdisp  = spec_table.vdisp 
vdisp_err = spec_table.vdisp_err 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display some of the above information
if NOT keyword_set( QUIET ) then begin 
    print, '##############################################################'
    print, ' SpecObjID        : ' + string( spec_id )
    print, ' RA_PLUG / DEC_PLT: ' + string( ra_plug ) + string( dec_plug ) 
    print, ' Redshift +/- Err : ' + string( z ) + ' +/-' + string( z_err )
    print, ' Median S/N in r & i : ' + string( sn_r ) + string( sn_i ) 
    print, ' VelDisp +/- Err  : ' + string( vdisp ) + ' +/-' + $
        string( vdisp_err )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic reduction of the spectrum 
;; Number of pixels in the spectrum 
n_pixels = n_elements( flux ) 
;; Linear wavelength 
wave = 10.0D^(llam) 
;; Convert ivariance into sigma 
sigma = SQRT( 1.0D / ivar ) 
;; Find the bad pixels with MAKS != 0
bad_pixels1 = where( mask ne 0 ) 
;; Find the bad pixels that have IVAR = 0 
bad_pixels2 = where( ivar eq 0 ) 
;; Mask out the bad pixels in the MASK and where ivar = 0 
mask_bad = mask 
if ( bad_pixels1[0] ne -1 ) then begin 
    mask_bad[ bad_pixels1 ] = 1 
endif
if ( bad_pixels2[0] ne -1 ) then begin 
    mask_bad[ bad_pixels2 ] = 1
endif
num_bad = n_elements( where( mask_bad eq 1 ) )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculate the ratio of sky flux and the flux of the target 
;; TODO: Should have an option for absolute or relative sky clipping
sky_obj_ratio = ( skye / flux )
;; Define the pixel with sky_obj_ratio larger than 3rd Quartile + 3.0 * IQ 
;; as the pixels strongly affected by sky emission lines. 
;; Build a separate mask for it 
mask_sky = intarr( n_pixels ) 

;; XXX Do not used relative mask
sky_summary = hs_basic_stats( skye ) 
sky_factor = 2.0
sky_outlier = ( sky_summary.uofen * sky_factor )
mask_sky[ where( skye ge sky_outlier ) ] = 1 

num_sky = n_elements( where( mask_sky eq 1 ) )

;; Build a combined mask based on Mask_BAD and Mask_SKY
mask_all = mask_bad 
mask_all[ where( mask_sky eq 1 ) ] = 1 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if NOT keyword_set( QUIET ) then begin 
    print, '##############################################################'
    print, ' Wavelength Coverage : ' + string( min( wave ) ) + ' - ' + $
        string( max( wave ) ) 
    print, ' Number of Pixels    : ' + string( n_pixels ) 
    print, ' Number of Bad Pixels : ' + string( num_bad ) 
    print, ' Number of Pixels Affected by Sky Emission : ' + string( num_sky )
    print, ' Sky Outlier Threshold : ' + string( sky_outlier )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Move the spectrum back to restframe 
rest = ( wave / ( 1.0 + z ) )
;; Find out the minimum and maximun of the restframe wavelength
min_rest = min( rest ) 
max_rest = max( rest )
;; Also correct the COEFF0 
coeff0 = alog10( double( wave[0] ) ) 
coeff0_new = coeff0 - alog10( 1.0D + double( z ) )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Convert the RA and DEC of the plug into Galactic coordinate: 
glactc, ra_plug, dec_plug, 2000., gl_plug, gp_plug, 1, /deg
;; Get the E(B-V) value for GL_PLUG and GP_PLUG 
if keyword_set( pg10 ) then begin 
    ebv = dust_getval( gl_plug, gp_plug, ipath=ipath, /interp, /pg10 ) 
endif else begin 
    ebv = dust_getval( gl_plug, gp_plug, ipath=ipath, /interp ) 
endelse
if keyword_set( no_extcorr ) then begin
    ;; Correction of the Galactic extinction 
    ;; A(V) = E(B-V) * R(V)
    R_v = 3.1 
    ;; Use the extinction curve from CCM(1989) or O'Donnel(1994)
    ;; where alam: A(lamda)/A(V)
    if keyword_set( CCM ) then begin 
        alam = ext_ccm( wave, R_v )
    endif else begin 
        if keyword_set( ODL ) then begin 
            alam = ext_odonnell( wave, R_v )
        endif else begin 
            alam = ext_ccm( wave, R_v )
        endelse
    endelse
    ;; Actuall correction 
    flux_deredden = ( flux * 10.0^( 0.4 * ebv[0] * alam * R_v ) )
endif else begin 
    flux_deredden = flux
endelse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if NOT keyword_set( QUIET ) then begin 
    print, '##############################################################'
    print, ' Wavelenght Coverage in Restframe: ' + string( min_rest ) + ' ' + $
        string( max_rest ) 
    print, ' Galactic coordinate of the Plug : ' + string( gl_plug ) + ' ' + $ 
        string( gp_plug ) 
    print, ' E(B - V) Value : ' + string( ebv[0] )
    print, '##############################################################'
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make a linear interpolate version of the spectrum 
rest_inter = floor( min_rest ) + 1.0 * findgen( floor( max_rest - min_rest ) )
n_pixels_inter = n_elements( rest_inter )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
flux_inter  = interpolate( flux_deredden, findex( rest, rest_inter ), /grid )
skye_inter  = interpolate( skye,  findex( rest, rest_inter ), /grid )
sigma_inter = interpolate( sigma, findex( rest, rest_inter ), /grid )
mask_inter  = ceil( interpolate( mask_all, findex( rest, rest_inter ), /grid ) )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make a plot for sanity check 
if keyword_set( PLOT ) then begin 
    pos = [ 0.09, 0.10, 0.99, 0.99 ]
    cgPlot, rest, flux, xstyle=1, linestyle=0, color=cgColor( 'Gray' ), $
        position=pos, xtitle='Wavelength', ytitle='Flux', /nodata
    
    cgOPlot, rest_inter, skye_inter, linestyle=2, color=cgColor('Orange')

    cgOPlot, wave, flux, linestyle=0, color=cgColor( 'Gray' )
    cgOPlot, rest, flux, linestyle=0, color=cgColor( 'Cyan' )
    cgOPlot, rest, flux_deredden, linestyle=0, color=cgColor( 'Blue' ) 
    
    ;; Pixels affected by sky
    index_nosky = where( mask_sky EQ 0 )
    temp = flux 
    temp[ index_nosky ] = !VALUES.F_NaN
    cgOplot, rest, temp, linestyle=0, color=cgColor( 'Red' )
    
    ;; Pixels without mask
    index_bad = where( mask_inter GT 0 )
    temp = flux_inter 
    temp[ index_bad ] = !VALUES.F_NaN 
    cgOPlot, rest_inter, temp, linestyle=0, color=cgColor( 'Green' )
    ;cgOPlot, rest, ( flux_deredden + sigma ), linestyle=2, $
    ;    color=cgColor( 'Cyan' )
    ;cgOPlot, rest, ( flux_deredden - sigma ), linestyle=2, $
    ;    color=cgColor( 'Cyan' )
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start saving the data 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; First save a binary table containing all the information: 
;; llam; wave; rest; flux; flux_deredden; ivar; sigma; mask; mask_bad; 
;; mask_sky; mask_all; skye; sky_obj_ratio 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header_new = strarr( 19 ) 
header_new[0] = 'SIMPLE  =                    T /Primary Header'
header_new[1] = 'BITPIX  =                  -32 / '
header_new[2] = 'NAXIS   =                    2 / ' 
header_new[3] = 'NAXIS1  =         ' + string( n_pixels ) + ' / '
header_new[4] = 'NAXIS2  =                   10 / '
header_new[5] = 'TTYPE1 =  "WAVE_REST" / '
header_new[6] = 'TTYPE2 =  "FLUX_DERED" / '
header_new[7] = 'TTYPE3 =  "IVAR" / '
header_new[8] = 'TTYPE4 =  "SIGMA" / '
header_new[9] = 'TTYPE5 =  "SKY_FLUX" / '
header_new[10] = 'TTYPE6 =  "SKY_FLUX_RATIO" / '
header_new[11] = 'TTYPE7 =  "MASK_ALL" / '
header_new[12] = 'TTYPE8 =  "MASK_BAD" / '
header_new[13] = 'TTYPE9 =  "MASK_SKY" / '
header_new[14] = 'TTYPE9 =  "WDISP" / '
header_new[15] = 'TTYPE10 =  "WAVE" / '
header_new[16] = 'EXTEND  =                    T /Extensions may be present'
header_new[17] = 'COMMENT   Made by HS_PREPARE_SDSS_SPEC '
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sxaddpar, header_new, 'COEFF0'    , coeff0_new 
sxaddpar, header_new, 'COEFF1'    , coeff1 
sxaddpar, header_new, 'Z'         ,   z 
sxaddpar, header_new, 'Z_ERR'     , z_err 
sxaddpar, header_new, 'RA_PLUG'   , ra_plug
sxaddpar, header_new, 'DEC_PLUG'  , dec_plug
sxaddpar, header_new, 'GL_PLUG'   , gl_plug
sxaddpar, header_new, 'GP_PLUG'   , gp_plug
sxaddpar, header_new, 'E_BV'      , ebv[0]
if keyword_set( new_vdp ) then begin 
    sxaddpar, header_new, 'VDISP' , new_vdp
endif else begin 
    sxaddpar, header_new, 'VDISP' , vdisp
endelse
sxaddpar, header_new, 'VDISP_ERR' , vdisp_err
sxaddpar, header_new, 'SN_MEDIAN' , sn_all
sxaddpar, header_new, 'SN_R'      , sn_r
sxaddpar, header_new, 'SN_I'      , sn_i
sxaddpar, header_new, 'MIN_REST'  , min_rest 
sxaddpar, header_new, 'MAX_REST'  , max_rest 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spec_output = fltarr( n_pixels, 11 ) 
spec_output[ *, 0 ] = rest 
spec_output[ *, 1 ] = flux_deredden 
spec_output[ *, 2 ] = ivar 
spec_output[ *, 3 ] = sigma 
spec_output[ *, 4 ] = skye 
spec_output[ *, 5 ] = sky_obj_ratio 
spec_output[ *, 6 ] = mask_all 
spec_output[ *, 7 ] = mask_bad 
spec_output[ *, 8 ] = mask_sky
spec_output[ *, 9 ] = wdsp
spec_output[ *, 10] = wave
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
new_suffix = '_' + suffix + '.fits' 
new_file = spec_file
strreplace, new_file, '.fits', new_suffix
mwrfits, spec_output, new_file, header_new, /create, /silent 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; For ULyss 
;; In Ulyss, this file can be directly read in as: 
;;    IDL>lun = fxposit( 'XXXXXXXXXX_uly.fits', 1 )
;;    IDL>uly_spect_read( lun ) 
;; Or you can try: 
;;    IDL>galaxy = 'XXXXXXXXXX_uly.fits' 
;;    IDL>ulyss, galaxy, model=uly_root+'/models/elodie32_flux_tgm.fits', /PLOT'
;; to see if ULyss can work properly
if keyword_set( save_ulyss ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    uly_file = spec_file
    strreplace, uly_file, '.fits', '_uly.fits'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    header_uly = strarr( 12 ) 
    header_uly[0] = 'SIMPLE  =                    T /Primary Header'
    header_uly[1] = 'BITPIX  =                  -32 / '
    header_uly[2] = 'NAXIS   =                    2 / ' 
    header_uly[3] = 'NAXIS1  =         ' + string( n_pixels ) + ' / '
    header_uly[4] = 'NAXIS2  =                    4 / '
    header_uly[5] = 'COEFF0  =   ' + string( coeff0_new ) + ' / '
    header_uly[6] = 'COEFF1  =   ' + string( coeff1 ) + ' / '
    header_uly[10] = 'EXTEND  =                    T /Extensions may be present'
    header_uly[11] = 'COMMENT   Made by HS_PREPARE_SDSS_SPEC '
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    uly_output = { SPEC:0.0d, LAMBDA:0.0, IVAR:0.0D, ORMASK:0L }
    uly_output = replicate ( uly_output, n_pixels )
    for j = 0, ( n_pixels - 1 ), 1 do begin 
        uly_output[j].spec   = flux_deredden[j]
        uly_output[j].lambda = rest[j] 
        uly_output[j].ivar   = ivar[j]
        uly_output[j].ormask = mask[j] 
    endfor 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mwrfits, uly_output, uly_file, /create, /silent 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endif 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; For INDEXF : 
;; 1: NAXIS1 and NAXIS2 are assumed to correspond to the spectral and spatial
;;    direction, respectively. The FITS header must contain the information 
;;    concerning the wavelength calibration (CRVAL1, CDELT1, CRPIX1; if not 
;;    present, CTYPE1=WAVE and CUNIT1=Angstrom are assumed).
;; 2: ERROR: Input FITS file name containing the error spectra (unbiased 
;;    standard deviation). The FITS header must contain the same information
;;    concerning the wavelength calibration than the data FITS file. If this 
;;    file is "undef", no error computation is performed.
;; See: http://pendientedemigracion.ucm.es/info/Astrof/software/indexf/
if keyword_set( save_indexf ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    indexf_file_1 = spec_file
    indexf_file_2 = spec_file
    strreplace, indexf_file_1, '.fits', '_ind.fits'
    strreplace, indexf_file_2, '.fits', '_ind_err.fits'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    header_ind = strarr( 11 ) 
    header_ind[0] = 'SIMPLE  =                    T /Primary Header'
    header_ind[1] = 'BITPIX  =                  -32 / '
    header_ind[2] = 'NAXIS   =                    2 / ' 
    header_ind[3] = 'NAXIS1  =         ' + string( n_pixels_inter ) + ' / '
    header_ind[4] = 'CRVAL1  =     ' + string( min_rest ) + ' / '
    header_ind[5] = 'CDELT1  =                    1 / '
    header_ind[6] = 'CRPIX1  =                    1 / '
    header_ind[7] = 'EXTEND  =                    T /Extensions may be present'
    header_ind[8] = 'VELDISP =     ' + string( vdisp ) + ' / '
    header_ind[9] = 'REDSHIFT =    ' + string( z ) + ' / ' 
    header_ind[10] = 'COMMENT   Made by HS_PREPARE_SDSS_SPEC '
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp = fltarr( n_pixels_inter )
    temp[ * ] = flux_inter
    mwrfits, temp, indexf_file_1, header_ind, /create, /silent 
    temp = fltarr( n_pixels_inter )
    temp[ * ] = sigma_inter
    mwrfits, temp, indexf_file_2, header_ind, /create, /silent 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; For STARLIGHT v4 
;;  STARLIGHT requires a simple four-column ASCII file as input, 
;;  The four columns are: 1) Wavelength, 2) FLux, 3) Error, 4) Mask 
;;  The wavelength is in Angstrom, and should be prepared in constant, linear 
;;  step; For the mask, any value greater than 0 will be considered as bad 
if keyword_set( save_sl ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sl_file = spec_file
    strreplace, sl_file, '.fits', '_sl.txt'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    index_nan_1 = where( flux_inter  EQ !VALUES.F_NAN )
    index_nan_2 = where( sigma_inter EQ !VALUES.F_NAN )
    if ( index_nan_1[0] ne -1 ) then begin 
        flux_inter[ index_nan_1 ] = -99 
        mask_inter[ index_nan_1 ] = 99L 
    endif 
    if ( index_nan_2[0] ne -1 ) then begin 
        sigma_inter[ index_nan_1 ] = -99 
        mask_inter[ index_nan_2 ]  = 99L 
    endif 
    mask_inter[ where( mask_inter ne 0 ) ] = 99L 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    openw, lun, sl_file, /get_lun, width=300
    for j = 0, ( n_pixels_inter - 1 ), 1 do begin 
        printf, lun, $
            string( rest_inter[j], format='(F7.2)' ) + ' ' + $ 
            string( flux_inter[j], format='(F16.6)' ) + ' ' + $ 
            string( sigma_inter[j], format='(F16.6)' ) + ' ' + $ 
            string( mask_inter[j], format='(I4)' ) 
    endfor 
    close, lun
    free_lun, lun
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use Lick_EW.pro from the EZ_Ages package, the value and error of all 
;; Lick/IDS index can be measured, and be used for estimating the abundance of 
;; different element using ea_ages.pro
;; 
;; IDL> lick_ew, 'spec_list', velocity_dispersion='veldisp_list', 
;;      resolution=2.39, outfile='out_list', wave_exten=0,  
;;      /plot, spec_exten=1, spec_nslice=0, err_nslice=1, /pix
if keyword_set( save_ez ) then begin 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ez_file = spec_file
    strreplace, ez_file, '.fits', '_ez.fits'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lickew_output = fltarr( n_pixels )
    lickew_output[ * ] = rest
    mwrfits, lickew_output, ez_file, /create, /silent 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    temp = mrdfits( ez_file, 0, ez_head )
    if keyword_set( new_vdp ) then begin 
        sxaddpar, ez_head, 'VDISP', new_vdp, 'Velocity dispersion' 
    endif else begin 
        sxaddpar, ez_head, 'VDISP', vdisp, 'Velocity dispersion' 
    endelse
    sxaddpar, ez_head, 'VDISPER'  , vdisp_err, 'Error of Velocity Dispersion' 
    sxaddpar, ez_haed, 'Z'        , z, 'Redshift'
    sxaddpar, ez_head, 'CRVAL1'   , coeff0_new 
    sxaddpar, ez_head, 'CD1_1'    ,  coeff1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lickew_output = fltarr( n_pixels, 2 )
    lickew_output[ *, 0 ] = flux_deredden 
    lickew_output[ *, 1 ] = sigma
    mwrfits, lickew_output, ez_file, ez_head, /creat, /silent 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

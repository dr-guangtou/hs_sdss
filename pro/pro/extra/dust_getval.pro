;------------------------------------------------------------------------------
;+
; NAME:
;   dust_getval
;
; PURPOSE:
;   Read values from BH files, SFD98 dust maps, and/or PG10 corrections
;
; CALLING SEQUENCE:
;   value = dust_getval( [ gall, galb, infile=infile, skipline=skipline, $
;    outfile=outfile, map=map, interp=interp, noloop=noloop, verbose=verbose, $
;    ipath=ipath, bhpath=bhpath ] )
;
; INPUTS:
;
; OPTIONAL INPUTS:
;   gall:       Galactic longitude(s) in degrees
;   galb:       Galactic latitude(s) in degrees
;   map:        Set to one of the following (default is 'Ebv'):
;               BH  : Burstein-Heiles 4*E(B-V)
;               I100: 100-micron map in MJy/Sr
;               X   : X-map, temperature-correction factor
;               T   : Temperature map in degrees Kelvin for n=2 emissivity
;               IX  : Temperature-corrected 100-micron map in MJy/Sr
;               Ebv : E(B-V) in magnitudes
;               mask: 8-bit mask
;               PG10: ONLY the corrections to the SFD98 maps from
;                     PG10, not to be used to for reddening correction
;                     without SFD98 corrections already applied.
;                     Note that these corrections allow for
;                     negative final reddenings, for users who prefer
;                     to avoid the clipping described in Section 5 of PG10.
;               Err : Derived errors in the PG10 corrections
;   infile:     If set, then read GALL and GALB from this file
;   skipline:   Number of lines to skip at the top of the input file
;   outfile:    If set, then write results to this file
;   interp:     Set this flag to return a linearly interpolated value
;               from the 4 nearest pixels.
;               This is disabled if map='mask'.
;   noloop:     Set this flag to read all values at once without a FOR loop.
;               This is a faster option for reading a large number of values,
;               but requires reading an entire FITS image into memory.
;               (Actually, the smallest possible sub-image is read.)
;   verbose:    Set this flag for verbose output, printing pixel coordinates
;               and map values.  Setting NOLOOP disables this option.
;   ipath:      Path name for dust maps; default to path set by the
;               environment variable $DUST_DIR/maps, or to the current
;               directory.
;   bhpath:     Path name for BH maps
;   pg10:       If set, include the corrections to E(B-V) from Peek
;               & Graves 2010, ApJ, in press. This keyword only
;               functions if map is not set, or set to 'Ebv'. 
;
; OPTIONAL OUTPUT:
;   corrpg10:   Returns a 1 if a correction from Peek & Graves 2010
;               was applied and a 0 if no such correction was applied,
;               because the data were beyond the area over which the
;               corrections are defined. Returns a 2 if the correction
;               from Peek & Graves 2010 would yield a negative
;               reddening, and thus a reddening of 0 is returned. This
;               clipping functionality is only used when the pg10
;               keyword is set, not when MAP='PG10' (see PG10, Section 5.)               
; 
; OUTPUTS:
;   value:      Value(s) from Lambert-projection maps.
;
; COMMENTS:
;   These data are based upon the following paper:
;   "Maps of Dust IR Emission for Use in Estimation of Reddening
;   and CMBR Foregrounds", Schlegel, D., Finkbeiner, D., & Davis, M.,
;   ApJ, 1998, 500, 525.
;
;   Further corrections based on "A Correction to the Standard
;   Galactic Reddening map: Passive Galaxies as Standard
;   Crayons", Peek, J. E. G., Graves, G. J., ApJ, in press.
;   
;   Either the coordinates GALL and GALB must be set, or these coordinates
;   must exist in the file INFILE.  Output is written to the variable VALUE
;   and/or the file OUTFILE.
;
; EXAMPLES:
;   Read the reddening value E(B-V) at Galactic (l,b)=(12,+34.5), 
;   interpolating from the nearest 4 pixels, and return result in VALUE.
;   > value = dust_getval(12, 34.5, /interp)
;
;   Read the reddening value E(B-V) at Galactic (l,b)=(197,+68.1), 
;   interpolating from the nearest 4 pixels, including the Peek and
;   Graves correction, and return result in VALUE.
;   > value = dust_getval(197, 68.1, /interp, /pg10)
;
;   Read the temperature map at positions listed in the file 'dave.in',
;   interpolating from the nearest 4 pixels, and output to file 'dave.out'.
;   The path name for the temperature maps is '/u/schlegel/'.
;   > value = dust_getval(map='T', ipath='/u/schlegel/', /interp, $
;     infile='dave.in', outfile='dave.out')
;
; DATA FILES FOR SFD MAPS:
;   SFD_dust_4096_ngp.fits
;   SFD_dust_4096_sgp.fits
;   SFD_i100_4096_ngp.fits
;   SFD_i100_4096_sgp.fits
;   SFD_mask_4096_ngp.fits
;   SFD_mask_4096_sgp.fits
;   SFD_temp_ngp.fits
;   SFD_temp_sgp.fits
;   SFD_xmap_ngp.fits
;   SFD_xmap_sgp.fits
;
; DATA FILES FOR BH MAPS:
;   hinorth.dat
;   hisouth.dat
;   rednorth.dat
;   redsouth.dat
;
; PROCEDURES CALLED:
;   bh_rdfort()
;   djs_int2bin()
;   readcol
;   wcs_getval()
;
; REVISION HISTORY:
;   25-Sep-1997  Written by David Schlegel, Durham
;   19-Jan-1998  DJS - Modified for general release.
;   30-Mar-1998  DJS - Modified to read SGP mask file for b<0, since it was
;                incorrectly reading the NGP mask.
;   19-May-1998  DJS - Subscripts modified to IDL 5 convention.
;   30-Jul-1998  DJS - Added default file path names for any users at Princeton
;                or at Berkeley.
;   18-Mar-1999  DJS - Allow call with GALL=0 or GALB=0.
;   31-Mar-1999  DJS - Modified to use wcs_getval() instead of lambert_getval()
;   20-Apr-2010  JEGP - Modified to allow PG10 corrections with new keywords
;-
;------------------------------------------------------------------------------
function dust_getval, gall, galb, infile=infile, skipline=skipline, $
 outfile=outfile, map=map_in, interp=interp_in, noloop=noloop, $
 verbose=verbose, ipath=ipath, bhpath=bhpath, pg10=pg10, corrpg10=corrpg10

   if (NOT keyword_set(infile) $
    AND (N_elements(gall) EQ 0 AND N_elements(galb) EQ 0) $
    ) then begin
      print, 'Must set either coordinates or INFILE'
      return, -1
   endif

   bitnames = [ $
    [ '' , '' ], $
    [ '' , '' ], $
    [ 'OK     ' , 'asteroi' ], $
    [ 'OK     ' , 'glitch ' ], $
    [ 'OK     ' , 'source ' ], $
    [ 'OK     ' , 'no_list' ], $
    [ 'OK     ' , 'big_obj' ], $
    [ 'OK     ' , 'no_IRAS' ] ]

   ; Convert map name to upper case; default to Ebv
   if keyword_set(map_in) then map = strupcase(map_in) else map = 'EBV'

   if keyword_set(interp_in) then interp = interp_in
   if (map EQ 'MASK') then interp=0B

   ; If INFILE is defined, then read galactic coordinates from that file
   if (keyword_set(infile)) then $
    readcol, infile, gall, galb, format='F,F', skipline=skipline

   if keyword_set(ipath) then begin
       dum = findfile(ipath+'SFD*.fits', count=ct)
       if (ct EQ 0) then begin
           message, 'Bad file path!'
           return, -1
       endif
   endif
        
   if (NOT keyword_set(ipath)) then begin
      dust_dir = getenv('DUST_DIR')
      if (dust_dir NE '') then ipath = dust_dir+'/maps/' $
       else ipath = './'
   endif
   dum = findfile(ipath+'SFD*.fits', count=ct)
   if (ct EQ 0) then begin
       message, 'No data files found in path'
       return, -1
   endif

   if (map EQ 'BH' AND NOT keyword_set(bhpath)) then begin
      spawn, '\arch', arch
      case arch[N_elements(arch)-1] of
         'sun4': bhpath = dust_dir+'/BHdat.sun4/'
         'i686': bhpath = dust_dir+'/BHdat.i686/'
         else:   bhpath = './'
      endcase
   endif

   case strupcase(map) of
   'BH': begin
;      value = wcs_getval(['bhngp.fits', 'bhsgp.fits'], $
;               gall, galb, path=bhpath, interp=interp, $
;               noloop=noloop, verbose=verbose)
      value = bh_rdfort( gall, galb, bhpath=bhpath )
      end
   'I100': begin
      value = wcs_getval( $
       ['SFD_i100_4096_ngp.fits', 'SFD_i100_4096_sgp.fits'], $
       gall, galb, path=ipath, interp=interp, noloop=noloop, verbose=verbose)
      end
   'X': begin
      value = wcs_getval( $
       ['SFD_xmap_ngp.fits', 'SFD_xmap_sgp.fits'], $
       gall, galb, path=ipath, interp=interp, noloop=noloop, verbose=verbose)
      end
   'T': begin
      value = wcs_getval( $
       ['SFD_temp_ngp.fits', 'SFD_temp_sgp.fits'], $
       gall, galb, path=ipath, interp=interp, noloop=noloop, verbose=verbose)
      end
   'IX': begin
      value = wcs_getval( $
       ['SFD_dust_4096_ngp.fits', 'SFD_dust_4096_sgp.fits'], $
       gall, galb, path=ipath, interp=interp, noloop=noloop, verbose=verbose)
      value = value / 0.0184
      end
   'EBV': begin
      value = wcs_getval( $
       ['SFD_dust_4096_ngp.fits', 'SFD_dust_4096_sgp.fits'], $
       gall, galb, path=ipath, interp=interp, noloop=noloop, verbose=verbose)
      if keyword_set(pg10) then begin
         vpg10 = fltarr(n_elements(galb))
         corrpg10 = fltarr(n_elements(galb))
         wh = where(galb gt 0, ct)
         if ct gt 0 then begin
            pg10value = wcs_getval(['PG_dust_4096_ngp.fits', 'null'], gall[wh], galb[wh], path=ipath, interp=interp, noloop=noloop, verbose=verbose)
            whf = where(finite(pg10value) eq 1, whfct)
            if (whfct gt 0) then begin
               vpg10[wh[whf]] = pg10value[whf]
               corrpg10[wh[whf]] = 2 - ((value[whf] + pg10value[whf]) ge 0)
            endif
            value = (value + vpg10) > 0.
         endif
      endif
      end
   'MASK': begin
      value = wcs_getval( $
       ['SFD_mask_4096_ngp.fits', 'SFD_mask_4096_sgp.fits'], $
       gall, galb, path=ipath, interp=interp, noloop=noloop, verbose=verbose)
      end
   'PG10': begin
      value = fltarr(n_elements(galb))
      corrpg10 = fltarr(n_elements(galb))
      wh = where(galb gt 0, ct)
      if ct gt 0 then begin
         pg10value = wcs_getval( ['PG_dust_4096_ngp.fits', 'null'], gall[wh], galb[wh], path=ipath, interp=interp, noloop=noloop, verbose=verbose)
         whf = where(finite(pg10value) eq 1, whfct)
         if (whfct gt 0) then begin
            value[wh[whf]] = pg10value[whf]
            corrpg10[wh[whf]] = 1.
         endif
      endif
   end
   'ERR': begin
      value = fltarr(n_elements(galb))
      corrpg10 = fltarr(n_elements(galb))
      wh = where(galb gt 0, ct)
      if ct gt 0 then begin
         pg10value = wcs_getval( ['PG_err_4096_ngp.fits', 'null'], gall[wh], galb[wh], path=ipath, interp=interp, noloop=noloop, verbose=verbose)
         whf = where(finite(pg10value) eq 1, whfct)
         if (whfct gt 0) then begin
            value[wh[whf]] = pg10value[whf]
            corrpg10[wh[whf]] = 1.
         endif
      endif
   end
 
   else: begin
      message, 'Valid map names: Ebv, BH, I100, X, T, IX, mask, PG10, Err'
      end
   endcase

   ; If OUTFILE is defined, then write to output file
   if (keyword_set(outfile)) then begin
      get_lun, olun
      openw, olun, outfile
      if (map EQ 'MASK') then begin
         for igal=0, N_elements(gall)-1 do begin
            bits = djs_int2bin(value[igal],ndigit=8)
            printf, olun, format='(f8.3,f8.3,7a8)', $
             gall[igal], galb[igal], $
             strcompress(string(bits[0]+2*bits[1])+'hcons'), $
             bitnames[indgen(6)*2+4+bits[2:7]]
         endfor
      endif else begin
         for igal=0, N_elements(gall)-1 do begin
            printf, olun, format='(f8.3,f8.3,f12.5)', $
             gall[igal], galb[igal], value[igal]
         endfor
      endelse
      close, olun
      free_lun, olun
   endif

   return, value
end
;------------------------------------------------------------------------------

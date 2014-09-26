;+
; NAME:
;   IM_CONVOLVE_SFH()
;
; PURPOSE:
;   Convolve an SSP with an arbitrary star formation history. 
;
; INPUTS: 
;   ssp - structure describing the SSP grid:
;     age  - age vector (yr) [NAGE]
;     wave - wavelength vector [NPIX]
;     flux - flux vector [NPIX,NAGE]
;   sfh - star formation rate at each TIME (Msun/yr) [NSFH]
;   time - time vector corresponding to SFH (Gyr) [NSFH] 
;
; OPTIONAL INPUTS:
;   mstar - stellar mass of the SSP with time [NAGE]
;
; OPTIONAL OUTPUTS:
;   cspmstar - stellar mass of the CSP with time [NSFH]
;
; KEYWORD PARAMETERS: 
;
; OUTPUTS: 
;   cspflux - time-dependent spectra of the composite stellar
;     population (CSP) [NPIX,NSFH]
;
; COMMENTS:
;
; EXAMPLES:
;
; MODIFICATION HISTORY:
;   J. Moustakas, 2011 Jan 20, UCSD - written, with input from
;     C. Tremonti and A. Diamond-Stanic
;
; Copyright (C) 2011, John Moustakas
; 
; This program is free software; you can redistribute it and/or modify 
; it under the terms of the GNU General Public License as published by 
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version. 
; 
; This program is distributed in the hope that it will be useful, but 
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; General Public License for more details. 
;-

function im_convolve_sfh, ssp, sfh=sfh, time=time, mstar=mstar, $
  cspmstar=cspmstar, mgalaxy = mgalaxy, age_wm = age_wm, age_wr = age_wr

    if (n_elements(ssp) eq 0L) then begin
       doc_library, 'im_convolve_sfh'
       return, -1
    endif

    if (tag_indx(ssp,'age') eq -1) or (tag_indx(ssp,'wave') eq -1) or $
      (tag_indx(ssp,'flux') eq -1) then begin
       splog, 'Incompatible SSP structure format'
       return, -1
    endif

; check for the SFH
    nsfh = n_elements(sfh)
    if (nsfh eq 0) or (n_elements(time) eq 0) then begin
       splog, 'SFH and TIME inputs required'
       return, -1
    endif
    if (nsfh ne n_elements(time)) then begin
       splog, 'Incompatible dimensions of SFH and TIME'
       return, -1
    endif

    npix = n_elements(ssp.wave)

; check for other quantities to convolve
    nmstar = n_elements(mstar)
    if (nmstar ne 0) then begin
       if (nmstar ne n_elements(ssp.age)) then begin
          splog, 'Dimensions of MSTAR and SSP.AGE do not agree'
          return, -1
       endif
    endif
    
    if (min(ssp.age) eq 0) then begin
       indx_age = where(ssp.age/1.d9 lt max(time))
       age = [ssp.age[indx_age]/1.d9, max(time)]
    endif else begin
       indx_age = where(ssp.age/1.d9 lt max(time))
       age = [0.D, ssp.age[indx_age]/1.d9, max(time)]
    endelse
    nthistime = n_elements(age)
    
    thistime = abs(reverse(max(time)-(age-min(age)))) ; avoid negative roundoff
    iindx = findex(time,thistime)
    thissfh = interpolate(sfh,iindx) ; [Msun/yr]
    sspindx = findex(ssp.age,reverse(age)*1D9)
    isspflux = interpolate(ssp.flux,sspindx,/grid)
    dth = (shift(thistime,-1) - thistime)/2.
    dth[nthistime-1] = 0. 
    dtl = (thistime - shift(thistime,+1))/2.
    dtl[0] = 0.
    t1 = thistime - dtl
    t2 = thistime + dth
       
    for jj = 0, n_elements(thistime)-1 do begin
       bin = where(time ge t1[jj] and time le t2[jj], nbin)
       if nbin le 1 then continue
       mass_inbin = im_integral(time, sfh, t1[jj], t2[jj])
       thissfh[jj] = mass_inbin/(t2[jj]-t1[jj])
    endfor

; do the convolution integral       
       dt = (shift(thistime,-1)-shift(thistime,+1))/2.0
       dt[0] = (thistime[1]-thistime[0])/2.0
       dt[nthistime-1] = (thistime[nthistime-1]-$
         thistime[nthistime-2])/2.0

       weight = thissfh*dt*1D9 ; [Msun]
       vweight = rebin(reform(weight,1,nthistime),npix,nthistime)
       cspflux = total(isspflux*vweight,2,/double)

; compute the output stellar mass
       if (nmstar gt 0) then cspmstar = $
         total(interpolate(mstar,sspindx)*weight,/double)
         
;*************************************************       
;         indpsb = where(thistime ge max(time)-2)
;         aaa = interpolate(mstar,sspindx)
;         csppsb = total(aaa[indpsb]*weight[indpsb],/double)
; print,cspmstar,csppsb
;         fracpsb = csppsb
;**************************************************       

       mgalaxy = total(weight) 
;   splog, systime(1)-t0
       cspflux = cspflux/cspmstar

    age_wm = total(interpolate(mstar,sspindx)*weight * interpolate(ssp.age,sspindx))/total(interpolate(mstar,sspindx)*weight)
    indr = where(ssp.wave ge 5000.-100. and ssp.wave le 5000.+100.)
    rlum = TOTAL(isspflux[indr,*],1,/nan) / double(n_elements(indr))
    age_wr = total(rlum*weight * interpolate(ssp.age,sspindx))/total(rlum*weight)
    
return, cspflux
end


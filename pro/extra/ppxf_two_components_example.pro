;#############################################################################
;
; Usage example for the procedure PPXF, which
; implements the Penalized Pixel-Fitting (pPXF) method by
; Cappellari M., & Emsellem E., 2004, PASP, 116, 138.
; 
; This example shows how to fit multiple stellar components with different
; stellar population and kinematics.
; 
; MODIFICATION HISTORY:
;   V1.0: Early test version. Michele Cappellari, Oxford, 20 July 2009
;   V1.1: Cleaned up for the paper by Johnston et al. (MNRAS, 2013).
;       MC, Oxford, 26 January 2012
;   V1.2: Adapted to the changes in the new public PPXF version. 
;       MC, Oxford 8 January 2014
;       
;#############################################################################
pro ppxf_two_components_example

velscale = 30d

fits_read, 'spectra/Rbi1.30z+0.00t12.59.fits', ssp, h ; Solar metallicitly, Age=12.59 Gyr
lamRange = sxpar(h,'CRVAL1') + [0d,sxpar(h,'CDELT1')*(sxpar(h,'NAXIS1')-1d)]
log_rebin, lamRange, ssp, model1, VELSCALE=velScale
model1 /= median(model1)

fits_read, 'spectra/Rbi1.30z+0.00t01.00.fits', ssp, h ; Solar metallicitly, Age=12.59 Gyr
lamRange = sxpar(h,'CRVAL1') + [0d,sxpar(h,'CDELT1')*(sxpar(h,'NAXIS1')-1d)]
log_rebin, lamRange, ssp, model2, VELSCALE=velScale
model2 /= median(model2)

model = [[model1],[model2]]
galaxy = model

; These are the input values for the (V,sigma)
; of the two kinematic components
;
vel = [0d, 250d]/velScale
sigma = [200d, 100d]/velScale

; The synthetic galaxy model consists of the sum of two
; SSP spectra with age of 1Gyr and 13Gyr respectively
; with different velocity and dispersion
;
for j=0,n_elements(vel)-1 do begin
    dx = ceil(abs(vel[j])+4.*sigma[j]) ; Sample the Gaussian at least to vel+4*sigma
    v = cap_range(dx,-dx,2*dx+1)
    losvd = exp(-0.5*((v - vel[j])/sigma[j])^2) ; Gaussian LOSVD
    losvd /= total(losvd) ; normaize LOSVD
    galaxy[*,j] = convol(model[*,j],losvd,/EDGE_TRUNCATE)
    galaxy[*,j] /= median(model[*,j])
endfor
galaxy = total(galaxy, 2)
sn = 200d
npix = n_elements(galaxy)
seed = 123 ; for reproducible results
galaxy += randomn(seed,npix)*galaxy/sn
noise = galaxy*0 + median(galaxy)/sn

; Adopts two templates per kinematic component
;
templates = [[model1], [model2], [model1], [model2]]

; Start both kinematic components from the same guess.
; With multiple stellar kinematic components
; a good starting guess is essential
;
start = [mean(vel),mean(sigma)]*velscale
start = [[start],[start]]
goodPixels = cap_range(20,1280)

!p.MULTI=[0,1,2]
print, "+++++++++++++++++++++++++++++++++++++++++++++"
ppxf, templates, galaxy, noise, velScale, start, sol, $
    GOODPIXELS=goodPixels, /PLOT, MOMENTS=[4,4], DEGREE=4, COMPONENT=[0,0,1,1], $
    TITLE='Two components pPXF fit'
print, "---------------------------------------------"
start = start[*,0]
ppxf, templates, galaxy, noise, velScale, start, sol, $
    GOODPIXELS=goodPixels, /PLOT, MOMENTS=4, DEGREE=4, $
    TITLE='Single components pPXF fit'
print, "============================================="    
!p.MULTI=0
             
end
;------------------------------------------------------------------------------

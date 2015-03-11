# Test on Galaxies with z<0.07

###    

### Preparation of the pipeline: 

 + 09-07: Revise the hs_coadd_sdss_spec.pro 
   - Slightly modify the requirement for the input list. Now it just need a list 
     of names of _hs version of SDSS spectra (the output of hs_prepare_sdss_spec.pro
   - Includes random error of velocity dispersion
   - Correct the error in convolving spectra to certain velocity dispersion
   - Includes outputs for STARLIGHT and ULyss
   - Adjust the method of polynomial-continuum fitting; add npoly as a free 
     parameter
 + 09-07: Revise the hs_prepare_sdss_spec.pro 
   - Add the optional keywords: /CCM and /ODL --> select the model used for 
     Galactic extinction correction between the CCM and ODonnel models 
   - Fix the problem with output file for ULyss 
   - Add an optional output file for STARLIGHT v4
 + 09-11: Adjust hs_coadd_sdss_spec.pro 
   - The output file for STARLIGHT gives weird results. Try fix it!
     Change the way to feed "error" to STARLIGHT
   - Add output to EZ_Ages 
   - Put information about the stacking, like n_spec, csigma, n_boot, n_poly..
     into the header of the _coadd.fits output
   - Add the final_spec_poly and final_used/n_spec to the _coadd.fits file
 + 09-11: Adjust hs_prepare_sdss_spec.pro 
   - Slightly modify the output for STARLIGHT
   - Add output to EZ_Ages
 + 09-11: Prepare the hs_spec_diff_plot.pro 
 + 09-12: hs_spec_diff_plot.pro 
   - Use fraction of total spectra used in the stacking as criteria to mask out 
     pixels
 + 09-12: hs_coadd_sdss_spec.pro 
   - Forgot to add the header into the output of _coadd.fits file! Correct it
 + 09-12: hs_specfeature_list.pro 
   - Create a .fits file for interesting spectral features
 + 09-14: Since SDSS has released DR10 data, re-do the sample selection for 
          both SDSS and BOSS sample 
   - Download the newly released anciliary data from Portsmouth, Wisconsin, and 
     Granada group 
   - In the new sample, use H0=70; Omega_m=0.274; Omega_Lambda=0.726 
   - The redshift range is 0.001-0.230 
   - The velocity dispersion range is 150.0 to 380.0
   - The MPA/JHU VAGC has been updated to SDSS DR8
 + 09-15: hs_specfeature_list.pro 
   - Updated; All Lick Index and useful index for IMF diagnose have been added
 + 09-15: hs_coadd_sdss_spec.pro 
   - Includes the finsal signal-to-noise ratio spectrum in the plot 
   - Overplot spectral features 
   - Slightly modifies the layout of the plot

### Note about softwares 
 
 + STARLIGHT v4: 
  - Many options to be explored in the config file, including the method of 
    pixel clipping which seems to influence our fitting significantly.  Until 
    now, the STARLIGHT run on our co-added spectra only generate useful results 
    when the error and flags are ignored. 
  - 

 + EZ_AGES: 
  - In principle, LICK_EW can be used to measure any line index. however, the 
    value of spectral resolution (in unit of angrstrom) is necessary.  For index 
    other than the Lick index, check the new LIS system by the MILES/MIUSCAT 
    group.  
  - EZ_AGES have different choice of isochrone and IMF form.  For our massive 
    ETGs, the measured index often lie ourside the model grids based on 
    solar [alpha/Fe] value and Salpeter IMF. 
  - Need to check the papers by Graves

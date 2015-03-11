# Sample Selection for Spectra Stacking Analysis 

## The Working Sample  

This is the attempt to define a more complete and better constrained sample of 
nearby galaxies for the study of their average stellar population properties 
through spectral stacking technique.  The sample is defined on the most recent 
data release of SDSS, which is DR10.  The new release adopts all SDSS spectra 
data from the last release (DR8), and newly released BOSS spectra (in total of 
1515,000 spectra).  All these spectra have been reduced using a improved  
pipeline.  Also, a series of measured properties, including stellar mass 
estimations, are provided in the DR10 database.  The details about these 
derived properties will be discussed later.  

First, a large "working" sample has been estabished by the following criteria: 

-------------------------------------------------------------------------------
where e.redshift between 0.001 and 0.205
  and s.z between 0.001 and 0.210
  and e.sigmastars between 130 and 360
  and (s.zErr/s.z)<0.02
  and s.zWarning = 0
  and s.survey = 'sdss'  ; or s.survey = 'boss'
-------------------------------------------------------------------------------

In this begining phase of the sample selection, very generous criteria in 
redshift and stellar velocity dispersion has been applied to ensure the 
inclusion of all spectra of interest.  For stellar velocity dispersion, the 
newly released value from the Portmouth group, which is derived using pPXF code, 
has been adopted.  Although the pPXF measurements are shown to be in satisfied 
agreement with the SDSS ones for DR7 sample (Thomas+2013), we are inclined to 
believe that pPXF kinematic fitting with a well-defined stellar population model 
library does provide potential improment.  The details about these different 
measurements will be discussed later.  Standard rules are also used to exclude 
spectra with troublesome redshift estimation. 

The application of the above standards results in 319082 spectra from 'SDSS' 
survey, and 27859 spectra from 'BOSS' survey.  At the current stage, only SDSS 
spectra are considered.  Within the framework of SDSS database, the selected 
galaxies have been cross-matched with all possible internal catlog, including 
the SDSS spectroscopic and photometric information, derived properties from the 
MPA/JHU, Portmouth, and Wisconsin group, and the GalaxyZoo data release, using 
the DR8 version of SpecobjID.  All these data have been retrieved from CasJobs.  

### Initial preparation 

+ First, the luminosity distance, look-back time, angular diameter distance, and 
  the physical scale per arc sec are deduced based on SDSS spectroscopic 
  redshift and the assumption of cosmological parameters.  Through out the whole 
  project, h0=0.71, \Omega_M=0.264, \Omega_\Lambda=0.736 have been adopted.  

+ The difference between the central coordinates of the galaxy and the central 
  coordinates of the fiber is quantified using: 
  ( RA/Dec_fiber - RA/Dec_gal ) / ( RA/DecErr_gal ) 
  The result is reassuring.  Such difference, even when presents, is way too 
  small to be a problem. 

+ The Petrosian 50% radius (petroR50_r) and the effective radius from the 
  de Vaucouler profile fitting (devRad_r) have been transformed into physical 
  unit (kpc);  Meanwhile, the ratio between the angular radius and the 1.5 
  arc sec of the fiber radius has been calculated. 

+ Cross-match the basic information with additional data for DR8 spectra: 
   - MPA/JHU catalog/extra information: including BPT classification, gaseous 
     metallicity, stellar mass, star formation and sSFR. (all/319082)
   - GalaxyZoo catalog: morphological classification (284197/319082)  
   - Portsmouth Group/Stellar Mass: The stellar mass and metallicity are derived 
     from spectro-photometric fitting using two different sets of templates: 
     the Passive and Star-forming ones, with two different choices of IMF: 
     Salpeter and Kroupa.  For the purpose of simplicity, we only consider the 
     results from Passive templates and Salpeter IMF, since most of the galaxies 
     we are interested in this study should be early-type, quiescent galaxies. 
   - Portsmouth Group/Emission line measurements: The flux and EW of a series of 
     emission lines have been measured using the code GANDALF.
   - Wisconsin/PCA Spectra Analysis: Using the PCA method presented in 
     Chen+2010, the stellar mass and stellar velocity dispersion have been 
     estimated.  The analysis has been done using two different sets of 
     SSP templates the BC03, and the Maraston+2011 version.  At this point, only 
     results based on BC03 models are considered. 
   - Granada Group/FSPS Analys: Spectro-Photometric stellar mass has been  
     deduced from SED fitting with FSPS models with different assumptions: 
     EarlyForm and WildForm, With dust, and no dust.  
   - More information about the above data can be found at the SDSS webpage: 
     http://www.sdss3.org/dr10/spectro/galaxy.php

+ Exclude bad data: 
   - [SciencePrimary==1 && sdssPrimary==1] --> 318145/319082 
   - [class_spec_sdss == 'GALAXY' ]        --> 318141/319082 
   - [platequality_spec != 'bad'  ]        --> 316558/319082 
     ** If more stringent rule is applied, which means 
        platequality_spec == 'good', 227717/319082 is left in the sample 
   - [airmass_spec <= 1.50]                --> 313593/319082 
   - [seeing80_spec <= 2.80]               --> 303388/319082
     ** The condition during the spectral observation should not be too bad. 
        The FWHM of the seeing should not be too close to the size of the fiber. 
   - [clean_photo == 1]                    --> 255381/319082 
   - [score_photo >= 0.80]                 --> 240176/319082
     ** The photometric quality of these galaxies should also be constrained 
        since fundamental photometric properties like effective radius, optical 
        color, and axis ratio are useful to us. 
   - [ ABS( b_gal ) >= 10.0 ]              --> All galaxies fullfill this criteria
   - [ extinction_g <= 0.30 ]              --> 230971/319082 
     ** Request low extinction for these galaxies. 
   - [ (vdisp_err_ports / vdisp_ports) < 0.2 ] --> 228770/319082
     ** Reasonable error for pPXF measurements of stellar velocity dispersion
   - [ petroR50_r_kpc between 0.0 and 40.0 kpc]  --> 228759/319082 
   - [ devRad_r_kpc between 0.0 and 40.0 kpc]    --> 228685/319082 
   - [ petroR50Err_r/petroR50_r < 0.3 ]          --> 226075/319082
   - [ devRadErr_r/devRad_r < 0.3 ]              --> 226068/319082
   - After small adjustments, the current number is  226999/319082
     
Among all the selected SDSS spectra, 17520 out of 226999 (~76%) have SDSS DR7 
specobjID.  Considering that additional information about the structure, 
environmental, and stellar population properties are only available for the DR7 
release, this significant subset will be treated with special attention 
separately.  207358/226999 (91%) of these galaxies have useful morphological 
classifications from the data release of GalaxyZoo project. 

Also, 15622 (25536) galaxies with redshift smaller than 0.06 (0.07) have been 
isolated.  For these galaxies, the NaI 8190 Angstrom double lines are available 
within the wavelength coverage of SDSS spectra, so they constitute an important 
baseline for the study of average stellar population properties in different 
redshift and velocity dispersion bins.  We will explore this special sample in 
great details. 

### Low redshift subsample

To ensure the number of spectra in each velocity dispersion bins so the final 
stacked spectra could have sufficient signal-to-noise ratio around the features 
that are interesting to our purpose, the low-redshift sample defined by z<0.07 
is adopted. 

+ First, sample is binned according to their aperture-corrected stellar velocity 
  dispersion.  We conduct the aperture correction by following the recipe 
  provided in Cappellari+2006 which is based on spatial resolved stellar 
  kinematics of nearby early-type galaxie in SAURON survey: 
  \sigma_cor = \sigma * ( 8.0 * r_ap / r_e )^0.066, where r_ap = 1.5 arc sec 
  for SDSS spectragraph, the pPXF stellar kinematic measurements from Portsmouth 
  group are selected for \sigma_\asteroid.  As for the effective radius of the 
  galaxy, the Petrosian R50 and de Vaucouler radius from SDSS pipeline are both 
  adopted.  We calculate a series sets of correction values using these two 
  different estimations of effective radius, both the original and the 
  circulized ones (Re_c = Re * \ssqrt( b/a ) ).  Hyde \& Bernardi 2009 mentioned 
  that the factor for aperture correction for early-type galaxies could be 
  between 0.04 and 0.07, hence we also calculated another sets of corrections 
  using the lower bound of the factor.  Eventually, we adopted the correction 
  value based on circulized de Vaucouler effective radius with a correction 
  factor of 0.066.  The use of different group of correction value can result in 
  slightly different sample in each velocity dispersion bin, especially when the 
  lower correction factor (0.04) is adopted.  However, such difference leaves 
  almost no trace in any of our conclusions (XXX TODO: Quantify this!!). 

+ Second, the galaxies in the low-redshift subsample are distributed into 
  different bins according to their corrected velocity dispersion.  Considering 
  the typical error for stellar velocity dispersion measurements is around 
  10.0km/s, it is reasonable to use 20 km/s as the bin size.  Meanwhile, the 
  number of spectra that fall into certain bin need to be large enough to ensure 
  a sufficient signal-to-noise ratio, so when necessay, the bin size will be 
  increased to 30 km/s.  This only applies to bins of very high velocity 
  dispersion.  After the aperture correction, the velocity dispersion value 
  systematically increases, hence the lowest velocity dispersion value for 
  stacking is set at 140 km/s 

+ To ensure that the specific definition of the velocity dispersion bins will 
  not affect the results, a second sets of bins are defined using a slightly 
  different lower and upper value of velocity dispersion.  From the starting 
  point, the lower bound of each bin gradually increases by 10.0 km/s.  The rest 
  of the criteria are exactly the same 

+ Besides velocity dispersion, extra constraints are considered to ensure that 
  most galaxies in each bins are bona fide early-type and/or passive galaxies. 
  These criteria normaly includes morphological classification, status of 
  current star-formation, AGN activity, et al.  There are a lot of options to 
  be explored based on the available value-added data for SDSS galaxies.  As the 
  first step, we start with a rather general standard to isolated early-type, 
  passive galaxies using the following criteria: 

     - fracDev_r > 0.8       --> Early-type like 
     - devAB_r > 0.4         --> Excludes possible highly-inclined discs 
     - sfr_tot_mpa < 3.0     --> Low current star formation rate 
     - specsfr_tot_mpa < 3.0 --> Same with above 
     - bpt_ports != 'Star Forming' and 'Seyfert' and 'Seyfert/LINER'
     *** The above criteria will be called as "basic" in the following studies

  ** sigma_bin         num     after_basic    median SN_r/Q10 
     [140.0,160.0]    5171    2975 lowz_s1a      35.2/24.9 
     [160.0,180.0]    5720    4005 lowz_s2a      35.2/25.1
     [180.0,200.0]    4401    3368 lowz_s3a      37.2/27.0
     [200.0,220.0]    3301    2735 lowz_s4a      39.0/28.8
     [220.0,240.0]    2436    2127 lowz_s5a      40.4/30.6
     [240.0,260.0]    1671    1484 lowz_s6a      41.7/32.0
     [260.0,280.0]    1028     935 lowz_s7a      43.0/33.9
     [280.0,300.0]     567     521 lowz_s8a      44.4/34.6
     [300.0,330.0]     403     363 lowz_s9a      45.0/37.0
  ** sigma_bin         num     after_basic  
     [150.0,170.0]    5999    3891 lowz_s1b      34.4/26.6
     [170.0,190.0]    5072    3729 lowz_s2b      36.4/26.1
     [190.0,210.0]    3882    3095 lowz_s3b      38.0/28.2 
     [210.0,230.0]    2860    2456 lowz_s4b      39.9/29.4
     [230.0,250.0]    2017    1768 lowz_s5b      41.0/30.7
     [250.0,270.0]    1342    1197 lowz_s6b      42.3/33.6
     [270.0,290.0]     759     707 lowz_s7b      44.0/34.2
     [290.0,320.0]     558     503 lowz_s8b      45.0/36.2
     
     - The co-added spectra and the associated files have been generated for the 
       above sample. 

+ Meanwhile, more stringent rules can be used to further "purify" the sample. 
  First, we could request useful stellar mass estimation using the PCA method 
  by the Wisconsin group.  Among many stellar mass estimations for these 
  galaxies, this method is based on full spectral information.  The comparison 
  between PCA-based stellar mass and the spectro-photometric based MPA/JHU total 
  stellar mass shows reassuring consistency.  The Wisconsin group provides the 
  stellar mass estimations based on two different templates: the BC03/CB07 
  version and the M11 version.  For reasons we will discuss later in details, 
  we adopt the ones based on CB07.  Second, the S/N ratio within each bins can 
  be slightly improved by removing the spectra in the lowest 10% quartile of 
  all galaxies in that velocity dispersion bin.  Although this will lead to 
  smaller number of galaxies used in the stacking, it will not hurt the final 
  co-added spectra since the median S/N within each bin also increases, and the 
  spectra with the worst quality have been removed. 

      - logm_pca between [ 9.0, 13.0 ]    --> Reasonable stellar mass estimation 
      - snMedian_r_spec > snMedian_r_Q10  --> Remove about 10% spectra with low S/N

  ** sigma_bin       num           <S/N_r>  <Mass>/sigma  <R_petro>   <R_dev>
     [140.0,160.0]  2674  lowz_s1c  36.3     10.77/0.25   2.55/1.44  3.23/2.29
     [160.0,180.0]  3596  lowz_s2c  36.3     10.81/0.26   2.42/1.47  3.03/2.23
     [180.0,200.0]  3031  lowz_s3c  38.4     10.92/0.26   2.65/1.49  3.31/2.15 
     [200.0,220.0]  2455  lowz_s4c  40.1     11.00/0.26   2.74/1.55  3.49/2.11
     [220.0,240.0]  1913  lowz_s5c  41.3     11.10/0.26   2.99/1.58  3.77/2.15 
     [240.0,260.0]  1365  lowz_s6c  42.5     11.16/0.26   3.13/1.66  4.03/2.23 
     [260.0,280.0]   857  lowz_s7c  43.6     11.24/0.27   3.24/1.81  4.30/2.32
     [280.0,300.0]   472  lowz_s8c  45.0     11.32/0.25   3.58/1.83  4.66/2.46 
     [300.0,340.0]   376  lowz_s9c  45.4     11.40/0.25   3.84/1.96  4.85/2.40 
  ** sigma_bin       num  r_basic 
     [150.0,170.0]  3277  lowz_s1d  36.3     10.78/0.25   2.43/1.41  3.03/2.18 
     [170.0,190.0]  3352  lowz_s2d  37.6     10.87/0.26   2.53/1.50  3.15/2.24 
     [190.0,210.0]  2781  lowz_s3d  38.9     10.96/0.26   2.68/1.48  3.38/2.11
     [210.0,230.0]  2206  lowz_s4d  40.9     11.05/0.26   2.84/1.59  3.59/2.13
     [230.0,250.0]  1590  lowz_s5d  42.0     11.13/0.26   3.05/1.64  3.94/2.19
     [250.0,270.0]  1095  lowz_s6d  43.1     11.21/0.26   3.22/1.70  4.13/2.29
     [270.0,290.0]   640  lowz_s7d  44.6     11.28/0.26   3.37/1.83  4.45/2.26
     [290.0,330.0]   523  lowz_s8d  45.3     11.39/0.25   3.80/1.94  4.85/2.48

+ Morphological classification different than simple fracDev can be obtained 
  using the GalaxyZoo data release.  For these relative nearby galaxies, 
  visual inspection can still be considered as the most reliable morphological 
  diagnose.  Most galaxies in our sample got in total of more than 10 votes 
  from GalaxyZoo.  The purpose of this selection is try to isolate true early 
  type, preferably elliptical or pure spheroidal, galaxies.  However, even with 
  the help of the best crowd-sourse visual inspection system, there is still no 
  clear criteria to eliminate contamination and increase completness.  In 
  GalaxyZoo, the votes from users have been summarized and debiased into the 
  probablity that certain galaxy belongs to the category of elliptical, spiral, 
  merger, and unknown system.  We only consider the debiased possibility for 
  elliptical class (p_el_debiased).  To be conservative enough at the current 
  point, we choose to use a rather loose boundary to separate early- and late-
  type galaxies: p_el_debiased = 0.7.  Based on the comparison with parameters 
  like fracDev, concentration index, and classification using machine-learning 
  technique by other group (Morphology2010), we are confident that such criteria 
  can effectively include most of the intrinsic early-type galaxies.  The 
  details about these comparisons, and further discussion of this standard will 
  be mentioned later. 
  
+ Meanwhile, for the purpose of comparison, the "late-type" galaxies from this 
  selection will not be excluded.  For the relative low velocity dispersion bins 
  (\sigma_{\asteroid} < 270.0 km/s), these galaxies are summarized into another 
  set of sub-samples.  Coadded spectra will also be generated for them

  ** sigma_bin       num  p_el>0.7     p_el<0.7        
     [140.0,160.0]  1423  lowz_s1e     2232  lowz_s1g 
     [160.0,180.0]  2107  lowz_s2e     2162  lowz_s2g
     [180.0,200.0]  2016  lowz_s3e     1412  lowz_s3g
     [200.0,220.0]  1805  lowz_s4e      901  lowz_s4g
     [220.0,240.0]  1533  lowz_s5e      550  lowz_s5g
     [240.0,260.0]  1136  lowz_s6e      305  lowz_s6g
     [260.0,280.0]   745  lowz_s7e 
     [280.0,300.0]   419  lowz_s8e  
     [300.0,340.0]   342  lowz_s9e  
  ** sigma_bin       num  r_basic 
     [150.0,170.0]  1925  lowz_s1f     2427  lowz_s1h 
     [170.0,190.0]  2107  lowz_s2f     1752  lowz_s2h
     [190.0,210.0]  1961  lowz_s3f     1146  lowz_s3h
     [210.0,230.0]  1696  lowz_s4f      719  lowz_s4h
     [230.0,250.0]  1314  lowz_s5f      410  lowz_s5h
     [250.0,270.0]   940  lowz_s6f      223  lowz_s6h
     [270.0,290.0]   562  lowz_s7f 
     [290.0,330.0]   477  lowz_s8f 

  ** The sub-samples for p_el < 0.7 need to be re-run 

+ At the same time, certain criteria related to the size of the galaxy need to 
  be taken into consideration.  Since the size of galaxy displays a large 
  scatter within each of the stellar velocity dispersion bins, to make sure that 
  the fixed SDSS fiber size does capture different fraction of the same 
  population of galaxies at different redshift bins, we exclude all the galaxies 
  that lay outside the 1st and 3rd quartile of the size ditribution.  And the 
  same lower and upper size boundary for each velocity dispersion bin will be 
  applied to high-z galaxies.  Here, the circulized Petrosian R50 is selected to  
  represent the effective radius of the galaxy.  Although it may not be the best 
  or unbiased proxy for galaxy size, it can be reliably obtained through SDSS 
  pipeline for the whole sample, and it can reproduce the known scaling 
  relations for early-type galaxies. 

  ** Using petroR50Cir_kpc_r
  ** sigma_bin      index     r Q10/LQ/Median/UQ/Q90     logm  
     [150.0,170.0] lowz_s1b  1.10/1.45/1.98/2.68/3.71  10.40/10.57/10.75/10.91/11.08
     [170.0,190.0] lowz_s2b  1.10/1.45/2.05/2.91/3.99  10.44/10.64/10.84/11.02/11.17 
     [190.0,210.0] lowz_s3b  1.14/1.53/2.18/3.04/4.18  10.55/10.74/10.93/11.11/11.26
     [210.0,230.0] lowz_s4b  1.15/1.56/2.29/3.25/4.27  10.61/10.82/11.02/11.19/11.33 
     [230.0,250.0] lowz_s5b  1.13/1.64/2.47/3.58/4.60  10.68/10.88/11.10/11.27/11.40
     [250.0,270.0] lowz_s6b  1.25/1.81/2.66/3.67/5.03  10.77/10.98/11.18/11.35/11.50 
     [270.0,290.0] lowz_s7b  1.23/1.84/2.70/3.93/5.23  10.82/11.05/11.25/11.42/11.54
     [290.0,320.0] lowz_s8b  1.34/2.06/3.09/4.16/5.57  10.91/11.16/11.35/11.51/11.63

+ For PetrosianR50Cir_kpc_r,  p_el_zoo > 0.7
  ** sigma_bin     lowz_s     num  snmedian r50_kpc  r50_fib logm_pca sn_expect 
     [150.0,170.0] lowz_s1i  1040    35.10   1.96     1.51      10.74    1131  
     [170.0,190.0] lowz_s2i  1163    36.17   2.04     1.59      10.83    1233
     [190.0,210.0] lowz_s3i  1054    38.42   2.18     1.65      10.92    1233 
     [210.0,230.0] lowz_s4i   885    39.90   2.31     1.77      11.01    1190
     [230.0,250.0] lowz_s5i   702    41.13   2.47     1.89      11.09    1086
     [250.0,270.0] lowz_s6i   498    42.22   2.66     1.98      11.18     937
     [270.0,290.0] lowz_s7i   289    44.34   2.75     2.11      11.26     748 
     [290.0,320.0] lowz_s8i   254    45.08   3.17     2.29      11.37     717

+ For PetrosianR50Cir_kpc_r,  fracDev_r > 0.8
  ** sigma_bin     lowz_s     num  snmedian r50_kpc  r50_fib logm_pca sn_expect 
     [150.0,170.0] lowz_s1j  1945    34.08   1.98     1.53      10.75    1499     
     [170.0,190.0] lowz_s2j  1869    36.15   2.05     1.61      10.84    1556
     [190.0,210.0] lowz_s3j  1554    37.82   2.19     1.68      10.93    1458
     [210.0,230.0] lowz_s4j  1221    39.75   2.29     1.77      11.02    1362
     [230.0,250.0] lowz_s5j   920    41.25   2.44     1.89      11.10    1243
     [250.0,270.0] lowz_s6j   616    42.25   2.66     2.01      11.19    1042
     [270.0,290.0] lowz_s7j   357    44.38   2.73     2.08      11.26     831
     [290.0,320.0] lowz_s8j   303    45.11   3.07     2.23      11.35     783

+ SDSS pipeline provides another possible proxy of effective radius of galaxy,   
  which is the effective radius from either an exponential disk or n=4 
  de Vaucouler profile fit.  The advantage of this method compared with 
  Petrosian R50 is that the PSF smearing effect was taken into account during 
  the fitting.  However, the intrinsic complexity of the galaxy structure, 
  even for elliptical galaxies, could leave bias in size estimation which is 
  based on simple n=4 fitting.  From more detailed studies, it is known that 
  massive elliptical normally can not be well-described by a single-Sersic 
  component.  Even when free Sersic, single-component fitting is applied as an 
  approximation, the Sersic index of the resulting models not only show a 
  rather wide distribution, but also systematically depends on some basic 
  properties of the galaxy, like the total luminosity.  The possible bias 
  introduced by this oversimplification will be discussed later.  

  ** Using devRadCir_kpc_r                         
  ** sigma_bin       index    devrad 1Q/M/3Q  devRad_fib     
     [150.0,170.0]  lowz_s1b  1.69/2.42/3.46  1.40/2.00/3.07 
     [170.0,190.0]  lowz_s2b  1.73/2.51/3.68  1.42/2.11/3.18
     [190.0,210.0]  lowz_s3b  1.84/2.70/3.90  1.50/2.19/3.28
     [210.0,230.0]  lowz_s4b  1.92/2.91/4.16  1.58/2.34/3.47
     [230.0,250.0]  lowz_s5b  2.05/3.16/4.48  1.70/2.51/3.61
     [250.0,270.0]  lowz_s6b  2.32/3.42/4.75  1.86/2.61/3.72
     [270.0,290.0]  lowz_s7b  2.38/3.56/5.04  1.94/2.71/3.95 
     [290.0,320.0]  lowz_s8b  2.65/3.91/5.38  2.06/2.95/4.09

+ For p_el_zoo > 0.7
  ** sigma_bin     lowz_s     num  snmedian r50_kpc  r50_fib logm_pca sn_expect 
     [150.0,170.0] lowz_s1k  1073   35.94    2.35      1.90    10.75 
     [170.0,190.0] lowz_s2k  1153   37.39    2.49      2.01    10.84
     [190.0,210.0] lowz_s3k  1068   38.93    2.67      2.08    10.92  
     [210.0,230.0] lowz_s4k   894   40.45    2.93      2.27    11.02 
     [230.0,250.0] lowz_s5k   699   41.20    3.16      2.44    11.09
     [250.0,270.0] lowz_s6k   491   42.56    3.42      2.54    11.18
     [270.0,290.0] lowz_s7k   294   44.38    3.65      2.69    11.26
     [290.0,320.0] lowz_s8k   253   45.08    3.88      2.91    11.36

+ For fracDev_r > 0.8
  ** sigma_bin     lowz_s     num  snmedian r50_kpc  r50_fib logm_pca sn_expect 
     [150.0,170.0] lowz_s1l  1955   34.76    2.42      1.92    10.75   
     [170.0,190.0] lowz_s2l  1868   37.19    2.51      2.05    10.84
     [190.0,210.0] lowz_s3l  1555   38.56    2.70      2.12    10.93
     [210.0,230.0] lowz_s4l  1225   40.38    2.91      2.28    11.02
     [230.0,250.0] lowz_s5l   916   41.27    3.15      2.47    11.10 
     [250.0,270.0] lowz_s6l   618   42.64    3.42      2.56    11.19  
     [270.0,290.0] lowz_s7l   368   44.41    3.57      2.67    11.26
     [290.0,320.0] lowz_s8l   311   45.09    3.88      2.91    11.35


+ At redshift higher than 0.07, 155806 galaxies which fullfill the "useful" rule 
  can be selected.  Among them, 23343 (15%) have velocity dispersion higher than 
  270.0 km/s; 15711 (10%) are between 250.0 and 270.0 km/s; 19662 (13%) are 
  between 230.0 and 250.0 km/s; 22192 (14%) are between 210.0 and 230.0 km/s.  
  There are 63988 (41%) galaxies at redshift between 0.07 and 0.12 (56363 with 
  fracDev_r > 0.8; and 24916 have p_el_zoo > 0.7) ; 75500 (48%) galaxies at 
  redshift between 0.12 and 0.18 (65051 with fracDev_r > 0.8; and 26404 have 
  p_el_zoo > 0.7).  As we from low to higher and higher redshift, the sample 
  starts to become incomplete at the low velocity dispersion end.  Hence, we 
  will only consider the four highest velocity dispersion bins that go from 
  230.0 to 330.0 km/s.  The interval of each bin is exactly the same with the 
  low-redshift subsamples.  As for the definition of the redshift bins, we 
  require that: 1) there are enough number in each bin so the final 
  signal-to-noise ratio of the combined spctra is comparable to the ones for 
  low-redshift subsamples; 2) The average ratio between the petroR50_r and the 
  aperture size of SDSS fiber steadly decreases with redshift.  
  For this purpose, the high-z galaxies are grouped into two bins of redshift: 
  z1=[0.07,0.12] and z2=[0.12,0.18] .

  ** Use PetroR50Cir_kpc_r
  ** z    sigma     index     num  snmedian r50_kpc  r50_fib logm_pca sn_expect  
  ** z=[0.02,0.07]
     lowz [230,250] lowz_s5c   916   41.27    2.45     1.92    11.09     1246 
     lowz [250,270] lowz_s6c   618   42.64    2.66     2.02    11.18     1059
     lowz [270,290] lowz_s7c   368   44.41    2.71     2.10    11.26      852
     lowz [290,330] lowz_s8c   311   45.08    3.07     2.23    11.35      793
  ** z=[0.07,0.12]
     z1   [230,250]  z1_s5c   3721   26.64    2.60     1.17    11.06     1622 
     z1   [250,270]  z1_s6c   2248   28.27    2.81     1.24    11.15     1337
     z1   [270,290]  z1_s7c   1498   29.46    2.95     1.30    11.22     1137
     z1   [290,330]  z1_s8c   1042   31.52    3.07     1.34    11.31     1016
  ** z=[0.12,0.18]
     z2   [230,250]  z2_s5c   3412   19.84    3.04     1.00    11.15     1156
     z2   [250,270]  z2_s6c   2630   20.12    3.12     1.01    11.21     1030 
     z2   [270,290]  z2_s7c   2084   20.32    3.29     1.04    11.27      926
     z2   [290,330]  z2_s8c   2097   20.75    3.38     1.04    11.33      947


  ** Use devRadCir_kpc_r 
  ** z    sigma     index     num  snmedian r50_kpc  r50_fib logm_pca sn_expect  
  ** z=[0.02,0.07]
     lowz [230,250] lowz_s5c   916   41.27    3.15     2.47    11.09     1246 
     lowz [250,270] lowz_s6c   618   42.64    3.42     2.56    11.18     1059
     lowz [270,290] lowz_s7c   368   44.41    3.57     2.67    11.26      852
     lowz [290,330] lowz_s8c   311   45.08    3.88     2.92    11.35      793
  ** z=[0.07,0.12]
     z1   [230,250]  z1_s5d   3590   27.03    3.14     1.41    11.10     1617 
     z1   [250,270]  z1_s6d   2283   29.06    3.49     1.53    11.19     1385
     z1   [270,290]  z1_s7d   1494   30.27    3.67     1.62    11.26     1159
     z1   [290,330]  z1_s8d   1102   32.18    3.86     1.70    11.35     1062
  ** z=[0.12,0.18]
     z2   [230,250]  z2_s5d   5083   19.38    3.53     1.09    11.19     1375
     z2   [250,270]  z2_s6d   4105   19.73    3.74     1.14    11.26     1262
     z2   [270,290]  z2_s7d   3110   20.15    3.96     1.19    11.32     1120
     z2   [290,330]  z2_s8d   3116   20.83    4.08     1.20    11.39     1161

+ Try to use the ratio between the size estimation and the fiber size

  **  sigma    |       lowz       |        z1        |         z2          |
  ** PetroR50Cir_fiber
    [230,250]     1.07/1.66/2.41     0.85/1.14/1.52       0.88/1.06/1.31 
    [250,270]     1.20/1.74/2.47     0.91/1.24/1.67       0.89/1.09/1.36
    [270,290]     1.19/1.80/2.64     0.91/1.28/1.74       0.92/1.14/1.42
    [290,330]     1.29/1.97/2.83     0.95/1.34/1.88       0.92/1.15/1.48
  ** devRadCir_fiber 
    [230,250]     1.36/2.15/3.11     0.92/1.31/1.82       0.91/1.14/1.48
    [250,270]     1.53/2.27/3.16     1.00/1.43/2.01       0.92/1.18/1.53
    [270,290]     1.58/2.32/3.37     1.01/1.50/2.13       0.95/1.23/1.61
    [290,330]     1.70/2.50/3.56     1.08/1.59/2.25       0.95/1.26/1.67

  ** At z=0.020: 1 arcsec = 0.400 kpc ; 1.5 arcsec = 0.600 kpc
  ** At z=0.045: 1 arcsec = 0.873 kpc ; 1.5 arcsec = 1.310 kpc
  ** At z=0.070: 1 arcsec = 1.320 kpc ; 1.5 arcsec = 1.980 kpc
  ** At z=0.095: 1 arcsec = 1.741 kpc ; 1.5 arcsec = 2.611 kpc
  ** At z=0.120: 1 arcsec = 2.138 kpc ; 1.5 arcsec = 3.207 kpc
  ** At z=0.150: 1 arcsec = 2.585 kpc ; 1.5 arcsec = 3.878 kpc
  ** At z=0.180: 1 arcsec = 3.003 kpc ; 1.5 arcsec = 4.505 kpc

  ** Using devRadCir_kpc_r   redshift                   
  ** sigma_bin    index rad  0.020  0.045  0.070  0.095  0.120  0.150  0.180
     [150.0,170.0] s1b 2.42   4.03   1.85   1.22   0.93   0.75   0.62   0.54
     [170.0,190.0] s2b 2.51   4.18   1.92   1.27   0.96   0.78   0.65   0.56
     [190.0,210.0] s3b 2.70   4.50   2.06   1.36   1.03   0.84   0.70   0.60
     [210.0,230.0] s4b 2.91
     [230.0,250.0] s5b 3.16
     [250.0,270.0] s6b 3.42
     [270.0,290.0] s7b 3.56
     [290.0,320.0] s8b 3.91

# Misc 

* scienceprimary ==1 && sdssprimary==1 && class_spec=="GALAXY" && platequality_spec != "bad" && airmass_spec <= 1.50 && seeing80_spec <= 2.80 && clean_photo == 1 && score_photo >= 0.80 && abs(b_gal) >=10.0 && extinction_g <= 0.30 && (vdisp_err_ports/vdisp_ports) <= 0.20 && petroR50_kpc_r >= 0.1 && petroR50_kpc_r <= 40.0 && devRad_kpc_r > 0.1 && devRad_kpc_r <= 40.0 && (petroR50Err_r/petroR50_r) <= 0.3 && (devRadErr_r/devRad_r) <= 0.3

* z_sdss < 0.07 && vdisp_cor_ports > 140.0 && vdisp_cor_ports <= 160.0 && fracDev_r > 0.8 && devAB_r > 0.4 && sfr_tot_mpa < 3.0 && specsfr_tot_mpa < 3.0 && bpt_ports != "Star Forming" && bpt_ports != "Seyfert" && bpt_ports != "Seyfert/LINER" 

* z_sdss < 0.07 && vdisp_cor_ports > 200.0 && vdisp_cor_ports <= 220.0 && fracDev_r > 0.8 && devAB_r > 0.4 && sfr_tot_mpa < 3.0 && specsfr_tot_mpa < 3.0 && bpt_ports != "Star Forming" && bpt_ports != "Seyfert"  && bpt_ports != "Seyfert/LINER"  && logm_pca >= 9.0 && logm_pca <=13.0 && snMedian_r_spec > 28.8

* z_sdss < 0.07 && sfr_tot_mpa < 3.0 && specsfr_tot_mpa < 3.0 && bpt_ports != "Star Forming" && bpt_ports != "Seyfert"  && bpt_ports != "Seyfert/LINER"  && logm_pca >= 9.0 && logm_pca <=13.0 --> "use" results in 24426 galaxies in the low-z bin

* z_sdss > 0.07 && vdisp_cor_ports > 270.0 && vdisp_cor_ports < 340.0 && sfr_tot_mpa < 3.0 && specsfr_tot_mpa < 3.0 && bpt_ports != "Star Forming" && bpt_ports != "Seyfert" && bpt_ports != "Seyfert/LINER"  && fracDev_r > 0.8 && logm_pca >= 9.5 && logm_pca <= 13.2 && devAB_r > 0.4

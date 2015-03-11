# Sample Selection 

## Overview

The main purpose of this study is to select a complete sample of relative 
nearby ETGs, group them into a series of sub-samples according to different 
physical properties, and use the high signal-to-noise ratio stacking spectrum 
of all the spectra within a subsample to study the average stellar population 
properties of them.  Both spectra index measurements and full-spectra fitting 
method will be applied to these stacking spectra to reveal their difference, and 
find potential trends between stellar age, metallicity, element-ratio, slope of 
IMF and other fundamental properties of the galaxies.  

The fixed aperture size of SDSS spectrograph will be used as a "selective 
collector", which includes stellar light from different physical size for 
galaxies at different redshift.  Hence, within a reasonably small range of 
redshift (means no significant evolution),

## Procedures 

* We assume: Omega\_M=0.27; Omega\_Lambda=0.73; h0=0.71

### Large sample from SDSS 

Galaxies are selected from SDSS DR9 database using the CasJob server.  

*   0.03 < z\_SDSS < 0.22 AND z\_Err/z\_SDSS <= 0.01 AND z\_WARNING = 0
    ** XXX
*   |b| > 10.0 AND extinction\_u < 0.30 
    ** XXX
*   160.0 < velDisp < 340.0 (km/s) AND velDispErr < 20.0 (km/s) 
    ** XXX
*   clean = 1 (photometric flag) AND score > 0.7
    ** XXX
*   sn_Median > 10.0 
    ** XXX
*   PlateQuality != 'bad' AND  (spectroscopic flag) AND seeing50 < 3.0 
    AND airmass < 1.8 
    ** XXX
*   Has useful size estimation (both PetroR50 and DevRad in r-band)

*  The above criteria resulted in 109090 galaxies from SDSS survey; and 5522 
   galaxies from BOSS survey 

*  All the necessary properties from SDSS database (both photometric and 
   spectroscopic ones) are retrieved; Also, relevant information from the 
   cross-matched catalog of MPA/JHU VAGC and GalaxyZoo are obtained. 

### Cross-match with other useful catalog

* Among these 109090 galaxies, 102079 have specobjID in SDSS DR7 

#### [NYU Value-Added Galaxy Catalog](http://sdss.physics.nyu.edu/vagc)

* NYU VAGC provided K-corrections of the ugrizJHK magnitudes for all the 
  galaxies in SDSS DR7; also, results from a Sersic radial profile fits are 
  provided

* The cross-match with our sample results in 108800 galaxies in common

* The K-corrected absolute magnitude and the associated uncertainties for g-
  and r-band; the R50 and Sersic index from the one-component Sersic fitting 
  are extracted for further use 

#### [GalaxyZoo DR1 Database](http://data.galaxyzoo.org) 

* The Table 2 from DR1 of GalaxyZoo included classifications of galaxies that 
  have SDSS DR7 spectra.  The votes are debiased to classify the object into 
  spiral, elliptical and uncertain categories. 

* The cross-match results in 102070 galaxies in common 

* The GalaxyZoo morphological classification can help us isolated non-ETG 
  objects in our sample 

#### [Morphology2010 Classification](http://gepicom04.obspm.fr/sdss_morphology/Morphology_2010.html)

* The morphology2010 catalog provides the automated probabilistic morphological 
  classification of the SDSS DR7 galaxies with z<0.25.  All galaxies are 
  classified into two broad classes  (E/S0, S); and 4 detailed classes (E, S0, 
  Sab and Scd). 

* The results from [ASK](ftp://ftp.iac.es/) (Automatic unsupervised 
  classification of spectra) are also attached in the catalog 

* The cross-match gives us 102027 galaxies in common 

* Combined with several parameters in SDSS database, and the GalaxyZoo  
  classifications, the Morphology2010 and ASK classification can further help 
  us better constraining our sample. 

#### [OSSY SDSS Database](http://gem.yonsei.ac.kr/~ksoh/wordpress/)

* The OSSY database provides improved and quality-assessed emission and 
  absorption line measurements of SDSS DR7 galaxies. 

* The strength of various stellar absorption lines (using EW) are measured 
  after the best nebular emission model from GANDALF is subtracted.  And the 
  impact of stellar kinematic broadening is corrected.  

* OSSY database provided a independent measurements of stellar velocity 
  dispersion, strength of both emission and absorption lines. 

* The cross-match gives us 97895 galaxies in common

#### [Group Catalog by Yang+2007](http://gax.shao.ac.cn/data/Group.html)

* Group catalog for SDSS DR7 galaxies are provided based on both Petrosian and 
  Model magnitude using the halo-based group finder that is optimized for 
  grouping galaxies that reside in the same dark matter halo. 

* The catalog provided the K+E corrected absolute magnitude in both g- and 
  r-band along with a series of properties related to the DM halo and the group. 

* The cross-match results in 109090 galaxies in common. 

* Such catalog can help up grouping galaxies in our sample into different types 
  according to their DM properties and/or environment 

#### [GIM2D Image Decomposition Results]()

* The catalog provides results from two-dimensional, Point-Spread-Function 
  convolved, bulge+disc decomposition in g- and r-band for a sample of 1123718 
  galaxies from SDSS DR7.  The background subtraction and object deblending 
  procedures have been improved compared to standard SDSS method.  

* The author built three different models for each galaxy: single Sersic; 
  dev+expdisk; Sersic+expdisk.  Relevant parameters from the single Sersic 
  and Sersic+expdisk model have been extracted from the Table.2 and Table.3. 

* The cross-match leaves 101447 common galaxies. 

### Preparation of the final sample 

#### Summary of important parameters 

* Before we could group the sample into different sub-samples according to 
  different properties, careful review, comparison and preparation of the 
  galactic properties in our hand is very necessary: 

  - Stellar Velocity Dispersion: 
     + a) velDisp\_SDSS; b) velDisp\_OSSY 
     + Key parameter for separating ETGs into different group.
     + Aperture correction is necessary 
  - Absolute Magnitude: 
     + a) M\_g and M\_r (Model, CModel, and Petro) from SDSS database 
     + b) M\_g and M\_r (both Model and Petro) from NYU VAGC 
     + c) M\_g and M\_r (both Model and Petro) from Yang+2007 group catalog
     + Another fundamental parameters; The magnitude from SDSS has been 
       corrected for Galactic extinction, further K+E correction is required; 
       Magnitude from VAGC catalog has been K-corrected, E-correction is still 
       necessary; Magnitude in Yang+2007 have been K+E corrected. 
   - Physical Size of the Galaxy 
     + a) PetroR50\_r or devRad\_r from SDSS database (arcsec)
     + b) R50 in R-band from Sersic radial profile fitting in NYU VAGC (arcsec)
     + c) R50 in R-band from 2-D Sersic fitting using GIM2D (arcsec) 
     + Physical size is useful in aperture correction of velocity dispersion and 
       the estimation of dynamical mass; Also, it is an important properties to 
       constrain our sample 
     + The unit of the chosen parameter that represents the physical size of
       galaxy need to convert into kpc; Simple correction for axis ratio is also 
       necessary. 
   - Axis ratio or ellipticity: 
     + a) devAB from SDSS database; 
     + b) e\_ss\_gim2d: ellipticity of single Sersic model in GIM2D catalog 
     + Useful for the estimation of circulized effective radius, and to exclude 
       edge-on galaxies from the sample. 
   - Sersic index: 
     + a) n_ser from NYU Sersic radial profile fitting; 
     + b) n_ser from GIM2D single Sersic 2-D fitting 
     + Sersic index can help constrain our sample; it is also necessary for the 
       estimation of dynamical mass 
   - Optical Color in SDSS filters: 
     + Directly related to the absolute magnitude 
     + Useful in understanding the sample; and estimate the average mass-to-
       light ratio of the galaxy. 
   - Stellar Mass: 
     + a) logMs\_MPA: from MPA/JHU VAGC 
     + b) logMs\_Kcor: Stellar mass estimated by K-correct code (Blanton+2005) 
     + c) logMs\_Color: Estimated using the absolute magnitude and a 
          mass-to-light ratio value using different absolute magnitude above. 
     + One of the most important derived parameters.
   - Parameters for the Classification of Galaxies:
     + a) Photometric parameters from SDSS database: fracDev\_r and derived 
          concentration index, et al. 
     + b) Spectroscopic parameters like the estimation of SFR, sSFR, the 
          classification on the BPT diagram from MPA/JHU catalog 
     + c) Morphological classifications from GalaxyZoo 
     + d) Morphological classifications from Morphology2010 automated catalog 
     + e) Automated spectroscopic classification using ASK method 
     + f) Environmental information from Yang+2007 group catalog 
       
* If we require the galaxy appears in all the catalog --> This leaves us 94418 
  galaxies. 

#### Step 1. Basic preparation of parameters: 

* Prepare the different version of absolute magnitude, optical color, effective 
  radius, axis ratio, and stellar mass estimations for further comparison 
* (09-03-2013) The absolute magnitude from GIM2D catalog show significant 
  difference with the others.  Re-organize the GIM2D catalog, and re-run the 
  data preparation pipeline.  After the double check, we will redo the 
  comparison within a reasonable range.  
* (09-04-2013) After checking with L.Simard and T.Mendel, the problem is solved. 
  The NYU VAGC adopted h0=1.0 during the k-correction.  Hence, a difference 
  equals to -5.0*log(h0) presented in the value of absolute magnitude with the 
  GIM2D value, where h0=0.7 is adopted.  So, the GIM2D absolute magnitude should 
  be -5.0*log(0.7) = 0.78 magnitude brighter than the NYU ones.  This will be 
  corrected in the data preparation code. 
* Also, the preparation code will be updated.  The difference among the 
  measurements of the same properties will be stored. 

  - K+correction is applied to the Model, Petro, and CModel flux (nmgy) from 
     SDSS database using all five filters.  The correction is done by using the 
     IDL code: [Kcorrect V4 by Blanton](http://howdy.physics.nyu.edu/index.php/Kcorrect)
  - Evolutionary-Correction: is a relative small correction considering the 
     redshift range of our sample.  The correction strongly depends on the 
     choice of stellar population model and the star-formation history. 
     + E-correction: E_Q = A_Q * ( z - z0 ); for us, z0=0.0 
     + a) Blanton+2003a: A_Q = [-4.22, -2.04, -1.62, -1.61] for [u,g,r,i]
     + b) Bell+2003: A_Q = [-2.3, -1.6, -1.3, -1.1] for [u,g,r,i]
     + c) Bernardi+2003a: A_Q=[1.2, 0.9, 0.8] for [g,r,i] 
     + We decided to use the A_Q value provided in Bell+2003, as a smoothly 
       varying SFH is used; Also, we will use the empirical correlation between 
       optical color and mass-to-light ratio from the same paper. 
  - For each set of 5-band photometry, the Kcorrect will return a set of 
     mass-to-light ratio estimations, and a stellar mass estimation;  
  - The absolute magnitude in r-band and the optical g-r color are used to 
     estimate the stellar mass adopting the empirical relation between this 
     color and the average r-band mass-to-light ratio in Bell+2003. 
     + log(M/L\_r) = a + b x (g-r): a=-0.306; b=-1.097 
     + In Bell+2003, a 'diet' Salpeter IMF is used; the estimated M/L is about 
       30% lower than the value based on classical Salpeter IMF 
  - All the effective radius estimations have been circulized according to 
     R\_e,c = R_e * SQRT( b/a )
     + For size estimation in GIM2D catalog, the e\_ss\_gim2d value is used 
     + For other size estimations, the devAB value from SDSS database is used 
  - Aperture correction based on different size estimations are prepared 
     using equation: sigma\_apcor = sigma * ( 8.0 * r\_ap/r\_e )^b 
     + r\_ap is the aperture size in arcsec, for SDSS, it is 1.5 arcsec; 
       for BOSS survey, it is 1.0 arcsec
     + for parameter b: b=0.066 in Cappellari+2006; b=0.04-0.7 in 
       Hyde & Bernardi+2009 
     + We adopted b=0.066 in Cappellari+2006; the value is based on 2-D 
       kinematic results from SAURON survey. 
  - To estimated the dynamical mass: M\_dyn = K(n) * sigma^2 * Re / G.  K(n) is 
     a factor that empirically related to the Sersic index: 
     + K(n) = 73.32 / (10.465 + ( n - 0.94 )^2 ) + 0.954
       
* The above corrections have been summarized into an IDL code: 
  sdss\_hsigma\_master.pro (use sdss\_hsigma\_master\_simple\_2.fits as input); 
  The code generates a new catalog: sdss\_hsigma\_new\_1.fits

##### Comparison of different estimations of the same physical property: 

###### Absolute Magnitude in r-band: 
 * The comparison uses AMAG\_R\_MODEL\_SDSS as reference (5-band K+E-corrected 
   model magnitude using our own procedure), and is within the range of 
   -23.5 < M\_r < -18.5
   
   + a) AMAG\_R\_PETRO\_SDSS = 0.976 * AMAG\_R\_MODEL\_SDSS - 0.413
     - Scatter slightly depends on velocity dispersion
     - Scatter clear depends on axis ratio and Sersic index
   + b) AMAG\_R\_CMODEL\_SDSS = 0.984 * AMAG\_R\_MODEL\_SDSS - 0.304
     - For a large fraction of galaxies with nser\_gim2d\_ss between 2 to 3, the 
       CMODEL absolute magnitude is higher than the model ones
   + c) AMAG\_R\_MODEL\_NYU = 0.970 * AMAG\_R\_MODEL\_SDSS - 0.671
     - Scatter is larger for some objects with either very low or high Sersic 
       index; a large fraction of the scattered objects have high axis-ratio;
       The velocity dispersion of these objects are not very high 
     - Add flux in NIR (J, H, Ks from 2MASS) increase the luminosity of some 
       objects (?)
   + d) AMAG\_R\_PETRO\_NYU = 0.949 * AMAG\_R\_MODEL\_SDSS - 1.015
   + e) AMAG\_R\_MODEL\_YANG is very close to AMAG\_R\_MODEL\_NYU; same with the 
        Petrosian magnitude
   + f) AMAG\_R\_SS\_GIM2D = 0.988 * AMAG\_R\_MODEL\_SDSS - 1.299
   + g) AMAG\_R\_BD\_GIM2D = 0.989 * AMAG\_R\_MODEL\_SDSS - 1.303 
     - The GIM2D decomposition gives much higher luminosity on average; the 
       scatters are also the largest, 
     - When the GIM2D magnitudes are compared with NYU magnitudes, the scatter 
       get slightly smaller.  But the GIM2D luminosity is still higher. The 
       difference clearly shows relations with Sersic index and axis ratio.
     - See Figure.8 in Simard+2012; There is something wrong! DOUBLE CHECK!!
        (XXX)
     - According to equation 3(a) in Simard+2012, the GIM2D absolute magnitude 
       has not been E-corrected --> Update sdss\_hsigma\_master.pro and redo 
       the procedure to generate an update catalog
     - The GIM2D catalog provide magnitude in g-band too; should take the 
       GIM2D version of g-r color into consideration --> Update the input 
       catalog --> sdss\_hsigma\_master\_simple\_3.fits ; Update 
       sdss\_hsigma\_master.pro --> sdss\_hsigma\_new\_1.fits

  * The bulge+disk decomposition by GIM2D suppose to provide better background 
    subtraction, deblending than default SDSS procedure; Also, the two 
    component model should recover the "real" luminosity better. 

###### Stellar Velocity Dispersion: 
 * The range of comparison is between 160.0 and 350.0 km/s 

   + VDISP\_OSSY = 1.074 * VDISP\_SDSS - 17.110 
   + VDISPERR\_OSSY = 0.823 * VDISPERR\_SDSS - 0.164 
     - The OSSY database gives smaller error on average; but the OSSY error 
       also scatters toward larger value. 
     - The procedure of kinematic estimation adopted by the OSSY database 
       (based on pPXF and GANDALF) should show improvement compared with 
       SDSS; However, this will lead to a slightly smaller sample size. 

###### Optical Color (g-r) 
 * The reasonable range of g-r color should be around [0.50, 1.40] 

   + G\_R\_COLOR\_MODEL\_NYU = 0.916 * G\_R\_COLOR\_MODEL\_SDSS + 0.019 
     - Good correlation, but the NYU color shows a lot of outliers toward 
       redder color.  The scatter depends on the structure of galaxies. 
   + G\_R\_COLOR\_PETRO\_SDSS = 1.004 * G\_R\_COLOR\_MODEL\_SDSS - 0.023 
     - Still, there are considerably large scatter, especially at the red 
       end.  And the scatter depends on the structure of galaxies. 
   + G\_R\_COLOR\_SS\_GIM2D = 0.880 * G\_R\_COLOR\_MODEL\_SDSS + 0.065 
   + G\_R\_COLOR\_BD\_GIM2D = 0.790 * G\_R\_COLOR\_MODEL\_SDSS + 0.115 
     - Scatter is quite large, and the GIM2D absolute magnitude need to be 
       double checked

###### Effective Radius 
 * Use R50C\_R\_BD\_GIM2D as reference; The reasonable range of R50C is around 
   [2.0, 30.0]

   + R50C\_R\_SS\_GIM2D = 1.495 * R50C\_R\_BD\_GIM2D - 1.043 
     - Very large scatter, especially at the large size end.
   + R50C\_R\_PETRO = 0.573 * R50C\_R\_BD\_GIM2D + 0.793 
     - Smaller scatter compared to the above one; However, the SDSS PetroR50 
       is significantly smaller than the R50 given by GIM2D B+D decompostion. 
     - The nature of B+D decomposition will lead to larger effective radius 
       compared to Petrosian photometry; Also, the different treatment of 
       background subtraction could leave footprint in this difference. 
   + R50C\_R\_DEV = 0.734 * R50C\_R\_BD\_GIM2D + 0.902 
     - Similar behavior with R50C\_R\_SS\_GIM2D, but even large error (easy to 
       understand, since here the n\_ser is fixed at 4.0).  And, apparently, 
       the difference strongly depends on structural parameters. 
   + R50C1\_R\_NYU = 0.802 * R50C\_R\_BD\_GIM2D - 0.153 
   + R50C2\_R\_NYU = 0.802 * R50C\_R\_BD\_GIM2D - 0.177 
     - Similar behavior with R50C\_R\_SS\_GIM2D. Large scatter. 
     - The scatter depends on the axis ratio; For Sersic index, the 
       dependence is not very obvious. 
     - The difference between R50C1 and R50C2 here is the use of BA\_SDSS and 
       BA\_GIM2D.  Clearly there is no difference between these two choice. 

###### Sersic Index 
 * For GIM2D free Sersic fitting, the allowed range of Sersic index is  
   between 0.0 and 8.0;  And for NYU radial profile fitting, the allowed 
   range is between 0.0 and 6.0. 

   + N\_ser\_NYU = 0.531 * N\_ser\_GIM2D + 1.497 
     - The NYU Sersic index is systematically smaller than the GIM2D one; 
       And the scatter at the high Sersic index end is quite large. 

###### Stellar Mass 


###### Summary

* The above linear relation should only be taken as a very general impression of 
  the correlation between the two version of measurements;  For some interesting 
  case, the dependence of their difference on other properties deserve more 
  careful investigations. 

* In general, due to many recent contributions from different works after SDSS 
  DR7, we should try to take these new measurements into serious consideration 
  instead of keep using the ones in the default database of SDSS: 
  + For structural related parameters: GIM2D B+D and Single-Sersic fitting 
    results should be adopted. 
  + For stellar velocity dispersion, the new measurements using pPXF from OSSY 
    database should be considered. 

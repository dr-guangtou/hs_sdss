### Comparison of reference spectra 

#### MIUSCAT SSPs

* Convolved to 350km/s 
* Wavelength range: 3465 to 9468 Angstrom
* Wavelength in air

* Reference Spectra 
  - Kroupa Universal; Slope = 1.3 
  - Metallicity: [M/H]=+0.0; Z=0.019 
  - Age = 12.59 Gyr

* SSPs used for comparison 
  - IMF: un0.8; un1.3; un1.8; bi0.80; bi1.30; bi1.80 
  - Metallicity: -0.40; +0.00; +0.20 
  - Age: 5.01Gyr; 8.91Gyr


#### CvD12 SSPs

* Convolved to 350 km/s 
* Wavelength range: 3400 to 9200 Angstrom 
* Wavelength in vacuum 
* 7400-8140 Angstrom are derived entirely from synthetic spectra 
* Continuum shape should not be trusted to better than several percent

* Reference Spectra 
  - IMF : cha 
  - Age : 13.5 Gyr 
  - [a/Fe] : 0.0

* SSPs used for comparison 
  - IMF : btl; x23; x30 
  - Age : 5 Gyr; 9 Gyr 
  - [a/Fe] : +0.2; +0.3; +0.4

#### MIUSCAT CSPs 

##### Ingredients

* IMF: un0.8; un1.3; un1.8 
* Metallicity: -0.4; +0.0; +0.2

##### SFH Model 

* alpha: 0.2; 0.5; 1.0
* tau: 0.2; 0.5; 1.0
* t_trun: 0 Gyr; 4 Gyr; 6 Gyr

#### Separate the spectra into a few segments

* Try to avoid region with strong change in continuum slope. 
* Save the "continuum"-divided spectra into separated files.
* Divide the reference spectrum with the ones with different age, metallicity, and IMF. Use the ratio to check the interesting ranges that are sensitive to certain stellar population parameter. 

##### Regions

* reg_l = [ 3540.0, 3990.0, 4480.0, 4920.0, 4480.0, 5350.0, 5820.0, 
    6050.0, 6580.0, 7030.0, 7530.0, 7530.0, 8050.0 ]
* reg_r = [ 4020.0, 4580.0, 5000.0, 5380.0, 5365.0, 5850.0, 6080.0, 
    6550.0, 7060.0, 7550.0, 7850.0, 8300.0, 8900.0 ]
* nm1_l = [ 3545.0, 4015.0, 4615.0, 4942.0, 4615.0, 5374.0, 5824.0, 
    6106.0, 6614.0, 7034.0, 7540.0, 7540.0, 8155.0 ] 
* nm1_r = [ 3555.0, 4025.0, 4625.0, 4952.0, 4625.0, 5386.0, 5836.0, 
    6118.0, 6626.0, 7046.0, 7552.0, 7552.0, 8165.0 ]
* nm2_l = [ 4005.0, 4504.0, 4944.0, 5354.0, 5354.0, 5824.0, 6066.0, 
    6528.0, 7036.0, 7468.0, 7811.0, 8240.0, 8840.0 ]
* nm2_r = [ 4015.0, 4514.0, 4954.0, 5364.0, 5364.0, 5836.0, 6078.0, 
    6540.0, 7048.0, 7480.0, 7823.0, 8250.0, 8850.0 ]

1. Region A: 3540-4020 
   * No useful IMF tracer; many age, total metallicity, and a/Fe sensitive 
     features 


# SpectralFitness Challenges -- Starlight Fitting Results for GCs from Song Huang

-----

## Intro: 
    
    * We correct the spectra for Galactic extinction using E(B-V) value from SFD98 dust
      map and Draine (2003) extinction curve. 
    * We interpolate the spectra to a new wavelength array from 3500.0-6059.2 Angstrom
      with a constant 0.8 Angstrom separation. 
    * We estimate error spectra using the S/N spectra provided in the ".aux.fits" files; 
      The spectra are with very high S/N, to speed up the fitting process, and also
      account for other systematics, we decrease the S/N value by 10x 
    * We mask out regions where the sky emission lines are extremely strong.

    * Here are a few key information:
        1. Wavelength: 3600-6050 Angstrom 
        2. Choice of stellar population model and IMF: We try two different models: 
            * MIUSCAT SSP with Kroupa IMF and Salpeter IMF; 
                - 282 SSPs: 47 Ages (70 Myrs - 14 Gyrs; roughly uniform in log-scale) x 6 Metallicity (-1.3 - +0.2)
            * New MILES SSP models with non-solar [a/Fe] with "uniform" and "bimodel"
              Kroupa, or Salpeter IMF; 
                - 255 SSPs: 3 [a/Fe] x 5 metallicity x 17 Ages 
            * !!WARNINGS!!: Here we include SSP with low metallicity that are labeled as 
              "NOT SAFE" by MILES library.
        3. Dust extinction: Only try with CCM extinction law; without help
           from any polynomial continuum, or additional extinction for younger population 
        4. Masks: We masked out regions with strong sky residuals, and the central region
           of the NaD absorption line ("sl_gc_mask.lis") 
        5. Kinematics: We let Starlight to fit the velocity and velocity dispersion at the
           same time

-----

## Models: 

    * We try five different models: 
        - (A): MIUSCAT; uniform-Kroupa IMF; 
        - (B): MIUSCAT; bimodel-Kroupa IMF; 
        - (C): MIUSCAT; Salpeter IMF; 
        - (D): MILES-BaSTI-aFe; uniform-Kroupa IMF; 
        - (E): MILES-BaSTI-aFe; Salpeter IMF; 

-----

## Configuration: 

    * Spectra are normalized between 5590-5680 Angstrom; Models are normalized at 5635 Angstrom
    * Apply 3-Sigma clipping 
    * We use 7 Markov chains 
    * Other settings are very similar to the "MEDIUM" fits suggested by Cid Fernandes

----- 

## Results: 

|----------------------|-------|------|-------|-------|------|------|--------|
|        NAME          | MODEL |  Av  | Age_L | Age_M | Z_L* | Z_M  |  Chi2  |
|                      |       |  mag |  Gyr  |  Gyr  | dex  | dex  |        |
|----------------------|-------|------|-------|-------|------|------|--------|
|      NGC 5286        |   A   | 0.04 | 10.64 | 12.24 |-1.43 |-1.40 |  473.4 |
|                      |   B   | 0.03 | 10.64 | 12.10 |-1.51 |-1.48 |  476.8 |
|                      |   C   | 0.02 | 10.59 | 12.13 |-1.46 |-1.43 |  474.8 |
|                      |   D   | 0.01 |  6.85 |  7.50 |-1.42 |-1.38 |  329.7 |
|                      |   E   |-0.02 |  6.96 |  7.55 |-1.44 |-1.40 |  335.0 |
|----------------------|-------|------|-------|-------|------|------|--------|
|      NGC 6522        |   A   | 0.29 |  9.77 | 11.92 |-0.92 |-0.83 |  521.9 |
|                      |   B   | 0.26 |  9.90 | 11.94 |-0.95 |-0.86 |  510.7 |
|                      |   C   | 0.26 |  9.45 | 11.49 |-0.95 |-0.85 |  513.7 |
|                      |   D   | 0.30 |  8.07 |  9.85 |-0.72 |-0.52 |  402.0 |
|                      |   E   | 0.28 |  8.17 |  9.94 |-0.75 |-0.54 |  397.6 |
|----------------------|-------|------|-------|-------|------|------|--------|
|      NGC 5286        |   A   |-0.30 | 11.87 | 12.57 |-0.20 |-0.12 |  594.4 |
|                      |   B   |-0.31 | 11.70 | 12.25 |-0.22 |-0.16 |  578.6 |
|                      |   C   |-0.33 | 11.77 | 12.30 |-0.20 |-0.18 |  579.6 |
|                      |   D   |-0.23 | 12.24 | 13.08 |-0.05 | 0.01 |  526.8 |
|                      |   E   |-0.25 | 13.28 | 13.99 |-0.08 |-0.04 |  505.8 |
|----------------------|-------|------|-------|-------|------|------|--------|

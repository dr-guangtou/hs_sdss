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

|----------------------|-------|-------|------|-------|-------|------|------|--------|
|        NAME          | MODEL | SIGMA |  Av  | Age_L | Age_M | Z_L* | Z_M  |  Chi2  |
|                      |       |  km/s |  mag |  Gyr  |  Gyr  | dex  | dex  |        |
|----------------------|-------|-------|------|-------|-------|------|------|--------|
|      NGC 5286        |   A   | 287.2 | 0.31 | 11.57 | 12.40 | 0.14 | 0.18 | 2237.1 |
|                      |   B   | 291.4 | 0.29 | 12.01 | 12.93 | 0.14 | 0.18 | 2422.0 |
|                      |   C   | 291.4 | 0.26 | 11.91 | 12.92 | 0.15 | 0.19 | 2503.8 |
|                      |   D   | 291.3 | 0.26 | 12.94 | 13.81 | ---- | ---- | 2132.4 |
|                      |   E   | 292.0 | 0.35 | 13.09 | 13.93 | ---- | ---- | 2216.9 |
|----------------------|-------|-------|------|-------|-------|------|------|--------|
|      NGC 6522        |   A   | 287.2 | 0.31 | 11.57 | 12.40 | 0.14 | 0.18 | 2237.1 |
|                      |   B   | 291.4 | 0.29 | 12.01 | 12.93 | 0.14 | 0.18 | 2422.0 |
|                      |   C   | 291.4 | 0.26 | 11.91 | 12.92 | 0.15 | 0.19 | 2503.8 |
|                      |   D   | 291.3 | 0.26 | 12.94 | 13.81 | ---- | ---- | 2132.4 |
|                      |   E   | 292.0 | 0.35 | 13.09 | 13.93 | ---- | ---- | 2216.9 |
|----------------------|-------|-------|------|-------|-------|------|------|--------|
|      NGC 6528        |   A   | 287.2 | 0.31 | 11.57 | 12.40 | 0.14 | 0.18 | 2237.1 |
|                      |   B   | 291.4 | 0.29 | 12.01 | 12.93 | 0.14 | 0.18 | 2422.0 |
|                      |   C   | 291.4 | 0.26 | 11.91 | 12.92 | 0.15 | 0.19 | 2503.8 |
|                      |   D   | 291.3 | 0.26 | 12.94 | 13.81 | ---- | ---- | 2132.4 |
|                      |   E   | 292.0 | 0.35 | 13.09 | 13.93 | ---- | ---- | 2216.9 |
|----------------------|-------|-------|------|-------|-------|------|------|--------|

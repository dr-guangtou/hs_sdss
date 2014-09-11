;;*** REMOVE_OUTLIERS
;;*
;;* AIM: given a spectral dataset and set of associated parameters
;;*      (currently with mean=0), remove the
;;*      outliers from the dataset and return the new data array
;;* 
;;* INPUT:
;;*     - data = array of spectra (nbin,ngal)
;;*     - pcs  = associated parameters (nparam,ngal)
;;*     - sigma = distance from zero to clip in terms of standard
;;                deviation.  
;;* OUPUT: 
;;*     - returns new data array with outliers removed
;;*     
;;*******************************************************************


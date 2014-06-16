;+
; NAME:
;             HS_BASIC_STATS
;
; PURPOSE:
;             Get the basic statistical information for an array of data
;
; USAGE:
;    result = hs_basic_stats( array, sig_cut=sig_cut ) 
; 
; OUTPUT: 
;    result = { num:0.0, min:0.0, max:0.0, avg:0.0, med:0.0, sig:0.0, adv:0.0, $
;       lquar:0.0, uquar:0.0, lifen:0.0, lofen:0.0, uifen:0.0, uofen:0.0, $
;       var:0.0, skw:0.0, kur:0.0 }
;
; AUTHOR:
;             Song Huang
;
; HISTORY:
;             Song Huang, 2014/06/05 - First version 
;-
; CATEGORY:    HS_SDSS
;------------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_robust_mean, Y, CUT, Sigma, Num_Rej, GoodInd=GoodInd
;+
; NAME:
;    Robust_Mean 
;
; PURPOSE:
;    Outlier-resistant determination of the mean and standard deviation.
;
; EXPLANATION:
;    Robust_Mean trims away outliers using the median and the median
;    absolute deviation.    An approximation formula is used to correct for
;    the trunction caused by trimming away outliers
;
; CALLING SEQUENCE:
;    mean = Robust_Mean( VECTOR, Sigma_CUT, Sigma_Mean, Num_RejECTED)
;
; INPUT ARGUMENT:
;       VECTOR    = Vector to average
;       Sigma_CUT = Data more than this number of standard deviations from the
;               median is ignored. Suggested values: 2.0 and up.
;
; OUTPUT ARGUMENT:
;       Mean  = the mean of the input vector, numeric scalar
;
; KEYWORDS:
;
;       GoodInd = The indices of the values not rejected
;
; OPTIONAL OUTPUTS:
;Sigma_Mean = the approximate standard deviation of the mean, numeric
;            scalar.  This is the Sigma of the distribution divided by sqrt(N-1)
;            where N is the number of unrejected points. The larger
;            SIGMA_CUT, the more accurate. It will tend to underestimate the
;            true uncertainty of the mean, and this may become significant for
;            cuts of 2.0 or less.
;       Num_RejECTED = the number of points trimmed, integer scalar
;
; EXAMPLE:
;       IDL> a = randomn(seed, 10000)    ;Normal distribution with 10000 pts
;       IDL> Robust_Mean,a, 3, mean, meansig, num    ;3 Sigma clipping   
;       IDL> print, mean, meansig,num
;
;       The mean should be near 0, and meansig should be near 0.01 ( =
;        1/sqrt(10000) ).    
; PROCEDURES USED:
;       AVG() - compute simple mean
; REVISION HISTORY:
;       Written, H. Freudenreich, STX, 1989; Second iteration added 5/91.
;       Use MEDIAN(/EVEN)    W. Landsman   April 2002
;       Correct conditional test, higher order truncation correction formula
;                R. Arendt/W. Landsman   June 2002
;       New truncation formula for sigma H. Freudenriech  July 2002
;-  
On_Error,2
 if N_params() LT 2 then begin
     print,'Syntax - Robust_Mean(Vector, Sigma_cut, [ Sigma_mean, '
     print,'                                  Num_Rejected ])'
     return,1
 endif  
 Npts    = N_Elements(Y)
 YMed    = MEDIAN(Y,/EVEN)
 AbsDev  = ABS(Y-YMed)
 MedAbsDev = MEDIAN(AbsDev,/EVEN)/0.6745
 IF MedAbsDev LT 1.0E-24 THEN MedAbsDev = AVG(AbsDev)/.8  
 Cutoff    = Cut*MedAbsDev  
 GoodInd = WHERE( AbsDev LE Cutoff, Num_Good )
 GoodPts = Y[ GoodInd ]
 Mean    = AVG( GoodPts )
 Sigma   = SQRT( TOTAL((GoodPts-Mean)^2)/Num_Good )
 Num_Rej = Npts - Num_Good ; Compenate Sigma for truncation (formula by HF):
 SC = Cut > 1.0
 IF SC LE 4.50 THEN $
    SIGMA=SIGMA/(-0.15405+0.90723*SC-0.23584*SC^2+0.020142*SC^3)  
 Cutoff = Cut*Sigma  
 GoodInd = WHERE( AbsDev LE Cutoff, Num_Good )
 GoodPts = Y[ GoodInd ]
 mean    = AVG( GoodPts )
 Sigma   = SQRT( TOTAL((GoodPts-mean)^2)/Num_Good )
 Num_Rej = Npts - Num_Good ; Fixed bug (should check for SC not Sigma) & add higher order correction
 SC = Cut > 1.0
 IF SC LE 4.50 THEN $
    SIGMA=SIGMA/(-0.15405+0.90723*SC-0.23584*SC^2+0.020142*SC^3) 
; Now the standard deviation of the mean:
 Sigma = Sigma/SQRT(Npts-1.)  
return,mean
 
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO HS_RSTAT, Data_in, Hinge1, Hinge2, Ifence1, Ifence2, Ofence1, Ofence2
;+
; NAME:
;   rstat
;
; PURPOSE:
;   Robust statistics on an array.  Results are output in terms of
;   "hinges" and "fences" as defined in Tukey's Exploratory Data
;   Analysis; these are the quantities that are typically used in
;   box-and-whisker plots.  These descriptive statistics are particularly
;   useful for telling whether a distribution has long tails or outliers.
;
; MAJOR TOPICS:
;   Statistics.
;
; CALLING SEQUENCE:
;   RSTAT, Data_in, Med, Hinge1, Hinge2, Ifence1, Ifence2, $
;       Ofence1, Ofence2, Mind, Maxd
;
; INPUT PARAMETERS:
;   data_in     Array of numbers to be characterized.
;
; INPUT KEYWORDS:
;   noprint     Flag.  Omit printing if set.
;   textout     The usual GSFC TEXTOUT parameter.
;   descrip     Descriptive line for hardcopy.
;                       
; OUTPUT PARAMETERS:
;   med         Median.
;   hinge1      Lower quartile.
;   hinge2      Upper quartile.
;   ifence1     Lower one of the inner fences =
;                   hinge1 - 1.5*(interquartile interval)
;   ifence2     Upper one of the inner fences =
;                   hinge2 + 1.5*(interquartile interval)
;   ofence1     Lower one of the outer fences =
;                   hinge1 - 3*(interquartile interval)
;   ofence2     Upper one of the outer fences =
;                   hinge2 + 3*(interquartile interval)
;   mind, maxd  Min and max.
;
; HISTORY:   2 Dec. 1996 - Written.  RSH, HSTX
;           15 Sep. 1999 - Spiffed up for usage similar to imlist.  RSH
;            1 June 2000 - Improved descriptive header for output.  RSH
;            3 July 2000 - IDL V5 and idlastro standards.  Check for
;                          existence of finite data.  RSH
;-

on_error, 2

IF n_params(0) LT 1 THEN BEGIN
    print, 'CALLING SEQUENCE:  HS_RSTAT, Data_in, '
    print, 'Hinge1, Hinge2, Ifence1, Ifence2, Ofence1, Ofence2'
    RETURN
ENDIF

;; NElement
nin  = n_elements(data_in)
wfin = where(finite(data_in), nfin)

IF nfin LE 0 THEN BEGIN
    message, ' No useful element in the array !!'
ENDIF

;; Filter the finite part 
data = data_in[wfin]

;; Sort the array; Number of finite elements
s = sort(data)
n = n_elements(data)

;; Index for median 
dmed = 0.5*(n+1)
fdmed = floor(dmed)

;; Get the median 
IF (n MOD 2) EQ 0 THEN BEGIN
    end1 = fdmed-1
    end2 = fdmed
    med = 0.5*(data[s[end1]] + data[s[end2]])
ENDIF ELSE BEGIN
    end1 = fdmed-1
    end2 = fdmed-1
    med = data[s[end1]]
ENDELSE
                 
;; Lower and Upper Quartile
n1 = ( end1 + 1 )
dhinge  = ( 0.5 * ( n1 + 1 ) )
fdhinge = floor( dhinge )
IF ( fdmed MOD 2 ) EQ 0 THEN BEGIN
    hinge1 = 0.5*(data[s[fdhinge-1]] + data[s[fdhinge]])
    hinge2 = 0.5*(data[s[n-fdhinge]] + data[s[n-fdhinge-1]])
ENDIF ELSE BEGIN
    hinge1 = data[s[fdhinge-1]]
    hinge2 = data[s[n-fdhinge]]
ENDELSE

;; Inner and Outer fences 
hspread = ( hinge2 - hinge1 )
step =  ( 1.5 * hspread )
;;
ifence1 = hinge1 - step
ifence2 = hinge2 + step
ofence1 = ifence1 - step
ofence2 = ifence2 + step

RETURN

END         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; + 
;; HS_Basic_Stats 
;; 06/02/2014 SH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function hs_basic_stats, array, sig_cut=sig_cut

    compile_opt idl2 
    on_error, 2 

    ;; Input 
    if ( n_params() eq 0 ) then begin 
        print, ' result = hs_basic_stats( array, sig_cut=sig_cut ) '
        return, -1 
    endif 
    ;; Output 
    result = { num:0.0, min:0.0, max:0.0, avg:0.0, med:0.0, sig:0.0, adv:0.0, $
        lquar:0.0, uquar:0.0, lifen:0.0, lofen:0.0, uifen:0.0, uofen:0.0, $
        var:0.0, skw:0.0, kur:0.0 }

    ;; Number of elements 
    result.num = n_elements( array ) 
    ;; Min & Max 
    result.min = min( array, /NaN )
    result.max = max( array, /NaN )
    ;; Median & Absoluate median deviation 
    if ( ( n_elements( array ) mod 2 ) EQ 0 ) then begin 
        result.med = median( array, /even ) 
        result.adv = median( abs( array - result.med ), /even )
    endif else begin 
        result.med = median( array ) 
        result.adv = median( abs( array - result.med ) )
    endelse
    ;; Mean & Sigma 
    if NOT keyword_set( sig_cut ) then begin 
        result.avg = mean( array, /NaN )
        result.sig = stddev( array, /NaN )
    endif else begin 
        result.avg = hs_robust_mean( array, sig_cut, robust_sig ) 
        result.sig = robust_sig 
    endelse
    ;; Variance 
    result.var = variance( array, /NaN ) 
    ;; Skewness and Kur 
    result.skw = skewness( array, /NaN ) 
    result.kur = kurtosis( array, /NaN )
    ;; Lower/Upper Quartile & Inner/Outer fences 
    hs_rstat, array, hinge1, hinge2, ifence1, ifence2, ofence1, ofence2
    result.lquar = hinge1 
    result.uquar = hinge2 
    result.lifen = ifence1 
    result.uifen = ifence2
    result.lofen = ofence1 
    result.uofen = ofence2 
    ;; Return the result 
    return, result 

end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

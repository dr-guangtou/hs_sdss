# Sanity checks with STARLIGHT v4.0 

+ Using the most recently released version of STARLIGHT 
+ Base on CB07 (Chabrier, Kroupa, and Salpeter IMF); and MIUSCAT (IMF options: un0.30/0.80/
  1.00/1.30/1.50/1.80/2.00/2.30; bi0.80/1.30/1.80/2.30; kb1.30; ku1.30) 
+ Use spec-1849-53846-0262_sl.txt as example: a normal ETG at z=0.97 

## Necessary knowledges

+ SL deals N*+4 parameters: N* population vectors; Av and Av_Y (not used); 
  v_d and v_disp
+ For normalization, makes sure that: "llow_norm < l_norm < lupp_norm"
+ The sum of all population vector was limited within "fn_low" and "fn_upp"
+ Important parameters in the configuration file: 
   - "N_chains": number of Markov Chains 
   - "N_loops_FF": number of loops for the First Fits stage; if you care about 
     the kinematics, use large loop number
   - "Temp_ini_FF"; "Temp_fin_FF": initial and final "temperature" for the 
     cooling scheme --> T_k = Temp_ini_FFx(Temp_fin_FF/Temp_ini_FF)^[(k-1)/(N_loops_FF-1)]; 
     The likelihood function under the assumption of Gaussian errors looks like 
     the Boltzmann factor: L \propto exp(-\chi^2); where (-\chi^2) works like an 
     adimentional energy, and the temperature at loop k modifies it into: 
     L \propto exp(-\chi^2/(2*T_k)). Hence, when T_k > 1, the likelihood 
     distribution is broaden, and while T_l < 1, the distribution is narrowed. 
     When the T_k is high, the error is overestimated, and the hyper-surface of 
     the likelihood is flat, large moves of the chains in parameter space is 
     allowed. So, during FF stage, start with large Temp_ini_FF ~ 100; and end 
     with Temp_fin_FF ~ 1
   - "i_RestartChains_FF": = 0/1/2 means do not reset the parameters of each  
     chain to their respective best values before the next loop / reset all 
     chains / only reset the chain with the worst \chi^2.0
   - "eff_IDEAL_FF" = ( number of accepted moves / total number of steps ); for 
     STARLIGHT to dynamically adjust the step size to reach a certain effiency.
   - "fN_sim_FF": STARLIGHT exams each chain after N_iter iterations, where  
     N_iter = fN_sim_FF x N_par = fN_sim_FF x (N* + 2) 
   - "Falpha": After N_iter iterations, if the efficiency (e) of certain chain 
     is smaller than desired value, the step size is reduced by a factor of alpha: 
     \alpha = Falpha^[(e-eff_IDEAL_FF)/eff_IDEAL_FF] ; and when e > eff_IDEAL_FF, 
     the step size gets larger
   - "i_UpdateAlpha": = 0/1/2 = turn off adaptive step size (BAD!) / same \alpha 
     for every chain / one \alpha for each chain
   - "R_ini_FF" and "R_fin_FF": parameters that decide when to stop iterating. 
     After (N_par x fN_sim_FF ) steps, the typical variance of a parameter within 
     each of the Chains is compared to the variance of the same parameter between 
     all chains --> this boils down to monitoring an adimensional number "R". 
     When "R" is large, it means the chains are far apart in the parameter space. 
     This value can be gradually decreased during the loops: "R_fin_FF < R_ini_FF"
   - "IsGRTestHard_FF" = 0 / 1 = happy with an on-average convergence (use <R>); 
     / Requires all parameters satisfy the Gelman & Rubin test (use R_j); Normally 
     0 is Ok for First Fits 
   - "fNmax_steps_FF": The total number of steps per chain in each cooling 
     loop cannot exceed (N_par x fNmax_steps_FF )
   - "clip_method_option": NSIGMA / RELRES / ABSRES / NOCLIP -> determines the   
     method of pixel clipping during the "Clip & Refit" stage
   - "sig_clip_threshold": 
     * For "NSIGMA" method: excluding points whose |O_lambda - M_lambda| residual 
       deviates by more than sig_clip_threshold x local error in O_lambda
     * For "RELRES" method: excluding points whose |O_lambda - M_lambda| / e_lambda 
       deviates by more than sig_clip_threshold x the rms of same quantity over 
       all non-masked points 
     * For "ABSRES" method: excluding points whose |O_lambda - M_lambda|  
       deviates by more than sig_clip_threshold x the rms of same quantity over 
       all non-masked points 
   - "IMPORTANT": if the \chi^2 of two fits of the same spectrum to be compared, 
     make sure that the same pixels have been clipped; if the mask has already 
     clean all the unfitable pixels, "NOCLIP" method should be the primary choice.
   - "wei_nsig_threshould": correct suspicious errors with extremely small value, 
     set this parameter to 0 when you play with weights in mask file. 
   - "R_Burn_in" and "IsGRTestHard_BurnIn": parameters that control the convergence 
     of the Chains during the Burn in stage
   - "NEX0s_loops": number of loops in the EX0 phase (fits with a condensed base); 
     All parameters with EX0s_ are counterparts 
   - "EX0s_PopVector_option": = MIN / AVE; During the EX0s phase, the irrelevant 
     bases can be exlcuded.  This parameter controls how the fiducial population 
     vector is selected: MIN: choose the best one so far; AVE: uses current mean 
     over all chains
   - "EX0s_Threshold": population with contribution smaller than this value will 
     be rejected. 
   - "EX0s_method_option" = SMALL / CUMUL : the method that defines irrelevance. 
     SMALL: excluds all populations with contribution small than "EX0s_Threshold". 
     CUMUL: excluds the populations with cumulative contribution up to "EX0s_Threshold"
     The later is usually better
   - "fEX0_MinBaseSize": The minimum number bases allowed by STARLIGHT.
   - "Temp_ini_EX0s"; "Temp_fin_EX0s": Parameters that define the behaviors of the 
     Markov Chains during the fine tunning phase.  To make sure that all chains 
     are approaching the best solution, makes "Temp_fin_EX0s" << 1
   - "IMPORTANT": From FF phase to EX0s phase, the temperature should go from 
    >> 1 to << 1
   - "AV_low" and "AV_upp": lower and upper limit for AV
   - "fn_low" and "fn_upp": lower and upper limit for the normalized flux
   - "f_cut": minimum allowed normalized flux; useful when flag is not available. 
     Use f_cut < 0 to turn it off. 
   - "N_int_Gauss": number of pixels withing \pm 6 sigma in the Gaussian LOSVD 
     convolution integral
   - "i_FitPowerLaw" and "alpha_PowerLaw": about power law fitting
   - "IMPORTANT": When two fits of the same galaxies will be compared, use the 
     exactly same flags, configuration file, and the same random number generater!

## Tests using different configuration of STARLIGHT 

 + For this test, use CB07_Salp bases; S/N window is between 5000 and 5200 \AA; 
   The wavelength range for fitting is 3850.0-8200.0 \AA
 + Common parameters in configuration files: 
   - [l_norm] = 4060.0 \AA 
   - [llow_norm] = 4020 \AA; [lupp_norm] = 4100 \AA 
   - [AV_low] = -0.2; [AV_upp] = 0.8 
   - [fn_low] = 0.6;  [fn_upp] = 1.6
   - [v0_low] = -75.0; [v0_upp] = 75.0 
   - [vd_low] = 150.0; [vd_upp] = 380.0
   - [N_int_Gauss] = 51
   - [f_cut] = 0.001 

 ### Test Group 1: Clipping method and threshold 
   
   | Configuration Files   | default | group_1a | group_1b | group_1c | group_1d |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   | clip_method_option    | NSIGMA  |  NSIGMA  |  NOCLIP* |  RELRES* |  ABSRES* |
   | sig_clip_threshold    |  3.0    |   5.0*   |    3.0   |    3.0*  |    3.0*  |
   | N_chains              |   7     |    7     |     7    |     7    |     7    |
   | Falpha                |  2.0    |   2.0    |    2.0   |    2.0   |    2.0   |
   | Temp_ini_FF           |  100    |   100    |    100   |    100   |    100   |
   | Temp_fin_FF           |   1     |    1     |     1    |     1    |     1    |
   | R_ini_FF              |  1.3    |   1.3    |    1.3   |    1.3   |    1.3   |
   | R_fin_FF              |  1.3    |   1.3    |    1.3   |    1.3   |    1.3   |
   | IsGRTestHard_FF       |   0     |    0     |     0    |     0    |     0    |
   | N_loops_FF            |   3     |    3     |     3    |     3    |     3    |
   | R_Burn_in             |  1.2    |   1.2    |    1.2   |    1.2   |    1.2   |
   | IsGRTestHard_BurnIn   |   0     |    0     |     0    |     0    |     0    |
   | EX0s_PopVector_option |  MIN    |   MIN    |    MIN   |    MIN   |    MIN   |
   | EX0s_method_option    |  CUMUL  |   CUMUL  |    CUMUL |    CUMUL |    CUMUL |
   | EX0s_Threshold        |  0.02   |   0.02   |    0.02  |    0.02  |    0.02  |
   | Temp_ini_EX0s         |  1.0    |   1.0    |    1.0   |    1.0   |    1.0   |
   | Temp_ini_EX0s         |  0.001  |   0.001  |    0.001 |    0.001 |    0.001 |
   | R_ini_EX0s            |  1.2    |   1.2    |    1.2   |    1.2   |    1.2   |
   | R_fin_EX0s            |  1.0    |   1.0    |    1.0   |    1.0   |    1.0   |
   | N_loops_EX0s          |   5     |    5     |     5    |     5    |     5    |

 ### Test Group 2: N_chains and N_loops 
   
   | Configuration Files   |group_2a | group_2b | group_2c | group_2d | group_2e |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   | clip_method_option    | NSIGMA  |  NSIGMA  |  NSIGMA  |  NSIGMA  |  NSIGMA  |
   | sig_clip_threshold    |  3.0    |   3.0    |    3.0   |    3.0   |    3.0   |
   | N_chains              |   5     |    7     |     7    |     7    |    12    |
   | N_loops_FF            |   3     |    3     |     5    |     5    |    10    |
   | N_loops_EX0s          |   3     |    5     |     5    |     5    |    10    |
   | IsGRTestHard_FF       |   0     |    0     |     1    |     1    |     1    |
   | IsGRTestHard_BurnIn   |   0     |    0     |     1    |     1    |     1    |
   | R_ini_FF              |  1.3    |   1.3    |    1.3   |    1.2   |    1.1   |
   | R_fin_FF              |  1.3    |   1.3    |    1.3   |    1.2   |    1.1   |
   | R_Burn_in             |  1.3    |   1.2    |    1.2   |    1.2   |    1.1   |
   | R_ini_EX0s            |  1.3    |   1.2    |    1.2   |    1.2   |    1.1   |
   | R_fin_EX0s            |  1.0    |   1.0    |    1.0   |    1.0   |    1.0   |
   | Falpha                |  2.0    |   2.0    |    2.0   |    2.0   |    2.0   |
   | Temp_ini_FF           |  100    |   100    |    100   |    100   |    100   |
   | Temp_fin_FF           |   1     |    1     |     1    |     1    |     1    |
   | EX0s_PopVector_option |  MIN    |   MIN    |    MIN   |    MIN   |    MIN   |
   | EX0s_method_option    |  CUMUL  |   CUMUL  |    CUMUL |    CUMUL |    CUMUL |
   | EX0s_Threshold        |  0.02   |   0.02   |    0.02  |    0.02  |    0.02  |
   | Temp_ini_EX0s         |  1.0    |   1.0    |    1.0   |    1.0   |    1.0   |
   | Temp_ini_EX0s         |  0.001  |   0.001  |    0.001 |    0.001 |    0.001 |

 ### Test Group 3: EX0s_PopVector_option and Falpha 
   
   | Configuration Files   |group_3a | group_3b | group_3c | group_3d | group_3e |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   | clip_method_option    | NSIGMA  |  NSIGMA  |  NSIGMA  |  NSIGMA  |  NSIGMA  |
   | sig_clip_threshold    |  3.0    |   3.0    |   3.0    |   3.0    |   3.0    |
   | N_chains              |   7     |    7     |    7     |    7     |    7     |
   | N_loops_FF            |   5     |    5     |    5     |    5     |    5     |
   | N_loops_EX0s          |   5     |    5     |    5     |    5     |    5     |
   | IsGRTestHard_FF       |   1     |    1     |    1     |    1     |    1     |
   | IsGRTestHard_BurnIn   |   1     |    1     |    1     |    1     |    1     |
   | R_ini_FF              |  1.3    |   1.3    |   1.3    |   1.3    |   1.3    |
   | R_fin_FF              |  1.3    |   1.3    |   1.3    |   1.3    |   1.3    |
   | R_Burn_in             |  1.2    |   1.2    |   1.2    |   1.2    |   1.2    |
   | R_ini_EX0s            |  1.2    |   1.2    |   1.2    |   1.2    |   1.2    |
   | R_fin_EX0s            |  1.0    |   1.0    |   1.0    |   1.0    |   1.0    |
   | Falpha                |  2.0    |   2.0    |   2.0    |   1.5*   |   2.5*   |
   | Temp_ini_FF           |  100    |   100    |   100    |   100    |   100    |
   | Temp_fin_FF           |   1     |    1     |    1     |    1     |    1     |
   | EX0s_PopVector_option |  MIN    |   MIN    |   AVE*   |   MIN    |   MIN    |
   | EX0s_method_option    | SMALL*  |   CUMUL  |   CUMUL  |   CUMUL  |   CUMUL  |
   | EX0s_Threshold        |  0.02   |   0.05*  |   0.02   |   0.02   |   0.02   |
   | Temp_ini_EX0s         |  1.0    |   1.0    |   1.0    |   1.0    |   1.0    |
   | Temp_ini_EX0s         |  0.001  |   0.001  |   0.001  |   0.001  |   0.001  |

 ### Test Group 4: Temp_ini and Temp_fin 
   
   | Configuration Files   |group_4a | group_4b | group_4c | group_4d | group_4e |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   | clip_method_option    | NSIGMA  |  NSIGMA  |  NSIGMA  |  NSIGMA  |  NSIGMA  |
   | sig_clip_threshold    |  3.0    |   3.0    |   3.0    |   3.0    |   3.0    |
   | N_chains              |   7     |    7     |    7     |    7     |    7     |
   | N_loops_FF            |   5     |    5     |    5     |    5     |    5     |
   | N_loops_EX0s          |   5     |    5     |    5     |    5     |    5     |
   | IsGRTestHard_FF       |   1     |    1     |    1     |    1     |    1     |
   | IsGRTestHard_BurnIn   |   1     |    1     |    1     |    1     |    1     |
   | R_ini_FF              |  1.3    |   1.3    |   1.3    |   1.3    |   1.3    |
   | R_fin_FF              |  1.3    |   1.3    |   1.3    |   1.3    |   1.3    |
   | R_Burn_in             |  1.2    |   1.2    |   1.2    |   1.2    |   1.2    |
   | R_ini_EX0s            |  1.2    |   1.2    |   1.2    |   1.2    |   1.2    |
   | R_fin_EX0s            |  1.0    |   1.0    |   1.0    |   1.0    |   1.0    |
   | Falpha                |  2.0    |   2.0    |   2.0    |   2.0    |   2.0    |
   | Temp_ini_FF           | 1000*   |   10*    |   100    |   100    |  1000*   |
   | Temp_fin_FF           |   1     |    1     |    1     |    1     |    1     |
   | EX0s_PopVector_option |  MIN    |   MIN    |   MIN    |   MIN    |   MIN    |
   | EX0s_method_option    |  CUMUL  |   CUMUL  |   CUMUL  |   CUMUL  |   CUMUL  |
   | EX0s_Threshold        |  0.02   |   0.02   |   0.02   |   0.02   |   0.02   |
   | Temp_ini_EX0s         |  1.0    |   1.0    |   1.0    |   1.0    |   1.0    |
   | Temp_ini_EX0s         |  0.001  |   0.001  |  0.0001* |   0.01*  | 0.0001*  |

 ### Test Group 5: Extinction law 
   + Use group_2d.config --> group_5.config 

   | Configuration Files   |group_5a | group_5b | group_5c | group_5d | group_5e |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   | Extinction law        |   CAL   |    GD1   |   GD3    |   HZ2    |   HZ3    |

 ### Test Group 6: Mask
   + Use group_2d.config --> group_6.config 
   + Masks2: Remove masks for all Balmer absorption lines except for Hbeta & Halpha
   + Masks3: Remove masks for all Balmer absorption lines (other than Hbeta & Halpha), 
             and masks for weak forbidden lines and He lines: [NeIII], [SII], HeI, 
             [FeVII], [NI], [FeIII], [OI], [SIII], [ArIII] 
   + Masks4: Masks3 + 2x weight to CaII K lines, G-band absorption lines 
   + Masks5: Masks4 + 2x weight to IMF sensitive index 
   + Masks6: Masks1 + 2x weight to IMF sensitive index

   | Configuration Files   |group_6a | group_6b | group_6c | group_6d | group_6e |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   | Mask File             |  Masks2 |  Masks3  |  Masks4  |  Masks5  |  Masks6  |

 ### Test Group 7: FIT/FIX kinematics
   + Use group_2d.config --> group_7.config 
   + group_2d resulted in v0=0.0; vd=187.74
   + The vd measured by SDSS is vd=182.9 

   | Configuration Files   |group_7a | group_7b | group_7c | group_7d | group_7e |
   | --------------------- |:-------:|:--------:|:--------:|:--------:|:--------:|
   |  Fixed v0             |   0.0   |  -64.0   |   64.0   |    0.0   |   0.0    |
   |  Fixed vd             |  182.9  |  182.9   |  182.9   |  177.74  |  197.74  |


## Tests using different wavelength coverage

## Tests using different spectral bases



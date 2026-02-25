/******************************************
  PHASE 3: ADaM - ADLB
  Lab analysis - HbA1c change from baseline
  This is the PRIMARY ENDPOINT of your trial!
******************************************/
/******************************************
  PHASE 3: ADaM - ADLB FIXED
******************************************/

/* Step 1: Sort LB data */
PROC SORT DATA=sdtm.lb OUT=lb_sorted; 
  BY USUBJID LBTESTCD VISIT; 
RUN;

/* Step 2: Baseline lab values */
DATA baseline_lb;
  LENGTH USUBJID $30;
  SET lb_sorted;
  IF LBBLFL = "Y";
  BASE = LBSTRESN;
  KEEP USUBJID LBTESTCD BASE;
RUN;

/* Step 3: Merge LB with baseline only (same BY keys) */
DATA lb_with_base;
  LENGTH USUBJID $30;
  MERGE lb_sorted   (IN=inLB)
        baseline_lb (IN=inBASE);
  BY USUBJID LBTESTCD;
  IF inLB;

  CHG  = LBSTRESN - BASE;
  IF BASE NE 0 THEN PCHG = (CHG / BASE) * 100;

  /* Clinical significance flag */
  IF CHG <= -0.5 THEN CLINSIFL = "Y";
  ELSE CLINSIFL = "N";

  IF UPCASE(VISIT) = "BASELINE" THEN ABLFL   = "Y";
  IF UPCASE(VISIT) = "WEEK4"    THEN ANL01FL  = "Y";
RUN;

/* Step 4: Merge with ADSL by USUBJID only */
DATA adam.adlb;
  LENGTH USUBJID $30;
  MERGE lb_with_base (IN=inLB)
        adsl_sorted  (IN=inADSL
                      KEEP=USUBJID TRTP TRTPN SAFFL AGE SEX);
  BY USUBJID;
  IF inLB;

  KEEP STUDYID USUBJID SUBJID TRTP TRTPN SAFFL
       VISIT LBDTC LBTESTCD LBTEST
       LBSTRESN BASE CHG PCHG LBSTRESU
       ABLFL ANL01FL CLINSIFL;
RUN;

PROC SORT DATA=adam.adlb; BY USUBJID LBTESTCD VISIT; RUN;

/* Verify everything populated */
PROC FREQ DATA=adam.adlb;
  TABLES TRTP TRTPN SAFFL CLINSIFL / MISSING LIST;
RUN;

PROC PRINT DATA=adam.adlb; RUN;
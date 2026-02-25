libname adam "/home/u42943022/clinical_project_s/adam";

/******************************************
  PHASE 3: ADaM - ADSL
  One row per subject - the master dataset
******************************************/

DATA adam.adsl;
  SET sdtm.dm;

  LENGTH SAFFL $1 ITTFL $1 TRTPN 8 TRTP $20;

  /* Treatment variables */
  TRTP  = ARMCD;   /* Planned treatment description */

  /* Numeric treatment code for analysis */
  IF ARMCD = "DRUG"    THEN TRTPN = 1;
  IF ARMCD = "PLACEBO" THEN TRTPN = 2;

  /* Analysis population flags */
  SAFFL = "Y";   /* Safety population - all subjects who received treatment */
  ITTFL = "Y";   /* Intent-to-treat population */

  /* Convert baseline date to SAS date for calculations */
  TRTSDT = INPUT(strip(RFSTDTC), ANYDTDTE10.);  /* Treatment start date */
  FORMAT TRTSDT DATE9.;

  KEEP STUDYID USUBJID SUBJID AGE SEX RACE 
       ARMCD TRTP TRTPN COUNTRY RFSTDTC TRTSDT
       SAFFL ITTFL;
RUN;

PROC SORT DATA=adam.adsl; BY USUBJID; RUN;
PROC PRINT DATA=adam.adsl; RUN;
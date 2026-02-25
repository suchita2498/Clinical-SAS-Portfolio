/******************************************
  PHASE 2: SDTM - VS DOMAIN
  Vital Signs - needs to be VERTICAL
  (one record per test per visit per subject)
******************************************/

/* Step 1: Systolic BP */
DATA vs1;
length VSTESTCD $20 VSTEST $50;
  SET raw.raw_vs;
  VSTESTCD = "SYSBP";
  VSTEST   = "Systolic Blood Pressure";
  VSSTRESN = SYSBP;
  VSSTRESU = "mmHg";
RUN;

/* Step 2: Diastolic BP */
DATA vs2;
LENGTH VSTESTCD $20 VSTEST $50;
  SET raw.raw_vs;
  VSTESTCD = "DIABP";
  VSTEST   = "Diastolic Blood Pressure";
  VSSTRESN = DIABP;
  VSSTRESU = "mmHg";
RUN;

/* Step 3: Weight */
DATA vs3;
LENGTH VSTESTCD $20 VSTEST $50;
  SET raw.raw_vs;
  VSTESTCD = "WEIGHT";
  VSTEST   = "Body Weight";
  VSSTRESN = WEIGHT;
  VSSTRESU = "kg";
RUN;

/* Combine all into one vertical VS domain */
DATA sdtm.vs;
  SET vs1 vs2 vs3;

  LENGTH STUDYID $20 DOMAIN $2 USUBJID $20;

  STUDYID = "DIAB-2023";
  DOMAIN  = "VS";
  USUBJID = CATS(STUDYID,"-",SUBJID);

  /* Flag baseline visits */
  IF UPCASE(VISIT) = "BASELINE" THEN VSBLFL = "Y";

  KEEP STUDYID DOMAIN USUBJID SUBJID VISIT VSDTC 
       VSTESTCD VSTEST VSSTRESN VSSTRESU VSBLFL;
RUN;

PROC SORT DATA=sdtm.vs; BY USUBJID VSTESTCD VISIT; RUN;
PROC PRINT DATA=sdtm.vs; RUN;
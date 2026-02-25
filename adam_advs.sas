/* Step 1: Fix USUBJID length in vs_sorted */
DATA vs_sorted_fix;
  LENGTH USUBJID $30;
  SET vs_sorted;
RUN;

/* Step 2: Fix USUBJID length in baseline_vs */
DATA baseline_vs;
  LENGTH USUBJID $30;
  SET vs_sorted_fix;
  IF VSBLFL = "Y";
  BASE = VSSTRESN;
  KEEP USUBJID VSTESTCD BASE;
RUN;

/* Step 3: Merge VS with baseline */
DATA vs_with_base;
  LENGTH USUBJID $30;
  MERGE vs_sorted_fix (IN=inVS)
        baseline_vs   (IN=inBASE);
  BY USUBJID VSTESTCD;
  IF inVS;

  CHG  = VSSTRESN - BASE;
  IF BASE NE 0 THEN PCHG = (CHG / BASE) * 100;

  IF UPCASE(VISIT) = "BASELINE" THEN ABLFL   = "Y";
  IF UPCASE(VISIT) = "WEEK4"    THEN ANL01FL  = "Y";
RUN;

/* Step 4: Merge with ADSL */
DATA adam.advs;
  LENGTH USUBJID $30;
  MERGE vs_with_base (IN=inVS)
        adsl_sorted  (IN=inADSL
                      KEEP=USUBJID TRTP TRTPN SAFFL AGE SEX);
  BY USUBJID;
  IF inVS;

  KEEP STUDYID USUBJID SUBJID TRTP TRTPN SAFFL
       VISIT VSDTC VSTESTCD VSTEST
       VSSTRESN BASE CHG PCHG VSSTRESU
       ABLFL ANL01FL VSBLFL;
RUN;

PROC SORT DATA=adam.advs; BY USUBJID VSTESTCD VISIT; RUN;

/* Verify TRTP and TRTPN populated correctly */
PROC FREQ DATA=adam.advs;
  TABLES TRTP TRTPN SAFFL / MISSING LIST;
RUN;

PROC PRINT DATA=adam.advs; RUN;
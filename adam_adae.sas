/******************************************
  PHASE 3: ADaM - ADAE
  Adverse event analysis with treatment info
******************************************/

/* First merge AE with ADSL to get treatment info */
PROC SORT DATA=sdtm.ae OUT=ae_sorted; BY USUBJID; RUN;

DATA adam.adae;
  MERGE ae_sorted   (IN=inAE)
        adam.adsl   (IN=inADSL 
                     KEEP=USUBJID TRTP TRTPN SAFFL AGE SEX);
  BY USUBJID;
  IF inAE;  /* Keep only subjects with AE records */

  LENGTH AEDECOD $100 TRTEMFL $1;

  /* Decode AE term - in real trials this maps to MedDRA */
  AEDECOD = PROPCASE(STRIP(AETERM));

  /* Treatment emergent flag - AE started after treatment began */
  TRTEMFL = "Y";  /* Simplified - in real trials compare dates */

  /* Severity numeric for sorting/analysis */
  IF STRIP(AESEV) = "Mild"     THEN ASEVN = 1;
  IF STRIP(AESEV) = "Moderate" THEN ASEVN = 2;
  IF STRIP(AESEV) = "Severe"   THEN ASEVN = 3;

  KEEP STUDYID USUBJID SUBJID TRTP TRTPN SAFFL
       AESEQ AETERM AEDECOD AESTDTC AEENDTC 
       AESEV ASEVN AEREL TRTEMFL;
RUN;

PROC SORT DATA=adam.adae; BY USUBJID AESTDTC; RUN;
PROC PRINT DATA=adam.adae; RUN;
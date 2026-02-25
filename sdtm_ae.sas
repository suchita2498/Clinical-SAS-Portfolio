

/******************************************
  PHASE 2: SDTM - AE DOMAIN
  Adverse Events
******************************************/

DATA sdtm.ae;
  SET raw.raw_ae;

  LENGTH STUDYID $20 DOMAIN $2 USUBJID $20 AESEQ 8;

  STUDYID = "DIAB-2023";
  DOMAIN  = "AE";
  USUBJID = CATS(STUDYID,"-",SUBJID);

  /* Sequence number per subject */
  AESEQ + 1;
  BY SUBJID; /* Will need sorting first */
  IF FIRST.SUBJID THEN AESEQ = 1;

  /* Standardize severity to CDISC terminology */
  AESEV = PROPCASE(STRIP(AESEV));  /* Mild, Moderate, Severe */

  KEEP STUDYID DOMAIN USUBJID SUBJID AESEQ AETERM 
       AESTDTC AEENDTC AESEV AEREL;

RUN;

/* Sort first, then re-run above — or sort here */
PROC SORT DATA=sdtm.ae; BY USUBJID AESTDTC; RUN;

PROC PRINT DATA=sdtm.ae; RUN;
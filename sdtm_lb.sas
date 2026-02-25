/******************************************
  PHASE 2: SDTM - LB DOMAIN
  Lab Results (HbA1c)
******************************************/

DATA sdtm.lb;
  SET raw.raw_lb;

  LENGTH STUDYID $20 DOMAIN $2 USUBJID $20;

  STUDYID  = "DIAB-2023";
  DOMAIN   = "LB";
  USUBJID  = CATS(STUDYID,"-",SUBJID);

  /* Rename lab variables to SDTM names */
  LBTESTCD = STRIP(LBTEST);       /* Test code */
  LBORRESU = STRIP(LBSTRESU);     /* Original unit */

  /* Flag baseline */
  IF UPCASE(VISIT) = "BASELINE" THEN LBBLFL = "Y";

  KEEP STUDYID DOMAIN USUBJID SUBJID VISIT LBDTC 
       LBTESTCD LBTEST LBSTRESN LBSTRESU LBORRESU LBBLFL;
RUN;

PROC SORT DATA=sdtm.lb; BY USUBJID LBTESTCD VISIT; RUN;
PROC PRINT DATA=sdtm.lb; RUN;
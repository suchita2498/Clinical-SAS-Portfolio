libname sdtm "/home/u42943022/clinical_project_s/sdtm";
/******************************************
  PHASE 2: SDTM - DM DOMAIN
  Demographics
******************************************/

/* Step 1: Create SDTM DM dataset */
data sdtm.dm;

    set raw.raw_demog
        (rename=(
            AGE     = RAW_AGE
            SEX     = RAW_SEX
            RACE    = RAW_RACE
            ARM     = RAW_ARM
            COUNTRY = RAW_COUNTRY
            RFSTDTC = RAW_RFSTDTC
        ));

    length STUDYID $8
           DOMAIN  $2
           USUBJID $30
           SUBJID  $10
           AGEU    $5
           SEX     $1
           RACE    $40
           ARMCD   $8
           ARM     $40
           COUNTRY $3
           RFSTDTC $20;

    /* Study identification */

    STUDYID = "DM001";
    DOMAIN  = "DM";

    /* Subject identification */

    SUBJID  = strip(SUBJID);
    USUBJID = catx("-", STUDYID, SUBJID);

    /* Age */

    AGE  = RAW_AGE;
    AGEU = "YEARS";

    /* Sex mapping */

    SEX = upcase(strip(RAW_SEX));

    /* Race mapping */

    if upcase(strip(RAW_RACE)) = "WHITE" then
        RACE = "WHITE";

    else if upcase(strip(RAW_RACE)) = "ASIAN" then
        RACE = "ASIAN";

    else if upcase(strip(RAW_RACE)) = "BLACK" then
        RACE = "BLACK OR AFRICAN AMERICAN";

    /* Treatment arm mapping */

    if upcase(strip(RAW_ARM)) = "DRUG" then do;
        ARMCD = "DRUG";
        ARM   = "DRUG";
    end;

    else if upcase(strip(RAW_ARM)) = "PLACEBO" then do;
        ARMCD = "PBO";
        ARM   = "PLACEBO";
    end;

    /* Country mapping */

    if upcase(strip(RAW_COUNTRY)) = "INDIA" then
        COUNTRY = "IND";

    /* Reference start date */

    RFSTDTC = strip(RAW_RFSTDTC);

    /* Keep SDTM DM variables */

    keep STUDYID DOMAIN USUBJID SUBJID
         AGE AGEU SEX RACE
         ARMCD ARM COUNTRY RFSTDTC;

    label
        STUDYID = "Study Identifier"
        DOMAIN  = "Domain Abbreviation"
        USUBJID = "Unique Subject Identifier"
        SUBJID  = "Subject Identifier"
        AGE     = "Age"
        AGEU    = "Age Units"
        SEX     = "Sex"
        RACE    = "Race"
        ARMCD   = "Planned Arm Code"
        ARM     = "Description of Planned Arm"
        COUNTRY = "Country"
        RFSTDTC = "Subject Reference Start Date/Time";

run;


/* Step 2: Check the output */

proc contents data=sdtm.dm;
run;

proc print data=sdtm.dm;
run;


/* Step 3: Check number of subjects */

proc sql;
    select count(*) as Total_Records,
           count(distinct USUBJID) as Unique_Subjects
    from sdtm.dm;
quit;

/* Step 4: Check duplicate subject identifiers */

proc sort data=sdtm.dm
          out=dm_check
          dupout=dm_duplicates
          nodupkey;
    by USUBJID;
run;

proc print data=dm_duplicates;
    title "Duplicate Subject Records";
run;




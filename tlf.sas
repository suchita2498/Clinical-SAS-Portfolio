LIBNAME adam "/home/u42943022/clinical_project_s/adam";

/* All outputs will save as RTF - opens in Word */
ODS RTF FILE="/home/u42943022/clinical_project_s/output/TLF_Report.rtf"
        STYLE=Journal;
ODS GRAPHICS ON;

/******************************************
  TABLE 1: Demographics Summary
  Standard "Table 1" in every clinical trial
******************************************/

TITLE1 "Table 14.1.1";
TITLE2 "Summary of Demographics";
TITLE3 "Safety Population";
FOOTNOTE1 "DRUG = Investigational Drug | PLACEBO = Placebo";
FOOTNOTE2 "Source: ADSL";

PROC TABULATE DATA=adam.adsl;
  CLASS TRTP;
  VAR AGE;
  TABLE AGE* (N MEAN STD MEDIAN MIN MAX), TRTP /
        BOX="Age (Years)";
RUN;


/* Sex summary - use PROC FREQ for character variables */
PROC FREQ DATA=adam.adsl;
  TABLES SEX * TRTP / NOCOL NOPERCENT NOROW;
  TITLE1 "Table 14.1.1(continued)";
  TITLE2 "Summary of Sex by Treatment Arm";
RUN;

/* Race summary */
PROC FREQ DATA=adam.adsl;
  TABLES RACE * TRTP / NOCOL NOPERCENT NOROW;
  TITLE1 "Table 14.1.1(continued) ";
  TITLE2 "Summary of Race by Treatment Arm";
RUN;
TITLE;
FOOTNOTE;

/******************************************
  TABLE 2: Adverse Event Summary
  By treatment arm and severity
******************************************/

TITLE1 "Table 14.3.1";
TITLE2 "Summary of Treatment-Emergent Adverse Events";
TITLE3 "Safety Population";
FOOTNOTE1 "TEAE = Treatment-Emergent Adverse Event";
FOOTNOTE2 "Source: ADAE";

/* AE count by term and treatment arm */
PROC FREQ DATA=adam.adae;
  TABLES AEDECOD * TRTP / NOCOL NOPERCENT NOROW;
  TITLE1 "Table 14.3.1(continued)";
  TITLE2 "TEAE Count by Preferred Term and Treatment Arm";
RUN;

/* AE count by severity and treatment arm */
PROC FREQ DATA=adam.adae;
  TABLES AESEV * TRTP / NOCOL NOPERCENT NOROW;
  TITLE1 "Table 14.3.1(continued)";
  TITLE2 "TEAE Count by Severity and Treatment Arm";
RUN;

/* AE count by relationship and treatment arm */
PROC FREQ DATA=adam.adae;
  TABLES AEREL * TRTP / NOCOL NOPERCENT NOROW;
  TITLE1 "Table 14.3.1(continued) ";
  TITLE2 "TEAE Count by Relationship to Study Drug and Treatment Arm";
RUN;

/* AE by severity breakdown */
PROC TABULATE DATA=adam.adae;
  CLASS TRTP ;
  VAR ASEVN;
  TABLE ASEVN * (N MEAN), TRTP/
        BOX="Severity Score";
RUN;

/******************************************
  TABLE 3: HbA1c Change from Baseline
  Primary Efficacy Endpoint
******************************************/

TITLE1 "Table 14.2.1";
TITLE2 "Summary of HbA1c (%) Change from Baseline at Week 4";
TITLE3 "Intent-to-Treat Population";
FOOTNOTE1 "CHG = Week 4 Value - Baseline Value";
FOOTNOTE2 "PCHG = Percent Change from Baseline";
FOOTNOTE3 "Source: ADLB";

/* Week 4 only */
DATA adlb_wk4;
  SET adam.adlb;
  IF ANL01FL = "Y" AND LBTESTCD = "HBA1C";
RUN;

PROC TABULATE DATA=adlb_wk4;
  CLASS TRTP;
  VAR BASE LBSTRESN CHG PCHG;
  TABLE (BASE LBSTRESN CHG PCHG),
        TRTP * (N MEAN STD MIN MAX) /
        BOX="HbA1c Parameter";
RUN;

/******************************************
  LISTING 1: Subject-Level Adverse Events
  Individual patient data listing
******************************************/

TITLE1 "Listing 16.2.1";
TITLE2 "Listing of All Treatment-Emergent Adverse Events";
TITLE3 "Safety Population";
FOOTNOTE1 "Adverse events sorted by Subject ID and Start Date";
FOOTNOTE2 "Source: ADAE";

PROC REPORT DATA=adam.adae NOWD SPLIT="|";
  COLUMN USUBJID TRTP AETERM AESTDTC AEENDTC AESEV AEREL;
  
  DEFINE USUBJID  / DISPLAY "Subject ID"       WIDTH=20;
  DEFINE TRTP     / DISPLAY "Treatment"        WIDTH=10;
  DEFINE AETERM   / DISPLAY "Adverse Event"    WIDTH=20;
  DEFINE AESTDTC  / DISPLAY "Start Date"       WIDTH=12;
  DEFINE AEENDTC  / DISPLAY "End Date"         WIDTH=12;
  DEFINE AESEV    / DISPLAY "Severity"         WIDTH=10;
  DEFINE AEREL    / DISPLAY "Relationship"     WIDTH=12;
RUN;

/******************************************
  FIGURE 1: HbA1c Mean Change from Baseline
  Primary Efficacy Visualization
******************************************/

TITLE1 "Figure 14.2.1";
TITLE2 "Mean HbA1c (%) by Visit and Treatment Arm";
FOOTNOTE1 "Error bars represent Standard Deviation";
FOOTNOTE2 "Source: ADLB";

/* Calculate means per visit per treatment */
PROC MEANS DATA=adam.adlb NOPRINT;
  CLASS TRTP VISIT;
  VAR LBSTRESN;
  OUTPUT OUT=hba1c_means MEAN=MEAN STD=STD N=N;
RUN;

DATA hba1c_means;
  SET hba1c_means;
  IF TRTP NE "" AND VISIT NE "";
  /* Visit order for X axis */
  IF VISIT = "BASELINE" THEN VISITN = 0;
  IF VISIT = "WEEK4"    THEN VISITN = 4;
RUN;

PROC SGPLOT DATA=hba1c_means;
  SERIES X=VISITN Y=MEAN / GROUP=TRTP 
         MARKERS LINEATTRS=(THICKNESS=2)
         MARKERATTRS=(SIZE=10);
  HIGHLOW X=VISITN HIGH=STD LOW=STD / GROUP=TRTP;
  XAXIS LABEL="Week" VALUES=(0 4) VALUESDISPLAY=("Baseline" "Week 4");
  YAXIS LABEL="Mean HbA1c (%)" MIN=6 MAX=10;
  KEYLEGEND / TITLE="Treatment Arm";
RUN;


TITLE;
FOOTNOTE;

ODS GRAPHICS OFF;
ODS RTF CLOSE;

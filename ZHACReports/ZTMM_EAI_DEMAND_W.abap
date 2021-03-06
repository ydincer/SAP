*&-------------------------------------------------------------*
*& Report ZTMM_EAI_DEMAND_W
*&-------------------------------------------------------------*
*System name         : HMI SYSTEM
*Sub system name     : ARCHIVE
*Program name        : Archiving : ZTMM_EAI_DEMAND (Write)
*Program descrition  : Generated automatically by the ZHACR00800
*Created on   : 20130603          Created by   : T00302
*Changed on :                           Changed by    :
*Changed descrition :
*"-------------------------------------------------------------*
REPORT ZTMM_EAI_DEMAND_W .

***** Include TOP
INCLUDE ZTMM_EAI_DEMAND_T .

***** Selection screen.
SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-001.
*SELECT-OPTIONS S_BEIKZ FOR ZTMM_EAI_DEMAND-BEIKZ.
*SELECT-OPTIONS S_BESKZ FOR ZTMM_EAI_DEMAND-BESKZ.
*SELECT-OPTIONS S_EDATE FOR ZTMM_EAI_DEMAND-EDATE.
*SELECT-OPTIONS S_EDMD_T FOR ZTMM_EAI_DEMAND-EDMD_TYPE.
*SELECT-OPTIONS S_EPART_ FOR ZTMM_EAI_DEMAND-EPART_NO.
*SELECT-OPTIONS S_LINE FOR ZTMM_EAI_DEMAND-LINE.
*SELECT-OPTIONS S_MODEL_ FOR ZTMM_EAI_DEMAND-MODEL_CODE.
*SELECT-OPTIONS S_PDATE FOR ZTMM_EAI_DEMAND-PDATE.
*SELECT-OPTIONS S_PLNT FOR ZTMM_EAI_DEMAND-PLNT.
*SELECT-OPTIONS S_PTYPE FOR ZTMM_EAI_DEMAND-PTYPE.
*SELECT-OPTIONS S_RPID FOR ZTMM_EAI_DEMAND-RPID.
SELECT-OPTIONS S_TAIT_T FOR ZTMM_EAI_DEMAND-TAIT_TARG_D.
SELECTION-SCREEN SKIP 1.
PARAMETERS: TESTRUN               AS CHECKBOX,
            CREATE    DEFAULT  'X' AS CHECKBOX,
            OBJECT    LIKE         ARCH_IDX-OBJECT
                      DEFAULT 'ZTMM_EAI_D' NO-DISPLAY .
SELECTION-SCREEN SKIP 1.
PARAMETERS: COMMENT   LIKE ADMI_RUN-COMMENTS OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B2.

***** Main login - common routine of include
PERFORM ARCHIVE_PROCESS.

***** Common routine
INCLUDE ZITARCW.

***** History for each object,
***** processing required for each part defined,
FORM OPEN_CURSOR_FOR_DB.
  OPEN CURSOR WITH HOLD G_CURSOR FOR
SELECT * FROM ZTMM_EAI_DEMAND
*WHERE BEIKZ IN S_BEIKZ
*AND BESKZ IN S_BESKZ
*AND EDATE IN S_EDATE
*AND EDMD_TYPE IN S_EDMD_T
*AND EPART_NO IN S_EPART_
*AND LINE IN S_LINE
*AND MODEL_CODE IN S_MODEL_
*AND PDATE IN S_PDATE
*AND PLNT IN S_PLNT
*AND PTYPE IN S_PTYPE
*AND RPID IN S_RPID.
WHERE TAIT_TARG_D IN S_TAIT_T.
ENDFORM.
FORM MAKE_ARCHIVE_OBJECT_ID.



ENDFORM.

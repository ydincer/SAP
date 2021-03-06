FUNCTION ZQM_SCRAP_DISPOSE .
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(I_QMNUM) LIKE  QMEL-QMNUM
*"     VALUE(I_TYPE) TYPE  CHAR1
*"     VALUE(I_RKMNG) LIKE  QMEL-RKMNG
*"  EXPORTING
*"     VALUE(O_WERKS) LIKE  QMEL-MAWERK
*"     VALUE(O_MATNR) LIKE  QMEL-MATNR
*"     VALUE(O_QMGRP) LIKE  QMEL-QMGRP
*"     VALUE(O_QMCOD) LIKE  QMEL-QMCOD
*"     VALUE(O_RKMNG) LIKE  QMEL-RKMNG
*"     VALUE(O_OTGRP) LIKE  VIQMFE-OTGRP
*"     VALUE(O_OTEIL) LIKE  VIQMFE-OTEIL
*"     VALUE(O_FEGRP) LIKE  VIQMFE-FEGRP
*"     VALUE(O_FECOD) LIKE  VIQMFE-FECOD
*"     VALUE(O_URGRP) LIKE  VIQMUR-URGRP
*"     VALUE(O_URCOD) LIKE  VIQMUR-URCOD
*"     VALUE(O_TXT04) LIKE  TJ30T-TXT04
*"     VALUE(O_STTXT) LIKE  RIWO00-STTXT
*"     VALUE(O_TOLOCA) TYPE  CHAR20
*"     VALUE(O_LIFNUM) LIKE  QMEL-LIFNUM
*"     VALUE(O_RESULT) TYPE  CHAR1
*"     VALUE(O_MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------
  DATA: BEGIN OF WA_DATA,
          WERKS LIKE  QMEL-MAWERK,
          MATNR LIKE QMEL-MATNR,
          QMGRP LIKE  QMEL-QMGRP,
          QMCOD LIKE  QMEL-QMCOD,
          RKMNG LIKE  QMEL-RKMNG,
          OTGRP LIKE  VIQMFE-OTGRP,
          OTEIL LIKE  VIQMFE-OTEIL,
          FEGRP LIKE  VIQMFE-FEGRP,
          FECOD LIKE  VIQMFE-FECOD,
          URGRP LIKE  VIQMUR-URGRP,
          URCOD LIKE  VIQMUR-URCOD,
          TXT04 LIKE  TJ30T-TXT04,
          STTXT LIKE  RIWO00-STTXT,
          TOLOCA(20),  " PKHD-LGPLA,
          LIFNUM LIKE QMEL-LIFNUM,
          RESULT TYPE  CHAR1,
          MESSAGE TYPE  CHAR255,
          END OF WA_DATA.

 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
         EXPORTING
              input  = i_qmnum
         IMPORTING
              output = i_qmnum.

  CASE I_TYPE.
    WHEN 'S'.
      IF I_QMNUM IS INITIAL.
        O_RESULT = 'E'.
        O_MESSAGE = 'No Notification Number'.
      ELSE.
        PERFORM GET_QMNUM_DATA USING WA_DATA
                         I_QMNUM O_RESULT O_MESSAGE.
        IF O_RESULT = 'S'.
          O_WERKS = WA_DATA-WERKS.
          O_MATNR = WA_DATA-MATNR.
          O_QMGRP = WA_DATA-QMGRP.
          O_QMCOD = WA_DATA-QMCOD.
          O_RKMNG = WA_DATA-RKMNG.
          O_OTGRP = WA_DATA-OTGRP.
          O_OTEIL = WA_DATA-OTEIL.
          O_FEGRP = WA_DATA-FEGRP.
          O_FECOD = WA_DATA-FECOD.
          O_URGRP = WA_DATA-URGRP.
          O_URCOD = WA_DATA-URCOD.
          O_TXT04 = WA_DATA-TXT04.
          O_STTXT = WA_DATA-STTXT.
          O_TOLOCA = WA_DATA-TOLOCA.
          O_LIFNUM = WA_DATA-LIFNUM.
        ENDIF.
      ENDIF.
    WHEN 'P'.
      PERFORM PROCESS_DISPOSITION USING I_QMNUM O_RESULT O_MESSAGE.
  ENDCASE.
ENDFUNCTION.

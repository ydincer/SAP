FUNCTION Z_HR_ESS_GET_EMP_TAX_DATA.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(EMPLOYEE_NUMBER) LIKE  BAPI7004-PERNR
*"  TABLES
*"      ZESS_TAX STRUCTURE  ZESS_EMP_TAX
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------

  __cls P0210.

  CALL FUNCTION 'HR_READ_INFOTYPE'
       EXPORTING
            PERNR     = EMPLOYEE_NUMBER
            INFTY     = '0210'
            BEGDA     = SY-DATUM
            ENDDA     = '99991231'
            BYPASS_BUFFER = 'X'
       TABLES
            INFTY_TAB = P0210.


  LOOP AT P0210.

    ZESS_TAX-TAX_AUTH    = P0210-TAURT.
    SELECT SINGLE LTEXT TAXLV
    INTO (ZESS_TAX-TAX_AUTH_LTEXT,ZESS_TAX-TAX_LEVEL)
    FROM T5UTZ WHERE TAXAU = P0210-TAURT.

*A	Federal
*B	State
*C	County
*D	City
*E	School District
*F	Other

    CASE ZESS_TAX-TAX_LEVEL.
      WHEN 'A'.
        ZESS_TAX-TAX_LEVEL_DESC = 'Federal'.
      WHEN 'B'.
        ZESS_TAX-TAX_LEVEL_DESC = 'State'.
      WHEN 'C'.
        ZESS_TAX-TAX_LEVEL_DESC = 'Country'.
      WHEN 'D'.
        ZESS_TAX-TAX_LEVEL_DESC = 'City'.
      WHEN 'E'.
        ZESS_TAX-TAX_LEVEL_DESC = 'School District'.
      WHEN 'F'.
        ZESS_TAX-TAX_LEVEL_DESC = 'Other'.
    ENDCASE.

    ZESS_TAX-FILING_STATUS = P0210-TXSTA.

    SELECT SINGLE LTEXT
    INTO (ZESS_TAX-F_STATUS_LTEXT)
    FROM T5UTK WHERE TAXAU = P0210-TAURT
                 AND TXSTA = P0210-TXSTA
                 AND ENDDA = '99991231'.

    ZESS_TAX-NO_OF_ALLOWANCES = P0210-NBREX.
    ZESS_TAX-EXEMPTION_AMOUNT = P0210-AMTEX.
    ZESS_TAX-NO_OF_ADD_ALLOW  = P0210-ADEXN.
    ZESS_TAX-ADD_EXEMPTION_AMT = P0210-ADEXA.
    ZESS_TAX-NO_OF_P_ALLOW     = P0210-PEREX.
    ZESS_TAX-NO_OF_DEP_ALLOW   = P0210-DEPEX.
    ZESS_TAX-TAX_EXEMPTION_IND = P0210-EXIND.
    ZESS_TAX-IRS_MANDATES_IND  = P0210-EXIND.               "IRSL1.
    ZESS_TAX-ADD_WITHHOLDING   = P0210-EXAMT.
    ZESS_TAX-DEF_FORMULA_NUM   = P0210-FRMNR. "FRMND.
    ZESS_TAX-ALT_FORMULA_NUM   = P0210-FRMNR.
    ZESS_TAX-NRATX = P0210-NRATX.
    APPEND ZESS_TAX.
  ENDLOOP.

  RETURN-TYPE = 'S'.
  RETURN-MESSAGE = 'Success!'.
  APPEND RETURN.

ENDFUNCTION.

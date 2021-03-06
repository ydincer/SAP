FUNCTION ZIM_GET_INSURANCE_DOC.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(ZFREQNO) LIKE  ZTINS-ZFREQNO
*"     VALUE(ZFINSEQ) LIKE  ZTINS-ZFINSEQ
*"     VALUE(ZFAMDNO) LIKE  ZTINS-ZFAMDNO
*"  EXPORTING
*"     VALUE(W_ZTINS) LIKE  ZTINS STRUCTURE  ZTINS
*"     VALUE(W_ZTINSRSP) LIKE  ZTINSRSP STRUCTURE  ZTINSRSP
*"     VALUE(W_ZTINSSG3) LIKE  ZTINSSG3 STRUCTURE  ZTINSSG3
*"  TABLES
*"      IT_ZSINSAGR STRUCTURE  ZSINSAGR
*"      IT_ZSINSSG2 STRUCTURE  ZSINSSG2
*"      IT_ZSINSSG5 STRUCTURE  ZSINSSG5
*"      IT_ZSINSAGR_ORG STRUCTURE  ZSINSAGR OPTIONAL
*"      IT_ZSINSSG2_ORG STRUCTURE  ZSINSSG2 OPTIONAL
*"      IT_ZSINSSG5_ORG STRUCTURE  ZSINSSG5 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"      NOT_INPUT
*"----------------------------------------------------------------------
  REFRESH : IT_ZSINSAGR, IT_ZSINSSG2, IT_ZSINSSG5.
  REFRESH : IT_ZSINSAGR_ORG, IT_ZSINSSG2_ORG, IT_ZSINSSG5_ORG.
  CLEAR : W_ZTINS, W_ZTINSRSP, W_ZTINSSG3.

  IF ZFREQNO IS INITIAL.
     RAISE NOT_INPUT.
  ENDIF.
* insurance Header Table
  SELECT SINGLE * INTO   W_ZTINS   FROM ZTINS
                  WHERE  ZFREQNO   EQ   ZFREQNO
                  AND    ZFINSEQ   EQ   ZFINSEQ
                  AND    ZFAMDNO   EQ   ZFAMDNO.

  IF SY-SUBRC NE 0.
     RAISE NOT_FOUND.
  ENDIF.
* insurance Response Table
  SELECT SINGLE * INTO   W_ZTINSRSP FROM ZTINSRSP
                  WHERE  ZFREQNO   EQ   ZFREQNO
                  AND    ZFINSEQ   EQ   ZFINSEQ
                  AND    ZFAMDNO   EQ   ZFAMDNO.
* insurance Seg. 3 Table
  SELECT SINGLE * INTO   W_ZTINSSG3 FROM ZTINSSG3
                  WHERE  ZFREQNO   EQ   ZFREQNO
                  AND    ZFINSEQ   EQ   ZFINSEQ
                  AND    ZFAMDNO   EQ   ZFAMDNO.

* insurance Seg. AGR Table
  SELECT *  INTO CORRESPONDING FIELDS OF TABLE IT_ZSINSAGR
            FROM ZTINSAGR
            WHERE  ZFREQNO   EQ   ZFREQNO
            AND    ZFINSEQ   EQ   ZFINSEQ
            AND    ZFAMDNO   EQ   ZFAMDNO
            ORDER BY  ZFLAGR.

  IT_ZSINSAGR_ORG[] = IT_ZSINSAGR[].

*  LOOP AT IT_ZSINSAGR.
*    W_TABIX = SY-TABIX.
*    MODIFY IT_ZSOFFO INDEX W_TABIX.
*     MOVE-CORRESPONDING   IT_ZSINSAGR   TO   IT_ZSINSAGR_ORG.
*     APPEND IT_ZSINSAGR_ORG.
*  ENDLOOP.

* insurance Seg. 2 Table
  SELECT *  INTO CORRESPONDING FIELDS OF TABLE IT_ZSINSSG2
            FROM ZTINSSG2
            WHERE  ZFREQNO   EQ   ZFREQNO
            AND    ZFINSEQ   EQ   ZFINSEQ
            AND    ZFAMDNO   EQ   ZFAMDNO
            ORDER BY  ZFLSG2.

  IT_ZSINSSG2_ORG[] = IT_ZSINSSG2[].

*  LOOP AT IT_ZSINSSG2.
*    W_TABIX = SY-TABIX.
*    MODIFY IT_ZSOFFO INDEX W_TABIX.
*     MOVE-CORRESPONDING   IT_ZSINSSG2   TO   IT_ZSINSSG2_ORG.
*     APPEND IT_ZSINSSG2_ORG.
*  ENDLOOP.

* insurance Seg. 5 Table
  SELECT *  INTO CORRESPONDING FIELDS OF TABLE IT_ZSINSSG5
            FROM ZTINSSG5
            WHERE  ZFREQNO   EQ   ZFREQNO
            AND    ZFINSEQ   EQ   ZFINSEQ
            ORDER BY  ZFLSG5.

  IT_ZSINSSG5_ORG[] = IT_ZSINSSG5[].

*  LOOP AT IT_ZSINSSG5.
*    W_TABIX = SY-TABIX.
*    MODIFY IT_ZSOFFO INDEX W_TABIX.
*     MOVE-CORRESPONDING   IT_ZSINSSG5   TO   IT_ZSINSSG5_ORG.
*     APPEND IT_ZSINSSG5_ORG.
*  ENDLOOP.

ENDFUNCTION.

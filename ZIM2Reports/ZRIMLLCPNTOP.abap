*----------------------------------------------------------------------*
*   INCLUDE ZRIMLLCPNTOP                                              *
*----------------------------------------------------------------------*
*&  프로그램명 : Local L/C 어음도착통보?
*&      작성자 : 김연중 INFOLINK Ltd.                                  *
*&      작성일 : 2000.06.21                                            *
*&  적용회사PJT: 현대전자산업 주식회사                                 *
*&---------------------------------------------------------------------*
*&   DESC.     :
*&
*&---------------------------------------------------------------------*

TABLES : ZTRED,           " 인수증
         ZTPMTHD.           " Payment Notice
*-----------------------------------------------------------------------
* SELECT RECORD용
*-----------------------------------------------------------------------
DATA: BEGIN OF IT_SELECTED OCCURS 0,
      ZFREDNO     LIKE ZTRED-ZFREDNO,      "인수증 관리번호
      ZFREQNO     LIKE ZTPMTHD-ZFREQNO,      "수입의뢰 관리번호
END OF IT_SELECTED.

DATA  W_ZFAMDNO        LIKE ZTREQST-ZFAMDNO.

DATA : OPTION(1)       TYPE C,             " 공통 popup Screen에서 사용
       ANTWORT(1)      TYPE C,             " 공통 popup Screen에서 사?
       CANCEL_OPTION   TYPE C,             " 공통 popup Screen에서 사?
       TEXTLEN         TYPE I,             " 공통 popup Screen에서 사용
       W_PROC_CNT      TYPE I.             " 처리건수

DATA : W_ERR_CHK(1)      TYPE C,
       W_SELECTED_LINES  TYPE P,             " 선택 LINE COUNT
       W_PAGE            TYPE I,             " Page Counter
       W_LINE            TYPE I,             " 페이지당 LINE COUNT
       W_COUNT           TYPE I,             " 전체 COUNT
       W_LIST_INDEX      LIKE SY-TABIX,
       W_FIELD_NM        LIKE DD03D-FIELDNAME,   " 필드?
       W_TABIX           LIKE SY-TABIX,      " TABLE INDEX
       W_UPDATE_CNT      TYPE I,
       W_BUTTON_ANSWER   TYPE C.

*&---------------------------------------------------------------------*
*&  Include           ZQMR_COR_SCRAP_MATERIAL_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE g_okcode.
*---BACK/CANCEL---*
    WHEN 'BACK' OR 'CANL'.
      LEAVE TO SCREEN 0.

*---EXIT---*
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                 " EXIT  INPUT
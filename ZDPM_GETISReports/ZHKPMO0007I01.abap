*&---------------------------------------------------------------------*
*&  Include           ZHKPMO0007I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR  'CANC' .
      LEAVE TO SCREEN 0.

    WHEN 'SAVE' .  "SAVE cbo table
      PERFORM process_save .

  ENDCASE .


ENDMODULE.                 " USER_COMMAND_0100  INPUT

*----------------------------------------------------------------------
* Program ID        : ZACOU141
* Title             : Calculate NAFTA Material Cost
* Created on        : 4/3/2008
* Created by        : I.G.MOON
* Specifications By : Andy Choi
* Description       : Create ZTCO_NAFTA table entries
*----------------------------------------------------------------------
* Modification Logs
* Date       Developer  Request    Description
* 10/29/2010 VALERIAN   UD1K950031 Overwrite 'TOTAL' value with value
*                                  from MBEWH-VERPR.
* 11/01/2010 VALERIAN   UD1K950053 Multiply 'TOTAL' value with 'REQQT'
*                                  field in the calculation logic.
* 11/12/2010 VALERIAN   UD1K950167 Exclude test vehicle.
*                                  Overwrite GPREIS with VERPR/PEINH
*----------------------------------------------------------------------

REPORT zacou141 MESSAGE-ID zmco.

TABLES : ztco_ck11, ztco_abispost, ztco_nafta, zsco_nafta_ck11,
sscrfields.

INCLUDE : z_moon_alv_top,
          z_moon_alv_fnc.

INCLUDE <icon>.                        " icon
* //////////////////////////////////////////////////// *

FIELD-SYMBOLS : <f_s>, <f_t> .

DEFINE __fill_value.                          " clear & refresh
  if &1 is initial.
    field_name_s = &2.
    field_name_t = &3.
    perform get_field_value using field_name_s
                                  field_name_t
                                  fr_ix.
  endif.
END-OF-DEFINITION.

DEFINE __fill_value_artnr.                          " clear & refresh
  if &1 is initial.
    field_name_s = &2.
    field_name_t = &3.
    perform get_field_value_artnr using field_name_s
                                  field_name_t
                                  fr_ix.
  endif.
END-OF-DEFINITION.

DEFINE __cls.                          " clear & refresh
  clear &1.refresh &1.
END-OF-DEFINITION.

DEFINE u_break.
  if p_debug eq true.
    break-point.
  endif.
END-OF-DEFINITION.
DEFINE __define_not_important.
* { not important
* Total Doc. Count to be created.
  data  : total_doc_cnt type i,
          current_doc_cnt type i.
  data : percentage type p,$mod type i,
         $current_cnt(10),$total_cnt(10),$text(100) .
  clear : total_doc_cnt,current_doc_cnt.
* }
END-OF-DEFINITION.

CONSTANTS:  false VALUE ' ',
            true  VALUE 'X'.
* //////////////////////////////////////////////////// *

DATA BEGIN OF g_t_ztco_nafta_ck11 OCCURS 0.
        INCLUDE STRUCTURE zsco_nafta_ck11.
DATA END OF g_t_ztco_nafta_ck11.

DATA BEGIN OF g_t_nafta_all OCCURS 0.
        INCLUDE STRUCTURE zsco_nafta_ck11.
DATA END OF g_t_nafta_all.

DATA : BEGIN OF gt_comp_keep OCCURS 0,
           compn LIKE g_t_nafta_all-compn,
           verpr LIKE g_t_nafta_all-verpr,
           peinh LIKE g_t_nafta_all-peinh,
           lifnr LIKE g_t_nafta_all-lifnr,
       END OF gt_comp_keep.

DATA : BEGIN OF gt_lifnr OCCURS 0,
           lifnr LIKE  lfa1-lifnr,
       END OF gt_lifnr.

DATA : BEGIN OF gt_land OCCURS 0,
           lifnr LIKE  lfa1-lifnr,
           land1 LIKE  lfa1-land1,
       END OF gt_land.

DATA gt_color LIKE zsco_color OCCURS 0 WITH HEADER LINE.

DATA  : it_row_tab TYPE TABLE OF zsco_nafta_ck11 WITH HEADER LINE,
        gt_out     TYPE TABLE OF zsco_nafta_ck11 WITH HEADER LINE,
        big_gt_out TYPE TABLE OF zsco_nafta_ck11 WITH HEADER LINE.

DATA g_t_nafta_all_f LIKE g_t_nafta_all OCCURS 0
WITH HEADER LINE.
DATA g_nafta LIKE ztco_nafta OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF ty_plant,
         bwkey TYPE bwkey,
       END OF ty_plant.

DATA : BEGIN OF it_ckmlmv003 OCCURS 0,
         bwkey      LIKE ckmlmv001-bwkey,
         matnr      LIKE ckmlmv001-matnr,
         aufnr      LIKE ckmlmv013-aufnr,
         verid_nd   LIKE ckmlmv001-verid_nd,
         meinh      LIKE ckmlmv003-meinh,
         out_menge  LIKE ckmlmv003-out_menge,
       END OF  it_ckmlmv003.

DATA gt_plant      TYPE TABLE OF ty_plant    WITH HEADER LINE.
RANGES : gr_bwkey FOR t001w-bwkey.
DATA: g_bukrs LIKE bsis-bukrs.
DATA: gv_date_f TYPE sydatum,             " from date
      gv_info_f TYPE sydatum,             " from date (info)
      gv_date_t TYPE sydatum,             " to date
      gv_date3  TYPE sydatum,             " next end
      g_ix   LIKE sy-tabix.

DATA: g_error(1),
      g_repid  LIKE sy-repid.
DATA :
      $verpr   TYPE verpr,
      $gpreis  TYPE zgpreis,
      $peinh   TYPE ck_kpeinh,
      $losgr   TYPE ck_losgr,
      $meins   TYPE meins.

DATA BEGIN OF lt_ztco_ck11 OCCURS 0.
        INCLUDE STRUCTURE ztco_ck11.
DATA END OF lt_ztco_ck11.

DATA BEGIN OF lta_ztco_ck11 OCCURS 0.
        INCLUDE STRUCTURE ztco_ck11.
DATA END OF lta_ztco_ck11.

DATA BEGIN OF ltb_ztco_ck11 OCCURS 0.
        INCLUDE STRUCTURE ztco_ck11.
DATA END OF ltb_ztco_ck11.

DATA $ck11_1 LIKE ztco_ck11 OCCURS 0 WITH HEADER LINE.
DATA $ck11_2 LIKE ztco_ck11 OCCURS 0 WITH HEADER LINE.
DATA $ck11_3 LIKE ztco_ck11 OCCURS 0 WITH HEADER LINE.

* //////////////////////////////////////////////////// *

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE text-001.
PARAMETERS       p_kokrs LIKE ztco_ck11-kokrs DEFAULT 'H201'.
PARAMETERS    :
*               p_artnr like ztco_ck11-artnr,
                p_bdatj LIKE ztco_ck11-bdatj OBLIGATORY MEMORY ID bdtj,
                p_poper LIKE ztco_ck11-poper OBLIGATORY MEMORY ID popr,
                p_klvar LIKE ztco_ck11-klvar DEFAULT 'ZUNF' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b0.

SELECTION-SCREEN BEGIN OF BLOCK b10 WITH FRAME TITLE text-011.
SELECT-OPTIONS s_artnr FOR ztco_ck11-artnr.
SELECTION-SCREEN END OF BLOCK b10.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-022.
PARAMETERS p_prd AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETERS p_del AS CHECKBOX.
PARAMETERS p_upd AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-004.
SELECT-OPTIONS s_compn FOR ztco_ck11-compn.
SELECTION-SCREEN END OF BLOCK b5.

* Layout
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-010.
PARAMETER :    p_dsp AS CHECKBOX DEFAULT true,
               p_vari TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN BEGIN OF BLOCK view-result WITH FRAME TITLE text-t03.
SELECTION-SCREEN PUSHBUTTON  1(24) vslt USER-COMMAND vslt.
SELECTION-SCREEN END OF BLOCK view-result.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  sy-title = '[CO] Calculate NAFTA Material Cost'.
  PERFORM default_.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'VSLT'.
      PERFORM view_.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM alv_variant_f4 CHANGING p_vari.

START-OF-SELECTION.

  PERFORM show_progress     USING 'Initializing...' '5'.
  IF p_del EQ true.
    DELETE FROM ztco_nafta WHERE kokrs EQ p_kokrs
                             AND bdatj EQ p_bdatj
                             AND poper EQ p_poper
                             AND artnr IN s_artnr
                             AND compn IN s_compn .
    COMMIT WORK.
  ENDIF.

  PERFORM initialize.

  DATA $p_artnr LIKE ztco_ck11-artnr.

  DATA: BEGIN OF itab_artnr OCCURS 0,
          artnr   LIKE   ztco_ck11-artnr,
        END   OF itab_artnr.

  IF p_prd IS INITIAL.
    SELECT DISTINCT a~artnr INTO TABLE itab_artnr
      FROM ztco_ck11 AS a
      INNER JOIN mara AS b
      ON b~matnr EQ a~artnr
    WHERE a~kokrs = p_kokrs
      AND a~klvar = p_klvar
      AND a~bdatj = p_bdatj
      AND a~poper = p_poper
      AND a~artnr IN s_artnr
      AND a~werks IN gr_bwkey
      AND b~mtart EQ 'FERT'
      %_HINTS ORACLE 'FIRST_ROWS(10) INDEX("ZTCO_CK11" "ZTCO_CK11~0")'.
  ELSE.
    SELECT DISTINCT matnr INTO TABLE itab_artnr
      FROM zvbw_ckmlmv003_1
    WHERE mgtyp eq 'NAFTA'
      and GJAHR = p_bdatj
      AND perio = p_poper
      AND matnr IN s_artnr
      AND werks IN gr_bwkey.
  ENDIF.

  SORT itab_artnr .
  DELETE ADJACENT DUPLICATES FROM itab_artnr.
  __cls big_gt_out.

  __define_not_important.

  DESCRIBE TABLE itab_artnr LINES total_doc_cnt.
  $total_cnt = total_doc_cnt.

  LOOP AT itab_artnr.

    ADD 1 TO current_doc_cnt.
    $current_cnt = current_doc_cnt.
    CONCATENATE itab_artnr-artnr ':' $current_cnt '/' $total_cnt
    INTO $text.
    CONDENSE $text.
    percentage = current_doc_cnt / total_doc_cnt * 100.
    PERFORM show_progress USING $text percentage.

    CLEAR $p_artnr.
    $p_artnr = itab_artnr-artnr.

    __cls : g_t_ztco_nafta_ck11.
    __cls gt_color.

    PERFORM get_g_t_ztco_nafta_ck11 USING  p_kokrs
                                           p_klvar
                                           $p_artnr
                                           p_bdatj
                                           p_poper .

    __cls : g_t_nafta_all.

    PERFORM get_g_t_nafta_all USING  p_kokrs
                                           $p_artnr
                                           p_bdatj
                                           p_poper.

    PERFORM show_progress     USING $p_artnr '80'.
    PERFORM move_result USING $p_artnr.

    PERFORM move_out.

    APPEND LINES OF gt_out TO big_gt_out.

  ENDLOOP.

  __cls gt_out.
  gt_out[] = big_gt_out[].

  IF p_upd EQ true.
    PERFORM show_progress USING 'Data Saving...' '90'.
    PERFORM save_z.
  ENDIF.

  IF p_dsp EQ true .
    PERFORM view_from_memory.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  get_g_t_row
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_g_t_ztco_nafta_ck11 USING $p_kokrs
                              $p_klvar
                              $p_artnr
                              $p_year
                              $p_month.

  DATA l_color TYPE i.
  DATA l_qty TYPE ztco_ck11-reqqt.
  DATA l_amt TYPE ztco_ck11-total.
  DATA lt_color LIKE gt_color OCCURS 0 WITH HEADER LINE.

  __cls : lt_ztco_ck11, lta_ztco_ck11, ltb_ztco_ck11.

  __cls : $ck11_1, $ck11_2, $ck11_3.

  PERFORM get_ck11_data TABLES lt_ztco_ck11
                               $ck11_1
                         USING $p_kokrs
                               $p_klvar
                               $p_year
                               $p_month
                               $p_artnr.

  IF sy-subrc EQ 0.

    PERFORM get_mip_list TABLES lt_ztco_ck11
                                $ck11_2.

    PERFORM get_ck11_data TABLES lta_ztco_ck11
                                 $ck11_2
                           USING $p_kokrs
                                 $p_klvar
                                 $p_year
                                 $p_month
                                 $p_artnr.

  ENDIF.

  IF sy-subrc EQ 0.
    PERFORM get_mip_list TABLES lta_ztco_ck11
                                $ck11_3.

    PERFORM get_ck11_data TABLES ltb_ztco_ck11
                                 $ck11_3
                           USING $p_kokrs
                                 $p_klvar
                                 $p_year
                                 $p_month
                                 $p_artnr.

  ENDIF.

  SORT : lta_ztco_ck11 BY artnr,
         ltb_ztco_ck11 BY artnr.
  DATA $subrc LIKE sy-subrc.
  DATA $ix LIKE sy-tabix.

  LOOP AT lt_ztco_ck11.

    CLEAR: l_qty, l_amt.

    IF lt_ztco_ck11-stkkz EQ 'X'.
      READ TABLE lta_ztco_ck11 WITH KEY artnr = lt_ztco_ck11-compn
                                                    BINARY SEARCH.
      $subrc = sy-subrc.
      $ix = sy-tabix.
    ELSE.
      $subrc = 4.
    ENDIF.

    IF $subrc NE 0.
      if lt_ztco_ck11-losgr is initial.
        lt_ztco_ck11-losgr = 1.
      endif.
      l_qty = lt_ztco_ck11-reqqt / lt_ztco_ck11-losgr.
      l_amt = lt_ztco_ck11-total / lt_ztco_ck11-losgr.
    ENDIF.

    PERFORM write_ztco_ck11 TABLES lt_ztco_ck11
                             USING '1' .

    IF l_qty <> 0.
      l_color = 5.
    ELSE.
      l_color = 0.
    ENDIF.
    g_t_ztco_nafta_ck11-l_qty = l_qty.
    g_t_ztco_nafta_ck11-l_amt = l_amt.
    g_t_ztco_nafta_ck11-l_color = l_color.

    g_t_ztco_nafta_ck11-verid = lt_ztco_ck11-verid.

*    if g_t_ztco_nafta_ck11-compn in s_compn.
    APPEND g_t_ztco_nafta_ck11.
*    endif.

    IF $subrc EQ 0.

      LOOP AT lta_ztco_ck11 FROM $ix.

        IF lta_ztco_ck11-artnr NE lt_ztco_ck11-compn.
          EXIT.
        ENDIF.

        CLEAR: l_qty, l_amt.

        IF lta_ztco_ck11-stkkz EQ 'X'.
          READ TABLE ltb_ztco_ck11 WITH KEY artnr = lta_ztco_ck11-compn
                                                        BINARY SEARCH.

          $subrc = sy-subrc.
          $ix = sy-tabix.
        ELSE.
          $subrc = 4.
        ENDIF.

        IF $subrc NE 0.

          if lt_ztco_ck11-losgr is initial.
            lt_ztco_ck11-losgr = 1.
          endif.

          l_qty = lt_ztco_ck11-reqqt / lt_ztco_ck11-losgr
                * lta_ztco_ck11-reqqt / lta_ztco_ck11-losgr.
          l_amt = lta_ztco_ck11-total / lta_ztco_ck11-reqqt * l_qty.
        ENDIF.

        PERFORM write_ztco_ck11 TABLES lta_ztco_ck11
                                 USING '2' .

        IF l_qty <> 0.
          l_color = 5.
        ELSE.
          l_color = 0.
        ENDIF.
        g_t_ztco_nafta_ck11-l_qty = l_qty.
        g_t_ztco_nafta_ck11-l_amt = l_amt.
        g_t_ztco_nafta_ck11-l_color = l_color.
        g_t_ztco_nafta_ck11-verid = lt_ztco_ck11-verid.
*        if g_t_ztco_nafta_ck11-compn in s_compn.

        APPEND g_t_ztco_nafta_ck11.
*        endif.

        IF  $subrc EQ 0.

          LOOP AT ltb_ztco_ck11 FROM $ix.

            IF ltb_ztco_ck11-artnr NE lta_ztco_ck11-compn.
              EXIT.
            ENDIF.

            if lt_ztco_ck11-losgr is initial.
              lt_ztco_ck11-losgr = 1.
            endif.

            l_qty = lt_ztco_ck11-reqqt / lt_ztco_ck11-losgr
                  * lta_ztco_ck11-reqqt / lta_ztco_ck11-losgr
                  * ltb_ztco_ck11-reqqt / ltb_ztco_ck11-losgr.
            l_amt = ltb_ztco_ck11-total / ltb_ztco_ck11-reqqt * l_qty.
            PERFORM write_ztco_ck11 TABLES ltb_ztco_ck11
                                     USING '3' .

            IF l_qty <> 0.
              l_color = 5.
            ELSE.
              l_color = 0.
            ENDIF.
            g_t_ztco_nafta_ck11-l_qty = l_qty.
            g_t_ztco_nafta_ck11-l_amt = l_amt.
            g_t_ztco_nafta_ck11-l_color = l_color.

            g_t_ztco_nafta_ck11-verid = lt_ztco_ck11-verid.
*            if g_t_ztco_nafta_ck11-compn in s_compn.

            APPEND g_t_ztco_nafta_ck11.
*            endif.

          ENDLOOP.
        ELSE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

*  PERFORM elim_color TABLES g_t_ztco_nafta_ck11.

  CALL FUNCTION 'Z_CO_ELIMINATE_COLOR_CODE'
       TABLES
            p_t_nafta = g_t_ztco_nafta_ck11
            gt_color  = lt_color.

  APPEND LINES OF lt_color TO gt_color.

ENDFORM.                    " get_g_t_row
*&---------------------------------------------------------------------*
*&      Form  write_ztco_ck11
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_CK11  text
*      -->P_0304   text
*----------------------------------------------------------------------*
FORM write_ztco_ck11 TABLES   t_ztco_ck11 STRUCTURE ztco_ck11
                      USING    value(p_level)        .

  CLEAR g_t_ztco_nafta_ck11.
  MOVE-CORRESPONDING t_ztco_ck11 TO g_t_ztco_nafta_ck11.
  g_t_ztco_nafta_ck11-zlevel = p_level.

ENDFORM.                    " WRITE_ZTCO_CK11
*&---------------------------------------------------------------------*
*&      Form  display_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_result USING $p_artnr..

  DATA $ix LIKE sy-tabix.
  DATA g_prd_qty TYPE ckml_outmenge.
  SORT g_t_ztco_nafta_ck11 BY artnr verid.
  DATA $fevor TYPE fevor.
  DATA $verpr LIKE it_row_tab-verpr.

  __cls gt_comp_keep.

  DELETE g_t_ztco_nafta_ck11 WHERE NOT compn IN s_compn.

*  DELETE g_t_nafta_all WHERE NOT compn IN s_compn.

  LOOP AT g_t_nafta_all.
    $ix = sy-tabix.
    IF g_t_nafta_all-zlevel > 1
          AND g_t_nafta_all-werks EQ 'P001'
          AND g_t_nafta_all-l_color NE 5.
      DELETE g_t_nafta_all INDEX $ix.
    ENDIF.
  ENDLOOP.

  LOOP AT g_t_nafta_all.
    $ix = sy-tabix.
    g_t_nafta_all-splnt = g_t_nafta_all-werks.

    READ TABLE g_t_ztco_nafta_ck11 WITH KEY
                                artnr = g_t_nafta_all-artnr
                                verid = g_t_nafta_all-verid
                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      if g_t_ztco_nafta_ck11-losgr is initial.
        g_t_ztco_nafta_ck11-losgr = 1.
      endif.
      g_t_nafta_all-losgr =  g_t_ztco_nafta_ck11-losgr.
      g_t_nafta_all-werks = g_t_ztco_nafta_ck11-werks.
      g_t_nafta_all-hwaer = g_t_ztco_nafta_ck11-hwaer.
      g_t_nafta_all-stalt = g_t_ztco_nafta_ck11-stalt.
    ELSE.
      DELETE g_t_nafta_all INDEX $ix.
      CONTINUE.
    ENDIF.

    IF g_t_nafta_all-artnr NE $p_artnr.
      READ TABLE it_ckmlmv003 WITH KEY matnr = g_t_nafta_all-artnr
                           BINARY SEARCH.
    ELSE.
      READ TABLE it_ckmlmv003 WITH KEY matnr = g_t_nafta_all-artnr
                          verid_nd =  g_t_nafta_all-verid
                           BINARY SEARCH.
    ENDIF.

    IF sy-subrc EQ 0.

      IF g_t_nafta_all-artnr NE $p_artnr.
*        g_t_nafta_all-upgvc = g_t_nafta_all-artnr.
        g_t_nafta_all-mip = g_t_nafta_all-artnr.
        g_t_nafta_all-artnr = $p_artnr.
      ENDIF.

      g_t_nafta_all-tosndamt = g_t_nafta_all-osndamt.
      g_prd_qty = it_ckmlmv003-out_menge.

* { by ig.moon 5/6/2008
      IF g_t_nafta_all-losgr EQ 0.
        g_t_nafta_all-losgr = 1.
      ENDIF.
* }
      IF g_prd_qty NE 0 .  "AND  g_t_nafta_all-losgr NE 0.
        g_t_nafta_all-osndamt = g_t_nafta_all-osndamt
                  / g_prd_qty * g_t_nafta_all-losgr.
      ELSE.
        g_t_nafta_all-osndamt = g_t_nafta_all-osndamt.
      ENDIF.
      g_t_nafta_all-l_amt = g_t_nafta_all-osndamt.

      MODIFY g_t_nafta_all INDEX $ix.
    ELSE.
      DELETE g_t_nafta_all INDEX $ix.
    ENDIF.

  ENDLOOP.


  SORT : g_t_nafta_all BY artnr mip compn verid,
         g_t_ztco_nafta_ck11 BY artnr verid ASCENDING
                                losgr DESCENDING.


  __cls it_row_tab.

  SORT gt_color BY matnr_o.

  LOOP AT g_t_ztco_nafta_ck11.

    CHECK g_t_ztco_nafta_ck11-l_color EQ '5'.

* + by ig.moon 4/2/2009 {
    READ TABLE gt_color WITH KEY matnr_o = g_t_ztco_nafta_ck11-compn
                                 BINARY SEARCH.

    IF sy-subrc EQ 0.

      it_row_tab = g_t_ztco_nafta_ck11.

      IF it_row_tab-artnr NE $p_artnr.
        it_row_tab-mip = g_t_ztco_nafta_ck11-artnr.
        it_row_tab-artnr = $p_artnr.
      ELSE.
      ENDIF.

      READ TABLE g_t_nafta_all
      WITH KEY artnr = g_t_ztco_nafta_ck11-artnr
               mip = g_t_ztco_nafta_ck11-mip
               compn = g_t_ztco_nafta_ck11-compn
               verid = g_t_ztco_nafta_ck11-verid
               BINARY SEARCH.
      IF sy-subrc EQ 0.
        it_row_tab-osndamt = g_t_nafta_all-l_amt.
        it_row_tab-tosndamt = g_t_nafta_all-tosndamt.
        it_row_tab-hwaer    = g_t_nafta_all-hwaer.
        it_row_tab-stalt    = g_t_nafta_all-stalt.

        DELETE g_t_nafta_all INDEX sy-tabix.
      ENDIF.

     READ TABLE gt_comp_keep WITH KEY compn = g_t_ztco_nafta_ck11-compn
     .
      IF sy-subrc EQ 0.
        it_row_tab-verpr = gt_comp_keep-verpr.
        it_row_tab-peinh = gt_comp_keep-peinh.
        it_row_tab-lifnr = gt_comp_keep-lifnr.

      ELSE.

*        CONCATENATE g_t_ztco_nafta_ck11-compn '%' INTO gt_color-matnr_i
*.

        CALL FUNCTION 'Z_CO_GET_MAP_IG'
             EXPORTING
                  matnr  = gt_color-matnr_i
                  poper  = it_row_tab-poper
                  bdatj  = it_row_tab-bdatj
                  i_look = true
             IMPORTING
                  verpr  = it_row_tab-verpr
                  peinh  = it_row_tab-peinh
                  retro  = it_row_tab-retro.

        PERFORM get_vendor_137 USING gt_color-matnr_i
                            CHANGING it_row_tab-lifnr
                                     it_row_tab-retro.

        MOVE :
        it_row_tab-compn TO gt_comp_keep-compn,
        it_row_tab-verpr TO gt_comp_keep-verpr,
        it_row_tab-peinh TO gt_comp_keep-peinh,
        it_row_tab-lifnr TO gt_comp_keep-lifnr.
        APPEND gt_comp_keep.
      ENDIF.

    ELSE.

      it_row_tab = g_t_ztco_nafta_ck11.

      IF it_row_tab-artnr NE $p_artnr.
        it_row_tab-mip = g_t_ztco_nafta_ck11-artnr.
        it_row_tab-artnr = $p_artnr.
      ELSE.
      ENDIF.

      READ TABLE g_t_nafta_all
      WITH KEY artnr = g_t_ztco_nafta_ck11-artnr
               mip = g_t_ztco_nafta_ck11-mip
               compn = g_t_ztco_nafta_ck11-compn
               verid = g_t_ztco_nafta_ck11-verid
               BINARY SEARCH.
      IF sy-subrc EQ 0.
        it_row_tab-osndamt = g_t_nafta_all-l_amt.
        it_row_tab-tosndamt = g_t_nafta_all-tosndamt.
        it_row_tab-hwaer    = g_t_nafta_all-hwaer.
        it_row_tab-stalt    = g_t_nafta_all-stalt.

        DELETE g_t_nafta_all INDEX sy-tabix.
      ENDIF.

     READ TABLE gt_comp_keep WITH KEY compn = g_t_ztco_nafta_ck11-compn
   .
      IF sy-subrc EQ 0.
        it_row_tab-verpr = gt_comp_keep-verpr.
        it_row_tab-peinh = gt_comp_keep-peinh.
        it_row_tab-lifnr = gt_comp_keep-lifnr.

      ELSE.

        CALL FUNCTION 'Z_CO_GET_MAP_IG'
             EXPORTING
                  matnr  = it_row_tab-compn
                  poper  = it_row_tab-poper
                  bdatj  = it_row_tab-bdatj
                  i_look = true
             IMPORTING
                  verpr  = it_row_tab-verpr
                  peinh  = it_row_tab-peinh
                  retro  = it_row_tab-retro.

        PERFORM get_vendor_137 USING it_row_tab-compn
                            CHANGING it_row_tab-lifnr
                                     it_row_tab-retro.

        MOVE :
        it_row_tab-compn TO gt_comp_keep-compn,
        it_row_tab-verpr TO gt_comp_keep-verpr,
        it_row_tab-peinh TO gt_comp_keep-peinh,
        it_row_tab-lifnr TO gt_comp_keep-lifnr.
        APPEND gt_comp_keep.
      ENDIF.
    ENDIF.

    CLEAR it_row_tab-land1.
    APPEND it_row_tab.
  ENDLOOP.

  LOOP AT g_t_nafta_all.
    $ix = sy-tabix.

    READ TABLE gt_color WITH KEY matnr_o = g_t_nafta_all-compn
                                 BINARY SEARCH.

    IF sy-subrc EQ 0.

      READ TABLE gt_comp_keep WITH KEY compn = g_t_nafta_all-compn.

      IF sy-subrc EQ 0.
        g_t_nafta_all-verpr = gt_comp_keep-verpr.
        g_t_nafta_all-peinh = gt_comp_keep-peinh.
        g_t_nafta_all-lifnr = gt_comp_keep-lifnr.
      ELSE.
        CONCATENATE g_t_nafta_all-compn '%' INTO gt_color-matnr_i.

        CALL FUNCTION 'Z_CO_GET_MAP_IG'
             EXPORTING
                  matnr  = gt_color-matnr_i
                  poper  = g_t_nafta_all-poper
                  bdatj  = g_t_nafta_all-bdatj
                  i_look = true
             IMPORTING
                  verpr  = g_t_nafta_all-verpr
                  peinh  = g_t_nafta_all-peinh
                  retro  = g_t_nafta_all-retro.


        PERFORM get_vendor_137 USING gt_color-matnr_i
                            CHANGING g_t_nafta_all-lifnr
                                     g_t_nafta_all-retro.

        MOVE :
        g_t_nafta_all-compn TO gt_comp_keep-compn,
        g_t_nafta_all-verpr TO gt_comp_keep-verpr,
        g_t_nafta_all-peinh TO gt_comp_keep-peinh,
        g_t_nafta_all-lifnr TO gt_comp_keep-lifnr.
        APPEND gt_comp_keep.

      ENDIF.
    ELSE.

      CALL FUNCTION 'Z_CO_GET_MAP_IG'
           EXPORTING
                matnr  = g_t_nafta_all-compn
                poper  = g_t_nafta_all-poper
                bdatj  = g_t_nafta_all-bdatj
                i_look = true
           IMPORTING
                verpr  = g_t_nafta_all-verpr
                peinh  = g_t_nafta_all-peinh
                retro  = g_t_nafta_all-retro.

      PERFORM get_vendor_137 USING g_t_nafta_all-compn
                          CHANGING g_t_nafta_all-lifnr
                                   g_t_nafta_all-retro .

      MOVE :
      g_t_nafta_all-compn TO gt_comp_keep-compn,
      g_t_nafta_all-verpr TO gt_comp_keep-verpr,
      g_t_nafta_all-peinh TO gt_comp_keep-peinh,
      g_t_nafta_all-lifnr TO gt_comp_keep-lifnr.
      APPEND gt_comp_keep.

    ENDIF.

    CLEAR :  g_t_nafta_all-l_qty, g_t_nafta_all-l_amt.
    g_t_nafta_all-gpreis = g_t_nafta_all-verpr.

    CLEAR g_t_nafta_all-land1.
    MODIFY g_t_nafta_all INDEX $ix TRANSPORTING
            verpr peinh l_qty l_amt lifnr gpreis retro land1.

  ENDLOOP.

  APPEND LINES OF g_t_nafta_all TO it_row_tab.

  LOOP AT it_row_tab.
    $ix = sy-tabix.
    it_row_tab-splnt = it_row_tab-werks.
    READ TABLE g_t_ztco_nafta_ck11 WITH KEY
                                artnr = it_row_tab-artnr
                                verid = it_row_tab-verid
                                BINARY SEARCH.
    IF sy-subrc EQ 0.
      it_row_tab-werks = g_t_ztco_nafta_ck11-werks.
      it_row_tab-hwaer = g_t_ztco_nafta_ck11-hwaer.
      it_row_tab-stalt = g_t_ztco_nafta_ck11-stalt.

      IF it_row_tab-l_amt IS INITIAL.

        READ TABLE gt_color WITH KEY matnr_o = it_row_tab-compn
                                     BINARY SEARCH.

        IF sy-subrc EQ 0.

          READ TABLE gt_comp_keep WITH KEY compn = it_row_tab-compn.

          IF sy-subrc EQ 0.
            it_row_tab-verpr = gt_comp_keep-verpr.
            it_row_tab-peinh = gt_comp_keep-peinh.
            it_row_tab-lifnr = gt_comp_keep-lifnr.
          ELSE.
            CONCATENATE it_row_tab-compn '%' INTO gt_color-matnr_i.
            CALL FUNCTION 'Z_CO_GET_MAP_IG'
                 EXPORTING
                      matnr  = gt_color-matnr_i
                      poper  = it_row_tab-poper
                      bdatj  = it_row_tab-bdatj
                      i_look = true
                 IMPORTING
                      verpr  = it_row_tab-verpr
                      peinh  = it_row_tab-peinh
                      retro  = it_row_tab-retro.
            MOVE :
            it_row_tab-compn TO gt_comp_keep-compn,
            it_row_tab-verpr TO gt_comp_keep-verpr,
            it_row_tab-peinh TO gt_comp_keep-peinh,
            it_row_tab-lifnr TO gt_comp_keep-lifnr.
            APPEND gt_comp_keep.
          ENDIF.
        ELSE.
          CALL FUNCTION 'Z_CO_GET_MAP_IG'
               EXPORTING
                    matnr  = it_row_tab-compn
                    poper  = it_row_tab-poper
                    bdatj  = it_row_tab-bdatj
                    i_look = true
               IMPORTING
                    verpr  = it_row_tab-verpr
                    peinh  = it_row_tab-peinh
                    retro  = it_row_tab-retro.
        ENDIF.

        it_row_tab-l_amt = it_row_tab-reqqt *
                            it_row_tab-verpr / it_row_tab-peinh.
        it_row_tab-gpreis = it_row_tab-verpr.
      ENDIF.

      IF it_row_tab-peinh IS INITIAL.
        READ TABLE gt_color WITH KEY matnr_o = it_row_tab-compn
                                     BINARY SEARCH.

        IF sy-subrc EQ 0.
          CONCATENATE it_row_tab-compn '%' INTO gt_color-matnr_i.
          CALL FUNCTION 'Z_CO_GET_MAP_IG'
               EXPORTING
                    matnr  = gt_color-matnr_i
                    poper  = it_row_tab-poper
                    bdatj  = it_row_tab-bdatj
                    i_look = true
               IMPORTING
                    verpr  = $verpr
                    peinh  = it_row_tab-peinh
                    retro  = it_row_tab-retro.
        ELSE.
          CALL FUNCTION 'Z_CO_GET_MAP_IG'
               EXPORTING
                    matnr  = it_row_tab-compn
                    poper  = it_row_tab-poper
                    bdatj  = it_row_tab-bdatj
                    i_look = true
               IMPORTING
                    verpr  = $verpr
                    peinh  = it_row_tab-peinh
                    retro  = it_row_tab-retro.
        ENDIF.
      ENDIF.
    ENDIF.
    it_row_tab-wertn = it_row_tab-l_amt.
    it_row_tab-reqqt = it_row_tab-l_qty.
    MODIFY it_row_tab INDEX $ix TRANSPORTING werks splnt hwaer
        stalt retro l_amt gpreis verpr peinh wertn reqqt.

  ENDLOOP.

  SORT it_row_tab BY artnr verid werks compn .

ENDFORM.                    " display_result
*&---------------------------------------------------------------------*
*&      Form  save_z
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_z.

  __cls g_nafta.
  SORT gt_out BY kokrs bdatj poper artnr verid werks compn.
  DATA $ix TYPE zcoindx.

  LOOP AT gt_out.
    AT NEW compn.
      CLEAR $ix.
    ENDAT.
    ADD 1 TO $ix.
    MOVE-CORRESPONDING gt_out TO g_nafta.
    g_nafta-indx = $ix.
    g_nafta-aedat = sy-datum.
    g_nafta-aenam = sy-uname.
    APPEND g_nafta.
  ENDLOOP.

  MODIFY ztco_nafta FROM TABLE g_nafta.

  IF sy-subrc EQ 0.
    COMMIT WORK.
    MESSAGE s000 WITH 'Data has been created Sucessfully !!!'.
  ENDIF.

ENDFORM.                    " save_z
*&---------------------------------------------------------------------*
*&      Form  get_g_t_ztco_nafta_ck11_osnd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_KOKRS  text
*      -->P_P_KLVAR  text
*      -->P_P_ARTNR  text
*      -->P_P_BDATJ  text
*      -->P_P_POPER  text
*----------------------------------------------------------------------*
FORM get_g_t_nafta_all USING $p_kokrs
                                   $p_artnr
                                   $p_year
                                   $p_month.

  DATA l_color TYPE i.
  DATA l_qty TYPE ztco_abispost-mbgbtr.
  DATA l_amt TYPE ztco_abispost-chg_wkgbtr.

  DATA BEGIN OF lt_ztco_osnd OCCURS 0.
          INCLUDE STRUCTURE zsco_osnd.
  DATA END OF lt_ztco_osnd.

  DATA BEGIN OF lta_ztco_osnd OCCURS 0.
          INCLUDE STRUCTURE zsco_osnd.
  DATA END OF lta_ztco_osnd.

  DATA BEGIN OF ltb_ztco_osnd OCCURS 0.
          INCLUDE STRUCTURE zsco_osnd.
  DATA END OF ltb_ztco_osnd.

  DATA $subrc LIKE sy-subrc.
  DATA $ix LIKE sy-tabix.

  DATA lt_color LIKE gt_color OCCURS 0 WITH HEADER LINE.

  PERFORM get_osnd_data TABLES lt_ztco_osnd
                               $ck11_1
                         USING $p_kokrs
                               $p_year
                               $p_month
                               $p_artnr.

  IF sy-subrc EQ 0.

    PERFORM get_osnd_data TABLES lta_ztco_osnd
                                 $ck11_2
                           USING $p_kokrs
                                 $p_year
                                 $p_month
                                 $p_artnr.

  ENDIF.

  IF sy-subrc EQ 0.

    PERFORM get_osnd_data TABLES ltb_ztco_osnd
                                 $ck11_3
                           USING $p_kokrs
                                 $p_year
                                 $p_month
                                 $p_artnr.

  ENDIF.

  SORT :
         lt_ztco_osnd BY matnr,
         lta_ztco_osnd BY matnr,
         ltb_ztco_osnd BY matnr.

  PERFORM fill_missed_osnd TABLES : lt_ztco_ck11  lt_ztco_osnd ,
                                    lta_ztco_ck11 lta_ztco_osnd,
                                    ltb_ztco_ck11 ltb_ztco_osnd.

  SORT :
         lta_ztco_osnd BY fsc_matnr,
         ltb_ztco_osnd BY fsc_matnr.

  LOOP AT lt_ztco_osnd.

    CLEAR: l_qty, l_amt.

    IF lt_ztco_osnd-mtart EQ 'HALB' OR lt_ztco_osnd-mtart EQ 'SEMI'.

      READ TABLE lta_ztco_osnd WITH KEY fsc_matnr = lt_ztco_osnd-matnr
                                                    BINARY SEARCH.
      $subrc = sy-subrc.
      $ix = sy-tabix.
    ELSE.
      $subrc = 4.
    ENDIF.

    IF $subrc NE 0.
      l_qty = lt_ztco_osnd-mbgbtr.
      l_amt = lt_ztco_osnd-chg_wkgbtr.
    ENDIF.

    PERFORM write_ztco_osnd TABLES lt_ztco_osnd
                             USING '1' .

    IF l_qty <> 0.
      l_color = 5.
    ELSE.
      l_color = 0.
    ENDIF.

    g_t_nafta_all-l_qty = l_qty.
    g_t_nafta_all-l_amt = l_amt.
    g_t_nafta_all-l_color = l_color.

    g_t_nafta_all-verid = lt_ztco_osnd-verid.

    IF l_amt <> 0.
      APPEND g_t_nafta_all.
    ENDIF.

    IF $subrc EQ 0.

      LOOP AT lta_ztco_osnd FROM $ix.

        IF lta_ztco_osnd-fsc_matnr NE lt_ztco_osnd-matnr.
          EXIT.
        ENDIF.

        CLEAR: l_qty, l_amt.

        IF lta_ztco_osnd-mtart EQ 'HALB'
        OR lta_ztco_osnd-mtart EQ 'SEMI'.
      READ TABLE ltb_ztco_osnd WITH KEY fsc_matnr = lta_ztco_osnd-matnr
                                                          BINARY SEARCH.

          $subrc = sy-subrc.
          $ix = sy-tabix.
        ELSE.
          $subrc = 4.
        ENDIF.
        IF $subrc NE 0.
          l_qty = lt_ztco_osnd-mbgbtr * lta_ztco_osnd-mbgbtr.
          l_amt = lta_ztco_osnd-chg_wkgbtr
                    / lta_ztco_osnd-mbgbtr * l_qty.
        ENDIF.

        PERFORM write_ztco_osnd TABLES lta_ztco_osnd
                                 USING '2' .

        IF l_qty <> 0.
          l_color = 5.
        ELSE.
          l_color = 0.
        ENDIF.
        g_t_nafta_all-l_qty = l_qty.
        g_t_nafta_all-l_amt = l_amt.
        g_t_nafta_all-l_color = l_color.

        g_t_nafta_all-verid = lt_ztco_osnd-verid.
        IF l_amt <> 0.
          APPEND g_t_nafta_all.
        ENDIF.

        IF  $subrc EQ 0.

          LOOP AT ltb_ztco_osnd FROM $ix.

            IF ltb_ztco_osnd-fsc_matnr NE lta_ztco_osnd-matnr.
              EXIT.
            ENDIF.

            l_qty = lt_ztco_osnd-mbgbtr
                  * lta_ztco_osnd-mbgbtr
                  * ltb_ztco_osnd-mbgbtr.
            l_amt = ltb_ztco_osnd-chg_wkgbtr
                      / ltb_ztco_osnd-mbgbtr * l_qty.

            PERFORM write_ztco_osnd TABLES ltb_ztco_osnd
                                     USING '3' .

            IF l_qty <> 0.
              l_color = 5.
            ELSE.
              l_color = 0.
            ENDIF.
            g_t_nafta_all-l_qty = l_qty.
            g_t_nafta_all-l_amt = l_amt.
            g_t_nafta_all-l_color = l_color.

            g_t_nafta_all-verid = lt_ztco_osnd-verid.
            IF l_amt <> 0.
              APPEND g_t_nafta_all.
            ENDIF.

          ENDLOOP.
        ELSE.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  PERFORM get_prd_qty USING $p_artnr.
  PERFORM add_prd_qty TABLES : $ck11_2, $ck11_3 .

* {

  DATA $it_ckmlmv003 LIKE it_ckmlmv003 OCCURS 0 WITH HEADER LINE.
  $it_ckmlmv003[] = it_ckmlmv003[].
  SORT $it_ckmlmv003 BY matnr ASCENDING
                            meinh DESCENDING.

  LOOP AT it_ckmlmv003.
    $ix = sy-tabix.
    IF it_ckmlmv003-meinh EQ space.
      READ TABLE $it_ckmlmv003 WITH KEY matnr = it_ckmlmv003-matnr
                                    BINARY SEARCH.
      it_ckmlmv003-meinh = $it_ckmlmv003-meinh.
      MODIFY  it_ckmlmv003 INDEX $ix TRANSPORTING meinh.
    ENDIF.
  ENDLOOP.

  __cls $it_ckmlmv003.
  LOOP AT it_ckmlmv003.
    $it_ckmlmv003 = it_ckmlmv003.
    COLLECT $it_ckmlmv003.
  ENDLOOP.

  __cls it_ckmlmv003.

  it_ckmlmv003[] = $it_ckmlmv003[].

* }
  SORT it_ckmlmv003 BY matnr verid_nd.

*  PERFORM elim_color TABLES g_t_nafta_all.

  CALL FUNCTION 'Z_CO_ELIMINATE_COLOR_CODE'
       TABLES
            p_t_nafta = g_t_nafta_all
            gt_color  = lt_color.

  APPEND LINES OF lt_color TO gt_color.

ENDFORM.                    " get_g_t_row


*&---------------------------------------------------------------------*
*&      Form  write_ztco_osnd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_OSND  text
*      -->P_0919   text
*----------------------------------------------------------------------*
FORM write_ztco_osnd TABLES   t_ztco_osnd STRUCTURE zsco_osnd
                      USING    value(p_level)        .


  CLEAR g_t_nafta_all.

  g_t_nafta_all-kokrs = t_ztco_osnd-kokrs.
  g_t_nafta_all-bdatj = t_ztco_osnd-gjahr.
  g_t_nafta_all-poper = t_ztco_osnd-period.
  g_t_nafta_all-artnr = t_ztco_osnd-fsc_matnr.
  g_t_nafta_all-werks = t_ztco_osnd-werks.
  g_t_nafta_all-compn = t_ztco_osnd-matnr.
  g_t_nafta_all-kstar = t_ztco_osnd-kstar.
  g_t_nafta_all-meeht = t_ztco_osnd-meinb.
  g_t_nafta_all-osndamt = t_ztco_osnd-chg_wkgbtr.
  g_t_nafta_all-hwaer = t_ztco_osnd-waers.
  g_t_nafta_all-verid = t_ztco_osnd-verid.
  g_t_nafta_all-mtart = t_ztco_osnd-mtart.

  g_t_nafta_all-zlevel = p_level.

ENDFORM.                    " WRITE_ZTCO_CK11
*&---------------------------------------------------------------------*
*&      Form  get_prd_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_prd_qty USING $p_matnr.

  __cls it_ckmlmv003 .
  DATA : it_ckmlmv003_temp LIKE it_ckmlmv003 OCCURS 0 WITH HEADER LINE.


** read GR data
  SELECT  a~bwkey a~matnr a~verid_nd
          c~aufnr
          b~out_menge
          b~meinh
    INTO CORRESPONDING FIELDS OF TABLE it_ckmlmv003_temp
    FROM ckmlmv001 AS a
    INNER JOIN ckmlmv003 AS b
       ON a~kalnr    =  b~kalnr_bal
    INNER JOIN ckmlmv013 AS c
       ON c~kalnr_proc = b~kalnr_in
   WHERE a~werks    IN gr_bwkey
     AND a~matnr    =  $p_matnr
     AND a~btyp     =  'BF'
     AND a~bwkey     IN  gr_bwkey
     AND b~gjahr    =  p_bdatj
     AND b~perio    =  p_poper
     AND c~flg_wbwg = 'X'
     AND c~autyp = '05'.

  LOOP AT it_ckmlmv003_temp.
    MOVE-CORRESPONDING it_ckmlmv003_temp TO it_ckmlmv003.
    CLEAR: " it_ckmlmv003-verid_nd,
           it_ckmlmv003-aufnr.
    COLLECT it_ckmlmv003. CLEAR it_ckmlmv003.
  ENDLOOP.

  SORT it_ckmlmv003 BY matnr verid_nd.

*  read table it_ckmlmv003 with key matnr = $p_matnr binary search.
*
*  if sy-subrc eq 0.
*    p_prd_qty = it_ckmlmv003-out_menge.
*  else.
*    p_prd_qty = 1.
*  endif.


ENDFORM.                    " get_prd_qty
*&---------------------------------------------------------------------*
*&      Form  get_plant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_plant.
  __cls  : gt_plant, gr_bwkey.

* Get plant
  SELECT bwkey INTO TABLE gt_plant
    FROM t001k
   WHERE bukrs = g_bukrs.

  LOOP AT gt_plant.
    gr_bwkey-sign = 'I'.
    gr_bwkey-option = 'EQ'.
    gr_bwkey-low = gt_plant-bwkey.

    APPEND gr_bwkey.
    CLEAR gr_bwkey.
  ENDLOOP.


ENDFORM.                    " GET_PLANT
*&---------------------------------------------------------------------*
*&      Form  elim_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_g_t_nafta_all  text
*----------------------------------------------------------------------*
*FORM elim_color TABLES p_t_nafta STRUCTURE zsco_nafta_ck11.
*
*  DATA: $strlen TYPE i.
*  DATA: $ix LIKE sy-tabix.
*
*  LOOP AT p_t_nafta.
*    $ix = sy-tabix.
*    $strlen = strlen( p_t_nafta-compn ).
*    IF $strlen > 11.
*      CASE $strlen.
*        WHEN 12 OR 13.
*          gt_color-matnr1 = p_t_nafta-compn.
*          p_t_nafta-compn = p_t_nafta-compn+(10).
*          gt_color-matnr2 = p_t_nafta-compn.
*          COLLECT gt_color.
*        WHEN 14 OR 15.
*          gt_color-matnr1 = p_t_nafta-compn.
*          p_t_nafta-compn = p_t_nafta-compn+(12).
*          gt_color-matnr2 = p_t_nafta-compn.
*          COLLECT gt_color.
*      ENDCASE.
*      MODIFY p_t_nafta INDEX $ix TRANSPORTING compn.
*
*    ENDIF.
*  ENDLOOP.
*
*  DATA $p_t_nafta LIKE zsco_nafta_ck11 OCCURS 0 WITH HEADER LINE.
*
*  LOOP AT p_t_nafta.
*    CHECK p_t_nafta-compn IN s_compn.
*    $p_t_nafta = p_t_nafta.
*
*    $verpr   = p_t_nafta-verpr.
*    $gpreis  = p_t_nafta-gpreis.
*    $peinh   = p_t_nafta-peinh.
*    $losgr   = p_t_nafta-losgr.
*
*    COLLECT $p_t_nafta.
*    MOVE :
*      $verpr   TO $p_t_nafta-verpr,
*      $gpreis  TO $p_t_nafta-gpreis,
*      $peinh   TO $p_t_nafta-peinh,
*      $losgr   TO $p_t_nafta-losgr.
*
*    MODIFY $p_t_nafta INDEX sy-tabix TRANSPORTING
*                              verpr gpreis peinh losgr.
*
*  ENDLOOP.
*  __cls p_t_nafta.
*  p_t_nafta[] = $p_t_nafta[].
*
*ENDFORM.                    " elim_color
*&---------------------------------------------------------------------*
*&      Form  get_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date.
  DATA: l_date(8).

  CLEAR: gv_info_f, gv_date_f, gv_date_t, gv_date3.

  CLEAR l_date.
  CONCATENATE '0101' p_bdatj INTO l_date.

  CALL FUNCTION 'CONVERT_DATE_INPUT'
       EXPORTING
            input  = l_date
       IMPORTING
            output = gv_info_f.

  CLEAR l_date.
  CONCATENATE p_poper+1(2) '01' p_bdatj  INTO l_date.

  CALL FUNCTION 'CONVERT_DATE_INPUT'
       EXPORTING
            input  = l_date
       IMPORTING
            output = gv_date_f.

  CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
       EXPORTING
            i_gjahr = p_bdatj
            i_periv = 'K0'
            i_poper = p_poper
       IMPORTING
            e_date  = gv_date_t.

ENDFORM.                    " get_date
*&---------------------------------------------------------------------*
*&      Form  get_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_bukrs.

  SELECT SINGLE bukrs INTO g_bukrs FROM tka02
            WHERE kokrs EQ p_kokrs .

ENDFORM.                    " get_bukrs
*&---------------------------------------------------------------------*
*&      Form  get_vendor_137
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_g_t_nafta_all_COMPN  text
*----------------------------------------------------------------------*
FORM get_vendor_137 USING p_compn
                 CHANGING p_lifnr p_retro.

  DATA: BEGIN OF it_lifnr OCCURS 21,
          lifnr TYPE lifnr,
        END   OF it_lifnr.
  DATA  l_lifnr TYPE lifnr.
  DATA $ix LIKE sy-tabix.
  DATA $matnr TYPE matnr.

  IF p_retro EQ space.
    SELECT DISTINCT lifnr INTO TABLE it_lifnr
                 FROM ztcou137
                WHERE bukrs EQ g_bukrs
                  AND matnr EQ p_compn
                  AND ( ( zdtfr <= gv_date_f AND zdtto >= gv_date_t )
                    OR  ( zdtfr <= gv_date_t AND zdtto >= gv_date_t ) ).


    IF sy-subrc NE 0.

      PERFORM get_simple_matnr USING p_compn
                            CHANGING $matnr.
      REPLACE '%' WITH '' INTO $matnr.
      CONCATENATE $matnr '%' INTO $matnr.

      SELECT DISTINCT lifnr INTO TABLE it_lifnr
                   FROM ztcou137
                  WHERE bukrs EQ g_bukrs
                    AND matnr LIKE $matnr
                  AND ( ( zdtfr <= gv_date_f AND zdtto <= gv_date_t )
                  OR  ( zdtfr <= gv_date_t AND zdtto >= gv_date_t ) ).
    ENDIF.

  ELSE.

    SELECT DISTINCT lifnr INTO TABLE it_lifnr
                 FROM ztcou137
                WHERE bukrs EQ g_bukrs
                  AND matnr EQ p_compn
                  AND zdtto >= gv_date_t .
    IF sy-subrc NE 0.

      PERFORM get_simple_matnr USING p_compn
                            CHANGING $matnr.

      CONCATENATE $matnr '%' INTO $matnr.

      SELECT DISTINCT lifnr INTO TABLE it_lifnr
                   FROM ztcou137
                  WHERE bukrs EQ g_bukrs
                    AND matnr LIKE $matnr
                      AND zdtto >= gv_date_t .

    ENDIF.
  ENDIF.

  READ TABLE it_lifnr INDEX 2.
*---multiple vendor - take KD vendor
  IF sy-subrc EQ 0.
    LOOP AT it_lifnr.
      SELECT SINGLE lifnr INTO l_lifnr
                  FROM lfa1
                WHERE lifnr EQ it_lifnr-lifnr
                  AND land1 <> 'US'.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF l_lifnr EQ space.
    READ TABLE it_lifnr INDEX 1.
    IF sy-subrc EQ 0.
      l_lifnr = it_lifnr-lifnr.
    ENDIF.
  ENDIF.

* by ig.moon {

  IF l_lifnr EQ space .

    DATA : $used_source TYPE  tabname16,
           $ekorg TYPE  ekorg,
           $infnr TYPE  infnr.

    CALL FUNCTION 'Z_CO_GET_VENDOR_SOURCE_AUTO'
         EXPORTING
              bukrs           = g_bukrs
              matnr           = p_compn
              available_date  = gv_date_f
         IMPORTING
              lifnr           = l_lifnr
              used_source     = $used_source
              ekorg           = $ekorg
              infnr           = $infnr
         EXCEPTIONS
              no_source_found = 1
              invalid_werks   = 2
              OTHERS          = 3.
    IF sy-subrc <> 0.
    ELSE.
      p_retro = 'I'.
    ENDIF.
  ENDIF.

* }

  p_lifnr = l_lifnr.


ENDFORM.                    " get_vendor_137
*&---------------------------------------------------------------------*
*&      Form  view_from_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_from_memory.

  DATA : $p_upd LIKE p_upd,
         $p_dsp LIKE p_dsp.

  $p_upd = p_upd.
  $p_dsp = p_dsp.

  p_upd = true.
  p_dsp = true.

  PERFORM set_output .

  p_upd = $p_upd.
  p_dsp = $p_dsp.


ENDFORM.                    " view_from_memory
*&---------------------------------------------------------------------*
*&      Form  move_out
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_out.
  DATA $ix TYPE i.
  DATA dummy.
  __cls gt_out.
  LOOP AT it_row_tab.
    MOVE-CORRESPONDING it_row_tab TO gt_out.

    CHECK gt_out-compn IN s_compn.
    CHECK gt_out-artnr+4(1) <> 'X'.                         "UD1K950167

* BEGIN OF UD1K950031 - Overwrite TOTAL value
    DATA: l_peinh TYPE peinh.

*   gt_out-total  = it_row_tab-l_amt.

    CLEAR: gt_out-total, l_peinh.
    SELECT SINGLE verpr peinh INTO (gt_out-total, l_peinh)
      FROM mbewh
     WHERE matnr = gt_out-compn
       AND bwkey = gt_out-werks
       AND bwtar = space
       AND lfgja = p_bdatj
       AND lfmon = p_poper.

    IF NOT l_peinh IS INITIAL.
*     gt_out-total  = gt_out-total / l_peinh.               "UD1K950053
      gt_out-total  = gt_out-total / l_peinh *              "UD1K950053
                      gt_out-reqqt.                         "UD1K950053
    ENDIF.
* END OF UD1K950031

    gt_out-reqqt  = it_row_tab-l_qty.
    gt_out-bdatj = p_bdatj.
    gt_out-poper = p_poper.

    CLEAR : gt_out-l_color,
            gt_out-indx.

    IF gt_out-lifnr IS INITIAL.
      dummy = true.
      PERFORM get_vendor_137 USING gt_out-compn
                          CHANGING gt_out-lifnr
                                   dummy.
    ENDIF.

    APPEND gt_out.

  ENDLOOP.

  __cls : gt_lifnr, gt_land.

  LOOP AT gt_out.
    gt_lifnr = gt_out-lifnr.
    COLLECT gt_lifnr.
  ENDLOOP.

  IF NOT gt_lifnr[] IS INITIAL.
    SELECT lifnr land1 INTO TABLE gt_land
    FROM  lfa1
    FOR  ALL ENTRIES IN gt_lifnr
    WHERE lifnr EQ gt_lifnr-lifnr .
    SORT gt_land BY lifnr.
  ENDIF.

  SORT it_row_tab BY artnr compn.

  DATA fr_ix TYPE i.

  DATA field_name_s(50).
  DATA field_name_t(50).


  LOOP AT gt_out.
    $ix = sy-tabix.
    READ TABLE it_row_tab WITH KEY artnr = gt_out-artnr
                                   BINARY SEARCH.
    IF sy-subrc EQ 0.
      fr_ix = sy-tabix.
    __fill_value_artnr : gt_out-bwdat 'IT_ROW_TAB-BWDAT' 'GT_OUT-BWDAT',
                         gt_out-aldat 'IT_ROW_TAB-ALDAT' 'GT_OUT-ALDAT',
                         gt_out-meins 'IT_ROW_TAB-MEINS' 'GT_OUT-MEINS',
                         gt_out-losgr 'IT_ROW_TAB-LOSGR' 'GT_OUT-LOSGR'.

    ENDIF.

    READ TABLE it_row_tab WITH KEY artnr = gt_out-artnr
                                   compn = gt_out-compn
                                   BINARY SEARCH.
    IF sy-subrc EQ 0.
      fr_ix = sy-tabix.
      __fill_value : gt_out-lifnr 'IT_ROW_TAB-LIFNR' 'GT_OUT-LIFNR',
                     gt_out-bklas 'IT_ROW_TAB-BKLAS' 'GT_OUT-BKLAS',
                     gt_out-stalt 'IT_ROW_TAB-STALT' 'GT_OUT-STALT',
                     gt_out-meeht 'IT_ROW_TAB-MEEHT' 'GT_OUT-MEEHT',
                     gt_out-matkl 'IT_ROW_TAB-MATKL' 'GT_OUT-MATKL',
                     gt_out-stawn 'IT_ROW_TAB-STAWN' 'GT_OUT-STAWN'.

    ENDIF.

    READ TABLE gt_land WITH KEY lifnr = gt_out-lifnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      gt_out-land1 = gt_land-land1.
    ENDIF.

    IF gt_out-stawn IS INITIAL.
      SELECT SINGLE stawn INTO gt_out-stawn FROM marc
              WHERE matnr EQ gt_out-compn.
    ENDIF.

    IF gt_out-bklas IS INITIAL.
      READ TABLE gt_color WITH KEY matnr_o = gt_out-compn.
      IF sy-subrc EQ 0.
        SELECT SINGLE b~bklas  INTO gt_out-bklas
                FROM ckmlrunperiod AS a
                  INNER JOIN ckmlmv011 AS b
                   ON  b~laufid = a~run_id
                INNER JOIN ckmlhd AS c
                  ON c~kalnr EQ b~kalnr
                WHERE a~gjahr = p_bdatj
                  AND a~poper = p_poper
                  AND c~matnr = gt_color-matnr_i
                  AND c~bwkey = gt_out-werks .
      ELSE.
        SELECT SINGLE b~bklas  INTO gt_out-bklas
                FROM ckmlrunperiod AS a
                  INNER JOIN ckmlmv011 AS b
                   ON  b~laufid = a~run_id
                INNER JOIN ckmlhd AS c
                  ON c~kalnr EQ b~kalnr
                WHERE a~gjahr = p_bdatj
                  AND a~poper = p_poper
                  AND c~matnr = gt_out-compn
                  AND c~bwkey = gt_out-werks .
      ENDIF.

      IF sy-subrc NE 0.
        SELECT SINGLE bklas INTO gt_out-bklas
                  FROM mbew
            WHERE matnr = gt_out-compn
              AND bwkey = gt_out-werks .
      ENDIF.
    ENDIF.

    IF gt_out-kstar IS INITIAL.
      SELECT SINGLE konts INTO gt_out-kstar
        FROM t030  WHERE ktopl EQ 'HNA1'
                     AND ktosl EQ 'GBB'
                     AND bwmod EQ '0001'
                     AND komok EQ 'VBR'
                     AND bklas EQ gt_out-bklas.
    ENDIF.

    MODIFY gt_out INDEX $ix.

  ENDLOOP.

  DATA $gt_out LIKE gt_out OCCURS 0 WITH HEADER LINE.
  SORT gt_color BY matnr_o.

  LOOP AT gt_out.

    $gt_out = gt_out.
    $verpr   = gt_out-verpr.
    $gpreis  = gt_out-gpreis.
    $peinh   = gt_out-peinh.
    $losgr   = gt_out-losgr.

    COLLECT $gt_out .
    MOVE :
      $verpr   TO $gt_out-verpr,
      $gpreis  TO $gt_out-gpreis,
      $peinh   TO $gt_out-peinh,
      $losgr   TO $gt_out-losgr.

    MODIFY $gt_out INDEX sy-tabix TRANSPORTING verpr
                                              gpreis peinh
                                              losgr meins col_spec.

  ENDLOOP.

  LOOP AT $gt_out.

    $ix = sy-tabix.

    READ TABLE gt_color WITH KEY matnr_o = $gt_out-compn
                                 BINARY SEARCH.
    IF sy-subrc EQ 0.
      $gt_out-col_spec = true.
    ELSE.
      $gt_out-col_spec = false.
    ENDIF.

* BEGIN OF UD1K950167
    CLEAR: $gt_out-gpreis, l_peinh.
    SELECT SINGLE verpr peinh INTO ($gt_out-gpreis, l_peinh)
      FROM mbewh
     WHERE matnr = $gt_out-compn
       AND bwkey = $gt_out-werks
       AND bwtar = space
       AND lfgja = p_bdatj
       AND lfmon = p_poper.

    IF NOT l_peinh IS INITIAL.
      $gt_out-gpreis  = $gt_out-gpreis / l_peinh.
    ENDIF.
* END OF UD1K950167

    MODIFY $gt_out INDEX $ix TRANSPORTING col_spec gpreis.  "UD1K950167
*   MODIFY $gt_out INDEX $ix TRANSPORTING col_spec.         "UD1K950167

  ENDLOOP.

  __cls gt_out.
  gt_out[] = $gt_out[].

ENDFORM.                    " move_out
*&---------------------------------------------------------------------*
*&      Form  set_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_output.

  CHECK : p_dsp EQ true,
          g_error IS INITIAL.

  PERFORM show_progress     USING 'Preparing screen...' '95'.
  PERFORM init_alv_parm.
  PERFORM fieldcat_init     USING gt_fieldcat[].
  PERFORM sort_build        USING gt_sort[].
  PERFORM alv_events_get    USING:  'P', 'T'.
  PERFORM alv_grid_display  TABLES  gt_out USING ''.

ENDFORM.                    " set_output

*---------------------------------------------------------------------*
*       FORM top_of_page                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.
  DATA l_text(60).
  REFRESH gt_listheader.

  l_text = 'Create ZTCO_NAFTA table entries'.
  PERFORM set_header_line USING:
          'P' 'H' ''      l_text       '',
          'S' 'S' 'FSC'   s_artnr-low  s_artnr-high,
          'P' 'S' 'Year'   p_bdatj      '',
          'P' 'S' 'Period' p_poper      ''.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            it_list_commentary = gt_listheader.

ENDFORM.                    "top_of_page

*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET
*---------------------------------------------------------------------*
FORM pf_status_set USING  ft_extab TYPE slis_t_extab.
  IF p_upd EQ true.
    SET PF-STATUS '100'." excluding 'SAVE'.
  ELSE.
    SET PF-STATUS '100' EXCLUDING ft_extab.
  ENDIF.
ENDFORM.                    "PF_STATUS_SET
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING fp_ucomm LIKE sy-ucomm
                        fs       TYPE slis_selfield.
  CLEAR : g_error.

  CASE fp_ucomm.
    WHEN 'SAVE'.
      CHECK g_error NE true.
      PERFORM save_z.

  ENDCASE.

ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  show_progress
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1894   text
*      -->P_1895   text
*----------------------------------------------------------------------*
FORM show_progress USING    pf_text
                            value(pf_val).

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = pf_val
            text       = pf_text.

ENDFORM.                    " SHOW_PROGRESS
*&---------------------------------------------------------------------*
*&      Form  init_alv_parm
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_alv_parm.

  __cls   :  gt_fieldcat, gt_sort, gt_events, gt_listheader,
             gt_sp_group.

  CLEAR   :  gs_layout.

  gs_layout-colwidth_optimize = 'X'.

*   Set variant
  gv_repid = gs_variant-report = sy-repid.
  gs_variant-variant = p_vari.

ENDFORM.                    " INIT_ALV_PARM
*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING ft_fieldcat TYPE slis_t_fieldcat_alv .

  DATA: l_pos TYPE i.

  __cls ft_fieldcat.

  DEFINE __catalog.
    l_pos = l_pos + 1.
    clear gs_fieldcat.
    gs_fieldcat-col_pos       = l_pos.
    gs_fieldcat-key           = &1.
    gs_fieldcat-fieldname     = &2.
    gs_fieldcat-seltext_m     = &3.        " Column heading
    gs_fieldcat-outputlen     = &4.        " Column width
    gs_fieldcat-datatype      = &5.        " Data type
    gs_fieldcat-emphasize     = &6.
    gs_fieldcat-cfieldname    = &7.
    gs_fieldcat-no_zero       = &8.
    append gs_fieldcat to  ft_fieldcat.
  END-OF-DEFINITION.

  __catalog :
    'X'  'ARTNR'    'FSC'              18  'CHAR' '' '' '',
    'X'  'VERID'    'Ver'               4  'CHAR' '' '' '',
    'X'  'COMPN'    'Component'        18  'CHAR' '' '' '',
    ' '  'MIP'      'M.I.P'            18  'CHAR' '' '' '',
    ' '  'UPGVC'    'UPGVC'            18  'CHAR' '' '' '',
    ' '  'MTART'    'Type'              4  'CHAR' '' '' '',
    ' '  'BKLAS'    'V.Cls'             4  'CHAR' '' '' '',
    ' '  'KSTAR'    'Cost Elem.'       10  'CHAR' '' '' '',
    ' '  'WERKS'    'Plant'             4  'CHAR' '' '' '',
    ' '  'SPLNT'    'S.Plnt'            4  'CHAR' '' '' ' ',
    ' '  'LIFNR'    'Vendor'            4  'CHAR' '' '' '',
    ' '  'LOSGR'    'Lot size'         13  'QUAN' '' '' 'X',
    ' '  'LAND1'    'CNTRY'             3  'CHAR' '' '' ' ',
    ' '  'GPREIS'   'Unit Price'       15  'CURR' '' '' ' ',
    ' '  'PEINH'    'PrU'               5  'DEC'  '' '' ' ',
    ' '  'MEEHT'    'UoM'               3  'CHAR' '' '' ' ',
    ' '  'ZLEVEL'   'Ct.Lvl'            4  'NUMC' '' '' ' ',
    ' '  'REQQT'    'Quantity'         15  'QUAN' '' '' 'X',
    ' '  'TOTAL'    'Amount'           15  'CURR' '' '' 'X',
    ' '  'TOSNDAMT' 'T.OS&D'           15  'CURR' '' '' 'X',
    ' '  'OSNDAMT'  'OS&D'             15  'CURR' '' '' 'X',
    ' '  'COL_SPEC' 'Col'               1  'CHAR' '' '' ' ',
    ' '  'RETRO'    'Ret'               1  'CHAR' '' '' ' '.

  PERFORM change_fieldcat USING ft_fieldcat[] .

ENDFORM.                    " fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  sort_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SORT[]  text
*----------------------------------------------------------------------*
FORM sort_build USING    ft_sort TYPE slis_t_sortinfo_alv.

  DEFINE sort_tab.
    clear gs_sort.
    gs_sort-fieldname = &1.
    gs_sort-spos      = &2.
    gs_sort-up        = &3.
    gs_sort-group     = &4.
    gs_sort-comp      = &5.
    append gs_sort to ft_sort.
  END-OF-DEFINITION.

  sort_tab :
     'ARTNR'        ' ' 'X' 'X' 'X',
     'VERID'        ' ' 'X' 'X' 'X',
     'COMPN'        ' ' 'X' 'X' 'X'.
*     'UPGVC'        ' ' 'X' 'X' 'X'.

ENDFORM.                    " SORT_BUILD
*&---------------------------------------------------------------------*
*&      Form  change_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM change_fieldcat USING    pt_fieldcat TYPE slis_t_fieldcat_alv.

  LOOP AT pt_fieldcat INTO gs_fieldcat.
    gs_fieldcat-ref_tabname = 'ZSCO_NAFTA_CK11'.
    gs_fieldcat-ref_fieldname = gs_fieldcat-fieldname.

    MODIFY pt_fieldcat FROM gs_fieldcat.
  ENDLOOP.

ENDFORM.                    " CHANGE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  default_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM default_.

  WRITE:
          icon_biw_report_view AS ICON TO vslt,
         'View saved data' TO vslt+4(21).

ENDFORM.                    " default_
*&---------------------------------------------------------------------*
*&      Form  view_
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_.

  PERFORM  initialize            .
  PERFORM view_from_table.

ENDFORM.                    " view_
*&---------------------------------------------------------------------*
*&      Form  initialize
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize.
  CLEAR g_error.
  PERFORM get_date.
  PERFORM get_bukrs.
  PERFORM get_plant.
ENDFORM.                    " initialize
*&---------------------------------------------------------------------*
*&      Form  view_from_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_from_table.

  __cls gt_out.

  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE gt_out
  FROM ztco_nafta
  WHERE kokrs = p_kokrs
    AND bdatj = p_bdatj
    AND poper = p_poper
    AND artnr IN s_artnr
    AND werks IN gr_bwkey .

  CHECK sy-subrc EQ 0.

  DATA : $p_upd LIKE p_upd,
         $p_dsp LIKE p_dsp.

  $p_upd = p_upd.
  $p_dsp = p_dsp.

  p_upd = false.
  p_dsp = true.

  PERFORM  set_output .

  p_upd = $p_upd.
  p_dsp = $p_dsp.

ENDFORM.                    " view_from_table
*&---------------------------------------------------------------------*
*&      Form  get_mip_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_CK11  text
*      -->P_$CK11  text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_mip_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_CK11  text
*      -->P_$CK11  text
*----------------------------------------------------------------------*
FORM get_mip_list TABLES   p_lt_ztco_ck11 STRUCTURE ztco_ck11
                           p_$ck11 STRUCTURE ztco_ck11.

  __cls p_$ck11.
  LOOP AT p_lt_ztco_ck11 WHERE stkkz = 'X'.
    p_$ck11 = p_lt_ztco_ck11.
    APPEND p_$ck11.
  ENDLOOP.

ENDFORM.                    " get_mip_list
*&---------------------------------------------------------------------*
*&      Form  get_ck11_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LTA_ZTCO_CK11  text
*      -->P_$CK11  text
*----------------------------------------------------------------------*
FORM get_ck11_data TABLES   p_ztco_ck11 STRUCTURE ztco_ck11
                            p_$ck11 STRUCTURE ztco_ck11
                   USING    $p_kokrs
                            $p_klvar
                            $p_year
                            $p_month
                            $p_artnr.

  __cls p_ztco_ck11.

  IF p_$ck11[] IS INITIAL.
    SELECT * INTO TABLE p_ztco_ck11
      FROM ztco_ck11
    WHERE kokrs = $p_kokrs
      AND klvar = $p_klvar
      AND bdatj = $p_year
      AND poper = $p_month
      AND artnr = $p_artnr
      AND werks IN gr_bwkey
      %_HINTS oracle 'FIRST_ROWS(10) INDEX("ZTCO_CK11" "ZTCO_CK11~0")'.
  ELSE.
    SELECT * INTO TABLE p_ztco_ck11
      FROM ztco_ck11
      FOR ALL ENTRIES IN p_$ck11
    WHERE kokrs = $p_kokrs
      AND klvar = $p_klvar
      AND bdatj = $p_year
      AND poper = $p_month
      AND artnr = p_$ck11-compn
      AND werks IN gr_bwkey
*      and verid = p_$ck11-verid
    %_HINTS oracle 'FIRST_ROWS(10) INDEX("ZTCO_CK11" "ZTCO_CK11~0")'.
  ENDIF.

ENDFORM.                    " get_ck11_data
*&---------------------------------------------------------------------*
*&      Form  get_osnd_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_OSND  text
*      -->P_$OSND  text
*      -->P_$P_KOKRS  text
*      -->P_$P_YEAR  text
*      -->P_$P_MONTH  text
*      -->P_$P_ARTNR  text
*----------------------------------------------------------------------*
FORM get_osnd_data TABLES   p_ztco_osnd STRUCTURE zsco_osnd
                            p_$osnd STRUCTURE ztco_ck11
                   USING    $p_kokrs
                            $p_year
                            $p_month
                            $p_artnr.

  DATA $p_ztco_osnd LIKE p_ztco_osnd
   OCCURS 0 WITH HEADER LINE.


  __cls p_ztco_osnd.

  IF p_$osnd[] IS INITIAL.

    SELECT
            a~kokrs
            a~gjahr
            a~period
            a~kstar
            a~werks
            a~matnr		
            a~chg_wkgbtr	
            a~waers	
            a~mbgbtr
            a~meinb	
            a~fsc_matnr
            a~verid	
            b~mtart
      INTO TABLE p_ztco_osnd
      FROM ztco_abispost AS a
      INNER JOIN mara AS b
      ON b~matnr EQ a~matnr
    WHERE a~kokrs = $p_kokrs
      AND a~gjahr = $p_year
      AND a~period = $p_month
      AND a~fsc_matnr = $p_artnr
       %_HINTS ORACLE 'FIRST_ROWS(10)'.

  ELSE.

    SELECT
        a~kokrs
        a~gjahr
        a~period
        a~kstar
        a~werks
        a~matnr		
        a~chg_wkgbtr	
        a~waers	
        a~mbgbtr
        a~meinb	
        a~fsc_matnr
        a~verid	
        b~mtart
      INTO TABLE p_ztco_osnd
      FROM ztco_abispost AS a
      INNER JOIN mara AS b
      ON b~matnr EQ a~matnr
    FOR ALL ENTRIES IN p_$osnd
    WHERE a~kokrs = $p_kokrs
      AND a~gjahr = $p_year
      AND a~period = $p_month
      AND a~fsc_matnr = p_$osnd-compn
   %_HINTS ORACLE 'FIRST_ROWS(10)'.

  ENDIF.

  LOOP AT p_ztco_osnd.
    $p_ztco_osnd = p_ztco_osnd.
    CLEAR $p_ztco_osnd-kstar.
    COLLECT $p_ztco_osnd.
  ENDLOOP.
  __cls p_ztco_osnd.
  p_ztco_osnd[] = $p_ztco_osnd[].
ENDFORM.                    " get_osnd_data
*&---------------------------------------------------------------------*
*&      Form  get_mip_list_osnd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_OSND  text
*----------------------------------------------------------------------*
FORM get_mip_list_osnd TABLES  p_lt_ztco_osnd STRUCTURE zsco_osnd
                               p_$osnd  STRUCTURE zsco_osnd.

  __cls p_$osnd.
  LOOP AT p_lt_ztco_osnd WHERE mtart = 'HALB' or mtart = 'SEMI'.
    p_$osnd = p_lt_ztco_osnd.
    APPEND p_$osnd.
  ENDLOOP.

ENDFORM.                    " get_mip_list_osnd
*&---------------------------------------------------------------------*
*&      Form  fill_missed_osnd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ZTCO_CK11  text
*      -->P_LT_ZTCO_OSND  text
*----------------------------------------------------------------------*
FORM fill_missed_osnd TABLES   p_lt_ztco_ck11 STRUCTURE ztco_ck11
                               p_lt_ztco_osnd STRUCTURE zsco_osnd.

  LOOP AT p_lt_ztco_ck11.
    READ TABLE p_lt_ztco_osnd WITH KEY matnr = p_lt_ztco_ck11-compn
                                     BINARY SEARCH.
    IF sy-subrc NE 0." and p_lt_ztco_ck11-werks eq 'E001'.
      MOVE-CORRESPONDING p_lt_ztco_ck11 TO p_lt_ztco_osnd.
      p_lt_ztco_osnd-gjahr = p_lt_ztco_ck11-bdatj.
      p_lt_ztco_osnd-period = p_lt_ztco_ck11-poper.
      p_lt_ztco_osnd-matnr = p_lt_ztco_ck11-compn.
      p_lt_ztco_osnd-chg_wkgbtr = 0.
      p_lt_ztco_osnd-mbgbtr = 0.
      p_lt_ztco_osnd-fsc_matnr = p_lt_ztco_ck11-artnr.
      APPEND p_lt_ztco_osnd.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " fill_missed_osnd
*&---------------------------------------------------------------------*
*&      Form  add_prd_qty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$CK11_2  text
*----------------------------------------------------------------------*
FORM add_prd_qty TABLES   p_$ck11_2 STRUCTURE ztco_ck11.

  DATA : it_ckmlmv003_temp LIKE it_ckmlmv003 OCCURS 0 WITH HEADER LINE.

** read GR data
  CHECK NOT p_$ck11_2[] IS INITIAL.
  SELECT  a~bwkey a~matnr a~verid_nd
          c~aufnr
          b~out_menge
          b~meinh
    INTO CORRESPONDING FIELDS OF TABLE it_ckmlmv003_temp
    FROM ckmlmv001 AS a
    INNER JOIN ckmlmv003 AS b
       ON a~kalnr    =  b~kalnr_bal
    INNER JOIN ckmlmv013 AS c
       ON c~kalnr_proc = b~kalnr_in
    FOR ALL ENTRIES IN p_$ck11_2
   WHERE a~werks    IN gr_bwkey
     AND a~matnr    =  p_$ck11_2-compn
     AND a~btyp     =  'BF'
     AND a~bwkey     IN  gr_bwkey
     AND b~gjahr    =  p_bdatj
     AND b~perio    =  p_poper
     AND c~flg_wbwg = 'X'
     AND c~autyp = '05'.

  LOOP AT it_ckmlmv003_temp.
    MOVE-CORRESPONDING it_ckmlmv003_temp TO it_ckmlmv003.
    CLEAR: " it_ckmlmv003-verid_nd,
           it_ckmlmv003-aufnr.
    COLLECT it_ckmlmv003. CLEAR it_ckmlmv003.
  ENDLOOP.

ENDFORM.                    " add_prd_qty
*&---------------------------------------------------------------------*
*&      Form  get_field_value
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2578   text
*----------------------------------------------------------------------*
FORM get_field_value USING p_src
                           p_tar
                           fr_ix.
  ASSIGN : (p_src) TO <f_s>,
           (p_tar) TO <f_t>.

  LOOP AT it_row_tab FROM fr_ix.
    IF it_row_tab-artnr NE gt_out-artnr OR
       it_row_tab-compn NE gt_out-compn.
      EXIT.
    ENDIF.
    IF NOT <f_s> IS INITIAL.
      <f_t> = <f_s>.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_field_value


*---------------------------------------------------------------------*
*       FORM get_field_value_artnr                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_SRC                                                         *
*  -->  P_TAR                                                         *
*  -->  FR_IX                                                         *
*---------------------------------------------------------------------*
FORM get_field_value_artnr USING p_src
                                 p_tar
                                 fr_ix.
  ASSIGN : (p_src) TO <f_s>,
           (p_tar) TO <f_t>.

  LOOP AT it_row_tab FROM fr_ix.
    IF it_row_tab-artnr NE gt_out-artnr.
      EXIT.
    ENDIF.
    IF NOT <f_s> IS INITIAL.
      <f_t> = <f_s>.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " get_field_value
*&---------------------------------------------------------------------*
*&      Form  get_simple_matnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_COMPN  text
*      <--P_$MATNR  text
*----------------------------------------------------------------------*
FORM get_simple_matnr USING    p_compn
                      CHANGING p_$matnr.

* EM4CPM100210QZ
* 012345678901

  DATA $strlen TYPE i.

  $strlen = strlen( p_compn ).

  IF p_compn+5(2) EQ 'M1'.
    p_$matnr = p_compn(12).
  ELSE.
    IF $strlen > 11.
      CASE $strlen.
        WHEN 12 OR 13.
          p_$matnr = p_compn(10).
*        WHEN 14 OR 15.
*          p_$matnr = p_compn+(12).
      ENDCASE.
    ELSE.
      p_$matnr = p_compn.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_simple_matnr

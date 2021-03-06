*----------------------------------------------------------------------*
*  INCLUDE ZACOU104_TOP                                                *
*----------------------------------------------------------------------*
*  Define Variant & tables & local class
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Define Variant & tables
*----------------------------------------------------------------------*
TABLES: ztcou104,    " [CO] Variance Analysis Code
        ztcoum05,    " [CO] ID Master
        *ztcou104, mvke, ztcou103,ztcou104lock,*ztcou104lock,
        ztcou100, mara.

* Internal Table for Display
TYPES: BEGIN OF ty_out.
        INCLUDE STRUCTURE ztcou104.
TYPES:  chk,
        celltab TYPE lvc_t_styl,
        tabcolor TYPE slis_t_specialcol_alv,
        indx TYPE i,
        werks	TYPE werks_d,
        fevor	TYPE fevor,
        mtart	TYPE mtart,
        prodh	TYPE prodh_d,
        model	TYPE zcofcmdl,
        kunnr	TYPE kunnr,
        mvgr4	TYPE mvgr4,
        mvgr3	TYPE mvgr3,
        mvgr5	TYPE mvgr5,
        matkl TYPE matkl,
        mvgr5abp TYPE mvgr5,
        lock,
*        lock_ico TYPE icon,
        lock_ico(4),      "2011.09.06  change
       END OF ty_out.


TYPES: BEGIN OF ty_out_lk.
        INCLUDE STRUCTURE ztcou104lock.
TYPES:  idtext TYPE maktg,
        chk,
        celltab TYPE lvc_t_styl,
        tabcolor TYPE slis_t_specialcol_alv,
        indx TYPE i,
       END OF ty_out_lk.

TYPES ddshretval_table TYPE TABLE OF ddshretval.

DATA: bezei       TYPE bezei,          " Controling area descrption
      gv_cnt      TYPE i,              " Total count
      gv_index    TYPE sytabix,        " Row Index
      gt_ztcou104 TYPE TABLE OF ztcou104 WITH HEADER LINE,
      gt_out      TYPE TABLE OF ty_out   WITH HEADER LINE,
     $gt_out      TYPE TABLE OF ty_out   WITH HEADER LINE.

DATA : BEGIN OF it_ckmlmv003 OCCURS 0,
         bwkey      LIKE ckmlmv001-bwkey,
         matnr      LIKE ckmlmv001-matnr,
         aufnr      LIKE ckmlmv013-aufnr,
         verid_nd   LIKE ckmlmv001-verid_nd,
         meinh      LIKE ckmlmv003-meinh,
         out_menge  LIKE ckmlmv003-out_menge,
         mvgr5      LIKE mvke-mvgr5,
         fevor      LIKE marc-fevor,

         model LIKE  zscou140-model,
         kunnr LIKE  zscou140-kunnr,

         mtart LIKE mara-mtart,
         matkl LIKE mara-matkl,

         werks LIKE marc-werks,
       END OF  it_ckmlmv003.

DATA BEGIN OF $gt_work OCCURS 0.
DATA  dealer(10).
DATA  gr5(5).
DATA  mi(20).
DATA  idx TYPE i.
        INCLUDE STRUCTURE gt_out.
DATA  END OF $gt_work.


DATA: BEGIN OF mi_prd_tab OCCURS 0,
        dealer(10),
        mi(20),
        year(4) TYPE n,
        poper(2) TYPE n,
        fsc TYPE matnr,
      END OF mi_prd_tab.

DATA: BEGIN OF mi_pln_tab OCCURS 0,
        dealer(10),
        mi(20),
        year(4) TYPE n,
        poper(2) TYPE n,
        fsc TYPE matnr,
      END OF mi_pln_tab.

DATA: BEGIN OF lt_mvke OCCURS 0,
        matnr  LIKE mvke-matnr,
        prodh  LIKE mvke-prodh,
        mvgr3  LIKE mvke-mvgr3,
        mvgr4  LIKE mvke-mvgr4,
        mvgr5  LIKE mvke-mvgr5,
        werks  LIKE marc-werks,
        fevor  LIKE marc-fevor,
        mtart  LIKE mara-mtart,
        matkl  LIKE mara-matkl,
      END OF lt_mvke.

DATA: BEGIN OF lt_a005 OCCURS 0,
        matnr   LIKE a005-matnr,
        kunnr   LIKE a005-kunnr,
      END   OF lt_a005.

TYPES: BEGIN OF ty_plant,
         bwkey TYPE bwkey,
       END OF ty_plant.

RANGES : gr_bwkey FOR t001w-bwkey.
DATA gt_plant      TYPE TABLE OF ty_plant    WITH HEADER LINE.

CONSTANTS: c_fsc01 TYPE dynfnam VALUE 'GT_OUT-FSC1',
           c_fsc02 TYPE dynfnam VALUE 'GT_OUT-FSC2',
           c_fsc03 TYPE dynfnam VALUE 'GT_OUT-FSC3',
           c_fsc04 TYPE dynfnam VALUE 'GT_OUT-FSC4',
           c_fsc05 TYPE dynfnam VALUE 'GT_OUT-FSC5',
           c_fsc06 TYPE dynfnam VALUE 'GT_OUT-FSC6',
           c_fsc07 TYPE dynfnam VALUE 'GT_OUT-FSC7',
           c_fsc08 TYPE dynfnam VALUE 'GT_OUT-FSC8',
           c_fsc09 TYPE dynfnam VALUE 'GT_OUT-FSC9',
           c_fsc10 TYPE dynfnam VALUE 'GT_OUT-FSC10',
           c_fsc11 TYPE dynfnam VALUE 'GT_OUT-FSC11',
           c_fsc12 TYPE dynfnam VALUE 'GT_OUT-FSC12'.

DATA  g_kokrs LIKE ztcou104-kokrs.
DATA  g_year LIKE ztcou104-bdatj .
DATA  g_kalka LIKE ztcou104-kalka.

DATA fname(30).
DATA fname2(30).
DATA fname3(30).
FIELD-SYMBOLS : <to>,<from>.

*Icon constants
constants: gc_red_icon(4)    value '@0A@'.  "ICON_LED_RED
constants: gc_green_icon(4)  value '@08@'.  "ICON_LED_GREEN
constants: gc_yellow_icon(4) value '@09@'.  "ICON_LED_YELLOW

*----------------------------------------------------------------------*
* Define local class
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF ztcou104_k,
              kokrs   TYPE kokrs,
              bdatj   TYPE bdatj,
              kalka   TYPE ck_kalka,
              id      TYPE zid1,
           END OF ztcou104_k.

    TYPES: ztcou104_key   TYPE STANDARD TABLE OF ztcou104_k,
           ztcou104_table TYPE STANDARD TABLE OF ztcou104.

    METHODS:
      handle_data_changed
         FOR EVENT data_changed OF cl_gui_alv_grid
             IMPORTING er_data_changed,
                       get_deleted_rows
             EXPORTING
                       deleted_rows TYPE ztcou104_table.

    METHODS:
             handle_double_click
                FOR EVENT double_click OF cl_gui_alv_grid
                IMPORTING e_row
                          e_column
                          es_row_no.

    METHODS:
      refresh_delta_tables.


  PRIVATE SECTION.
    DATA deleted_rows TYPE STANDARD TABLE OF ztcou104.
    DATA  error_in_data TYPE c.
    METHODS:
      perform_semantic_checks
         IMPORTING
            pr_data_changed TYPE REF TO cl_alv_changed_data_protocol.

ENDCLASS.                   " LCL_EVENT_RECEIVER Definition

*----------------------------------------------------------------------*
* Implementation local class
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

* Setting for Change data

  METHOD handle_data_changed.

    error_in_data = space.

* check mt_good_cells semantically
    CALL METHOD perform_semantic_checks( er_data_changed ).
    IF error_in_data = 'X'.
      CALL METHOD er_data_changed->display_protocol.
    ENDIF.

  ENDMETHOD.                    " handle_data_changed

  METHOD get_deleted_rows.
    deleted_rows = me->deleted_rows.
  ENDMETHOD.

  METHOD refresh_delta_tables.
    CLEAR me->deleted_rows[].
  ENDMETHOD.

  METHOD perform_semantic_checks.

    DATA: ls_mod_cells TYPE lvc_s_modi,
          ls_cells     TYPE lvc_s_modi.

    DATA: l_del_row TYPE lvc_s_moce,
          ls_ztcou104 TYPE ztcou104.

    DATA: l_ins_row TYPE lvc_s_moce,
          ls_outtab LIKE LINE OF gt_out.

    DATA: flag_insert.
    DATA: l_text(50).
    DATA: l_num(3) TYPE n.
    DATA: l_year(4) TYPE n.
    DATA locked(1).
    FIELD-SYMBOLS: <fs> TYPE table.    " Output table

    LOOP AT pr_data_changed->mt_deleted_rows INTO l_del_row.
      READ TABLE gt_out INTO ls_outtab INDEX l_del_row-row_id.
      IF sy-subrc NE 0.
        MESSAGE i000(0k) WITH text-e01. "Internal error
      ELSE.

        CALL FUNCTION 'Z_CHK_LOCK_STATUS_FSC_OVERAL'
             EXPORTING
                  kokrs  = gt_out-kokrs
                  bdatj  = gt_out-bdatj
                  kalka  = gt_out-kalka
                  id     = gt_out-id
             IMPORTING
                  locked = locked.

        IF locked EQ 'X'.
          MESSAGE i000 WITH
              'Locked FSC will be disappeared on screen not database.'.
        ENDIF.

        MOVE-CORRESPONDING ls_outtab TO ls_ztcou104.
        APPEND ls_ztcou104 TO deleted_rows.
      ENDIF.
    ENDLOOP.

    LOOP AT pr_data_changed->mt_inserted_rows INTO l_ins_row.
      ASSIGN pr_data_changed->mp_mod_rows->* TO <fs>.

      LOOP AT <fs> INTO ls_outtab.
        ls_outtab-mandt = sy-mandt.
        ls_outtab-kokrs = g_kokrs.
        ls_outtab-bdatj = g_year.
        ls_outtab-kalka = g_kalka.
        MODIFY <fs> FROM ls_outtab INDEX sy-tabix.
      ENDLOOP.
      flag_insert = 'X'.
    ENDLOOP.

    CHECK flag_insert EQ space.

    LOOP AT pr_data_changed->mt_good_cells INTO ls_mod_cells.

      READ TABLE gt_out INTO ls_outtab INDEX ls_mod_cells-row_id .

      IF sy-subrc = 0 AND ls_mod_cells-value NE space.
        IF ls_mod_cells-fieldname CP 'FSC*'.
          l_num = ls_mod_cells-fieldname+4(2).

          SELECT SINGLE * INTO ztcou100 FROM ztcou100
                          WHERE kokrs EQ ls_outtab-kokrs
                            AND kalka EQ ls_outtab-kalka
                            AND bdatj EQ ls_outtab-bdatj
                            AND poper EQ l_num
                            AND matnr EQ ls_mod_cells-value.

          IF sy-subrc NE 0.

            SELECT SINGLE * INTO ztcou103 FROM ztcou103
                  WHERE kokrs EQ ls_outtab-kokrs
                    AND kalka EQ ls_outtab-kalka
                    AND bdatj EQ ls_outtab-bdatj
                    AND poper EQ l_num
                    AND artnr EQ ls_mod_cells-value.

            IF sy-subrc NE 0.
              error_in_data = 'X'.
              EXIT.
            ENDIF.
          ENDIF.

        ELSE.
          CASE ls_mod_cells-fieldname.
            WHEN 'ZABP_FSC'.
              SELECT SINGLE * INTO ztcou103 FROM ztcou103
                              WHERE kokrs EQ ls_outtab-kokrs
                                AND kalka EQ 'BP'
                                AND bdatj EQ ls_outtab-bdatj
                                AND poper EQ '001'
                                AND artnr EQ ls_mod_cells-value.
              IF sy-subrc NE 0.
                error_in_data = 'X'.
                EXIT.
              ENDIF.
            WHEN 'ZBASE_FSC'.

              IF NOT ls_outtab-zbase_fsc IS INITIAL.
                l_year = ls_outtab-zbase_fsc.
              ELSE.
                l_year = ls_outtab-bdatj - 1.
              ENDIF.

              l_year =  ls_outtab-bdatj - 1.
              SELECT SINGLE * INTO ztcou103 FROM ztcou103
                              WHERE kokrs EQ ls_outtab-kokrs
                                AND kalka EQ ls_outtab-kalka
                                AND bdatj EQ l_year
                                AND poper EQ '012'
                                AND artnr EQ ls_mod_cells-value.
              IF sy-subrc NE 0.
                error_in_data = 'X'.
                EXIT.
              ENDIF.
          ENDCASE.
        ENDIF.
        CALL METHOD pr_data_changed->modify_cell
                  EXPORTING i_row_id    = ls_mod_cells-row_id
                            i_fieldname = ls_mod_cells-fieldname
                            i_value     = ls_mod_cells-value.

        MODIFY gt_out FROM ls_outtab INDEX ls_mod_cells-row_id.

      ENDIF.
    ENDLOOP.

    IF error_in_data EQ 'X'.
      CONCATENATE '''' ls_mod_cells-value '''' ':' ls_outtab-bdatj
  'does not exist.' INTO l_text SEPARATED BY space.
      CALL METHOD pr_data_changed->add_protocol_entry
                   EXPORTING
        i_msgid = '0K' i_msgno = '000'  i_msgty = 'E'
        i_msgv1 = l_text
        i_fieldname = ls_mod_cells-fieldname
        i_row_id = ls_mod_cells-row_id.
    ENDIF.
  ENDMETHOD.

* Setting for double click
  METHOD handle_double_click.
    PERFORM double_click USING e_row
                               e_column
                               es_row_no.
  ENDMETHOD.                    " handle_hotspot_click

ENDCLASS.                   " LCL_EVENT_RECEIVER Implementation

DATA g_event_receiver  TYPE REF TO lcl_event_receiver.

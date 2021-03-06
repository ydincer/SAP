*--------------------------------------------------------------------*
* Prgram  : ZACO20R_SHOP_NEW                                         *
* Date    : 2006.08.08                                               *
* Author  : JHS                                                      *
* Spec    : Andy Choi                                                *
*                                                                    *
* Modification Log                                                   *
* Date        Developer Issue No Description                         *
* 6/10/2010   VALERIAN  Add selection logic based on 'Component'     *
*             HIS20094  field (defined in selection-screen)          *
* 6/18/2013   T00303    UD1K957395  U1: Apply Archiving
*--------------------------------------------------------------------*

report  zaco20r_shop_new message-id zmco no standard page heading.


tables : ztco_shop_sum,
         ztco_shop_cc,
         tka01,
         a018,
         mara.

data : it_shop_sum like table of ztco_shop_sum with header line.
data : begin of it_shop_cc  occurs 0.
        include structure ztco_shop_cc.
data :   verid like ztco_shop_sum-verid,
       end of it_shop_cc.

data : begin of it_display occurs 0,
       poper like ztco_shop_sum-poper,
       artnr like ztco_shop_sum-artnr,
       typps like ztco_shop_sum-typps,
       kstar like ztco_shop_sum-kstar,
       resou like ztco_shop_sum-resou,

       shop  like ztco_shop_sum-shop,

       elemt        like ztco_shop_cc-elemt,
       wkgbtr       like ztco_shop_cc-wkgbtr,
       wkgbtr2      like ztco_shop_cc-wkgbtr2,
       add_wkgbtr   like ztco_shop_cc-wkgbtr,
       wip_amt      like ztco_shop_cc-wip_amt,
       wip_pamt     like ztco_shop_cc-wip_pamt,
       scrap_amt    like ztco_shop_cc-scrap_amt,
       manu_amt     like ztco_shop_cc-manu_amt,
       gr_amt       like ztco_shop_cc-gr_amt,
       single_amt   like ztco_shop_cc-single_amt,
       multi_amt    like ztco_shop_cc-multi_amt,
       multi_samt   like ztco_shop_cc-multi_samt ,
       multi_mamt   like ztco_shop_cc-multi_mamt,
       misc         like ztco_shop_cc-misc,

       gr_qty       like ztco_shop_sum-gr_qty,
       single_qty   like ztco_shop_sum-single_qty,
       manu_qty     like ztco_shop_sum-manu_qty,
       pp_grqty     like ztco_shop_sum-gr_qty,
       maktg        like makt-maktg,

       wkgbtr_f     like ztco_shop_cc-wkgbtr,
       wkgbtr2_f    like ztco_shop_cc-wkgbtr2,
       add_wkgbtr_f like ztco_shop_cc-wkgbtr,
       wip_amt_f    like ztco_shop_cc-wip_amt,
       wip_pamt_f   like ztco_shop_cc-wip_pamt,
       scrap_amt_f  like ztco_shop_cc-scrap_amt,
       manu_amt_f   like ztco_shop_cc-manu_amt,
       gr_amt_f     like ztco_shop_cc-gr_amt,
       single_amt_f like ztco_shop_cc-single_amt,
       multi_amt_f  like ztco_shop_cc-multi_amt,
       multi_samt_f like ztco_shop_cc-multi_samt ,
       multi_mamt_f like ztco_shop_cc-multi_mamt,
       misc_f       like ztco_shop_cc-misc,

       llv_matnr like ztco_shop_sum-llv_matnr,
       kostl     like ztco_shop_sum-kostl,
       lstar     like ztco_shop_sum-lstar,
       par_werks like ztco_shop_sum-par_werks,
       bwkey     like ztco_shop_sum-bwkey,

       stprs     like ztco_shop_sum-stprs,
       verpr     like ztco_shop_sum-verpr,
       peinh     like ztco_shop_sum-peinh,
       meeht     like ztco_shop_sum-meeht,

       aufnr     like ztco_shop_sum-aufnr,
       verid     like ztco_shop_sum-verid,

       lifnr like ekko-lifnr,
       name1 like lfa1-name1.

data : end of it_display .

data : begin of it_ckmlmv003 occurs 0,
         bwkey      like ckmlmv001-bwkey,
         matnr      like ckmlmv001-matnr,
         aufnr      like ckmlmv013-aufnr,
         verid_nd   like ckmlmv001-verid_nd,
         meinh      like ckmlmv003-meinh,
         out_menge  like ckmlmv003-out_menge,
       end of  it_ckmlmv003.

data : begin of it_mara occurs 0,
         werks type werks_d,
         matnr type matnr,
       end of it_mara.

data : begin of it_marc occurs 0,
         matnr      like marc-matnr,
         werks      like marc-werks,

         raube      like mara-raube, "shop
         fevor      like marc-fevor, "PP schedule
         mtart      like mara-mtart,
         matkl      like mara-matkl,
         vspvb      like marc-vspvb,
         prctr      like marc-prctr,
         maktg      like makt-maktg,
       end of  it_marc.


data : begin of it_s013  occurs 0,
         matnr like s013-matnr,
         lifnr like s013-lifnr,
         name1 like lfa1-name1,
         spmon like s013-spmon,
       end of it_s013 .

data : begin of it_ekbe  occurs 0,
         matnr type matnr,
         lifnr like ekko-lifnr,
         budat like ekbe-budat,
       end of it_ekbe .

data : begin of it_lfa1  occurs 0,
         lifnr like lfa1-lifnr,
         name1 like lfa1-name1,
       end of it_lfa1 .

*- U1 Start
data: gt_ztco_shop_cc_a  type table of ztco_shop_cc  with header line,
      gt_ztco_shop_sum_a type table of ztco_shop_sum with header line,
      gt_ckmlmv013_a     type table of ckmlmv013     with header line.

data: begin of gt_proc_gr_a occurs 0,
      par_werks like it_shop_sum-bwkey,
      artnr     like it_shop_sum-artnr,
      aufnr     like it_shop_sum-aufnr,
      verid     like it_shop_sum-verid,
      bdatj     like it_shop_sum-bdatj,
      poper     like it_shop_sum-poper,
      end of gt_proc_gr_a.

data: begin of gt_ekbe_a occurs 0,
      matnr like ekbe-matnr,
      lifnr like ekko-lifnr,
      budat like ekbe-budat,
      end of gt_ekbe_a.

ranges: gr_ven_matnr_a for s013-matnr,
        gr_werks_a     for ekbe-werks.
*- U1 End

*--------------------------------------------------------------------*
* INCLUDE
*--------------------------------------------------------------------*
include zco_alv_top.
include zco_alv_form.


*--------------------------------------------------------------------*
* INITIALIZATION.
*--------------------------------------------------------------------*
initialization.
*  perform init_variant.

*--------------------------------------------------------------------*
* SELECTION-SCREEN
*--------------------------------------------------------------------*
  selection-screen begin of block bl1 with frame title text-001.

  parameters     : p_kokrs like ztco_shop_sum-kokrs memory id cac,
                   p_bdatj like ztco_shop_sum-bdatj memory id bdtj.
  select-options : s_poper for ztco_shop_sum-poper  memory id popr,
                   s_artnr for ztco_shop_sum-artnr  memory id  mat,
                   s_verid for ztco_shop_sum-verid,
                   s_typps for ztco_shop_sum-typps,
                   s_kstar for ztco_shop_sum-kstar memory id ka3,
                   s_resou for ztco_shop_sum-resou,
                   s_elemt for ztco_shop_cc-elemt,
                   s_shop  for ztco_shop_sum-shop,
                   s_fevor for ztco_shop_sum-fevor,
                   s_matnr for ztco_shop_sum-llv_matnr.     "HIS20094

  selection-screen end of block bl1.
*  select-options : s_aufnr for ztco_shop_sum-aufnr  memory id anr,
*                   s_verid for ztco_shop_sum-verid.
  parameters: p_shop   as checkbox default ' '.  "derive shop from mater

* Reporting Options
  selection-screen begin of block bl2 with frame title text-002.
  selection-screen begin of line.
  selection-screen comment (15) text-004.
  selection-screen position 33.
*--(scale)
  parameters: p_trunc like rfpdo1-ts70skal  default '0'.
  selection-screen comment 35(1) text-005.
*--(decimals)
  parameters: p_decl like rfpdo1-ts70skal  default '0'.
  selection-screen end of line.

*  selection-screen skip 1.
  selection-screen begin of block bl3 with frame title text-003.
  parameters : p_unit  radiobutton group ra01.    "Unit price
  parameters : p_sum   radiobutton group ra01.    "Amt

  selection-screen end of block bl3.


  selection-screen skip 1.


  parameters: p_lifnr as checkbox default ' '.
  select-options: s_lifnr for a018-lifnr.
  selection-screen skip 1.
  parameters: p_vsum   as checkbox default 'X'.  "Sum all version
  parameters: p_matgrp  as checkbox default 'X'. "Sum by material group

  selection-screen end of block bl2.

*- U1 Start
  include ziarch_comm01.
*- U1 End
  selection-screen skip 1.

  selection-screen begin of block bl4 with frame title text-006.
  parameters : p_cp as checkbox.
  selection-screen begin of line.

  selection-screen comment 3(70) text-m01.
  selection-screen end of line.
  selection-screen end of block bl4.

*--------------------------------------------------------------------*
start-of-selection.
*--------------------------------------------------------------------*

** Added on 10/02/13 for archiving bug fix
  if p_cp = 'X'.
    data: lt_ckmlmv013 like table of ckmlmv013 with header line,
          l_cn type i.
    select * into table lt_ckmlmv013
      from ckmlmv013.
    describe table  lt_ckmlmv013 lines l_cn.
    if l_cn > 0.
      modify zckmlmv013 from table lt_ckmlmv013.
      if sy-subrc = 0.
        commit work.
        message s000 with'Data was copied: ' l_cn.
      else.
        rollback work.
        message s000 with'Error Occured'.
      endif.
    endif.
    exit.
  endif.
** End on 10/02/13
* Select SHOP Summary
  perform read_tka01.
  perform get_table.

* AMT displayed per unit
* IF P_UNIT = 'X'.
  perform get_product_gr.
* ENDIF.

  perform define_mara.
  perform get_material_group.

* Vendor displayed
  if p_lifnr = 'X'.
    if 1 = 2.
      perform get_lifnr_for_part.
    endif.
    perform get_lifnr_for_part_new.
    perform get_lifnr_name.

    it_s013-matnr = 'R16N'.  "*R16N Engine
    it_s013-lifnr = 'SEF9'.
    append it_s013.

  endif.

  perform make_data.

*--------------------------------------------------------------------*
end-of-selection.
*--------------------------------------------------------------------*
*-- Data Display
  perform display_data.

*&---------------------------------------------------------------------*
*&      Form  GET_TABLE
*&---------------------------------------------------------------------*
form get_table .

  perform get_shop_cost.

endform.                    " GET_TABLE
*&---------------------------------------------------------------------*
*&      Form  GET_SHOP_COST
*&---------------------------------------------------------------------*
form get_shop_cost.

  select  *  into table it_shop_sum
     from ztco_shop_sum
    where kokrs       =  p_kokrs
      and bdatj       =  p_bdatj
      and poper       in s_poper
      and typps       in s_typps
      and kstar       in s_kstar
      and resou       in s_resou
      and artnr       in s_artnr
      and verid       in s_verid
      and shop        in s_shop
      and fevor       in s_fevor
      and llv_matnr   in s_matnr.                           "HIS20094

*- U1 Start
  if p_arch eq 'X'.
    perform archive_read_ztco_shop_sum.
  endif.
*- U1 End

*  describe table it_shop_sum lines sy-index.
*  check sy-index > 0.

  select  *  into corresponding fields of table it_shop_cc
      from ztco_shop_cc as a
** Changed on 10/02/13
*      INNER JOIN ckmlmv013 AS b
       inner join zckmlmv013 as b
** En don 10/02/13
         on a~aufnr = b~aufnr
    where kokrs       =  p_kokrs
      and bdatj       =  p_bdatj
      and poper       in s_poper
      and typps       in s_typps
      and kstar       in s_kstar
      and resou       in s_resou
      and elemt       in s_elemt
      and artnr       in s_artnr
      and verid       in s_verid.

*- U1 Start
  if p_arch eq 'X'.
    perform archive_read_ztco_shop_cc.
    if not gt_ztco_shop_cc_a[] is initial.
      perform archive_read_ckmlmv013.
    endif.
  endif.
*- U1 End

endform.                    " GET_SHOP_COST
*&---------------------------------------------------------------------*
*&      Form  MAKE_DATA
*&---------------------------------------------------------------------*
form make_data .

  sort it_marc by matnr werks.

* by ig.moon 8/7/2009 {
*  sort it_shop_sum by kokrs bdatj poper aufnr resou kstar.
  sort it_shop_sum by kokrs bdatj poper typps aufnr resou kstar.
* }

  sort it_s013 by matnr.
  sort it_lfa1 by lifnr.
  sort it_shop_cc.
  sort it_ckmlmv003 by aufnr.

  loop at it_shop_cc.
    clear it_display.
    move-corresponding it_shop_cc to it_display.
    clear it_display-poper.

    if it_shop_cc-typps ca 'MEV'.
      perform fill_shop_sum_info.
      if sy-subrc <> 0. continue. endif.
    else.
      perform fill_basic_info.
    endif.

*   Version SUM
    if p_vsum = 'X'.
      clear: it_display-verid, it_display-aufnr.
    endif.

    collect it_display.
  endloop.


  data: l_idx type i.

  sort it_ckmlmv003 by matnr verid_nd.
  loop at it_display.
    l_idx = sy-tabix.

    perform get_pp_grqty changing it_display-pp_grqty.
    check it_display-pp_grqty > 0.

    if p_unit = 'X'.
      perform calculate_unit.
    endif.

    modify it_display index l_idx.
  endloop.

* by ig.moon 4/21/2010 {
  perform filter_it_display.
* }

  sort it_display by artnr.

*  IF p_unit = 'X'.
*    PERFORM recalculate_per_unit.
*  ENDIF.
endform.                    " MAKE_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
form display_data .

*-- ALV layout
  perform alv_set_layout   using  space  space
                                  space  space.

*-- Event
  perform alv_get_event    using  gt_events.

*-- Fieldcategory
  perform alv_get_fieldcat tables gt_fieldcat using 'DISPLAY'.
  perform alv_chg_fieldcat tables gt_fieldcat.

*-- Sort
  perform set_sort         tables gt_alv_sort.

*-- Top of page
*  PERFORM SET_TOP_PAGE.

*-- Display
  perform alv_grid_display tables it_display.


endform.                    " DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Form  ALV_CHG_FIELDCAT
*&---------------------------------------------------------------------*
form alv_chg_fieldcat tables pt_fieldcat type slis_t_fieldcat_alv.

  perform alv_chg_fieldcat_1 tables pt_fieldcat.

endform.                    " ALV_CHG_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  ALV_CHG_FIELDCAT_1
*&---------------------------------------------------------------------*
form alv_chg_fieldcat_1 tables pt_fieldcat type slis_t_fieldcat_alv.

  read table it_display index 1.

  loop at pt_fieldcat into gs_fieldcat.
    clear :  gs_fieldcat-key, gs_fieldcat-no_out.

    if gs_fieldcat-col_pos < 8.
      gs_fieldcat-key     = 'X'.
    endif.

    if gs_fieldcat-cfieldname = 'WAERS'.
      gs_fieldcat-do_sum = 'X'.
    endif.

    if gs_fieldcat-datatype = 'CURR'.
      gs_fieldcat-datatype = 'DEC'.
      gs_fieldcat-round    = p_trunc.

      if not p_decl is initial.
        gs_fieldcat-decimals_out = p_decl.
      endif.
    endif.

    case gs_fieldcat-fieldname.
      when 'RESOU'.  " Resource
        set_fieldcat gs_fieldcat text-t07 .
      when 'VERPR'.  " moving avg
        set_fieldcat gs_fieldcat text-t38 .
      when 'WKGBTR'.  " Current (Overall)
        set_fieldcat gs_fieldcat text-t23 .
      when 'WKGBTR2'.  " Current var. (Overall)
        set_fieldcat gs_fieldcat text-t24 .
      when 'ADD_WKGBTR'.  " Current  Additive (Overall)
        set_fieldcat gs_fieldcat text-t25 .
      when 'WIP_AMT'.  " WIP - begining (Overall)
        set_fieldcat gs_fieldcat text-t27 .
      when 'WIP_PAMT'." WIP - ending (Overall)
        set_fieldcat gs_fieldcat text-t28 .
      when 'SCRAP_AMT'.  " Scrap (Overall)
        set_fieldcat gs_fieldcat text-t29 .
      when 'MANU_AMT'.  " Manufacturing (Overall)
        set_fieldcat gs_fieldcat text-t30 .
      when 'GR_AMT'.  " GR (Overall)
        set_fieldcat gs_fieldcat text-t31.
      when 'SINGLE_AMT'.  " Material ledger - single (Overall)
        set_fieldcat gs_fieldcat text-t32.
      when 'MULTI_AMT'.  " Material ledger - multi (Overall)
        set_fieldcat gs_fieldcat text-t33.
      when 'MULTI_SAMT'.  " Material ledger - multi-single (Overall)
        set_fieldcat gs_fieldcat text-t34.
      when 'MULTI_MAMT'.  " Material ledger - multi-multi (Overall)
        set_fieldcat gs_fieldcat text-t35.
      when 'MISC'.  " Mics. Cost (Overall)
        set_fieldcat gs_fieldcat text-t36.

* Fixed
      when 'WKGBTR_F'.  " Current (Fixed)
        set_fieldcat gs_fieldcat text-t39 .
      when 'WKGBTR2_F'.  " Current var. (Fixed)
        set_fieldcat gs_fieldcat text-t40.
      when 'ADD_WKGBTR_F'.  " Current  Additive (Fixed)
        set_fieldcat gs_fieldcat text-t41.
      when 'WIP_AMT_F'.  " WIP - begining (Fixed)
        set_fieldcat gs_fieldcat text-t43.
      when 'WIP_PAMT_F'." WIP - ending (Fixed)
        set_fieldcat gs_fieldcat text-t44.
      when 'SCRAP_AMT_F'.  " Scrap (Fixed)
        set_fieldcat gs_fieldcat text-t45 .
      when 'MANU_AMT_F'.  " Manufacturing (Fixed)
        set_fieldcat gs_fieldcat text-t46 .
      when 'GR_AMT_F'.  " GR (Fixed)
        set_fieldcat gs_fieldcat text-t47 .
      when 'SINGLE_AMT_F'.  " Material ledger - single (Fixed)
        set_fieldcat gs_fieldcat text-t48 .
      when 'MULTI_AMT_F'.  " Material ledger - multi (Fixed)
        set_fieldcat gs_fieldcat text-t49 .
      when 'MULTI_SAMT_F'.  " Material ledger - multi-single (Fixed)
        set_fieldcat gs_fieldcat text-t50 .
      when 'MULTI_MAMT_F'.  " Material ledger - multi-multi (Fixed)
        set_fieldcat gs_fieldcat text-t51 .
      when 'MISC_F'.  " Mics. Cost (Fixed)
        set_fieldcat gs_fieldcat text-t52 .
      when 'MANU_QTY'.  " Manu_Qty
        set_fieldcat gs_fieldcat text-t53 .
      when 'GR_QTY'.    " Comp STD Qty
        set_fieldcat gs_fieldcat text-t54 .
      when 'SINGLE_QTY'. " Single-level diff.
        set_fieldcat gs_fieldcat text-t55.
      when 'PP_GRQTY'.    " GR Qty
        set_fieldcat gs_fieldcat text-t56 .
    endcase.

    clear: gs_fieldcat-cfieldname,
           gs_fieldcat-ctabname.
    modify pt_fieldcat from gs_fieldcat.
  endloop.

endform.                    "alv_chg_fieldcat_1
*&--------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&--------------------------------------------------------------------*
form pf_status_set using it_extab type slis_t_extab .

  set pf-status 'STANDARD'.  "  EXCLUDING IT_EXTAB.

endform.                    "PF_STATUS_SET
*---------------------------------------------------------------------*
*       FORM ALV_user_command
*---------------------------------------------------------------------*
form user_command using p_ucomm     like sy-ucomm
                        ps_selfield type slis_selfield.


endform.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  SET_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_ALV_SORT  text
*----------------------------------------------------------------------*
form set_sort tables  pt_alv_sort structure gs_alv_sort.

*
*  clear : gs_alv_sort,  gt_alv_sort[].
*
*  case 'X'.
*    when p_but1.
*      gs_alv_sort-spos      = '1'.
*      gs_alv_sort-fieldname = 'LIFNR'.
*      gs_alv_sort-tabname   = 'IT_DISPLAY'.
*      gs_alv_sort-up        = 'X'.
*      gs_alv_sort-subtot    = 'X'.
*      append gs_alv_sort  to gt_alv_sort.
*
*    when p_but2.
*      gs_alv_sort-spos      = '1'.
*      gs_alv_sort-fieldname = 'SAKTO'.
*      gs_alv_sort-tabname   = 'IT_DISPLAY'.
*      gs_alv_sort-up        = 'X'.
*      gs_alv_sort-subtot    = 'X'.
*      append gs_alv_sort  to gt_alv_sort.
*
*    when p_but3.
*      gs_alv_sort-spos      = '1'.
*      gs_alv_sort-fieldname = 'BELNR'.
*      gs_alv_sort-tabname   = 'IT_DISPLAY'.
*      gs_alv_sort-up        = 'X'.
*      gs_alv_sort-subtot    = 'X'.
*      append gs_alv_sort  to gt_alv_sort.
*  endcase.
endform.                    " SET_SORT
*&---------------------------------------------------------------------*
*&      Form  SET_TOP_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form set_top_page.
  clear : gs_line.
  gs_line-typ  = 'H'.
  gs_line-info = text-h01.
  append gs_line to gt_list_top_of_page .

*  CLEAR : gs_line.
*  APPEND INITIAL LINE TO gt_list_top_of_page .

*  append_top :
*      'S' text-h02 s_kokrs-low s_kokrs-high,
*      'S' text-h03 p_bdatj-low p_bdatj-high,
*      'S' text-h04 s_poper-low s_poper-high,
*      'S' text-h13 s_shop-low  s_shop-high,
*      'S' text-h05 s_aufnr-low s_aufnr-high,
*      'S' text-h06 s_artnr-low s_artnr-high,
*      'S' text-h07 s_matnr-low s_matnr-high,
*      'S' text-h08 s_typps-low s_typps-high,
*      'S' text-h09 s_kstar-low s_kstar-high,
*      'S' text-h10 s_elemt-low s_elemt-high,
*      'S' text-h11 s_kostl-low s_kostl-high,
*      'S' text-h12 s_lstar-low s_lstar-high.

endform.                    " SET_TOP_PAGE
*&---------------------------------------------------------------------*
*&      Form  get_product_gr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_product_gr.
  data : begin of it_proc_gr occurs 0,
          par_werks like it_shop_sum-bwkey,
          artnr     like it_shop_sum-artnr,
          aufnr     like it_shop_sum-aufnr,
          verid     like it_shop_sum-verid,
          bdatj     like it_shop_sum-bdatj,
          poper     like it_shop_sum-poper,
        end of it_proc_gr.

  data : it_ckmlmv003_temp like it_ckmlmv003 occurs 0 with header line.


  loop at it_shop_sum.
    move-corresponding it_shop_sum to it_proc_gr.
    append it_proc_gr. clear it_proc_gr.
  endloop.
  sort it_proc_gr.
  delete adjacent duplicates from it_proc_gr.

* read GR data
  select  a~bwkey a~matnr a~verid_nd
          c~aufnr
          b~out_menge b~meinh
    into corresponding fields of table it_ckmlmv003_temp
    from ckmlmv001 as a
    inner join ckmlmv003 as b
       on a~kalnr    =  b~kalnr_bal
** On 10/02/13 for Archiving bug fix
**    INNER JOIN ckmlmv013 AS c
    inner join zckmlmv013 as c
** end on 10/02/13
       on c~kalnr_proc = b~kalnr_in
     for all entries in it_proc_gr
   where a~bwkey    =  it_proc_gr-par_werks
     and a~matnr    =  it_proc_gr-artnr
     and a~verid_nd =  it_proc_gr-verid
     and a~btyp     =  'BF'
     and b~gjahr    =  p_bdatj
     and b~perio    in s_poper
**     and c~flg_wbwg = 'X'.   "goods movement
***    and c~loekz    = space. "Not deleted.
     and c~flg_wbwg = 'X'
     and c~autyp = '05'.

**- U1 Start
*  IF p_arch EQ 'X'.
*    CLEAR: gt_proc_gr_a, gt_proc_gr_a[].
*    gt_proc_gr_a[] = it_proc_gr[].
*    PERFORM archive_read_ckmlmv013_2 TABLES it_ckmlmv003_temp.
*  ENDIF.
**- U1 End

*** 11/19/2013 - T00306 Start
  delete it_ckmlmv003_temp where meinh is initial.
*** 11/19/2013 - T00306 End

  loop at it_ckmlmv003_temp.
    move-corresponding it_ckmlmv003_temp to it_ckmlmv003.

    if p_vsum = 'X'.
      clear: it_ckmlmv003-verid_nd,
             it_ckmlmv003-aufnr.
    endif.

    collect it_ckmlmv003. clear it_ckmlmv003.
  endloop.

*** 11/19/2013 - T00306 Start
  delete it_ckmlmv003 where out_menge eq 0.
*** 11/19/2013 - T00306 End

endform.                    " get_product_gr
*&---------------------------------------------------------------------*
*&      Form  recalculate_per_unit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*form recalculate_per_unit.
*  data : l_pp_grqty like  it_ckmlmv003-out_menge.
*
*  loop at it_display.
*    clear it_ckmlmv003.
*
*    if p_vsum = 'X'.
*      read table it_ckmlmv003 with key bwkey    = it_display-par_werks
*                                       matnr    = it_display-artnr.
*    else.
*      read table it_ckmlmv003 with key bwkey    = it_display-par_werks
*                                       matnr    = it_display-artnr
*                                       verid_nd = it_display-verid.
*    endif.
*
*    clear : l_pp_grqty.
*    l_pp_grqty =  it_ckmlmv003-out_menge.
*
*    if l_pp_grqty <>  0 .
*      it_display-wkgbtr     = it_display-wkgbtr      / l_pp_grqty.
*      it_display-wkgbtr2    = it_display-wkgbtr2     / l_pp_grqty.
*      it_display-wkgbtr     = it_display-wkgbtr      / l_pp_grqty.
*      it_display-wkgbtr2    = it_display-wkgbtr2     / l_pp_grqty.
*      it_display-wip_amt    = it_display-wip_amt     / l_pp_grqty.
*      it_display-wip_pamt   = it_display-wip_pamt    / l_pp_grqty.
*      it_display-scrap_amt  = it_display-scrap_amt   / l_pp_grqty.
*      it_display-manu_amt   = it_display-manu_amt    / l_pp_grqty.
*      it_display-gr_amt     = it_display-gr_amt      / l_pp_grqty.
*      it_display-single_amt = it_display-single_amt  / l_pp_grqty.
*      it_display-multi_amt  = it_display-multi_amt   / l_pp_grqty.
*      it_display-multi_samt = it_display-multi_samt  / l_pp_grqty.
*      it_display-multi_mamt = it_display-multi_mamt  / l_pp_grqty.
*      it_display-misc       = it_display-misc        / l_pp_grqty.
*
*
*
*      it_display-wkgbtr_f     = it_display-wkgbtr_f      / l_pp_grqty.
*      it_display-wkgbtr2_f    = it_display-wkgbtr2_f     / l_pp_grqty.
*      it_display-wkgbtr_f     = it_display-wkgbtr_f      / l_pp_grqty.
*      it_display-wkgbtr2_f    = it_display-wkgbtr2_f     / l_pp_grqty.
*      it_display-wip_amt_f    = it_display-wip_amt_f     / l_pp_grqty.
*      it_display-wip_pamt_f   = it_display-wip_pamt_f    / l_pp_grqty.
*      it_display-scrap_amt_f  = it_display-scrap_amt_f   / l_pp_grqty.
*      it_display-manu_amt_f   = it_display-manu_amt_f    / l_pp_grqty.
*      it_display-gr_amt_f     = it_display-gr_amt_f      / l_pp_grqty.
*      it_display-single_amt_f = it_display-single_amt_f / l_pp_grqty.
*      it_display-multi_amt_f  = it_display-multi_amt_f   / l_pp_grqty.
*      it_display-multi_samt_f = it_display-multi_samt_f / l_pp_grqty.
*      it_display-multi_mamt_f = it_display-multi_mamt_f / l_pp_grqty.
*      it_display-misc_f       = it_display-misc_f        / l_pp_grqty.
*
*      it_display-pp_grqty       = l_pp_grqty.
*      modify it_display. clear it_display.
*    endif.
*  endloop.
*endform.                    " recalculate_per_unit
*&---------------------------------------------------------------------*
*&      Form  get_lifnr_for_part
*&---------------------------------------------------------------------*
*       take too long db selection
*&---------------------------------------------------------------------*
form get_lifnr_for_part.
  data : l_lifnr like ekko-lifnr.
  data : l_fdate type datum,
         l_last_date like ekbe-budat.

  data : l_ok(1),
         l_cnt type i.
  ranges : r_ven_matnr for s013-matnr.
  ranges : r_ven_matnr2 for s013-matnr.
  data : l_spmon like s013-spmon.

  data : begin of it_ekbe occurs 0,
         matnr like ekbe-matnr,
         lifnr like ekko-lifnr,
         budat like ekbe-budat,
         end of it_ekbe.


  loop at it_marc where mtart cs 'ROH' .
    check it_marc-matnr <> 'R16N'.
    r_ven_matnr-sign   = 'I'.
    r_ven_matnr-option = 'EQ'.
    r_ven_matnr-low    = it_marc-matnr.
    collect r_ven_matnr. clear r_ven_matnr.
  endloop.
  read table s_poper.
*  CONCATENATE  s_poper-low+1(2) '/' p_bdatj INTO l_spmon.
  concatenate  p_bdatj s_poper-low+1(2)  p_bdatj into l_spmon.

* For getting VENDOR
* step 1) select s013 (LIS Table)
* step 2) select ekbe (PO history)

  select distinct lifnr matnr
    into table it_s013
    from s013
    for all entries in it_marc
   where spmon <= l_spmon
     and matnr = it_marc-matnr
*    AND matnr IN r_ven_matnr
   group by lifnr matnr.
*  order by spmon descending.

* Delete r_ven_matnr's matnr if it getted vendor from s013
  sort it_s013 by matnr.

*MULTIPLE VENDOR... SELECT FIRST ONE!!! FIXME LATER
  loop at r_ven_matnr.
    clear it_s013.
    loop at it_s013 where matnr = r_ven_matnr-low.
      l_ok = 'X'.
      l_cnt = l_cnt + 1.
      if l_cnt > 1.
        clear l_ok.
        exit.
      endif.
    endloop.

    if l_ok = ''.
      r_ven_matnr2 = r_ven_matnr.
      append r_ven_matnr2.
      delete it_s013 where matnr = r_ven_matnr-low.
    endif.
    clear : l_ok, l_cnt.
  endloop.

  sort r_ven_matnr2 by low.
  delete adjacent duplicates from r_ven_matnr2.

  check not r_ven_matnr2[] is initial.

*  Get vendor from ekbe
  read table s_poper index 1.
  if s_poper-high = ''.
    s_poper-high = s_poper-low.
  endif.

  concatenate p_bdatj s_poper-high+1(2) '01' into l_fdate.
  call function 'LAST_DAY_OF_MONTHS'
    exporting
      day_in            = l_fdate
    importing
      last_day_of_month = l_last_date
    exceptions
      day_in_no_date    = 1
      others            = 2.

*FIXME
  ranges: r_werks for ekbe-werks.
  r_werks-option = 'EQ'.
  r_werks-sign   = 'I'.
  r_werks-low = 'E001'. append r_werks.
  r_werks-low = 'P001'. append r_werks.

  select distinct a~matnr b~lifnr max( a~budat )
  appending  corresponding fields of table it_ekbe
    from ekbe as a
   inner join ekko as b
      on a~ebeln = b~ebeln
   where a~werks    in r_werks
     and a~budat    <= l_last_date
     and a~bwart    = '101'
     and a~matnr    in r_ven_matnr2
     and a~bewtp    =  'E'
    group by a~matnr b~lifnr.
*  SELECT DISTINCT a~matnr b~lifnr MAX( a~budat )
*  APPENDING  CORRESPONDING FIELDS OF TABLE it_ekbe
*    FROM ekbe AS a
*   INNER JOIN ekko AS b
*      ON a~ebeln = b~ebeln
*   for all entries in r_ven_matnr2
*   WHERE a~werks    in r_werks
*     AND a~budat    <= l_last_date
*     AND a~bwart    = '101'
*     and a~matnr    = r_ven_matnr2-low
*     AND a~bewtp    =  'E'
*    GROUP by a~matnr b~lifnr.

*- U1 Start
  if p_arch eq 'X'.
    perform archive_read_ekbe_ekko tables it_ekbe r_werks r_ven_matnr2
                                    using l_last_date.
  endif.
*- U1 End

  loop at it_ekbe.
    move-corresponding it_ekbe to it_s013.
    collect it_s013. clear it_s013.
  endloop.


endform.                    " get_lifnr_for_part
*&---------------------------------------------------------------------*
*&      Form  convert_to_material_group
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_DISPLAY_LLV_MATNR  text
*      <--P_IT_DISPLAY_RESOU  text
*----------------------------------------------------------------------*
form convert_to_material_group changing p_llv_matnr
                                    p_resou
                                    p_subrc.

  clear it_marc.
  read table it_marc with key matnr = it_display-llv_matnr
                              werks = it_display-bwkey
                              binary search.

  if sy-subrc = 0 .
    if p_shop = 'X'.

      call function 'Z_CO_SHOP_DETERMINE'
        exporting
          f_typps = 'M'
          f_prctr = it_marc-prctr
          f_fevor = it_marc-fevor
          f_werks = it_marc-werks
          f_raube = it_marc-raube
        importing
          e_shop  = it_display-shop.

*      if it_shop_sum-par_werks = 'E001'.
*        it_display-shop = 'MXEX'.
*
*      else.
*        case it_marc-fevor.
*          when 'SPB' or 'SPD' or 'SPP'.
*            it_display-shop = 'MXSX'.
*          when 'SEA' or 'SEC'.
*            it_display-shop = 'MXEX'.
*
*          when others.
*            case it_marc-raube.
*              when 10.
*                it_display-shop = 'MXSX'.
*              when 11.
*                it_display-shop = 'MXBX'.
*              when 12.
*                it_display-shop = 'MXPX'.
*              when 13.
*                it_display-shop = 'MXTX'.
*              when 14.
*                it_display-shop = 'MXEX'.
*              when others.
*                it_display-shop = space. "'MXTX'.
*            endcase.
*        endcase.
*      endif.


    endif.

*   replace materia => material group and SUM by material group
*   replace resouce => Proposed Supply Area and SUM by Supply area
    p_llv_matnr = it_marc-matkl.
    p_resou     = it_marc-vspvb.
    p_subrc = 0.

  else.
    p_subrc = 4.
  endif.

endform.                    " convert_to_material_group
*&---------------------------------------------------------------------*
*&      Form  get_material_group
*&---------------------------------------------------------------------*
form get_material_group.

  check not it_mara[] is initial.
  select a~matnr b~werks
         a~raube b~fevor
         a~mtart a~matkl b~vspvb b~prctr c~maktg
    into table it_marc
    from mara as a
    inner join marc as b
       on a~matnr = b~matnr
    inner join makt as c
       on c~matnr = a~matnr
      and c~spras = sy-langu
    for all entries  in it_mara
   where b~matnr    = it_mara-matnr
     and b~werks    = it_mara-werks.

*-get MIP information
  data: begin of lt_marc occurs 0,
          matnr like marc-matnr,
          fevor like marc-fevor,
        end of lt_marc.
  select matnr fevor into table lt_marc
     from marc
     for all entries in it_marc
     where matnr = it_marc-matnr
       and fevor <> space.
  sort lt_marc by matnr.

  data: l_idx like sy-tabix.
  loop at it_marc.
    l_idx = sy-tabix.

    read table lt_marc with key matnr = it_marc-matnr.
    if sy-subrc = 0.
      it_marc-fevor = lt_marc-fevor.  "production scheduler
    else.
      clear it_marc-fevor.
    endif.

    modify it_marc index l_idx transporting fevor.
  endloop.

endform.                    " get_material_group
*&---------------------------------------------------------------------*
*&      Form  define_mara
*&---------------------------------------------------------------------*
form define_mara.

  loop at it_shop_sum.
    check it_shop_sum-llv_matnr <> space.

    it_mara-werks = it_shop_sum-bwkey.
    it_mara-matnr = it_shop_sum-llv_matnr.
    append it_mara. clear it_mara.
  endloop.

  sort it_mara.
  delete adjacent duplicates from it_mara.

endform.                    " define_mara
*&---------------------------------------------------------------------*
*&      Form  get_lifnr_name
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_lifnr_name.

  select lifnr name1
    into corresponding fields of table it_lfa1
    from lfa1
     for all entries  in it_s013
   where lifnr = it_s013-lifnr .


endform.                    " get_lifnr_name
*&---------------------------------------------------------------------*
*&      Form  calculate_unit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form calculate_unit.
*  data : l_pp_grqty like  it_display-pp_grqty.         "5 digit
  data : l_pp_grqty type i.


*  CLEAR IT_CKMLMV003.
*  if p_vsum = 'X'.
*    read table it_ckmlmv003 with key bwkey    = it_display-par_werks
*                                     matnr    = it_display-artnr.
*  else.
*    read table it_ckmlmv003 with key bwkey    = it_display-par_werks
*                                     matnr    = it_display-artnr
*                                     verid_nd = it_display-verid.
*  endif.
*  clear : l_pp_grqty.

  l_pp_grqty =  it_display-pp_grqty / 1000.

*FIXME
  if l_pp_grqty = 0.
    l_pp_grqty = 1.
    break-point.
  endif.

*decimal 4 amount, decimal 5 qty
  if l_pp_grqty <>  0 .
    it_display-wkgbtr     = it_display-wkgbtr      / l_pp_grqty.
    it_display-wkgbtr2    = it_display-wkgbtr2     / l_pp_grqty.
    it_display-add_wkgbtr = it_display-add_wkgbtr  / l_pp_grqty.
    it_display-wip_amt    = it_display-wip_amt     / l_pp_grqty.
    it_display-wip_pamt   = it_display-wip_pamt    / l_pp_grqty.
    it_display-scrap_amt  = it_display-scrap_amt   / l_pp_grqty.
    it_display-manu_amt   = it_display-manu_amt    / l_pp_grqty.
    it_display-gr_amt     = it_display-gr_amt      / l_pp_grqty.
    it_display-single_amt = it_display-single_amt  / l_pp_grqty.
    it_display-multi_amt  = it_display-multi_amt   / l_pp_grqty.
    it_display-multi_samt = it_display-multi_samt  / l_pp_grqty.
    it_display-multi_mamt = it_display-multi_mamt  / l_pp_grqty.
    it_display-misc       = it_display-misc        / l_pp_grqty.


    it_display-wkgbtr_f     = it_display-wkgbtr_f      / l_pp_grqty.
    it_display-wkgbtr2_f    = it_display-wkgbtr2_f     / l_pp_grqty.
    it_display-add_wkgbtr_f = it_display-add_wkgbtr_f  / l_pp_grqty.
    it_display-wip_amt_f    = it_display-wip_amt_f     / l_pp_grqty.
    it_display-wip_pamt_f   = it_display-wip_pamt_f    / l_pp_grqty.
    it_display-scrap_amt_f  = it_display-scrap_amt_f   / l_pp_grqty.
    it_display-manu_amt_f   = it_display-manu_amt_f    / l_pp_grqty.
    it_display-gr_amt_f     = it_display-gr_amt_f      / l_pp_grqty.
    it_display-single_amt_f = it_display-single_amt_f / l_pp_grqty.
    it_display-multi_amt_f  = it_display-multi_amt_f   / l_pp_grqty.
    it_display-multi_samt_f = it_display-multi_samt_f / l_pp_grqty.
    it_display-multi_mamt_f = it_display-multi_mamt_f / l_pp_grqty.
    it_display-misc_f       = it_display-misc_f        / l_pp_grqty.

    it_display-manu_qty     = it_display-manu_qty      / l_pp_grqty.
    it_display-gr_qty       = it_display-gr_qty        / l_pp_grqty.
    it_display-single_qty   = it_display-single_qty    / l_pp_grqty.

  endif.

endform.                    " calculate_unit
*&---------------------------------------------------------------------*
*&      Form  pp_grqty
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_pp_grqty changing p_pp_grqty type ckml_outmenge.
  clear it_ckmlmv003.
  if p_vsum = 'X'.
    read table it_ckmlmv003 with key matnr    = it_display-artnr.
  else.
    read table it_ckmlmv003 with key matnr    = it_display-artnr
                                     verid_nd = it_display-verid.
  endif.

  check it_ckmlmv003-out_menge > 0.
  clear : p_pp_grqty.
*  p_pp_grqty = it_ckmlmv003-out_menge .
*
*  p_pp_grqty = it_ckmlmv003-out_menge * 100.
*
  call function 'UNIT_CONVERSION_SIMPLE'
    exporting
      input                = it_ckmlmv003-out_menge
      unit_in              = it_ckmlmv003-meinh
      unit_out             = it_ckmlmv003-meinh
    importing
      output               = p_pp_grqty
    exceptions
      conversion_not_found = 1
      division_by_zero     = 2
      input_invalid        = 3
      output_invalid       = 4
      overflow             = 5
      type_invalid         = 6
      units_missing        = 7
      unit_in_not_found    = 8
      unit_out_not_found   = 9.

  if p_pp_grqty = 0.
    break-point.
  endif.
endform.                    " pp_grqty
*&---------------------------------------------------------------------*
*&      Form  determine_vendor
*&---------------------------------------------------------------------*
form determine_vendor.

  clear it_s013.
  read table it_s013 with key matnr = it_display-llv_matnr
                     binary search.
  if sy-subrc = 0.
    it_display-lifnr = it_s013-lifnr.
    clear it_lfa1.
    read table it_lfa1 with key lifnr = it_display-lifnr
                       binary search.
    it_display-name1 = it_lfa1-name1.
  endif.

endform.                    " determine_vendor
*&---------------------------------------------------------------------*
*&      Form  fill_shop_sum_info
*&---------------------------------------------------------------------*
form fill_shop_sum_info.
  data : l_llv_matnr like it_shop_sum-llv_matnr,
         l_resou     like it_shop_cc-resou,
         l_subrc     like sy-subrc.

  clear it_shop_sum.
  read table it_shop_sum with key kokrs =  it_shop_cc-kokrs
                                  bdatj =  it_shop_cc-bdatj
                                  poper =  it_shop_cc-poper
* by ig.moon 8/9.2009 {
                                  typps =  it_shop_cc-typps
* }
                                  aufnr =  it_shop_cc-aufnr
                                  resou =  it_shop_cc-resou
                                  kstar =  it_shop_cc-kstar
                              binary search.
  if sy-subrc = 0.
    it_display-par_werks  = it_shop_sum-par_werks.
    it_display-aufnr      = it_shop_sum-aufnr.
    it_display-verid      = it_shop_sum-verid.

    it_display-shop       = it_shop_sum-shop.
    it_display-bwkey      = it_shop_sum-bwkey.
    it_display-llv_matnr  = it_shop_sum-llv_matnr.
    it_display-kostl      = it_shop_sum-kostl.
    it_display-lstar      = it_shop_sum-lstar.
    it_display-meeht      = it_shop_sum-meeht.
*    it_display-PEINH      = it_shop_sum-peinh.
*    it_display-STPRS      = it_shop_sum-STPRS.
*    it_display-VERPR      = it_shop_sum-VERPR.

    it_display-gr_qty     = it_shop_sum-gr_qty.
    it_display-single_qty = it_shop_sum-single_qty.
    it_display-manu_qty   = it_shop_sum-manu_qty.

    if it_display-llv_matnr <> space.
*   display vendor of parts
      if p_lifnr = 'X'.
        perform determine_vendor.
      endif.

      clear : l_llv_matnr, l_resou, l_subrc.
      perform convert_to_material_group changing l_llv_matnr
                                                 l_resou
                                                 l_subrc .

      if p_matgrp = 'X' and l_subrc = 0.
        it_display-llv_matnr = l_llv_matnr.
        it_display-resou     = l_resou.
        clear: it_display-peinh, it_display-stprs, it_display-verpr.
      else.
        it_display-maktg = it_marc-maktg.
      endif.

    elseif it_shop_cc-typps = 'E'.

    endif.
  endif.

endform.                    " fill_shop_sum_info
*&---------------------------------------------------------------------*
*&      Form  get_lifnr_for_part_new
*&---------------------------------------------------------------------*
form get_lifnr_for_part_new.

  data: w_datum_f   like   sy-datum,
        w_datum_t   like   sy-datum.
  constants: c_ekorg like ekko-ekorg  value 'PU01'.

  call function 'LAST_DAY_IN_PERIOD_GET'
    exporting
      i_periv        = tka01-lmona
      i_gjahr        = p_bdatj
      i_poper        = s_poper-low
    importing
      e_date         = w_datum_t
    exceptions
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      others         = 4.

  select lifnr matnr
    into corresponding fields of table it_s013
    from a018 as a
     for all entries in it_marc
   where kappl =  'M'
     and kschl =  'PB00'     "ZTIR = PB00
     and lifnr in s_lifnr
     and matnr = it_marc-matnr
     and ekorg =  c_ekorg
     and esokz =  '0'
     and datbi >= w_datum_t
     and datab <= w_datum_t.

endform.                    " get_lifnr_for_part_new
*&---------------------------------------------------------------------*
*&      Form  read_tka01
*&---------------------------------------------------------------------*
form read_tka01.

  clear tka01.
  select single * from tka01
                 where kokrs = p_kokrs.
  if sy-subrc <> 0.
    message e038 with p_kokrs.
  endif.

endform.                    " read_tka01
*&---------------------------------------------------------------------*
*&      Form  fill_basic_info
*&---------------------------------------------------------------------*
form fill_basic_info.
  clear it_ckmlmv003.
  read table it_ckmlmv003 with key aufnr = it_display-aufnr
             binary search.

  it_display-par_werks  = it_ckmlmv003-bwkey.
  it_display-aufnr      = it_ckmlmv003-aufnr.
  it_display-verid      = it_ckmlmv003-verid_nd.

endform.                    " fill_basic_info
*&---------------------------------------------------------------------*
*&      Form  filter_it_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form filter_it_display.

  data $it_display like it_display occurs 0 with header line.
  data $ix type i.

  $it_display[] = it_display[].

  sort $it_display by artnr shop resou ascending
                     manu_amt descending.

  delete adjacent duplicates from $it_display
    comparing artnr shop resou .

  sort $it_display by artnr shop resou elemt.

  loop at it_display.
    $ix = sy-tabix.
    read table $it_display with key   artnr = it_display-artnr
                                      shop = it_display-shop
                                      resou =  it_display-resou
                                      elemt  =  it_display-elemt
                                      binary search.

    if sy-subrc eq 0.
    else.
      it_display-manu_qty = 0.
      modify it_display index $ix transporting manu_qty.
    endif.
  endloop.
endform.                    " filter_it_display
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_READ_ZTCO_SHOP_SUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form archive_read_ztco_shop_sum.

  types: begin of ty_ztco_shop_sum,
         kokrs type kokrs,
         bdatj type bdatj,
         poper type poper,
         typps type typps,
         kstar type kstar,
         resou type char25,
         aufnr type aufnr,
         fevor type fevor,
           archivekey type arkey,
           archiveofs type admi_offst.
  types: end of ty_ztco_shop_sum.

  data: l_handle    type sytabix,
        lt_ztco_shop_sum type table of ztco_shop_sum with header line,
        l_archindex like aind_str2-archindex,
        l_gentab    like aind_str2-gentab.

  data: lt_inx_ztco_shop_sum type table of ty_ztco_shop_sum,
        ls_inx_ztco_shop_sum type ty_ztco_shop_sum.

* 1. Input the archive infostructure name
  clear l_archindex.
  l_archindex = 'ZTCOSHOPSUM_001'.

* 2. Get the structure table using infostructure
  clear l_gentab.
  select single gentab into l_gentab from aind_str2
   where archindex = l_archindex.

  check sy-subrc = 0 and not l_gentab is initial.

* 3. Get the archived data from structure table
  clear lt_inx_ztco_shop_sum[].
  select * into corresponding fields of table lt_inx_ztco_shop_sum
    from (l_gentab)
   where kokrs     =  p_kokrs
     and bdatj     =  p_bdatj
     and poper     in s_poper
     and typps     in s_typps
     and kstar     in s_kstar
     and resou     in s_resou.

  check not lt_inx_ztco_shop_sum[] is initial.

* 4. Get more archived data looping structure table
  clear: gt_ztco_shop_sum_a, gt_ztco_shop_sum_a[].
  loop at lt_inx_ztco_shop_sum into ls_inx_ztco_shop_sum.
*  4.1 Read information from archivekey & offset
    clear l_handle.
    call function 'ARCHIVE_READ_OBJECT'
      exporting
        object                    = 'ZTCOSHOPSU'
        archivkey                 = ls_inx_ztco_shop_sum-archivekey
        offset                    = ls_inx_ztco_shop_sum-archiveofs
      importing
        archive_handle            = l_handle
      exceptions
        no_record_found           = 1
        file_io_error             = 2
        internal_error            = 3
        open_error                = 4
        cancelled_by_user         = 5
        archivelink_error         = 6
        object_not_found          = 7
        filename_creation_failure = 8
        file_already_open         = 9
        not_authorized            = 10
        file_not_found            = 11
        error_message             = 12
        others                    = 13.

    check sy-subrc = 0.

*  4.2 Read table from information
    clear: lt_ztco_shop_sum, lt_ztco_shop_sum[].
    call function 'ARCHIVE_GET_TABLE'
      exporting
        archive_handle          = l_handle
        record_structure        = 'ZTCO_SHOP_SUM'
        all_records_of_object   = 'X'
      tables
        table                   = lt_ztco_shop_sum
      exceptions
        end_of_object           = 1
        internal_error          = 2
        wrong_access_to_archive = 3
        others                  = 4.

    check sy-subrc = 0 and not lt_ztco_shop_sum[] is initial.

    delete lt_ztco_shop_sum where not ( artnr     in s_artnr
                              and       verid     in s_verid
                              and       shop      in s_shop
                              and       fevor     in s_fevor
                              and       llv_matnr in s_matnr ).

* 5. Append archived data table to finally interal table
    insert lines of lt_ztco_shop_sum into table gt_ztco_shop_sum_a.
  endloop.

  sort gt_ztco_shop_sum_a.
  delete adjacent duplicates from gt_ztco_shop_sum_a comparing all
  fields.

  insert lines of gt_ztco_shop_sum_a into table it_shop_sum.

endform.                    " ARCHIVE_READ_ZTCO_SHOP_SUM
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_READ_ZTCO_SHOP_CC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form archive_read_ztco_shop_cc .

  types: begin of ty_ztco_shop_cc,
         kokrs type kokrs,
         bdatj type bdatj,
         poper type poper,
         typps type typps,
         kstar type kstar,
         resou type char25,
         elemt type ck_element,
         aufnr type aufnr,
         artnr type artnr,
           archivekey type arkey,
           archiveofs type admi_offst.
  types: end of ty_ztco_shop_cc.

  data: l_handle    type sytabix,
        lt_ztco_shop_cc type table of ztco_shop_cc with header line,
        l_archindex like aind_str2-archindex,
        l_gentab    like aind_str2-gentab.

  data: lt_inx_ztco_shop_cc type table of ty_ztco_shop_cc,
        ls_inx_ztco_shop_cc type ty_ztco_shop_cc.

* 1. Input the archive infostructure name
  clear l_archindex.
  l_archindex = 'ZTCOSHOPCC_001'.

* 2. Get the structure table using infostructure
  clear l_gentab.
  select single gentab into l_gentab from aind_str2
   where archindex = l_archindex.

  check sy-subrc = 0 and not l_gentab is initial.

* 3. Get the archived data from structure table
  clear lt_inx_ztco_shop_cc[].
  select * into corresponding fields of table lt_inx_ztco_shop_cc
    from (l_gentab)
  where kokrs =  p_kokrs
    and bdatj =  p_bdatj
    and poper in s_poper
    and typps in s_typps
    and kstar in s_kstar
    and resou in s_resou
    and elemt in s_elemt
    and artnr in s_artnr.

  check not lt_inx_ztco_shop_cc[] is initial.

** 3. Get the archived data from structure table
*  CLEAR lt_inx_ztco_shop_cc[].
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_inx_ztco_shop_cc
*    FROM (l_gentab).
**   WHERE aufnr IN s_aufnr.
*
*  CHECK NOT lt_inx_ztco_shop_cc[] IS INITIAL.

* 4. Get more archived data looping structure table
  clear: gt_ztco_shop_cc_a, gt_ztco_shop_cc_a[].
  loop at lt_inx_ztco_shop_cc into ls_inx_ztco_shop_cc.
*  4.1 Read information from archivekey & offset
    clear l_handle.
    call function 'ARCHIVE_READ_OBJECT'
      exporting
        object                    = 'ZTCOSHOPCC'
        archivkey                 = ls_inx_ztco_shop_cc-archivekey
        offset                    = ls_inx_ztco_shop_cc-archiveofs
      importing
        archive_handle            = l_handle
      exceptions
        no_record_found           = 1
        file_io_error             = 2
        internal_error            = 3
        open_error                = 4
        cancelled_by_user         = 5
        archivelink_error         = 6
        object_not_found          = 7
        filename_creation_failure = 8
        file_already_open         = 9
        not_authorized            = 10
        file_not_found            = 11
        error_message             = 12
        others                    = 13.

    check sy-subrc = 0.

*  4.2 Read table from information
    clear: lt_ztco_shop_cc, lt_ztco_shop_cc[].
    call function 'ARCHIVE_GET_TABLE'
      exporting
        archive_handle          = l_handle
        record_structure        = 'ZTCO_SHOP_CC'
        all_records_of_object   = 'X'
      tables
        table                   = lt_ztco_shop_cc
      exceptions
        end_of_object           = 1
        internal_error          = 2
        wrong_access_to_archive = 3
        others                  = 4.

    check sy-subrc = 0 and not lt_ztco_shop_cc[] is initial.

* 5. Append archived data table to finally interal table
    insert lines of lt_ztco_shop_cc into table gt_ztco_shop_cc_a.
  endloop.

  sort gt_ztco_shop_cc_a.
  delete adjacent duplicates from gt_ztco_shop_cc_a comparing all fields
  .

endform.                    " ARCHIVE_READ_ZTCO_SHOP_CC
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_READ_CKMLMV013
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form archive_read_ckmlmv013 .

*  TYPES: BEGIN OF ty_ckmlmv013,
*         aufnr TYPE aufnr,
*           archivekey TYPE arkey,
*           archiveofs TYPE admi_offst.
*  TYPES: END OF ty_ckmlmv013.
*
*  DATA: l_handle    TYPE sytabix,
*        lt_ckmlmv013 TYPE TABLE OF ckmlmv013 WITH HEADER LINE,
*        l_archindex LIKE aind_str2-archindex,
*        l_gentab    LIKE aind_str2-gentab.
*
*  DATA: lt_inx_ckmlmv013 TYPE TABLE OF ty_ckmlmv013,
*        ls_inx_ckmlmv013 TYPE ty_ckmlmv013.
*
  data: lt_ztco_shop_cc_a_tmp like gt_ztco_shop_cc_a occurs 0
                              with header line.

*  CONSTANTS: c_zckmlmv013_001(14) VALUE 'ZCKMLMV013_001'.
*
** 1. Input the archive infostructure name
*  CLEAR l_archindex.
*  l_archindex = c_zckmlmv013_001.
*
** 2. Get the structure table using infostructure
*  CLEAR l_gentab.
*  SELECT SINGLE gentab INTO l_gentab FROM aind_str2
*   WHERE archindex = l_archindex.
*
*  CHECK sy-subrc = 0 AND NOT l_gentab IS INITIAL.
*
  clear: lt_ztco_shop_cc_a_tmp, lt_ztco_shop_cc_a_tmp[].
  lt_ztco_shop_cc_a_tmp[] = gt_ztco_shop_cc_a[].
  sort lt_ztco_shop_cc_a_tmp by aufnr.
  delete adjacent duplicates from lt_ztco_shop_cc_a_tmp comparing aufnr.
*
** 3. Get the archived data from structure table
*  CLEAR lt_inx_ckmlmv013[].
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_inx_ckmlmv013
*    FROM (l_gentab)
*    FOR ALL ENTRIES IN lt_ztco_shop_cc_a_tmp
*   WHERE aufnr = lt_ztco_shop_cc_a_tmp-aufnr.
*
*  CHECK NOT lt_inx_ckmlmv013[] IS INITIAL.
*
** 4. Get more archived data looping structure table
*  CLEAR: gt_ckmlmv013_a, gt_ckmlmv013_a[].
*  LOOP AT lt_inx_ckmlmv013 INTO ls_inx_ckmlmv013.
**  4.1 Read information from archivekey & offset
*    CLEAR l_handle.
*    CALL FUNCTION 'ARCHIVE_READ_OBJECT'
*      EXPORTING
*        object                    = 'CO_ORDER'
*        archivkey                 = ls_inx_ckmlmv013-archivekey
*        offset                    = ls_inx_ckmlmv013-archiveofs
*      IMPORTING
*        archive_handle            = l_handle
*      EXCEPTIONS
*        no_record_found           = 1
*        file_io_error             = 2
*        internal_error            = 3
*        open_error                = 4
*        cancelled_by_user         = 5
*        archivelink_error         = 6
*        object_not_found          = 7
*        filename_creation_failure = 8
*        file_already_open         = 9
*        not_authorized            = 10
*        file_not_found            = 11
*        error_message             = 12
*        OTHERS                    = 13.
*
*    CHECK sy-subrc = 0.
*
**  4.2 Read table from information
*    CLEAR: lt_ckmlmv013, lt_ckmlmv013[].
*    CALL FUNCTION 'ARCHIVE_GET_TABLE'
*      EXPORTING
*        archive_handle          = l_handle
*        record_structure        = 'CKMLMV013'
*        all_records_of_object   = 'X'
*      TABLES
*        table                   = lt_ckmlmv013
*      EXCEPTIONS
*        end_of_object           = 1
*        internal_error          = 2
*        wrong_access_to_archive = 3
*        OTHERS                  = 4.
*
*    CHECK sy-subrc = 0 AND NOT lt_ckmlmv013[] IS INITIAL.
*
*    DELETE lt_ckmlmv013 WHERE verid NOT IN s_verid.
*
** 5. Append archived data table to finally interal table
*    INSERT LINES OF lt_ckmlmv013 INTO TABLE gt_ckmlmv013_a.
*  ENDLOOP.

  select * into corresponding fields of table gt_ckmlmv013_a
    from zckmlmv013
*    FROM ckmlmv013
    for all entries in lt_ztco_shop_cc_a_tmp
   where aufnr = lt_ztco_shop_cc_a_tmp-aufnr
   and   verid in s_verid.

  sort gt_ckmlmv013_a.
  delete adjacent duplicates from gt_ckmlmv013_a comparing all fields.

  loop at gt_ztco_shop_cc_a.
    clear it_shop_cc.
    move-corresponding gt_ztco_shop_cc_a to it_shop_cc.

    clear gt_ckmlmv013_a.
*    READ TABLE gt_ckmlmv013_a WITH KEY aufnr = gt_ckmlmv013_a-aufnr.
    read table gt_ckmlmv013_a with key aufnr = gt_ztco_shop_cc_a-aufnr.
    check sy-subrc = 0.

    it_shop_cc-verid = gt_ckmlmv013_a-verid.

    append it_shop_cc.  clear it_shop_cc.
  endloop.

endform.                    " ARCHIVE_READ_CKMLMV013
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_READ_CKMLMV013_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form archive_read_ckmlmv013_2 tables pt_ckmlmv003 structure it_ckmlmv003
.

  types: begin of ty_ckmlmv013,
         kalnr_proc type ckml_f_procnr,
         autyp      type auftyp,
         flg_wbwg   type ckml_flg_wbwg,
           archivekey type arkey,
           archiveofs type admi_offst.
  types: end of ty_ckmlmv013.

  data: l_handle    type sytabix,
        lt_ckmlmv013 type table of ckmlmv013 with header line,
        l_archindex like aind_str2-archindex,
        l_gentab    like aind_str2-gentab.

  data: lt_inx_ckmlmv013 type table of ty_ckmlmv013,
        ls_inx_ckmlmv013 type ty_ckmlmv013.

  data: begin of lt_ckmlmv003 occurs 0,
        bwkey      like ckmlmv001-bwkey,
        matnr      like ckmlmv001-matnr,
        aufnr      like ckmlmv013-aufnr,
        verid_nd   like ckmlmv001-verid_nd,
        meinh      like ckmlmv003-meinh,
        out_menge  like ckmlmv003-out_menge,
          kalnr_in like ckmlmv003-kalnr_in,   "Join Condition
        end of  lt_ckmlmv003.
  data: lt_ckmlmv003_tmp like lt_ckmlmv003 occurs 0 with header line.

* 1. Input the archive infostructure name
  clear l_archindex.
  l_archindex = 'ZCKMLMV013_001'.

* 2. Get the structure table using infostructure
  clear l_gentab.
  select single gentab into l_gentab from aind_str2
   where archindex = l_archindex.

  check sy-subrc = 0 and not l_gentab is initial.

  clear: lt_ckmlmv003, lt_ckmlmv003[].
  select a~bwkey a~matnr a~verid_nd
*         c~aufnr
         b~out_menge b~meinh
           b~kalnr_in        "<== Join condition
    into corresponding fields of table lt_ckmlmv003
    from ckmlmv001 as a inner join ckmlmv003 as b
                                on a~kalnr =  b~kalnr_bal
*                        INNER JOIN ckmlmv013 AS c
*                                ON c~kalnr_proc = b~kalnr_in
     for all entries in gt_proc_gr_a
   where a~bwkey    =  gt_proc_gr_a-par_werks
     and a~matnr    =  gt_proc_gr_a-artnr
     and a~verid_nd =  gt_proc_gr_a-verid
     and a~btyp     =  'BF'
     and b~gjahr    =  p_bdatj
     and b~perio    in s_poper.
**     and c~flg_wbwg = 'X'.   "goods movement
***    and c~loekz    = space. "Not deleted.
*     AND c~flg_wbwg = 'X'
*     AND c~autyp = '05'.

  check not lt_ckmlmv003[] is initial.

  clear: lt_ckmlmv003_tmp, lt_ckmlmv003_tmp[].
  lt_ckmlmv003_tmp[] = lt_ckmlmv003[].
  sort lt_ckmlmv003_tmp by kalnr_in.
  delete adjacent duplicates from lt_ckmlmv003_tmp comparing kalnr_in.

* 3. Get the archived data from structure table
  clear lt_inx_ckmlmv013[].
  select * into corresponding fields of table lt_inx_ckmlmv013
    from (l_gentab)
    for all entries in lt_ckmlmv003_tmp
   where kalnr_proc = lt_ckmlmv003_tmp-kalnr_in
     and flg_wbwg   = 'X'
     and autyp      = '05'.

  check not lt_inx_ckmlmv013[] is initial.

* 4. Get more archived data looping structure table
  clear: gt_ckmlmv013_a, gt_ckmlmv013_a[].
  loop at lt_inx_ckmlmv013 into ls_inx_ckmlmv013.
*  4.1 Read information from archivekey & offset
    clear l_handle.
    call function 'ARCHIVE_READ_OBJECT'
      exporting
        object                    = 'CO_ORDER'
        archivkey                 = ls_inx_ckmlmv013-archivekey
        offset                    = ls_inx_ckmlmv013-archiveofs
      importing
        archive_handle            = l_handle
      exceptions
        no_record_found           = 1
        file_io_error             = 2
        internal_error            = 3
        open_error                = 4
        cancelled_by_user         = 5
        archivelink_error         = 6
        object_not_found          = 7
        filename_creation_failure = 8
        file_already_open         = 9
        not_authorized            = 10
        file_not_found            = 11
        error_message             = 12
        others                    = 13.

    check sy-subrc = 0.

*  4.2 Read table from information
    clear: lt_ckmlmv013, lt_ckmlmv013[].
    call function 'ARCHIVE_GET_TABLE'
      exporting
        archive_handle          = l_handle
        record_structure        = 'CKMLMV013'
        all_records_of_object   = 'X'
      tables
        table                   = lt_ckmlmv013
      exceptions
        end_of_object           = 1
        internal_error          = 2
        wrong_access_to_archive = 3
        others                  = 4.

    check sy-subrc = 0 and not lt_ckmlmv013[] is initial.

* 5. Append archived data table to finally interal table
    insert lines of lt_ckmlmv013 into table gt_ckmlmv013_a.
  endloop.

  sort gt_ckmlmv013_a.
  delete adjacent duplicates from  gt_ckmlmv013_a comparing all fields.

  loop at lt_ckmlmv003.
    clear gt_ckmlmv013_a.
    read table gt_ckmlmv013_a with key kalnr_proc =
    lt_ckmlmv003-kalnr_in.

    check sy-subrc = 0.

    clear pt_ckmlmv003.
    move-corresponding lt_ckmlmv003 to pt_ckmlmv003.
    pt_ckmlmv003-aufnr = gt_ckmlmv013_a-aufnr.

    append pt_ckmlmv003.
  endloop.

endform.                    " ARCHIVE_READ_CKMLMV013_2
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_READ_EKBE_EKKO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_EKBE  text
*----------------------------------------------------------------------*
form archive_read_ekbe_ekko tables pt_ekbe      structure gt_ekbe_a
                                   pr_werks     structure gr_werks_a
                                   pr_ven_matnr structure gr_ven_matnr_a
                             using p_last_date.

  types: begin of ty_ekbe,
         ebeln type ebeln,
         ebelp type ebelp,
         zekkn type dzekkn,
         vgabe type vgabe,
         gjahr type mjahr,
         belnr type mblnr,
         buzei type mblpo,
         werks type werks_d,
         budat type budat,
         bwart type bwart,
         matnr type matnr,
         bewtp type bewtp,
         lifnr type elifn,
           archivekey type arkey,
           archiveofs type admi_offst.
  types: end of ty_ekbe.

  data: l_handle    type sytabix,
        lt_ekbe     type table of ekbe with header line,
        l_archindex like aind_str2-archindex,
        l_gentab    like aind_str2-gentab.

  data: lt_inx_ekbe type table of ty_ekbe,
        ls_inx_ekbe type ty_ekbe.

* 1. Input the archive infostructure name
  clear l_archindex.
  l_archindex = 'ZEKBE_001'.

* 2. Get the structure table using infostructure
  clear l_gentab.
  select single gentab into l_gentab from aind_str2
   where archindex = l_archindex.

  check sy-subrc = 0 and not l_gentab is initial.

* 3. Get the archived data from structure table
  clear lt_inx_ekbe[].
  select distinct matnr lifnr max( budat )
    into corresponding fields of table lt_inx_ekbe
    from (l_gentab)
   where werks in pr_werks
     and budat <= p_last_date
     and bwart = '101'
     and matnr in pr_ven_matnr
     and bewtp =  'E'
    group by matnr lifnr.

  loop at lt_inx_ekbe into ls_inx_ekbe.
    clear pt_ekbe.
    move-corresponding ls_inx_ekbe to pt_ekbe.
    append pt_ekbe.  clear pt_ekbe.
  endloop.

endform.                    " ARCHIVE_READ_EKBE_EKKO

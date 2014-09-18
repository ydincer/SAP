*----------------------------------------------------------------------*
*   INCLUDE ZCO_ZXM06U52_MOD                                           *
*----------------------------------------------------------------------*


  REFRESH: it_info, it_knumh.

*ISSUE: SUB is not maintained properly...
  SELECT * INTO CORRESPONDING FIELDS OF TABLE it_info
    FROM eina AS a INNER JOIN eine AS b
      ON a~infnr = b~infnr
   WHERE a~matnr = i_bqpim-matnr
     AND a~loekz = ' '
*    AND a~urzzt = 'SUB'   "Vaatz I/F (Module sub)
     AND b~werks = ' '
     AND b~ekorg = l_ekorg
     AND b~loekz = ' '.

  LOOP AT it_info.
*---Material Info-Price Record
    SELECT knumh datab lifnr ekorg
      INTO CORRESPONDING FIELDS OF it_knumh
      FROM a018
     WHERE kappl =  'M'
       AND kschl =  'PB00'
       AND matnr =  i_bqpim-matnr
       AND lifnr =  it_info-lifnr
*      and ekorg =  c_ekorg
       AND esokz =  '0'
       AND datbi >=  i_bqpim-nedat   "Valid To
       AND datab <=  i_bqpim-nedat.  "Valid from
      IF sy-subrc = 0.
        it_knumh-infnr = it_info-infnr.
        APPEND it_knumh.
      ENDIF.
    ENDSELECT.
  ENDLOOP.

  DESCRIBE TABLE it_knumh LINES sy-index.
**----- OK. Determine Vendor.
  IF sy-index = 1.
    c_bqpex-flief = it_knumh-lifnr.  "Fixed vendor.
    c_bqpex-ekorg = it_knumh-ekorg.
    c_bqpex-infnr = it_knumh-infnr.

**----- Determine Newest Valid From, lowest price
  ELSEIF sy-index > 1.
    IF l_send_notice = 1.
      l_send_notice = 12.  "Multi info-record exist
    ENDIF.

    IF l_flg_low = 'X'.
      LOOP AT it_knumh.
        SELECT SINGLE * FROM konp
         WHERE knumh = it_knumh-knumh
           AND kappl = 'M'
           AND kschl = 'PB00'.
        it_knumh-kstbmt = konp-kbetr / konp-kpein.
        it_knumh-kbetr  = konp-kbetr.
        it_knumh-kpein  = konp-kpein.
        MODIFY it_knumh.
      ENDLOOP.

      SORT it_knumh BY datab  DESCENDING
                       kstbmt ASCENDING.
      READ TABLE it_knumh INDEX 1.
      IF sy-subrc = 0.
        c_bqpex-flief = it_knumh-lifnr.  "Fixed vendor.
        c_bqpex-ekorg = it_knumh-ekorg.
        c_bqpex-infnr = it_knumh-infnr.
*     c_bqpex-lifnr = it_info-lifnr.
      ENDIF.
    ENDIF.

  ENDIF.

*&---------------------------------------------------------------------*
*&  Include           Z_EXECUTE
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM at_selection_screen .


ENDFORM.                    " AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Gerekli olan data çekildi.
*----------------------------------------------------------------------*
FORM set_pf_status USING p_extab TYPE slis_t_extab.
  "STATUS tanimlamada herhangi bir isimde verilebilir.
  "excluding var araştır
  "ona butonları ekliyosun function codu ekliyosun onu göstermiyor
  "tam burda kullancan.
*  CASE 'X'.
*    WHEN p_gun.
*      SET PF-STATUS 'STANDARD'.
*    WHEN p_log.
*      SET PF-STATUS 'STANDARD1'.
*  ENDCASE.

  IF p_log IS INITIAL.
    APPEND 'SIL' TO p_extab.
    APPEND 'KAYI' TO p_extab.
  ENDIF.

  SET PF-STATUS 'STANDARD' EXCLUDING p_extab.

ENDFORM.
FORM get_data .

  SELECT  sflight~carrid
          sflight~connid
          sflight~fldate
          sflight~price
          sflight~currency
          sflight~paymentsum
          sflight~planetype
          spfli~countryfr
          spfli~cityfrom
          spfli~airpfrom
          spfli~countryto
          spfli~cityto
          spfli~airpto
          spfli~fltime
          scarr~carrname

          INTO CORRESPONDING FIELDS OF TABLE gt_flight
          FROM sflight
          INNER JOIN spfli
                      ON sflight~carrid = spfli~carrid
          INNER JOIN scarr
                      ON sflight~carrid = scarr~carrid

                      WHERE sflight~carrid  IN so_carid
                       AND  sflight~connid  IN so_conid
                       AND  sflight~fldate  IN so_date.

  IF sy-subrc = 0.
    MESSAGE s003(z_odev3_msg).
  ENDIF.

*  SELECT  sflight~carrid,
*          sflight~fldate,
*          sflight~connid,
*          sflight~fldate,
*          sflight~price,
*          sflight~currency,
*          sflight~paymentsum,
*          sflight~planetype,
*          spfli~countryfr,
*          spfli~cityfrom,
*          spfli~airpfrom,
*          spfli~countryto,
*          spfli~cityto,
*          spfli~airpto,
*          spfli~fltime,
*          scarr~carrname
*          FROM sflight
*          INNER JOIN spfli ON sflight~carrid = spfli~carrid
*          INNER JOIN scarr ON sflight~carrid = scarr~carrid
*          INTO TABLE @data(lt_Data)
*            WHERE sflight~carrid IN @so_carid
*             AND  sflight~connid IN @so_conid
*             AND  sflight~fldate IN @so_date.

* eksik patch var yeni kod tanımlaması

*Öenmli not
*into corresponding ile into table arasında performans farkı var
* into correspondibg select attığın alan adını gider tabloda tek tek
* search eder ve yavaşlar mesela sen en başta carrid çektin ama senin
* tablonda en son sırada ise tek tek bakar en son da bulur buda yavaşlar
* select sıran ile tablondaki alanların sırası aynı olacak ve into table
*olcak

ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_layout .
* CLEAR ct_layout.
"ct_layout-colwidth_optimize = 'X'.         " Optimization of Col width
  ct_layout-coltab_fieldname = 'CELLCOLOR'.  " Cell color Column Name
  ct_layout-info_fieldname   = 'LINE_COLOR'.
* ct_layout-INFO_FNAME       = 'LINE_COLOR'.
  ct_layout-window_titlebar  = 'Tur Sirketi Odev'.
  ct_layout-box_fieldname    = 'SEL'.
  ct_layout-zebra            = 'X'.
* daha düzenli olur
ENDFORM.                    " SET_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display .
* fonksiyon çağırınca kullanmadığın alanları sil kalabalık görünmesin.
* fonksiyon çağırınca exeption aç aksi taktirdehata alırsa dump alırsın.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'SET_USER_COMMAND'
      is_layout                = ct_layout
      it_fieldcat              = ct_fcat[]
    TABLES
      t_outtab                 = gt_flight
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " ALV_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  SET_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_catalog .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_FLIGHT'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = ct_fcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*catalog olustuktan sonra mgüdahale etmek için;

  LOOP AT ct_fcat INTO wa_fcat. "NOT Alanı Editliyoruz.
    "hangi alana müdahale etmek için bir if ihtiyacimiz var.
    CASE wa_fcat-fieldname.
      WHEN 'NOTLAR'.
        wa_fcat-seltext_l = 'Tutulan Notlar'. "uzun adi
        wa_fcat-seltext_m = 'Notlar'. "orta adi
        wa_fcat-seltext_s = 'Not.'.     "kisa adi
        wa_fcat-row_pos   = 16.   "Sütün pozisizyonu
        wa_fcat-edit      = 'X'.   "Düzenlemeyi açıyoruz

    ENDCASE.
    MODIFY ct_fcat FROM wa_fcat.
    CLEAR wa_fcat.
  ENDLOOP.


ENDFORM.                    " SET_CATALOG




*&---------------------------------------------------------------------*
*&      SET_USER_COMMAND
*&---------------------------------------------------------------------*
* "USER Command icinde ayrica Perform tanimlamasi
*----------------------------------------------------------------------*

FORM set_user_command USING p_ucomm "Hangi butona bastigimizi ceker
                            p_selfield TYPE slis_selfield.

  DATA: gd_repid LIKE sy-repid,
        ref_grid TYPE REF TO cl_gui_alv_grid.

  IF ref_grid IS INITIAL. "ALV Check Changed DATA
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.
  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data.
  ENDIF.

  CASE  p_ucomm.
    WHEN 'KAYIT'.
      PERFORM kaydet CHANGING p_selfield.
    WHEN 'KONTROL'.
      PERFORM kontrol.
    WHEN 'KAYDET'.
      PERFORM log_kaydet CHANGING p_selfield.
    WHEN 'SIL'.
      PERFORM sil CHANGING p_selfield.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  KAYDET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM kaydet CHANGING is_selfield TYPE slis_selfield.
  "DATA: lt_save_data TYPE TABLE OF zodev_1 WITH HEADER LINE.
  DATA: lt_save_data TYPE  zodev_1 OCCURS 0 WITH HEADER LINE.


*lv_save_wa TYPE zodev_1.
*lt_save_data-DEGISTIREN_TARIHI     = sy-datum.  kayıt İşlemi
*Diğerleriyle Yapılacak
*lt_save_data-DEGISTIREN_SAATI      = sy-uzeit.  kayıt İşlemi
*Diğerleriyle Yapılacak
*lt_save_data-DEGISTIREN_KULLANICI  = sy-uname.  kayıt İşlemi
*Diğerleriyle Yapılacak

  is_selfield-refresh = 'X'.

  LOOP AT gt_flight  WHERE sel = 'X'.

    lt_save_data-kayit_tarihi       = sy-datum.
    lt_save_data-kayit_saati        = sy-uzeit.
    lt_save_data-kaydeden_kullanici = sy-uname.
    lt_save_data-carrid             = gt_flight-carrid.
    lt_save_data-carrname           = gt_flight-carrname.
    lt_save_data-connid             = gt_flight-connid.
    lt_save_data-fldate             = gt_flight-fldate.
    lt_save_data-price              = gt_flight-price.
    lt_save_data-currency           = gt_flight-currency.
    lt_save_data-paymentsum         = gt_flight-paymentsum.
    lt_save_data-planetype          = gt_flight-planetype.
    lt_save_data-countryfr          = gt_flight-countryfr.
    lt_save_data-cityfrom           = gt_flight-cityfrom.
    lt_save_data-airpfrom           = gt_flight-airpfrom.
    lt_save_data-countryto          = gt_flight-countryto.
    lt_save_data-cityto             = gt_flight-cityto.
    lt_save_data-airpto             = gt_flight-airpto.
    lt_save_data-fltime             = gt_flight-fltime.
    lt_save_data-notlar             = gt_flight-notlar.

    MOVE-CORRESPONDING  gt_flight TO lt_save_data.
    APPEND lt_save_data.
  ENDLOOP.
  IF lt_save_data[] IS NOT INITIAL .
    MODIFY zodev_1 FROM TABLE lt_save_data.
    CLEAR: gt_flight,
           lt_save_data.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
*      COMMIT WORK.
      MESSAGE i001(z_odev3_msg).
    ENDIF.
    is_selfield-refresh = 'X'.
  ELSE.
    MESSAGE s002(z_odev3_msg) DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " KAYDET

*&---------------------------------------------------------------------*
*&      Form  KONTROL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM kontrol.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_ZODEV1'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = ct_fcat2[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "catalog olustuktan sonra müdahale etmek için;

  LOOP AT ct_fcat2 INTO wa_fcat2. "NOT Alanı Editliyoruz.

  "hangi alana müdahale etmek için bir if ihtiyacimiz var.
    CASE wa_fcat2-fieldname.
      WHEN 'NOTLAR'.

        wa_fcat-seltext_l = 'Tutulan Notlar'. "uzun adi
        wa_fcat-seltext_m = 'Notlar'.         "orta adi
        wa_fcat-seltext_s = 'Not.'.           "kisa adi
        wa_fcat-row_pos   = 16.         "Sütün pozisizyonu
        wa_fcat-edit      = 'X'.   "Düzenlemeyi açıyoruz

    ENDCASE.
    MODIFY ct_fcat2 FROM wa_fcat2.
    CLEAR wa_fcat2.
  ENDLOOP.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING

      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'SET_USER_COMMAND'
      is_layout                = ct_layout
      it_fieldcat              = ct_fcat2[]

    TABLES
      t_outtab                 = gt_zodev1
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " KONTROL
*&---------------------------------------------------------------------*
*&      Form  GUNCEL_VERI_GETIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM guncel_veri_getir .
*****  "For ROW Colors
*****  Populate color variable with color properties
*****  Char 1 = C (This is color property)
*****  Char 2 = 3 (Color Codes : 1-7)
*****  Char 3 = Intensified Display on/off (1 or 0)
*****  Char 4 = Inverse display on/off (1 or 0)
*****  Example : wa_ekko-line_color = C410
* Color the Quantity cell where quantity is less than 5

  LOOP AT gt_flight WHERE fltime GT 500.
    gt_flight-line_color = 'C600'.
    MODIFY gt_flight.
    CLEAR gt_flight.
  ENDLOOP.

  PERFORM set_catalog.
  PERFORM alv_display.

ENDFORM.                    " GUNCEL_VERI_GETIR
*&---------------------------------------------------------------------*
*&      Form  SECIMLER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM secimler .
  PERFORM get_data.
  PERFORM get_data_ztable.
  CASE 'X'.
    WHEN p_gun.
      PERFORM guncel_veri_getir.
    WHEN p_log.
      PERFORM log_verisi_getir.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " SECIMLER
*&---------------------------------------------------------------------*
*&      Form  LOG_VERISI_GETIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM log_verisi_getir .

  PERFORM set_catalog_log_verisi.
  PERFORM alv_display_log_verisi.

ENDFORM.                    " LOG_VERISI_GETIR
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_ztable .

  SELECT   mandt
           kayit_tarihi
           kayit_saati
           kaydeden_kullanici
           degistiren_tarihi
           degistiren_saati
           degistiren_kullanici
           carrid
           connid
           fldate
           price
           currency
           paymentsum
           planetype
           countryfr
           cityfrom
           airpfrom
           countryto
           cityto
           airpto
           fltime
           notlar

           INTO CORRESPONDING FIELDS OF TABLE gt_zodev1
            FROM  zodev_1
                          WHERE      carrid IN so_carid  "sflight~
                              AND    connid IN so_conid
                              AND     fldate IN so_date.
  IF sy-subrc = 0.
    SORT gt_zodev1 BY kayit_tarihi.
  ENDIF.
ENDFORM.                    " GET_DATA_ZTABLE
*&---------------------------------------------------------------------*
*&      Form  SET_CATALOG_LOG_VERISI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_catalog_log_verisi .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_ZODEV1'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = ct_fcat1[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*catalog olustuktan sonra mgüdahale etmek için;

  LOOP AT ct_fcat1 INTO wa_fcat1. "NOT Alanı Editliyoruz.

    "hangi alana müdahale etmek için bir if ihtiyacimiz var.
    CASE wa_fcat1-fieldname.
      WHEN 'NOTLAR'.

        wa_fcat1-seltext_l = 'Tutulan Notlar'. "uzun adi
        wa_fcat1-seltext_m = 'Notlar'. "orta adi
        wa_fcat1-seltext_s = 'Not.'.     "kisa adi
        wa_fcat1-row_pos   = 16.   "Sütün pozisizyonu
        wa_fcat1-edit      = 'X'.   "Düzenlemeyi açıyoruz

    ENDCASE.
    MODIFY ct_fcat1 FROM wa_fcat1.
    CLEAR wa_fcat1.
  ENDLOOP.
ENDFORM.                    " SET_CATALOG_LOG_VERISI
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY_LOG_VERISI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display_log_verisi .
* fonksiyon çağırınca kullanmadığın alanları sil kalabalık görünmesin.
* fonksiyon çağırınca exeption aç aksi taktirdehata alırsa dump alırsın.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'SET_USER_COMMAND'
      is_layout                = ct_layout
      it_fieldcat              = ct_fcat1[]
    TABLES
      t_outtab                 = gt_zodev1
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.
ENDFORM.                    " ALV_DISPLAY_LOG_VERISI
*&---------------------------------------------------------------------*
*&      Form  LOG_KAYDET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_SELFIELD  text
*----------------------------------------------------------------------*
FORM log_kaydet  CHANGING is_selfield TYPE slis_selfield.

  "DATA: lt_save_data TYPE TABLE OF zodev_1 WITH HEADER LINE.
  DATA: lt_save_data TYPE  zodev_1 OCCURS 0 WITH HEADER LINE.

  is_selfield-refresh = 'X'.

  LOOP AT gt_flight  WHERE sel = 'X'.
    "kayıt İşlemi Diğerleriyle Yapılacak
    lt_save_data-degistiren_tarihi     = sy-datum.
    lt_save_data-degistiren_saati      = sy-uzeit.
    lt_save_data-degistiren_kullanici  = sy-uname.
    "kayıt İşlemi Diğerleriyle Yapılacak
    lt_save_data-carrid             = gt_flight-carrid.
    lt_save_data-carrname           = gt_flight-carrname.
    lt_save_data-connid             = gt_flight-connid.
    lt_save_data-fldate             = gt_flight-fldate.
    lt_save_data-price              = gt_flight-price.
    lt_save_data-currency           = gt_flight-currency.
    lt_save_data-paymentsum         = gt_flight-paymentsum.
    lt_save_data-planetype          = gt_flight-planetype.
    lt_save_data-countryfr          = gt_flight-countryfr.
    lt_save_data-cityfrom           = gt_flight-cityfrom.
    lt_save_data-airpfrom           = gt_flight-airpfrom.
    lt_save_data-countryto          = gt_flight-countryto.
    lt_save_data-cityto             = gt_flight-cityto.
    lt_save_data-airpto             = gt_flight-airpto.
    lt_save_data-fltime             = gt_flight-fltime.
    lt_save_data-notlar             = gt_flight-notlar.

    MOVE-CORRESPONDING  gt_flight TO lt_save_data.
    APPEND lt_save_data.
  ENDLOOP.
  IF lt_save_data[] IS NOT INITIAL .
    MODIFY zodev_1 FROM TABLE lt_save_data.
    CLEAR: gt_flight,
           lt_save_data.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
*      COMMIT WORK.
      MESSAGE i001(z_odev3_msg).
    ENDIF.
    is_selfield-refresh = 'X'.
  ELSE.
    MESSAGE s002(z_odev3_msg) DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " LOG_KAYDET
*&---------------------------------------------------------------------*
*&      Form  SIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sil CHANGING is_selfield TYPE slis_selfield.
  "DATA: lt_save_data TYPE TABLE OF zodev_1 WITH HEADER LINE.
  DATA: lt_save_data TYPE  zodev_1 OCCURS 0 WITH HEADER LINE.

  LOOP AT gt_flight  WHERE sel = 'X'. "Seçilen Verileri Çek
    MOVE-CORRESPONDING  gt_flight TO lt_save_data.
    APPEND lt_save_data.
  ENDLOOP.

  IF lt_save_data[] IS NOT INITIAL .
    DELETE zodev_1 FROM TABLE lt_save_data.
    CLEAR: gt_flight,
           lt_save_data.

    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
*      COMMIT WORK.
      MESSAGE i004(z_odev3_msg).
    ENDIF.
    is_selfield-refresh = 'X'.
  ELSE.
    MESSAGE s002(z_odev3_msg) DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " SIL

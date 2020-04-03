*&---------------------------------------------------------------------*
*&  Include           Z_TOP
*&---------------------------------------------------------------------*
TABLES: sflight,spfli,scarr,sscrfields,zodev_1.

*Notes:...
*SSCRFIELDS is a predefined structure used to assign display values for
*function keys.
TYPE-POOLS: slis. "SLIS Contains all the ALV data Types


DATA : BEGIN OF gt_flight OCCURS 0, "tüm kayıtlar için structure

  carrid      LIKE  sflight-carrid,
  carrname    LIKE  scarr-carrname,
  connid      LIKE  sflight-connid,
  fldate      LIKE  sflight-fldate,
  price       LIKE  sflight-price,
  currency    LIKE  sflight-currency,
  paymentsum  LIKE  sflight-paymentsum,
  planetype   LIKE  sflight-planetype,
  countryfr   LIKE  spfli-countryfr,
  cityfrom    LIKE  spfli-cityfrom,
  airpfrom    LIKE  spfli-airpfrom,
  countryto   LIKE  spfli-countryto,
  cityto      LIKE  spfli-cityto,
  airpto      LIKE  spfli-airpto,
  fltime      LIKE  spfli-fltime,
  notlar(100),
  line_color(4), "Renk değerleri tutulur.
  cellcolor TYPE lvc_t_scol, "Cell Color
  sel,

  END OF gt_flight.

DATA: BEGIN OF gs_flight, "gs flight work area
  carrid      TYPE  sflight-carrid,
  carrname    TYPE  scarr-carrname,
  connid      TYPE  sflight-connid,
  fldate      TYPE  sflight-fldate,
  price       TYPE  sflight-price,
  currency    TYPE  sflight-currency,
  paymentsum  TYPE  sflight-paymentsum,
  planetype   TYPE  sflight-planetype,
  countryfr   TYPE  spfli-countryfr,
  cityfrom    TYPE  spfli-cityfrom,
  airpfrom    TYPE  spfli-airpfrom,
  countryto   TYPE  spfli-countryto,
  cityto      TYPE  spfli-cityto,
  airpto      TYPE  spfli-airpto,
  fltime      TYPE  spfli-fltime,
  not(100),
  line_color(4), "Renk değerleri tutulur.
  cellcolor TYPE lvc_t_scol, "Cell Color
  sel,
  END OF gs_flight.

DATA : BEGIN OF gt_zodev1 OCCURS 0 , "tüm kayıtlar için structure
kayit_tarihi          LIKE  zodev_1-kayit_tarihi,
kayit_saati           LIKE  zodev_1-kayit_saati  ,
kaydeden_kullanici    LIKE  zodev_1-kaydeden_kullanici,
degistiren_tarihi     LIKE  zodev_1-degistiren_tarihi,
degistiren_saati      LIKE  zodev_1-degistiren_saati ,
degistiren_kullanici  LIKE  zodev_1-degistiren_kullanici,
  carrid      LIKE  zodev_1-carrid,
  carrname    LIKE  zodev_1-carrname,
  connid      LIKE  zodev_1-connid,
  fldate      LIKE  zodev_1-fldate,
  price       LIKE  zodev_1-price,
  currency    LIKE  zodev_1-currency,
  paymentsum  LIKE  zodev_1-paymentsum,
  planetype   LIKE  zodev_1-planetype,
  countryfr   LIKE  zodev_1-countryfr,
  cityfrom    LIKE  zodev_1-cityfrom,
  airpfrom    LIKE  zodev_1-airpfrom,
  countryto   LIKE  zodev_1-countryto,
  cityto      LIKE  zodev_1-cityto,
  airpto      LIKE  zodev_1-airpto,
  fltime      LIKE  zodev_1-fltime,
  notlar(100),
  line_color(4), "Renk değerleri tutulur.
  cellcolor TYPE lvc_t_scol, "Cell Color
  sel,

  END OF gt_zodev1.


*DATA: gt_zodev1 type ZODEV_1 occurs 0 WITH HEADER LINE,
*      gs_zodev1 type ZODEV_1.


*Local variable decleration
DATA: c_sel TYPE n.

*itab decleration
DATA: ct_fcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ct_fcat1 TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ct_fcat2 TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      cs_fieldcat TYPE slis_fieldcat_alv,
      cs_field TYPE slis_t_specialcol_alv,
      ct_layout TYPE slis_layout_alv.



* work area declerations
DATA: wa_fcat             LIKE LINE OF ct_fcat,
       wa_fcat1             LIKE LINE OF ct_fcat,
       wa_fcat2             LIKE LINE OF ct_fcat,
      "ALV control: Structure for cell coloring
      wa_cellcolor        TYPE lvc_s_scol, "renklendirme wa
      lv_index            TYPE sy-tabix.


SELECTION-SCREEN: BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
SELECT-OPTIONS so_carid FOR sflight-carrid.
SELECT-OPTIONS so_conid FOR sflight-connid.
*SELECT-OPTIONS so_ctime FOR spfli-fltime.
SELECT-OPTIONS so_date FOR sflight-fldate OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN: BEGIN OF BLOCK blk2 WITH FRAME TITLE text-002.

PARAMETERS: p_gun RADIOBUTTON GROUP gr1,
            p_log RADIOBUTTON GROUP gr1.

SELECTION-SCREEN END OF BLOCK blk2.

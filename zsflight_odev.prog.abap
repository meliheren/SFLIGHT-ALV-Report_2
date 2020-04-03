*&---------------------------------------------------------------------
*
*& Report  ZMELIH_ODEV_FLIGHT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zsflight_odev.

INCLUDE zsflight_top. "Structure - Tables - Select Options Tanımlamaları
INCLUDE zsflight_execute."İşlem Kodları


INITIALIZATION.

  PERFORM set_layout.

AT SELECTION-SCREEN.
  PERFORM at_selection_screen.

START-OF-SELECTION.
  PERFORM secimler.


END-OF-SELECTION.






*&---------------------------------------------------------------------*
*& - Melih EREN
*&
*&---------------------------------------------------------------------*

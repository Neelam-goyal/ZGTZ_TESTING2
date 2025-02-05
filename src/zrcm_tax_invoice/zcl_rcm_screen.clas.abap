CLASS zcl_rcm_screen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RCM_SCREEN IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zcds_rcm,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.

      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

      DATA(lt_clause)  = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameters)  = io_request->get_parameters( ).
      DATA(lt_fileds)  = io_request->get_requested_elements( ).
      DATA(lt_sort)  = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'ACCOUNTINGDOCUMENT'.
          DATA(lt_AccountingDocument) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_CompanyCode) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = 'FISCALYEAR'.
          DATA(lt_FiscalYear) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'ACCOUNTINGDOCUMENTTYPE'.
          DATA(lt_accountingDocumentType) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = 'DOCUMENTDATE'.
          DATA(lt_DocumentDate) = ls_FILTER_cond-range[].
        ENDIF.
      ENDLOOP.



      SELECT
       a~accountingdocument ,
         a~fiscalyear,
         a~companycode,
*         a~AccountingDocumentItem,
         a~AccountingDocumentType,
         a~DocumentDate,
         a~GLAccount,
         a~absoluteamountincocodecrcy,
*         a~customer,
         a~supplier,
         a~ClearingDate,
         a~ClearingJournalEntry,
         a~OriginalReferenceDocument,
         a~FinancialAccountType,
         b~ISREVERSED
         FROM i_operationalacctgdocitem AS a
         left JOIN I_ACCOUNTINGDOCUMENTJOURNAL as b ON a~AccountingDocument = b~AccountingDocument AND a~CompanyCode = b~CompanyCode AND a~FiscalYear = b~FiscalYear
          WHERE a~AccountingDocumentType IN ( 'RE', 'KR' )
*          AND a~AccountingDocumentItemType = 'T'
*          AND a~FinancialAccountType = 'K'
          AND a~transactiontypedetermination IN ('JRC', 'JRS', 'JRI', 'JRU')
          AND a~AccountingDocument IN  @lt_accountingdocument
          AND a~CompanyCode IN @lt_companycode
          AND a~FiscalYear IN @lt_fiscalyear
*          AND a~AccountingDocumentItem IN @lt_accountingdocumentitem
          AND a~AccountingDocumentType IN @lt_accountingdocumenttype
          AND a~DocumentDate IN @lt_documentdate
          INTO TABLE @DATA(it_item).

          SORT IT_ITEM BY accountingdocument fiscalyear companycode.
          DELETE ADJACENT DUPLICATES FROM it_item COMPARING accountingdocument fiscalyear companycode.


          loop at it_item INTO DATA(wa).
          if wa-IsReversed is INITIAL.
          ls_response-AccountingDocument = wa-AccountingDocument.
*          ls_response-AccountingDocumentItem = wa-AccountingDocumentItem.
          ls_response-FiscalYear = wa-FiscalYear.
          ls_response-CompanyCode = wa-CompanyCode.
          ls_response-AccountingDocumentType = wa-AccountingDocumentType.
          ls_response-DocumentDate = wa-DocumentDate.
*          ls_response-Customer = wa-Customer.
          ls_response-GLAccount = wa-GLAccount.

          IF wa-FinancialAccountType = 'K'.
          ls_response-Supplier = wa-Supplier.
          ENDIF.

          ls_response-AbsoluteAmountInCoCodeCrcy = wa-AbsoluteAmountInCoCodeCrcy.
          ls_response-OriginalReferenceDocument = wa-OriginalReferenceDocument.
          ls_response-ClearingDate = wa-ClearingDate.
          ls_response-ClearingJournalEntry = wa-ClearingJournalEntry.
          APPEND ls_response TO lt_response.
          ENDIF.

          clear ls_response.
          clear wa.


          ENDLOOP.




      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).



    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS ztest_pay_adv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE vbeln.
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.

*    CLASS-METHODS :
*      create_client
*        IMPORTING url           TYPE string
*        RETURNING VALUE(result) TYPE REF TO if_web_http_client
*        RAISING   cx_static_check ,
*
**      read_posts
*        IMPORTING VALUE(accountingDocNo) TYPE string
*        RETURNING VALUE(result12)        TYPE string
*        RAISING   cx_static_check .


  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://bn-dev-jpiuus30.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_salesorder_print/zsd_salesorder_print'.
ENDCLASS.



CLASS ztest_pay_adv IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

********* Header level data*********************
    SELECT SINGLE
    a~accountingdocument,
    a~postingdate,
    a~documentdate,
    a~supplier,
    a~documentdate AS  documentdate2,
    a~amountincompanycodecurrency,
    b~CompanyCodeName, "done
    c~plantname,
    d~BPSupplierFullName,
    f~glaccountlongname,
    e~accountingdocumentheadertext

    FROM i_operationalacctgdocitem AS a
    LEFT JOIN i_companycode AS b ON a~companycode = b~companycode
    LEFT JOIN i_plant AS c ON a~BusinessPlace  = c~Plant
    LEFT JOIN i_supplier AS d ON a~Supplier = d~Supplier
    LEFT JOIN i_accountingdocumentjournal AS e ON a~ClearingAccountingDocument = e~AccountingDocument AND a~CompanyCode = e~CompanyCode
                                                    AND a~ClearingDocFiscalYear = e~FiscalYear
    LEFT JOIN i_glaccounttextrawdata AS f ON  e~glaccount = f~GLAccount
                    WHERE a~ClearingAccountingDocument ='1500000033' AND  a~accountingdocumentitem = '002'
*     AND a~ClearingDocFiscalYear = '2024' AND a~CompanyCode = 'GT00' AND
*                     a~accountingdocumentitem = '002' AND e~GLAccountType = 'C' AND e~Ledger = '0L'
        INTO @DATA(wa).

    out->write( wa ).


********Item level data***************

    SELECT
     a~accountingdocument,
     a~businessplace,
     a~accountingdocumenttype,
     a~withholdingtaxamount,
     a~amountincompanycodecurrency,
     b~documentreferenceid,
     b~documentdate
   FROM i_operationalacctgdocitem AS a
   LEFT JOIN i_journalentry AS b ON a~AccountingDocument = b~AccountingDocument
   WHERE a~ClearingAccountingDocument ='1500000033' AND  "a~ClearingDocFiscalYear = '2024' AND a~CompanyCode = 'GT00' AND
   a~TransactionTypeDetermination = 'KBS'
   INTO TABLE @DATA(item).

    DATA(lv_xml) =
    |<Form>| &&
    |<Header>| &&
    |<company_name>{ wa-CompanyCodeName }</company_name>| &&
    |<Branch></Branch>| &&
    |<payment_Advice></payment_Advice>| &&
    |<Voucher_No>{ wa-AccountingDocument }</Voucher_No>| &&
    |<Voucher_Date>{ wa-PostingDate }</Voucher_Date>| &&
    |<payment_From>{ wa-GLAccountLongName }</payment_From>| &&
    |<payment_To>{ wa-BPSupplierFullName }</payment_To>| &&
    |<Cheq_Neft_Rtgs_No>{ wa-AccountingDocumentHeaderText }</Cheq_Neft_Rtgs_No>| &&
    |<Cheq_Neft_Rtgs_Date>{ wa-DocumentDate }</Cheq_Neft_Rtgs_Date>| &&
    |<Payment_To></Payment_To>| &&
    |<Logic_for_data_inpara>{ wa-PostingDate }</Logic_for_data_inpara>| &&
    |<Logic_for_Amount_inpara>{ wa-AmountInCompanyCodeCurrency }</Logic_for_Amount_inpara>| &&
    |</Header>| &&
    |<LineItem>|.

    LOOP AT item INTO DATA(wa_item).
      DATA(lv_xml_table) =
        |<item>| &&
        |<Sr_No></Sr_No>| &&
        |<Document_No>{ wa_item-AccountingDocument }</Document_No>| &&
        |<Business_Place>{ wa_item-BusinessPlace }</Business_Place>| &&
        |<Document_Type>{ wa_item-AccountingDocumentType }</Document_Type>| &&
        |<Invoice_Ref_No>{ wa_item-DocumentReferenceID }</Invoice_Ref_No>| &&
        |<Invoice_Ref_Date>{ wa_item-DocumentDate }</Invoice_Ref_Date>| &&
        |<Invoice_Amount></Invoice_Amount>| &&
        |<TDS_Amount>{ wa_item-WithholdingTaxAmount }</TDS_Amount>| &&
        |<Net_Amount>{ wa_item-AmountInCompanyCodeCurrency }</Net_Amount>| &&
        |<Total></Total>| &&
        |</item>|.
      CONCATENATE lv_xml lv_xml_table INTO lv_xml.
    ENDLOOP.
    CONCATENATE lv_xml '</LineItem>' '</Form>' INTO lv_xml. " Properly closing the root tag.

    out->write( lv_xml ).


*    CALL METHOD zcl_ads_print=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = lc_template_name
*      RECEIVING
*        result   = result12 ).





  ENDMETHOD.
  .

ENDCLASS.





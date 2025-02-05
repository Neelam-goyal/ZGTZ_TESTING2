CLASS zcl_Money_receipt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    CLASS-METHODS :

      read_posts
        IMPORTING lv_belnr2      TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS lc_template_name TYPE string VALUE 'zmoneyreceipt/zmoneyreceipt'."'zpo/zpo_v2'."
ENDCLASS.



CLASS zcl_Money_receipt IMPLEMENTATION.

  METHOD read_posts .

*******************************************************************************Header Select Query
SELECT SINGLE
    a~accountingdocumenttype,
    a~accountingdocument,
    a~postingdate,
    a~FinancialAccountType,
    a~Customer,
    a~supplier,
*    a~OffsettingAccountType,
    a~OffsettingAccount,
*    a~AmountInCompanyCodeCurrency,
    b~CustomerName,
    c~suppliername,
    d~GLAccountType
    FROM I_OperationalAcctgDocItem AS a
    LEFT JOIN I_Customer AS b ON a~customer = b~customer and a~AccountingDocumentType = 'DZ'
    LEFT JOIN I_Supplier AS c ON a~Supplier = c~Supplier
    LEFT JOIN I_GLACCOUNTSTDVH AS d ON a~GLAccount = d~GLAccount and d~GLAccountType = 'C'
    WHERE a~AccountingDocument  = @lv_belnr2
     and ( a~FinancialAccountType = 'K' OR a~FinancialAccountType = 'D' )
    INTO @DATA(wa).

  SELECT single
   a~AbsoluteAmountInCoCodeCrcy
   FROM I_OperationalAcctgDocItem AS a
   WHERE a~AccountingDocument  =  @lv_belnr2  "'1400000001'
   and a~FinancialAccountType = 'S'
   and a~HouseBankAccount is not INITIAL
   into @data(a).




****** Variables ******
    DATA : Vendor TYPE String.
*    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY space.
   IF wa-Supplier IS NOT INITIAL AND wa-SupplierName IS NOT INITIAL.
    CONCATENATE: wa-Supplier wa-SupplierName INTO Vendor SEPARATED BY ' / '.
    endif.
    IF wa-Customer IS NOT INITIAL AND wa-CustomerName IS NOT INITIAL.
    DATA : Customer TYPE String.
*    CONCATENATE: wa-Customer wa-CustomerName INTO Customer SEPARATED BY space.
    CONCATENATE wa-Customer wa-CustomerName INTO Customer SEPARATED BY ' / '.
    endif.



*******************************************************************************Header XML
DATA(lv_xml) = |<Form>| &&
               |<InternalDocumentNode>| &&
               |<AccountingDocument>{ wa-AccountingDocument }</AccountingDocument>| &&
               |<AccountingDocumentType>{ wa-AccountingDocumentType }</AccountingDocumentType>| &&
               |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
               |<OffsettingAccountType>{ wa-FinancialAccountType }</OffsettingAccountType>| &&
               |<OffsettingAccount>{ wa-OffsettingAccount }</OffsettingAccount>| &&
               |<CustomerName>{ Customer }</CustomerName>| &&
               |<SupplierName>{ Vendor }</SupplierName>| &&
               |<GLAccountType>{ wa-GLAccountType }</GLAccountType>| &&
               |<AmountInCompanyCodeCurrency>{ a }</AmountInCompanyCodeCurrency>| &&
               |</InternalDocumentNode>| &&
               |</Form>|.
*


    CALL METHOD ycl_test_adobe2=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.

*******************************************************************************FOOTER Select Query

*SELECT SINGLE
*a~house_num1,
*a~street,
*a~city1,
*a~post_code1
*
*FROM ESH_N_COMPANY_ADDRESS_ADDRESS AS a
*INTO @DATA(WA2).

*CLASS zcl_money_receipt DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun .
*    CLASS-DATA : access_token TYPE string .
*    CLASS-DATA : xml_file TYPE string .
*    CLASS-DATA : var1 TYPE vbeln.
*    TYPES :
*      BEGIN OF struct,
*        xdp_template TYPE string,
*        xml_data     TYPE string,
*        form_type    TYPE string,
*        form_locale  TYPE string,
*        tagged_pdf   TYPE string,
*        embed_font   TYPE string,
*      END OF struct."
*
*
*    CLASS-METHODS :
*      create_client
*        IMPORTING url           TYPE string
*        RETURNING VALUE(result) TYPE REF TO if_web_http_client
*        RAISING   cx_static_check ,
*
*      read_posts
*        IMPORTING VALUE(AccountingDocument) TYPE string
*        RETURNING VALUE(result12)     TYPE string
*        RAISING   cx_static_check .
*  PROTECTED SECTION.
*
*  PRIVATE SECTION.
*    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
*    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
*    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
*    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
*    CONSTANTS lc_template_name TYPE string VALUE 'zmoneyreceipt/zmoneyreceipt'."'zpo/zpo_v2'."
*ENDCLASS.
*
*
*
*CLASS zcl_money_receipt IMPLEMENTATION.
*  METHOD create_client .
*    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
*    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
*
*  ENDMETHOD .
*  METHOD read_posts.
**  METHOD if_oo_adt_classrun~main.
*    var1 = AccountingDocument.
*    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
*    AccountingDocument = var1.
*****************************************  header data ******************************************************
*    SELECT SINGLE
*    a~accountingdocumenttype,
*    a~accountingdocument,
*    a~postingdate,
*    a~OffsettingAccountType,
*    a~OffsettingAccount,
*    a~AmountInCompanyCodeCurrency,
*    b~CustomerName,
*    b~supplier,
*    c~suppliername,
*    d~GLAccountType
*
*
*    FROM I_OperationalAcctgDocItem AS a
*    LEFT JOIN I_Customer AS b ON a~customer = b~customer and a~AccountingDocumentType = 'DZ'
*    LEFT JOIN I_Supplier AS c ON b~Supplier = c~Supplier
*    LEFT JOIN I_GLACCOUNTSTDVH AS d ON a~GLAccount = d~GLAccount and d~GLAccountType = 'C'
*    WHERE a~AccountingDocument  = @AccountingDocument
*    INTO @DATA(wa).
*
*
*
************************************************    header xml ***********************************************
*DATA(lv_xml) = |<Form>| &&
*               |<InternalDocumentNode>| &&
*               |<AccountingDocument>{ wa-AccountingDocument }</AccountingDocument>| &&
*               |<AccountingDocumentType>{ wa-AccountingDocumentType }</AccountingDocumentType>| &&
*               |<PostingDate>{ wa-PostingDate }</PostingDate>| &&
*               |<OffsettingAccountType>{ wa-OffsettingAccountType }</OffsettingAccountType>| &&
*               |<CustomerName>{ wa-CustomerName }</CustomerName>| &&
*               |<SupplierName>{ wa-SupplierName }</SupplierName>| &&
*               |<GLAccountType>{ wa-GLAccountType }</GLAccountType>| &&
*               |<AmountInCompanyCodeCurrency>{ wa-AmountInCompanyCodeCurrency }</AmountInCompanyCodeCurrency>| &&
*               |</InternalDocumentNode>| &&
*               |</Form>|.
*
*    CALL METHOD ycl_test_adobe2=>getpdf(
*      EXPORTING
*        xmldata  = lv_xml
*        template = lc_template_name
*      RECEIVING
*        result   = result12 ).
*
*  ENDMETHOD.
*
*  METHOD if_oo_adt_classrun~main.
*
*  ENDMETHOD.
*
*ENDCLASS.
*


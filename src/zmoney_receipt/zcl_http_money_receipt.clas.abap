CLASS zcl_http_Money_Receipt DEFINITION

  PUBLIC

  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_http_service_extension.

    METHODS: get_html RETURNING VALUE(ui_html) TYPE string,
             post_html IMPORTING lv_belnr TYPE string RETURNING VALUE(html) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_http_Money_Receipt IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.

    DATA(req_method) = request->get_method( ).

    CASE req_method.

      WHEN CONV string( if_web_http_client=>get ).
        " Handle GET request

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).
        " Handle POST request

        DATA(lv_belnr) = request->get_form_field( `belnr` ).

        response->set_text( post_html( lv_belnr ) ).

    ENDCASE.

  ENDMETHOD.


   METHOD get_html.

*     SELECT SINGLE FROM i_operationalacctgdocitem
*        FIELDS AccountingDocument
**        WHERE AccountingDocument = @lv_belnr
*        INTO @DATA(it_belnr).
*
*    DATA count TYPE string.
*
*    count = lines( it ).

     ui_html = |<html><head><title>Money Receipt</title></head><body style="margin:0 ;background-color:#495767;">|.

    CONCATENATE ui_html
                 '<form action="/sap/bc/http/sap/ZCL_HTTP_MONEY_RECEIPT" method="POST">'
                 '<label style = "color:white;font-size:17px" for="belnr">Accounting Document</label>'
                 '<input style="font-size:17px;padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color: white;" type="text" id="belnr" name="belnr" required>'
                 '<input style="font-size:14px;background-color:#1b8dec;padding:5px 17px;border-radius: 6px;cursor:pointer;border:none;color:white;font-weight:700;" type="submit" value="Print">'
                 '</form>'
               '</body></html>' INTO ui_html.
  ENDMETHOD.


  METHOD post_html.

    DATA LV_belnr2 TYPE string.

    SELECT SINGLE FROM I_OperationalAcctgDocItem

      FIELDS  accountingdocument

      WHERE accountingdocument = @lv_belnr

      INTO @LV_belnr2.

    IF LV_belnr2 IS NOT INITIAL.

      TRY.

          " Construct HTML response with embedded PDF view
          DATA(pdf_content) = zcl_Money_Receipt=>read_posts( LV_belnr2 = lv_belnr ).
*            DATA(pdf_content) = zcl_purord_importing=>read_posts( LV_PO2 = '0500000014' ).

*          html = |{ pdf_content }|.
           html = |{ pdf_content }|.

        CATCH cx_static_check INTO DATA(er).

          html = |Accounting Document does not exist: { er->get_longtext( ) }|.

      ENDTRY.

    ELSE.

      html = |Accounting Document not found|.

    ENDIF.

  ENDMETHOD.

ENDCLASS.




*CLASS zcl_http_Money_REceipt DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*    INTERFACES if_http_service_extension.
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*    METHODS: get_html RETURNING VALUE(html) TYPE string.
*    METHODS: post_html
*      IMPORTING
*                lv_belnr TYPE string
*      RETURNING VALUE(html)  TYPE string.
*
*    CLASS-DATA url TYPE string.
*ENDCLASS.
*
*
*
*CLASS zcl_http_Money_REceipt IMPLEMENTATION.
*  METHOD if_http_service_extension~handle_request.
*
*    DATA(req) = request->get_form_fields(  ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
*    DATA(cookies)  = request->get_cookies(  ) .
*
*    DATA req_host TYPE string.
*    DATA req_proto TYPE string.
*    DATA req_uri TYPE string.
*    DATA json TYPE string .
*
*    req_host = request->get_header_field( i_name = 'Host' ).
*    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
*    IF req_proto IS INITIAL.
*      req_proto = 'https'.
*    ENDIF.
**     req_uri = request->get_request_uri( ).
*    DATA(symandt) = sy-mandt.
*    req_uri = '/sap/bc/http/sap/ZCL_HTTP_MONEY_RECEIPT?sap-client=080'.
*    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.
*
*
*    CASE request->get_method( ).
*
*      WHEN CONV string( if_web_http_client=>get ).
*
*        response->set_text( get_html( ) ).
*
*      WHEN CONV string( if_web_http_client=>post ).
*
*        DATA(lv_belnr) = request->get_form_field( `belnr` ).
*
*
*        SELECT SINGLE FROM i_operationalacctgdocitem
*        FIELDS AccountingDocument
*        WHERE AccountingDocument = @lv_belnr
*        INTO @DATA(it_belnr).
*
*        IF it_belnr IS NOT INITIAL.
*
*          TRY.
*              DATA(pdf) = zcl_Money_receipt=>read_posts( lv_belnr = belnr ) .
*
**            response->set_text( pdf ).
*
*              DATA(html) = |<html> | &&
*                             |<body> | &&
*                               | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
*                             | </body> | &&
*                           | </html>|.
*
*
*
*              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
*              response->set_text( html ).
*            CATCH cx_static_check INTO DATA(er).
*              response->set_text( er->get_longtext(  ) ).
*          ENDTRY.
*        ELSE.
*          response->set_text( 'Works Order does not exist.' ).
*        ENDIF.
*
*    ENDCASE.
*
*  ENDMETHOD.
*  METHOD get_html.    "Response HTML for GET request
*
*    html = |<html> \n| &&
*  |<body> \n| &&
*  |<title>Works Order </title> \n| &&
*  |<form action="{ url }" method="POST">\n| &&
*  |<H2>GTZ Works Order Print</H2> \n| &&
*  |<label for="fname">Works Order:  </label> \n| &&
*  |<input type="text" id="salesorderno" name="salesorderno" required ><br><br> \n| &&
*  |<input type="submit" value="Submit"> \n| &&
*  |</form> | &&
*  |</body> \n| &&
*  |</html> | .
*
*
*
*
*
*  ENDMETHOD.
*
*  METHOD post_html.
*
*    html = |<html> \n| &&
*   |<body> \n| &&
*   |<title>Works Order</title> \n| &&
*   |<form action="{ url }" method="Get">\n| &&
*   |<H2>Works Order Print Success </H2> \n| &&
*   |<input type="submit" value="Go Back"> \n| &&
*   |</form> | &&
*   |</body> \n| &&
*   |</html> | .
*  ENDMETHOD.
*ENDCLASS.
*
*
*
***
***CLASS zcl_http_money_receipt DEFINITION
***  PUBLIC
***  FINAL
***  CREATE PUBLIC .
***
***  PUBLIC SECTION.
***
***    INTERFACES if_http_service_extension .
***
***    METHODS: get_html RETURNING VALUE(ui_html) TYPE string,
***      post_html IMPORTING lv_belnr TYPE string RETURNING VALUE(html) TYPE string.
***
***  PROTECTED SECTION.
***  PRIVATE SECTION.
***ENDCLASS.
***
***
***
***CLASS zcl_http_money_receipt IMPLEMENTATION.
***
***
***  METHOD if_http_service_extension~handle_request.
***    DATA(req_method) = request->get_method( ).
***
***    CASE req_method.
***
***      WHEN CONV string( if_web_http_client=>get ).
***        " Handle GET request
***
***        response->set_text( get_html( ) ).
***
***      WHEN CONV string( if_web_http_client=>post ).
***
***        " Handle POST request
***
***        DATA(lv_belnr) = request->get_form_field( `belnr` ).
***
***        response->set_text( post_html( lv_belnr ) ).
***
***    ENDCASE.
***
***  ENDMETHOD.
***
***  METHOD get_html.
***
***    " Fetch data from the database
***
***    SELECT FROM i_operationalacctgdocitem
***           FIELDS
***              accountingdocumenttype,
***              accountingdocument,
***              postingdate,
***              offsettingAccountType,
***              OffsettingAccount,
***              AmountInCompanyCodeCurrency
***           INTO TABLE @DATA(it).
***
***    DATA count TYPE string.
***
***    count = lines( it ).
***
***    " Combine everything into the HTML output
***    ui_html = |<html><head><title>General Information</title></head><body style="margin:0 ;background-color:#495767;">|.
***
***    CONCATENATE ui_html
***                 '<form action="/sap/bc/http/sap/ZHTTP_MONEY_RECEIPT" method="POST">'
***                 '<label style = "color:white;font-size:17px" for="belnr">Document Number</label>'
***                 '<input style="font-size:17px;padding:2px 3px;background:transparent;border:1px solid white;margin:4px;color: white;" type="text" id="belnr" name="belnr" required>'
***                 '<input style="font-size:14px;background-color:#1b8dec;padding:5px 17px;border-radius: 6px;cursor:pointer;border:none;color:white;font-weight:700;" type="submit" value="Print">'
***                 '</form>'
***               '</body></html>' INTO ui_html.
***  ENDMETHOD.
***
***
***   METHOD post_html.
***
***    DATA lv_belnr2 TYPE string.
***
***    SELECT SINGLE FROM i_operationalacctgdocitem
***
***      FIELDS AccountingDocument
***
***      WHERE AccountingDocument = @lv_belnr
***
***      INTO @lv_belnr2.
***
***    IF lv_belnr2 IS NOT INITIAL.
***
***      TRY.
***
***          " Construct HTML response with embedded PDF view
***
***          DATA(pdf_content) = zcl_money_receipt=>read_posts( lv_belnr2 = lv_belnr ).
***
***          html = |{ pdf_content }|.
****           html = |<html><body><iframe src="data:application/pdf;base64,{ pdf_content }" width="100%" height="600px"></iframe></body></html>|.
***
***        CATCH cx_static_check INTO DATA(er).
***
***          html = |Accounting Document does not exist: { er->get_longtext( ) }|.
***
***      ENDTRY.
***
***    ELSE.
***
***      html = |Accounting Document not found|.
***
***    ENDIF.
***
***  ENDMETHOD.
***
***
***ENDCLASS.

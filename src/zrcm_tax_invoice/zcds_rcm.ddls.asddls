@EndUserText.label: 'i_operationalacctgdocitem CDS'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_RCM_SCREEN'
@UI.headerInfo: {typeName: 'RCM TAX INVOICE PRINT'}
define view entity ZCDS_RCM
  as select from I_OperationalAcctgDocItem
{

      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'Accounting Document' }]
  key AccountingDocument,
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'Company Code' }]
  key CompanyCode,

      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'Fiscal Year' }]
  key FiscalYear,
  
  @UI.hidden: true
  key AccountingDocumentItem,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:4 }]
      @UI.lineItem   : [{ position:4, label:'Journal Entry Type' }]
      AccountingDocumentType,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:5 }]
      @UI.lineItem   : [{ position:5, label:'Journal Entry Date' }]
      DocumentDate,


      @Search.defaultSearchElement: true
      @UI.lineItem   : [{ position:6, label:'G/L Account' }]
      GLAccount,

      @Semantics.amount.currencyCode: 'curr'
      @UI.lineItem   : [{ position:7, label:'Amount' }]
      AbsoluteAmountInCoCodeCrcy,
      CompanyCodeCurrency as curr,


      @Search.defaultSearchElement: true
      @UI.lineItem   : [{ position:8, label:'Supplier' }]
      Supplier,

      @Search.defaultSearchElement: true
      @UI.lineItem   : [{ position:9, label:'Clearing Date' }]
      ClearingDate,

      @Search.defaultSearchElement: true
      @UI.lineItem   : [{ position:10, label:'Clearing Journal Entry' }]
      ClearingJournalEntry,

      @Search.defaultSearchElement: true
      @UI.lineItem   : [{ position:11, label:'MIRO No.' }]
      OriginalReferenceDocument






}

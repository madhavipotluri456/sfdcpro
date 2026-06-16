public inherited sharing class InvoicePDFController {
    public Account targetAccount { get; private set; }
    public String generatedDate { get; private set; }

    public InvoicePDFController(ApexPages.StandardController stdController) {
        this.targetAccount = [SELECT Id, Name, AccountNumber, Rating, Industry, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id = :stdController.getId()];
        this.generatedDate = System.now().format('MMMM dd, yyyy');
    }
}

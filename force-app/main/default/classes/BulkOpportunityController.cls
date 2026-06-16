public inherited sharing class BulkOpportunityController {
    public List<Opportunity> recordList { get; set; }
    
    public BulkOpportunityController() {
        this.recordList = [SELECT Id, Name, StageName, Amount, CloseDate FROM Opportunity LIMIT 50];
    }

    public PageReference saveChanges() {
        Savepoint sp = Database.setSavepoint();
        try {
            update recordList;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Transaction Complete: All records bulk-updated safely.'));
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'DML Rollback Triggered: ' + ex.getMessage()));
        }
        return null;
    }
}

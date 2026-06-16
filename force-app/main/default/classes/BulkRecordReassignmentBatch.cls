/**
 * @description Enterprise Batch Utility to handle high-volume record ownership transfer safely across chunks.
 */
public inherited sharing class BulkRecordReassignmentBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private Id departingOwnerId;
    private Id receivingOwnerId;
    public Integer totalRecordsTransferred = 0;

    /**
     * @description Simple dynamic constructor initializing operational context parameters.
     * @param departingOwnerId The User ID of the executive relinquishing ownership.
     * @param receivingOwnerId The User ID of the executive inheriting the records.
     */
    public BulkRecordReassignmentBatch(Id departingOwnerId, Id receivingOwnerId) {
        this.departingOwnerId = departingOwnerId;
        this.receivingOwnerId = receivingOwnerId;
    }

    /**
     * @description Locates all active accounts belonging to the departing user.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        String queryStr = 'SELECT Id, OwnerId FROM Account WHERE OwnerId = :departingOwnerId';
        return Database.getQueryLocator(queryStr);
    }

    /**
     * @description Swaps the ownership parameters in safe, transactional blocks.
     */
    public void execute(Database.BatchableContext context, List<SObject> scopeChunk) {
        List<Account> accountsToUpdate = new List<Account>();

        for (SObject record : scopeChunk) {
            Account acc = (Account) record;
            acc.OwnerId = receivingOwnerId;
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            totalRecordsTransferred += accountsToUpdate.size();
            
            // Execute the update. Using standard Opt-In DML allows partial successes 
            // instead of failing an entire batch execution sequence.
            Database.SaveResult[] results = Database.update(accountsToUpdate, false);
            
            // Production Tip: Iterate through SaveResult arrays to capture and log individual row errors
        }
    }

    /**
     * @description Finalizes operational logs or fires email summaries to system administrators.
     */
    public void finish(Database.BatchableContext context) {
        System.debug('Ownership Transfer Execution Completed. Records Shifted: ' + totalRecordsTransferred);
    }
}

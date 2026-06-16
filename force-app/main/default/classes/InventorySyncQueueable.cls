/**
 * @description Handles the asynchronous heavy lifting of syncing altered records to an external API.
 */
public inherited sharing class InventorySyncQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> recordIdsToSync;

    public InventorySyncQueueable(List<Id> recordIdsToSync) {
        this.recordIdsToSync = recordIdsToSync;
    }

    public void execute(QueueContext context) {
        if (recordIdsToSync == null || recordIdsToSync.isEmpty()) {
            return;
        }

        // Fetch the modern values to send downstream
        List<Account> accounts = [SELECT Id, Name, AccountNumber, ShippingStreet FROM Account WHERE Id IN :recordIdsToSync];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:External_ERP_System/v1/inventory/sync');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(accounts));

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Enterprise requirement: Log errors to a custom debugging framework or platform event here
                System.debug('ERP Sync Failed: ' + response.getBody());
            }
        } catch (Exception ex) {
            System.debug('Network Callout Error: ' + ex.getMessage());
        }
    }
}

/**
 * @description Decodes inbound streaming CDC events and batches them out to the background worker.
 */
public inherited sharing class InventorySyncDispatcher {
    
    public static void parseAndRoute(List<AccountChangeEvent> events) {
        List<Id> recordIdsToProcess = new List<Id>();

        for (AccountChangeEvent event : events) {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            
            // Only capture mutations we actually care about (Create, Update, Undelete)
            if (header.changeType == 'CREATE' || header.changeType == 'UPDATE' || header.changeType == 'UNDELETE') {
                // CDC payloads contain an array of Record IDs because events can be compressed/batched together
                recordIdsToProcess.addAll(header.recordIds);
            }
        }

        // Guardrail checking: ensure we don't enqueue a background thread if there's no data
        if (!recordIdsToProcess.isEmpty()) {
            System.enqueueJob(new InventorySyncQueueable(recordIdsToProcess));
        }
    }
}

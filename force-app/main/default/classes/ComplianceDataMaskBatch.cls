/**
 * @description Dynamic, high-throughput Batch Engine designed to scrub and anonymize PII records.
 * Implements Database.Stateful to safely track metrics across large data chunk loops.
 */
public inherited sharing class ComplianceDataMaskBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private String targetSObjectName;
    private List<String> fieldsToMask;
    public Integer recordsProcessedCount = 0;

    /**
     * @description Simple dynamic constructor initialization layout.
     * @param targetSObjectName API Name of target entity (e.g., 'Lead')
     * @param fieldsToMask Collection of targeted field API strings (e.g., New List<String>{'Email', 'Phone'})
     */
    public ComplianceDataMaskBatch(String targetSObjectName, List<String> fieldsToMask) {
        this.targetSObjectName = targetSObjectName;
        this.fieldsToMask = fieldsToMask;
    }

    /**
     * @description Collects data securely by assembling a sanitized dynamic query locator string.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        // Build out field query paths ensuring Id is uniquely preserved
        String queryFields = 'Id';
        for (String field : fieldsToMask) {
            if (!field.equalsIgnoreCase('Id')) {
                queryFields += ', ' + String.escapeSingleQuotes(field.trim());
            }
        }
        
        String finalScrubQuery = 'SELECT ' + queryFields + ' FROM ' + String.escapeSingleQuotes(targetSObjectName);
        return Database.getQueryLocator(finalScrubQuery);
    }

    /**
     * @description Loops through chunks in bulk and dynamically masks targeted record string fields.
     */
    public void execute(Database.BatchableContext context, List<SObject> recordsChunk) {
        List<SObject> recordsToUpdate = new List<SObject>();

        for (SObject record : recordsChunk) {
            Boolean recordAltered = false;

            for (String fieldName : fieldsToMask) {
                fieldName = fieldName.trim();
                Object rawValue = record.get(fieldName);

                // Dynamically swap active strings out for safe, anonymous placeholders
                if (rawValue instanceof String) {
                    String stringVal = (String) rawValue;
                    if (String.isNotBlank(stringVal)) {
                        if (fieldName.toLowerCase().contains('email')) {
                            record.put(fieldName, 'masked_user_' + record.Id + '@compliance-vault.internal');
                        } else if (fieldName.toLowerCase().contains('phone')) {
                            record.put(fieldName, '000-000-0000');
                        } else {
                            record.put(fieldName, '[CONFIDENTIAL_REDACTED]');
                        }
                        recordAltered = true;
                    }
                }
            }

            if (recordAltered) {
                recordsToUpdate.add(record);
            }
        }

        if (!recordsToUpdate.isEmpty()) {
            recordsProcessedCount += recordsToUpdate.size();
            // Bypass standard validation rules if necessary using enterprise flags, or execute DML cleanly
            Database.update(recordsToUpdate, true);
        }
    }

    /**
     * @description Triggers follow-up logging or confirmation actions once data scrubbing wraps up.
     */
    public void finish(Database.BatchableContext context) {
        System.debug('Compliance Data Masking Complete. Records Processed Safely: ' + recordsProcessedCount);
    }
}

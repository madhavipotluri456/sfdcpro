/**
 * @description Architecture Engine providing dynamic, object-agnostic metadata describes and records.
 */
public inherited sharing class DynamicGridController {

    public class GridWrapper {
        @AuraEnabled public List<Map<String, String>> columns {get; set;}
        @AuraEnabled public List<SObject> records {get; set;}
        
        public GridWrapper(List<Map<String, String>> columns, List<SObject> records) {
            this.columns = columns;
            this.records = records;
        }
    }

    /**
     * @description Dynamically describes an object and queries fields based on a dynamic input blueprint.
     * @param sObjectName Technical API name (e.g., 'Contact', 'Opportunity')
     * @param fieldCSV Comma-separated field string (e.g., 'Name, Email, Phone')
     */
    @AuraEnabled(cacheable=true)
    public static GridWrapper getGridData(String sObjectName, String fieldCSV) {
        List<Map<String, String>> columns = new List<Map<String, String>>();
        List<String> fields = fieldCSV.split(',');
        
        // 1. Enforce strict platform metadata security access rules
        SObjectType targetType = Schema.getGlobalDescribe().get(sObjectName);
        if (targetType == null || !targetType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Access Denied or Invalid Object Schema.');
        }

        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        
        // 2. Build out dynamic column schema map arrays for LWC lightning-datatable
        for (String fieldName : fields) {
            fieldName = fieldName.trim();
            if (fieldMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                Map<String, String> column = new Map<String, String>();
                column.put('label', fieldDescribe.getLabel());
                column.put('fieldName', fieldDescribe.getName());
                column.put('type', String.valueOf(fieldDescribe.getType()).toLowerCase());
                column.put('sortable', 'true');
                columns.add(column);
            }
        }

        // 3. Formulate an injection-safe dynamic query execution line
        String cleanQuery = 'SELECT Id, ' + String.escapeSingleQuotes(fieldCSV) + ' FROM ' + String.escapeSingleQuotes(sObjectName) + ' LIMIT 500';
        List<SObject> records = Database.query(cleanQuery);

        return new GridWrapper(columns, records);
    }
}

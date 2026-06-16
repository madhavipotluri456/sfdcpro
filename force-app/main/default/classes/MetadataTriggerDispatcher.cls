/**
 * @description Dynamic Dispatcher Core that uses reflection to route trigger contexts 
 * based on administrative Custom Metadata configuration streams.
 */
public inherited sharing class MetadataTriggerDispatcher {

    /**
     * @description Inspects the active context, loads corresponding metadata, and executes logic.
     * @param sObjectName API name of the contextual object (e.g., 'Contact')
     * @param operationType System enum representing the exact runtime event step
     */
    public static void run(String sObjectName, System.TriggerOperation operationType) {
        // Enforce safe structural mapping strings for querying metadata
        String operationStr = String.valueOf(operationType);
        
        // 1. Simulation of Custom Metadata query loop:
        // In a real sandbox, you would query your record tracking configuration like this:
        // [SELECT Class_Name__c, Execution_Order__c FROM Trigger_Action__mdt 
        //  WHERE Object_API_Name__c = :sObjectName AND Active__c = true AND Event__c = :operationStr ORDER BY Execution_Order__c]
        
        // 2. Demonstration Example: Hardcoded metadata fallback simulation block 
        // to show how reflection resolves the string target cleanly to a real runtime class
        List<String> mockConfiguredClassNames = new List<String>();
        if (sObjectName == 'Contact') {
            mockConfiguredClassNames.add('ContactSanitizationHandler'); 
        }

        // 3. Reflection Execution Loop
        for (String className : mockConfiguredClassNames) {
            // Convert the text string directly into an executable Apex Type descriptor
            Type targetClassType = Type.forName(className);
            
            if (targetClassType != null) {
                // Instantiate the object variant dynamically using its zero-argument constructor
                Object instance = targetClassType.newInstance();
                
                // Securely cast the object instance to our known structural handler interface
                if (instance instanceof TriggerHandlerInterface) {
                    TriggerHandlerInterface handler = (TriggerHandlerInterface) instance;
                    
                    // Safely route the systemic context inputs straight into the business module
                    handler.execute(Trigger.new, Trigger.oldMap, operationType);
                }
            }
        }
    }
}

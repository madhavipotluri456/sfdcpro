/**
 * @description Enterprise Logging Architecture Engine to record and audit API outbound integration states.
 */
public inherited sharing class IntegrationLogger {

    /**
     * @description Formulates a log entry based on active HTTP callout parameters.
     * @param serviceName Name of the integration target (e.g., 'Stripe Payment', 'AWS Storage')
     * @param req The active outbound HttpRequest payload
     * @param res The returning inbound HttpResponse payload
     */
    public static void logCallout(String serviceName, HttpRequest req, HttpResponse res) {
        String logBody = '--- OUTBOUND REQUEST ---\n' +
                         'Endpoint: ' + req.getEndpoint() + '\n' +
                         'Method: ' + req.getMethod() + '\n' +
                         'Payload: ' + req.getBody() + '\n\n' +
                         '--- INBOUND RESPONSE ---\n' +
                         'Status Code: ' + res.getStatusCode() + '\n' +
                         'Status: ' + res.getStatus() + '\n' +
                         'Response Body: ' + res.getBody();

        saveLog(serviceName, logBody, res.getStatusCode() >= 400 ? 'Error' : 'Success');
    }

    /**
     * @description Overloaded logger method to capture systemic integration exceptions safely.
     */
    public static void logException(String serviceName, Exception ex) {
        String logBody = '--- EXCEPTION DETECTED ---\n' +
                         'Type: ' + ex.getTypeName() + '\n' +
                         'Message: ' + ex.getMessage() + '\n' +
                         'Stack Trace:\n' + ex.getStackTraceString();

        saveLog(serviceName, logBody, 'Fatal');
    }

    /**
     * @description Low-level persistence utility logic. 
     * In full production, this logs straight to a custom object (Integration_Log__c) 
     * or publishes an EventBus Platform Event to remain decoupled.
     */
    private static void saveLog(String serviceName, String logBody, String statusLevel) {
        // We output cleanly to System Debugging grids for this core portfolio layout
        System.debug('==================================================');
        System.debug('INTEGRATION LOG [' + statusLevel.toUpperCase() + '] FOR: ' + serviceName);
        System.debug(logBody);
        System.debug('==================================================');
        
        // Example operational DML block to preserve the record long-term:
        // Integration_Log__c log = new Integration_Log__c(
        //     Service_Name__c = serviceName,
        //     Payload_Details__c = logBody,
        //     Log_Status__c = statusLevel
        // );
        // insert log;
    }
}

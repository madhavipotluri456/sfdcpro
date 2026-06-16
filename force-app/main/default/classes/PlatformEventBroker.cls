/**
 * @description High-Scale Event Broker Engine that dynamic processes and decouples platform event handlers.
 */
public inherited sharing class PlatformEventBroker {

    /**
     * @description Orchestrated routing hub for incoming event payload arrays.
     * @param platformEventAPIName Technical API name of the event stream (e.g., 'Order_Event__e')
     * @param eventPayloads List of incoming event records passed out of the event trigger context
     */
    public static void broker(String platformEventAPIName, List<SObject> eventPayloads) {
        if (eventPayloads == null || eventPayloads.isEmpty()) {
            return;
        }

        // 1. Simulation of Custom Metadata lookup fetching classes subscribed to this event string
        List<String> registeredSubscriberClassNames = new List<String>();
        if (platformEventAPIName == 'Order_Event__e') {
            registeredSubscriberClassNames.add('OrderFinanceProvisioningHandler');
            registeredSubscriberClassNames.add('OrderSlackNotificationHandler');
        }

        // 2. High-Scale Resilient Processing Loop
        for (String className : registeredSubscriberClassNames) {
            try {
                // Instantiation via Apex Reflection
                Type handlerType = Type.forName(className);
                if (handlerType != null) {
                    Object handlerInstance = handlerType.newInstance();
                    
                    if (handlerInstance instanceof EventSubscriberInterface) {
                        EventSubscriberInterface subscriber = (EventSubscriberInterface) handlerInstance;
                        
                        // Fire the processing execution inside a isolated, safe silo block
                        subscriber.process(eventPayloads);
                    }
                }
            } catch (Exception ex) {
                // CRITICAL SAFETY GUARDRAIL: Log the exception to your Project 7 logger engine
                // but let the loop CONTINUE so other subscribers don't starve or crash out!
                System.debug('Broker Execution Failure on subscriber [' + className + ']: ' + ex.getMessage());
            }
        }
    }
}

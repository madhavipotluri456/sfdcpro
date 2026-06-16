/**
 * @description Subscription trigger routing high-scale events directly into the event broker framework.
 */
trigger OrderEventTrigger on AccountChangeEvent (after insert) {
    // Note: We are referencing AccountChangeEvent here as an architectural proxy 
    // so it saves cleanly without needing a custom __e object pre-provisioned in your org metadata.
    PlatformEventBroker.broker('Order_Event__e', Trigger.new);
}

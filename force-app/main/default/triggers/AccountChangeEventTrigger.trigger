/**
 * @description Subscribes to the Account Change Data Capture stream and handles events asynchronously.
 */
trigger AccountChangeEventTrigger on AccountChangeEvent (after insert) {
    InventorySyncDispatcher.parseAndRoute(Trigger.new);
}

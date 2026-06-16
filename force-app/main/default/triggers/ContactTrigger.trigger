/**
 * @description Agnostic Contact Trigger routing all structural context steps straight to the Metadata Engine.
 */
trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    MetadataTriggerDispatcher.run('Contact', Trigger.operationType);
}

/**
 * @description Contract Interface that all pluggable trigger business handlers must implement.
 */
public interface TriggerHandlerInterface {
    void execute(List<SObject> newRecords, Map<Id, SObject> oldMap, System.TriggerOperation operationType);
}

/**
 * @description Contract Interface for pluggable processing nodes subscribing to the Event Broker.
 */
public interface EventSubscriberInterface {
    void process(List<SObject> eventPayloads);
}

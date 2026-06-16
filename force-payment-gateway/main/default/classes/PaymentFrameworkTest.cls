@isTest
private class PaymentFrameworkTest {

    @isTest
    static void testStripeAdapterSuccess() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentAdapterMock(true));

        Test.startTest();
        Map<String, Object> result = PaymentProcessingService.process('StripePaymentAdapter', 10.00, 'USD');
        Test.stopTest();

        System.assertEquals('Success', result.get('status'), 'The transaction should have succeeded.');
        System.assertEquals('ch_mock_12345', result.get('transactionId'), 'The transaction ID should match the mock payload.');
    }

    @isTest
    static void testStripeAdapterFailure() {
        Test.setMock(HttpCalloutMock.class, new StripePaymentAdapterMock(false));

        Test.startTest();
        Map<String, Object> result = PaymentProcessingService.process('StripePaymentAdapter', 10.00, 'USD');
        Test.stopTest();

        System.assertEquals('Failed', result.get('status'), 'The transaction framework should capture the failure gracefully.');
        System.assert(((String)result.get('errorMessage')).contains('Gateway Error'), 'The error message should wrap the gateway response.');
    }

    @isTest
    static void testInvalidClassReflection() {
        try {
            PaymentProcessingService.process('NonExistentPaymentAdapter', 10.00, 'USD');
            System.assert(false, 'An exception should have been thrown for an invalid class definition.');
        } catch (AuraHandledException ex) {
            System.assert(true, 'Caught expected runtime exception.');
        }
    }
}

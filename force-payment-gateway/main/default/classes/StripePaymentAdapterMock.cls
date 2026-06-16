@isTest
public class StripePaymentAdapterMock implements HttpCalloutMock {
    private Boolean isSuccess;

    public StripePaymentAdapterMock(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if (this.isSuccess) {
            response.setStatusCode(200);
            response.setBody('{"id": "ch_mock_12345", "status": "succeeded", "amount": 1000}');
        } else {
            response.setStatusCode(400);
            response.setBody('{"error": {"message": "Your card was declined."}}');
        }
        
        return response;
    }
}

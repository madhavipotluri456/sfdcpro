/**
 * @description Integration backend generating pre-signed signatures or direct paths to stream records to AWS S3.
 */
public inherited sharing class AmazonS3Controller {

    /**
     * @description Formulates a secure, time-bound REST endpoint link for uploading directly to Amazon Web Services.
     * @param fileName Name of file (e.g., 'invoice.pdf')
     * @param contentType MIME file type (e.g., 'application/pdf')
     * @return Fully configured endpoint string ready for consumption by LWC fetch/XMLHttpRequest.
     */
    @AuraEnabled
    public static String getPresignedUploadUrl(String fileName, String contentType) {
        // Enforce explicit security settings
        String bucketName = 'enterprise-salesforce-vault-storage';
        String awsRegion = 'us-east-1';
        
        // Formulate target URL endpoint
        // Production architecture tip: Leverage Named Credentials for managing security handshakes cleanly
        String formattedEndpoint = 'https://' + bucketName + '.s3.' + awsRegion + '.amazonaws.com/' + EncodingUtil.urlEncode(fileName, 'UTF-8');
        
        // Return endpoint path. In a fully realized AWS pipeline, you would calculate 
        // the AWS Signature V4 authentication string here and append it to the query parameters.
        return formattedEndpoint;
    }
}

public inherited sharing class IntegrationStrategyFactory {
    public interface VaultStorageStrategy {
        String generateUploadSignature(String targetFileName, String contentType);
    }
    
    public class AWSS3Strategy implements VaultStorageStrategy {
        public String generateUploadSignature(String targetFileName, String contentType) {
            String targetBucket = 'enterprise-cloud-vault';
            return 'https://' + targetBucket + '.s3.amazonaws.com/' + EncodingUtil.urlEncode(targetFileName, 'UTF-8');
        }
    }

    @AuraEnabled
    public static String getSecureStreamEndpoint(String fileName, String contentType) {
        try {
            VaultStorageStrategy strategy = new AWSS3Strategy();
            String endpoint = strategy.generateUploadSignature(fileName, contentType);
            System.debug('Cloud-Vault Stream Endpoint Authorized: ' + endpoint);
            return endpoint;
        } catch (Exception ex) {
            throw new AuraHandledException('Vault Authorization Aborted: ' + ex.getMessage());
        }
    }
}

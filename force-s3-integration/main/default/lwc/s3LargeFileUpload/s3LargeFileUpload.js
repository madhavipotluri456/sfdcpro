import { LightningElement, api, track } from 'lwc';
import getPresignedUploadUrl from '@salesforce/apex/AmazonS3Controller.getPresignedUploadUrl';

export default class S3LargeFileUpload extends LightningElement {
    @api recordId; // Captures current record page context implicitly
    @track uploadStatusMessage = '';
    
    selectedFile;

    handleFileSelection(event) {
        if (event.target.files.length > 0) {
            this.selectedFile = event.target.files[0];
            this.uploadStatusMessage = `Ready to stream: ${this.selectedFile.name}`;
        }
    }

    async handleUploadExecute() {
        if (!this.selectedFile) {
            this.uploadStatusMessage = 'Error: Please choose a valid file matrix first.';
            return;
        }

        this.uploadStatusMessage = 'Requesting secure AWS Pre-signed signature wrapper...';

        try {
            // 1. Fetch authenticated transaction endpoint from Apex controller
            const s3UploadUrl = await getPresignedUploadUrl({
                fileName: this.selectedFile.name,
                contentType: this.selectedFile.type
            });

            this.uploadStatusMessage = 'Streaming file data chunks straight to AWS S3...';

            // 2. Fire direct HTTP PUT fetch callout directly from browser to save Salesforce cloud space
            const response = await fetch(s3UploadUrl, {
                method: 'PUT',
                headers: {
                    'Content-Type': this.selectedFile.type
                },
                body: this.selectedFile
            });

            if (response.ok) {
                this.uploadStatusMessage = 'Success! File bypass stream to AWS complete.';
            } else {
                this.uploadStatusMessage = `Upload failed with HTTP status code: ${response.status}`;
            }
        } catch (error) {
            console.error('S3 Upload Transactional Exception:', error);
            this.uploadStatusMessage = `Fatal Error: ${error.message}`;
        }
    }
}

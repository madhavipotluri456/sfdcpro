import { LightningElement, api, track } from 'lwc';
import getSecureStreamEndpoint from '@salesforce/apex/IntegrationStrategyFactory.getSecureStreamEndpoint';

export default class CloudVaultStreamer extends LightningElement {
    @track systemStatus = 'Awaiting File Telemetry Matrix...';
    localActiveFile;

    handleFileCapture(event) {
        if (event.target.files.length > 0) {
            this.localActiveFile = event.target.files[0];
            this.systemStatus = `Asset Staged: ${this.localActiveFile.name}`;
        }
    }

    async executeBypassStream() {
        if (!this.localActiveFile) return;
        this.systemStatus = 'Generating Strategy Signature via Apex Factory...';
        try {
            const uploadUrl = await getSecureStreamEndpoint({
                fileName: this.localActiveFile.name,
                contentType: this.localActiveFile.type
            });
            this.systemStatus = 'Bypassing Salesforce Cloud Storage... Streaming to AWS S3...';
            const response = await fetch(uploadUrl, {
                method: 'PUT',
                headers: { 'Content-Type': this.localActiveFile.type },
                body: this.localActiveFile
            });
            this.systemStatus = response.ok ? 'Transaction Vault Stream Success!' : `Error: ${response.status}`;
        } catch (error) {
            this.systemStatus = `Fatal Bridge Crash: ${error.message}`;
        }
    }
}

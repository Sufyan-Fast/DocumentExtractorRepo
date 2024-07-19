import { LightningElement, api, track } from 'lwc';



export default class ScreenFlowRichText extends LightningElement {
    @api fieldValue = " ";
    @api fieldLabel;
    @api required;
    @api fieldLength;
    @api visibleLines;
    @api recordId;
    @api validity;
    @track documentId;
    @api attachFile;
    @api attachName;
    @api url;
    files = [];

    allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'clean',
        'table',
        'header',
        'color',
        'background',
        'code',
        'code-block',
        'script',
        'blockquote',
        'direction',
    ];

    connectedCallback() {
        this.validity = true;
        document.documentElement.style.setProperty('--rta-visiblelines', (this.visibleLines * 2) + 'em');
    }

    handleChange(event) {
        if ((event.target.value).length > this.fieldLength) {
            this.validity = false;
            this.errorMessage = "You have exceeded the max length";
        }
        else {
            this.validity = true;
            this.fieldValue = event.target.value;
        }
    }




    handleUploadFinished(event) {
        this.files = event.target.files;
        let attachmentNames = [];
        let base64DataList = [];

        // Prepare attachments
        for (let i = 0; i < this.files.length; i++) {
            attachmentNames.push(this.files[i].name);
            let reader = new FileReader();
            reader.onload = () => {
                let base64 = reader.result.split(',')[1];
                base64DataList.push(base64);

                // Check if all attachments are processed
                if (base64DataList.length === this.files.length) {
                    this.attachFile = base64DataList;
                    this.attachName = attachmentNames;
                    ;
            
                }
            };
            reader.readAsDataURL(this.files[i]); // Read each file as DataURL
        }
    }


    
}
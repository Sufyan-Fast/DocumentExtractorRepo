public with sharing class CB_DownloadStubController {
    // Variables to store SharePoint file URL and error message
    public String url { get; set; }
    public String error { get; set; }
    
    // Constructor
    public CB_DownloadStubController() {
        // Initialize variables
        url = '';
        error = '';
    }
    
    // Method to retrieve SharePoint file URL
    public PageReference populateUrl() {
        String requestUrl = ApexPages.currentPage().getUrl();
        
        // Check if the request URL has a file extension
        if (requestUrl.contains('.') && !requestUrl.endsWith('/')) {
            // Redirect to your Visualforce page if the request has a file extension
            return new PageReference('/apex/cb_downloadStub');
        } else {
            // Placeholder logic to retrieve SharePoint file URL
            // Replace this with your actual logic to fetch the SharePoint file URL
            // For demonstration purposes, I'm just setting a sample URL
            String sharepointUrl = 'https://mytelespecialists.sharepoint.com/:b:/r/sites/Test2SalesforceIntegration/Documents/Providers/Donald%20Lee/Muhammad%20Ghous%20Resume%20(1).pdf?csf=1&web=1&e=QSmcDG';
            return new PageReference(sharepointUrl);
        }
    }
}
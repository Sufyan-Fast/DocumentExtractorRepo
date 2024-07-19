public class H_Privilige_ApplicationDelConroller {
    public Hospital_Affiliation__c HAFtoDelete;
    public Boolean showDialog { get; set; }
    public Boolean showInitialDialog { get; set; }
    private Boolean hasPermission { get; set; }

    // Constructor to initialize the HAFtoDelete variable
    public H_Privilige_ApplicationDelConroller(ApexPages.StandardController controller) {
        this.HAFtoDelete = (Hospital_Affiliation__c)controller.getRecord();
        this.showDialog = false;
        this.showInitialDialog = true; // Initially show the first dialog
        this.hasPermission = false;
        System.debug('Hospital Affiliation ID: ' + HAFtoDelete.Id);
    }

    // Method to check Permission Set
    private Boolean hasPermissionSet(String permissionSetName) {
        try {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
            System.debug('Permission set found!');
            return [SELECT count() FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId = :UserInfo.getUserId()] > 0;
        } catch (QueryException e) {
            System.debug('Error occurred while querying Permission Set: ' + e.getMessage());
            return false;
        }
    }

    // Method to check permission and redirect
    public PageReference checkPermissionAndRedirect() {
        this.hasPermission = hasPermissionSet('Credentialing_Add_New_Credentialing_Entities');
        return null;
    }

    // Method to confirm the initial deletion prompt
    public PageReference confirmInitialDelete() {
        if (hasPermission) {
            showInitialDialog = false;
            showDialog = true; // Show the next confirmation dialog
        } else {
            delete HAFtoDelete;
            System.debug('Deleted current record without additional permissions');
            PageReference pg = new PageReference('/a2g');
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }

    // Method to confirm the account deletion and related HAP records
    public PageReference confirmDelete() {
        if (showDialog) {
            List<Hospital_Privilege_Application__c> RelatedAffiliationRecord = [SELECT Id FROM Hospital_Privilege_Application__c WHERE Hospital_Affiliation__c = :HAFtoDelete.Id];
            System.debug('Privilige Application Record ' + RelatedAffiliationRecord);
            if (RelatedAffiliationRecord.size() > 0) {
                delete RelatedAffiliationRecord;    
            }
        }
        delete HAFtoDelete;   
        System.debug('Inside Confirm Delete: Both HAF/HAP');

        PageReference pg = new PageReference('/a2g');
        pg.setRedirect(true);
        return pg;
    }

    	public PageReference cancelDelete() {
        System.debug('Inside Cancel Delete');
        PageReference pg = new PageReference('/' + HAFtoDelete.Id);
        pg.setRedirect(true);
        return pg;
    }

    // Method to delete only the current record (when the user clicks No in the second dialog)
    public PageReference deleteOnlyCurrent() {
        delete HAFtoDelete;
        System.debug('Deleted only current record');

        PageReference pg = new PageReference('/a2g');
        pg.setRedirect(true);
        return pg;
    }
}
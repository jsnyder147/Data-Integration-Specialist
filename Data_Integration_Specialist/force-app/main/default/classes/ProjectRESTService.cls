@RestResource(urlMapping='/project/*')
global class ProjectRESTService {
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status) {
        List<Project__c> projectList = [SELECT Id FROM Project__c WHERE Name=:ProjectName];
        Project__c project = new Project__c();
        if(projectList.size() > 0) {
            project = projectList.get(0);
        }
        Savepoint sp = Database.setSavepoint();
        try { 
            project.ProjectRef__c = ProjectRef;
            project.Name = ProjectName;
            project.Opportunity__c = OpportunityId;
            project.Start_Date__c = StartDate;
            project.End_Date__c = EndDate;
            project.Billable_Amount__c = Amount;
            project.Status__c = Status;

            upsert project;

            updateOpp(OpportunityId);
            
            return 'OK';
        }
        catch(Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        }
    }

    private static void updateOpp(String oppId) {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: oppId];
        opp.DeliveryInstallationStatus__c = 'In Progress';
        update opp;
    }
}
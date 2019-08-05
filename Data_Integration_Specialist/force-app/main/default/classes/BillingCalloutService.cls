public class BillingCalloutService {
    public static void callBillingService(List<Project__c> oldProjectList, List<Project__c> newProjectList) {
        Project__c oldProject = oldProjectList.get(0);
        Project__c newProject = newProjectList.get(0);
        if(oldProject.Status__c != 'Billable' && newProject.Status__c == 'Billable') {
            callTheService(newProject.ProjectRef__c, newProject.Billable_Amount__c);
        }
    }

    @future (callout=true)
    private static void callTheService(String ProjectRef, Decimal BillingAmount) {
        BillingServiceProxy.project project = new BillingServiceProxy.project();
        project.projectid = projectRef;
        project.billAmount = BillingAmount;
        project.username = ServiceCredentials__c.getValues('BillingServiceCredential').Username__c;
        project.password = ServiceCredentials__c.getValues('BillingServiceCredential').Password__c;
        BillingServiceProxy.InvoicesPortSoap11 invoiceCall = new BillingServiceProxy.InvoicesPortSoap11();
        String response = invoiceCall.billProject(project);
    }
}
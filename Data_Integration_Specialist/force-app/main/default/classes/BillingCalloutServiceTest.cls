@isTest
private class BillingCalloutServiceTest {
	@TestSetup
	static void makeData(){
		Account acc = new Account();
        acc.Name = 'Test Acc 1';
        insert acc;

        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test Opp 1';
        opp1.Type = 'New Project';
        opp1.Amount = 1000;
        opp1.CloseDate = Date.today();
        opp1.StageName = 'Submitted Project';
        insert opp1;

		Project__c oldProject = new Project__c();
		oldProject.Name = 'oldProject';
		oldProject.Opportunity__c = opp1.Id;
		oldProject.ProjectRef__c = 'abcdefg';
		oldProject.Status__c = 'Running';
		oldProject.Start_Date__c = Date.today();
		oldProject.Billable_Amount__c = 10000.20;
		oldProject.End_Date__c = Date.today().addMonths(1);
		insert oldProject;

		Project__c newProject = new Project__c();
		newProject.Name = 'newProject';
		newProject.Opportunity__c = opp1.Id;
		newProject.ProjectRef__c = 'abcdefg123';
		newProject.Status__c = 'Billable';
		newProject.Start_Date__c = Date.today();
		newProject.Billable_Amount__c = 10000.20;
		newProject.End_Date__c = Date.today().addMonths(1);
		insert newProject;

		ServiceCredentials__c BillingServiceCredential = new ServiceCredentials__c();
		BillingServiceCredential.Name = 'BillingServiceCredential';
		BillingServiceCredential.Username__c = 'username';
		BillingServiceCredential.Password__c = 'password';
        insert BillingServiceCredential;
	}	
	@isTest 
	static void testSucessfulCall() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
		List<Project__c> oldProjectList = [SELECT Id, Name, ProjectRef__c, Status__c, Billable_Amount__c FROM Project__c WHERE Name=:'oldProject'];
		List<Project__c> newProjectList = [SELECT Id, Name, ProjectRef__c, Status__c, Billable_Amount__c FROM Project__c WHERE Name=:'newProject'];
		Test.startTest();
			BillingCalloutService.callBillingService(oldProjectList,newProjectList);
		Test.stopTest();
		Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name=:'newProject'];
		system.assertEquals('Billed', project.Status__c);
	}
	@isTest 
	static void testFailedCall() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
		List<Project__c> oldProjectList = [SELECT Id, Name, ProjectRef__c, Status__c, Billable_Amount__c FROM Project__c WHERE Name=:'oldProject'];
		List<Project__c> newProjectList = [SELECT Id, Name, ProjectRef__c, Status__c, Billable_Amount__c FROM Project__c WHERE Name=:'newProject'];
		Test.startTest();
			BillingCalloutService.callBillingService(oldProjectList,newProjectList);
		Test.stopTest();
		Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name=:'newProject'];
		system.assertNotEquals('Billed', project.Status__c);
	}
}
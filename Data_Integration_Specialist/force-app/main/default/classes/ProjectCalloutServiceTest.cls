@isTest
private class ProjectCalloutServiceTest {
    @testSetup 
    static void setupTestData(){
		// Create the opportunity record
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
		// Create the opportunity record
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp 2';
        opp2.Type = 'New Project';
        opp2.Amount = 2000;
        opp2.CloseDate = Date.today();
        opp2.StageName = 'Resubmit Project';
        insert opp2;
        // Create the Custom Settings
        ServiceTokens__c servToken = new ServiceTokens__c();
        servToken.Name = 'ProjectServiceToken';
        servToken.Token__c = 'abcd1234efgh5678';
        insert servToken;
    }

    @isTest
    static void testSuccess() {
        test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test Opp 1' LIMIT 1];
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(oppty.Id);
        Test.startTest();
        ProjectCalloutService.postOpportunityToPMS(oppIdList);
        Test.stopTest();
        oppty = [SELECT StageName from Opportunity WHERE StageName='Submitted Project'];
        System.assertEquals('Submitted Project',oppty.StageName);
    }

    @isTest
    static void testFailure() {
        test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name ='Test Opp 2' LIMIT 1];
        List<Id> oppIdList = new List<Id>();
        oppIdList.add(oppty.Id);
        Test.startTest();
        ProjectCalloutService.postOpportunityToPMS(oppIdList);
        Test.stopTest();
        oppty = [SELECT StageName from Opportunity WHERE StageName='Resubmit Project'];
        System.assertEquals('Resubmit Project',oppty.StageName);
    }
}
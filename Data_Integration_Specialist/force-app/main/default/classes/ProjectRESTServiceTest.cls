@isTest
private class ProjectRESTServiceTest {
	@TestSetup
	static void makeData(){
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
	}

	@isTest
	static void testSuccessfulPost() {

		RestRequest request = new RestRequest();

		request.requestUri = '/services/apexrest/project/';
		request.httpMethod = 'Post';

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

		RestContext.request = request;
		String response = ProjectRESTService.postProjectData('refTest', 'Test Project1', opp.Id, Date.today(), Date.today().addMonths(1), 200, 'Running');
		System.assertEquals('OK', response);
	}

	@isTest
	static void testFailedPost() {

		RestRequest request = new RestRequest();

		request.requestUri = '/services/apexrest/project/';
		request.httpMethod = 'Post';

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

		RestContext.request = request;
		String response = ProjectRESTService.postProjectData('refTest', 'Test Project1', opp.Id, Date.today(), Date.today().addMonths(1), 200, 'Nothing');
		System.assertNotEquals('OK', response);
	}
}
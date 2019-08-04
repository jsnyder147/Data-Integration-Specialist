public class ProjectCalloutService {
    // Complete the implementation for business and callout logic
	@InvocableMethod
	public static void postOpportunityToPMS(List<Id> oppId){
		Opportunity opportunity = [SELECT Id,Name,Account.Name,CloseDate,Amount FROM Opportunity WHERE Id = :oppId[0]];
        String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
            generator.writeStringField('opportunityId', opportunity.Id);
            generator.writeStringField('opportunityName', opportunity.Name);
            generator.writeStringField('accountName', opportunity.Account.Name);
            generator.writeDateField('closeDate',opportunity.CloseDate);
            generator.writeNumberField('amoun', opportunity.Amount);
        generator.writeEndObject();
        String jsonInput = generator.getAsString();

		System.enqueueJob(new QueueablePMSCall(serviceToken, jsonInput, opportunity.Id));
    }
    
    // Future method to make apex callout
    @Future(callout=true)
    private static void postToPMS(String serviceToken, String jsonInput, Id oppoId) {
        HTTPRequest req = new HTTPRequest();
        req.setEndPoint('callout:ProjectService');
        req.setMethod('POST');
        req.setHeader('token',serviceToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');        
        req.setBody(jsonInput);
        HTTP http = new HTTP();
        HTTPResponse res = http.send(req);
        Opportunity opp = new Opportunity(Id=oppoId);
        if(res.getStatusCode() != 201){
            opp.StageName = 'Resubmit Project';
            System.debug('Failure: ' + res.getStatusCode() + ' ' + res.getStatus());
        } else {
            opp.StageName = 'Submitted Project';                
            System.debug('Success: ' + res.getStatus());
        }
        update opp;
    }
    
    // Queueable class to enque the post request
    class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts {
        private String serviceToken;
        private String jsonInput;
        private String Id;
        public QueueablePMSCall(String serviceToken, String jsonInput, Id oppoId){
            this.serviceToken = serviceToken;
            this.jsonInput = jsonInput;
            this.Id = oppoId;
        }
        public void execute(QueueableContext context) {
            postToPMS(serviceToken, jsonInput, Id);
        }
    }
    
}
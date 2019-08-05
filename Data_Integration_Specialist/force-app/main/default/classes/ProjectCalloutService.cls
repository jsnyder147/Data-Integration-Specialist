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
            if(opportunity.Account.Name != null) {
                generator.writeStringField('accountName', opportunity.Account.Name);
            }
            else {
                 generator.writeNullField('accountName');
            }
            generator.writeDateField('closeDate',opportunity.CloseDate);
            generator.writeNumberField('amoun', opportunity.Amount);
        generator.writeEndObject();
        String jsonInput = generator.getAsString();

		System.enqueueJob(new QueueablePMSCall(serviceToken, jsonInput, opportunity.Id));
    }
    
    // Future method to make apex callout
    @Future(callout=true)
    private static void postToPMS(String serviceToken, String jsonInput, Id oppId) {
        HTTPRequest request = new HTTPRequest();
        request.setEndPoint('callout:ProjectService');
        request.setMethod('POST');
        request.setHeader('token',serviceToken);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');        
        request.setBody(jsonInput);
        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        Opportunity opp = new Opportunity(Id=oppId);
        if(response.getStatusCode() != 201){
            opp.StageName = 'Resubmit Project';
            System.debug('Failure: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            opp.StageName = 'Submitted Project';    
            system.debug('response: ' + response);        
            System.debug('Success: ' + response.getStatus());
        }
        update opp;
    }
    
    // Queueable class to enque the post request
    class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts {
        private String serviceToken;
        private String jsonInput;
        private String Id;
        public QueueablePMSCall(String serviceToken, String jsonInput, Id oppId){
            this.serviceToken = serviceToken;
            this.jsonInput = jsonInput;
            this.Id = oppId;
        }
        public void execute(QueueableContext context) {
            postToPMS(serviceToken, jsonInput, Id);
        }
    }
    
}
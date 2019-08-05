@isTest
global class BillingCalloutServiceMock implements WebServiceMock {

	global void doInvoke(
		Object stub,
		Object request,
		Map<String, Object> response,
		String endpoint,
		String soapAction,
		String requestName,
		String responseNS,
		String responseName,
		String responseType) {
		// start - specify the response you want to send
		BillingServiceProxy.billProjectResponse_element responseElement = 
			new BillingServiceProxy.billProjectResponse_element();
		responseElement.Status = 'OK';
		// end
		response.put('response_x', responseElement); 
	}
}
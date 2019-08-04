global class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   global HTTPResponse respond(HTTPRequest request) {
      // Create a fake response
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatus('Not Created');
      response.setStatusCode(400);
      return response; 
   }
}
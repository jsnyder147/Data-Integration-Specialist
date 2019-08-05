global class ProjectCalloutServiceMock implements HttpCalloutMock{
   global HTTPResponse respond(HTTPRequest request) {
      // Create a fake response
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatus('Created');
      response.setStatusCode(201);
      return response; 
   }
}
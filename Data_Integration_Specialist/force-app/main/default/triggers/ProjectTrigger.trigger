trigger ProjectTrigger on Project__c (after update) {
   if(Trigger.isAfter) {
       if(Trigger.isUpdate) {
           BillingCalloutService.callBillingService(Trigger.old, Trigger.new);
       }
   }
}
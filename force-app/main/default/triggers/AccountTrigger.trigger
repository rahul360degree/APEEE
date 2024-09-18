trigger AccountTrigger on Account  (before delete, before insert, before update, after delete, after insert, after undelete, after update) 
{
    fflib_SObjectDomain.triggerHandler(Accounts.class);
}
({
	    doInit: function(component, event, helper) {
        let recordId = component.get("v.recordId");
        console.log('recordId---'+recordId);
        let redirect = $A.get("e.force:navigateToSObject");
        redirect.setParams({
            "recordId": recordId
        });
        
        redirect.fire();
    }
})
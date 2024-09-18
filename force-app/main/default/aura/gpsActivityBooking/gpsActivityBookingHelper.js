({
    getActivityListView : function(component, event, helper) {
        let options = [];
        var action = component.get("c.getGPSMetadata");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                returnValue.forEach(element =>
                                    options.push({label: element.Label, value: element.DeveloperName,objectApiName : element.ObjectName__c})
                                   )
                console.log('options:::'+options);
                component.set("v.listViewOptions",options);
                component.set("v.objectApiName",options[0].objectApiName);
                component.set("v.listName",options[0].value);
                component.set("v.selectedValue",options[0].value);
                component.set("v.isShowListView", true);
                console.log('options:::',options);
            }
        });
        $A.enqueueAction(action);
    }
})
({
    doInit : function(component, event, helper) {
        helper.getActivityListView(component, event, helper); 
    },
    handleChange : function (component, event, helper){
        let selectedOptionValue = event.getParam("value");
        let listViewOptions = component.get("v.listViewOptions");
        let selectedListView = listViewOptions.find(res => {
            return res.value === selectedOptionValue
        });
        console.log('selectedListView::'+JSON.stringify(selectedListView));
        component.set("v.objectApiName",selectedListView.objectApiName);
        component.set("v.listName",selectedListView.value);
        component.set("v.isShowListView", false);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.isShowListView", true);
            }), 200
        );
    }
})
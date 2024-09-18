({
    doinit : function(component, event, helper) {   
        var test = component.get('v.cssClasses');
        console.log('test 000 ' + test);
        // if(test == 'cHeaderPanel'){
        //     var css = this.template.host.style;
        //     css.setProperty('--displayHeader','none');
        //     console.log('css -- ' + JSON.stringify(css));
        // }
    }
})
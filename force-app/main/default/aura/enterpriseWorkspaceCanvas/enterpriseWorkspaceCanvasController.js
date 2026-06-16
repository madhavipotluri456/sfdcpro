({
    doInit : function(component, event, helper) {
        // Load default structural framework state on initial browser render loop
        helper.injectDynamicComponent(component, "lightning:badge", {
            "label": "Workspace Initialization Sequenced Successfully",
            "class": "slds-theme_success"
        });
    },

    handleLoadAccountGrid : function(component, event, helper) {
        component.set("v.currentViewName", "Global Accounts Matrix");
        // Target an existing standard LWC grid or custom Aura element dynamically 
        helper.injectDynamicComponent(component, "c:dynamicDataGrid", {
            "objectApiName": "Account",
            "fieldsToDisplay": "Name, Industry, AnnualRevenue, Rating"
        });
    },

    handleLoadDiagnostics : function(component, event, helper) {
        component.set("v.currentViewName", "System Outbound Ledger Audits");
        // Inject different data context mapping strings entirely
        helper.injectDynamicComponent(component, "c:dynamicDataGrid", {
            "objectApiName": "Contact",
            "fieldsToDisplay": "FirstName, LastName, Email, Title"
        });
    }
})

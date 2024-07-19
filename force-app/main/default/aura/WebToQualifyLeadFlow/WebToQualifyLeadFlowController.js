({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("QualifyflowData");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Quarterly_Lead");
    }
})
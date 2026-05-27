sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'managerdashboard',
            componentId: 'ExpenseItemsObjectPage',
            contextPath: '/ManagerDashboard/items'
        },
        CustomPageDefinitions
    );
});
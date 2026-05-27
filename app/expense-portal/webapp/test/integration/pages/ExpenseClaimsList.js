sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'expense.portal.expenseportal',
            componentId: 'ExpenseClaimsList',
            contextPath: '/ExpenseClaims'
        },
        CustomPageDefinitions
    );
});
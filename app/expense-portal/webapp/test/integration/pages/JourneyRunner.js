sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"expense/portal/expenseportal/test/integration/pages/ExpenseClaimsList",
	"expense/portal/expenseportal/test/integration/pages/ExpenseClaimsObjectPage",
	"expense/portal/expenseportal/test/integration/pages/ExpenseItemsObjectPage"
], function (JourneyRunner, ExpenseClaimsList, ExpenseClaimsObjectPage, ExpenseItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('expense/portal/expenseportal') + '/test/flp.html#app-preview',
        pages: {
			onTheExpenseClaimsList: ExpenseClaimsList,
			onTheExpenseClaimsObjectPage: ExpenseClaimsObjectPage,
			onTheExpenseItemsObjectPage: ExpenseItemsObjectPage
        },
        async: true
    });

    return runner;
});


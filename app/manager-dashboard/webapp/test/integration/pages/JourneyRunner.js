sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"managerdashboard/test/integration/pages/ManagerDashboardList",
	"managerdashboard/test/integration/pages/ManagerDashboardObjectPage",
	"managerdashboard/test/integration/pages/ExpenseItemsObjectPage"
], function (JourneyRunner, ManagerDashboardList, ManagerDashboardObjectPage, ExpenseItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('managerdashboard') + '/test/flp.html#app-preview',
        pages: {
			onTheManagerDashboardList: ManagerDashboardList,
			onTheManagerDashboardObjectPage: ManagerDashboardObjectPage,
			onTheExpenseItemsObjectPage: ExpenseItemsObjectPage
        },
        async: true
    });

    return runner;
});


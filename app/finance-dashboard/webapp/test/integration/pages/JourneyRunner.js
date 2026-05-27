sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"financedashboard/test/integration/pages/FinanceDashboardList",
	"financedashboard/test/integration/pages/FinanceDashboardObjectPage"
], function (JourneyRunner, FinanceDashboardList, FinanceDashboardObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('financedashboard') + '/test/flp.html#app-preview',
        pages: {
			onTheFinanceDashboardList: FinanceDashboardList,
			onTheFinanceDashboardObjectPage: FinanceDashboardObjectPage
        },
        async: true
    });

    return runner;
});


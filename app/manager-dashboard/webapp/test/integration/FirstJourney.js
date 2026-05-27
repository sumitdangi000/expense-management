sap.ui.define([
    "sap/ui/test/opaQunit",
    "./pages/JourneyRunner"
], function (opaTest, runner) {
    "use strict";

    function journey() {
        QUnit.module("First journey");

        opaTest("Start application", function (Given, When, Then) {
            Given.iStartMyApp();

            Then.onTheManagerDashboardList.iSeeThisPage();
            Then.onTheManagerDashboardList.onFilterBar().iCheckFilterField("Status");
            Then.onTheManagerDashboardList.onFilterBar().iCheckFilterField("Category");
            Then.onTheManagerDashboardList.onFilterBar().iCheckFilterField("Policy Violation");
            Then.onTheManagerDashboardList.onTable().iCheckColumns(5, {"claimDate":{"header":"Claim Date"},"tripPurpose":{"header":"Purpose"},"totalAmount":{"header":"Total Amount"},"status":{"header":"Status"},"policyViolation":{"header":"Policy Violation"}});

        });


        opaTest("Navigate to ObjectPage", function (Given, When, Then) {
            // Note: this test will fail if the ListReport page doesn't show any data
            
            When.onTheManagerDashboardList.onFilterBar().iExecuteSearch();
            
            Then.onTheManagerDashboardList.onTable().iCheckRows();

            When.onTheManagerDashboardList.onTable().iPressRow(0);
            Then.onTheManagerDashboardObjectPage.iSeeThisPage();

        });

        opaTest("Teardown", function (Given, When, Then) { 
            // Cleanup
            Given.iTearDownMyApp();
        });
    }

    runner.run([journey]);
});
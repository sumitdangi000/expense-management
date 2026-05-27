// // ============================================================
// // FILE: app/finance-dashboard/annotations.cds
// //
// // PURPOSE : Fiori Analytical List Page (ALP) for Finance Dashboard
// //           - KPI Tags (Pending Reimbursements, Policy Violations,
// //             Monthly Spend, Avg Processing Days)
// //           - Visual Filter Charts (Category Donut, Monthly Trend Line,
// //             Status Bar)
// //           - List Report LineItem with criticality + actions
// //           - Object Page header KPIs + facets
// //
// // REQUIRES: ExpenseClaims entity must expose these *aggregatable* properties
// //           via the service (see srv/expense-service.cds below).
// //           Virtual field `criticality : Integer` must be computed
// //           in the service handler (see bottom of this file).
// // ============================================================

// using ExpenseService as service from '../../srv/expense-service';

// // ============================================================
// // 0. COMMON LABELS  –  reused across all pages
// // ============================================================

// annotate service.ExpenseClaims with {
//     ID               @title : 'Claim ID';
//     claimDate        @title : 'Claim Date';
//     tripPurpose      @title : 'Purpose';
//     totalAmount      @title : 'Total Amount'    @Measures.ISOCurrency : currency;
//     currency         @title : 'Currency';
//     status           @title : 'Status';
//     policyViolation  @title : 'Policy Violation';
//     violationMessage @title : 'Violation Message';
//     violationCount   @title : 'No. of Violations';
//     paidOn           @title : 'Paid On';
// }

// annotate service.ExpenseItems with {
//     category        @title : 'Category';
//     expenseDate     @title : 'Expense Date';
//     amount          @title : 'Amount'           @Measures.ISOCurrency : currency;
//     convertedAmount @title : 'Amount (INR)'     @Measures.ISOCurrency : 'INR';
//     description     @title : 'Description';
//     policyViolation @title : 'Policy Violation';
// }

// annotate service.Reimbursements with {
//     status        @title : 'Reimb. Status';
//     paymentRef    @title : 'Payment Reference';
//     processedDate @title : 'Processed On';
// }


// // ============================================================
// // 1. VALUE HELPS
// // ============================================================

// annotate service.ExpenseClaims with {

//     status @(
//         Common.ValueListWithFixedValues : true,
//         Common.ValueList : {
//             $Type          : 'Common.ValueListType',
//             CollectionPath : 'statusView',
//             Parameters     : [{
//                 $Type             : 'Common.ValueListParameterOut',
//                 LocalDataProperty : status,
//                 ValueListProperty : 'status'
//             }]
//         }
//     );

//     currency @(
//         Common.ValueListWithFixedValues : true,
//         Common.ValueList : {
//             $Type          : 'Common.ValueListType',
//             CollectionPath : 'CurrencyView',
//             Parameters     : [{
//                 $Type             : 'Common.ValueListParameterOut',
//                 LocalDataProperty : currency,
//                 ValueListProperty : 'code'
//             }]
//         }
//     );

//     employee @(
//         Common.Text            : employee.name,
//         Common.TextArrangement : #TextOnly,
//         Common.ValueList : {
//             $Type          : 'Common.ValueListType',
//             CollectionPath : 'Employees',
//             Parameters     : [
//                 {
//                     $Type             : 'Common.ValueListParameterOut',
//                     LocalDataProperty : employee_ID,
//                     ValueListProperty : 'ID'
//                 },
//                 {
//                     $Type             : 'Common.ValueListParameterDisplayOnly',
//                     ValueListProperty : 'name'
//                 },
//                 {
//                     $Type             : 'Common.ValueListParameterDisplayOnly',
//                     ValueListProperty : 'empNo'
//                 }
//             ]
//         }
//     );

//     approvedBy @(
//         Common.Text            : approvedBy.name,
//         Common.TextArrangement : #TextOnly
//     );
// }

// annotate service.ExpenseItems with {
//     category @(
//         Common.ValueListWithFixedValues : true,
//         Common.ValueList : {
//             $Type          : 'Common.ValueListType',
//             CollectionPath : 'categoryView',
//             Parameters     : [{
//                 $Type             : 'Common.ValueListParameterOut',
//                 LocalDataProperty : category,
//                 ValueListProperty : 'category'
//             }]
//         }
//     );
// }


// // ============================================================
// // 2. FIELD CONTROLS  –  mandatory, hidden, read-only
// // ============================================================

// annotate service.ExpenseClaims with {
//     claimDate       @Common.FieldControl : #Mandatory;
//     tripPurpose     @Common.FieldControl : #Mandatory;
//     // Audit fields — never shown in UI
//     createdAt       @UI.Hidden;
//     createdBy       @UI.Hidden;
//     modifiedAt      @UI.Hidden;
//     modifiedBy      @UI.Hidden;
// }

// annotate service.ExpenseItems with {
//     amount          @Common.FieldControl : #Mandatory;
//     expenseDate     @Common.FieldControl : #Mandatory;
//     category        @Common.FieldControl : #Mandatory;
//     createdAt       @UI.Hidden;
//     createdBy       @UI.Hidden;
//     modifiedAt      @UI.Hidden;
//     modifiedBy      @UI.Hidden;
// }


// // ============================================================
// // 3. DATA POINTS  –  KPI numbers shown in header & KPI cards
// // ============================================================

// annotate service.ExpenseClaims with @(

//     // ── KPI 1 : Total Spend ─────────────────────────────────
//     UI.DataPoint #TotalSpend : {
//         $Type           : 'UI.DataPointType',
//         Value           : totalAmount,
//         Title           : 'Total Claimed (INR)',
//         Description     : 'Sum of all submitted expense amounts',
//         Criticality     : #Positive,
//         ValueFormat     : {
//             $Type                    : 'UI.NumberFormat',
//             NumberOfFractionalDigits : 0
//         }
//     },

//     // ── KPI 2 : Violation Count ─────────────────────────────
//     UI.DataPoint #ViolationKPI : {
//         $Type       : 'UI.DataPointType',
//         Value       : violationCount,
//         Title       : 'Policy Violations',
//         Description : 'Claims with at least one policy breach',
//         Criticality : #Negative,
//         // Traffic-light thresholds:  0 = green, 1-2 = orange, 3+ = red
//         CriticalityCalculation : {
//             $Type                    : 'UI.CriticalityCalculationType',
//             ImprovementDirection     : #Minimize,
//             AcceptanceRangeLowValue  : 0,
//             AcceptanceRangeHighValue : 0,
//             ToleranceRangeLowValue   : 1,
//             ToleranceRangeHighValue  : 2,
//             DeviationRangeLowValue   : 3,
//             DeviationRangeHighValue  : 9999
//         },
//         TrendCalculation : {
//             $Type                : 'UI.TrendCalculationType',
//             ReferenceValue       : 10,
//             IsRelativeDifference : true,
//             UpDifference         : 0.2,
//             DownDifference       : -0.2
//         }
//     },

//     // ── KPI 3 : Status indicator ────────────────────────────
//     UI.DataPoint #StatusKPI : {
//         $Type       : 'UI.DataPointType',
//         Value       : status,
//         Title       : 'Claim Status',
//         Criticality : criticality      // virtual Integer field computed in handler
//     }
// );

// // ── KPI 4 : Pending Reimbursements ──────────────────────────
// annotate service.Reimbursements with @(
//     UI.DataPoint #PendingReimb : {
//         $Type       : 'UI.DataPointType',
//         Value       : status,
//         Title       : 'Pending Reimbursements',
//         Description : 'Reimbursements awaiting processing',
//         Criticality : #Negative
//     }
// );


// // ============================================================
// // 4. CHARTS  –  used in Visual Filters (ALP) + Analytical Cards
// // ============================================================

// annotate service.ExpenseClaims with @(

//     // ── Chart A : Monthly Spend Trend (Line) ────────────────
//     UI.Chart #MonthlySpendTrend : {
//         $Type               : 'UI.ChartDefinitionType',
//         Title               : 'Monthly Spend Trend',
//         Description         : 'Total claim amount per month — current FY',
//         ChartType           : #Line,
//         Dimensions          : [ claimDate ],
//         DimensionAttributes : [{
//             $Type     : 'UI.ChartDimensionAttributeType',
//             Dimension : claimDate,
//             Role      : #Category
//         }],
//         Measures            : [ totalAmount ],
//         MeasureAttributes   : [{
//             $Type   : 'UI.ChartMeasureAttributeType',
//             Measure : totalAmount,
//             Role    : #Axis1,
//             DataPoint : '@UI.DataPoint#TotalSpend'
//         }]
//     },

//     // ── Chart B : Expense by Category (Donut) ───────────────
//     UI.Chart #ExpenseByCategory : {
//         $Type               : 'UI.ChartDefinitionType',
//         Title               : 'Expense by Category',
//         Description         : 'Spend distribution across expense categories',
//         ChartType           : #Donut,
//         Dimensions          : [],           // aggregated at service via $apply
//         Measures            : [ totalAmount ],
//         MeasureAttributes   : [{
//             $Type   : 'UI.ChartMeasureAttributeType',
//             Measure : totalAmount,
//             Role    : #Axis1,
//             DataPoint : '@UI.DataPoint#TotalSpend'
//         }]
//     },

//     // ── Chart C : Claims by Status (Bar) ────────────────────
//     UI.Chart #ClaimsByStatus : {
//         $Type               : 'UI.ChartDefinitionType',
//         Title               : 'Claims by Status',
//         Description         : 'Count of claims in each workflow status',
//         ChartType           : #Bar,
//         Dimensions          : [ status ],
//         DimensionAttributes : [{
//             $Type     : 'UI.ChartDimensionAttributeType',
//             Dimension : status,
//             Role      : #Category
//         }],
//         Measures            : [ totalAmount ],
//         MeasureAttributes   : [{
//             $Type   : 'UI.ChartMeasureAttributeType',
//             Measure : totalAmount,
//             Role    : #Axis1
//         }]
//     },

//     // ── Chart D : Violations by Category (Bar) ──────────────
//     UI.Chart #ViolationByCategory : {
//         $Type               : 'UI.ChartDefinitionType',
//         Title               : 'Violations by Category',
//         Description         : 'Policy violation count per expense category',
//         ChartType           : #Bar,
//         Dimensions          : [],
//         Measures            : [ violationCount ],
//         MeasureAttributes   : [{
//             $Type   : 'UI.ChartMeasureAttributeType',
//             Measure : violationCount,
//             Role    : #Axis1,
//             DataPoint : '@UI.DataPoint#ViolationKPI'
//         }]
//     }
// );

// // ExpenseItems category donut (used in sub-page visual filter)
// annotate service.ExpenseItems with @(
//     UI.Chart #ItemsByCategory : {
//         $Type               : 'UI.ChartDefinitionType',
//         Title               : 'Items by Category',
//         ChartType           : #Donut,
//         Dimensions          : [ category ],
//         DimensionAttributes : [{
//             $Type     : 'UI.ChartDimensionAttributeType',
//             Dimension : category,
//             Role      : #Category
//         }],
//         Measures            : [ convertedAmount ],
//         MeasureAttributes   : [{
//             $Type   : 'UI.ChartMeasureAttributeType',
//             Measure : convertedAmount,
//             Role    : #Axis1
//         }]
//     }
// );


// // ============================================================
// // 5. KPI  –  full KPI tag annotation (number + mini-chart)
// //    Rendered as "KPI Tag" tile in the ALP header area
// // ============================================================

// annotate service.ExpenseClaims with @(

//     // ── KPI Tag 1 : Total Monthly Spend ─────────────────────
//     UI.KPI #KPIMonthlySpend : {
//         $Type     : 'UI.KPIType',
//         DataPoint : '@UI.DataPoint#TotalSpend',
//         Detail    : {
//             $Type                       : 'UI.KPIDetailType',
//             DefaultPresentationVariant  : {
//                 $Type          : 'UI.PresentationVariantType',
//                 Visualizations : [ '@UI.Chart#MonthlySpendTrend' ]
//             }
//         },
//         SelectionVariant : {
//             $Type : 'UI.SelectionVariantType',
//             Text  : 'All Active Claims',
//             SelectOptions : [{
//                 $Type        : 'UI.SelectOptionType',
//                 PropertyName : status,
//                 Ranges       : [
//                     { Sign : #Include, Option : #EQ, Low : 'SUBMITTED' },
//                     { Sign : #Include, Option : #EQ, Low : 'APPROVED'  }
//                 ]
//             }]
//         }
//     },

//     // ── KPI Tag 2 : Policy Violations ───────────────────────
//     UI.KPI #KPIPolicyViolations : {
//         $Type     : 'UI.KPIType',
//         DataPoint : '@UI.DataPoint#ViolationKPI',
//         Detail    : {
//             $Type                      : 'UI.KPIDetailType',
//             DefaultPresentationVariant : {
//                 $Type          : 'UI.PresentationVariantType',
//                 Visualizations : [ '@UI.Chart#ViolationByCategory' ]
//             }
//         },
//         SelectionVariant : {
//             $Type : 'UI.SelectionVariantType',
//             Text  : 'Violated Claims',
//             SelectOptions : [{
//                 $Type        : 'UI.SelectOptionType',
//                 PropertyName : policyViolation,
//                 Ranges       : [{
//                     Sign   : #Include,
//                     Option : #EQ,
//                     Low    : true
//                 }]
//             }]
//         }
//     }
// );

// // ── KPI Tag 3 : Pending Reimbursements ──────────────────────
// annotate service.Reimbursements with @(
//     UI.KPI #KPIPendingReimb : {
//         $Type     : 'UI.KPIType',
//         DataPoint : '@UI.DataPoint#PendingReimb',
//         Detail    : {
//             $Type                      : 'UI.KPIDetailType',
//             DefaultPresentationVariant : {
//                 $Type          : 'UI.PresentationVariantType',
//                 Visualizations : [ '@UI.Chart#PendingByMonth' ]
//             }
//         },
//         SelectionVariant : {
//             $Type : 'UI.SelectionVariantType',
//             Text  : 'Pending Only',
//             SelectOptions : [{
//                 $Type        : 'UI.SelectOptionType',
//                 PropertyName : status,
//                 Ranges       : [{
//                     Sign   : #Include,
//                     Option : #EQ,
//                     Low    : 'PENDING'
//                 }]
//             }]
//         }
//     },

//     UI.Chart #PendingByMonth : {
//         $Type               : 'UI.ChartDefinitionType',
//         Title               : 'Pending Reimbursements by Month',
//         ChartType           : #Bar,
//         Dimensions          : [ processedDate ],
//         DimensionAttributes : [{
//             $Type     : 'UI.ChartDimensionAttributeType',
//             Dimension : processedDate,
//             Role      : #Category
//         }],
//         Measures            : [ status ],
//         MeasureAttributes   : [{
//             $Type   : 'UI.ChartMeasureAttributeType',
//             Measure : status,
//             Role    : #Axis1
//         }]
//     }
// );


// // ============================================================
// // 6. SELECTION FIELDS  –  Filter Bar on List Report / ALP
// // ============================================================

// annotate service.ExpenseClaims with @(
//     UI.SelectionFields : [
//         status,
//         claimDate,
//         currency,
//         policyViolation,
//         employee_ID,
//         totalAmount
//     ]
// );


// // ============================================================
// // 7. LINE ITEM  –  Table columns for List Report
// // ============================================================

// annotate service.ExpenseClaims with @(
//     UI.LineItem : [
//         // ── Inline action button (top of column list = first toolbar) ──
//         {
//             $Type  : 'UI.DataFieldForAction',
//             Action : 'ExpenseService.processPayment',
//             Label  : 'Process Payment',
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type  : 'UI.DataFieldForAction',
//             Action : 'ExpenseService.approveAll',
//             Label  : 'Approve Selected',
//             ![@UI.Importance] : #Medium
//         },
//         // ── Columns ───────────────────────────────────────────────────
//         {
//             $Type             : 'UI.DataField',
//             Value             : ID,
//             Label             : 'Claim ID',
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : employee.name,
//             Label             : 'Employee',
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : claimDate,
//             Label             : 'Claim Date',
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : tripPurpose,
//             Label             : 'Purpose',
//             ![@UI.Importance] : #Medium
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : totalAmount,
//             Label             : 'Total Amount',
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : currency,
//             Label             : 'Currency',
//             ![@UI.Importance] : #Low
//         },
//         {
//             // criticality drives automatic color-coded badge
//             $Type             : 'UI.DataField',
//             Value             : status,
//             Label             : 'Status',
//             Criticality       : criticality,
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : policyViolation,
//             Label             : 'Violation',
//             Criticality       : #Negative,
//             ![@UI.Importance] : #High
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : violationCount,
//             Label             : '# Violations',
//             Criticality       : '@UI.DataPoint#ViolationKPI/CriticalityCalculation',
//             ![@UI.Importance] : #Medium
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : paidOn,
//             Label             : 'Paid On',
//             ![@UI.Importance] : #Low
//         },
//         {
//             $Type             : 'UI.DataField',
//             Value             : reimbursement.status,
//             Label             : 'Reimb. Status',
//             ![@UI.Importance] : #Medium
//         }
//     ]
// );


// // ============================================================
// // 8. PRESENTATION VARIANT  –  Default sort/group + which charts
// //    to show alongside the table (drives the ALP "Content Area")
// // ============================================================

// annotate service.ExpenseClaims with @(

//     UI.PresentationVariant #Default : {
//         $Type          : 'UI.PresentationVariantType',
//         Text           : 'Default',
//         MaxItems       : 50,
//         SortOrder      : [{
//             $Type      : 'Common.SortOrderType',
//             Property   : claimDate,
//             Descending : true
//         }],
//         GroupBy        : [ status ],
//         Visualizations : [
//             '@UI.Chart#MonthlySpendTrend',
//             '@UI.Chart#ExpenseByCategory',
//             '@UI.LineItem'
//         ]
//     },

//     UI.PresentationVariant #ByViolation : {
//         $Type          : 'UI.PresentationVariantType',
//         Text           : 'Violations First',
//         MaxItems       : 50,
//         SortOrder      : [
//             { Property : policyViolation, Descending : true },
//             { Property : claimDate,       Descending : true }
//         ],
//         GroupBy        : [ policyViolation ],
//         Visualizations : [
//             '@UI.Chart#ViolationByCategory',
//             '@UI.LineItem'
//         ]
//     }
// );


// // ============================================================
// // 9. SELECTION VARIANT  –  Saved filter presets in filter bar
// // ============================================================

// annotate service.ExpenseClaims with @(

//     UI.SelectionVariant #PendingClaims : {
//         $Type : 'UI.SelectionVariantType',
//         Text  : 'Pending Claims',
//         SelectOptions : [{
//             $Type        : 'UI.SelectOptionType',
//             PropertyName : status,
//             Ranges       : [{
//                 Sign   : #Include,
//                 Option : #EQ,
//                 Low    : 'SUBMITTED'
//             }]
//         }]
//     },

//     UI.SelectionVariant #ViolatedOnly : {
//         $Type : 'UI.SelectionVariantType',
//         Text  : 'Policy Violations',
//         SelectOptions : [{
//             $Type        : 'UI.SelectOptionType',
//             PropertyName : policyViolation,
//             Ranges       : [{
//                 Sign   : #Include,
//                 Option : #EQ,
//                 Low    : true
//             }]
//         }]
//     },

//     UI.SelectionVariant #PaidThisMonth : {
//         $Type : 'UI.SelectionVariantType',
//         Text  : 'Paid This Month',
//         SelectOptions : [{
//             $Type        : 'UI.SelectOptionType',
//             PropertyName : status,
//             Ranges       : [{
//                 Sign   : #Include,
//                 Option : #EQ,
//                 Low    : 'PAID'
//             }]
//         }]
//     }
// );


// // ============================================================
// // 10. SELECTION PRESENTATION VARIANT  –  The KEY annotation
// //     that wires charts + KPIs + table together into ALP mode.
// //     Reference this in manifest.json → "annotationPath"
// // ============================================================

// annotate service.ExpenseClaims with @(
//     UI.SelectionPresentationVariant #FinanceDashboard : {
//         $Type : 'UI.SelectionPresentationVariantType',
//         Text  : 'Finance Dashboard',

//         // Default filters pre-applied when page opens
//         SelectionVariant : {
//             $Type : 'UI.SelectionVariantType',
//             Text  : 'Active Claims',
//             SelectOptions : [{
//                 $Type        : 'UI.SelectOptionType',
//                 PropertyName : status,
//                 Ranges       : [
//                     { Sign : #Include, Option : #EQ, Low : 'SUBMITTED' },
//                     { Sign : #Include, Option : #EQ, Low : 'APPROVED'  },
//                     { Sign : #Include, Option : #EQ, Low : 'PENDING'   }
//                 ]
//             }]
//         },

//         // Which charts and table to render in the content area
//         PresentationVariant : {
//             $Type          : 'UI.PresentationVariantType',
//             Text           : 'Finance Charts + Table',
//             MaxItems       : 100,
//             SortOrder      : [{
//                 $Type      : 'Common.SortOrderType',
//                 Property   : claimDate,
//                 Descending : true
//             }],
//             GroupBy        : [ status ],
//             Visualizations : [
//                 // Order matters: charts render top, table renders below
//                 '@UI.Chart#MonthlySpendTrend',
//                 '@UI.Chart#ExpenseByCategory',
//                 '@UI.Chart#ClaimsByStatus',
//                 '@UI.LineItem'
//             ]
//         }
//     }
// );


// // ============================================================
// // 11. HEADER INFO + HEADER FACETS  –  Object Page header bar
// // ============================================================

// annotate service.ExpenseClaims with @(

//     UI.HeaderInfo : {
//         $Type          : 'UI.HeaderInfoType',
//         TypeName       : 'Expense Claim',
//         TypeNamePlural : 'Expense Claims',
//         Title          : { Value : tripPurpose },
//         Description    : { Value : status      },
//         ImageUrl       : ''
//     },

//     // KPI tiles shown in the object page header strip
//     UI.HeaderFacets : [
//         {
//             $Type  : 'UI.ReferenceFacet',
//             ID     : 'HeaderTotalAmount',
//             Target : '@UI.DataPoint#TotalSpend',
//             Label  : 'Total Amount'
//         },
//         {
//             $Type  : 'UI.ReferenceFacet',
//             ID     : 'HeaderViolations',
//             Target : '@UI.DataPoint#ViolationKPI',
//             Label  : 'Policy Violations'
//         },
//         {
//             $Type  : 'UI.ReferenceFacet',
//             ID     : 'HeaderStatus',
//             Target : '@UI.DataPoint#StatusKPI',
//             Label  : 'Claim Status'
//         }
//     ]
// );


// // ============================================================
// // 12. OBJECT PAGE FACETS  –  sections and field groups
// // ============================================================

// annotate service.ExpenseClaims with @(
//     UI.Facets : [

//         // ── Section 1 : Claim + Payment side-by-side ──────────
//         {
//             $Type  : 'UI.CollectionFacet',
//             ID     : 'ClaimOverview',
//             Label  : 'General Information',
//             Facets : [
//                 {
//                     $Type  : 'UI.ReferenceFacet',
//                     ID     : 'ClaimDetails',
//                     Target : '@UI.FieldGroup#ClaimDetails',
//                     Label  : 'Claim Details'
//                 },
//                 {
//                     $Type  : 'UI.ReferenceFacet',
//                     ID     : 'PaymentDetails',
//                     Target : '@UI.FieldGroup#PaymentInfo',
//                     Label  : 'Payment Information'
//                 }
//             ]
//         },

//         // ── Section 2 : Policy violations ─────────────────────
//         {
//             $Type  : 'UI.CollectionFacet',
//             ID     : 'PolicySection',
//             Label  : 'Policy Compliance',
//             Facets : [{
//                 $Type  : 'UI.ReferenceFacet',
//                 ID     : 'ViolationFacet',
//                 Target : '@UI.FieldGroup#ViolationDetails',
//                 Label  : 'Violation Details'
//             }]
//         },

//         // ── Section 3 : Expense items sub-table ───────────────
//         {
//             $Type  : 'UI.ReferenceFacet',
//             ID     : 'ExpenseItemsTable',
//             Label  : 'Expense Items',
//             Target : 'items/@UI.LineItem'
//         },

//         // ── Section 4 : Reimbursement details ─────────────────
//         {
//             $Type  : 'UI.ReferenceFacet',
//             ID     : 'ReimbursementFacet',
//             Label  : 'Reimbursement',
//             Target : 'reimbursement/@UI.FieldGroup#ReimDetails'
//         }
//     ],

//     // ── Field group : Claim Details ───────────────────────────
//     UI.FieldGroup #ClaimDetails : {
//         $Type : 'UI.FieldGroupType',
//         Label : 'Claim Details',
//         Data  : [
//             { $Type : 'UI.DataField', Value : ID,               Label : 'Claim ID'    },
//             { $Type : 'UI.DataField', Value : claimDate,        Label : 'Claim Date'  },
//             { $Type : 'UI.DataField', Value : tripPurpose,      Label : 'Purpose'     },
//             { $Type : 'UI.DataField', Value : totalAmount,      Label : 'Amount'      },
//             { $Type : 'UI.DataField', Value : currency,         Label : 'Currency'    },
//             {
//                 $Type       : 'UI.DataField',
//                 Value       : status,
//                 Label       : 'Status',
//                 Criticality : criticality
//             },
//             { $Type : 'UI.DataField', Value : employee.name,    Label : 'Employee'    },
//             { $Type : 'UI.DataField', Value : approvedBy.name,  Label : 'Approved By' }
//         ]
//     },

//     // ── Field group : Payment Info ────────────────────────────
//     UI.FieldGroup #PaymentInfo : {
//         $Type : 'UI.FieldGroupType',
//         Label : 'Payment',
//         Data  : [
//             { $Type : 'UI.DataField', Value : paidOn,                         Label : 'Paid On'            },
//             { $Type : 'UI.DataField', Value : reimbursement.paymentRef,       Label : 'Payment Ref'        },
//             { $Type : 'UI.DataField', Value : reimbursement.status,           Label : 'Reimb. Status'      },
//             { $Type : 'UI.DataField', Value : reimbursement.processedDate,    Label : 'Processed On'       },
//             { $Type : 'UI.DataField', Value : reimbursement.processedBy.name, Label : 'Processed By'       }
//         ]
//     },

//     // ── Field group : Violation Details ──────────────────────
//     UI.FieldGroup #ViolationDetails : {
//         $Type : 'UI.FieldGroupType',
//         Label : 'Violation Details',
//         Data  : [
//             { $Type : 'UI.DataField', Value : policyViolation,  Label : 'Has Violation',      Criticality : #Negative },
//             { $Type : 'UI.DataField', Value : violationCount,   Label : 'Violation Count'                             },
//             { $Type : 'UI.DataField', Value : violationMessage, Label : 'Violation Message'                           }
//         ]
//     }
// );

// // Reimbursement field group (shown via association in object page)
// annotate service.Reimbursements with @(
//     UI.FieldGroup #ReimDetails : {
//         $Type : 'UI.FieldGroupType',
//         Label : 'Reimbursement Details',
//         Data  : [
//             { $Type : 'UI.DataField', Value : ID,                    Label : 'ID'             },
//             { $Type : 'UI.DataField', Value : status,                Label : 'Status'         },
//             { $Type : 'UI.DataField', Value : paymentRef,            Label : 'Payment Ref'    },
//             { $Type : 'UI.DataField', Value : processedDate,         Label : 'Processed On'   },
//             { $Type : 'UI.DataField', Value : processedBy.name,      Label : 'Processed By'   }
//         ]
//     }
// );

// // Expense items sub-table on object page
// annotate service.ExpenseItems with @(
//     UI.LineItem : [
//         { $Type : 'UI.DataField', Value : category,        Label : 'Category'        },
//         { $Type : 'UI.DataField', Value : expenseDate,     Label : 'Date'            },
//         { $Type : 'UI.DataField', Value : amount,          Label : 'Amount'          },
//         { $Type : 'UI.DataField', Value : currency,        Label : 'Currency'        },
//         { $Type : 'UI.DataField', Value : convertedAmount, Label : 'Converted (INR)' },
//         { $Type : 'UI.DataField', Value : description,     Label : 'Description'     },
//         {
//             $Type       : 'UI.DataField',
//             Value       : policyViolation,
//             Label       : 'Violation',
//             Criticality : #Negative
//         }
//     ]
// );


// // ============================================================
// // 13. QUICK VIEW  –  hover card on Employee column in table
// // ============================================================

// annotate service.Employees with @(
//     UI.QuickViewFacets : [{
//         $Type  : 'UI.ReferenceFacet',
//         Target : '@UI.FieldGroup#EmployeeCard',
//         Label  : 'Employee Info'
//     }],
//     UI.FieldGroup #EmployeeCard : {
//         $Type : 'UI.FieldGroupType',
//         Data  : [
//             { $Type : 'UI.DataField', Value : empNo,           Label : 'Emp No'     },
//             { $Type : 'UI.DataField', Value : name,            Label : 'Name'       },
//             { $Type : 'UI.DataField', Value : email,           Label : 'Email'      },
//             { $Type : 'UI.DataField', Value : department.name, Label : 'Department' }
//         ]
//     }
// );


// // ============================================================
// // 14. CAPABILITIES  –  OData $metadata hints for the UI shell
// // ============================================================

// annotate service.ExpenseClaims with @(
//     Capabilities.FilterRestrictions : {
//         $Type : 'Capabilities.FilterRestrictionsType',
//         FilterExpressionRestrictions : [{
//             $Type             : 'Capabilities.FilterExpressionRestrictionType',
//             Property          : claimDate,
//             AllowedExpressions : 'SingleRange'
//         }]
//     },
//     Capabilities.SortRestrictions : {
//         $Type                  : 'Capabilities.SortRestrictionsType',
//         NonSortableProperties  : [ violationMessage ]
//     },
//     Capabilities.SearchRestrictions : {
//         $Type      : 'Capabilities.SearchRestrictionsType',
//         Searchable : true
//     }
// );


// // ============================================================
// // 15. SIDE EFFECTS  –  auto-refresh related fields after edits
// // ============================================================

// annotate service.ExpenseClaims with @(
//     Common.SideEffects #OnStatusChange : {
//         $Type            : 'Common.SideEffectsType',
//         SourceProperties : [ status ],
//         TargetProperties : [ paidOn, violationCount ]
//     },
//     Common.SideEffects #OnAmountChange : {
//         $Type            : 'Common.SideEffectsType',
//         SourceProperties : [ totalAmount ],
//         TargetProperties : [ policyViolation, violationMessage, violationCount ]
//     }
// );


// // ============================================================
// // 16. manifest.json  –  PASTE THIS into your Fiori app
// //     fiori-tools generated path: webapp/manifest.json
// //
// //  "targets": {
// //    "ExpenseClaimsList": {
// //      "type": "Component",
// //      "id": "ExpenseClaimsList",
// //      "name": "sap.fe.templates.ListReport",
// //      "options": {
// //        "settings": {
// //          "entitySet": "ExpenseClaims",
// //          "variantManagement": "Page",
// //          "initialLoad": true,
// //          "controlConfiguration": {
// //            "@com.sap.vocabularies.UI.v1.SelectionPresentationVariant#FinanceDashboard": {
// //              "tableSettings": {
// //                "type": "AnalyticalTable",
// //                "selectionMode": "Multi"
// //              }
// //            }
// //          },
// //          "views": {
// //            "paths": [{
// //              "key": "tab1",
// //              "annotationPath":
// //                "com.sap.vocabularies.UI.v1.SelectionPresentationVariant#FinanceDashboard"
// //            }]
// //          }
// //        }
// //      }
// //    }
// //  }
// // ============================================================


// // ============================================================
// // 17. srv/expense-service.cds  –  SERVICE PROJECTION
// //     (add virtual `criticality` field here)
// //
// //  service ExpenseService {
// //      @Aggregation.ApplySupported.PropertyRestrictions: true
// //      entity ExpenseClaims as projection on em.ExpenseClaims {
// //          *,
// //          virtual criticality : Integer  // computed below
// //      }
// //      entity ExpenseItems     as projection on em.ExpenseItems;
// //      entity Reimbursements   as projection on em.Reimbursements;
// //      entity ExpensePolicies  as projection on em.ExpensePolicies;
// //      entity Employees        as projection on em.Employees;
// //      entity Departments      as projection on em.Departments;
// //      entity Managers         as projection on em.Managers;
// //      entity CurrencyView     as projection on em.CurrencyView;
// //      entity categoryView     as projection on em.categoryView;
// //      entity statusView       as projection on em.statusView;
// //  }
// // ============================================================


// // ============================================================
// // 18. srv/expense-service.js  –  HANDLER (criticality + action)
// //
// //  module.exports = (srv) => {
// //
// //    // Compute criticality for status colour-coding
// //    srv.after('READ', 'ExpenseClaims', (rows) => {
// //      for (const row of [rows].flat()) {
// //        switch (row.status) {
// //          case 'PAID':
// //          case 'APPROVED':   row.criticality = 3; break; // Green
// //          case 'SUBMITTED':  row.criticality = 2; break; // Orange
// //          case 'REJECTED':
// //          case 'WITHDRAWN':  row.criticality = 1; break; // Red
// //          default:           row.criticality = 0;        // Neutral
// //        }
// //      }
// //    });
// //
// //    // Bound action: Process Payment
// //    srv.on('processPayment', 'ExpenseClaims', async (req) => {
// //      const { ID } = req.params[0];
// //      await UPDATE('ExpenseClaims').set({
// //          status  : 'PAID',
// //          paidOn  : new Date().toISOString().slice(0, 10)
// //      }).where({ ID });
// //      await UPDATE('Reimbursements').set({
// //          status        : 'COMPLETED',
// //          processedDate : new Date().toISOString().slice(0, 10)
// //      }).where({ claim_ID : ID });
// //      return req.info('Payment processed successfully.');
// //    });
// //
// //  };
// // ============================================================

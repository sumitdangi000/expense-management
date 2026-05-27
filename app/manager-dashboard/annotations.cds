using ExpenseService as service from '../../srv/service';
annotate service.ManagerDashboard with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : employee.empNo,
            Label : 'Emp No',
        },
        {
            $Type : 'UI.DataField',
            Value : claimDate,
            Label : 'Claim Date',
        },
        {
            $Type : 'UI.DataField',
            Value : totalAmount,
            Label : 'Total Amount',
        },
        {
            $Type : 'UI.DataField',
            Value : status,
            Label : 'Status',
            Criticality : (status = 'DRAFT' ? 5 : status = 'PAID' ? 4 : status = 'APPROVED' ? 3 : status = 'SUBMITTED' ? 2 : status = 'REJECTED' ? 1 : 0)

        },
        {
            $Type : 'UI.DataField',
            Value : tripPurpose,
            Label : 'Trip Purpose',
        },
        {
            $Type : 'UI.DataField',
            Value : items.receipt,
            Label : 'Receipt',
        },
        {
            $Type : 'UI.DataField',
            Value : policyViolation,
            Label : 'Policy Violation',
            Criticality : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0)
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.approveClaim',
            Label : 'Approve Claim',
            ![@UI.Importance] : #High,
            Criticality: #Positive
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.rejectClaim',
            Label : 'Reject Claim',
            ![@UI.Importance] : #High,
            Criticality: #Negative
        },
    ],
    UI.SelectionPresentationVariant #tableView : {
        $Type : 'UI.SelectionPresentationVariantType',
        PresentationVariant : {
            $Type : 'UI.PresentationVariantType',
            Visualizations : [
                '@UI.LineItem',
            ],
            SortOrder : [
                {
                    $Type : 'Common.SortOrderType',
                    Property : status,
                    Descending : true,
                },
            ],
        },
        SelectionVariant : {
            $Type : 'UI.SelectionVariantType',
            SelectOptions : [
            ],
        },
        Text : 'Table View',
    },
    UI.LineItem #tableView : [
    ],
    UI.SelectionPresentationVariant #tableView1 : {
        $Type : 'UI.SelectionPresentationVariantType',
        PresentationVariant : {
            $Type : 'UI.PresentationVariantType',
            Visualizations : [
                '@UI.LineItem#tableView',
            ],
        },
        SelectionVariant : {
            $Type : 'UI.SelectionVariantType',
            SelectOptions : [
            ],
        },
        Text : 'Table View 1',
    },
    UI.SelectionFields : [
        status,
        items.category,
        items.policyViolation,
    ],
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Claim Details',
            ID : 'ClaimDetails',
            Target : '@UI.FieldGroup#ClaimDetails',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Employee Details',
            ID : 'Items',
            Target : '@UI.FieldGroup#Items',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'More Details',
            ID : 'MoreDetails',
            Target : 'items/@UI.LineItem#MoreDetails',
        },
    ],
    UI.FieldGroup #ClaimDetails : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : claimDate,
                Label : 'Claim Date',
            },
            {
                $Type : 'UI.DataField',
                Value : tripPurpose,
                Label : 'Trip Purpose',
            },
            {
                $Type : 'UI.DataField',
                Value : totalAmount,
                Label : 'Total Amount',
            },
            {
                $Type : 'UI.DataField',
                Value : status,
                Criticality : (status = 'DRAFT' ? 5 : status = 'PAID' ? 4 : status = 'APPROVED' ? 3 : status = 'SUBMITTED' ? 2 : status = 'REJECTED' ? 1 : 0),
                CriticalityRepresentation: #WithoutIcon
            },
            {
                $Type : 'UI.DataField',
                Value : policyViolation,
                Label : 'Policy Violation',
                Criticality : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0),

            },
            {
                $Type : 'UI.DataField',
                Value : violationMessage,
                Label : 'Violation Message',
            },
            
        ],
    },
    UI.HeaderInfo : {
        Title : {
            $Type : 'UI.DataField',
            Value : employee.name,
        },
        TypeName : '',
        TypeNamePlural : '',
        Description : {
            $Type : 'UI.DataField',
            Value : tripPurpose,
        },
        TypeImageUrl : 'sap-icon://customer',
    },
    UI.FieldGroup #Items : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : employee.empNo,
                Label : 'Emp No',
            },
            {
                $Type : 'UI.DataField',
                Value : employee.name,
                Label : 'Emp Name',
            },
            {
                $Type : 'UI.DataField',
                Value : employee.email,
                Label : 'Email',
            },
            {
                $Type : 'UI.DataField',
                Value : employee.department.deptId,
                Label : 'Dept ID',
            },
            {
                $Type : 'UI.DataField',
                Value : employee.department.name,
                Label : 'Department Name',
            },
            {
                $Type : 'UI.DataField',
                Value : employee.manager.managerId,
                Label : 'Manager ID',
            },
        ],
    },
    UI.Identification : [
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'ExpenseService.approveClaim',
            Label : 'Approve Claim',
            Criticality:3
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'ExpenseService.rejectClaim',
            Label : 'Reject Claim',
            Criticality:1
        },
    ],
    UI.DataPoint #claimDate : {
        $Type : 'UI.DataPointType',
        Value : claimDate,
        Title : 'Dlaim Date',
    },
);

annotate service.ManagerDashboard with {
    status @(
        Common.Label : 'Status',
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'statusView',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : status,
                    ValueListProperty : 'status',
                },
            ],
        },
        Common.ValueListWithFixedValues : true,
    )
};

annotate service.ExpenseItems with @(
    UI.LineItem #MoreDetails : [
        {
            $Type : 'UI.DataField',
            Value : claim.items.expenseDate,
            Label : 'Expense Date',
        },
        {
            $Type : 'UI.DataField',
            Value : category,
        },
        {
            $Type : 'UI.DataField',
            Value : description,
            Label : 'Description',
        },
        {
            $Type : 'UI.DataField',
            Value : claim.items.receipt,
            Label : 'receipt',
        },
        {
            $Type : 'UI.DataField',
            Value : policyViolation,
            Criticality : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0)

        },
    ],
    UI.DataPoint #amount : {
        Value : amount,
    },
    UI.Chart #amount : {
        ChartType : #Area,
        Title : 'amount',
        Measures : [
            amount,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#amount',
                Role : #Axis1,
                Measure : amount,
            },
        ],
        Dimensions : [
            amount,
        ],
    },
);

annotate service.ManagerDashboard with @(

    UI.DataPoint #TotalSpend : {
        $Type       : 'UI.DataPointType',
        Value       : `₹ {totalAmount}`,
        Title       : 'Total Claimed (₹)',
        Description : 'Sum of all submitted expense amounts',
        Criticality : #Positive,
        ValueFormat : {
            $Type                    : 'UI.NumberFormat',
            NumberOfFractionalDigits : 0,
        },
    },

    UI.DataPoint #ViolationKPI : {
        $Type       : 'UI.DataPointType',
        Value       : `{policyViolation} - {violationCount}`,
        Title       : 'Policy Violations',
        Description : 'Claims with at least one policy breach',
        Criticality : (violationCount = 0 ? 3 : violationCount > 0 ? 1 : 0),
        CriticalityCalculation : {
            $Type                    : 'UI.CriticalityCalculationType',
            ImprovementDirection     : #Minimize,
            AcceptanceRangeLowValue  : 0,
            AcceptanceRangeHighValue : 0,
            ToleranceRangeLowValue   : 1,
            ToleranceRangeHighValue  : 2,
            DeviationRangeLowValue   : 3,
            DeviationRangeHighValue  : 9999,
        },
        TrendCalculation : {
            $Type                : 'UI.TrendCalculationType',
            ReferenceValue       : 10,
            IsRelativeDifference : true,
            UpDifference         : 0.2,
            DownDifference       : -0.2,
        },
    },

    UI.DataPoint #StatusKPI : {
        $Type       : 'UI.DataPointType',
        Value       : status,
        Title       : 'Claim Status',
        Criticality : (status = 'DRAFT' ? 5 : status = 'PAID' ? 4 : status = 'APPROVED' ? 3 : status = 'SUBMITTED' ? 2 : status = 'REJECTED' ? 1 : 0),
    },
);

annotate service.ManagerDashboard with @(

    UI.HeaderFacets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'claimDate',
            Target : '@UI.DataPoint#claimDate',
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'HeaderTotalAmount',
            Target : '@UI.DataPoint#TotalSpend',
            Label  : 'Total Amount',
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'HeaderViolations',
            Target : '@UI.DataPoint#ViolationKPI',
            Label  : 'Policy Violations',
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'HeaderStatus',
            Target : '@UI.DataPoint#StatusKPI',
            Label  : 'Claim Status',
        },
        
    ]);



 using ExpenseService as service from '../../srv/service';

annotate service.ExpenseClaims with @(
    UI.FieldGroup #GeneratedGroup    : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : employee_ID,
                Label : 'Employee',
            },
            {
                $Type: 'UI.DataField',
                Label: 'Claim Date',
                Value: claimDate,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Trip Purpose',
                Value: tripPurpose,
            },
            {
                $Type       : 'UI.DataField',
                Value       : policyViolation,
                Label       : 'Is Policy Violated',
                Criticality : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0)
            },
            {
                $Type        : 'UI.DataField',
                Value        : violationMessage,
                Label        : 'Violation Reasons',
                ![@UI.Hidden]: (policyViolation = false),
                Criticality : 1,
                CriticalityRepresentation:#WithoutIcon
            },
        ],
    },
    UI.Facets                        : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneratedFacet1',
            Label : 'Claim Details',
            Target: '@UI.FieldGroup#GeneratedGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Expense Items',
            ID : 'BasicInformation',
            Target : 'items/@UI.LineItem#BasicInformation',
        },
    ],
    UI.LineItem                      : [
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.submitClaim',
            Label : 'Submit Claim',
            Criticality:3
            
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.withdrawClaim',
            Label : 'Withdraw Claim',
            Criticality:#VeryNegative
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.getReimbursementStatus',
            Label : 'Check Reimbursement Status',
            Criticality:#Information,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Claim Date',
            Value: claimDate,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Purpose',
            Value: tripPurpose,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Amount',
            Value: totalAmount,
        },
        {
            $Type       : 'UI.DataField',
            Label       : 'Status',
            Value       : status,
            Criticality : (status = 'DRAFT' ? 5 : status = 'PAID' ? 4 : status = 'APPROVED' ? 3 : status = 'SUBMITTED' ? 2 : status = 'REJECTED' ? 1 : 0)
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target : '@UI.DataPoint#violationCount',
            Label : 'Policy Violation',
            @UI.Importance : #High,

        },
        {
            $Type : 'UI.DataField',
            Value : modifiedAt,
        },


    ],
    UI.SelectionFields               : [
        status,
        items.category,
        policyViolation,
    ],
    UI.HeaderInfo                    : {
        Title         : {
            $Type: 'UI.DataField',
            Value: tripPurpose,
        },
        TypeName      : 'My Claim',
        TypeNamePlural: 'My Claims',
        Description   : {
            $Type: 'UI.DataField',
            Value: status,
        },
        TypeImageUrl  : 'sap-icon://monitor-payments',
    },
    UI.Identification                : [
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.submitClaim',
            Label : 'Submit Claim',
            Criticality:#Positive
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.withdrawClaim',
            Label : 'Withdraw Claim',
            Criticality:#Negative
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'ExpenseService.getReimbursementStatus',
            Label : 'Check Reimbursement Status',
            Criticality:#Information
        },
    ],
    UI.QuickViewFacet                : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Violation Details',
        Target: '@UI.FieldGroup#ViolationQuickView',
    }, ],
    UI.FieldGroup #ViolationQuickView: {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: violationMessage,
            Label: 'Violation Reasons',
            
        }, ],
    },
    UI.FieldGroup #Itemdetails       : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: items.policyViolation,
            },
            {
                $Type: 'UI.DataField',
                Value: items.receipt,
                Label: 'receipt',
            },
            {
                $Type: 'UI.DataField',
                Value: items.receiptName,
                Label: 'receiptName',
            },
            {
                $Type: 'UI.DataField',
                Value: items.receiptType,
                Label: 'receiptType',
            },
            {
                $Type: 'UI.DataField',
                Value: items.description,
                Label: 'description',
            },
        ],
    },
    UI.FieldGroup #ItemDetails       : {
        $Type: 'UI.FieldGroupType',
        Data : [],
    },
    UI.FieldGroup #Items : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : items.category,
            },
            {
                $Type : 'UI.DataField',
                Value : items.amount,
                Label : 'amount',
            },
            {
                $Type : 'UI.DataField',
                Value : items.currency,
                Label : 'currency',
            },
            {
                $Type : 'UI.DataField',
                Value : items.description,
                Label : 'description',
            },
            {
                $Type : 'UI.DataField',
                Value : items.modifiedAt,
            },
            {
                $Type : 'UI.DataField',
                Value : items.receipt,
                Label : 'receipt',
            },
        ],
    },
    UI.FieldGroup #ItemDetails1 : {
        $Type : 'UI.FieldGroupType',
        Data : [
        ],
    },
    UI.SelectionPresentationVariant #tableView : {
        $Type : 'UI.SelectionPresentationVariantType',
        PresentationVariant : {
            $Type : 'UI.PresentationVariantType',
            Visualizations : [
                '@UI.LineItem',
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
    UI.DataPoint #violationCount : {
        Value : violationItemCount,
        Visualization : #Progress,
        TargetValue : itemCount,
        Criticality : (violationItemCount>0?1:3),
        CriticalityRepresentation:#WithoutIcon
    },
);

annotate service.ExpenseClaims with {
    employee @(
        Common.ValueList: {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Employees',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: employee_ID,
                    ValueListProperty: 'ID',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'empNo',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'email',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'bankAccount',
                },
            ],
        },
        Common.Text : employee.name,
        Common.Text.@UI.TextArrangement : #TextOnly,
    )
};

annotate service.ExpenseClaims with {
    approvedBy @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Managers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: approvedBy_ID,
                ValueListProperty: 'ID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'managerId',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name',
            },
        ],
    }
};

annotate service.ExpenseClaims with {
    status @(
        Common.Label                   : 'Status',
        Common.FieldControl            : #ReadOnly,
        Criticality                    : (status = 'DRAFT' ? 5 : status = 'PAID' ? 4 : status = 'APPROVED' ? 3 : status = 'SUBMITTED' ? 2 : status = 'REJECTED' ? 1 : 0),
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
    UI.LineItem #Items        : [
        {
            $Type         : 'UI.DataField',
            Value         : expenseDate,
            Label         : '{i18n>ExpenseDate}',
            @UI.Importance: #High,
        },
        {
            $Type         : 'UI.DataField',
            Value         : category,
            Label         : 'Category',
            @UI.Importance: #High,
        },
        {
            $Type         : 'UI.DataField',
            Value         : amount,
            Label         : 'Amount',
            @UI.Importance: #High,
        },
        {
            $Type : 'UI.DataField',
            Value : currency,
            Label : 'Currency',
        },
        {
            $Type: 'UI.DataField',
            Value: description,
            Label: 'Description',
        },
    ],
    UI.Facets                 : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Item Details',
        ID    : 'ItemDetails',
        Target: '@UI.FieldGroup#ItemDetails',
    }, ],
    UI.FieldGroup #ItemDetails: {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: receipt,
        }, ],
    },
    UI.LineItem #ItemDetails  : [
        {
            $Type: 'UI.DataField',
            Value: category,
            Label: 'Category',
        },
        {
            $Type       : 'UI.DataField',
            Value       : policyViolation,
            Label       : 'Is Policy Violated',
            Criticality : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0)

        },
        {
            $Type: 'UI.DataField',
            Value: receipt,
            Label: 'Receipt',
        },
        {
            $Type         : 'UI.DataFieldForIntentBasedNavigation',
            SemanticObject: 'Test',
            Action        : 'TestAction',
            Label         : 'Test Action',
        },
    ],
    UI.LineItem #BasicInformation : [
        {
            $Type : 'UI.DataField',
            Value : expenseDate,
            Label : 'Expense Date',
        },
        {
            $Type : 'UI.DataField',
            Value : category,
        },
        {
            $Type : 'UI.DataField',
            Value : amount,
            Label : 'Amount',
        },
        {
            $Type : 'UI.DataField',
            Value : currency,
            Label : 'Currency',
        },
        {
            $Type : 'UI.DataField',
            Value : description,
            Label : 'Description',
        },
        {
            $Type : 'UI.DataField',
            Value : receipt,
            Label : 'Upload Receipt',
        },
        {
            $Type : 'UI.DataField',
            Value : policyViolation,
            Label : 'Policy Violation',
            Criticality : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0)
        },
    ],
    UI.DataPoint #amount1 : {
        Value : amount,
    },
    UI.Chart #amount1 : {
        ChartType : #Area,
        Measures : [
            amount,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#amount1',
                Role : #Axis1,
                Measure : amount,
            },
        ],
        Dimensions : [
            amount,
        ],
    },
);

annotate service.ExpenseItems with {
    category @(
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'categoryView',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: category,
                ValueListProperty: 'category',
            }, ],
        },
        Common.ValueListWithFixedValues: true,
        Common.FieldControl            : #Mandatory,
        Common.Label                   : 'Category',
    )
};

annotate service.ExpenseClaims with {
    totalAmount @(
        Common.FieldControl : #ReadOnly,
        Measures.ISOCurrency: currency,
    )
};

annotate service.ExpenseItems with {
    currency @(
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'CurrencyView',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: currency,
                ValueListProperty: 'code',
            }, ],
        },
        Common.ValueListWithFixedValues: true,
    )
};

annotate service.ExpenseItems with {
    policyViolation @(
        Common.Label       : 'Policy Violation',
        Common.FieldControl: #ReadOnly,
        Criticality        : (policyViolation = true ? 1 : policyViolation = false ? 3 : 0)
    )
};

annotate service.ExpenseClaims with {
    policyViolation  @(
        Common.FieldControl  : #ReadOnly,
        Common.SemanticObject: 'ExpenseClaim',
        Common.Label : 'Policy Violation',
    );
    violationMessage @(
        Common.FieldControl: #ReadOnly,
        Common.Label       : 'Violation Reasons'
    )
};

annotate service.ExpenseClaims with @(

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
    },

    UI.DataPoint #StatusKPI : {
        $Type       : 'UI.DataPointType',
        Value       : status,
        Title       : 'Claim Status',
        Criticality : (status = 'DRAFT' ? 5 : status = 'PAID' ? 4 : status = 'APPROVED' ? 3 : status = 'SUBMITTED' ? 2 : status = 'REJECTED' ? 1 : 0),
    },
);
annotate service.ExpenseClaims with @(

    UI.HeaderFacets : [
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

annotate service.ExpenseClaims with actions {

    submitClaim @UI.Criticality : #Positive;
    withdrawClaim @UI.Criticality : #Negative;

};
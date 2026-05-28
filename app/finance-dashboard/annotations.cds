using ExpenseService as service from '../../srv/service';
using from '../../srv/service';

annotate ReimbursementService.FinanceDashboard with @(
    UI.LineItem                                     : [
        {
            $Type: 'UI.DataField',
            Value: claimDate,
            Label: 'Claim Date',
        },
        {
            $Type: 'UI.DataField',
            Value: employeeName,
            Label: 'Employee Name',
        },
        {
            $Type: 'UI.DataField',
            Value: claimTotal,
            Label: 'Total Claimed',
        },
        {
            $Type       : 'UI.DataField',
            Value       : violationMessage,
            Label       : 'Violation Message',
            Criticality : (violationMessage != null ? 1 : 0),
            CriticalityRepresentation:#WithoutIcon
        },
        {
            $Type: 'UI.DataField',
            Value: managerId,
            Label: 'Approved By',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action : 'ReimbursementService.EntityContainer/getPendingReimbursements',
            Label : 'Get Pending Reimbursements',
        },
        {
            $Type : 'UI.DataField',
            Value : status,
            Label : 'Claim Status',
            Criticality : (status = 'PAID' ? 3 : status = 'APPROVED' ? 2 : 0),
            CriticalityRepresentation:#WithoutIcon,

        },
    ],
    UI.SelectionPresentationVariant #tableView      : {
        $Type              : 'UI.SelectionPresentationVariantType',
        PresentationVariant: {
            $Type         : 'UI.PresentationVariantType',
            Visualizations: ['@UI.LineItem',
            ],
        },
        SelectionVariant   : {
            $Type        : 'UI.SelectionVariantType',
            SelectOptions: [],
        },
        Text               : 'Table View',
    },
    Analytics.AggregatedProperty #claimTotal_sum    : {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'claimTotal_sum',
        AggregatableProperty: claimTotal,
        AggregationMethod   : 'sum',
        @Common.Label       : 'Total Claim',
    },
    UI.Chart #alpChart                              : {
        $Type          : 'UI.ChartDefinitionType',
        ChartType      : #ColumnStackedDual,
        Dimensions     : [claimMonth, ],
        DynamicMeasures: [
            '@Analytics.AggregatedProperty#claimTotal_sum',
            '@Analytics.AggregatedProperty#violationCount_sum',
        ],
        Title : 'Claim Amount and Violations By Month',
    },
    Analytics.AggregatedProperty #violationCount_sum: {
        $Type               : 'Analytics.AggregatedPropertyType',
        Name                : 'violationCount_sum',
        AggregatableProperty: violationCount,
        AggregationMethod   : 'sum',
        @Common.Label       : 'Violation Count',
    },
    UI.DataPoint #claimDate                         : {
        $Type: 'UI.DataPointType',
        Value: claimDate,
        Title: 'Date',
    },
    UI.DataPoint #claimTotal                        : {
        $Type      : 'UI.DataPointType',
        Value      : claimTotal,
        Title      : 'Total Claimed Amount',
        Criticality: 3
    },
    UI.DataPoint #violationCount                    : {
        $Type       : 'UI.DataPointType',
        Value       : violationCount,
        Title       : 'Violation Count',
        Criticality : (violationCount > 0 ? 1 : 3)

    },
    UI.HeaderFacets                                 : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'claimDate',
            Target: '@UI.DataPoint#claimDate',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'claimTotal',
            Target: '@UI.DataPoint#claimTotal',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'violationCount',
            Target : '@UI.DataPoint#violationCount1',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'status',
            Target : '@UI.DataPoint#status',
        },
    ],
    UI.DataPoint #claimTotal1                       : {
        Value       : claimTotal,
        MinimumValue: 0,
        MaximumValue: 50000,
    },
    UI.Chart #claimTotal                            : {
        ChartType        : #Bullet,
        Title            : 'claimTotal',
        Measures         : [claimTotal, ],
        MeasureAttributes: [{
            DataPoint: '@UI.DataPoint#claimTotal1',
            Role     : #Axis1,
            Measure  : claimTotal,
        }, ],
    },
    Communication.Contact #contact1                 : {
        $Type: 'Communication.ContactType',
        fn   : employeeName,
        org  : departmentName,
        email : [
            {
                $Type : 'Communication.EmailAddressType',
                type : #work,
                address : employeeEmail,
            },
        ],
    },
    UI.Chart #visualFilter : {
        $Type : 'UI.ChartDefinitionType',
        ChartType : #Bar,
        Dimensions : [
            status,
        ],
        DynamicMeasures : [
            '@Analytics.AggregatedProperty#claimTotal_sum',
        ],
    },
    UI.PresentationVariant #visualFilter : {
        $Type : 'UI.PresentationVariantType',
        Visualizations : [
            '@UI.Chart#visualFilter',
        ],
    },
    UI.SelectionFields : [
        
    ],
    UI.DataPoint #violationCount1 : {
        $Type : 'UI.DataPointType',
        Value : claimViolation,
        Title : 'Is Policy Violated',
        Criticality:(claimViolation=true?1:3)
    },
    UI.DataPoint #status : {
        $Type : 'UI.DataPointType',
        Value : ReimbursementStatus,
        Title : 'Reimbursement Status',
        Criticality : (ReimbursementStatus = 'COMPLETED' ? 3 : ReimbursementStatus = 'PENDING' ? 2 : 0),
        CriticalityRepresentation:#WithoutIcon

    },
    UI.Chart #visualFilter1 : {
        $Type : 'UI.ChartDefinitionType',
        ChartType : #Bar,
        Dimensions : [
            departmentName,
        ],
        DynamicMeasures : [
            '@Analytics.AggregatedProperty#claimTotal_sum',
        ],
    },
    UI.PresentationVariant #visualFilter1 : {
        $Type : 'UI.PresentationVariantType',
        Visualizations : [
            '@UI.Chart#visualFilter1',
        ],
    },
);

annotate ReimbursementService.FinanceDashboard with @(

    UI.HeaderInfo              : {
        TypeName      : 'Finance Claim',
        TypeNamePlural: 'Finance Claims',
        Title         : {Value: employeeName},
        Description   : {Value: tripPurpose}
    },

    UI.FieldGroup #GeneralInfo : {Data : [
        {
            $Type: 'UI.DataField',
            Value: claimID,
            Label: 'Claim ID',
        },

        {
            $Type: 'UI.DataField',
            Value: claimDate,
            Label: 'Claim Date'
        },

        {
            $Type: 'UI.DataField',
            Value: employeeCode,
            Label: 'Employee Code'
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target: '@Communication.Contact#contact1',
            Label : 'Employee Details',
        },

        {
            $Type: 'UI.DataField',
            Value: tripPurpose,
            Label: 'Trip Purpose'
        },

        {
            $Type: 'UI.DataField',
            Value: status,
            Label: 'Claim Status',
            Criticality:#VeryPositive
        },

        {
            $Type: 'UI.DataField',
            Value: claimViolation,
            Label: 'Policy Violation',
            Criticality:(claimViolation>0?1:0),
            CriticalityRepresentation:#WithoutIcon
        },

        {
            $Type: 'UI.DataField',
            Value: violationCount,
            Label: 'Violation Count',
            Criticality : (violationCount > 0 ? 1 : 3)

        },

        {
            $Type: 'UI.DataField',
            Value: claimTotal,
            Label: 'Amount Claimed'
        },
        {
            $Type       : 'UI.DataField',
            Value       : violationMessage,
            Label       : 'Violation Message',
            Criticality : (violationMessage != null ? 1 : 0),
            CriticalityRepresentation:#WithoutIcon
        },
        {
            $Type: 'UI.DataField',
            Value: managerId,
            Label: 'Approver ID',
        },

    ]},

    UI.Facets                  : [

    {
        $Type : 'UI.ReferenceFacet',
        Label : 'General Information',
        Target: '@UI.FieldGroup#GeneralInfo'
    }],

    UI.Identification          : [

    {
        $Type : 'UI.DataFieldForAction',
        Action: 'ReimbursementService.Reimbursements.processReimbursement',
        Label : 'Process Reimbursement',
        Criticality:3
    }]
);
annotate ReimbursementService.FinanceDashboard with {
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
)};

annotate ReimbursementService.FinanceDashboard with {
    departmentName @(
        Common.Label : 'Department',
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Departments',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : departmentName,
                    ValueListProperty : 'name',
                },
            ],
        },
        Common.ValueListWithFixedValues : true,
        Common.ValueList #visualFilter : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'FinanceDashboard',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : departmentName,
                    ValueListProperty : 'departmentName',
                },
            ],
            PresentationVariantQualifier : 'visualFilter1',
        },
    )
};

annotate ReimbursementService.FinanceDashboard with @(

    Aggregation.ApplySupported : {

        Transformations : [
            'aggregate',
            'groupby',
            'filter',
            'search',
            'orderby',
            'top',
            'skip'
        ],

        GroupableProperties : [
            claimMonth,
            status,
            employeeName,
            departmentName,
            currency
        ],

        AggregatableProperties : [
            { Property : claimTotal },
            { Property : violationCount }
        ]
    },

    Analytics.AggregatedProperties : [

        {
            Name : 'sumClaimTotal',
            AggregationMethod : 'sum',
            AggregatableProperty : claimTotal,
            ![@Common.Label] : 'Total Claim Amount'
        },

        {
            Name : 'sumViolations',
            AggregationMethod : 'sum',
            AggregatableProperty : violationCount,
            ![@Common.Label] : 'Total Violations'
        }
    ]

);


annotate ReimbursementService.FinanceDashboard with {
    claimTotal @Measures.ISOCurrency : currency
};


using {expense.management as db} from '../db/schema';

@requires: ['Employee','Manager','Finance','Administrator']
service ExpenseService {
    function getUserInfo() returns {};

    @restrict: [
        {
            grant: ['READ'],
            to   : ['Manager','Finance','Employee']
        },
        {
            grant: ['*'],
            to   : 'Administrator'
        }
    ]
    entity Employees        as projection on db.Employees;

    @restrict: [
        {
            grant: ['READ'],
            to   : ['Manager','Finance','Employee']
        },
        {
            grant: ['*'],
            to   : 'Administrator'
        }
    ]
    entity ExpensePolicies  as projection on db.ExpensePolicies;

    @odata.draft.enabled
    @Capabilities.UpdateRestrictions: {Updatable: {$edmJson: {$Ne: [
        {$Path: 'status'},
        'APPROVED'
    ]}}}
    @Capabilities.DeleteRestrictions: {Deletable: {$edmJson: {$Ne: [
        {$Path: 'status'},
        ['APPROVED','REJECTED','PAID','WITHDRAWN','SUBMITTED']
    ]}}}
    @cds.redirection.target
    @restrict                       : [
        {
            grant: ['READ','UPDATE'],
            to   : ['Manager','Finance']
        },
        {
            grant: ['*'],
            to   : ['Administrator']
        },
        {
            grant: ['*'],
            to   : ['Employee'],
        }
    ]
    entity ExpenseClaims    as projection on db.ExpenseClaims
        actions {
            @Core.OperationAvailable: {$edmJson: {$Eq: [
                {$Path: 'status'},
                'DRAFT'
            ]}}
            @Common.IsActionCritical:true
            action submitClaim()   returns String;

            @Core.OperationAvailable: {$edmJson: {$In: [
                {$Path: 'status'},
                ['SUBMITTED']
            ]}}
            @Common.IsActionCritical:true
            action withdrawClaim() returns String;

            @Core.OperationAvailable: {$edmJson: {$In: [
                {$Path: 'status'},
                ['APPROVED','PAID']
            ]}}
            action getReimbursementStatus()

        };

    @cds.redirection.target
    @restrict: [
        {
            grant: ['READ'],
            to   : ['Manager','Finance']
        },
        {
            grant: ['*'],
            to   : ['Administrator']
        },
        {
            grant: ['*'],
            to   : ['Employee']
        } 
    ]
    entity ExpenseItems     as projection on db.ExpenseItems;

    entity statusView       as projection on db.statusView;
    entity CurrencyView     as projection on db.CurrencyView;
    entity categoryView     as projection on db.categoryView;

    // Manager Dashboard
    @readonly
    @restrict: [
        {
            grant: ['*'],
            to   : ['Administrator','Manager']
        }
    ]
    entity ManagerDashboard as
        projection on db.ExpenseClaims {
            ID,
            claimDate,
            tripPurpose,
            totalAmount,
            currency,
            status,
            policyViolation,
            violationMessage,
            violationCount,
            employee,
            approvedBy,
            items
        }
        actions {
            @Core.OperationAvailable: {$edmJson: {$Eq: [
                {$Path: 'status'},
                'SUBMITTED'
            ]}}
            @Common.IsActionCritical: true
            action approveClaim()              returns String;

            @Core.OperationAvailable: {$edmJson: {$Eq: [
                {$Path: 'status'},
                'SUBMITTED'
            ]}}
            action rejectClaim(reason: String) returns String;
        }
}


service ReimbursementService {
    @restrict:[
        {
            grant : ['*'],
            to : ['Administrator']
        },
        {
            grant : ['READ'],
            to : ['Finance']
        }
    ]
    entity Reimbursements   as projection on db.Reimbursements;

    function getPendingReimbursements() returns array of FinanceDashboard;

    @cds.redirection.target
    entity ExpenseClaims as projection on db.ExpenseClaims excluding {reimbursement};

    // @cds.redirection.target
    // @readonly
    // entity ExpenseItems     as projection on db.ExpenseItems;

    // @readonly
    // entity Employees        as projection on db.Employees;

    // @readonly
    // entity Managers         as projection on db.Managers;

    // @readonly
    // entity Departments      as projection on db.Departments;

    // @readonly
    // entity Currency         as projection on db.Currency;

    entity statusView       as projection on db.statusView;



    @restrict:[
        {
            grant : ['READ'],
            to    : ['Finance']
        },
        {
            grant : ['*'],
            to    : ['Administrator']
        }
    ]
    @cds.redirection.target
    @readonly
    entity FinanceDashboard as
        select from db.ExpenseClaims as claim
        left join db.Employees as emp
            on claim.employee.ID = emp.ID
        left join db.Departments as dept
            on emp.department.ID = dept.ID
        left join db.Managers as manager
            on emp.manager.ID = manager.ID
        left join db.Reimbursements as reim
            on reim.claim.ID = claim.ID
        {
            key claim.ID               as claimID        : UUID,
                claim.tripPurpose,
                claim.claimDate,
                claim.claimYearMonth   as claimMonth,
                claim.status           as status,
                claim.currency,
                claim.policyViolation  as claimViolation : Boolean,
                claim.violationCount   as violationCount : Integer,
                claim.violationMessage,
                claim.totalAmount      as claimTotal     : Decimal(15, 2),
                reim.status            as ReimbursementStatus : String,
                emp.empNo              as employeeCode   : String,
                emp.name               as employeeName   : String,
                emp.email              as employeeEmail  : String,
                dept.name              as departmentName : String,
                manager.managerId      as managerId      : String 
                   
        }actions{
            @restrict:[{grant:'*',to:'Finance'}]
            @Common.IsActionCritical:true
            @Core.OperationAvailable: {$edmJson: {$Eq: [
                {$Path: 'status'},
                'APPROVED',
            ]}}
            action processReimbursement() returns String;
        }

    
}

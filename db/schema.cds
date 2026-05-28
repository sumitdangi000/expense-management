namespace expense.management;

using {managed,cuid} from '@sap/cds/common';

entity ExpenseClaims : cuid, managed {
    employee         : Association to Employees;
    claimDate        : Date        @mandatory;
    claimYearMonth   : String(7);
    tripPurpose      : String(255) @mandatory;
    totalAmount      : Decimal(15, 2) default 0.00;
    currency         : String(3) default 'INR';
    status           : ClaimStatus default 'DRAFT';

    itemCount          : Integer default 0;
    violationItemCount : Integer default 0;

    approvedBy       : Association to Managers;
    paidOn           : Date;
    policyViolation  : Boolean default false;
    violationMessage : String(1000);
    violationCount   : Integer default 0;
    items            : Composition of many ExpenseItems
                           on items.claim = $self;
    reimbursement    : Association to one Reimbursements
                           on reimbursement.claim = $self;
}

entity ExpenseItems : cuid, managed {
    claim           : Association to ExpenseClaims;
    category        : ExpenseCategory @mandatory default 'OTHERS';
    expenseDate     : Date            @mandatory;
    amount          : Decimal(15, 2)  @mandatory;
    currency        : CurrencyType    @mandatory default 'INR';
    receipt         : LargeBinary     @Core.MediaType                  : receiptType
                                      @Core.ContentDisposition.Filename: receiptName;

    receiptType     : String          @Core.IsMediaType;
    receiptName     : String;
    description     : String(500) default null;
    policyViolation : Boolean default false;
}

entity Reimbursements : cuid, managed {
    claim         : Association to one ExpenseClaims @mandatory;
    processedBy   : Association to Managers;
    processedDate : Date;
    paymentRef    : String(100);
    status        : ReimbursementStatus default 'PENDING';
}

entity ExpensePolicies : cuid, managed {
    category          : ExpenseCategory @mandatory;
    maxAmountPerDay   : Decimal(15, 2);
    maxAmountPerClaim : Decimal(15, 2);
    receiptRequired   : Boolean default false;
}

entity Employees {
    key ID          : UUID;
        empNo       : String;
        name        : String(255);
        email       : String(255);
        bankAccount : String(100);
        department  : Association to Departments;
        manager     : Association to Managers;
}

@cds.autoexpose
entity Departments {
    key ID        : UUID;
        deptId    : String;
        name      : String;
        employees : Association to many Employees
                        on employees.department = $self;
}

@cds.autoexpose
entity Managers {
        managerId : String;
    key ID        : UUID;
        name      : String;
        employees : Association to many Employees
                        on employees.manager = $self;
}

entity Currency {
    key code : String(3);
        name : String;
}

@cds.persistence.skip
entity PendingReimbursements : cuid {
    employeeName : String;
    amount       : Decimal(15, 2);
    claimDate    : Date;
    status       : String;
}

type ExpenseCategory     : String enum {
    TRAVEL;
    INTERNET;
    FOOD;
    HOTEL;
    TRANSPORT;
    MEDICAL;
    OFFICE;
    OTHERS;
}

type ClaimStatus         : String enum {
    DRAFT;
    SUBMITTED;
    APPROVED;
    REJECTED;
    PAID;
    WITHDRAWN
}

type ReimbursementStatus : String enum {
    PENDING;
    PROCESSING;
    COMPLETED;
    FAILED;
    CANCELLED;
}

type CurrencyType        : String(3) enum {
    INR;
    USD;
    EUR;
    JPY;
    CNY;
    CAD;
    AUD;
    GBP;
}

entity CurrencyView as
    select from Currency {
        key code : String(3)
    }
    group by
        code;

entity categoryView as
    select from ExpensePolicies {
        key category
    }
    group by
        category;

entity statusView   as
    select from ExpenseClaims {
        key status
    }
    group by
        status;

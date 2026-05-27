const cds = require('@sap/cds');
const { DELETE, UPDATE, SELECT, INSERT } = cds.ql;

module.exports = cds.service.impl(async function () {
    const { ExpenseClaims, Employees, ExpenseItems, ExpensePolicies, ManagerDashboard } = this.entities('ExpenseService');
    const { Reimbursements, FinanceDashboard } = this.entities('ReimbursementService');

    // CONNECTION TO EXTERNAL CURRENCY API USING DESTINATIONS
    let currencyAPI = null;
    try {
        currencyAPI = await cds.connect.to('CurrencyAPILocal');
        console.log('Currency API connected');
    } catch (e) {
        console.log('Currency API connection failed:', e.message);
    }

    async function convertToINR(amount, currency) {
        if (currency === 'INR' || !currencyAPI) return Number(amount);
        try {
            const res = await currencyAPI.send({ method: 'GET', path: `/latest?from=${currency}&to=INR` });
            const rate = Number(res?.rates?.['INR']);
            return isFinite(rate) ? amount * rate : Number(amount.toFixed(2));
        } catch (e) {
            return Number(amount);
        }
    }

    async function calculateTotalInINR(items) {
        let total = 0;
        for (const item of items) {
            const amount = Number(item.amount);
            if (!isFinite(amount)) continue;
            const finalAmount = await convertToINR(amount, item.currency);
            if (isFinite(finalAmount)) total += finalAmount;
            console.log("Converted amount is:", finalAmount, "  total:", total);
        }
        return Number(total.toFixed(2));
    }

    async function validateItems(items) {
        let hasViolation = false;
        let violationCount = 0;
        let reasons = [];

        for (const item of items) {
            const policy = await SELECT.one.from(ExpensePolicies).where({ category: item.category });
            if (!policy) {
                item.policyViolation = false;
                continue;
            }
            const amountInINR = await convertToINR(item.amount, item.currency);

            let thisItemHasViolation = false;

            if (policy.maxAmountPerClaim && amountInINR > policy.maxAmountPerClaim) {
                thisItemHasViolation = true;
                hasViolation = true;
                violationCount++;
                reasons.push(`${item.category}: limit exceeded (${amountInINR.toFixed(2)} INR > ${policy.maxAmountPerClaim} INR)`);
            }

            const receiptIsMissing = !item.receipt || String(item.receipt).trim() === '';

            if (policy.receiptRequired && receiptIsMissing) {
                thisItemHasViolation = true;
                hasViolation = true;
                violationCount++;
                reasons.push(`${item.category}: receipt missing`);
            }

            if (policy.allowedCurrencies && !policy.allowedCurrencies.includes(item.currency)) {
                thisItemHasViolation = true;
                hasViolation = true;
                violationCount++;
                reasons.push(`${item.category}: currency ${item.currency} not allowed`);
            }

            item.policyViolation = thisItemHasViolation;
        }
        return { hasViolation, violationCount, reasons, items };
    }


    // RESTRICT MANAGER VIEW: Only show claims that are Submitted, Approved, or Rejected
    this.before('READ', 'ManagerDashboard', (req) => {
        req.query.where({ status: ['SUBMITTED', 'APPROVED', 'REJECTED'] });
    });


    // RESTRICT FINANCE-DASHBOARD VIEW
    this.before('READ', FinanceDashboard, (req) => {
        req.query.where({status: ['APPROVED', 'PAID'] });
    });


    // RESTRICT EMPLOYEE VIEW: Employees only see their own claims in the Portal
    this.before('READ', ExpenseClaims, (req) => {
        if (req.user.is('Employee') && !req.user.is('Administrator')) {
            req.query.where({ createdBy: req.user.id });
        }
    });


    // HIDE BANK ACCOUNT: for Manager and Employee roles
    this.after('READ', Employees, (data, req) => {
        if (!req.user.is('Finance') && !req.user.is('Administrator')) {
            const employees = Array.isArray(data) ? data : [data];
            employees.forEach(emp => delete emp.bankAccount);
        }
    });
    

    // BEFORE DELETE EXPENSE CLAIMS
    this.before('DELETE', ExpenseClaims, async (req) => {
        const claimID = req.data.ID || req.params?.[0]?.ID;
        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.reject(404, `Claim not found for claimID ${claimID}`);
        if (claim.status !== 'DRAFT') return req.reject(400, `Only DRAFT claims can be deleted. Current status: ${claim.status}`);
    });


    // BEFORE UPDATE EXPENSE CLAIMS 
    this.before('UPDATE', ExpenseClaims, async (req) => {
        const claimID = req.data.ID || req.params?.[0]?.ID;
        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.reject(404, `Claim not found for claimID ${claimID}`);
        if (claim.status !== 'DRAFT') return req.reject(400,`Only DRAFT claims can be updated. Current status: ${claim.status}`)
        const { items } = req.data;
        if (!items || items.length === 0) return;
        const { hasViolation, violationCount, reasons } = await validateItems(items);
        req.data.policyViolation = hasViolation;
        req.data.violationCount = violationCount;
        req.data.violationMessage = reasons.length > 0 ? [...new Set(reasons)].join('\n') : null;
        req.data.totalAmount = await calculateTotalInINR(items);
        req.data.currency = 'INR';
    });


    // BEFORE SUBMIT CLAIM ACTION
    this.before('submitClaim', async (req) => {
        const claimID = req.data?.claimID || req.params?.[0]?.ID;
        if (!claimID) return req.reject(400, 'Claim ID is required');

        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.reject(404, `Claim not found: ${claimID}`);

        const items = await SELECT.from(ExpenseItems)
            .columns('ID', 'category', 'amount', 'currency', 'receipt')
            .where({ claim_ID: claimID });
        if (!items.length) return req.reject(400, 'No items found for this claim');

        const { hasViolation, violationCount, reasons } = await validateItems(items);
        const receiptError = reasons.find(r => r.includes('receipt missing'));

        if (receiptError) {
            const category = receiptError.split(':')[0];
            return req.reject(400, `${category} requires a receipt. Please upload one before submitting.`);
        }
        for (const item of items) {
            await UPDATE(ExpenseItems)
                .set({ policyViolation: item.policyViolation })
                .where({ ID: item.ID });
        }
        const totalInINR = await calculateTotalInINR(items);
        await UPDATE(ExpenseClaims)
            .set({
                totalAmount: totalInINR,
                currency: 'INR',
                policyViolation: hasViolation,
                violationCount: violationCount,
                violationMessage: reasons.length > 0 ? [...new Set(reasons)].join('\n') : null,
                modifiedAt: new Date()
            })
            .where({ ID: claimID });
            return await SELECT.from(ExpenseClaims)
    });


    // SUBMIT CLAIM
    this.on('submitClaim', async (req) => {
        const claimID = req.data.claimID || req.params?.[0]?.ID;
        if (!claimID) return req.reject(400, 'Claim ID is missing from request');
        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.error(404, `Claim not found for claimID ${claimID}`);
        if (claim.status !== 'DRAFT') return req.error(400, 'Only DRAFT claims can be submitted');
        await UPDATE(ExpenseClaims).set({ status: 'SUBMITTED' }).where({ ID: claimID });
        req.notify(`Claim ${claimID} submitted for approval`);
        return 'Claim submitted successfully';
    });


    // APPROVE CLAIM
    this.on('approveClaim', 'ManagerDashboard', async (req) => {
        const claimID = req.data.claimID || req.params?.[0]?.ID;
        if (!claimID) return req.reject(400, 'Claim ID is required');
        const claim = await SELECT.one.from('expense.management.ExpenseClaims').where({ ID: claimID });
        if (!claim) return req.reject(404, `Claim not found for claimID ${claimID}`);
        if (claim.status !== 'SUBMITTED') return req.reject(400, `Only SUBMITTED claims can be approved. Current status: ${claim.status}`);
        await UPDATE('expense.management.ExpenseClaims').set({ status: 'APPROVED', approvedBy_ID: req.user.id, modifiedAt: new Date() }).where({ ID: claimID });
        await INSERT.into('expense.management.Reimbursements').entries({ claim_ID: claimID, status: 'PENDING' });
        console.log(`[Audit Log]: Claim ${claimID} approved by ${req.user.id} at ${new Date().toISOString()}`);
        req.notify(`Claim approved successfully`);
        return `Claim ${claimID} approved successfully.`;
    });


    // REJECT CLAIM
    this.on('rejectClaim', ManagerDashboard, async (req) => {
        const claimID = req.data.claimID || req.params?.[0]?.ID;
        const { reason } = req.data;
        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.error(404, `Claim not found for claimID ${claimID}`);
        if (claim.status !== 'SUBMITTED') return req.error(400, 'Only SUBMITTED claims can be rejected');
        if (!reason) return req.error(400, 'Rejection reason is required');
        await UPDATE(ExpenseClaims).set({ status: 'REJECTED', modifiedAt: new Date() }).where({ ID: claimID });
        req.notify(`Claim ${claimID} rejected. Reason: ${reason}`);
        return `Claim ${claimID} rejected.`;
    });


    // WITHDRAW CLAIM
    this.on('withdrawClaim', async (req) => {
        const claimID = req.data.claimID || req.params?.[0]?.ID;
        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.error(404, `Claim not found for claimID ${claimID}`);
        if (claim.status == 'REJECTED' || claim.status == 'PAID' || claim.status == 'WITHDRAWN') return req.error(400, `Can't withdraw - Claim already ${claim.status}`);
        await UPDATE(ExpenseClaims).set({ status: 'WITHDRAWN', modifiedAt: new Date() }).where({ ID: claimID });
        req.notify(`Claim ${claimID} withdrawn successfully.`);
        return `Claim ${claimID} withdrawn successfully.`;
    });


    // CHECK CLAIM AND BANK ACCOUNT BEFORE PROCESSING REIMBURSEMENT
    this.before('processReimbursement', async (req) => {
        const params = req.params?.[0]
        let claimID = params.claimID;
        if (!claimID) return req.reject(400, 'Claim ID is required');
        const claim = await SELECT.one.from(ExpenseClaims).where({ ID: claimID });
        if (!claim) return req.reject(404, `Claim not found for claimID ${claimID}`);
        if (claim.status !== 'APPROVED') return req.reject(400, 'Only APPROVED claims can be processed');
        const employee = await SELECT.one.from(Employees).where({ ID: claim.employee_ID });
        if (!employee?.bankAccount) {
            return req.reject(400, 'Employee bank account missing');
        }
        const reimbursement = await SELECT.one.from(Reimbursements).where({ claim_ID: claimID });
        if (!reimbursement) return req.reject(404, 'Reimbursement record not found');
        if (reimbursement.status !== 'PENDING') return req.reject(400,`Reimbursement already ${reimbursement.status}`);
    });


    // PROCESS REIMBURSEMENT
    this.on('processReimbursement', async (req) => {
        const params = req.params?.[0];
        const claimID = params.claimID 
        const paymentRef = `PAY-${Date.now()}`;
        await UPDATE(Reimbursements).set({processedDate: new Date(),paymentRef,status: 'COMPLETED'}).where({ claim_ID: claimID });
        await UPDATE(ExpenseClaims).set({status: 'PAID'}).where({ ID: claimID });
        req.notify(`Payment processed for claim ${claimID}.`);
        return `Payment processed for claim ${claimID}.`;
    });


    // GET PENDING REIMBURSEMENTS
    this.on('getPendingReimbursements', async () => {
        const response = await SELECT.from(FinanceDashboard)
            .where({ status: 'APPROVED' })
            .and('claimID not in', SELECT.from(Reimbursements).columns('claim_ID'));
        console.log(response);
        return response  
    });


    // GET REIMBURSEMENT STATUS
    this.on('getReimbursementStatus', async (req) => {
        const claimID = req.params?.[0]?.ID || req.data.claimID;
        if (!claimID) return req.reject(400, 'Claim ID is missing');
        const claim = await SELECT.one.from(ExpenseClaims).columns('status').where({ ID: claimID });
        if (!claim) return req.reject(404, 'Claim not found');
        if (!claim.status === 'APPROVED') req.reject(400, "Reimbursements Status available only for Approved Claims");
        const reimbursement = await SELECT.one.from(Reimbursements).where({ claim_ID: claimID });
        if (!reimbursement) req.reject(400, "No reimbursement status found for this claim.\nPlease contact Finance Dept.")
        req.info(`Reimbursement status  : ${reimbursement?.status}\nPayment Reference No : ${reimbursement?.paymentRef}`);
    });


    // BEFORE CREATE EXPENSE CLAIMS
    this.before('CREATE', ExpenseClaims, async (req) => {
        const { items,claimDate } = req.data;
        if(claimDate>(new Date().toISOString().slice(0,10))) req.reject(400,"Future Claim Date is not allowed")
        console.log("req user data: ",req.user);
        req.data.employee_ID = req.user.id;
        console.log("employee ID auto filled: ",req.data.employee_ID);
        if (!items || items.length === 0) return;
        const { hasViolation, violationCount, reasons } = await validateItems(items);
        req.data.policyViolation = hasViolation;
        req.data.violationCount = violationCount;
        req.data.violationMessage = reasons.length > 0 ? [...new Set(reasons)].join('\n') : null;
        req.data.totalAmount = await calculateTotalInINR(items);
        req.data.currency = 'INR';
    });


    // BEFORE CREATE EXPENSE ITEMS
    this.on('CREATE',ExpenseItems,async(req)=>{
        const {claimID,expenseDate} = req.data;
        console.log("items:",claimID);
        const claim = await SELECT.one.from(ExpenseClaims).where({ID:claimID});
        if(!claim) req.reject(400,"No claim found")
        if(claim.claimDate<expenseDate) req.reject(400,"Expense Date must be older or equal to Claim Date") 
    })


    // AUTO-FILL EMPLOYEE AND TODAY'S DATE
    this.before('NEW','ExpenseClaims.drafts',async(req)=>{
        req.data.employee_ID = req.user.id;
        req.data.claimDate = new Date()//.toISOString().slice(0,10);
    })


    // FOR MONTHLY ANALYTICS
    this.after('READ', 'FinanceDashboard', (data) => {
        const records = Array.isArray(data) ? data : [data];
        records.forEach(record => {
            if (record.claimDate) {
                const date = new Date(record.claimDate);
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0');
                record.claimYearMonth = `${year}-${month}`;
            }
        });
    });


    // FUNCTION TO GET USER DETAILS
    this.on('getUserInfo',async(req)=>{
        console.log(req.user);
        const roles = Object.keys(req.user.roles);
        return(`User ID : ${req.user.id}
                Name : ${req.user.name}
                Email : ${req.user.email}
                Roles : ${roles.join(',')}`)
    })
});


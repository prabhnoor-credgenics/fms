package models.loanrecovery;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;


public class LoanRecoveryRequest {
    
    @JsonProperty("loan_id")
    private String loanId;
    
    @JsonProperty("client_customer_id")
    private String clientCustomerId;
    
    @JsonProperty("loan_type")
    private String loanType;
    
    @JsonProperty("applicant_name")
    private String applicantName;
    
    @JsonProperty("applicant_dob")
    private String applicantDob;
    
    @JsonProperty("applicant_email")
    private String applicantEmail;
    
    @JsonProperty("applicant_gender")
    private String applicantGender;
    
    @JsonProperty("applicant_contact_number")
    private String applicantContactNumber;
    
    @JsonProperty("applicant_monthly_income")
    private Integer applicantMonthlyIncome;
    
    @JsonProperty("applicant_cibil_score")
    private Integer applicantCibilScore;
    
    @JsonProperty("applicant_occupation")
    private String applicantOccupation;
    
    @JsonProperty("applicant_aadhar_number")
    private String applicantAadharNumber;
    
    @JsonProperty("applicant_language")
    private String applicantLanguage;
    
    @JsonProperty("applicant_pan_number")
    private String applicantPanNumber;
    
    @JsonProperty("total_loan_amount")
    private Integer totalLoanAmount;
    
    @JsonProperty("loan_tenure")
    private Integer loanTenure;
    
    @JsonProperty("client_loan_sanction_date")
    private String clientLoanSanctionDate;
    
    @JsonProperty("loan_end_date")
    private String loanEndDate;
    
    @JsonProperty("interest_on_loan")
    private Integer interestOnLoan;
    
    @JsonProperty("tenure_finished")
    private Boolean tenureFinished;
    
    @JsonProperty("security_type")
    private String securityType;
    
    @JsonProperty("backed_by_surety")
    private Boolean backedBySurety;
    
    @JsonProperty("loan_nbfc_name")
    private String loanNbfcName;
    
    @JsonProperty("loan_nbfc_cin")
    private String loanNbfcCin;
    
    @JsonProperty("emi_amount")
    private Integer emiAmount;
    
    @JsonProperty("product_type")
    private String productType;
    
    @JsonProperty("credit_account_number")
    private String creditAccountNumber;
    
    @JsonProperty("credit_account_holder_name")
    private String creditAccountHolderName;
    
    @JsonProperty("credit_bank_name")
    private String creditBankName;
    
    @JsonProperty("credit_account_holder_type")
    private String creditAccountHolderType;
    
    @JsonProperty("credit_bank_ifsc_code")
    private String creditBankIfscCode;
    
    @JsonProperty("document_details")
    private List<DocumentDetail> documentDetails;
    
    @JsonProperty("business_name")
    private String businessName;
    
    @JsonProperty("applicant_address")
    private List<ApplicantAddress> applicantAddress;
    
    @JsonProperty("defaults")
    private List<LoanDefault> defaults;
    
    @JsonProperty("co_applicant")
    private List<CoApplicant> coApplicant;
    

    public LoanRecoveryRequest() {
    }
    
  
    public String getLoanId() {
        return loanId;
    }
    
    public void setLoanId(String loanId) {
        this.loanId = loanId;
    }
    
    public String getClientCustomerId() {
        return clientCustomerId;
    }
    
    public void setClientCustomerId(String clientCustomerId) {
        this.clientCustomerId = clientCustomerId;
    }
    
    public String getLoanType() {
        return loanType;
    }
    
    public void setLoanType(String loanType) {
        this.loanType = loanType;
    }
    
    public String getApplicantName() {
        return applicantName;
    }
    
    public void setApplicantName(String applicantName) {
        this.applicantName = applicantName;
    }
    
    public String getApplicantDob() {
        return applicantDob;
    }
    
    public void setApplicantDob(String applicantDob) {
        this.applicantDob = applicantDob;
    }
    
    public String getApplicantEmail() {
        return applicantEmail;
    }
    
    public void setApplicantEmail(String applicantEmail) {
        this.applicantEmail = applicantEmail;
    }
    
    public String getApplicantGender() {
        return applicantGender;
    }
    
    public void setApplicantGender(String applicantGender) {
        this.applicantGender = applicantGender;
    }
    
    public String getApplicantContactNumber() {
        return applicantContactNumber;
    }
    
    public void setApplicantContactNumber(String applicantContactNumber) {
        this.applicantContactNumber = applicantContactNumber;
    }
    
    public Integer getApplicantMonthlyIncome() {
        return applicantMonthlyIncome;
    }
    
    public void setApplicantMonthlyIncome(Integer applicantMonthlyIncome) {
        this.applicantMonthlyIncome = applicantMonthlyIncome;
    }
    
    public Integer getApplicantCibilScore() {
        return applicantCibilScore;
    }
    
    public void setApplicantCibilScore(Integer applicantCibilScore) {
        this.applicantCibilScore = applicantCibilScore;
    }
    
    public String getApplicantOccupation() {
        return applicantOccupation;
    }
    
    public void setApplicantOccupation(String applicantOccupation) {
        this.applicantOccupation = applicantOccupation;
    }
    
    public String getApplicantAadharNumber() {
        return applicantAadharNumber;
    }
    
    public void setApplicantAadharNumber(String applicantAadharNumber) {
        this.applicantAadharNumber = applicantAadharNumber;
    }
    
    public String getApplicantLanguage() {
        return applicantLanguage;
    }
    
    public void setApplicantLanguage(String applicantLanguage) {
        this.applicantLanguage = applicantLanguage;
    }
    
    public String getApplicantPanNumber() {
        return applicantPanNumber;
    }
    
    public void setApplicantPanNumber(String applicantPanNumber) {
        this.applicantPanNumber = applicantPanNumber;
    }
    
    public Integer getTotalLoanAmount() {
        return totalLoanAmount;
    }
    
    public void setTotalLoanAmount(Integer totalLoanAmount) {
        this.totalLoanAmount = totalLoanAmount;
    }
    
    public Integer getLoanTenure() {
        return loanTenure;
    }
    
    public void setLoanTenure(Integer loanTenure) {
        this.loanTenure = loanTenure;
    }
    
    public String getClientLoanSanctionDate() {
        return clientLoanSanctionDate;
    }
    
    public void setClientLoanSanctionDate(String clientLoanSanctionDate) {
        this.clientLoanSanctionDate = clientLoanSanctionDate;
    }
    
    public String getLoanEndDate() {
        return loanEndDate;
    }
    
    public void setLoanEndDate(String loanEndDate) {
        this.loanEndDate = loanEndDate;
    }
    
    public Integer getInterestOnLoan() {
        return interestOnLoan;
    }
    
    public void setInterestOnLoan(Integer interestOnLoan) {
        this.interestOnLoan = interestOnLoan;
    }
    
    public Boolean getTenureFinished() {
        return tenureFinished;
    }
    
    public void setTenureFinished(Boolean tenureFinished) {
        this.tenureFinished = tenureFinished;
    }
    
    public String getSecurityType() {
        return securityType;
    }
    
    public void setSecurityType(String securityType) {
        this.securityType = securityType;
    }
    
    public Boolean getBackedBySurety() {
        return backedBySurety;
    }
    
    public void setBackedBySurety(Boolean backedBySurety) {
        this.backedBySurety = backedBySurety;
    }
    
    public String getLoanNbfcName() {
        return loanNbfcName;
    }
    
    public void setLoanNbfcName(String loanNbfcName) {
        this.loanNbfcName = loanNbfcName;
    }
    
    public String getLoanNbfcCin() {
        return loanNbfcCin;
    }
    
    public void setLoanNbfcCin(String loanNbfcCin) {
        this.loanNbfcCin = loanNbfcCin;
    }
    
    public Integer getEmiAmount() {
        return emiAmount;
    }
    
    public void setEmiAmount(Integer emiAmount) {
        this.emiAmount = emiAmount;
    }
    
    public String getProductType() {
        return productType;
    }
    
    public void setProductType(String productType) {
        this.productType = productType;
    }
    
    public String getCreditAccountNumber() {
        return creditAccountNumber;
    }
    
    public void setCreditAccountNumber(String creditAccountNumber) {
        this.creditAccountNumber = creditAccountNumber;
    }
    
    public String getCreditAccountHolderName() {
        return creditAccountHolderName;
    }
    
    public void setCreditAccountHolderName(String creditAccountHolderName) {
        this.creditAccountHolderName = creditAccountHolderName;
    }
    
    public String getCreditBankName() {
        return creditBankName;
    }
    
    public void setCreditBankName(String creditBankName) {
        this.creditBankName = creditBankName;
    }
    
    public String getCreditAccountHolderType() {
        return creditAccountHolderType;
    }
    
    public void setCreditAccountHolderType(String creditAccountHolderType) {
        this.creditAccountHolderType = creditAccountHolderType;
    }
    
    public String getCreditBankIfscCode() {
        return creditBankIfscCode;
    }
    
    public void setCreditBankIfscCode(String creditBankIfscCode) {
        this.creditBankIfscCode = creditBankIfscCode;
    }
    
    public List<DocumentDetail> getDocumentDetails() {
        return documentDetails;
    }
    
    public void setDocumentDetails(List<DocumentDetail> documentDetails) {
        this.documentDetails = documentDetails;
    }
    
    public String getBusinessName() {
        return businessName;
    }
    
    public void setBusinessName(String businessName) {
        this.businessName = businessName;
    }
    
    public List<ApplicantAddress> getApplicantAddress() {
        return applicantAddress;
    }
    
    public void setApplicantAddress(List<ApplicantAddress> applicantAddress) {
        this.applicantAddress = applicantAddress;
    }
    
    public List<LoanDefault> getDefaults() {
        return defaults;
    }
    
    public void setDefaults(List<LoanDefault> defaults) {
        this.defaults = defaults;
    }
    
    public List<CoApplicant> getCoApplicant() {
        return coApplicant;
    }
    
    public void setCoApplicant(List<CoApplicant> coApplicant) {
        this.coApplicant = coApplicant;
    }
}
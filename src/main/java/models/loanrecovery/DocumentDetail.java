package models.loanrecovery;

import com.fasterxml.jackson.annotation.JsonProperty;


public class DocumentDetail {
    
    @JsonProperty("security_mode")
    private String securityMode;
    
    @JsonProperty("document_number")
    private String documentNumber;
    
    @JsonProperty("document_bank_name")
    private String documentBankName;
    
    @JsonProperty("document_bank_ifsc_code")
    private String documentBankIfscCode;
    
    @JsonProperty("document_amount")
    private Integer documentAmount;
    
    @JsonProperty("document_date")
    private String documentDate;
    
    @JsonProperty("document_dishonour_date")
    private String documentDishonourDate;
    
    @JsonProperty("document_signature_name")
    private String documentSignatureName;
    
    @JsonProperty("document_bounce_bank_account_number")
    private String documentBounceBankAccountNumber;
    
    @JsonProperty("document_bounce_bank_ifsc_code")
    private String documentBounceBankIfscCode;
    
    @JsonProperty("document_bounce_charges")
    private Integer documentBounceCharges;
    
    @JsonProperty("document_bounce_bank_name")
    private String documentBounceBankName;
    
    @JsonProperty("document_bounce_bank_address")
    private String documentBounceBankAddress;
    
    @JsonProperty("document_bounce_memo_date")
    private String documentBounceMemoDate;
    
    @JsonProperty("reason_of_document_bounce")
    private String reasonOfDocumentBounce;
    
    @JsonProperty("document_bounce_memo_reference_number")
    private String documentBounceMemoReferenceNumber;
    
    @JsonProperty("document_sequence_number")
    private String documentSequenceNumber;
    
    @JsonProperty("document_bounce_memo_return_date")
    private String documentBounceMemoReturnDate;
    

    public DocumentDetail() {
    }
    

    public String getSecurityMode() {
        return securityMode;
    }
    
    public void setSecurityMode(String securityMode) {
        this.securityMode = securityMode;
    }
    
    public String getDocumentNumber() {
        return documentNumber;
    }
    
    public void setDocumentNumber(String documentNumber) {
        this.documentNumber = documentNumber;
    }
    
    public String getDocumentBankName() {
        return documentBankName;
    }
    
    public void setDocumentBankName(String documentBankName) {
        this.documentBankName = documentBankName;
    }
    
    public String getDocumentBankIfscCode() {
        return documentBankIfscCode;
    }
    
    public void setDocumentBankIfscCode(String documentBankIfscCode) {
        this.documentBankIfscCode = documentBankIfscCode;
    }
    
    public Integer getDocumentAmount() {
        return documentAmount;
    }
    
    public void setDocumentAmount(Integer documentAmount) {
        this.documentAmount = documentAmount;
    }
    
    public String getDocumentDate() {
        return documentDate;
    }
    
    public void setDocumentDate(String documentDate) {
        this.documentDate = documentDate;
    }
    
    public String getDocumentDishonourDate() {
        return documentDishonourDate;
    }
    
    public void setDocumentDishonourDate(String documentDishonourDate) {
        this.documentDishonourDate = documentDishonourDate;
    }
    
    public String getDocumentSignatureName() {
        return documentSignatureName;
    }
    
    public void setDocumentSignatureName(String documentSignatureName) {
        this.documentSignatureName = documentSignatureName;
    }
    
    public String getDocumentBounceBankAccountNumber() {
        return documentBounceBankAccountNumber;
    }
    
    public void setDocumentBounceBankAccountNumber(String documentBounceBankAccountNumber) {
        this.documentBounceBankAccountNumber = documentBounceBankAccountNumber;
    }
    
    public String getDocumentBounceBankIfscCode() {
        return documentBounceBankIfscCode;
    }
    
    public void setDocumentBounceBankIfscCode(String documentBounceBankIfscCode) {
        this.documentBounceBankIfscCode = documentBounceBankIfscCode;
    }
    
    public Integer getDocumentBounceCharges() {
        return documentBounceCharges;
    }
    
    public void setDocumentBounceCharges(Integer documentBounceCharges) {
        this.documentBounceCharges = documentBounceCharges;
    }
    
    public String getDocumentBounceBankName() {
        return documentBounceBankName;
    }
    
    public void setDocumentBounceBankName(String documentBounceBankName) {
        this.documentBounceBankName = documentBounceBankName;
    }
    
    public String getDocumentBounceBankAddress() {
        return documentBounceBankAddress;
    }
    
    public void setDocumentBounceBankAddress(String documentBounceBankAddress) {
        this.documentBounceBankAddress = documentBounceBankAddress;
    }
    
    public String getDocumentBounceMemoDate() {
        return documentBounceMemoDate;
    }
    
    public void setDocumentBounceMemoDate(String documentBounceMemoDate) {
        this.documentBounceMemoDate = documentBounceMemoDate;
    }
    
    public String getReasonOfDocumentBounce() {
        return reasonOfDocumentBounce;
    }
    
    public void setReasonOfDocumentBounce(String reasonOfDocumentBounce) {
        this.reasonOfDocumentBounce = reasonOfDocumentBounce;
    }
    
    public String getDocumentBounceMemoReferenceNumber() {
        return documentBounceMemoReferenceNumber;
    }
    
    public void setDocumentBounceMemoReferenceNumber(String documentBounceMemoReferenceNumber) {
        this.documentBounceMemoReferenceNumber = documentBounceMemoReferenceNumber;
    }
    
    public String getDocumentSequenceNumber() {
        return documentSequenceNumber;
    }
    
    public void setDocumentSequenceNumber(String documentSequenceNumber) {
        this.documentSequenceNumber = documentSequenceNumber;
    }
    
    public String getDocumentBounceMemoReturnDate() {
        return documentBounceMemoReturnDate;
    }
    
    public void setDocumentBounceMemoReturnDate(String documentBounceMemoReturnDate) {
        this.documentBounceMemoReturnDate = documentBounceMemoReturnDate;
    }
}
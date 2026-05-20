package models.loanrecovery;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;


public class CoApplicant {
    
    @JsonProperty("co_applicant_dob")
    private String coApplicantDob;
    
    @JsonProperty("co_applicant_name")
    private String coApplicantName;
    
    @JsonProperty("co_applicant_type")
    private String coApplicantType;
    
    @JsonProperty("co_applicant_email")
    private String coApplicantEmail;
    
    @JsonProperty("co_applicant_gender")
    private String coApplicantGender;
    
    @JsonProperty("co_applicant_address")
    private List<CoApplicantAddress> coApplicantAddress;
    
    @JsonProperty("co_applicant_language")
    private String coApplicantLanguage;
    
    @JsonProperty("co_applicant_pan_number")
    private String coApplicantPanNumber;
    
    @JsonProperty("co_applicant_contact_number")
    private String coApplicantContactNumber;
    
    @JsonProperty("co_applicant_notice_reference_number")
    private String coApplicantNoticeReferenceNumber;
    

    public CoApplicant() {
    }
    

    public String getCoApplicantDob() {
        return coApplicantDob;
    }
    
    public void setCoApplicantDob(String coApplicantDob) {
        this.coApplicantDob = coApplicantDob;
    }
    
    public String getCoApplicantName() {
        return coApplicantName;
    }
    
    public void setCoApplicantName(String coApplicantName) {
        this.coApplicantName = coApplicantName;
    }
    
    public String getCoApplicantType() {
        return coApplicantType;
    }
    
    public void setCoApplicantType(String coApplicantType) {
        this.coApplicantType = coApplicantType;
    }
    
    public String getCoApplicantEmail() {
        return coApplicantEmail;
    }
    
    public void setCoApplicantEmail(String coApplicantEmail) {
        this.coApplicantEmail = coApplicantEmail;
    }
    
    public String getCoApplicantGender() {
        return coApplicantGender;
    }
    
    public void setCoApplicantGender(String coApplicantGender) {
        this.coApplicantGender = coApplicantGender;
    }
    
    public List<CoApplicantAddress> getCoApplicantAddress() {
        return coApplicantAddress;
    }
    
    public void setCoApplicantAddress(List<CoApplicantAddress> coApplicantAddress) {
        this.coApplicantAddress = coApplicantAddress;
    }
    
    public String getCoApplicantLanguage() {
        return coApplicantLanguage;
    }
    
    public void setCoApplicantLanguage(String coApplicantLanguage) {
        this.coApplicantLanguage = coApplicantLanguage;
    }
    
    public String getCoApplicantPanNumber() {
        return coApplicantPanNumber;
    }
    
    public void setCoApplicantPanNumber(String coApplicantPanNumber) {
        this.coApplicantPanNumber = coApplicantPanNumber;
    }
    
    public String getCoApplicantContactNumber() {
        return coApplicantContactNumber;
    }
    
    public void setCoApplicantContactNumber(String coApplicantContactNumber) {
        this.coApplicantContactNumber = coApplicantContactNumber;
    }
    
    public String getCoApplicantNoticeReferenceNumber() {
        return coApplicantNoticeReferenceNumber;
    }
    
    public void setCoApplicantNoticeReferenceNumber(String coApplicantNoticeReferenceNumber) {
        this.coApplicantNoticeReferenceNumber = coApplicantNoticeReferenceNumber;
    }
}
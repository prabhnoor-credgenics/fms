package models.loanrecovery;

import com.fasterxml.jackson.annotation.JsonProperty;


public class ApplicantAddress {
    
    @JsonProperty("applicant_address_type")
    private String applicantAddressType;
    
    @JsonProperty("applicant_address_text")
    private String applicantAddressText;
    
    @JsonProperty("applicant_city")
    private String applicantCity;
    
    @JsonProperty("applicant_state")
    private String applicantState;
    
    @JsonProperty("applicant_pincode")
    private Integer applicantPincode;
    
    @JsonProperty("applicant_landmark")
    private String applicantLandmark;
    

    public ApplicantAddress() {
    }
    

    public String getApplicantAddressType() {
        return applicantAddressType;
    }
    
    public void setApplicantAddressType(String applicantAddressType) {
        this.applicantAddressType = applicantAddressType;
    }
    
    public String getApplicantAddressText() {
        return applicantAddressText;
    }
    
    public void setApplicantAddressText(String applicantAddressText) {
        this.applicantAddressText = applicantAddressText;
    }
    
    public String getApplicantCity() {
        return applicantCity;
    }
    
    public void setApplicantCity(String applicantCity) {
        this.applicantCity = applicantCity;
    }
    
    public String getApplicantState() {
        return applicantState;
    }
    
    public void setApplicantState(String applicantState) {
        this.applicantState = applicantState;
    }
    
    public Integer getApplicantPincode() {
        return applicantPincode;
    }
    
    public void setApplicantPincode(Integer applicantPincode) {
        this.applicantPincode = applicantPincode;
    }
    
    public String getApplicantLandmark() {
        return applicantLandmark;
    }
    
    public void setApplicantLandmark(String applicantLandmark) {
        this.applicantLandmark = applicantLandmark;
    }
}
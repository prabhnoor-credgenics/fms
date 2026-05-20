package models.loanrecovery;

import com.fasterxml.jackson.annotation.JsonProperty;


public class CoApplicantAddress {
    
    @JsonProperty("co_applicant_city")
    private String coApplicantCity;
    
    @JsonProperty("co_applicant_state")
    private String coApplicantState;
    
    @JsonProperty("co_applicant_pincode")
    private Integer coApplicantPincode;
    
    @JsonProperty("co_applicant_address_text")
    private String coApplicantAddressText;
    
    @JsonProperty("co_applicant_address_type")
    private String coApplicantAddressType;
    

    public CoApplicantAddress() {
    }
    

    public String getCoApplicantCity() {
        return coApplicantCity;
    }
    
    public void setCoApplicantCity(String coApplicantCity) {
        this.coApplicantCity = coApplicantCity;
    }
    
    public String getCoApplicantState() {
        return coApplicantState;
    }
    
    public void setCoApplicantState(String coApplicantState) {
        this.coApplicantState = coApplicantState;
    }
    
    public Integer getCoApplicantPincode() {
        return coApplicantPincode;
    }
    
    public void setCoApplicantPincode(Integer coApplicantPincode) {
        this.coApplicantPincode = coApplicantPincode;
    }
    
    public String getCoApplicantAddressText() {
        return coApplicantAddressText;
    }
    
    public void setCoApplicantAddressText(String coApplicantAddressText) {
        this.coApplicantAddressText = coApplicantAddressText;
    }
    
    public String getCoApplicantAddressType() {
        return coApplicantAddressType;
    }
    
    public void setCoApplicantAddressType(String coApplicantAddressType) {
        this.coApplicantAddressType = coApplicantAddressType;
    }
}
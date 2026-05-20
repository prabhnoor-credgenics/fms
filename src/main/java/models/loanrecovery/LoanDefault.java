package models.loanrecovery;

import com.fasterxml.jackson.annotation.JsonProperty;


public class LoanDefault {
    
    @JsonProperty("allocation_month")
    private String allocationMonth;
    
    @JsonProperty("total_claim_amount")
    private Integer totalClaimAmount;
    
    @JsonProperty("late_fee")
    private Integer lateFee;
    
    @JsonProperty("date_of_default")
    private String dateOfDefault;
    
    @JsonProperty("expected_emi")
    private Integer expectedEmi;
    
    @JsonProperty("default_emi_number")
    private Integer defaultEmiNumber;
    
    @JsonProperty("settlement_amount")
    private Integer settlementAmount;
    
    @JsonProperty("client_amount_recovered")
    private Integer clientAmountRecovered;
    
    @JsonProperty("principal_outstanding_amount")
    private Integer principalOutstandingAmount;
    
    @JsonProperty("expected_emi_principal_amount")
    private Integer expectedEmiPrincipalAmount;
    

    public LoanDefault() {
    }
    

    public String getAllocationMonth() {
        return allocationMonth;
    }
    
    public void setAllocationMonth(String allocationMonth) {
        this.allocationMonth = allocationMonth;
    }
    
    public Integer getTotalClaimAmount() {
        return totalClaimAmount;
    }
    
    public void setTotalClaimAmount(Integer totalClaimAmount) {
        this.totalClaimAmount = totalClaimAmount;
    }
    
    public Integer getLateFee() {
        return lateFee;
    }
    
    public void setLateFee(Integer lateFee) {
        this.lateFee = lateFee;
    }
    
    public String getDateOfDefault() {
        return dateOfDefault;
    }
    
    public void setDateOfDefault(String dateOfDefault) {
        this.dateOfDefault = dateOfDefault;
    }
    
    public Integer getExpectedEmi() {
        return expectedEmi;
    }
    
    public void setExpectedEmi(Integer expectedEmi) {
        this.expectedEmi = expectedEmi;
    }
    
    public Integer getDefaultEmiNumber() {
        return defaultEmiNumber;
    }
    
    public void setDefaultEmiNumber(Integer defaultEmiNumber) {
        this.defaultEmiNumber = defaultEmiNumber;
    }
    
    public Integer getSettlementAmount() {
        return settlementAmount;
    }
    
    public void setSettlementAmount(Integer settlementAmount) {
        this.settlementAmount = settlementAmount;
    }
    
    public Integer getClientAmountRecovered() {
        return clientAmountRecovered;
    }
    
    public void setClientAmountRecovered(Integer clientAmountRecovered) {
        this.clientAmountRecovered = clientAmountRecovered;
    }
    
    public Integer getPrincipalOutstandingAmount() {
        return principalOutstandingAmount;
    }
    
    public void setPrincipalOutstandingAmount(Integer principalOutstandingAmount) {
        this.principalOutstandingAmount = principalOutstandingAmount;
    }
    
    public Integer getExpectedEmiPrincipalAmount() {
        return expectedEmiPrincipalAmount;
    }
    
    public void setExpectedEmiPrincipalAmount(Integer expectedEmiPrincipalAmount) {
        this.expectedEmiPrincipalAmount = expectedEmiPrincipalAmount;
    }
}
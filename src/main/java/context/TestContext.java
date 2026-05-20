package context;

import io.restassured.response.Response;

import java.util.HashMap;
import java.util.Map;


public class TestContext {

    private String authToken;
    private String companyId;
    private String trademark;
    private String companyName;
    private String companyEmail;
    private String adminEmail;
    private String authorizedRepresentativeName;
    private String adminFirstName;
    private String adminLastName;
    private String profileId;
    private String userId;
    private String companyType;
    private String clientType;
    private String companySubType;
    private String tenantType;
    private Response response;
    private String lastRequestBody;


    private String scenarioLoanId;
    private String scenarioCompanyId;
    private String scenarioAllocationMonth;
    private String scenarioName;

    private int userSlot;

    private final Map<String, String> randomStringCache = new HashMap<>();

    public Response getResponse() {
        return response;
    }

    public void setResponse(Response response) {
        this.response = response;
    }

    public String getLastRequestBody() {
        return lastRequestBody;
    }

    public void setLastRequestBody(String lastRequestBody) {
        this.lastRequestBody = lastRequestBody;
    }

    public String getAuthToken() {
        return authToken;
    }

    public void setAuthToken(String token) {
        this.authToken = token;
    }

    public String getCompanyId() {
        return companyId;
    }

    public void setCompanyId(String id) {
        this.companyId = id;
    }

    public String getTrademark() {
        return trademark;
    }

    public void setTrademark(String trademark) {
        this.trademark = trademark;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getCompanyEmail() {
        return companyEmail;
    }

    public void setCompanyEmail(String companyEmail) {
        this.companyEmail = companyEmail;
    }

    public String getAdminEmail() {
        return adminEmail;
    }

    public void setAdminEmail(String adminEmail) {
        this.adminEmail = adminEmail;
    }

    public String getAuthorizedRepresentativeName() {
        return authorizedRepresentativeName;
    }

    public void setAuthorizedRepresentativeName(String authorizedRepresentativeName) {
        this.authorizedRepresentativeName = authorizedRepresentativeName;
    }

    public String getAdminFirstName() {
        return adminFirstName;
    }

    public void setAdminFirstName(String adminFirstName) {
        this.adminFirstName = adminFirstName;
    }

    public String getAdminLastName() {
        return adminLastName;
    }

    public void setAdminLastName(String adminLastName) {
        this.adminLastName = adminLastName;
    }

    public String getProfileId() {
        return profileId;
    }

    public void setProfileId(String profileId) {
        this.profileId = profileId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getCompanyType() {
        return companyType;
    }

    public void setCompanyType(String companyType) {
        this.companyType = companyType;
    }

    public String getClientType() {
        return clientType;
    }

    public void setClientType(String clientType) {
        this.clientType = clientType;
    }

    public String getCompanySubType() {
        return companySubType;
    }

    public void setCompanySubType(String companySubType) {
        this.companySubType = companySubType;
    }

    public String getTenantType() {
        return tenantType;
    }

    public void setTenantType(String tenantType) {
        this.tenantType = tenantType;
    }

    public String getScenarioLoanId() {
        return scenarioLoanId;
    }

    public void setScenarioLoanId(String scenarioLoanId) {
        this.scenarioLoanId = scenarioLoanId;
    }

    public String getScenarioCompanyId() {
        return scenarioCompanyId;
    }

    public void setScenarioCompanyId(String scenarioCompanyId) {
        this.scenarioCompanyId = scenarioCompanyId;
    }

    public String getScenarioAllocationMonth() {
        return scenarioAllocationMonth;
    }

    public void setScenarioAllocationMonth(String scenarioAllocationMonth) {
        this.scenarioAllocationMonth = scenarioAllocationMonth;
    }

    public String getScenarioName() {
        return scenarioName;
    }

    public void setScenarioName(String scenarioName) {
        this.scenarioName = scenarioName;
    }

    public int getUserSlot() {
        return userSlot;
    }

    public void setUserSlot(int userSlot) {
        this.userSlot = userSlot;
    }

    public Map<String, String> getRandomStringCache() {
        return randomStringCache;
    }

    public void clearRandomStringCache() {
        randomStringCache.clear();
    }
}

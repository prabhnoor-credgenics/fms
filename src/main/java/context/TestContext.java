package context;

import enums.UserRole;
import io.restassured.response.Response;

import java.util.HashMap;
import java.util.Map;

/**
 * Per-scenario state holder. Created once per Cucumber scenario by PicoContainer.
 */
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
    private Response savedComparisonResponse;
    private String lastRequestBody;

    /** Request/Response logs for Extent failure reporting */
    private String apiLogs;

    /** Scenario-specific overrides */
    private String scenarioLoanId;
    private String scenarioCompanyId;
    private String scenarioAllocationMonth;
    private String scenarioName;
    private String scenarioVariableId;
    private String scenarioMappingId;

    /** Parallel user pool slot */
    private int userSlot;

    /** Role used for authentication in the current scenario */
    private UserRole userRole;

    private final Map<String, String> randomStringCache = new HashMap<>();

    public Response getResponse() {
        return response;
    }

    public void setResponse(Response response) {
        this.response = response;
    }

    public Response getSavedComparisonResponse() {
        return savedComparisonResponse;
    }

    public void setSavedComparisonResponse(Response savedComparisonResponse) {
        this.savedComparisonResponse = savedComparisonResponse;
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

    public String getApiLogs() {
        return apiLogs;
    }

    public void setApiLogs(String apiLogs) {
        this.apiLogs = apiLogs;
    }

    public void clearApiLogs() {
        this.apiLogs = null;
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

    public String getScenarioVariableId() {
        return scenarioVariableId;
    }

    public void setScenarioVariableId(String scenarioVariableId) {
        this.scenarioVariableId = scenarioVariableId;
    }

    public String getScenarioMappingId() {
        return scenarioMappingId;
    }

    public void setScenarioMappingId(String scenarioMappingId) {
        this.scenarioMappingId = scenarioMappingId;
    }

    public int getUserSlot() {
        return userSlot;
    }

    public void setUserSlot(int userSlot) {
        this.userSlot = userSlot;
    }

    public UserRole getUserRole() {
        return userRole;
    }

    public void setUserRole(UserRole userRole) {
        this.userRole = userRole;
    }

    public Map<String, String> getRandomStringCache() {
        return randomStringCache;
    }

    public void clearRandomStringCache() {
        randomStringCache.clear();
    }
}
package context;

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
    private Response response;

    /** Scenario-specific overrides (take priority over global.properties). */
    private String scenarioLoanId;
    private String scenarioCompanyId;
    private String scenarioAllocationMonth;
    private String scenarioName;
    /** Parallel user pool slot (0 .. poolSize-1), bound to the TestNG worker thread. */
    private int userSlot;

    private final Map<String, String> randomStringCache = new HashMap<>();

    public Response getResponse() {
        return response;
    }

    public void setResponse(Response response) {
        this.response = response;
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

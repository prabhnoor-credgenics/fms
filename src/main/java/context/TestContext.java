package context;

import enums.UserRole;
import io.restassured.response.Response;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
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
    private Response savedComparisonResponse;
    private String lastRequestBody;
    private String requestBody;

    private String apiLogs;

    private String scenarioLoanId;
    private String scenarioVariableName;
    private String scenarioCompanyId;
    private String scenarioAllocationMonth;
    private String scenarioName;
    private String scenarioVariableId;
    private String scenarioMappingId;

    private int userSlot;

    private String activeModule;

    private UserRole userRole;

    private final Map<String, String> randomStringCache = new HashMap<>();

    private final Map<String, Long> capturedTimes = new HashMap<>();

    private final Map<String, Object> capturedValues = new HashMap<>();

    public void captureValue(String key, String value) {
        capturedValues.put(key, value);
    }

    public void captureObject(String key, Object value) {
        capturedValues.put(key, value);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getCapturedMap(String key) {
        Object value = capturedValues.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof Map<?, ?> map) {
            return (Map<String, Object>) map;
        }
        throw new IllegalStateException(
                "Captured '" + key + "' is not a map (found " + value.getClass().getSimpleName() + ")");
    }

    @SuppressWarnings("unchecked")
    public List<Object> getCapturedList(String key) {
        Object value = capturedValues.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof List<?> list) {
            return (List<Object>) list;
        }
        throw new IllegalStateException(
                "Captured '" + key + "' is not a list (found " + value.getClass().getSimpleName() + ")");
    }

    public boolean hasCapturedValue(String key) {
        return capturedValues.containsKey(key);
    }

    public boolean hasCapturedPath(String path) {
        try {
            resolveCapturedPath(path);
            return true;
        } catch (RuntimeException e) {
            return false;
        }
    }

    public String getCapturedValue(String keyOrPath) {
        return stringifyCaptured(resolveCapturedPath(keyOrPath));
    }

    public Object getCapturedObject(String keyOrPath) {
        return resolveCapturedPath(keyOrPath);
    }

    public Object resolveCapturedPath(String keyOrPath) {
        if (keyOrPath == null || keyOrPath.isBlank()) {
            throw new IllegalArgumentException("Captured key/path must not be blank");
        }
        String path = keyOrPath.trim();
        int split = indexOfNestedPath(path);
        String rootKey = split < 0 ? path : path.substring(0, split);
        if (!capturedValues.containsKey(rootKey)) {
            throw new IllegalStateException(
                    "Nothing captured as '" + rootKey + "'. Use 'I store/capture response field ...' first.");
        }
        Object root = capturedValues.get(rootKey);
        if (split < 0) {
            return root;
        }
        String nested = path.substring(split);
        if (nested.startsWith(".")) {
            nested = nested.substring(1);
        }
        return readNested(root, nested, path);
    }

    private static int indexOfNestedPath(String path) {
        for (int i = 0; i < path.length(); i++) {
            char c = path.charAt(i);
            if (c == '.' || c == '[') {
                return i;
            }
        }
        return -1;
    }

    private static Object readNested(Object root, String nestedPath, String fullPath) {
        if (root == null) {
            throw new IllegalStateException("Captured path '" + fullPath + "' resolved to null root");
        }
        try {
            String json = stringifyCaptured(root);
            io.restassured.path.json.JsonPath jsonPath = io.restassured.path.json.JsonPath.from(json);
            Object value = jsonPath.get(nestedPath);
            if (value == null) {
                throw new IllegalStateException("Captured path '" + fullPath + "' not found inside stored value");
            }
            return value;
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException(
                    "Failed to read captured path '" + fullPath + "': " + e.getMessage(), e);
        }
    }

    public void clearCapturedValues() {
        capturedValues.clear();
    }

    public void clearCapturedValue(String key) {
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException("Captured key must not be blank");
        }
        capturedValues.remove(key);
    }

    public Map<String, Object> getCapturedValues() {
        return capturedValues;
    }

    public static String stringifyCaptured(Object raw) {
        if (raw == null) {
            return null;
        }
        if (raw instanceof String || raw instanceof Number || raw instanceof Boolean) {
            return String.valueOf(raw);
        }
        try {
            return new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(raw);
        } catch (Exception e) {
            return String.valueOf(raw);
        }
    }

    public record UserSession(String authToken, String companyId, String userId, UserRole role, int slot,
                              String module) {}

    private final Map<String, UserSession> namedSessions = new LinkedHashMap<>();

    public void rememberUserSession(String key, UserSession session) {
        namedSessions.put(key, session);
    }

    public UserSession getUserSession(String key) {
        return namedSessions.get(key);
    }

    public void removeUserSession(String key) {
        namedSessions.remove(key);
    }

    public Map<String, UserSession> getNamedSessions() {
        return namedSessions;
    }

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

    public String getRequestBody() {
        return requestBody;
    }

    public void setRequestBody(String requestBody) {
        this.requestBody = requestBody;
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

    public String getScenarioVariableName() {
        return scenarioVariableName;
    }

    public void setScenarioVariableName(String scenarioVariableName) {
        this.scenarioVariableName = scenarioVariableName;
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

    public String getActiveModule() {
        return activeModule;
    }

    public void setActiveModule(String activeModule) {
        this.activeModule = activeModule;
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

    public void captureTime(String key, long epochMillis) {
        capturedTimes.put(key, epochMillis);
    }

    public Long getCapturedTime(String key) {
        return capturedTimes.get(key);
    }

    public Map<String, Long> getCapturedTimes() {
        return capturedTimes;
    }
}

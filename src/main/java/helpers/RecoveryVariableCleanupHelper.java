package helpers;

import config.ConfigReader;
import context.TestContext;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

public class RecoveryVariableCleanupHelper {

    private static final Logger logger = LogManager.getLogger(RecoveryVariableCleanupHelper.class);

    private static final Pattern GENERATED_VARIABLE_NAME =
            Pattern.compile("(?i)^variable\\d{6}$");

    private final TestContext testContext;
    private final ConfigReader configReader;

    public RecoveryVariableCleanupHelper(
            TestContext testContext,
            ConfigReader configReader
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
    }

    public void markGeneratedVariablesNonMandatoryBestEffort() {
        String token = resolveAuthToken();
        String companyId = resolveCompanyId();
        if (token == null || token.isBlank() || companyId == null || companyId.isBlank()) {
            logger.warn(
                    "Variable cleanup skipped: missing auth token or company id (tokenPresent={}, companyId={})",
                    token != null && !token.isBlank(),
                    companyId
            );
            return;
        }

        try {
            String baseUrl = configReader.getBaseUrl();
            String variablesUrl = baseUrl + "/recovery/variables";
            
            Response listResponse = io.restassured.RestAssured.given()
                    .baseUri(baseUrl)
                    .header("authenticationtoken", token)
                    .header("accept", "application/json, text/plain, */*")
                    .header("Referer", variablesUrl)
                    .queryParam("company_id", companyId)
                    .queryParam("include_computed_variables", "false")
                    .queryParam("include_meta_data", "false")
                    .get("/recovery/variables");

            if (listResponse.statusCode() < 200 || listResponse.statusCode() >= 300) {
                logger.warn(
                        "Variable cleanup skipped: GET /recovery/variables returned {} tokenPrefix={} companyId={} body={}",
                        listResponse.statusCode(),
                        token.length() >= 8 ? token.substring(0, 8) : token,
                        companyId,
                        truncate(listResponse.asString())
                );
                return;
            }

            List<Map<String, Object>> output = listResponse.jsonPath().getList("output");
            demoteIfNeeded(output, token, companyId, testContext.getScenarioVariableId());
            demoteMatchingGenerated(output, token, companyId);
        } catch (Exception e) {
            logger.warn("Best-effort recovery-variable cleanup failed: {}", e.toString());
        }
    }

    private void demoteMatchingGenerated(
            List<Map<String, Object>> variables,
            String token,
            String companyId
    ) {
        if (variables == null) {
            return;
        }
        for (Map<String, Object> item : variables) {
            Object nameObj = item.get("variable_name");
            String name = nameObj == null ? null : nameObj.toString();
            if (name != null && GENERATED_VARIABLE_NAME.matcher(name).matches() && isMandatory(item)) {
                Object idObj = item.get("variable_id");
                if (idObj != null) {
                    patchNonMandatory(token, companyId, idObj.toString(), name);
                }
            }
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?>) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subVars;
                demoteMatchingGenerated(nested, token, companyId);
            }
        }
    }

    private void demoteIfNeeded(
            List<Map<String, Object>> variables,
            String token,
            String companyId,
            String knownId
    ) {
        if (knownId != null && !knownId.isBlank()) {
            patchNonMandatory(token, companyId, knownId, "(scenario VARIABLE_ID)");
            return;
        }
        String scenarioName = testContext.getScenarioVariableName();
        if (scenarioName == null || scenarioName.isBlank() || variables == null) {
            return;
        }
        String id = findVariableIdByNameIgnoreCase(variables, scenarioName);
        if (id != null) {
            patchNonMandatory(token, companyId, id, scenarioName);
        }
    }

    private void patchNonMandatory(String token, String companyId, String variableId, String label) {
        try {
            String baseUrl = configReader.getBaseUrl();
            Response patch = io.restassured.RestAssured.given()
                    .baseUri(baseUrl)
                    .header("authenticationtoken", token)
                    .header("accept", "application/json, text/plain, */*")
                    .header("Content-Type", "application/json")
                    .header("Referer", baseUrl + "/recovery/variables")
                    .body(Map.of(
                            "company_id", companyId,
                            "variable_id", variableId,
                            "is_mandatory", false
                    ))
                    .patch("/recovery/variables");
            logger.info(
                    "Marked variable '{}' ({}) non-mandatory — status {}",
                    label,
                    variableId,
                    patch.statusCode()
            );
        } catch (Exception e) {
            logger.warn("Failed to mark variable '{}' non-mandatory: {}", label, e.toString());
        }
    }

    static String findVariableIdByNameIgnoreCase(List<Map<String, Object>> variables, String name) {
        if (variables == null || name == null) {
            return null;
        }
        for (Map<String, Object> item : variables) {
            Object itemName = item.get("variable_name");
            if (itemName != null && name.equalsIgnoreCase(itemName.toString())) {
                Object idObj = item.get("variable_id");
                if (idObj != null) {
                    return idObj.toString();
                }
            }
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?>) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subVars;
                String found = findVariableIdByNameIgnoreCase(nested, name);
                if (found != null) {
                    return found;
                }
            }
        }
        return null;
    }

    private static boolean isMandatory(Map<String, Object> item) {
        Object flag = item.get("is_mandatory");
        if (flag instanceof Boolean) {
            return (Boolean) flag;
        }
        return flag != null && "true".equalsIgnoreCase(flag.toString());
    }

    private String resolveAuthToken() {
        if (testContext.getAuthToken() != null && !testContext.getAuthToken().isBlank()) {
            return testContext.getAuthToken();
        }
        Map<String, TestContext.UserSession> sessions = testContext.getNamedSessions();
        if (sessions != null) {
            for (TestContext.UserSession session : sessions.values()) {
                if (session != null && session.authToken() != null && !session.authToken().isBlank()) {
                    return session.authToken();
                }
            }
        }
        return null;
    }

    private String resolveCompanyId() {
        if (testContext.getCompanyId() != null && !testContext.getCompanyId().isBlank()) {
            return testContext.getCompanyId();
        }
        if (testContext.getScenarioCompanyId() != null && !testContext.getScenarioCompanyId().isBlank()) {
            return testContext.getScenarioCompanyId();
        }
        Map<String, TestContext.UserSession> sessions = testContext.getNamedSessions();
        if (sessions != null) {
            for (TestContext.UserSession session : sessions.values()) {
                if (session != null && session.companyId() != null && !session.companyId().isBlank()) {
                    return session.companyId();
                }
            }
        }
        String fromConfig = configReader.getCompanyId();
        if (fromConfig != null && !fromConfig.isBlank()) {
            return fromConfig;
        }
        return configReader.getApiKeyGlobalCompanyId();
    }

    private static String truncate(String value) {
        if (value == null) {
            return "";
        }
        return value.length() <= 300 ? value : value.substring(0, 300) + "...";
    }
}

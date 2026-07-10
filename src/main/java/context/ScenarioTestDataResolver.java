package context;

import config.ConfigReader;
import helpers.RandomDataHelper;
import utils.TestDataHelper;


public class ScenarioTestDataResolver {

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final TestDataHelper testDataHelper;

    public ScenarioTestDataResolver(
            TestContext testContext,
            ConfigReader configReader,
            TestDataHelper testDataHelper
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.testDataHelper = testDataHelper;
    }


    public void ensureUniqueLoanIdIfEnabled() {
        if (!configReader.isUniqueLoanIdPerScenarioEnabled()) {
            return;
        }
        if (testContext.getScenarioLoanId() != null && !testContext.getScenarioLoanId().isBlank()) {
            return;
        }
        testContext.setScenarioLoanId(RandomDataHelper.uniqueLoanId());
    }

    public String resolveLoanId() {
        if (testContext.getScenarioLoanId() != null && !testContext.getScenarioLoanId().isBlank()) {
            return testContext.getScenarioLoanId();
        }
        String fromConfig = configReader.getLoanId();
        if (fromConfig != null && !fromConfig.isBlank()) {
            return fromConfig;
        }
        throw new IllegalStateException(
                "Loan ID is not set. Use 'Given scenario loan id is ...', enable test.data.unique.loan.id.per.scenario in global.properties, or set loan.id in global.properties"
        );
    }

    public String resolveCompanyId() {
        if (testContext.getScenarioCompanyId() != null && !testContext.getScenarioCompanyId().isBlank()) {
            return testContext.getScenarioCompanyId();
        }
        if (testContext.getCompanyId() != null && !testContext.getCompanyId().isBlank()) {
            return testContext.getCompanyId();
        }
        String fromConfig = configReader.getCompanyId();
        if (fromConfig != null && !fromConfig.isBlank()) {
            return fromConfig;
        }
        String globalCompanyId = configReader.getApiKeyGlobalCompanyId();
        if (globalCompanyId != null && !globalCompanyId.isBlank()) {
            return globalCompanyId;
        }
        throw new IllegalStateException(
                "Company ID is not initialized. Use 'Given scenario company id is ...', "
                        + "set company_id in properties, or configure {env}_api_key_global_company_id"
        );
    }

    /**
     * Resolve the company the active user actually belongs to, ignoring any scenario-level
     * company override. Some scenarios set a pseudo company (e.g. {@code "All"}) for the
     * API-under-test request; that value is not a real member company, so it cannot be used to
     * look up the user's {@code profile_id} in {@code assigned_companies_dict}. Use this instead
     * of {@link #resolveCompanyId()} whenever the company id must map to the logged-in user's
     * own membership (e.g. permission grants).
     */
    public String resolveUserCompanyId() {
        if (testContext.getCompanyId() != null && !testContext.getCompanyId().isBlank()) {
            return testContext.getCompanyId();
        }
        String fromConfig = configReader.getCompanyId();
        if (fromConfig != null && !fromConfig.isBlank()) {
            return fromConfig;
        }
        String globalCompanyId = configReader.getApiKeyGlobalCompanyId();
        if (globalCompanyId != null && !globalCompanyId.isBlank()) {
            return globalCompanyId;
        }
        throw new IllegalStateException(
                "Active user's company id is not initialized. Authenticate first, "
                        + "set company_id in properties, or configure {env}_api_key_global_company_id"
        );
    }

    public String resolveAllocationMonth() {
        if (testContext.getScenarioAllocationMonth() != null && !testContext.getScenarioAllocationMonth().isBlank()) {
            return testContext.getScenarioAllocationMonth();
        }
        return configReader.getAllocationMonth();
    }

    public String resolveAllocationMonthOffset(String text) {
        return testDataHelper.replaceAllocationMonthOffset(text);
    }

    public String resolveVariableId() {
        if (testContext.getScenarioVariableId() != null && !testContext.getScenarioVariableId().isBlank()) {
            return testContext.getScenarioVariableId();
        }
        throw new IllegalStateException(
                "Variable ID is not set. Use 'I store the created variable id from response' after a POST first."
        );
    }

    public String replaceScenarioPlaceholders(String text) {
        if (text == null) {
            return null;
        }
        String result = resolveNamedSessionPlaceholders(text);
        result = testDataHelper.replacePlaceholders(result);
        result = result.replace(ContextKeys.LOAN_ID, resolveLoanId());
        result = result.replace(ContextKeys.COMPANY_ID, resolveCompanyId());
        String allocationMonth = resolveAllocationMonth();
        if (allocationMonth != null && !allocationMonth.isBlank()) {
            result = result.replace(ContextKeys.ALLOCATION_MONTH, allocationMonth);
        }
        if (result.contains(ContextKeys.VARIABLE_ID)) {
            result = result.replace(ContextKeys.VARIABLE_ID, resolveVariableId());
        }
        if (result.contains(ContextKeys.MAPPING_ID)) {
            result = result.replace(ContextKeys.MAPPING_ID, resolveMappingId());
        }
        if (result.contains(ContextKeys.CREATOR_USER_ID)) {
            result = result.replace(ContextKeys.CREATOR_USER_ID, resolveCreatorUserId());
        }
        return result;
    }

    public String resolveCreatorUserId() {
        if (testContext.getUserId() != null && !testContext.getUserId().isBlank()) {
            return testContext.getUserId();
        }
        throw new IllegalStateException(
                "Creator user id is not set. Use 'I store the current user id from the user profile' "
                        + "while authenticated as the creator before referencing {CREATOR_USER_ID}."
        );
    }


    public String resolveNamedSessionPlaceholders(String text) {
        if (text == null || text.indexOf('{') < 0) {
            return text;
        }
        String result = text;
        result = replaceKeyed(result, ContextKeys.AUTH_TOKEN_FOR_PREFIX, "auth token",
                session -> session.authToken());
        result = replaceKeyed(result, ContextKeys.COMPANY_ID_FOR_PREFIX, "company id",
                session -> session.companyId());
        result = replaceKeyed(result, ContextKeys.USER_ID_FOR_PREFIX, "user id",
                session -> session.userId());
        return result;
    }


    private String replaceKeyed(
            String text,
            String prefix,
            String fieldLabel,
            java.util.function.Function<TestContext.UserSession, String> extractor
    ) {
        String result = text;
        int start;
        while ((start = result.indexOf(prefix)) >= 0) {
            int end = result.indexOf('}', start);
            if (end < 0) {
                break; // unterminated placeholder; leave the rest as-is
            }
            String key = result.substring(start + prefix.length(), end).trim();
            TestContext.UserSession session = testContext.getUserSession(key);
            if (session == null) {
                throw new IllegalStateException(
                        "No user remembered as '" + key + "'. Use a step like "
                                + "'I authenticate as \"creator\" slot 1 and remember as \"" + key + "\"' first.");
            }
            String value = extractor.apply(session);
            if (value == null || value.isBlank()) {
                throw new IllegalStateException(
                        "Remembered user '" + key + "' has no " + fieldLabel + " captured.");
            }
            result = result.substring(0, start) + value + result.substring(end + 1);
        }
        return result;
    }

    public String resolveMappingId() {
        if (testContext.getScenarioMappingId() != null && !testContext.getScenarioMappingId().isBlank()) {
            return testContext.getScenarioMappingId();
        }
        throw new IllegalStateException(
                "Mapping ID is not set. Use 'I store the created mapping id from response' after a POST first."
        );
    }
}

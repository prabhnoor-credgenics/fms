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
                        + "set company.id in properties, or configure {env}.api.key.global.company.id"
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
        String result = testDataHelper.replacePlaceholders(text);
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

    public String resolveMappingId() {
        if (testContext.getScenarioMappingId() != null && !testContext.getScenarioMappingId().isBlank()) {
            return testContext.getScenarioMappingId();
        }
        throw new IllegalStateException(
                "Mapping ID is not set. Use 'I store the created mapping id from response' after a POST first."
        );
    }
}

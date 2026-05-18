package context;

import config.ConfigReader;
import utils.TestDataHelper;

/**
 * Resolves loan ID, company ID, and allocation month for the current scenario.
 * Scenario-level values override {@code global.properties}; unique loan IDs are generated when enabled.
 */
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

    /**
     * Ensures each parallel scenario has its own loan ID when configured, avoiding cross-thread collisions.
     */
    public void ensureUniqueLoanIdIfEnabled() {
        if (!configReader.isUniqueLoanIdPerScenarioEnabled()) {
            return;
        }
        if (testContext.getScenarioLoanId() != null && !testContext.getScenarioLoanId().isBlank()) {
            return;
        }
        String prefix = configReader.getLoanIdPrefix();
        String uniqueLoanId = prefix + "_" + testDataHelper.generateUUID().replace("-", "").substring(0, 12);
        testContext.setScenarioLoanId(uniqueLoanId);
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
                "Loan ID is not set. Use 'Given scenario loan id is ...', enable test.data.unique.loan.id.per.scenario, or set loan.id in global.properties"
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
        throw new IllegalStateException("Company ID is not initialized for this scenario");
    }

    public String resolveAllocationMonth() {
        if (testContext.getScenarioAllocationMonth() != null && !testContext.getScenarioAllocationMonth().isBlank()) {
            return testContext.getScenarioAllocationMonth();
        }
        return configReader.getAllocationMonth();
    }

    public String replaceScenarioPlaceholders(String text) {
        if (text == null) {
            return null;
        }
        String result = testDataHelper.replacePlaceholders(text);
        result = result.replace("{LOAN_ID}", resolveLoanId());
        result = result.replace("{COMPANY_ID}", resolveCompanyId());
        String allocationMonth = resolveAllocationMonth();
        if (allocationMonth != null && !allocationMonth.isBlank()) {
            result = result.replace("{ALLOCATION_MONTH}", allocationMonth);
        }
        return result;
    }
}

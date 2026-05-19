package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.TestDataHelper;


public class ScenarioDataStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ScenarioDataStepDefinitions.class);

    private final TestContext testContext;
    private final TestDataHelper testDataHelper;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public ScenarioDataStepDefinitions(
            TestContext testContext,
            TestDataHelper testDataHelper,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.testDataHelper = testDataHelper;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    @Given("scenario loan id is {string}")
    public void scenario_loan_id_is(String loanId) {
        testContext.setScenarioLoanId(scenarioTestDataResolver.replaceScenarioPlaceholders(loanId));
        logger.info("Scenario loan id set to: {}", testContext.getScenarioLoanId());
    }

    @Given("scenario loan id is unique")
    public void scenario_loan_id_is_unique() {
        scenarioTestDataResolver.ensureUniqueLoanIdIfEnabled();
        if (testContext.getScenarioLoanId() == null) {
            String unique = "api_auto_" + testDataHelper.generateUUID().replace("-", "").substring(0, 12);
            testContext.setScenarioLoanId(unique);
        }
        logger.info("Unique scenario loan id: {}", testContext.getScenarioLoanId());
    }

    @Given("scenario company id is {string}")
    public void scenario_company_id_is(String companyId) {
        testContext.setScenarioCompanyId(companyId);
        logger.info("Scenario company id set to: {}", companyId);
    }

    @Given("scenario allocation month is {string}")
    public void scenario_allocation_month_is(String allocationMonth) {
        testContext.setScenarioAllocationMonth(allocationMonth);
        logger.info("Scenario allocation month set to: {}", allocationMonth);
    }
}

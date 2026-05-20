package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.RandomDataHelper;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;


public class ScenarioDataStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ScenarioDataStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public ScenarioDataStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
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
            testContext.setScenarioLoanId(RandomDataHelper.uniqueLoanId());
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

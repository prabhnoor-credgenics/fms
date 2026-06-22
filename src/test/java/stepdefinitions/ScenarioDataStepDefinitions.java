package stepdefinitions;

import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.RandomDataHelper;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;


public class ScenarioDataStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ScenarioDataStepDefinitions.class);

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public ScenarioDataStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    @Given("scenario loan id is unique")
    public void scenario_loan_id_is_unique() {
        scenarioTestDataResolver.ensureUniqueLoanIdIfEnabled();
        if (testContext.getScenarioLoanId() == null) {
            testContext.setScenarioLoanId(RandomDataHelper.uniqueLoanId());
        }
        logger.info("Unique scenario loan id: {}", testContext.getScenarioLoanId());
    }

    @Given("scenario company id is from configuration")
    public void scenario_company_id_is_from_configuration() {
        String companyId = configReader.getApiKeyGlobalCompanyId();
        if (companyId == null || companyId.isBlank()) {
            throw new IllegalStateException(
                    "Global company id not configured. Set {env}.api.key.global.company.id in environment properties."
            );
        }
        testContext.setScenarioCompanyId(companyId);
        logger.info("Scenario company id set from configuration: {}", companyId);
    }

    @Given("scenario allocation month offset is {int}")
    public void scenario_allocation_month_offset_is(int monthOffset) {
        String allocationMonth = LocalDate.now()
                .plusMonths(monthOffset)
                .withDayOfMonth(1)
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        testContext.setScenarioAllocationMonth(allocationMonth);
        logger.info("Scenario allocation month offset {} resolved to: {}", monthOffset, allocationMonth);
    }
}

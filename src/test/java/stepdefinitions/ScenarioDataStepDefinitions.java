package stepdefinitions;

import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.RandomDataHelper;
import helpers.RecoveryVariableCleanupHelper;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.TestDataHelper;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class ScenarioDataStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ScenarioDataStepDefinitions.class);
    private static final DateTimeFormatter ALLOCATION_MONTH_OFFSET_FORMAT =
            DateTimeFormatter.ofPattern("yyyy-M-dd");

    private final TestContext testContext;
    private final ConfigReader configReader;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final TestDataHelper testDataHelper;
    private final RecoveryVariableCleanupHelper recoveryVariableCleanupHelper;


    public ScenarioDataStepDefinitions(
            TestContext testContext,
            ConfigReader configReader,
            ScenarioTestDataResolver scenarioTestDataResolver,
            TestDataHelper testDataHelper,
            RecoveryVariableCleanupHelper recoveryVariableCleanupHelper
    ) {
        this.testContext = testContext;
        this.configReader = configReader;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.testDataHelper = testDataHelper;
        this.recoveryVariableCleanupHelper = recoveryVariableCleanupHelper;
    }

    @Given("scenario loan id is unique")
    public void scenario_loan_id_is_unique() {
        scenarioTestDataResolver.ensureUniqueLoanIdIfEnabled();
        if (testContext.getScenarioLoanId() == null) {
            testContext.setScenarioLoanId(RandomDataHelper.uniqueLoanId());
        }
        logger.info("Unique scenario loan id: {}", testContext.getScenarioLoanId());
    }

    @Given("scenario variable name is unique")
    public void scenario_variable_name_is_unique() {
        scenarioTestDataResolver.ensureUniqueVariableName();
        logger.info("Unique scenario variable name: {}", testContext.getScenarioVariableName());
    }

    @And("scenario variable type is {string}")
    public void scenario_variable_type_is(String variableType) {
        testContext.captureValue("VARIABLE_TYPE", variableType);
        logger.info("Scenario variable type: {}", variableType);
    }

    @Given("I mark generated recovery variables as non-mandatory")
    public void i_mark_generated_recovery_variables_as_non_mandatory() {
        recoveryVariableCleanupHelper.markGeneratedVariablesNonMandatoryBestEffort();
    }

    @Given("scenario company id is from configuration")
    public void scenario_company_id_is_from_configuration() {
        String companyId = configReader.getApiKeyGlobalCompanyId();
        if (companyId == null || companyId.isBlank()) {
            throw new IllegalStateException(
                    "Global company id not configured. Set {env}_api_key_global_company_id in environment properties."
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
                .format(ALLOCATION_MONTH_OFFSET_FORMAT);
        testContext.setScenarioAllocationMonth(allocationMonth);
        logger.info("Scenario allocation month offset {} resolved to: {}", monthOffset, allocationMonth);
    }

    @Given("I capture the current time as {string}")
    public void i_capture_the_current_time_as(String key) {
        long epochMillis = System.currentTimeMillis();
        testContext.captureTime(key, epochMillis);
        logger.info("Captured current time as '{}' (epoch millis {}). All formats:", key, epochMillis);
        testDataHelper.allTimeFormats(epochMillis)
                .forEach((format, value) -> logger.info("  {} -> {}", format, value));
    }
}

package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import payload.CompanyCreationPayloadBuilder;
import service.CompanyCreationService;
import validators.business.CompanyCreationValidator;

import static constants.FrameworkConstants.SCHEMA_COMPANY_GET_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP1_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP2_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP3_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP4_SUCCESS;


public class CompanyCreationStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CompanyCreationStepDefinitions.class);

    private final TestContext testContext;
    private final CompanyCreationPayloadBuilder payloadBuilder;
    private final CompanyCreationService companyCreationService;
    private final CompanyCreationValidator companyCreationValidator;

    public CompanyCreationStepDefinitions(
            TestContext testContext,
            CompanyCreationPayloadBuilder payloadBuilder,
            CompanyCreationService companyCreationService,
            CompanyCreationValidator companyCreationValidator
    ) {
        this.testContext = testContext;
        this.payloadBuilder = payloadBuilder;
        this.companyCreationService = companyCreationService;
        this.companyCreationValidator = companyCreationValidator;
    }

    @Given("company creation test data is prepared")
    public void company_creation_test_data_is_prepared() {
        payloadBuilder.prepareCompanyCreationTestData();
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
    }

    @Given("company creation step 1 is completed")
    public void company_creation_step_1_is_completed() {
        company_creation_test_data_is_prepared();
        if (testContext.getCompanyId() == null || testContext.getCompanyId().isBlank()) {
            Response response = companyCreationService.createCompanyStep1();
            companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_STEP1_SUCCESS);
            companyCreationValidator.extractAndStoreStep1(response);
        } else {
            logger.info("Step 1 already completed for company_id={}", testContext.getCompanyId());
        }
    }

    @Given("company creation steps 1 and 2 are completed")
    public void company_creation_steps_1_and_2_are_completed() {
        company_creation_step_1_is_completed();
        Response step2 = companyCreationService.createCompanyStep2();
        companyCreationValidator.validateSchema(step2, SCHEMA_COMPANY_STEP2_SUCCESS);
        companyCreationValidator.validateStep2(step2);
    }

    @Given("company creation steps 1, 2 and 3 are completed")
    public void company_creation_steps_1_2_and_3_are_completed() {
        company_creation_steps_1_and_2_are_completed();
        Response step3 = companyCreationService.createCompanyStep3();
        companyCreationValidator.validateSchema(step3, SCHEMA_COMPANY_STEP3_SUCCESS);
        companyCreationValidator.validateStep3(step3);
    }

    @When("I create company with validation step 1")
    public void i_create_company_with_validation_step_1() {
        companyCreationService.createCompanyStep1();
    }

    @When("I create company with validation step 2")
    public void i_create_company_with_validation_step_2() {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep2();
    }

    @When("I create company with validation step 3")
    public void i_create_company_with_validation_step_3() {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep3();
    }

    @When("I create company with validation step 4")
    public void i_create_company_with_validation_step_4() {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep4();
    }

    @When("I get user company details for the created company")
    public void i_get_user_company_details_for_the_created_company() {
        companyCreationService.getUserCompanyDetails();
    }

    @When("I get recovery company details for the created company")
    public void i_get_recovery_company_details_for_the_created_company() {
        companyCreationService.getRecoveryCompanyDetails(true);
    }

    @Then("company creation step 1 should be successful")
    public void company_creation_step_1_should_be_successful() {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_STEP1_SUCCESS);
        companyCreationValidator.extractAndStoreStep1(response);
    }

    @Then("company creation step 2 should be successful")
    public void company_creation_step_2_should_be_successful() {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_STEP2_SUCCESS);
        companyCreationValidator.validateStep2(response);
    }

    @Then("company creation step 3 should be successful")
    public void company_creation_step_3_should_be_successful() {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_STEP3_SUCCESS);
        companyCreationValidator.validateStep3(response);
    }

    @Then("company creation step 4 should be successful")
    public void company_creation_step_4_should_be_successful() {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_STEP4_SUCCESS);
        companyCreationValidator.extractAndStoreStep4(response);
    }

    @Then("the created company details should match test context")
    public void the_created_company_details_should_match_test_context() {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_GET_SUCCESS);
        companyCreationValidator.validateCreatedCompanyMatchesContext(response);
    }

    @Then("company creation stored identifiers should be present")
    public void company_creation_stored_identifiers_should_be_present() {
        org.testng.Assert.assertNotNull(testContext.getCompanyId(), "company_id");
        org.testng.Assert.assertNotNull(testContext.getTrademark(), "trademark");
        org.testng.Assert.assertNotNull(testContext.getCompanyName(), "company_name");
        org.testng.Assert.assertNotNull(testContext.getCompanyEmail(), "company_email");
        logger.info(
                "Stored identifiers present: company_id={}, trademark={}",
                testContext.getCompanyId(),
                testContext.getTrademark()
        );
    }

    @Then("company creation final identifiers should be present")
    public void company_creation_final_identifiers_should_be_present() {
        company_creation_stored_identifiers_should_be_present();
        org.testng.Assert.assertNotNull(testContext.getProfileId(), "profile_id");
        org.testng.Assert.assertNotNull(testContext.getUserId(), "user_id");
        logger.info(
                "Final identifiers: profile_id={}, user_id={}",
                testContext.getProfileId(),
                testContext.getUserId()
        );
    }

    private Response requireResponse() {
        Response response = testContext.getResponse();
        if (response == null) {
            throw new IllegalStateException("No API response in TestContext. Execute a When step first.");
        }
        return response;
    }
}

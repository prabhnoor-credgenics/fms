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

import helpers.SchemaHelper;

import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP1_REQUEST;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP1_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP2_REQUEST;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP2_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP3_REQUEST;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP3_SUCCESS;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP4_REQUEST;
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

    @Given("company creation steps 1 and 2 are completed")
    public void company_creation_steps_1_and_2_are_completed() {
        company_creation_test_data_is_prepared();
        Response step1 = companyCreationService.createCompanyStep1();
        companyCreationValidator.validateSchema(step1, SCHEMA_COMPANY_STEP1_SUCCESS);
        companyCreationValidator.extractAndStoreStep1(step1);
        Response step2 = companyCreationService.createCompanyStep2();
        companyCreationValidator.validateSchema(step2, SCHEMA_COMPANY_STEP2_SUCCESS);
        companyCreationValidator.validateStep2(step2);
    }

    @When("I create company with validation step 1")
    public void i_create_company_with_validation_step_1() {
        companyCreationService.createCompanyStep1();
    }

    @When("I create company with validation step 1 without mandatory field {string}")
    public void i_create_company_with_validation_step_1_without_mandatory_field(String fieldName) {
        company_creation_test_data_is_prepared();
        companyCreationService.createCompanyStep1WithoutMandatoryField(fieldName);
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

    @When("I create company with validation step 3 without mandatory admin field {string}")
    public void i_create_company_with_validation_step_3_without_mandatory_admin_field(String adminFieldName) {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep3WithoutAdminField(adminFieldName);
    }

    @When("I create company with validation step 3 without email only")
    public void i_create_company_with_validation_step_3_without_email_only() {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep3WithoutEmailOnly();
    }

    @When("I create company with validation step 3 without email and mobile")
    public void i_create_company_with_validation_step_3_without_email_and_mobile() {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep3WithoutEmailAndMobile();
    }

    @When("I create company with validation step 4")
    public void i_create_company_with_validation_step_4() {
        companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        companyCreationService.createCompanyStep4();
    }

    @Then("company creation step 1 should be successful")
    public void company_creation_step_1_should_be_successful() {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, SCHEMA_COMPANY_STEP1_SUCCESS);
        companyCreationValidator.extractAndStoreStep1(response);
    }

    private void company_creation_request_should_match_json_schema(String schemaPath) {
        String body = testContext.getLastRequestBody();
        if (body == null || body.isBlank()) {
            throw new IllegalStateException(
                    "No company creation request body in context. Execute a company creation When step first."
            );
        }
        SchemaHelper.validateRequestBody(body, schemaPath);
        logger.info("Company creation request schema validation passed: {}", schemaPath);
    }

    @Then("company creation step 1 request should match json schema")
    public void company_creation_step_1_request_should_match_json_schema() {
        company_creation_request_should_match_json_schema(SCHEMA_COMPANY_STEP1_REQUEST);
    }

    @Then("company creation step 2 request should match json schema")
    public void company_creation_step_2_request_should_match_json_schema() {
        company_creation_request_should_match_json_schema(SCHEMA_COMPANY_STEP2_REQUEST);
    }

    @Then("company creation step 3 request should match json schema")
    public void company_creation_step_3_request_should_match_json_schema() {
        company_creation_request_should_match_json_schema(SCHEMA_COMPANY_STEP3_REQUEST);
    }

    @Then("company creation step 4 request should match json schema")
    public void company_creation_step_4_request_should_match_json_schema() {
        company_creation_request_should_match_json_schema(SCHEMA_COMPANY_STEP4_REQUEST);
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

    private Response requireResponse() {
        Response response = testContext.getResponse();
        if (response == null) {
            throw new IllegalStateException("No API response in TestContext. Execute a When step first.");
        }
        return response;
    }
}

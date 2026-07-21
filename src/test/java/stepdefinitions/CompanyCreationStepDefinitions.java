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

import java.util.Map;

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

    // step number -> success/request schema classpath (replaces the four SCHEMA_COMPANY_STEPn_* per-step methods)
    private static final Map<Integer, String> SUCCESS_SCHEMA = Map.of(
            1, SCHEMA_COMPANY_STEP1_SUCCESS,
            2, SCHEMA_COMPANY_STEP2_SUCCESS,
            3, SCHEMA_COMPANY_STEP3_SUCCESS,
            4, SCHEMA_COMPANY_STEP4_SUCCESS
    );
    private static final Map<Integer, String> REQUEST_SCHEMA = Map.of(
            1, SCHEMA_COMPANY_STEP1_REQUEST,
            2, SCHEMA_COMPANY_STEP2_REQUEST,
            3, SCHEMA_COMPANY_STEP3_REQUEST,
            4, SCHEMA_COMPANY_STEP4_REQUEST
    );

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

    /**
     * Parameterized replacement for the former four {@code I create company with validation step 1..4}
     * steps. Steps 2-4 first assert trademark consistency across the wizard (step 1 has just had its
     * data prepared, so it doesn't). The existing feature text ("... step 1") still matches via {int}.
     */
    @When("I create company with validation step {int}")
    public void i_create_company_with_validation_step(int step) {
        if (step != 1) {
            companyCreationValidator.assertTrademarkConsistentAcrossSteps();
        }
        switch (step) {
            case 1 -> companyCreationService.createCompanyStep1();
            case 2 -> companyCreationService.createCompanyStep2();
            case 3 -> companyCreationService.createCompanyStep3();
            case 4 -> companyCreationService.createCompanyStep4();
            default -> throw new IllegalArgumentException("Unknown company creation step: " + step);
        }
    }

    @When("I create company with validation step 1 without mandatory field {string}")
    public void i_create_company_with_validation_step_1_without_mandatory_field(String fieldName) {
        company_creation_test_data_is_prepared();
        companyCreationService.createCompanyStep1WithoutMandatoryField(fieldName);
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

    /**
     * Parameterized replacement for the former four {@code company creation step 1..4 should be successful}
     * steps. Validates the step's success schema, then runs the step-specific extract/validate side-effect.
     */
    @Then("company creation step {int} should be successful")
    public void company_creation_step_should_be_successful(int step) {
        Response response = requireResponse();
        companyCreationValidator.validateSchema(response, schemaFor(SUCCESS_SCHEMA, step, "success"));
        switch (step) {
            case 1 -> companyCreationValidator.extractAndStoreStep1(response);
            case 2 -> companyCreationValidator.validateStep2(response);
            case 3 -> companyCreationValidator.validateStep3(response);
            case 4 -> companyCreationValidator.extractAndStoreStep4(response);
            default -> throw new IllegalArgumentException("Unknown company creation step: " + step);
        }
    }

    /**
     * Parameterized replacement for the former four {@code company creation step 1..4 request should
     * match json schema} steps.
     */
    @Then("company creation step {int} request should match json schema")
    public void company_creation_step_request_should_match_json_schema(int step) {
        String body = testContext.getLastRequestBody();
        if (body == null || body.isBlank()) {
            throw new IllegalStateException(
                    "No company creation request body in context. Execute a company creation When step first."
            );
        }
        String schemaPath = schemaFor(REQUEST_SCHEMA, step, "request");
        SchemaHelper.validateRequestBody(body, schemaPath);
        logger.info("Company creation request schema validation passed: {}", schemaPath);
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

    private static String schemaFor(Map<Integer, String> schemas, int step, String kind) {
        String schema = schemas.get(step);
        if (schema == null) {
            throw new IllegalArgumentException(
                    "No company creation " + kind + " schema for step " + step + " (expected 1-4).");
        }
        return schema;
    }

    private Response requireResponse() {
        Response response = testContext.getResponse();
        if (response == null) {
            throw new IllegalStateException("No API response in TestContext. Execute a When step first.");
        }
        return response;
    }
}

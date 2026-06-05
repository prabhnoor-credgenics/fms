package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.DataUploadMappingsValidator;

public class DataUploadMappingsStepDefinitions {

    private static final Logger logger = LogManager.getLogger(DataUploadMappingsStepDefinitions.class);

    private final TestContext testContext;
    private final DataUploadMappingsValidator validator;

    public DataUploadMappingsStepDefinitions(TestContext testContext,
                                             DataUploadMappingsValidator validator) {
        this.testContext = testContext;
        this.validator   = validator;
    }

    @Then("I store the created mapping id from response")
    public void i_store_the_created_mapping_id_from_response() {
        Response response = activeResponse();
        Object idObj = response.jsonPath().get("mapping_id");
        if (idObj == null) {
            throw new IllegalStateException(
                    "Cannot extract mapping_id from response. Ensure the POST /data-upload/mappings succeeded."
            );
        }
        String mappingId = idObj.toString();
        testContext.setScenarioMappingId(mappingId);
        logger.info("Stored created mapping id: {}", mappingId);
    }

    @Then("data upload mappings list shape should be valid")
    public void data_upload_mappings_list_shape_should_be_valid() {
        validator.validateListShape(activeResponse());
    }

    @Then("data upload mapping create shape should be valid")
    public void data_upload_mapping_create_shape_should_be_valid() {
        validator.validateCreateShape(activeResponse());
    }

    @Then("data upload mapping update shape should be valid")
    public void data_upload_mapping_update_shape_should_be_valid() {
        validator.validateUpdateShape(activeResponse());
    }

    @Then("data upload mapping PATCH validation error shape should be valid")
    public void data_upload_mapping_patch_validation_error_shape_should_be_valid() {
        validator.validatePatchValidationErrorShape(activeResponse());
    }

    @Then("data upload mapping detail shape should be valid")
    public void data_upload_mapping_detail_shape_should_be_valid() {
        validator.validateDetailShape(activeResponse());
    }

    private Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}

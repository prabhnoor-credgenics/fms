package validators.business;

import context.ScenarioTestDataResolver;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;

public class LoanStageConfigValidator {

    private static final Logger logger = LogManager.getLogger(LoanStageConfigValidator.class);

    private static final List<String> MANDATORY_CONFIG_FIELDS = List.of(
            "id",
            "company_id",
            "stage_variable_id",
            "normalize_stage_variable_id",
            "roll_back_counter",
            "roll_forward_counter",
            "stabilize_counter",
            "normalize_counter",
            "rollback_reduction_factor",
            "rollforward_reduction_factor",
            "stabilize_reduction_factor",
            "normalize_reduction_factor",
            "stage_variable_name",
            "normalize_stage_variable_name"
    );

    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public LoanStageConfigValidator(ScenarioTestDataResolver scenarioTestDataResolver) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    public void validateMandatoryFields(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        for (String field : MANDATORY_CONFIG_FIELDS) {
            softAssert.assertNotNull(jsonPath.get(field), field + " must be present");
        }

        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");
        softAssert.assertNotNull(jsonPath.get("message_template"), "message_template must be present");
        softAssert.assertNotNull(jsonPath.get("message_placeholder"), "message_placeholder must be present");

        String message = jsonPath.getString("message");
        softAssert.assertTrue(message != null && !message.isBlank(), "message must not be blank");

        String stageVariableName = jsonPath.getString("stage_variable_name");
        softAssert.assertTrue(
                stageVariableName != null && !stageVariableName.isBlank(),
                "stage_variable_name must be a non-blank string"
        );

        String normalizeStageVariableName = jsonPath.getString("normalize_stage_variable_name");
        softAssert.assertTrue(
                normalizeStageVariableName != null && !normalizeStageVariableName.isBlank(),
                "normalize_stage_variable_name must be a non-blank string"
        );

        softAssert.assertAll();
        logger.info(
                "Loan stage config mandatory field validation passed (id={}, stage_variable_name={})",
                jsonPath.get("id"),
                stageVariableName
        );
    }

    public void validateCompanyIdMapping(Response response) {
        String expectedCompanyId = scenarioTestDataResolver.resolveCompanyId();
        String actualCompanyId = response.jsonPath().getString("company_id");

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertNotNull(actualCompanyId, "company_id must be present in response");
        softAssert.assertEquals(
                actualCompanyId,
                expectedCompanyId,
                "company_id in response should match requested company_id"
        );
        softAssert.assertAll();
        logger.info("Loan stage config company_id mapping validated for company_id={}", expectedCompanyId);
    }
}

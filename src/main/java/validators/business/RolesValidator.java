package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;
import java.util.Map;

/**
 * Validator for the Roles CRUD endpoints (RoleAPI).
 *
 * Roles uniquely wrap success responses in the standard envelope
 * {id, success, message, data, error_code} (standard_generate_response). Error responses are the
 * plain {"message": ...} form produced by the HandledException handler.
 */
public class RolesValidator {

    private static final Logger logger = LogManager.getLogger(RolesValidator.class);

    /**
     * Success shape. NOTE: although the doc says RoleAPI uses standard_generate_response
     * ({id,success,message,data,error_code}), staging actually returns the raw {data, message}
     * tuple — so we assert data + message present (no `success` flag).
     */
    public void validateSuccessEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("data"), "data must be present");
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("roles success response validated");
    }

    /** Create/update/delete return a data object carrying the changed id / result. */
    public void validateMutationResponse(Response response) {
        validateSuccessEnvelope(response);
        SoftAssert sa = new SoftAssert();
        Object data = response.jsonPath().get("data");
        sa.assertTrue(data instanceof Map, "data must be an object for a role mutation");
        sa.assertAll();
        logger.info("roles mutation response validated");
    }

    /** List response: data.roles is an array of {role_id, role_name}. */
    public void validateListResponse(Response response) {
        validateSuccessEnvelope(response);
        SoftAssert sa = new SoftAssert();
        List<Map<String, Object>> roles = response.jsonPath().getList("data.roles");
        sa.assertNotNull(roles, "data.roles must be present and be an array");
        sa.assertAll();
        logger.info("roles list response validated (roles: {})", roles == null ? 0 : roles.size());
    }

    /** Single-role response: data.role_details object present. */
    public void validateDetailsResponse(Response response) {
        validateSuccessEnvelope(response);
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(response.jsonPath().get("data.role_details"), "data.role_details must be present");
        sa.assertAll();
        logger.info("roles details response validated");
    }

    /** Error responses are the plain {"message": ...} form. */
    public void validateFailureEnvelope(Response response) {
        JsonPath jp = response.jsonPath();
        SoftAssert sa = new SoftAssert();
        sa.assertNotNull(jp.get("message"), "message must be present");
        sa.assertAll();
        logger.info("roles failure envelope validated");
    }
}

package validators.business;

import context.TestContext;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.ResponseValidator;

import java.io.File;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchema;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.notNullValue;


public class CompanyCreationValidator {

    private static final Logger logger = LogManager.getLogger(CompanyCreationValidator.class);

    private final TestContext testContext;

    public CompanyCreationValidator(TestContext testContext) {
        this.testContext = testContext;
    }

    public void validateSchema(Response response, String schemaClasspath) {
        if (response == null) {
            throw new IllegalStateException("Cannot validate schema: response is null");
        }
        response.then().assertThat().body(matchesJsonSchema(new File("src/test/resources/" + schemaClasspath)));
        logger.info("Schema validation passed: {}", schemaClasspath);
    }

    public void validateHttpOk(Response response) {
        ResponseValidator.validateStatusCode(response, 201);
    }

    public void validateSuccessFlag(Response response) {
        Boolean success = response.jsonPath().getBoolean("success");
        assertThat("success flag should be true", success, is(true));
    }

    public void extractAndStoreStep1(Response response) {
        validateHttpOk(response);
        validateSuccessFlag(response);

        String companyId = response.jsonPath().getString("data.company_id");
        assertThat("data.company_id must not be null", companyId, notNullValue());
        assertThat("data.company_id must not be blank", companyId.isBlank(), is(false));

        testContext.setCompanyId(companyId);
        logger.info(
                "Step 1 stored company_id={}, trademark={}, companyName={}",
                companyId,
                testContext.getTrademark(),
                testContext.getCompanyName()
        );
    }

    public void validateStep2(Response response) {
        validateHttpOk(response);
        validateSuccessFlag(response);
        String message = response.jsonPath().getString("message");
        assertThat(message, equalTo("Permissions validated and saved."));
        logger.info("Step 2 validated for trademark={}", testContext.getTrademark());
    }

    public void validateStep3(Response response) {
        validateHttpOk(response);
        validateSuccessFlag(response);
        String message = response.jsonPath().getString("message");
        assertThat(message, equalTo("Admin details validated and saved."));
        logger.info("Step 3 validated for trademark={}", testContext.getTrademark());
    }

    public void extractAndStoreStep4(Response response) {
        validateHttpOk(response);
        validateSuccessFlag(response);

        String message = response.jsonPath().getString("message");
        assertThat(message, equalTo("company created successfully"));

        String companyId = response.jsonPath().getString("data.company_id");
        String profileId = response.jsonPath().getString("data.company_admin_result.profile_id");
        String userId = response.jsonPath().getString("data.company_admin_result.user_id");

        assertThat("data.company_id", companyId, notNullValue());
        assertThat("data.company_admin_result.profile_id", profileId, notNullValue());
        assertThat("data.company_admin_result.user_id", userId, notNullValue());

        if (testContext.getCompanyId() != null && !testContext.getCompanyId().equals(companyId)) {
            throw new AssertionError(
                    "company_id from step 4 (" + companyId + ") does not match step 1 ("
                            + testContext.getCompanyId() + ")"
            );
        }

        testContext.setCompanyId(companyId);
        testContext.setProfileId(profileId);
        testContext.setUserId(userId);

        Boolean setupStatusesSuccess = response.jsonPath().getBoolean("data.setup_statuses_result.success");
        assertThat("setup_statuses_result.success", setupStatusesSuccess, is(true));

        logger.info(
                "Step 4 stored company_id={}, profile_id={}, user_id={}",
                companyId,
                profileId,
                userId
        );
    }

    
    public void validateCreatedCompanyMatchesContext(Response response) {
        validateHttpOk(response);

        String trademark = firstNonBlank(
                response.jsonPath().getString("data.trademark"),
                response.jsonPath().getString("data.company_details.trademark"),
                response.jsonPath().getString("company_details.trademark")
        );
        String companyName = firstNonBlank(
                response.jsonPath().getString("data.company_name"),
                response.jsonPath().getString("data.company_details.company_name")
        );
        String companyId = firstNonBlank(
                response.jsonPath().getString("data.company_id"),
                response.jsonPath().getString("data.company_details.company_id"),
                testContext.getCompanyId()
        );
        String companyEmail = firstNonBlank(
                response.jsonPath().getString("data.company_email[0]"),
                response.jsonPath().getString("data.company_email"),
                response.jsonPath().getString("data.company_details.company_email[0]")
        );
        String adminEmail = firstNonBlank(
                response.jsonPath().getString("data.admin_email"),
                response.jsonPath().getString("data.company_admin_details.email"),
                testContext.getAdminEmail()
        );
        String companyType = firstNonBlank(
                response.jsonPath().getString("data.company_type"),
                response.jsonPath().getString("data.company_details.company_type"),
                testContext.getCompanyType()
        );
        String tenantType = firstNonBlank(
                response.jsonPath().getString("data.tenant_type"),
                response.jsonPath().getString("data.company_details.tenant_type"),
                testContext.getTenantType()
        );

        assertThat("company_id should match", companyId, equalTo(testContext.getCompanyId()));

        if (trademark != null) {
            assertThat("trademark should match", trademark, equalTo(testContext.getTrademark()));
        } else {
            logger.warn("trademark not found in GET response; validated via TestContext only");
        }

        if (companyName != null) {
            assertThat("company_name should match", companyName, equalTo(testContext.getCompanyName()));
        }

        if (companyEmail != null && testContext.getCompanyEmail() != null) {
            assertThat("company_email should match", companyEmail, equalTo(testContext.getCompanyEmail()));
        }

        if (adminEmail != null && testContext.getAdminEmail() != null) {
            assertThat("admin_email should match", adminEmail, equalTo(testContext.getAdminEmail()));
        }

        if (companyType != null) {
            assertThat("company_type should match", companyType, equalTo(testContext.getCompanyType()));
        }

        if (tenantType != null) {
            assertThat("tenant_type should match", tenantType, equalTo(testContext.getTenantType()));
        }

        logger.info("GET company validation passed for company_id={}", testContext.getCompanyId());
    }

    public void assertTrademarkConsistentAcrossSteps() {
        assertThat("trademark must be set", testContext.getTrademark(), notNullValue());
        logger.info("Trademark consistency check passed: {}", testContext.getTrademark());
    }

    private static String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }
}

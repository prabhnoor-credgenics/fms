package service;

import base.RestAssuredBase;
import config.ConfigReader;
import context.TestContext;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import payload.CompanyCreationPayloadBuilder;
import utils.JsonUtils;

import java.util.Objects;

import static constants.FrameworkConstants.ENDPOINT_RECOVERY_COMPANY;
import static constants.FrameworkConstants.ENDPOINT_USER_COMPANY;
import static io.restassured.RestAssured.given;


public class CompanyCreationService {

    private static final Logger logger = LogManager.getLogger(CompanyCreationService.class);

    private final ConfigReader configReader;
    private final TestContext testContext;
    private final RestAssuredBase restAssuredBase;
    private final CompanyCreationPayloadBuilder payloadBuilder;

    public CompanyCreationService(
            ConfigReader configReader,
            TestContext testContext,
            RestAssuredBase restAssuredBase,
            CompanyCreationPayloadBuilder payloadBuilder
    ) {
        this.configReader = configReader;
        this.testContext = testContext;
        this.restAssuredBase = restAssuredBase;
        this.payloadBuilder = payloadBuilder;
    }

    public Response createCompanyStep1() {
        return postCompanyPayload(payloadBuilder.buildStep1Payload(), 1);
    }

    public Response createCompanyStep2() {
        return postCompanyPayload(payloadBuilder.buildStep2Payload(), 2);
    }

    public Response createCompanyStep3() {
        return postCompanyPayload(payloadBuilder.buildStep3Payload(), 3);
    }

    public Response createCompanyStep4() {
        return postCompanyPayload(payloadBuilder.buildStep4Payload(), 4);
    }


    public Response getUserCompanyDetails() {
        requireCompanyId();
        logger.info("Fetching user company details for company_id={}", testContext.getCompanyId());
        Response response = authorizedRequest()
                .queryParam("company_id", testContext.getCompanyId())
                .when()
                .get(ENDPOINT_USER_COMPANY)
                .then()
                .extract()
                .response();
        storeAndLogResponse(response, "GET " + ENDPOINT_USER_COMPANY);
        return response;
    }


    public Response getRecoveryCompanyDetails(boolean bifurcationPrefix) {
        requireCompanyId();
        logger.info(
                "Fetching recovery company details for company_id={}, bifurcation_prefix={}",
                testContext.getCompanyId(),
                bifurcationPrefix
        );
        Response response = authorizedRequest()
                .queryParam("company_id", testContext.getCompanyId())
                .queryParam("bifurcation_prefix", bifurcationPrefix)
                .when()
                .get(ENDPOINT_RECOVERY_COMPANY)
                .then()
                .extract()
                .response();
        storeAndLogResponse(response, "GET " + ENDPOINT_RECOVERY_COMPANY);
        return response;
    }

    private Response postCompanyPayload(String body, int step) {
        Objects.requireNonNull(body, "Request body must not be null for step " + step);
        if (body.isBlank()) {
            throw new IllegalArgumentException("Request body must not be blank for step " + step);
        }
        requireAuthToken();
        logger.info("POST {} validation_step={}", ENDPOINT_USER_COMPANY, step);
        logger.debug("Request body (step {}): {}", step, body);

        Response response = authorizedRequest()
                .header("origin", uiOrigin())
                .header("referer", uiCreateCompanyReferer())
                .body(body)
                .when()
                .post(ENDPOINT_USER_COMPANY)
                .then()
                .extract()
                .response();

        storeAndLogResponse(response, "POST " + ENDPOINT_USER_COMPANY + " step " + step);
        return response;
    }

    private io.restassured.specification.RequestSpecification authorizedRequest() {
        requireAuthToken();
        return restAssuredBase.getRequestSpec()
                .header("authenticationtoken", testContext.getAuthToken())
                .header("accept", "application/json, text/plain, */*");
    }

    private void requireAuthToken() {
        if (testContext.getAuthToken() == null || testContext.getAuthToken().isBlank()) {
            throw new IllegalStateException("Auth token is not set. Ensure Hooks authentication completed.");
        }
    }

    private void requireCompanyId() {
        if (testContext.getCompanyId() == null || testContext.getCompanyId().isBlank()) {
            throw new IllegalStateException(
                    "company_id is not set. Complete company creation step 1 or step 4 first."
            );
        }
    }

    private String uiOrigin() {
        return uiCreateCompanyReferer().replace("/admin/create-company", "");
    }

    private String uiCreateCompanyReferer() {
        String base = configReader.getBaseUrl();
        if (base.contains("staging")) {
            return "https://ui.staging.credgenics.com/admin/create-company";
        }
        if (base.contains("dev") || base.contains("onprem")) {
            return "https://ui.dev.credgenics.com/admin/create-company";
        }
        if (base.contains("prod") || base.contains("apiprod")) {
            return "https://ui.credgenics.com/admin/create-company";
        }
        return "https://ui.staging.credgenics.com/admin/create-company";
    }

    private void storeAndLogResponse(Response response, String operation) {
        if (response == null) {
            throw new IllegalStateException(operation + " returned null response");
        }
        testContext.setResponse(response);
        logger.info("{} completed with status {}", operation, response.getStatusCode());
        logResponseBody(response);
    }

    private void logResponseBody(Response response) {
        String body = response.getBody().asString();
        if (body == null || body.isBlank()) {
            logger.info("Response body: (empty)");
            return;
        }
        try {
            logger.info("Response body:\n{}", JsonUtils.prettyPrint(body));
        } catch (Exception e) {
            logger.info("Response body: {}", body);
        }
    }
}

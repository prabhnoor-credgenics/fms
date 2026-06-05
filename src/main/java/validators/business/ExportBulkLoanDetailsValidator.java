package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.List;

public class ExportBulkLoanDetailsValidator {

    private static final Logger logger = LogManager.getLogger(ExportBulkLoanDetailsValidator.class);

    public void validateLinkResponseShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Link response should be HTTP 200");
        softAssert.assertEquals(json.getString("message"), "success", "message should be 'success'");
        softAssert.assertNotNull(json.get("output"), "output must be present for link response");

        String output = json.getString("output");
        softAssert.assertNotNull(output, "output should not be null");
        softAssert.assertFalse(output == null || output.isBlank(), "output should be a non-blank S3 URL string");

        softAssert.assertAll();
        logger.info("ExportBulkLoanDetails link response shape validated");
    }

    public void validateDataResponseShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Data response should be HTTP 200");
        softAssert.assertNotNull(json.get("message"), "message must be present");
        softAssert.assertNotNull(json.get("data"), "data must be present for data response");

        List<?> data = json.getList("data");
        softAssert.assertNotNull(data, "data should be a list");

        String message = json.getString("message");
        softAssert.assertTrue(
                "success".equals(message) || "no data found".equals(message),
                "message should be 'success' or 'no data found', got: " + message
        );

        softAssert.assertAll();
        logger.info("ExportBulkLoanDetails data response shape validated: {} records", data == null ? 0 : data.size());
    }

    public void validateNoDataShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "No-data response should be HTTP 200");
        softAssert.assertEquals(json.getString("message"), "no data found", "message should be 'no data found'");

        List<?> data = json.getList("data");
        softAssert.assertNotNull(data, "data must be present");
        softAssert.assertTrue(data != null && data.isEmpty(), "data should be an empty array");

        softAssert.assertAll();
        logger.info("ExportBulkLoanDetails no-data shape validated");
    }

    public void validateLoanLimitErrorShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 400, "Loan limit error should be HTTP 400");
        softAssert.assertNotNull(json.get("message"), "message must be present");

        String message = json.getString("message");
        softAssert.assertTrue(
                message != null && message.contains("Loan Export is supported for a maximum of"),
                "message should describe the export limit, got: " + message
        );

        softAssert.assertAll();
        logger.info("ExportBulkLoanDetails loan-limit error shape validated");
    }
}

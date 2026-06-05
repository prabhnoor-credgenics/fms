package validators.business;

import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

public class LoanDetailValidator {

    private static final Logger logger = LogManager.getLogger(LoanDetailValidator.class);

    public void validateSuccessShape(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Success should be HTTP 200");
        softAssert.assertEquals(json.getString("message"), "success", "message should be 'success'");
        softAssert.assertNotNull(json.get("output"), "output must be present");

        softAssert.assertAll();
        logger.info("LoanDetail success shape validated");
    }

    public void validateLoanFieldsPresent(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        Object loanDetails   = json.get("output.loan_details");
        Object applicantDets = json.get("output.applicant_details");
        boolean hasLoanDetails = loanDetails != null || applicantDets != null;
        softAssert.assertTrue(hasLoanDetails,
                "output should contain loan_details (loan company) or applicant_details (credit-line company)");
        softAssert.assertNotNull(json.get("output.global_status"), "global_status must be present when fields=loan");

        softAssert.assertAll();
        logger.info("LoanDetail loan fields validated");
    }

    public void validatePaymentFieldsPresent(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertNotNull(json.get("output.payment_history"),
                "payment_history must be present when fields includes payment");

        softAssert.assertAll();
        logger.info("LoanDetail payment fields validated");
    }

    public void validateNoticeFieldsPresent(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertNotNull(json.get("output.notice_tracking_details"),
                "notice_tracking_details must be present when fields=notice");

        softAssert.assertAll();
        logger.info("LoanDetail notice fields validated");
    }

    public void validateCommunicationFieldsPresent(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertNotNull(json.get("output.communication_details"),
                "communication_details must be present when fields=communication");

        softAssert.assertAll();
        logger.info("LoanDetail communication fields validated");
    }

    public void validateRemarkFieldsPresent(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertNotNull(json.get("output.remarks"),
                "remarks must be present when fields=remark");

        softAssert.assertAll();
        logger.info("LoanDetail remark fields validated");
    }

    public void validateReminderFieldsPresent(Response response) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        softAssert.assertNotNull(json.get("output.reminders"),
                "reminders must be present when fields=reminders");

        softAssert.assertAll();
        logger.info("LoanDetail reminders fields validated");
    }

    public void validateLoanIdInResponse(Response response, String expectedLoanId) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), 200, "Should be HTTP 200");
        String actualLoanId = json.getString("output.loan_details.loan_id");
        if (actualLoanId == null) {
            actualLoanId = json.getString("output.applicant_details.client_customer_id");
        }
        softAssert.assertNotNull(actualLoanId, "loan_id or client_customer_id must be present in output");
        if (expectedLoanId != null && actualLoanId != null) {
            softAssert.assertEquals(actualLoanId, expectedLoanId,
                    "loan_id in response should match requested loan_id");
        }

        softAssert.assertAll();
        logger.info("LoanDetail loan_id in response validated: expected={} actual={}", expectedLoanId, actualLoanId);
    }

    public void validateErrorMessage(Response response, int expectedStatus, String expectedMessage) {
        JsonPath json = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertEquals(response.getStatusCode(), expectedStatus,
                "Status code mismatch for error: " + expectedMessage);
        softAssert.assertEquals(json.getString("message"), expectedMessage,
                "Error message mismatch");

        softAssert.assertAll();
        logger.info("LoanDetail error validated: status={} message={}", expectedStatus, expectedMessage);
    }
}

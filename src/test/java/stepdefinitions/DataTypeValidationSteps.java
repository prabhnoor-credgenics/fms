package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.datatype.DataTypeValidator;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

public class DataTypeValidationSteps {
    private static final Logger logger = LogManager.getLogger(DataTypeValidationSteps.class);

    private final TestContext testContext;

    public DataTypeValidationSteps(TestContext testContext) {
        this.testContext = testContext;
    }

    private Response response() {
        Response response = testContext.getResponse();
        if (response == null) {
            throw new IllegalStateException("No API response available. Send a request before validating fields.");
        }
        return response;
    }

    @Then("the field {string} should be a valid text with max length {int}")
    public void the_field_should_be_valid_text(String jsonPath, int maxLength) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidText(fieldValue.toString(), maxLength);
            assertThat("Field '" + jsonPath + "' failed text validation", isValid, is(true));
            logger.info("Field '{}' passed text validation (max length: {})", jsonPath, maxLength);
        } else {
            logger.warn("Field '{}' is null, skipping text validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid boolean")
    public void the_field_should_be_valid_boolean(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidBoolean(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed boolean validation", isValid, is(true));
            logger.info("Field '{}' passed boolean validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid integer")
    public void the_field_should_be_valid_integer(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidInteger(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed integer validation", isValid, is(true));
            logger.info("Field '{}' passed integer validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid integer in range {int} to {int}")
    public void the_field_should_be_valid_integer_in_range(String jsonPath, int min, int max) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidIntegerInRange(fieldValue.toString(), min, max);
            assertThat("Field '" + jsonPath + "' failed integer range validation (expected: " + min + "-" + max + ")", isValid, is(true));
            logger.info("Field '{}' passed integer range validation ({}-{})", jsonPath, min, max);
        }
    }

    @Then("the field {string} should be a valid decimal")
    public void the_field_should_be_valid_decimal(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidDecimal(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed decimal validation", isValid, is(true));
            logger.info("Field '{}' passed decimal validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid amount")
    public void the_field_should_be_valid_amount(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidAmount(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed amount validation", isValid, is(true));
            logger.info("Field '{}' passed amount validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid percentage")
    public void the_field_should_be_valid_percentage(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidPercentage(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed percentage validation", isValid, is(true));
            logger.info("Field '{}' passed percentage validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid mobile number")
    public void the_field_should_be_valid_mobile_number(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidMobileNumber(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed mobile number validation", isValid, is(true));
            logger.info("Field '{}' passed mobile number validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid email")
    public void the_field_should_be_valid_email(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidEmail(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed email validation", isValid, is(true));
            logger.info("Field '{}' passed email validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid pincode")
    public void the_field_should_be_valid_pincode(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidPincode(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed pincode validation", isValid, is(true));
            logger.info("Field '{}' passed pincode validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid URL")
    public void the_field_should_be_valid_url(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidUrl(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed URL validation", isValid, is(true));
            logger.info("Field '{}' passed URL validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid date")
    public void the_field_should_be_valid_date(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidDate(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed date validation (expected YYYY-MM-DD format)", isValid, is(true));
            logger.info("Field '{}' passed date validation", jsonPath);
        }
    }

    @Then("the field {string} should be a valid CIBIL score")
    public void the_field_should_be_valid_cibil_score(String jsonPath) {
        Object fieldValue = response().jsonPath().get(jsonPath);
        if (fieldValue != null) {
            boolean isValid = DataTypeValidator.isValidCibilScore(fieldValue.toString());
            assertThat("Field '" + jsonPath + "' failed CIBIL score validation (expected range: 300-900)", isValid, is(true));
            logger.info("Field '{}' passed CIBIL score validation", jsonPath);
        }
    }
}

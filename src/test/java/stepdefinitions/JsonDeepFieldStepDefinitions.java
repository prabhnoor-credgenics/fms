package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.JsonDeepFieldHelper;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.Assert;


public class JsonDeepFieldStepDefinitions {

    private static final Logger logger = LogManager.getLogger(JsonDeepFieldStepDefinitions.class);

    private static final String SIGN_RULE =
            "(positive|negative|non-negative|non-positive|zero|non-zero)";

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public JsonDeepFieldStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }


    @Then("key {string} should exist somewhere in the response")
    public void key_should_exist_somewhere_in_the_response(String key) {
        key_should_exist_somewhere_under_path(key, "$");
    }

    @Then("key {string} should exist somewhere under path {string}")
    public void key_should_exist_somewhere_under_path(String key, String rootPath) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertKeyPresent(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted key '{}' exists under '{}'", field, displayPath(path));
    }

    @Then("the count of {string} in the response should be {int}")
    public void the_count_of_in_the_response_should_be(String key, int expectedCount) {
        the_count_of_under_path_should_be(key, "$", expectedCount);
    }

    @Then("the count of {string} under path {string} should be {int}")
    public void the_count_of_under_path_should_be(String key, String rootPath, int expectedCount) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        int actual = JsonDeepFieldHelper.count(ResponseHelper.resolve(null, testContext), path, field);
        Assert.assertEquals(
                actual,
                expectedCount,
                "Expected " + expectedCount + " occurrence(s) of '" + field
                        + "' under '" + displayPath(path) + "' but found " + actual
        );
        logger.info("Asserted count of '{}' under '{}' is {}", field, displayPath(path), expectedCount);
    }

    @Then("the count of {string} in the response should be at least {int}")
    public void the_count_of_in_the_response_should_be_at_least(String key, int minCount) {
        the_count_of_under_path_should_be_at_least(key, "$", minCount);
    }

    @Then("the count of {string} under path {string} should be at least {int}")
    public void the_count_of_under_path_should_be_at_least(String key, String rootPath, int minCount) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        int actual = JsonDeepFieldHelper.count(ResponseHelper.resolve(null, testContext), path, field);
        Assert.assertTrue(
                actual >= minCount,
                "Expected at least " + minCount + " occurrence(s) of '" + field
                        + "' under '" + displayPath(path) + "' but found " + actual
        );
        logger.info("Asserted count of '{}' under '{}' is >= {} (actual={})", field, displayPath(path), minCount, actual);
    }

    @Then("I remember the count of {string} under path {string} as {string}")
    public void i_remember_the_count_of_under_path_as(String key, String rootPath, String rememberAs) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        String as = requireResolved("rememberAs", rememberAs);
        int count = JsonDeepFieldHelper.count(ResponseHelper.resolve(null, testContext), path, field);
        testContext.captureValue(as, String.valueOf(count));
        logger.info("Remembered count of '{}' under '{}' as '{}' = {}", field, displayPath(path), as, count);
    }


    @Then("all values of {string} in the response should be unique")
    public void all_values_of_in_the_response_should_be_unique(String key) {
        all_values_of_under_path_should_be_unique(key, "$");
    }

    @Then("all values of {string} under path {string} should be unique")
    public void all_values_of_under_path_should_be_unique(String key, String rootPath) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertUniqueValues(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted all '{}' under '{}' are unique", field, displayPath(path));
    }


    @Then("all values of {string} in the response should be {string}")
    public void all_values_of_in_the_response_should_be(String key, String datatype) {
        all_values_of_under_path_should_be(key, "$", datatype);
    }

    @Then("all values of {string} under path {string} should be {string}")
    public void all_values_of_under_path_should_be(String key, String rootPath, String datatype) {
        assertDatatype(key, rootPath, datatype, false);
    }

    @Then("all values of {string} in the response should be {string} or null")
    public void all_values_of_in_the_response_should_be_or_null(String key, String datatype) {
        all_values_of_under_path_should_be_or_null(key, "$", datatype);
    }

    @Then("all values of {string} under path {string} should be {string} or null")
    public void all_values_of_under_path_should_be_or_null(String key, String rootPath, String datatype) {
        assertDatatype(key, rootPath, datatype, true);
    }


    @Then("all values of {string} in the response should be null")
    public void all_values_of_in_the_response_should_be_null(String key) {
        all_values_of_under_path_should_be_null(key, "$");
    }

    @Then("all values of {string} under path {string} should be null")
    public void all_values_of_under_path_should_be_null(String key, String rootPath) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertAllNull(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted all '{}' under '{}' are null", field, displayPath(path));
    }

    @Then("all values of {string} in the response should not be null")
    public void all_values_of_in_the_response_should_not_be_null(String key) {
        all_values_of_under_path_should_not_be_null(key, "$");
    }

    @Then("all values of {string} under path {string} should not be null")
    public void all_values_of_under_path_should_not_be_null(String key, String rootPath) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertAllNotNull(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted all '{}' under '{}' are not null", field, displayPath(path));
    }


    @Then("all values of {string} in the response should have length {int}")
    public void all_values_of_in_the_response_should_have_length(String key, int expectedLength) {
        all_values_of_under_path_should_have_length(key, "$", expectedLength);
    }

    @Then("all values of {string} under path {string} should have length {int}")
    public void all_values_of_under_path_should_have_length(String key, String rootPath, int expectedLength) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertStringLengthEquals(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                expectedLength,
                false
        );
        logger.info("Asserted all '{}' under '{}' have length {}", field, displayPath(path), expectedLength);
    }

    @Then("all values of {string} in the response should have length {int} or be null")
    public void all_values_of_in_the_response_should_have_length_or_be_null(String key, int expectedLength) {
        all_values_of_under_path_should_have_length_or_be_null(key, "$", expectedLength);
    }

    @Then("all values of {string} under path {string} should have length {int} or be null")
    public void all_values_of_under_path_should_have_length_or_be_null(String key, String rootPath, int expectedLength) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertStringLengthEquals(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                expectedLength,
                true
        );
        logger.info("Asserted all '{}' under '{}' have length {} or null", field, displayPath(path), expectedLength);
    }

    @Then("all values of {string} in the response should have length between {int} and {int}")
    public void all_values_of_in_the_response_should_have_length_between(String key, int min, int max) {
        all_values_of_under_path_should_have_length_between(key, "$", min, max);
    }

    @Then("all values of {string} under path {string} should have length between {int} and {int}")
    public void all_values_of_under_path_should_have_length_between(String key, String rootPath, int min, int max) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertStringLengthBetween(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                min,
                max,
                false
        );
        logger.info("Asserted all '{}' under '{}' have length between {} and {}", field, displayPath(path), min, max);
    }

    @Then("all values of {string} in the response should have length between {int} and {int} or be null")
    public void all_values_of_in_the_response_should_have_length_between_or_null(String key, int min, int max) {
        all_values_of_under_path_should_have_length_between_or_null(key, "$", min, max);
    }

    @Then("all values of {string} under path {string} should have length between {int} and {int} or be null")
    public void all_values_of_under_path_should_have_length_between_or_null(
            String key, String rootPath, int min, int max) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertStringLengthBetween(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                min,
                max,
                true
        );
        logger.info(
                "Asserted all '{}' under '{}' have length between {} and {} or null",
                field,
                displayPath(path),
                min,
                max
        );
    }


    @Then("all values of {string} in the response should match regex {string}")
    public void all_values_of_in_the_response_should_match_regex(String key, String regex) {
        all_values_of_under_path_should_match_regex(key, "$", regex);
    }

    @Then("all values of {string} under path {string} should match regex {string}")
    public void all_values_of_under_path_should_match_regex(String key, String rootPath, String regex) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        String pattern = requireResolved("regex", regex);
        JsonDeepFieldHelper.assertMatchesRegex(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                pattern,
                false
        );
        logger.info("Asserted all '{}' under '{}' match regex '{}'", field, displayPath(path), pattern);
    }

    @Then("all values of {string} in the response should match regex {string} or be null")
    public void all_values_of_in_the_response_should_match_regex_or_null(String key, String regex) {
        all_values_of_under_path_should_match_regex_or_null(key, "$", regex);
    }

    @Then("all values of {string} under path {string} should match regex {string} or be null")
    public void all_values_of_under_path_should_match_regex_or_null(String key, String rootPath, String regex) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        String pattern = requireResolved("regex", regex);
        JsonDeepFieldHelper.assertMatchesRegex(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                pattern,
                true
        );
        logger.info("Asserted all '{}' under '{}' match regex '{}' or null", field, displayPath(path), pattern);
    }


    @Then("all values of {string} in the response should be " + SIGN_RULE + " integer")
    public void all_values_of_in_the_response_should_be_sign_integer(String key, String signRule) {
        assertNumeric(key, "$", signRule, true, false);
    }

    @Then("all values of {string} under path {string} should be " + SIGN_RULE + " integer")
    public void all_values_of_under_path_should_be_sign_integer(String key, String rootPath, String signRule) {
        assertNumeric(key, rootPath, signRule, true, false);
    }

    @Then("all values of {string} in the response should be " + SIGN_RULE + " integer or null")
    public void all_values_of_in_the_response_should_be_sign_integer_or_null(String key, String signRule) {
        assertNumeric(key, "$", signRule, true, true);
    }

    @Then("all values of {string} under path {string} should be " + SIGN_RULE + " integer or null")
    public void all_values_of_under_path_should_be_sign_integer_or_null(
            String key, String rootPath, String signRule) {
        assertNumeric(key, rootPath, signRule, true, true);
    }

    @Then("all values of {string} in the response should be " + SIGN_RULE + " number")
    public void all_values_of_in_the_response_should_be_sign_number(String key, String signRule) {
        assertNumeric(key, "$", signRule, false, false);
    }

    @Then("all values of {string} under path {string} should be " + SIGN_RULE + " number")
    public void all_values_of_under_path_should_be_sign_number(String key, String rootPath, String signRule) {
        assertNumeric(key, rootPath, signRule, false, false);
    }

    @Then("all values of {string} in the response should be " + SIGN_RULE + " number or null")
    public void all_values_of_in_the_response_should_be_sign_number_or_null(String key, String signRule) {
        assertNumeric(key, "$", signRule, false, true);
    }

    @Then("all values of {string} under path {string} should be " + SIGN_RULE + " number or null")
    public void all_values_of_under_path_should_be_sign_number_or_null(
            String key, String rootPath, String signRule) {
        assertNumeric(key, rootPath, signRule, false, true);
    }


    @Then("all values of {string} in the response should have array size {int}")
    public void all_values_of_in_the_response_should_have_array_size(String key, int expectedSize) {
        all_values_of_under_path_should_have_array_size(key, "$", expectedSize);
    }

    @Then("all values of {string} under path {string} should have array size {int}")
    public void all_values_of_under_path_should_have_array_size(String key, String rootPath, int expectedSize) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertArraySizeEquals(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                expectedSize,
                false
        );
        logger.info("Asserted all '{}' under '{}' have array size {}", field, displayPath(path), expectedSize);
    }

    @Then("all values of {string} in the response should have array size {int} or be null")
    public void all_values_of_in_the_response_should_have_array_size_or_null(String key, int expectedSize) {
        all_values_of_under_path_should_have_array_size_or_null(key, "$", expectedSize);
    }

    @Then("all values of {string} under path {string} should have array size {int} or be null")
    public void all_values_of_under_path_should_have_array_size_or_null(
            String key, String rootPath, int expectedSize) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertArraySizeEquals(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                expectedSize,
                true
        );
        logger.info(
                "Asserted all '{}' under '{}' have array size {} or null",
                field,
                displayPath(path),
                expectedSize
        );
    }

    @Then("all values of {string} in the response should have array size at least {int}")
    public void all_values_of_in_the_response_should_have_array_size_at_least(String key, int minSize) {
        all_values_of_under_path_should_have_array_size_at_least(key, "$", minSize);
    }

    @Then("all values of {string} under path {string} should have array size at least {int}")
    public void all_values_of_under_path_should_have_array_size_at_least(String key, String rootPath, int minSize) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertArraySizeAtLeast(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                minSize,
                false
        );
        logger.info("Asserted all '{}' under '{}' have array size >= {}", field, displayPath(path), minSize);
    }

    @Then("all values of {string} in the response should have array size at least {int} or be null")
    public void all_values_of_in_the_response_should_have_array_size_at_least_or_null(String key, int minSize) {
        all_values_of_under_path_should_have_array_size_at_least_or_null(key, "$", minSize);
    }

    @Then("all values of {string} under path {string} should have array size at least {int} or be null")
    public void all_values_of_under_path_should_have_array_size_at_least_or_null(
            String key, String rootPath, int minSize) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        JsonDeepFieldHelper.assertArraySizeAtLeast(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                minSize,
                true
        );
        logger.info(
                "Asserted all '{}' under '{}' have array size >= {} or null",
                field,
                displayPath(path),
                minSize
        );
    }


    private void assertDatatype(String key, String rootPath, String datatype, boolean allowNull) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        String type = requireResolved("datatype", datatype);
        JsonDeepFieldHelper.assertDatatype(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                type,
                allowNull
        );
        logger.info(
                "Asserted all '{}' under '{}' are datatype '{}'{}",
                field,
                displayPath(path),
                type,
                allowNull ? " or null" : ""
        );
    }

    private void assertNumeric(
            String key,
            String rootPath,
            String signRule,
            boolean requireInteger,
            boolean allowNull) {
        String field = requireResolved("key", key);
        String path = resolveRootPath(rootPath);
        // Helper signature: (response, rootPath, fieldName, signRule, allowNull, requireInteger)
        JsonDeepFieldHelper.assertNumericSign(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                signRule,
                allowNull,
                requireInteger
        );
        logger.info(
                "Asserted all '{}' under '{}' are {} {}{}",
                field,
                displayPath(path),
                signRule,
                requireInteger ? "integer" : "number",
                allowNull ? " or null" : ""
        );
    }

    private String resolveRootPath(String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null || resolved.isBlank() || "$".equals(resolved.trim())) {
            return "";
        }
        return resolved.trim();
    }

    private static String displayPath(String path) {
        return (path == null || path.isBlank()) ? "$" : path;
    }

    private String requireResolved(String label, String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null || resolved.isBlank()) {
            throw new IllegalArgumentException("Resolved " + label + " is blank");
        }
        return resolved.trim();
    }
}

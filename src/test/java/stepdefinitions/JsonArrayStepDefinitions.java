package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.JsonArrayHelper;
import helpers.JsonKeyHelper;
import helpers.ResponseHelper;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;

public class JsonArrayStepDefinitions {

    private static final Logger logger = LogManager.getLogger(JsonArrayStepDefinitions.class);

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public JsonArrayStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }



    @Then("I extract {string} from array {string} using {string} with value {string} and remember as {string}")
    public void i_extract_from_array_using_with_value_and_remember_as(
            String targetKey,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String rememberAs
    ) {
        String resolvedTargetKey = requireResolved("target key", targetKey);
        String resolvedArrayPath = requireResolved("array path", arrayPath);
        String resolvedReferenceKey = requireResolved("reference key", referenceKey);
        String resolvedReferenceValue = requireResolved("reference value", referenceValue);
        String resolvedRememberAs = requireResolved("remember-as key", rememberAs);

        Response response = ResponseHelper.resolve(null, testContext);
        String extracted = JsonArrayHelper.extractField(
                response,
                resolvedArrayPath,
                resolvedReferenceKey,
                resolvedReferenceValue,
                resolvedTargetKey
        );
        testContext.captureValue(resolvedRememberAs, extracted);
        logger.info(
                "Extracted '{}'='{}' from array '{}' where {}='{}' and remembered as {{CAPTURED:{}}}",
                resolvedTargetKey,
                extracted,
                resolvedArrayPath,
                resolvedReferenceKey,
                resolvedReferenceValue,
                resolvedRememberAs
        );
    }

    @Then("I validate {string} in array {string} using {string} with value {string} equals {string}")
    public void i_validate_in_array_using_with_value_equals(
            String targetKey,
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String expectedValue
    ) {
        String resolvedTargetKey = requireResolved("target key", targetKey);
        String resolvedArrayPath = requireResolved("array path", arrayPath);
        String resolvedReferenceKey = requireResolved("reference key", referenceKey);
        String resolvedReferenceValue = requireResolved("reference value", referenceValue);
        String resolvedExpected = requireResolved("expected value", expectedValue);

        Response response = ResponseHelper.resolve(null, testContext);
        JsonArrayHelper.validateField(
                response,
                resolvedArrayPath,
                resolvedReferenceKey,
                resolvedReferenceValue,
                resolvedTargetKey,
                resolvedExpected
        );
        logger.info(
                "Validated array '{}' where {}='{}' has {}='{}'",
                resolvedArrayPath,
                resolvedReferenceKey,
                resolvedReferenceValue,
                resolvedTargetKey,
                resolvedExpected
        );
    }



    @Then("the array {string} should be empty")
    public void the_array_should_be_empty(String arrayPath) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertEmpty(ResponseHelper.resolve(null, testContext), path);
        logger.info("Asserted array '{}' is empty", path);
    }

    @Then("the array {string} should not be empty")
    public void the_array_should_not_be_empty(String arrayPath) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertNotEmpty(ResponseHelper.resolve(null, testContext), path);
        logger.info("Asserted array '{}' is not empty", path);
    }

    @Then("the array {string} size should be {int}")
    public void the_array_size_should_be(String arrayPath, Integer expectedSize) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertSizeEquals(ResponseHelper.resolve(null, testContext), path, expectedSize);
        logger.info("Asserted array '{}' size == {}", path, expectedSize);
    }

    @Then("the array {string} size should be greater than {int}")
    public void the_array_size_should_be_greater_than(String arrayPath, Integer minExclusive) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertSizeGreaterThan(ResponseHelper.resolve(null, testContext), path, minExclusive);
        logger.info("Asserted array '{}' size > {}", path, minExclusive);
    }

    @Then("the array {string} size should be less than {int}")
    public void the_array_size_should_be_less_than(String arrayPath, Integer maxExclusive) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertSizeLessThan(ResponseHelper.resolve(null, testContext), path, maxExclusive);
        logger.info("Asserted array '{}' size < {}", path, maxExclusive);
    }

    @Then("the array {string} size should be at least {int}")
    public void the_array_size_should_be_at_least(String arrayPath, Integer minInclusive) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertSizeAtLeast(ResponseHelper.resolve(null, testContext), path, minInclusive);
        logger.info("Asserted array '{}' size >= {}", path, minInclusive);
    }

    @Then("the array {string} size should be at most {int}")
    public void the_array_size_should_be_at_most(String arrayPath, Integer maxInclusive) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertSizeAtMost(ResponseHelper.resolve(null, testContext), path, maxInclusive);
        logger.info("Asserted array '{}' size <= {}", path, maxInclusive);
    }

    @Then("the array {string} size should be between {int} and {int}")
    public void the_array_size_should_be_between(String arrayPath, Integer minInclusive, Integer maxInclusive) {
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertSizeBetween(
                ResponseHelper.resolve(null, testContext),
                path,
                minInclusive,
                maxInclusive
        );
        logger.info("Asserted array '{}' size between {} and {}", path, minInclusive, maxInclusive);
    }

    @Then("I store array {string} size as {string}")
    public void i_store_array_size_as(String arrayPath, String rememberAs) {
        String path = requireResolved("array path", arrayPath);
        String key = requireResolved("remember-as key", rememberAs);
        int size = JsonArrayHelper.size(ResponseHelper.resolve(null, testContext), path);
        testContext.captureValue(key, String.valueOf(size));
        logger.info("Stored array '{}' size={} as {{CAPTURED:{}}}", path, size, key);
    }

    // --- Contains / content ---

    @Then("the array {string} should contain item where {string} is {string}")
    public void the_array_should_contain_item_where(String arrayPath, String referenceKey, String referenceValue) {
        String path = requireResolved("array path", arrayPath);
        String refKey = requireResolved("reference key", referenceKey);
        String refVal = requireResolved("reference value", referenceValue);
        JsonArrayHelper.assertContainsItem(ResponseHelper.resolve(null, testContext), path, refKey, refVal);
        logger.info("Asserted array '{}' contains item where {}='{}'", path, refKey, refVal);
    }

    @Then("the array {string} should not contain item where {string} is {string}")
    public void the_array_should_not_contain_item_where(String arrayPath, String referenceKey, String referenceValue) {
        String path = requireResolved("array path", arrayPath);
        String refKey = requireResolved("reference key", referenceKey);
        String refVal = requireResolved("reference value", referenceValue);
        JsonArrayHelper.assertDoesNotContainItem(ResponseHelper.resolve(null, testContext), path, refKey, refVal);
        logger.info("Asserted array '{}' does not contain item where {}='{}'", path, refKey, refVal);
    }

    @Then("the array {string} should have {int} items where {string} is {string}")
    public void the_array_should_have_n_items_where(
            String arrayPath,
            Integer expectedCount,
            String referenceKey,
            String referenceValue
    ) {
        String path = requireResolved("array path", arrayPath);
        String refKey = requireResolved("reference key", referenceKey);
        String refVal = requireResolved("reference value", referenceValue);
        JsonArrayHelper.assertMatchCount(
                ResponseHelper.resolve(null, testContext),
                path,
                refKey,
                refVal,
                expectedCount
        );
        logger.info("Asserted array '{}' has {} item(s) where {}='{}'", path, expectedCount, refKey, refVal);
    }

    @Then("every item in array {string} should have key {string}")
    public void every_item_in_array_should_have_key(String arrayPath, String key) {
        String path = requireResolved("array path", arrayPath);
        String field = requireResolved("key", key);
        JsonArrayHelper.assertEveryItemHasKey(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted every item in array '{}' has key '{}'", path, field);
    }

    @Then("any item in array {string} should have key {string}")
    public void any_item_in_array_should_have_key(String arrayPath, String key) {
        String path = requireResolved("array path", arrayPath);
        String field = requireResolved("key", key);
        JsonKeyHelper.assertAnyItemHasKey(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted at least one item in array '{}' has key '{}'", path, field);
    }

    @Then("no item in array {string} should have key {string}")
    public void no_item_in_array_should_have_key(String arrayPath, String key) {
        String path = requireResolved("array path", arrayPath);
        String field = requireResolved("key", key);
        JsonKeyHelper.assertNoItemHasKey(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted no item in array '{}' has key '{}'", path, field);
    }

    @Then("the JSON object {string} should contain key {string}")
    public void the_json_object_should_contain_key(String objectPath, String key) {
        String path = resolvePathAllowingRoot(objectPath);
        String field = requireResolved("key", key);
        JsonKeyHelper.assertObjectContainsKey(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted JSON object '{}' contains key '{}'", path.isBlank() ? "$" : path, field);
    }

    @Then("the JSON object {string} should not contain key {string}")
    public void the_json_object_should_not_contain_key(String objectPath, String key) {
        String path = resolvePathAllowingRoot(objectPath);
        String field = requireResolved("key", key);
        JsonKeyHelper.assertObjectDoesNotContainKey(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted JSON object '{}' does not contain key '{}'", path.isBlank() ? "$" : path, field);
    }

    @Then("the item in array {string} where {string} is {string} should contain key {string}")
    public void the_item_in_array_where_should_contain_key(
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String key
    ) {
        String path = requireResolved("array path", arrayPath);
        String refKey = requireResolved("reference key", referenceKey);
        String refVal = requireResolved("reference value", referenceValue);
        String field = requireResolved("key", key);
        JsonKeyHelper.assertMatchedItemContainsKey(
                ResponseHelper.resolve(null, testContext),
                path,
                refKey,
                refVal,
                field
        );
        logger.info(
                "Asserted matched item in array '{}' where {}='{}' contains key '{}'",
                path, refKey, refVal, field
        );
    }

    @Then("the item in array {string} where {string} is {string} should not contain key {string}")
    public void the_item_in_array_where_should_not_contain_key(
            String arrayPath,
            String referenceKey,
            String referenceValue,
            String key
    ) {
        String path = requireResolved("array path", arrayPath);
        String refKey = requireResolved("reference key", referenceKey);
        String refVal = requireResolved("reference value", referenceValue);
        String field = requireResolved("key", key);
        JsonKeyHelper.assertMatchedItemDoesNotContainKey(
                ResponseHelper.resolve(null, testContext),
                path,
                refKey,
                refVal,
                field
        );
        logger.info(
                "Asserted matched item in array '{}' where {}='{}' does not contain key '{}'",
                path, refKey, refVal, field
        );
    }

    @Then("every item in array {string} should have {string} equal to {string}")
    public void every_item_in_array_should_have_equal_to(String arrayPath, String key, String expectedValue) {
        String path = requireResolved("array path", arrayPath);
        String field = requireResolved("key", key);
        String expected = requireResolved("expected value", expectedValue);
        JsonArrayHelper.assertEveryItemFieldEquals(
                ResponseHelper.resolve(null, testContext),
                path,
                field,
                expected
        );
        logger.info("Asserted every item in array '{}' has {}='{}'", path, field, expected);
    }

    @Then("values of {string} in array {string} should be unique")
    public void values_of_in_array_should_be_unique(String key, String arrayPath) {
        String field = requireResolved("key", key);
        String path = requireResolved("array path", arrayPath);
        JsonArrayHelper.assertValuesUnique(ResponseHelper.resolve(null, testContext), path, field);
        logger.info("Asserted values of '{}' in array '{}' are unique", field, path);
    }

    @Then("I extract all {string} from array {string} and remember as {string}")
    public void i_extract_all_from_array_and_remember_as(String key, String arrayPath, String rememberAs) {
        String field = requireResolved("key", key);
        String path = requireResolved("array path", arrayPath);
        String captureKey = requireResolved("remember-as key", rememberAs);
        List<String> values = JsonArrayHelper.extractAllFieldValues(
                ResponseHelper.resolve(null, testContext),
                path,
                field
        );
        testContext.captureObject(captureKey, values);
        logger.info(
                "Extracted {} value(s) of '{}' from array '{}' as {{CAPTURED:{}}}",
                values.size(),
                field,
                path,
                captureKey
        );
    }


    private String resolvePathAllowingRoot(String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null) {
            return "";
        }
        return resolved.trim();
    }

    private String requireResolved(String label, String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null || resolved.isBlank()) {
            throw new IllegalArgumentException("Resolved " + label + " is blank");
        }
        return resolved.trim();
    }
}

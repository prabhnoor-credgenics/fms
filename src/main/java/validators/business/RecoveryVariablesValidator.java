package validators.business;

import context.ScenarioTestDataResolver;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.asserts.SoftAssert;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


public class RecoveryVariablesValidator {

    private static final Logger logger = LogManager.getLogger(RecoveryVariablesValidator.class);

    private static final List<String> KNOWN_COMPUTED_VARIABLE_NAMES = List.of(
            "dpd",
            "balance_claim_amount",
            "dpd_bracket"
    );

    /** Present when include_meta_data=true; omitted when false (is_trackable may still appear). */
    private static final String META_DATA_FIELD = "description";

    private static final List<String> MANDATORY_VARIABLE_FIELDS = List.of(
            "variable_id",
            "variable_path",
            "variable_name",
            "variable_type",
            "data_type",
            "active",
            "is_default_variable",
            "is_allocation_variable",
            "is_mandatory",
            "variable_category"
    );

    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public RecoveryVariablesValidator(ScenarioTestDataResolver scenarioTestDataResolver) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
    }

    public void validateMandatoryFields(Response response) {
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        softAssert.assertNotNull(jsonPath.get("output"), "output array must be present");
        softAssert.assertNotNull(jsonPath.get("message"), "message must be present");
        softAssert.assertNotNull(jsonPath.get("message_template"), "message_template must be present");
        softAssert.assertNotNull(jsonPath.get("message_placeholder"), "message_placeholder must be present");

        List<Map<String, Object>> output = jsonPath.getList("output");
        softAssert.assertNotNull(output, "output must be a non-null array");
        softAssert.assertTrue(output != null && !output.isEmpty(), "output array must not be empty");

        if (output != null) {
            validateVariableList(output, "output", softAssert);
        }

        softAssert.assertAll();
        logger.info("Recovery variables mandatory field validation passed");
    }

    public void validateCompanyIdMapping(Response response) {
        String expectedCompanyId = scenarioTestDataResolver.resolveCompanyId();
        JsonPath jsonPath = response.jsonPath();
        SoftAssert softAssert = new SoftAssert();

        List<Map<String, Object>> output = jsonPath.getList("output");
        softAssert.assertNotNull(output, "output must not be null for company_id=" + expectedCompanyId);
        softAssert.assertTrue(
                output != null && !output.isEmpty(),
                "output must contain variables for company_id=" + expectedCompanyId
        );

        String message = jsonPath.getString("message");
        softAssert.assertNotNull(message, "message must be present");
        softAssert.assertTrue(!message.isBlank(), "message must not be blank");

        softAssert.assertAll();
        logger.info(
                "Recovery variables company scope validated for company_id={} ({} top-level variables)",
                expectedCompanyId,
                output == null ? 0 : output.size()
        );
    }

    public void validateComputedVariablesIncluded(Response response) {
        Set<String> variableNames = collectVariableNames(response);
        int computedFlagCount = countComputedVariableFlags(response);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertTrue(
                computedFlagCount > 0 || containsAnyKnownComputedVariable(variableNames),
                "Expected computed variables when include_computed_variables=true "
                        + "(is_computed_variable flags=" + computedFlagCount
                        + ", known names present=" + containsAnyKnownComputedVariable(variableNames) + ")"
        );
        softAssert.assertAll();
        logger.info(
                "Computed variables included: {} is_computed_variable flag(s), known names found={}",
                computedFlagCount,
                intersectsKnownComputedNames(variableNames)
        );
    }

    public void validateComputedVariablesExcluded(Response response) {
        Set<String> variableNames = collectVariableNames(response);
        int computedFlagCount = countComputedVariableFlags(response);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertEquals(
                computedFlagCount,
                0,
                "No variable should have is_computed_variable=true when include_computed_variables=false"
        );
        for (String computedName : KNOWN_COMPUTED_VARIABLE_NAMES) {
            softAssert.assertFalse(
                    variableNames.contains(computedName),
                    "Computed variable '" + computedName + "' must not be present when include_computed_variables=false"
            );
        }
        softAssert.assertAll();
        logger.info("Computed variables excluded from response");
    }

    public void validateResponseDiffersWhenComputedDisabled(Response withComputed, Response withoutComputed) {
        Set<String> namesWithComputed = collectVariableNames(withComputed);
        Set<String> namesWithoutComputed = collectVariableNames(withoutComputed);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertFalse(
                namesWithComputed.equals(namesWithoutComputed),
                "Variable name sets should differ between include_computed_variables=true and false"
        );

        for (String computedName : KNOWN_COMPUTED_VARIABLE_NAMES) {
            softAssert.assertTrue(
                    namesWithComputed.contains(computedName),
                    "Baseline response (include_computed_variables=true) should contain '" + computedName + "'"
            );
            softAssert.assertFalse(
                    namesWithoutComputed.contains(computedName),
                    "Response with include_computed_variables=false should not contain '" + computedName + "'"
            );
        }

        softAssert.assertTrue(
                namesWithComputed.size() > namesWithoutComputed.size(),
                "Response with computed variables should expose more variable names (with="
                        + namesWithComputed.size() + ", without=" + namesWithoutComputed.size() + ")"
        );

        softAssert.assertAll();
        logger.info(
                "Response diff validated: with computed {} variables, without computed {} variables",
                namesWithComputed.size(),
                namesWithoutComputed.size()
        );
    }

    public void validateMetaDataIncluded(Response response) {
        int descriptionCount = countFieldInTree(response, META_DATA_FIELD);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertTrue(
                descriptionCount > 0,
                "At least one variable should include '" + META_DATA_FIELD
                        + "' when include_meta_data=true (count=" + descriptionCount + ")"
        );
        softAssert.assertAll();
        logger.info("Meta data field '{}' included {} time(s)", META_DATA_FIELD, descriptionCount);
    }

    public void validateMetaDataExcluded(Response response) {
        int descriptionCount = countFieldInTree(response, META_DATA_FIELD);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertEquals(
                descriptionCount,
                0,
                "Field '" + META_DATA_FIELD + "' must not be present when include_meta_data=false"
        );
        softAssert.assertAll();
        logger.info("Meta data field '{}' excluded from response", META_DATA_FIELD);
    }

    public void validateResponseDiffersWhenMetaDisabled(Response withMeta, Response withoutMeta) {
        int descriptionsWithMeta = countFieldInTree(withMeta, META_DATA_FIELD);
        int descriptionsWithoutMeta = countFieldInTree(withoutMeta, META_DATA_FIELD);
        int totalKeysWithMeta = countAllKeysInTree(withMeta);
        int totalKeysWithoutMeta = countAllKeysInTree(withoutMeta);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertTrue(
                descriptionsWithMeta > 0,
                "Baseline response (include_meta_data=true) should contain description fields"
        );
        softAssert.assertEquals(
                descriptionsWithoutMeta,
                0,
                "Response with include_meta_data=false should not contain description fields"
        );
        softAssert.assertTrue(
                totalKeysWithMeta > totalKeysWithoutMeta,
                "Response with meta data should include more fields per variable objects (with="
                        + totalKeysWithMeta + ", without=" + totalKeysWithoutMeta + ")"
        );

        softAssert.assertAll();
        logger.info(
                "Meta data diff validated: description with={}, without={}; total keys with={}, without={}",
                descriptionsWithMeta,
                descriptionsWithoutMeta,
                totalKeysWithMeta,
                totalKeysWithoutMeta
        );
    }

    public void validateResponseDiffersWhenBothFlagsDisabled(Response withAll, Response minimal) {
        validateResponseDiffersWhenComputedDisabled(withAll, minimal);
        validateResponseDiffersWhenMetaDisabled(withAll, minimal);

        Set<String> namesWithAll = collectVariableNames(withAll);
        Set<String> namesMinimal = collectVariableNames(minimal);
        int keysWithAll = countAllKeysInTree(withAll);
        int keysMinimal = countAllKeysInTree(minimal);

        SoftAssert softAssert = new SoftAssert();
        softAssert.assertTrue(
                keysWithAll > keysMinimal,
                "Minimal response (computed=false, meta=false) should have fewer fields (with="
                        + keysWithAll + ", minimal=" + keysMinimal + ")"
        );
        softAssert.assertTrue(
                namesWithAll.size() > namesMinimal.size(),
                "Minimal response should expose fewer variable names (with="
                        + namesWithAll.size() + ", minimal=" + namesMinimal.size() + ")"
        );
        softAssert.assertAll();
        logger.info(
                "Both flags disabled diff validated: {} vs {} variable names, {} vs {} total keys",
                namesWithAll.size(),
                namesMinimal.size(),
                keysWithAll,
                keysMinimal
        );
    }

    private void validateVariableList(
            List<Map<String, Object>> variables,
            String pathPrefix,
            SoftAssert softAssert
    ) {
        for (int index = 0; index < variables.size(); index++) {
            Map<String, Object> item = variables.get(index);
            String prefix = pathPrefix + "[" + index + "]";
            assertMandatoryFieldsOnVariable(item, prefix, softAssert);

            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?> subList && !subList.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subList;
                validateVariableList(nested, prefix + ".sub_variables", softAssert);
            }
        }
    }

    private void assertMandatoryFieldsOnVariable(
            Map<String, Object> item,
            String prefix,
            SoftAssert softAssert
    ) {
        for (String field : MANDATORY_VARIABLE_FIELDS) {
            softAssert.assertTrue(
                    item.containsKey(field) && item.get(field) != null,
                    prefix + " missing mandatory field: " + field
            );
        }
        if (item.containsKey("variable_name")) {
            Object name = item.get("variable_name");
            softAssert.assertTrue(
                    name instanceof String && !((String) name).isBlank(),
                    prefix + ".variable_name must be a non-blank string"
            );
        }
        if (item.containsKey("variable_path")) {
            Object path = item.get("variable_path");
            softAssert.assertTrue(
                    path instanceof String && !((String) path).isBlank(),
                    prefix + ".variable_path must be a non-blank string"
            );
        }
    }

    private Set<String> collectVariableNames(Response response) {
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        Set<String> names = new HashSet<>();
        if (output != null) {
            collectVariableNamesFromList(output, names);
        }
        return names;
    }

    private void collectVariableNamesFromList(List<Map<String, Object>> variables, Set<String> names) {
        for (Map<String, Object> item : variables) {
            Object name = item.get("variable_name");
            if (name instanceof String variableName && !variableName.isBlank()) {
                names.add(variableName);
            }
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?> subList && !subList.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subList;
                collectVariableNamesFromList(nested, names);
            }
        }
    }

    private int countComputedVariableFlags(Response response) {
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        if (output == null) {
            return 0;
        }
        return countComputedVariableFlagsInList(output);
    }

    private int countComputedVariableFlagsInList(List<Map<String, Object>> variables) {
        int count = 0;
        for (Map<String, Object> item : variables) {
            if (Boolean.TRUE.equals(item.get("is_computed_variable"))) {
                count++;
            }
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?> subList && !subList.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subList;
                count += countComputedVariableFlagsInList(nested);
            }
        }
        return count;
    }

    private boolean containsAnyKnownComputedVariable(Set<String> variableNames) {
        return intersectsKnownComputedNames(variableNames);
    }

    private boolean intersectsKnownComputedNames(Set<String> variableNames) {
        for (String computedName : KNOWN_COMPUTED_VARIABLE_NAMES) {
            if (variableNames.contains(computedName)) {
                return true;
            }
        }
        return false;
    }

    private int countFieldInTree(Response response, String fieldName) {
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        if (output == null) {
            return 0;
        }
        return countFieldInList(output, fieldName);
    }

    private int countFieldInList(List<Map<String, Object>> variables, String fieldName) {
        int count = 0;
        for (Map<String, Object> item : variables) {
            if (item.containsKey(fieldName)) {
                count++;
            }
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?> subList && !subList.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subList;
                count += countFieldInList(nested, fieldName);
            }
        }
        return count;
    }

    private int countAllKeysInTree(Response response) {
        List<Map<String, Object>> output = response.jsonPath().getList("output");
        if (output == null) {
            return 0;
        }
        return countAllKeysInList(output);
    }

    private int countAllKeysInList(List<Map<String, Object>> variables) {
        int count = 0;
        for (Map<String, Object> item : variables) {
            count += item.size();
            Object subVars = item.get("sub_variables");
            if (subVars instanceof List<?> subList && !subList.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> nested = (List<Map<String, Object>>) subList;
                count += countAllKeysInList(nested);
            }
        }
        return count;
    }
}

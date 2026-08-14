package stepdefinitions;

import context.ScenarioTestDataResolver;
import helpers.CsvValidator;
import helpers.FileHelper;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.File;

public class CsvStepDefinitions {

    private static final Logger logger = LogManager.getLogger(CsvStepDefinitions.class);

    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final CsvValidator csvValidator;

    public CsvStepDefinitions(
            ScenarioTestDataResolver scenarioTestDataResolver,
            CsvValidator csvValidator
    ) {
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.csvValidator = csvValidator;
    }

    @Given("I load csv from {string}")
    public void i_load_csv_from(String filePath) {
        String resolved = requireResolved("csv path", filePath);
        File file = new File(resolved);
        if (!file.isFile()) {
            file = FileHelper.resolveTestFile(resolved);
        }
        csvValidator.loadDownloaded(file);
        logger.info("CSV loaded from '{}'", file.getAbsolutePath());
    }

    @Then("I validate CSV where {string} is {string} has {string} as {string}")
    public void i_validate_csv_where_is_has_as(
            String referenceColumn,
            String referenceValue,
            String targetColumn,
            String expectedValue
    ) {
        String refCol = requireResolved("reference column", referenceColumn);
        String refVal = requireResolved("reference value", referenceValue);
        String targetCol = requireResolved("target column", targetColumn);
        String expected = requireResolved("expected value", expectedValue);
        csvValidator.validateCellValue(refCol, refVal, targetCol, expected);
    }

    @Given("I clear the loaded csv")
    public void i_clear_the_loaded_csv() {
        String previous = csvValidator.getLoadedFilePath();
        csvValidator.closeQuietly();
        logger.info("Cleared loaded CSV from memory{}", previous == null ? "" : " (was: " + previous + ")");
    }

    private String requireResolved(String label, String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null || resolved.isBlank()) {
            throw new IllegalArgumentException("Resolved " + label + " is blank");
        }
        return resolved.trim();
    }
}

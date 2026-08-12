package stepdefinitions;

import context.ScenarioTestDataResolver;
import context.TestContext;
import helpers.ExcelValidator;
import helpers.FileHelper;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.File;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ExcelStepDefinitions {

    private static final Logger logger = LogManager.getLogger(ExcelStepDefinitions.class);
    private static final DateTimeFormatter FILE_TS = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_SSS");

    private final TestContext testContext;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final ExcelValidator excelValidator;

    public ExcelStepDefinitions(
            TestContext testContext,
            ScenarioTestDataResolver scenarioTestDataResolver,
            ExcelValidator excelValidator
    ) {
        this.testContext = testContext;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.excelValidator = excelValidator;
    }

    @When("I download file from absolute url {string} as {string}")
    public void i_download_file_from_absolute_url_as(String absoluteUrl, String captureKey) {
        String resolvedUrl = requireResolved("absolute url", absoluteUrl);
        String resolvedKey = requireResolved("capture key", captureKey);

        String extension = guessExtension(resolvedUrl);
        Path destination = Path.of(
                "target",
                "downloads",
                resolvedKey + "_" + LocalDateTime.now().format(FILE_TS) + extension
        );
        File downloaded = ExcelValidator.downloadToFile(resolvedUrl, destination);
        testContext.captureValue(resolvedKey, downloaded.getAbsolutePath());
        logger.info("Stored downloaded file path as '{}' = {}", resolvedKey, downloaded.getAbsolutePath());

        if (extension.equalsIgnoreCase(".xlsx") || extension.equalsIgnoreCase(".xls")) {
            excelValidator.loadDownloaded(downloaded);
        }
    }

    @Given("I load excel from {string}")
    public void i_load_excel_from(String filePath) {
        String resolved = requireResolved("excel path", filePath);
        File file = new File(resolved);
        if (!file.isFile()) {
            file = FileHelper.resolveTestFile(resolved);
        }
        excelValidator.loadDownloaded(file);
        logger.info("Excel loaded from '{}'", file.getAbsolutePath());
    }

    @Then("I validate Excel where {string} is {string} has {string} as {string}")
    public void i_validate_excel_where_is_has_as(
            String referenceColumn,
            String referenceValue,
            String targetColumn,
            String expectedValue
    ) {
        String refCol = requireResolved("reference column", referenceColumn);
        String refVal = requireResolved("reference value", referenceValue);
        String targetCol = requireResolved("target column", targetColumn);
        String expected = requireResolved("expected value", expectedValue);
        excelValidator.validateCellValue(refCol, refVal, targetCol, expected);
    }

    @Given("I clear the loaded excel")
    public void i_clear_the_loaded_excel() {
        String previous = excelValidator.getLoadedFilePath();
        excelValidator.closeQuietly();
        logger.info("Cleared loaded Excel from memory{}", previous == null ? "" : " (was: " + previous + ")");
    }

    private String requireResolved(String label, String raw) {
        String resolved = scenarioTestDataResolver.replaceScenarioPlaceholders(raw);
        if (resolved == null || resolved.isBlank()) {
            throw new IllegalArgumentException("Resolved " + label + " is blank");
        }
        return resolved.trim();
    }

    private static String guessExtension(String url) {
        String path = url;
        int query = path.indexOf('?');
        if (query >= 0) {
            path = path.substring(0, query);
        }
        String lower = path.toLowerCase();
        if (lower.endsWith(".xlsx")) {
            return ".xlsx";
        }
        if (lower.endsWith(".xls")) {
            return ".xls";
        }
        if (lower.endsWith(".csv")) {
            return ".csv";
        }
        // export links often omit extension; default to xlsx for this framework use-case
        return ".xlsx";
    }
}

package runners;

import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;


@CucumberOptions(
        features = "src/test/resources/features/recovery_loan/",
        glue = {
                "stepdefinitions",
                "hooks",
                "context",
                "config",
                "auth",
                "base",
                "utils",
                "helpers",
                "service",
                "payload",
                "validators"
        },
        plugin = {
                "pretty",
                "com.aventstack.extentreports.cucumber.adapter.ExtentCucumberAdapter:",
                "hooks.ThreadStatsListener",
                "rerun:rerun/failedrerun.txt"
        },

        monochrome = true,
        tags = "@500"

)
public class TestRunner extends AbstractTestNGCucumberTests {
}
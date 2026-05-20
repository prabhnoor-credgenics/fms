package runners;

import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;


@CucumberOptions(
        features = "src/test/resources/features/recovery/004_global_status.feature",
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
                "hooks.CucumberStepTracker",
                "html:target/cucumber-reports/cucumber.html",
                "json:target/cucumber-reports/cucumber.json",
                "junit:target/cucumber-reports/cucumber.xml",
                "timeline:target/cucumber-reports/timeline"
        },
        tags = "@api"
)
public class TestRunner extends AbstractTestNGCucumberTests {
}
package runners;

import hooks.SlackReportListener;
import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;
import org.testng.annotations.Listeners;

@Listeners(SlackReportListener.class)
@CucumberOptions(
        features = "@rerun/failedparallelrerun.txt",
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
                "rerun:rerun/failedrerun.txt",
                "hooks.SlackReportCucumberPlugin"
        },
monochrome = true,
        tags = "not @500"

        )
public class FailedScenarioRunner extends AbstractTestNGCucumberTests {
}


package runners;

import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;
import org.testng.annotations.DataProvider;

@CucumberOptions(
        features = "src/test/resources/features/",
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
        tags="@document-type and @array-lookup",
        monochrome = true
)
public class TestRunner extends AbstractTestNGCucumberTests {

    @Override
    @DataProvider(parallel = false)
    public Object[][] scenarios() {
        return super.scenarios();
    }

}

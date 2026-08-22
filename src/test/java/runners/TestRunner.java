package runners;

import hooks.SlackReportListener;
import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Listeners;

@Listeners(SlackReportListener.class)
@CucumberOptions(
        features = "src/test/resources/features/recovery_loan/068_bulk_export_now_loan.feature",
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

package runners;

import hooks.SlackReportListener;
import io.cucumber.testng.AbstractTestNGCucumberTests;
import io.cucumber.testng.CucumberOptions;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Listeners;


@Listeners(SlackReportListener.class)
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
                "rerun:rerun/failedrerun.txt",
                "hooks.SlackReportCucumberPlugin"
        },
        tags = "not @shouldfail and not @500 and not @public-access-token and not @internal-register-route and not @first-login and not @creditline",
        monochrome = true
)
public class ParallelCucumberRunner extends AbstractTestNGCucumberTests {

    @Override
    @DataProvider(parallel = true)
    public Object[][] scenarios() {
        return super.scenarios();
    }
}

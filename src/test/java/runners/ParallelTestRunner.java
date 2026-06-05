package runners;

import io.cucumber.testng.CucumberOptions;
import io.cucumber.testng.PickleWrapper;
import io.cucumber.testng.TestNGCucumberRunner;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import java.net.URI;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Runs feature files in parallel. All scenarios within the same feature file
 * execute sequentially on a single thread. Thread count is controlled by
 * data-provider-thread-count in testng-parallel.xml.
 */
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
                "hooks.ThreadStatsListener",
                "com.aventstack.extentreports.cucumber.adapter.ExtentCucumberAdapter:"
        },
        monochrome = true,
        tags = "@api"
)
public class ParallelTestRunner {

    private static final Logger logger = LogManager.getLogger(ParallelTestRunner.class);

    private TestNGCucumberRunner testNGCucumberRunner;

    @BeforeClass(alwaysRun = true)
    public void setUpClass() {
        testNGCucumberRunner = new TestNGCucumberRunner(this.getClass());
    }

    /**
     * Runs all scenarios of one feature file sequentially on the calling thread.
     * Failures are collected and the first one is re-thrown after all scenarios finish.
     */
    @Test(groups = "cucumber", description = "Runs Cucumber Feature", dataProvider = "features")
    public void runFeature(List<Object[]> scenarios) throws Throwable {
        Throwable firstFailure = null;
        for (Object[] row : scenarios) {
            PickleWrapper pickle = (PickleWrapper) row[0];
            try {
                testNGCucumberRunner.runScenario(pickle.getPickle());
            } catch (Throwable t) {
                if (firstFailure == null) {
                    firstFailure = t;
                }
            }
        }
        if (firstFailure != null) {
            throw firstFailure;
        }
    }

    /**
     * Groups all scenarios by their feature file URI. Each entry in the returned
     * array represents one feature file and becomes a single parallel unit of work.
     */
    @DataProvider(parallel = true)
    public Object[][] features() {
        Object[][] allScenarios = testNGCucumberRunner.provideScenarios();

        Map<URI, List<Object[]>> byFeature = new LinkedHashMap<>();
        for (Object[] row : allScenarios) {
            PickleWrapper pickle = (PickleWrapper) row[0];
            URI uri = pickle.getPickle().getUri();
            byFeature.computeIfAbsent(uri, k -> new ArrayList<>()).add(row);
        }

        logger.info("Parallel execution: {} feature(s) discovered, each will run on a single thread",
                byFeature.size());

        Object[][] result = new Object[byFeature.size()][];
        int i = 0;
        for (Map.Entry<URI, List<Object[]>> entry : byFeature.entrySet()) {
            String featureName = entry.getKey().toString();
            featureName = featureName.substring(featureName.lastIndexOf('/') + 1);
            logger.debug("Feature slot {}: {} ({} scenario(s))", i, featureName, entry.getValue().size());
            result[i++] = new Object[]{entry.getValue()};
        }
        return result;
    }

    @AfterClass(alwaysRun = true)
    public void tearDownClass() {
        testNGCucumberRunner.finish();
    }
}

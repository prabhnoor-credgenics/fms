package runners;

import org.testng.annotations.DataProvider;

/**
 * Same Cucumber features as {@link TestRunner}, but scenarios execute in parallel via TestNG.
 */
public class ParallelTestRunner extends TestRunner {

    @Override
    @DataProvider(parallel = true)
    public Object[][] scenarios() {
        return super.scenarios();
    }
}

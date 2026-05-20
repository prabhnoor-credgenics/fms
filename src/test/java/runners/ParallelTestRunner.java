package runners;

import org.testng.annotations.DataProvider;


public class ParallelTestRunner extends TestRunner {

    @Override
    @DataProvider(parallel = true)
    public Object[][] scenarios() {
        return super.scenarios();
    }
}

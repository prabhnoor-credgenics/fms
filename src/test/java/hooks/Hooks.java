package hooks;

import auth.allocator.ParallelUserAllocator;
import auth.manager.AuthManager;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.UserRole;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.DbClient;
import utils.LoggingContext;

public class Hooks {
    private static final Logger logger = LogManager.getLogger(Hooks.class);

    private final TestContext testContext;
    private final AuthManager authManager;
    private final DbClient dbClient;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final ParallelUserAllocator parallelUserAllocator;

    public Hooks(
            TestContext testContext,
            AuthManager authManager,
            DbClient dbClient,
            ScenarioTestDataResolver scenarioTestDataResolver,
            ParallelUserAllocator parallelUserAllocator
    ) {
        this.testContext = testContext;
        this.authManager = authManager;
        this.dbClient = dbClient;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.parallelUserAllocator = parallelUserAllocator;
    }

    @Before(order = 0)
    public void setUpScenario(Scenario scenario) {
        testContext.setScenarioName(scenario.getName());
        parallelUserAllocator.allocateForCurrentThread(testContext);
        LoggingContext.bind(scenario.getName(), testContext.getUserSlot());
        testContext.clearRandomStringCache();
        scenarioTestDataResolver.ensureUniqueLoanIdIfEnabled();

        UserRole role;
        if (scenario.getSourceTagNames().contains("@chief-admin")) {
            role = UserRole.CHIEF_ADMIN;
        } else if (scenario.getSourceTagNames().contains("@approver")) {
            role = UserRole.APPROVER;
        } else {
            role = UserRole.CREATOR;
        }

        logger.info("Scenario '{}' | thread '{}' | userSlot {} | role: {}",
                scenario.getName(), Thread.currentThread().getName(), testContext.getUserSlot(), role);
        authManager.initializeAuthentication(role);
    }

    @After
    public void tearDown() {
        dbClient.close();
        LoggingContext.clear();
        logger.info("Scenario teardown completed (user slot {})", testContext.getUserSlot());
    }
}

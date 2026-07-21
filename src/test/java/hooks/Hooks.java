package hooks;

import auth.manager.AuthManager;
import auth.allocator.ParallelUserAllocator;
import com.aventstack.extentreports.cucumber.adapter.ExtentCucumberAdapter;
import config.ConfigReader;
import context.ScenarioTestDataResolver;
import context.TestContext;
import enums.UserRole;

import java.util.Collection;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import helpers.LoggingHelper;
import utils.DbClient;
import utils.LoggingContext;

public class Hooks {

    private static final Logger logger = LogManager.getLogger(Hooks.class);

    private final TestContext testContext;
    private final AuthManager authManager;
    private final DbClient dbClient;
    private final ScenarioTestDataResolver scenarioTestDataResolver;
    private final ParallelUserAllocator parallelUserAllocator;
    private final ConfigReader configReader;

    public Hooks(
            TestContext testContext,
            AuthManager authManager,
            DbClient dbClient,
            ScenarioTestDataResolver scenarioTestDataResolver,
            ParallelUserAllocator parallelUserAllocator,
            ConfigReader configReader
    ) {
        this.testContext = testContext;
        this.authManager = authManager;
        this.dbClient = dbClient;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
        this.parallelUserAllocator = parallelUserAllocator;
        this.configReader = configReader;
    }

    @Before(order = 0)
    public void setUpScenario(Scenario scenario) {

        testContext.clearApiLogs();
        testContext.setScenarioName(scenario.getName());

        parallelUserAllocator.allocateForCurrentThread(testContext);


        Integer slotOverride = parseSlotTag(scenario.getSourceTagNames());
        if (slotOverride != null) {
            if (configReader.isParallelExecutionEnabled()) {
                logger.warn("@slot-{} tag set while parallel execution is enabled; this can collide "
                        + "with the allocator's per-thread slots. Honouring the tag anyway.", slotOverride);
            }
            testContext.setUserSlot(slotOverride);
            logger.info("@slot tag override: scenario '{}' will use credential slot {}",
                    scenario.getName(), slotOverride);
        }

        LoggingContext.bind(
                scenario.getName(),
                testContext.getUserSlot()
        );

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

        logger.info(
                "Scenario '{}' | thread '{}' | userSlot {} | role: {}",
                scenario.getName(),
                Thread.currentThread().getName(),
                testContext.getUserSlot(),
                role
        );

        testContext.setUserRole(role);
        authManager.initializeAuthentication(role);
    }


    private static Integer parseSlotTag(Collection<String> tags) {
        final String prefix = "@slot-";
        for (String tag : tags) {
            if (tag != null && tag.startsWith(prefix)) {
                String num = tag.substring(prefix.length()).trim();
                try {
                    return Integer.parseInt(num);
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException(
                            "Invalid slot tag '" + tag + "'. Expected @slot-<number>, e.g. @slot-2.");
                }
            }
        }
        return null;
    }

    @After
    public void tearDown(Scenario scenario) {

        try {

            if (scenario.isFailed()) {

                LoggingHelper.logScenarioFailure(scenario.getName());

                String apiLogs = testContext.getApiLogs();

                if (apiLogs != null && !apiLogs.isBlank()) {

                    // HTML-escape the logs before embedding in the Extent report. Request/response
                    // bodies can contain markup (e.g. XSS-injection test payloads or reflected HTML);
                    // rendering them raw makes the report itself execute that script when opened.
                    String safeApiLogs = escapeHtml(apiLogs);

                    ExtentCucumberAdapter.getCurrentStep().fail(
                            "<details>" +
                            "<summary><b>API Request / Response Logs</b></summary>" +
                            "<pre style='white-space: pre-wrap; font-family: monospace;'>" +
                            safeApiLogs +
                            "</pre>" +
                            "</details>"
                    );
                }
            }

            if (dbClient != null) {
                dbClient.close();
            }

            logger.info(
                    "Scenario teardown completed (user slot {})",
                    testContext.getUserSlot()
            );

        } finally {

            testContext.clearApiLogs();
            LoggingContext.clear();
        }
    }

    /**
     * Minimal HTML escaping so request/response content embedded in the Extent report renders as
     * literal text instead of executable markup (prevents stored-XSS in the report from test
     * payloads or reflected HTML). Order matters: escape {@code &} first.
     */
    private static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
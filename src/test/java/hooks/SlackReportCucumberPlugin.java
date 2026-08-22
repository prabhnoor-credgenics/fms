package hooks;

import helpers.SlackReporter;
import io.cucumber.plugin.ConcurrentEventListener;
import io.cucumber.plugin.event.EventPublisher;
import io.cucumber.plugin.event.TestRunFinished;
import io.cucumber.plugin.event.TestRunStarted;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.ReportSanitizer;

import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Cucumber plugin so Slack sharing works from the Cucumber test runner
 * (IDE feature-file run, {@code io.cucumber.core.cli.Main}, TestNG {@code @CucumberOptions}).
 */
public class SlackReportCucumberPlugin implements ConcurrentEventListener {

    private static final Logger logger = LogManager.getLogger(SlackReportCucumberPlugin.class);
    private static final AtomicBoolean HOOK_REGISTERED = new AtomicBoolean(false);

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestRunStarted.class, event -> registerShutdownHook());
        publisher.registerHandlerFor(TestRunFinished.class, this::onRunFinished);
        registerShutdownHook();
    }

    private void onRunFinished(TestRunFinished event) {
        logger.info("Cucumber run finished — sharing execution report to Slack if enabled");
        ReportSanitizer.sanitizeReportsUnder("TestReports");
        SlackReporter.publishLatestIfEnabled();
    }

    private static void registerShutdownHook() {
        if (!HOOK_REGISTERED.compareAndSet(false, true)) {
            return;
        }
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            ReportSanitizer.sanitizeReportsUnder("TestReports");
            SlackReporter.publishLatestIfEnabled();
        }, "slack-report-publisher"));
    }
}

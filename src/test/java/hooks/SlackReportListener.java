package hooks;

import helpers.SlackReporter;
import org.testng.IExecutionListener;
import org.testng.ISuite;
import org.testng.ISuiteListener;
import utils.ReportSanitizer;

/**
 * Shares the execution report to Slack after TestNG finishes — sequential, parallel
 * feature runner, and parallel Cucumber data-provider runner.
 */
public class SlackReportListener implements IExecutionListener, ISuiteListener {

    @Override
    public void onFinish(ISuite suite) {
        publishAfterSuite("suite:" + suite.getName());
    }

    @Override
    public void onExecutionFinish() {
        publishAfterSuite("execution");
        Runtime.getRuntime().addShutdownHook(new Thread(
                SlackReporter::publishLatestIfEnabled,
                "slack-report-publisher"
        ));
    }

    private void publishAfterSuite(String source) {
        ReportSanitizer.sanitizeReportsUnder("TestReports");
        SlackReporter.publishLatestIfEnabled();
    }
}

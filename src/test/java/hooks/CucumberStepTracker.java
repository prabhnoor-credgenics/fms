package hooks;

import io.cucumber.plugin.ConcurrentEventListener;
import io.cucumber.plugin.event.EventPublisher;
import io.cucumber.plugin.event.HookTestStep;
import io.cucumber.plugin.event.PickleStepTestStep;
import io.cucumber.plugin.event.Status;
import io.cucumber.plugin.event.TestStepFinished;
import io.cucumber.plugin.event.TestStepStarted;
import utils.LoggingContext;

public class CucumberStepTracker implements ConcurrentEventListener {

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestStepStarted.class, this::onStepStarted);
        publisher.registerHandlerFor(TestStepFinished.class, this::onStepFinished);
    }

    private void onStepStarted(TestStepStarted event) {
        LoggingContext.setCurrentStep(describeStep(event.getTestStep()));
    }

    private void onStepFinished(TestStepFinished event) {
        if (event.getResult().getStatus() == Status.FAILED) {
            LoggingContext.recordFailure(
                    describeStep(event.getTestStep()),
                    event.getResult().getError()
            );
        }
    }

    private static String describeStep(io.cucumber.plugin.event.TestStep testStep) {
        if (testStep instanceof PickleStepTestStep pickleStep) {
            return pickleStep.getStep().getKeyword() + " " + pickleStep.getStep().getText();
        }
        if (testStep instanceof HookTestStep hookStep) {
            return hookStep.getHookType().name() + " hook";
        }
        return testStep.getClass().getSimpleName();
    }
}

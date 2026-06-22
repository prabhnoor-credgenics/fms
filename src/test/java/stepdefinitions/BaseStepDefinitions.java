package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.restassured.response.Response;

/**
 * Shared base for the per-feature step-definition classes.
 *
 * <p>Holds the injected {@link TestContext} and the {@link #activeResponse()}
 * lookup that every thin validator step-def previously redeclared verbatim.
 * Cucumber's PicoContainer factory instantiates the concrete subclasses (which
 * keep their own constructors and pass {@code testContext} up via {@code super});
 * this abstract class carries no step annotations, so it is never treated as glue.
 */
public abstract class BaseStepDefinitions {

    protected final TestContext testContext;

    protected BaseStepDefinitions(TestContext testContext) {
        this.testContext = testContext;
    }

    protected Response activeResponse() {
        return ResponseHelper.resolve(null, testContext);
    }
}

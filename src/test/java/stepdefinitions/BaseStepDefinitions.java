package stepdefinitions;

import context.TestContext;
import helpers.ResponseHelper;
import io.restassured.response.Response;

public abstract class BaseStepDefinitions {

    protected final TestContext testContext;

    protected BaseStepDefinitions(TestContext testContext) {
        this.testContext = testContext;
    }

    protected Response activeResponse() {

        return ResponseHelper.resolve(null, testContext);
    }
}

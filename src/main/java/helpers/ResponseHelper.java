package helpers;

import context.TestContext;
import io.restassured.response.Response;

/**
 * Resolves the active API response from step-local state or {@link TestContext}.
 */
public final class ResponseHelper {

    private ResponseHelper() {
        throw new UnsupportedOperationException("Utility class");
    }

    /**
     * Prefers the step-local response; falls back to {@link TestContext#getResponse()}.
     */
    public static Response resolve(Response localResponse, TestContext testContext) {
        if (localResponse != null) {
            return localResponse;
        }
        if (testContext == null) {
            throw new IllegalStateException("TestContext must not be null");
        }
        Response fromContext = testContext.getResponse();
        if (fromContext == null) {
            throw new IllegalStateException(
                    "No API response available. Send a request or run a service step first."
            );
        }
        return fromContext;
    }
}

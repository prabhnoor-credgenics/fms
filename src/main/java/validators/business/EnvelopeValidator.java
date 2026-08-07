package validators.business;

import io.restassured.response.Response;

public interface EnvelopeValidator {

    default void validateSuccessEnvelope(Response response) {
        throw new UnsupportedOperationException(
                getClass().getSimpleName() + " has no success-envelope validator");
    }

    default void validateFailureEnvelope(Response response) {
        throw new UnsupportedOperationException(
                getClass().getSimpleName() + " has no failure-envelope validator");
    }
}

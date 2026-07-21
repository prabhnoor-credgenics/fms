package validators.business;

import io.restassured.response.Response;

/**
 * Common type for the per-feature response-envelope validators so a single generic step
 * ({@code the "<key>" success/failure response should be valid}) can dispatch to any of them,
 * replacing the ~80 near-identical per-feature "the &lt;feature&gt; success/failure response should be
 * valid" step methods that previously each wrapped one validator.
 *
 * <p>Both methods are {@code default} throwers so a validator that only supports one direction
 * (success-only or failure-only) still satisfies the interface; the concrete method it declares
 * (or inherits from {@link BaseEnvelopeValidator#validateFailureEnvelope}) overrides the default.
 */
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

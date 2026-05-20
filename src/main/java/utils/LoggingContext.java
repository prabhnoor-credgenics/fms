package utils;

import org.apache.logging.log4j.ThreadContext;


public final class LoggingContext {

    public static final String SCENARIO_NAME = "scenarioName";
    public static final String THREAD_NAME = "threadName";
    public static final String USER_SLOT = "userSlot";

    private static final ThreadLocal<String> CURRENT_STEP = new ThreadLocal<>();
    private static final ThreadLocal<String> FAILED_STEP = new ThreadLocal<>();
    private static final ThreadLocal<Throwable> LAST_FAILURE = new ThreadLocal<>();

    private LoggingContext() {}

    public static void bind(String scenarioName, int userSlot) {
        ThreadContext.put(SCENARIO_NAME, scenarioName == null ? "unknown" : scenarioName);
        ThreadContext.put(THREAD_NAME, Thread.currentThread().getName());
        ThreadContext.put(USER_SLOT, String.valueOf(userSlot));
    }

    public static void clear() {
        ThreadContext.remove(SCENARIO_NAME);
        ThreadContext.remove(THREAD_NAME);
        ThreadContext.remove(USER_SLOT);
        CURRENT_STEP.remove();
        FAILED_STEP.remove();
        LAST_FAILURE.remove();
    }

    public static void setCurrentStep(String stepText) {
        if (stepText == null || stepText.isBlank()) {
            CURRENT_STEP.remove();
        } else {
            CURRENT_STEP.set(stepText);
        }
    }

    public static String getCurrentStep() {
        return CURRENT_STEP.get();
    }

    public static void recordFailure(String stepText, Throwable error) {
        if (stepText != null && !stepText.isBlank()) {
            FAILED_STEP.set(stepText);
        }
        if (error != null) {
            LAST_FAILURE.set(error);
        }
    }

    public static String getFailedStep() {
        String failed = FAILED_STEP.get();
        return failed != null ? failed : CURRENT_STEP.get();
    }

    public static Throwable getLastFailure() {
        return LAST_FAILURE.get();
    }
}

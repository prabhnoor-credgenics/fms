package utils;

import org.apache.logging.log4j.ThreadContext;


public final class LoggingContext {

    public static final String SCENARIO_NAME = "scenarioName";
    public static final String THREAD_NAME = "threadName";
    public static final String USER_SLOT = "userSlot";

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
    }
}

package auth.allocator;

import config.ConfigReader;
import context.TestContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class ParallelUserAllocator {

    private static final Logger logger = LogManager.getLogger(ParallelUserAllocator.class);

    private static final ConcurrentHashMap<Long, Integer> THREAD_TO_SLOT = new ConcurrentHashMap<>();

    // Hands out strictly increasing, unique slot numbers. Using an atomic counter (instead of
    // THREAD_TO_SLOT.size()) avoids a race where two threads computing slots concurrently for
    // different keys both read the same size() and get assigned the SAME slot -> two threads
    // would then share one credential, causing the server to invalidate a session.
    private static final AtomicInteger NEXT_SLOT = new AtomicInteger(0);

    private final ConfigReader configReader;

    public ParallelUserAllocator(ConfigReader configReader) {
        this.configReader = configReader;
    }


    public void allocateForCurrentThread(TestContext testContext) {
        if (configReader.isSingleUserMode()) {
            testContext.setUserSlot(0);
            logger.info("Thread '{}' using shared single-user slot (single-user mode)",
                    Thread.currentThread().getName());
            return;
        }
        int poolSize = configReader.getParallelUserPoolSize();
        int slot = resolveSlotForCurrentThread(poolSize);
        testContext.setUserSlot(slot);
        logger.info("Thread '{}' assigned parallel user slot {} of {}",
                Thread.currentThread().getName(), slot, poolSize);
    }

    public int resolveSlotForCurrentThread(int poolSize) {
        if (poolSize <= 1) {
            return 0;
        }
        long threadId = Thread.currentThread().threadId();
        return THREAD_TO_SLOT.computeIfAbsent(threadId, id -> {
            int slot = NEXT_SLOT.getAndIncrement();
            if (slot >= poolSize) {
                // Roll back so the counter and the error message stay consistent if more
                // over-capacity threads arrive.
                NEXT_SLOT.decrementAndGet();
                throw new IllegalStateException(
                        "Cannot assign a unique user slot: more than " + poolSize
                                + " worker threads are active but parallel.user.pool.size=" + poolSize + ". "
                                + "Add more user credentials (stag.user.N.email) and increase "
                                + "parallel.user.pool.size and testng thread-count together."
                );
            }
            logger.debug("Mapped thread id {} to user slot {}", id, slot);
            return slot;
        });
    }


    public static void reset() {
        THREAD_TO_SLOT.clear();
        NEXT_SLOT.set(0);
    }
}

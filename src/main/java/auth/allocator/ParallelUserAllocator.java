package auth.allocator;

import config.ConfigReader;
import context.TestContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.concurrent.ConcurrentHashMap;

public class ParallelUserAllocator {

    private static final Logger logger = LogManager.getLogger(ParallelUserAllocator.class);

    private static final ConcurrentHashMap<Long, Integer> THREAD_TO_SLOT = new ConcurrentHashMap<>();

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
            if (THREAD_TO_SLOT.size() >= poolSize) {
                throw new IllegalStateException(
                        "Cannot assign a unique user slot: " + (THREAD_TO_SLOT.size() + 1)
                                + " worker threads are active but parallel.user.pool.size=" + poolSize + ". "
                                + "Add more user credentials (stag.user.N.email) and increase "
                                + "parallel.user.pool.size and testng thread-count together."
                );
            }
            int slot = THREAD_TO_SLOT.size();
            logger.debug("Mapped thread id {} to user slot {}", id, slot);
            return slot;
        });
    }


    public static void reset() {
        THREAD_TO_SLOT.clear();
    }
}

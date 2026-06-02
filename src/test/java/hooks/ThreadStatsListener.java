package hooks;

import com.aventstack.extentreports.service.ExtentService;
import io.cucumber.plugin.ConcurrentEventListener;
import io.cucumber.plugin.event.EventPublisher;
import io.cucumber.plugin.event.PickleStepTestStep;
import io.cucumber.plugin.event.TestCaseStarted;
import io.cucumber.plugin.event.TestRunFinished;
import io.cucumber.plugin.event.TestStepFinished;
import java.util.Comparator;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class ThreadStatsListener implements ConcurrentEventListener {

    private static final ConcurrentHashMap<String, ThreadStats> STATS = new ConcurrentHashMap<>();

    private static class ThreadStats {
        final long threadId;
        final Set<String> features = ConcurrentHashMap.newKeySet();
        final AtomicInteger scenarios = new AtomicInteger(0);
        final AtomicInteger steps = new AtomicInteger(0);

        ThreadStats(long threadId) {
            this.threadId = threadId;
        }
    }

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestCaseStarted.class, this::onScenarioStarted);
        publisher.registerHandlerFor(TestStepFinished.class, this::onStepFinished);
        publisher.registerHandlerFor(TestRunFinished.class, this::onRunFinished);
    }

    private ThreadStats statsForCurrentThread() {
        Thread t = Thread.currentThread();
        return STATS.computeIfAbsent(t.getName(), k -> new ThreadStats(t.getId()));
    }

    private void onScenarioStarted(TestCaseStarted event) {
        ThreadStats stats = statsForCurrentThread();
        stats.scenarios.incrementAndGet();
        String uri = event.getTestCase().getUri().toString();
        String featureName = uri.substring(uri.lastIndexOf('/') + 1);
        stats.features.add(featureName);
    }

    private void onStepFinished(TestStepFinished event) {
        if (event.getTestStep() instanceof PickleStepTestStep) {
            statsForCurrentThread().steps.incrementAndGet();
        }
    }

    private void onRunFinished(TestRunFinished event) {
        if (STATS.isEmpty()) {
            return;
        }

        int totalScenarios = STATS.values().stream().mapToInt(s -> s.scenarios.get()).sum();
        int totalSteps = STATS.values().stream().mapToInt(s -> s.steps.get()).sum();
        int totalFeatures = (int) STATS.values().stream()
                .flatMap(s -> s.features.stream()).distinct().count();

        StringBuilder sb = new StringBuilder();
        sb.append("\n╔══════════════════════════════════════════════════════════╗\n");
        sb.append(  "║           PARALLEL EXECUTION SUMMARY                     ║\n");
        sb.append(  "╚══════════════════════════════════════════════════════════╝\n");
        sb.append(String.format("  Threads active : %d%n", STATS.size()));
        sb.append(String.format("  Total features : %d%n", totalFeatures));
        sb.append(String.format("  Total scenarios: %d%n", totalScenarios));
        sb.append(String.format("  Total steps    : %d%n", totalSteps));
        sb.append("  ─────────────────────────────────────────────────────────\n");

        STATS.entrySet().stream()
                .sorted(Comparator.comparing(Map.Entry::getKey))
                .forEach(entry -> {
                    String threadName = entry.getKey();
                    ThreadStats stats = entry.getValue();
                    sb.append(String.format("  [%s] (id:%d)%n", threadName, stats.threadId));
                    sb.append(String.format("      Features : %d%n", stats.features.size()));
                    sb.append(String.format("      Scenarios: %d%n", stats.scenarios.get()));
                    sb.append(String.format("      Steps    : %d%n", stats.steps.get()));
                    stats.features.stream().sorted()
                            .forEach(f -> sb.append(String.format("        - %s%n", f)));
                });

        sb.append("  ─────────────────────────────────────────────────────────");
        System.err.println(sb.toString());

        publishToExtentReport(totalFeatures, totalScenarios, totalSteps);

        STATS.clear();
    }

    private void publishToExtentReport(int totalFeatures, int totalScenarios, int totalSteps) {
        try {
            ExtentService.getInstance().setSystemInfo("Threads Active", String.valueOf(STATS.size()));
            ExtentService.getInstance().setSystemInfo("Total Features", String.valueOf(totalFeatures));
            ExtentService.getInstance().setSystemInfo("Total Scenarios", String.valueOf(totalScenarios));
            ExtentService.getInstance().setSystemInfo("Total Steps", String.valueOf(totalSteps));

            STATS.entrySet().stream()
                    .sorted(Comparator.comparing(Map.Entry::getKey))
                    .forEach(entry -> {
                        String threadName = entry.getKey();
                        ThreadStats stats = entry.getValue();
                        String featureList = String.join(", ", stats.features.stream().sorted().toList());
                        String value = String.format(
                                "id:%d | Features:%d | Scenarios:%d | Steps:%d | %s",
                                stats.threadId,
                                stats.features.size(),
                                stats.scenarios.get(),
                                stats.steps.get(),
                                featureList
                        );
                        ExtentService.getInstance().setSystemInfo(threadName, value);
                    });
        } catch (Exception ignored) {
        }
    }
}

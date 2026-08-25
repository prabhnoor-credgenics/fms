package utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.net.InetAddress;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Builds a local-run summary from Cucumber JSON + the latest Extent HTML report.
 */
public final class ExecutionReportSummary {

    private static final Logger logger = LogManager.getLogger(ExecutionReportSummary.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();

    public static final String REPORT_BASE_DIR = "TestReports";
    public static final String CUCUMBER_JSON = "target/cucumber-reports/cucumber.json";
    public static final String EXTENT_FILE_NAME = "ExtentReport.html";

    private ExecutionReportSummary() {
        throw new UnsupportedOperationException("Utility class");
    }

    public record Result(
            int passed,
            int failed,
            int skipped,
            int pending,
            long durationNanos,
            List<String> failedScenarios,
            Path extentReport,
            Path cucumberJson
    ) {
        public int total() {
            return passed + failed + skipped + pending;
        }

        public boolean hasFailures() {
            return failed > 0;
        }
    }

    public static Result collect() {
        Path json = Path.of(CUCUMBER_JSON);
        int passed = 0;
        int failed = 0;
        int skipped = 0;
        int pending = 0;
        long duration = 0L;
        List<String> failedNames = new ArrayList<>();

        if (Files.isRegularFile(json)) {
            try {
                JsonNode root = MAPPER.readTree(json.toFile());
                if (root != null && root.isArray()) {
                    for (JsonNode feature : root) {
                        JsonNode elements = feature.path("elements");
                        if (!elements.isArray()) {
                            continue;
                        }
                        String featureName = feature.path("name").asText("unknown feature");
                        for (JsonNode element : elements) {
                            String type = element.path("type").asText("");
                            if ("background".equalsIgnoreCase(type)) {
                                continue;
                            }
                            ScenarioOutcome outcome = outcomeOf(element);
                            duration += outcome.durationNanos;
                            switch (outcome.status) {
                                case "passed" -> passed++;
                                case "failed" -> {
                                    failed++;
                                    failedNames.add(featureName + " › " + element.path("name").asText("unnamed"));
                                }
                                case "skipped" -> skipped++;
                                default -> pending++;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                logger.warn("Could not parse Cucumber JSON '{}': {}", json, e.getMessage());
            }
        } else {
            logger.info("Cucumber JSON not found at '{}' — Slack summary will omit scenario counts", json);
        }

        return new Result(
                passed,
                failed,
                skipped,
                pending,
                duration,
                List.copyOf(failedNames),
                latestExtentReport().orElse(null),
                Files.isRegularFile(json) ? json : null
        );
    }

    public static Optional<Path> latestExtentReport() {
        Path base = Path.of(REPORT_BASE_DIR);
        if (!Files.isDirectory(base)) {
            return Optional.empty();
        }
        try (Stream<Path> stream = Files.walk(base)) {
            return stream
                    .filter(Files::isRegularFile)
                    .filter(p -> EXTENT_FILE_NAME.equalsIgnoreCase(p.getFileName().toString()))
                    .max(Comparator.comparingLong(p -> p.toFile().lastModified()));
        } catch (IOException e) {
            logger.warn("Could not scan '{}' for Extent report: {}", base, e.getMessage());
            return Optional.empty();
        }
    }

    public static Optional<Path> waitForExtentReport(Duration timeout) {
        long deadline = System.currentTimeMillis() + Math.max(0, timeout.toMillis());
        Optional<Path> found = latestExtentReport();
        while (found.isEmpty() && System.currentTimeMillis() < deadline) {
            try {
                Thread.sleep(400);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return Optional.empty();
            }
            found = latestExtentReport();
        }
        return found;
    }

    public static String hostName() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (Exception e) {
            return "unknown-host";
        }
    }

    public static String userName() {
        return System.getProperty("user.name", "unknown");
    }

    public static String formatDuration(long nanos) {
        if (nanos <= 0) {
            return "n/a";
        }
        long seconds = nanos / 1_000_000_000L;
        long minutes = seconds / 60;
        long rem = seconds % 60;
        if (minutes > 0) {
            return minutes + "m " + rem + "s";
        }
        return rem + "s";
    }

    private record ScenarioOutcome(String status, long durationNanos) {
    }

    private static ScenarioOutcome outcomeOf(JsonNode element) {
        String worst = "passed";
        long duration = 0L;
        JsonNode steps = element.path("steps");
        if (steps.isArray()) {
            for (JsonNode step : steps) {
                JsonNode result = step.path("result");
                duration += result.path("duration").asLong(0L);
                String status = result.path("status").asText("passed").toLowerCase(Locale.ROOT);
                worst = worse(worst, status);
            }
        }
        JsonNode after = element.path("after");
        if (after.isArray()) {
            for (JsonNode hook : after) {
                String status = hook.path("result").path("status").asText("passed").toLowerCase(Locale.ROOT);
                worst = worse(worst, status);
            }
        }
        return new ScenarioOutcome(worst, duration);
    }

    private static String worse(String current, String next) {
        int a = rank(current);
        int b = rank(next);
        return b > a ? next : current;
    }

    private static int rank(String status) {
        return switch (status) {
            case "failed" -> 4;
            case "pending", "undefined", "ambiguous" -> 3;
            case "skipped" -> 2;
            default -> 1;
        };
    }

    public static String failedPreview(List<String> failedScenarios, int max) {
        if (failedScenarios == null || failedScenarios.isEmpty()) {
            return "";
        }
        return failedScenarios.stream()
                .limit(max)
                .map(name -> "• " + name)
                .collect(Collectors.joining("\n"));
    }
}

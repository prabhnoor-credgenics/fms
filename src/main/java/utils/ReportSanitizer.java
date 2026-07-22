package utils;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Post-processes the generated ExtentReports HTML to neutralise any HTML/JS that originated from
 * test content (Gherkin data-table cells and docstrings/code blocks).
 *
 * <p>The ExtentReports Cucumber adapter renders test-provided content as <b>raw HTML</b> inside the
 * static report file. Data-table cells land in {@code <table class='markup-table'>} cells and
 * docstrings/bodies land in {@code <textarea class='code-block'>} — both live in the static markup,
 * so an injected {@code <script>} or {@code <img onerror=...>} (e.g. an XSS negative-test payload or
 * a reflected API response) would execute when the report is opened. There is no escape switch in the
 * adapter, so we escape those regions after the report is written.
 *
 * <p>Only the inner content of those two test-content regions is escaped ({@code <} / {@code >} →
 * entities). The report template's own scripts, styles and structure are left untouched, so the
 * report still renders and its charts still work.
 */
public final class ReportSanitizer {

    private static final Logger LOGGER = LogManager.getLogger(ReportSanitizer.class);

    // Gherkin data tables — the adapter renders these as <table class='markup-table ...'>. Only
    // cells inside such a table hold test content; the report's own tables are left untouched.
    private static final Pattern MARKUP_TABLE =
            Pattern.compile("(<table[^>]*class='[^']*markup-table[^']*'[^>]*>)(.*?)(</table>)",
                    Pattern.DOTALL | Pattern.CASE_INSENSITIVE);
    // Individual cells within a markup-table.
    private static final Pattern CELL =
            Pattern.compile("(<t[dh][^>]*>)(.*?)(</t[dh]>)", Pattern.DOTALL | Pattern.CASE_INSENSITIVE);
    // Docstring / request-body code blocks — the adapter renders these as <textarea class='code-block'>.
    private static final Pattern CODE_BLOCK =
            Pattern.compile("(<textarea[^>]*class='[^']*code-block[^']*'[^>]*>)(.*?)(</textarea>)",
                    Pattern.DOTALL | Pattern.CASE_INSENSITIVE);

    private ReportSanitizer() {
    }

    /**
     * Finds the most recent Spark.html and ExtentReport.html under {@code baseDir} (recursively) and
     * sanitises them. Never throws — report post-processing must not fail the test run.
     */
    public static void sanitizeReportsUnder(String baseDir) {
        try {
            Path base = Path.of(baseDir);
            if (!Files.isDirectory(base)) {
                return;
            }
            for (String name : new String[]{"Spark.html", "ExtentReport.html"}) {
                latest(base, name).ifPresent(ReportSanitizer::sanitize);
            }
        } catch (Exception e) {
            LOGGER.warn("Report sanitisation skipped for '{}': {}", baseDir, e.toString());
        }
    }

    private static java.util.Optional<Path> latest(Path base, String fileName) throws IOException {
        try (var stream = Files.walk(base)) {
            List<Path> matches = stream
                    .filter(Files::isRegularFile)
                    .filter(p -> p.getFileName().toString().equals(fileName))
                    .collect(Collectors.toList());
            return matches.stream().max(Comparator.comparingLong(p -> p.toFile().lastModified()));
        }
    }

    /** Sanitises a single report file in place. */
    public static void sanitize(Path htmlFile) {
        if (htmlFile == null || !Files.isRegularFile(htmlFile)) {
            return;
        }
        try {
            String html = Files.readString(htmlFile, StandardCharsets.UTF_8);
            // Escape code-block docstrings, and escape cells only within Gherkin markup-tables.
            String out = escapeRegions(html, CODE_BLOCK);
            out = escapeMarkupTableCells(out);
            if (!out.equals(html)) {
                Files.writeString(htmlFile, out, StandardCharsets.UTF_8);
                LOGGER.info("Sanitised test-content markup in report: {}", htmlFile);
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Failed to sanitise report " + htmlFile, e);
        }
    }

    private static String escapeRegions(String html, Pattern region) {
        Matcher m = region.matcher(html);
        StringBuilder sb = new StringBuilder();
        while (m.find()) {
            String replacement = m.group(1) + escapeAngles(m.group(2)) + m.group(3);
            m.appendReplacement(sb, Matcher.quoteReplacement(replacement));
        }
        m.appendTail(sb);
        return sb.toString();
    }

    /** Escapes {@code <td>}/{@code <th>} contents, but only inside Gherkin {@code markup-table}s. */
    private static String escapeMarkupTableCells(String html) {
        Matcher table = MARKUP_TABLE.matcher(html);
        StringBuilder sb = new StringBuilder();
        while (table.find()) {
            String escapedTable = table.group(1) + escapeRegions(table.group(2), CELL) + table.group(3);
            table.appendReplacement(sb, Matcher.quoteReplacement(escapedTable));
        }
        table.appendTail(sb);
        return sb.toString();
    }

    /**
     * Escapes only {@code <} and {@code >} (enough to stop any tag being parsed/executed). {@code &}
     * is intentionally left alone so already-escaped entities are not double-escaped.
     */
    private static String escapeAngles(String value) {
        return value.replace("<", "&lt;").replace(">", "&gt;");
    }
}

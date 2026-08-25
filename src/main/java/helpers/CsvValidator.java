package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.Assert;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;


public class CsvValidator {

    private static final Logger logger = LogManager.getLogger(CsvValidator.class);

    private List<String> headers;
    private List<List<String>> dataRows;
    private String loadedFilePath;

    public void load(String filePath) {
        File file = FileHelper.resolveTestFile(filePath);
        loadDownloaded(file);
    }

    public void loadDownloaded(File file) {
        if (file == null || !file.isFile()) {
            throw new IllegalArgumentException("Downloaded CSV file is missing: " + file);
        }
        closeQuietly();
        try {
            parseFile(file);
            loadedFilePath = file.getPath();
            logger.info(
                    "Loaded CSV '{}' ({} columns, {} data rows)",
                    loadedFilePath,
                    headers.size(),
                    dataRows.size()
            );
        } catch (IOException e) {
            throw new IllegalStateException("Failed to open CSV file: " + file.getPath(), e);
        }
    }

    public String getLoadedFilePath() {
        return loadedFilePath;
    }

    public void validateCellValue(
            String referenceColumn,
            String referenceValue,
            String targetColumn,
            String expectedValue
    ) {
        requireLoaded();

        int referenceColumnIndex = getColumnIndex(referenceColumn);
        int targetColumnIndex = getColumnIndex(targetColumn);
        String expected = expectedValue == null ? "" : expectedValue.trim();
        String reference = referenceValue == null ? "" : referenceValue.trim();

        for (int rowIndex = 0; rowIndex < dataRows.size(); rowIndex++) {
            List<String> row = dataRows.get(rowIndex);
            String actualReferenceValue = cellAt(row, referenceColumnIndex);
            if (actualReferenceValue.equals(reference)) {
                String actualTargetValue = cellAt(row, targetColumnIndex);
                Assert.assertEquals(
                        actualTargetValue,
                        expected,
                        "CSV validation failed. "
                                + "Reference Column: " + referenceColumn
                                + ", Reference Value: " + referenceValue
                                + ", Target Column: " + targetColumn
                                + ", Expected: " + expectedValue
                                + ", Actual: " + actualTargetValue
                                + ", Row: " + (rowIndex + 2)
                                + ", File: " + loadedFilePath
                );
                logger.info(
                        "CSV validation passed: where {}='{}' has {}='{}' (row {})",
                        referenceColumn, referenceValue, targetColumn, expectedValue, rowIndex + 2
                );
                return;
            }
        }

        Assert.fail(
                "No row found where '" + referenceColumn + "' = '" + referenceValue
                        + "' in CSV file: " + loadedFilePath
        );
    }

    /**
     * Asserts every data row has a blank/empty value in {@code columnName}.
     */
    public void validateColumnBlankInAllRows(String columnName) {
        requireLoaded();
        int columnIndex = getColumnIndex(columnName);
        List<String> failures = new ArrayList<>();
        for (int rowIndex = 0; rowIndex < dataRows.size(); rowIndex++) {
            String actual = cellAt(dataRows.get(rowIndex), columnIndex);
            if (!actual.isBlank()) {
                failures.add("row " + (rowIndex + 2) + "='" + actual + "'");
            }
        }
        if (!failures.isEmpty()) {
            Assert.fail(
                    "Expected CSV column '" + columnName + "' to be blank in all rows but found values: "
                            + String.join(", ", failures) + ". File: " + loadedFilePath
            );
        }
        logger.info(
                "CSV column '{}' is blank in all {} data row(s) ({})",
                columnName,
                dataRows.size(),
                loadedFilePath
        );
    }

    public void closeQuietly() {
        headers = null;
        dataRows = null;
        loadedFilePath = null;
    }

    private void parseFile(File file) throws IOException {
        Charset charset = detectCharset(file);
        List<String> lines = new ArrayList<>();
        try (BufferedReader reader = Files.newBufferedReader(file.toPath(), charset)) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.isBlank()) {
                    lines.add(stripBom(line));
                }
            }
        }
        if (lines.isEmpty()) {
            throw new IllegalStateException("CSV file is empty: " + file.getPath());
        }

        headers = parseLine(lines.get(0));
        if (headers.isEmpty()) {
            throw new IllegalStateException("CSV header row is empty: " + file.getPath());
        }
        for (int i = 0; i < headers.size(); i++) {
            headers.set(i, headers.get(i).trim());
        }

        dataRows = new ArrayList<>();
        for (int i = 1; i < lines.size(); i++) {
            dataRows.add(parseLine(lines.get(i)));
        }
    }

    private int getColumnIndex(String columnName) {
        requireLoaded();
        if (columnName == null || columnName.isBlank()) {
            Assert.fail("Column name must not be blank");
        }
        String wanted = columnName.trim();
        for (int i = 0; i < headers.size(); i++) {
            if (headers.get(i).equalsIgnoreCase(wanted)) {
                return i;
            }
        }
        Assert.fail("Column '" + columnName + "' not found in CSV file: " + loadedFilePath);
        return -1;
    }

    private static String cellAt(List<String> row, int index) {
        if (index < 0 || index >= row.size()) {
            return "";
        }
        String value = row.get(index);
        return value == null ? "" : value.trim();
    }

    private void requireLoaded() {
        if (headers == null || dataRows == null) {
            throw new IllegalStateException(
                    "No CSV file loaded. Use 'I load csv from \"...\"' or download a CSV file first.");
        }
    }

    private static Charset detectCharset(File file) throws IOException {
        byte[] prefix = Files.readAllBytes(file.toPath());
        if (prefix.length >= 3
                && (prefix[0] & 0xFF) == 0xEF
                && (prefix[1] & 0xFF) == 0xBB
                && (prefix[2] & 0xFF) == 0xBF) {
            return StandardCharsets.UTF_8;
        }
        return StandardCharsets.UTF_8;
    }

    private static String stripBom(String line) {
        if (line != null && !line.isEmpty() && line.charAt(0) == '\uFEFF') {
            return line.substring(1);
        }
        return line;
    }


    static List<String> parseLine(String line) {
        List<String> fields = new ArrayList<>();
        if (line == null) {
            return fields;
        }
        StringBuilder current = new StringBuilder();
        boolean inQuotes = false;
        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (inQuotes) {
                if (c == '"') {
                    if (i + 1 < line.length() && line.charAt(i + 1) == '"') {
                        current.append('"');
                        i++;
                    } else {
                        inQuotes = false;
                    }
                } else {
                    current.append(c);
                }
            } else if (c == '"') {
                inQuotes = true;
            } else if (c == ',') {
                fields.add(current.toString());
                current.setLength(0);
            } else {
                current.append(c);
            }
        }
        fields.add(current.toString());
        return fields;
    }
}

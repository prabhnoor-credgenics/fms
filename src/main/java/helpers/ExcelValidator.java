package helpers;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.testng.Assert;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/**
 * Loads an Excel workbook and validates cells using:
 * Reference column → Reference value → Target column → Expected value
 */
public class ExcelValidator {

    private static final Logger logger = LogManager.getLogger(ExcelValidator.class);
    private static final DataFormatter FORMATTER = new DataFormatter();

    private Workbook workbook;
    private Sheet sheet;
    private String loadedFilePath;

    public void load(String filePath) {
        closeQuietly();
        File file = FileHelper.resolveTestFile(filePath);
        try (InputStream in = new FileInputStream(file)) {
            workbook = WorkbookFactory.create(in);
            sheet = workbook.getNumberOfSheets() > 0 ? workbook.getSheetAt(0) : null;
            if (sheet == null) {
                throw new IllegalStateException("Excel file has no sheets: " + file.getPath());
            }
            loadedFilePath = file.getPath();
            logger.info("Loaded Excel '{}' (sheet='{}')", loadedFilePath, sheet.getSheetName());
        } catch (IOException e) {
            throw new IllegalStateException("Failed to open Excel file: " + file.getPath(), e);
        }
    }

    public void loadDownloaded(File file) {
        if (file == null || !file.isFile()) {
            throw new IllegalArgumentException("Downloaded Excel file is missing: " + file);
        }
        closeQuietly();
        try (InputStream in = new FileInputStream(file)) {
            workbook = WorkbookFactory.create(in);
            sheet = workbook.getNumberOfSheets() > 0 ? workbook.getSheetAt(0) : null;
            if (sheet == null) {
                throw new IllegalStateException("Excel file has no sheets: " + file.getPath());
            }
            loadedFilePath = file.getPath();
            logger.info("Loaded downloaded Excel '{}' (sheet='{}')", loadedFilePath, sheet.getSheetName());
        } catch (IOException e) {
            throw new IllegalStateException("Failed to open downloaded Excel file: " + file.getPath(), e);
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
        requireSheetLoaded();

        int referenceColumnIndex = getColumnIndex(referenceColumn);
        int targetColumnIndex = getColumnIndex(targetColumn);
        String expected = expectedValue == null ? "" : expectedValue.trim();
        String reference = referenceValue == null ? "" : referenceValue.trim();

        for (int rowIndex = 1; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
            Row row = sheet.getRow(rowIndex);
            if (row == null) {
                continue;
            }

            String actualReferenceValue = getCellValue(row.getCell(referenceColumnIndex));
            if (actualReferenceValue.equals(reference)) {
                String actualTargetValue = getCellValue(row.getCell(targetColumnIndex));
                Assert.assertEquals(
                        actualTargetValue,
                        expected,
                        "Excel validation failed. "
                                + "Reference Column: " + referenceColumn
                                + ", Reference Value: " + referenceValue
                                + ", Target Column: " + targetColumn
                                + ", Expected: " + expectedValue
                                + ", Actual: " + actualTargetValue
                                + ", Row: " + (rowIndex + 1)
                                + ", File: " + loadedFilePath
                );
                logger.info(
                        "Excel validation passed: where {}='{}' has {}='{}' (row {})",
                        referenceColumn, referenceValue, targetColumn, expectedValue, rowIndex + 1
                );
                return;
            }
        }

        Assert.fail(
                "No row found where '" + referenceColumn + "' = '" + referenceValue
                        + "' in Excel file: " + loadedFilePath
        );
    }

    private int getColumnIndex(String columnName) {
        requireSheetLoaded();
        if (columnName == null || columnName.isBlank()) {
            Assert.fail("Column name must not be blank");
        }

        Row headerRow = sheet.getRow(0);
        if (headerRow == null) {
            Assert.fail("Excel header row (row 1) is missing in file: " + loadedFilePath);
        }

        for (Cell cell : headerRow) {
            String header = getCellValue(cell);
            if (header.equalsIgnoreCase(columnName.trim())) {
                return cell.getColumnIndex();
            }
        }

        Assert.fail("Column '" + columnName + "' not found in Excel file: " + loadedFilePath);
        return -1;
    }

    private String getCellValue(Cell cell) {
        if (cell == null) {
            return "";
        }
        return FORMATTER.formatCellValue(cell).trim();
    }

    private void requireSheetLoaded() {
        if (sheet == null) {
            throw new IllegalStateException(
                    "No Excel file loaded. Use 'I load excel from \"...\"' or download an Excel file first.");
        }
    }

    public void closeQuietly() {
        if (workbook != null) {
            try {
                workbook.close();
            } catch (IOException e) {
                logger.warn("Failed to close Excel workbook '{}': {}", loadedFilePath, e.getMessage());
            }
        }
        workbook = null;
        sheet = null;
        loadedFilePath = null;
    }

    public static File downloadToFile(String absoluteUrl, Path destination) {
        if (absoluteUrl == null || absoluteUrl.isBlank()) {
            throw new IllegalArgumentException("Download URL must not be blank");
        }
        String url = absoluteUrl.trim();
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            throw new IllegalArgumentException("Download URL must start with http:// or https://. Got: " + url);
        }
        try {
            Files.createDirectories(destination.getParent());
            try (InputStream in = java.net.URI.create(url).toURL().openStream()) {
                Files.copy(in, destination, StandardCopyOption.REPLACE_EXISTING);
            }
            File file = destination.toFile();
            logger.info("Downloaded file from absolute URL to '{}' ({} bytes)", file.getPath(), file.length());
            return file;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to download file from absolute URL: " + url, e);
        }
    }
}

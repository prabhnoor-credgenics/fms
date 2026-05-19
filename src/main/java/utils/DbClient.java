package utils;

import config.ConfigReader;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DbClient {

    private final ConfigReader configReader;
    private Connection connection;

    public DbClient(ConfigReader configReader) {
        this.configReader = configReader;
    }

    public Connection getConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                connection = DriverManager.getConnection(
                        configReader.getDbUrl(),
                        configReader.getDbUsername(),
                        configReader.getDbPassword()
                );
            }
            return connection;
        } catch (SQLException e) {
            throw new RuntimeException("DB connection failed", e);
        }
    }

    /**
     * Fetches a single column for a row identified by a parameterized WHERE clause.
     * Table and column names are validated (alphanumeric + underscore only) because JDBC cannot bind identifiers.
     */
    public DbRow fetchSingleColumn(
            String tableName,
            String columnName,
            String whereColumn,
            String whereValue
    ) {
        validateSqlIdentifier(tableName, "table");
        validateSqlIdentifier(columnName, "column");
        validateSqlIdentifier(whereColumn, "where column");

        String sql = "SELECT " + columnName + " FROM " + tableName + " WHERE " + whereColumn + " = ?";

        try (PreparedStatement stmt = getConnection().prepareStatement(sql)) {
            stmt.setString(1, whereValue);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalStateException(
                            "No DB row in " + tableName + " where " + whereColumn + " = " + whereValue
                    );
                }
                Object value = rs.getObject(columnName);
                int sqlType = rs.getMetaData().getColumnType(1);
                return new DbRow(value, sqlType);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Query execution failed: " + sql, e);
        }
    }

    public String getSingleValue(String tableName, String columnName, String whereColumn, String whereValue) {
        DbRow row = fetchSingleColumn(tableName, columnName, whereColumn, whereValue);
        return row.value() == null ? null : row.value().toString();
    }

    private void validateSqlIdentifier(String identifier, String label) {
        if (identifier == null || !identifier.matches("[a-zA-Z_][a-zA-Z0-9_]*")) {
            throw new IllegalArgumentException("Invalid SQL " + label + " name: " + identifier);
        }
    }

    public void close() {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                throw new RuntimeException("Failed to close DB connection", e);
            } finally {
                connection = null;
            }
        }
    }

    public record DbRow(Object value, int sqlType) {}
}

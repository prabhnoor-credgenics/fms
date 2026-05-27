package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import io.restassured.response.Response;
import utils.DbClient;

import java.math.BigDecimal;
import java.sql.Types;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNull;
import static org.testng.Assert.fail;

public class LoanRecoveryDbDatatypeSteps {

    private final TestContext testContext;
    private final DbClient dbClient;

    public LoanRecoveryDbDatatypeSteps(TestContext testContext, DbClient dbClient) {
        this.testContext = testContext;
        this.dbClient = dbClient;
    }

    @Then(
            "DB column {string} in table {string} should have datatype {string} " +
                    "and match API field {string} for loan {string} and company {string}"
    )
    public void validateDbDatatypeAndValue(
            String dbColumn,
            String tableName,
            String expectedDbType,
            String jsonPath,
            String loanId,
            String companyId
    ) {
        Response response = testContext.getResponse();
        if (response == null) {
            throw new IllegalStateException("No API response available. Send a request before DB validation.");
        }


        DbClient.DbRow dbRow = dbClient.fetchSingleColumn(tableName, dbColumn, "loan_id", loanId, companyId);

        assertEquals(
                sqlTypeToString(dbRow.sqlType()),
                expectedDbType,
                "DB datatype mismatch for column: " + dbColumn
        );

        Object apiValue = response.jsonPath().get(jsonPath);
        Object dbValue = dbRow.value();

        if (apiValue == null) {
            assertNull(dbValue, "DB value should be NULL for " + dbColumn);
            return;
        }

        switch (expectedDbType.toUpperCase()) {
            case "VARCHAR":
            case "TEXT":
                assertEquals(dbValue.toString(), apiValue.toString());
                break;

            case "INTEGER":
                assertEquals(
                        ((Number) dbValue).intValue(),
                        ((Number) apiValue).intValue()
                );
                break;

            case "NUMERIC":
            case "DECIMAL":
                assertEquals(
                        ((BigDecimal) dbValue).doubleValue(),
                        Double.parseDouble(apiValue.toString()),
                        0.01
                );
                break;

            case "BOOLEAN":
                assertEquals(
                        Boolean.parseBoolean(dbValue.toString()),
                        Boolean.parseBoolean(apiValue.toString())
                );
                break;

            default:
                fail("Unsupported DB type validation: " + expectedDbType);
        }
    }

    private String sqlTypeToString(int sqlType) {
        return switch (sqlType) {
            case Types.VARCHAR -> "VARCHAR";
            case Types.INTEGER -> "INTEGER";
            case Types.NUMERIC -> "NUMERIC";
            case Types.DECIMAL -> "DECIMAL";
            case Types.BOOLEAN -> "BOOLEAN";
            default -> "UNKNOWN";
        };
    }
}

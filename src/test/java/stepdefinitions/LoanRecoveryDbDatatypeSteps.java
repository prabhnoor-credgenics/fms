package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import io.restassured.path.json.JsonPath;
import utils.DbClient;
import context.ScenarioTestDataResolver;

import java.sql.Types;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNull;
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.fail;

public class LoanRecoveryDbDatatypeSteps {

    private final TestContext testContext;
    private final DbClient dbClient;
    private final ScenarioTestDataResolver scenarioTestDataResolver;

    public LoanRecoveryDbDatatypeSteps(TestContext testContext, DbClient dbClient, ScenarioTestDataResolver scenarioTestDataResolver) {
        this.testContext = testContext;
        this.dbClient = dbClient;
        this.scenarioTestDataResolver = scenarioTestDataResolver;
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
        String requestBody = testContext.getLastRequestBody();
        if (requestBody == null) {
            throw new IllegalStateException("No request body available. Send a request before DB validation.");
        }

        String resolvedLoanId = scenarioTestDataResolver.replaceScenarioPlaceholders(loanId);
        String resolvedCompanyId = scenarioTestDataResolver.replaceScenarioPlaceholders(companyId);

        DbClient.DbRow dbRow;
        if ("loan_id".equals(dbColumn)) {
            dbRow = dbClient.fetchSingleColumn(tableName, dbColumn, "loan_id", resolvedLoanId, resolvedCompanyId);
        } else {
            dbRow = dbClient.fetchFromLoanDetailsJson(tableName, dbColumn, resolvedLoanId, resolvedCompanyId);
        }

        assertEquals(
                sqlTypeToString(dbRow.sqlType()),
                expectedDbType,
                "DB datatype mismatch for column: " + dbColumn
        );

        Object apiValue = JsonPath.from(requestBody).get(jsonPath);
        Object dbValue = dbRow.value();

        if (apiValue == null) {
            assertNull(dbValue, "DB value should be NULL for " + dbColumn);
            return;
        }

        switch (expectedDbType.toUpperCase()) {
            case "VARCHAR":
            case "TEXT":
                assertTrue(
                        dbValue.toString().contains(apiValue.toString()),
                        "DB value '" + dbValue + "' does not contain expected '" + apiValue + "' for column " + dbColumn
                );
                break;

            case "INTEGER":
                assertEquals(
                        Integer.parseInt(dbValue.toString()),
                        (int) Double.parseDouble(apiValue.toString())
                );
                break;

            case "NUMERIC":
            case "DECIMAL":
                assertEquals(
                        Double.parseDouble(dbValue.toString()),
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

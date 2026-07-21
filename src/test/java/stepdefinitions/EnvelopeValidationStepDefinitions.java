package stepdefinitions;

import context.TestContext;
import io.cucumber.java.en.Then;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import validators.business.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Generic response-envelope validation steps replacing the ~80 per-feature
 * "the &lt;feature&gt; success/failure response should be valid" steps. Each feature now writes
 * the "&lt;key&gt;" success response should be valid (or failure); the key selects the feature's
 * EnvelopeValidator from the registry. Behaviour is unchanged - the same validator method runs.
 */
public class EnvelopeValidationStepDefinitions extends BaseStepDefinitions {

    private static final Logger logger = LogManager.getLogger(EnvelopeValidationStepDefinitions.class);

    private final Map<String, EnvelopeValidator> registry = new HashMap<>();

    public EnvelopeValidationStepDefinitions(
            TestContext testContext,
            AllocationDetailsValidator allocationDetailsValidator,
            AllocationEnqueueValidator allocationEnqueueValidator,
            AssignedCompaniesValidator assignedCompaniesValidator,
            BulkLoanPurgeValidator bulkLoanPurgeValidator,
            BulkVerifyLoanValidator bulkVerifyLoanValidator,
            CompanyDetailsValidator companyDetailsValidator,
            CompanyPermissionsValidator companyPermissionsValidator,
            CompanyTableNamesValidator companyTableNamesValidator,
            CompanyTypeValidator companyTypeValidator,
            CompanyUserCreateValidator companyUserCreateValidator,
            CompanyUserDetailsValidator companyUserDetailsValidator,
            CompanyUsersExportValidator companyUsersExportValidator,
            CompanyUsersListValidator companyUsersListValidator,
            ConnectionConfigValidator connectionConfigValidator,
            CoordinatesDistanceValidator coordinatesDistanceValidator,
            ExportLoanAllocatedUserValidator exportLoanAllocatedUserValidator,
            ExportLoanPaymentsValidator exportLoanPaymentsValidator,
            ExportLoanWithAllocatedUsersValidator exportLoanWithAllocatedUsersValidator,
            ExportLoanWithDocumentsValidator exportLoanWithDocumentsValidator,
            ExportLoanWithTagsValidator exportLoanWithTagsValidator,
            ExportPaymentsValidator exportPaymentsValidator,
            ExportsPaymentsLogsValidator exportsPaymentsLogsValidator,
            FinalStatusValidator finalStatusValidator,
            InternalBulkLoansValidator internalBulkLoansValidator,
            InternalCompanyUsersValidator internalCompanyUsersValidator,
            InternalRegisterRouteValidator internalRegisterRouteValidator,
            LoanDetailsUpdateValidator loanDetailsUpdateValidator,
            LoanUpdateValidator loanUpdateValidator,
            OutgoingWebhookValidator outgoingWebhookValidator,
            ProfileDetailsValidator profileDetailsValidator,
            ProfilesListValidator profilesListValidator,
            PublicAccessTokenValidator publicAccessTokenValidator,
            PublicLoginValidator publicLoginValidator,
            QuickAllocationValidator quickAllocationValidator,
            QuickDeAllocationValidator quickDeAllocationValidator,
            RolesValidator rolesValidator,
            TerritoryDetailsValidator territoryDetailsValidator,
            UserAllocatedLoansValidator userAllocatedLoansValidator,
            UserDetailsValidator userDetailsValidator,
            UserNavBarValidator userNavBarValidator,
            UserVariablesValidator userVariablesValidator,
            UsersFilterValidator usersFilterValidator,
            V1LoanMaskedDetailsValidator v1LoanMaskedDetailsValidator,
            VerifyUserValidator verifyUserValidator,
            GlobalUsersListValidator globalUsersListValidator
    ) {
        super(testContext);
        registry.put("allocation_details", allocationDetailsValidator);
        registry.put("allocation_enqueue", allocationEnqueueValidator);
        registry.put("assigned_companies", assignedCompaniesValidator);
        registry.put("bulk_loan_purge", bulkLoanPurgeValidator);
        registry.put("bulk_verify_loan", bulkVerifyLoanValidator);
        registry.put("company_details", companyDetailsValidator);
        registry.put("company_permissions", companyPermissionsValidator);
        registry.put("company_table_names", companyTableNamesValidator);
        registry.put("company_type", companyTypeValidator);
        registry.put("company_user_create", companyUserCreateValidator);
        registry.put("company_user_details", companyUserDetailsValidator);
        registry.put("company_users_export", companyUsersExportValidator);
        registry.put("company_users_list", companyUsersListValidator);
        registry.put("connection_config", connectionConfigValidator);
        registry.put("coordinates_distance", coordinatesDistanceValidator);
        registry.put("export_loan_allocated_user", exportLoanAllocatedUserValidator);
        registry.put("export_loan_payments", exportLoanPaymentsValidator);
        registry.put("export_loan_with_allocated_users", exportLoanWithAllocatedUsersValidator);
        registry.put("export_loan_with_documents", exportLoanWithDocumentsValidator);
        registry.put("export_loan_with_tags", exportLoanWithTagsValidator);
        registry.put("export_payments", exportPaymentsValidator);
        registry.put("export_payments_logs", exportsPaymentsLogsValidator);
        registry.put("final_status", finalStatusValidator);
        registry.put("internal_bulk_loans", internalBulkLoansValidator);
        registry.put("internal_company_users", internalCompanyUsersValidator);
        registry.put("internal_register_route", internalRegisterRouteValidator);
        registry.put("loan_details_update", loanDetailsUpdateValidator);
        registry.put("loan_update", loanUpdateValidator);
        registry.put("outgoing_webhook", outgoingWebhookValidator);
        registry.put("profile_details", profileDetailsValidator);
        registry.put("profiles_list", profilesListValidator);
        registry.put("public_access_token", publicAccessTokenValidator);
        registry.put("public_login", publicLoginValidator);
        registry.put("quick_allocation", quickAllocationValidator);
        registry.put("quick_deallocation", quickDeAllocationValidator);
        registry.put("roles", rolesValidator);
        registry.put("territory_details", territoryDetailsValidator);
        registry.put("user_allocated_loans", userAllocatedLoansValidator);
        registry.put("user_details", userDetailsValidator);
        registry.put("user_nav_bar", userNavBarValidator);
        registry.put("user_variables", userVariablesValidator);
        registry.put("users_filter", usersFilterValidator);
        registry.put("v1_loan_details", v1LoanMaskedDetailsValidator);
        registry.put("verify_user", verifyUserValidator);
        registry.put("global_users", globalUsersListValidator);
    }

    private EnvelopeValidator validatorFor(String key) {
        EnvelopeValidator validator = registry.get(key);
        if (validator == null) {
            throw new IllegalArgumentException(
                    "No envelope validator registered for key '" + key + "'. Known keys: " + registry.keySet());
        }
        return validator;
    }

    @Then("the {string} success response should be valid")
    public void the_success_response_should_be_valid(String key) {
        validatorFor(key).validateSuccessEnvelope(activeResponse());
        logger.info("success envelope validated for '{}'", key);
    }

    @Then("the {string} failure response should be valid")
    public void the_failure_response_should_be_valid(String key) {
        validatorFor(key).validateFailureEnvelope(activeResponse());
        logger.info("failure envelope validated for '{}'", key);
    }
}

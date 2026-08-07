package payload;

import config.ConfigReader;
import context.TestContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import helpers.FileHelper;
import helpers.JsonHelper;
import helpers.RandomDataHelper;
import helpers.SchemaHelper;

import static constants.FrameworkConstants.COMPANY_STEP1_TEMPLATE;
import static constants.FrameworkConstants.COMPANY_STEP2_TEMPLATE;
import static constants.FrameworkConstants.COMPANY_STEP3_TEMPLATE;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP1_REQUEST;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP2_REQUEST;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP3_REQUEST;
import static constants.FrameworkConstants.SCHEMA_COMPANY_STEP4_REQUEST;

public class CompanyCreationPayloadBuilder {

    private static final Logger logger = LogManager.getLogger(CompanyCreationPayloadBuilder.class);

    private static final String COMPANY_TYPE = "loan";
    private static final String CLIENT_TYPE = "mediation";
    private static final String COMPANY_SUB_TYPE = "collection";
    private static final String TENANT_TYPE = "company";

    private final ConfigReader configReader;
    private final TestContext testContext;

    public CompanyCreationPayloadBuilder(
            ConfigReader configReader,
            TestContext testContext
    ) {
        this.configReader = configReader;
        this.testContext = testContext;
    }

    public void prepareCompanyCreationTestData() {
        String companyName = RandomDataHelper.uniqueCompanyName();
        String trademark = RandomDataHelper.uniqueCompanyName();
        String digits = digitsSuffix(companyName);
        String companyEmail = "TestCompany" + digits + "@yopmail.com";
        String adminEmail = RandomDataHelper.generateRandomEmail();
        String authorizedRepresentativeName = RandomDataHelper.randomName();
        String adminFirstName = RandomDataHelper.randomFirstName();
        String adminLastName = RandomDataHelper.randomLastName();

        testContext.setCompanyName(companyName);
        testContext.setTrademark(trademark);
        testContext.setCompanyEmail(companyEmail);
        testContext.setAdminEmail(adminEmail);
        testContext.setAuthorizedRepresentativeName(authorizedRepresentativeName);
        testContext.setAdminFirstName(adminFirstName);
        testContext.setAdminLastName(adminLastName);
        testContext.setCompanyType(COMPANY_TYPE);
        testContext.setClientType(CLIENT_TYPE);
        testContext.setCompanySubType(COMPANY_SUB_TYPE);
        testContext.setTenantType(TENANT_TYPE);

        logger.info(
                "Prepared company creation test data: trademark={}, companyName={}, companyEmail={}, adminEmail={}, "
                        + "authorizedRepresentativeName={}, adminFirstName={}, adminLastName={}",
                trademark,
                companyName,
                companyEmail,
                adminEmail,
                authorizedRepresentativeName,
                adminFirstName,
                adminLastName
        );
    }

    private static String digitsSuffix(String name) {
        if (name == null) {
            return "";
        }
        int i = name.length();
        while (i > 0 && Character.isDigit(name.charAt(i - 1))) {
            i--;
        }
        return name.substring(i);
    }

    public String buildStep1Payload() {
        String payload = assembleStep1Payload();
        SchemaHelper.validateRequestBody(payload, SCHEMA_COMPANY_STEP1_REQUEST);
        logger.debug("Built company creation step 1 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    public String buildStep1PayloadWithoutMandatoryField(String fieldName) {
        String payload = JsonHelper.removeField(assembleStep1Payload(), "data." + fieldName);
        logger.debug("Built step 1 payload without mandatory field '{}' for trademark={}",
                fieldName, testContext.getTrademark());
        return payload;
    }

    private String assembleStep1Payload() {
        requireTrademarkPrepared();
        requireAuthorizedRepresentativeNamePrepared();
        String template = FileHelper.readResourceAsString(COMPANY_STEP1_TEMPLATE);
        String[] ips = configReader.getCompanyCreationWhitelistedIps().split(",");
        return template
                .replace("{COMPANY_TYPE}", COMPANY_TYPE)
                .replace("{CLIENT_TYPE}", CLIENT_TYPE)
                .replace("{COMPANY_SUB_TYPE}", COMPANY_SUB_TYPE)
                .replace("{TENANT_TYPE}", TENANT_TYPE)
                .replace("{COUNTRY_ISD_CODE}", configReader.getCompanyCreationCountryIsdCode())
                .replace("{COMPANY_NAME}", escapeJson(testContext.getCompanyName()))
                .replace("{TRADEMARK}", escapeJson(testContext.getTrademark()))
                .replace("{COMPANY_EMAIL}", escapeJson(testContext.getCompanyEmail()))
                .replace("{AUTHORIZED_REP_NAME}", escapeJson(testContext.getAuthorizedRepresentativeName()))
                .replace("{GST_NUMBER}", configReader.getCompanyCreationGstNumber())
                .replace("{COMPANY_CODE}", escapeJson(testContext.getTrademark()))
                .replace("{ALIAS_PROFILE_ID}", configReader.getCompanyCreationAliasProfileId())
                .replace("{WHITELISTED_IP_1}", ips[0].trim())
                .replace("{WHITELISTED_IP_2}", ips.length > 1 ? ips[1].trim() : ips[0].trim());
    }

    public String buildStep2Payload() {
        requireTrademarkPrepared();
        String template = FileHelper.readResourceAsString(COMPANY_STEP2_TEMPLATE);
        String payload = template.replace("{TRADEMARK}", escapeJson(testContext.getTrademark()));
        SchemaHelper.validateRequestBody(payload, SCHEMA_COMPANY_STEP2_REQUEST);
        logger.debug("Built company creation step 2 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    public String buildStep3Payload() {
        String payload = assembleStep3Payload();
        SchemaHelper.validateRequestBody(payload, SCHEMA_COMPANY_STEP3_REQUEST);
        logger.debug("Built company creation step 3 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    public String buildStep3PayloadWithoutAdminField(String adminFieldName) {
        String payload = JsonHelper.removeField(
                assembleStep3Payload(),
                "data.company_admin_details." + adminFieldName
        );
        logger.debug(
                "Built step 3 payload without admin field '{}' for trademark={}",
                adminFieldName,
                testContext.getTrademark()
        );
        return payload;
    }

    public String buildStep3PayloadWithoutEmailOnly() {
        String payload = JsonHelper.removeField(
                assembleStep3PayloadNoMobile(),
                "data.company_admin_details.email"
        );
        logger.debug("Built step 3 payload without email (mobile not sent) for trademark={}",
                testContext.getTrademark());
        return payload;
    }

    public String buildStep3PayloadWithoutEmailAndMobile() {
        String payload = assembleStep3Payload();
        payload = JsonHelper.removeField(payload, "data.company_admin_details.email");
        payload = JsonHelper.removeField(payload, "data.company_admin_details.mobile");
        logger.debug(
                "Built step 3 payload without email and mobile for trademark={}",
                testContext.getTrademark()
        );
        return payload;
    }

    private String assembleStep3PayloadNoMobile() {
        return JsonHelper.removeField(assembleStep3Payload(), "data.company_admin_details.mobile");
    }

    private String assembleStep3Payload() {
        requireTrademarkPrepared();
        requireAdminEmailPrepared();
        requireAdminNamePrepared();
        String template = FileHelper.readResourceAsString(COMPANY_STEP3_TEMPLATE);
        return template
                .replace("{TRADEMARK}", escapeJson(testContext.getTrademark()))
                .replace("{COUNTRY_ISD_CODE}", configReader.getCompanyCreationCountryIsdCode())
                .replace("{ADMIN_EMAIL}", escapeJson(testContext.getAdminEmail()))
                .replace("{ADMIN_FIRST_NAME}", escapeJson(testContext.getAdminFirstName()))
                .replace("{ADMIN_LAST_NAME}", escapeJson(testContext.getAdminLastName()));
    }

    public String buildStep4Payload() {
        requireTrademarkPrepared();
        String payload = """
                {
                  "validation_step": 4,
                  "trademark": "%s"
                }
                """.formatted(escapeJson(testContext.getTrademark()));
        SchemaHelper.validateRequestBody(payload, SCHEMA_COMPANY_STEP4_REQUEST);
        logger.debug("Built company creation step 4 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    private void requireTrademarkPrepared() {
        if (testContext.getTrademark() == null || testContext.getTrademark().isBlank()) {
            throw new IllegalStateException(
                    "Trademark is not set. Call 'Given company creation test data is prepared' first."
            );
        }
    }

    private void requireAdminEmailPrepared() {
        if (testContext.getAdminEmail() == null || testContext.getAdminEmail().isBlank()) {
            throw new IllegalStateException(
                    "Admin email is not set. Call 'Given company creation test data is prepared' first."
            );
        }
    }

    private void requireAuthorizedRepresentativeNamePrepared() {
        String name = testContext.getAuthorizedRepresentativeName();
        if (name == null || name.isBlank()) {
            throw new IllegalStateException(
                    "Authorized representative name is not set. Call 'Given company creation test data is prepared' first."
            );
        }
    }

    private void requireAdminNamePrepared() {
        if (testContext.getAdminFirstName() == null || testContext.getAdminFirstName().isBlank()
                || testContext.getAdminLastName() == null || testContext.getAdminLastName().isBlank()) {
            throw new IllegalStateException(
                    "Admin first/last name is not set. Call 'Given company creation test data is prepared' first."
            );
        }
    }

    private static String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

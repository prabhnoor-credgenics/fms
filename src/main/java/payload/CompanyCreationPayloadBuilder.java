package payload;

import config.ConfigReader;
import context.TestContext;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import utils.JsonUtils;
import utils.TestDataHelper;

import static constants.FrameworkConstants.COMPANY_STEP1_TEMPLATE;
import static constants.FrameworkConstants.COMPANY_STEP2_TEMPLATE;
import static constants.FrameworkConstants.COMPANY_STEP3_TEMPLATE;


public class CompanyCreationPayloadBuilder {

    private static final Logger logger = LogManager.getLogger(CompanyCreationPayloadBuilder.class);

    private static final String COMPANY_TYPE = "loan";
    private static final String CLIENT_TYPE = "mediation";
    private static final String COMPANY_SUB_TYPE = "collection";
    private static final String TENANT_TYPE = "company";

    private final ConfigReader configReader;
    private final TestContext testContext;
    private final TestDataHelper testDataHelper;

    public CompanyCreationPayloadBuilder(
            ConfigReader configReader,
            TestContext testContext,
            TestDataHelper testDataHelper
    ) {
        this.configReader = configReader;
        this.testContext = testContext;
        this.testDataHelper = testDataHelper;
    }


    public void prepareCompanyCreationTestData() {
        String suffix = testDataHelper.generateUUID().replace("-", "").substring(0, 8);
        String companyName = "Test Company " + suffix;
        String trademark = "Tests Company " + suffix;
        String companyEmail = "TestCompany" + suffix + "@yopmail.com";
        String adminEmail = "TestAdmin" + suffix + "@yopmail.com";

        testContext.setCompanyName(companyName);
        testContext.setTrademark(trademark);
        testContext.setCompanyEmail(companyEmail);
        testContext.setAdminEmail(adminEmail);
        testContext.setCompanyType(COMPANY_TYPE);
        testContext.setClientType(CLIENT_TYPE);
        testContext.setCompanySubType(COMPANY_SUB_TYPE);
        testContext.setTenantType(TENANT_TYPE);

        logger.info(
                "Prepared company creation test data: trademark={}, companyName={}, companyEmail={}",
                trademark,
                companyName,
                companyEmail
        );
    }

    public String buildStep1Payload() {
        requireTrademarkPrepared();
        String template = JsonUtils.readJsonFromFile(COMPANY_STEP1_TEMPLATE);
        String[] ips = configReader.getCompanyCreationWhitelistedIps().split(",");
        String payload = template
                .replace("{COMPANY_TYPE}", COMPANY_TYPE)
                .replace("{CLIENT_TYPE}", CLIENT_TYPE)
                .replace("{COMPANY_SUB_TYPE}", COMPANY_SUB_TYPE)
                .replace("{TENANT_TYPE}", TENANT_TYPE)
                .replace("{COUNTRY_ISD_CODE}", configReader.getCompanyCreationCountryIsdCode())
                .replace("{COMPANY_NAME}", escapeJson(testContext.getCompanyName()))
                .replace("{TRADEMARK}", escapeJson(testContext.getTrademark()))
                .replace("{COMPANY_EMAIL}", escapeJson(testContext.getCompanyEmail()))
                .replace("{GST_NUMBER}", configReader.getCompanyCreationGstNumber())
                .replace("{COMPANY_CODE}", escapeJson(testContext.getTrademark()))
                .replace("{ALIAS_PROFILE_ID}", configReader.getCompanyCreationAliasProfileId())
                .replace("{WHITELISTED_IP_1}", ips[0].trim())
                .replace("{WHITELISTED_IP_2}", ips.length > 1 ? ips[1].trim() : ips[0].trim());

        logger.debug("Built company creation step 1 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    public String buildStep2Payload() {
        requireTrademarkPrepared();
        String template = JsonUtils.readJsonFromFile(COMPANY_STEP2_TEMPLATE);
        String payload = template.replace("{TRADEMARK}", escapeJson(testContext.getTrademark()));
        logger.debug("Built company creation step 2 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    public String buildStep3Payload() {
        requireTrademarkPrepared();
        requireAdminEmailPrepared();
        String suffix = testContext.getAdminEmail().substring(
                testContext.getAdminEmail().indexOf("TestAdmin") + 9,
                testContext.getAdminEmail().indexOf('@')
        );
        String template = JsonUtils.readJsonFromFile(COMPANY_STEP3_TEMPLATE);
        String payload = template
                .replace("{TRADEMARK}", escapeJson(testContext.getTrademark()))
                .replace("{COUNTRY_ISD_CODE}", configReader.getCompanyCreationCountryIsdCode())
                .replace("{ADMIN_EMAIL}", escapeJson(testContext.getAdminEmail()))
                .replace("{ADMIN_LAST_NAME}", suffix);
        logger.debug("Built company creation step 3 payload for trademark={}", testContext.getTrademark());
        return payload;
    }

    public String buildStep4Payload() {
        requireTrademarkPrepared();
        String payload = """
                {
                  "validation_step": 4,
                  "trademark": "%s"
                }
                """.formatted(escapeJson(testContext.getTrademark()));
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

    private static String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

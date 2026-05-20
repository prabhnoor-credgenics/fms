package base;

import config.ConfigReader;
import io.restassured.filter.log.RequestLoggingFilter;
import io.restassured.filter.log.ResponseLoggingFilter;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import static io.restassured.RestAssured.given;


public class RestAssuredBase {
    private static final Logger logger = LogManager.getLogger(RestAssuredBase.class);

    private final ConfigReader configReader;

    public RestAssuredBase(ConfigReader configReader) {
        this.configReader = configReader;
    }

    public RequestSpecification getRequestSpec() {
        RequestSpecification spec = given()
                .baseUri(configReader.getBaseUrl())
                .contentType(configReader.getDefaultContentType())
                .accept(configReader.getDefaultAcceptType());

        if (!configReader.isCiMode()) {
            if (configReader.isRequestLoggingEnabled()) {
                spec.filter(new RequestLoggingFilter());
            }
            if (configReader.isResponseLoggingEnabled()) {
                spec.filter(new ResponseLoggingFilter());
            }
        }

        logger.debug("Request specification prepared for base URI: {}", configReader.getBaseUrl());
        return spec;
    }

    public RequestSpecification getRequestSpec(ContentType contentType) {
        return getRequestSpec().contentType(contentType);
    }
}

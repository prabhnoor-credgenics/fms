package utils.crypto;

import config.ConfigReader;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.crypto.Cipher;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

public class RSAEncryptionUtil {

    private static final Logger logger = LogManager.getLogger(RSAEncryptionUtil.class);

    private final ConfigReader configReader;

    public RSAEncryptionUtil(ConfigReader configReader) {
        this.configReader = configReader;
    }

    public String encrypt(String plainText) {
        try {
            String publicKey = configReader.getPublicKey()
                    .replace("-----BEGIN PUBLIC KEY-----", "")
                    .replace("-----END PUBLIC KEY-----", "")
                    .replaceAll("\\s", "");

            byte[] keyBytes = Base64.getDecoder().decode(publicKey);
            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(keyBytes);
            PublicKey key = KeyFactory.getInstance("RSA").generatePublic(keySpec);

            Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-1AndMGF1Padding");
            cipher.init(Cipher.ENCRYPT_MODE, key);

            byte[] encryptedBytes = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encryptedBytes);

        } catch (Exception e) {
            logger.error("RSA encryption failed for environment {}: {}",
                    configReader.getEnvironment(), e.getMessage(), e);
            throw new RuntimeException(
                    "RSA encryption failed (" + configReader.getEnvironment() + "): " + e.getMessage(), e);
        }
    }
}

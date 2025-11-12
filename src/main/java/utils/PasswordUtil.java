package utils;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Utility class for secure password hashing and verification.
 * Uses PBKDF2WithHmacSHA256 algorithm with salt.
 */
public class PasswordUtil {

    // Recommended PBKDF2 settings
    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256;

    /**
     * Generates a random salt.
     */
    private static String generateSalt() {
        byte[] salt = new byte[16];
        SecureRandom random = new SecureRandom();
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    /**
     * Hashes a password with a new random salt.
     * @param password Plaintext password
     * @return String array: [salt, hash]
     */
    public static String[] hashPassword(String password) {
        String salt = generateSalt();
        String hash = hashWithSalt(password, salt);
        return new String[] { salt, hash };
    }

    /**
     * Combines salt + hash into single string for storage (salt:hash)
     * @param password Plaintext password
     * @return Combined salt:hash string
     */
    public static String hashPasswordCombined(String password) {
        String[] data = hashPassword(password);
        return data[0] + ":" + data[1];
    }

    /**
     * Verifies a password against stored salt:hash value.
     * @param password Plaintext password entered by user
     * @param stored Combined salt:hash from database
     * @return true if match, false otherwise
     */
    public static boolean verifyPassword(String password, String stored) {
        if (stored == null || !stored.contains(":")) return false;

        String[] parts = stored.split(":");
        if (parts.length != 2) return false;

        String salt = parts[0];
        String storedHash = parts[1];

        String calculatedHash = hashWithSalt(password, salt);
        return storedHash.equals(calculatedHash);
    }

    /**
     * Performs hashing with given salt using PBKDF2WithHmacSHA256
     */
    private static String hashWithSalt(String password, String salt) {
        try {
            PBEKeySpec spec = new PBEKeySpec(
                    password.toCharArray(),
                    Base64.getDecoder().decode(salt),
                    ITERATIONS,
                    KEY_LENGTH
            );
            SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            byte[] hash = skf.generateSecret(spec).getEncoded();
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error hashing password: " + e.getMessage(), e);
        }
    }
}

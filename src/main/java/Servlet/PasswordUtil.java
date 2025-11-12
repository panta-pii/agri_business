package Servlet;


import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    // Generate a random salt
    public static String getSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    // Hash a password using SHA-256 and a salt
    public static String hashPassword(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes());
            byte[] hashedPassword = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hashedPassword);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }

    // Verify password (compare entered password with stored hash)
    public static boolean verifyPassword(String enteredPassword, String storedHash, String storedSalt) {
        String newHash = hashPassword(enteredPassword, storedSalt);
        return newHash != null && newHash.equals(storedHash);
    }

    // Generate salt + hash pair (used during registration)
    public static String[] hashPassword(String password) {
        String salt = getSalt();
        String hashedPassword = hashPassword(password, salt);
        return new String[]{hashedPassword, salt};
    }
}

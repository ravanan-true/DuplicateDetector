
package com.duplicatedetector.util;

import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    private static final int ITERATIONS = 210000;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16;

    private PasswordUtil() {
        // Utility class
    }

    public static String hashPassword(String password)
            throws Exception {

        byte[] salt = new byte[SALT_LENGTH];
        SecureRandom random = new SecureRandom();
        random.nextBytes(salt);

        byte[] hash = generateHash(password, salt);

        return ITERATIONS + ":" 
                + Base64.getEncoder().encodeToString(salt)
                + ":"
                + Base64.getEncoder().encodeToString(hash);
    }

    public static boolean verifyPassword(
            String password, String storedHash) throws Exception {

        if (password == null || storedHash == null) {
            return false;
        }

        String[] parts = storedHash.split(":");

        if (parts.length != 3) {
            return false;
        }

        int iterations = Integer.parseInt(parts[0]);

        if (iterations < 1 || iterations > 1000000) {
            return false;
        }

        byte[] salt = Base64.getDecoder().decode(parts[1]);
        byte[] expectedHash = Base64.getDecoder().decode(parts[2]);

        if (salt.length < 16 || expectedHash.length != 32) {
            return false;
        }

        byte[] actualHash = generateHash(
                password, salt, iterations);

        return java.security.MessageDigest.isEqual(
                expectedHash, actualHash);
    }

    private static byte[] generateHash(
            String password, byte[] salt) throws Exception {

        return generateHash(password, salt, ITERATIONS);
    }

    private static byte[] generateHash(
            String password, byte[] salt, int iterations)
            throws Exception {

        KeySpec spec = new PBEKeySpec(
                password.toCharArray(),
                salt,
                iterations,
                KEY_LENGTH
        );

        SecretKeyFactory factory =
                SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");

        return factory.generateSecret(spec).getEncoded();
    }
}

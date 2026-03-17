import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class TestPassword {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "123456";
        String hash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAtmZ5EHs0MlqoFLDJ8gR.Jl9WNu";
        
        System.out.println("Password: " + password);
        System.out.println("Hash: " + hash);
        System.out.println("Matches: " + encoder.matches(password, hash));
        
        // Generate a new hash
        String newHash = encoder.encode(password);
        System.out.println("New Hash: " + newHash);
        System.out.println("New Hash Matches: " + encoder.matches(password, newHash));
    }
}

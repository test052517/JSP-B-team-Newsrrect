package mgr;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.io.InputStream;

/**
 * 데이터베이스 연결을 관리하는 매니저 클래스
 */
public class ConnectionMgr {
    private static final String CONFIG_FILE = "/config.properties";
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    private static String DB_DRIVER;
    
    // 정적 초기화 블록
    static {
        loadDatabaseConfig();
    }
    
    /**
     * 데이터베이스 설정을 properties 파일에서 로드
     */
    private static void loadDatabaseConfig() {
        try (InputStream input = ConnectionMgr.class.getResourceAsStream(CONFIG_FILE)) {
            Properties prop = new Properties();
            prop.load(input);
            
            DB_DRIVER = prop.getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
            DB_URL = prop.getProperty("db.url", "jdbc:mysql://localhost:3306/news_analysis?useSSL=false&serverTimezone=Asia/Seoul");
            DB_USER = prop.getProperty("db.user", "root");
            DB_PASSWORD = prop.getProperty("db.password", "1234");
            
            // JDBC 드라이버 로드
            Class.forName(DB_DRIVER);
            System.out.println("데이터베이스 드라이버 로드 성공: " + DB_DRIVER);
            
        } catch (Exception e) {
            System.err.println("데이터베이스 설정 로드 실패: " + e.getMessage());
            e.printStackTrace();
            
            // 기본값 설정
            DB_DRIVER = "com.mysql.cj.jdbc.Driver";
            DB_URL = "jdbc:mysql://localhost:3306/news_analysis?useSSL=false&serverTimezone=Asia/Seoul";
            DB_USER = "root";
            DB_PASSWORD = "1234";
            
            try {
                Class.forName(DB_DRIVER);
            } catch (ClassNotFoundException ex) {
                System.err.println("JDBC 드라이버 로드 실패: " + ex.getMessage());
            }
        }
    }
    
    /**
     * 데이터베이스 연결 생성
     * @return Connection 객체
     * @throws SQLException 데이터베이스 연결 실패 시
     */
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("데이터베이스 연결 성공: " + DB_URL);
            return conn;
        } catch (SQLException e) {
            System.err.println("데이터베이스 연결 실패: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * 연결 테스트
     * @return 연결 성공 여부
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("연결 테스트 실패: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * 리소스 정리 메소드
     * @param conn Connection 객체
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                System.out.println("데이터베이스 연결 종료");
            } catch (SQLException e) {
                System.err.println("연결 종료 실패: " + e.getMessage());
            }
        }
    }
    
    /**
     * 현재 설정된 데이터베이스 정보 반환
     */
    public static String getDatabaseInfo() {
        return String.format("Database: %s, User: %s", DB_URL, DB_USER);
    }
}
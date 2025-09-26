package mgr;

import java.sql.*;
import java.util.Properties;
import java.util.Vector;
import java.util.HashMap;
import java.util.Map;

/**
 * Manages multiple java.sql.Connection pools for different databases.
 *
 * @author Modified for multi-database support
 */
public class DBConnectionMgr {
    // 각 데이터베이스별로 연결 풀을 관리
    private Map<String, Vector<ConnectionObject>> connectionPools = new HashMap<>();
    
    // 데이터베이스 설정 정보
    private Map<String, DatabaseConfig> dbConfigs = new HashMap<>();
    
    private boolean _traceOn = false;
    private boolean initialized = false;
    private int _openConnections = 50;
    private static DBConnectionMgr instance = null;

    private DBConnectionMgr() {
        initializeDatabaseConfigs();
    }
    
    private void initializeDatabaseConfigs() {
        // 첫 번째 데이터베이스 (뉴스 분석)
        DatabaseConfig newsDB = new DatabaseConfig();
        newsDB.driver = "com.mysql.cj.jdbc.Driver";
        newsDB.url = "jdbc:mysql://localhost:3306/news_analysis?characterEncoding=UTF-8&serverTimezone=UTC";
        newsDB.user = "root";
        newsDB.password = "1234";
        dbConfigs.put("news", newsDB);
        connectionPools.put("news", new Vector<>(10));
        
        // 두 번째 데이터베이스 (사용자 정보나 다른 용도)
        DatabaseConfig userDB = new DatabaseConfig();
        userDB.driver = "com.mysql.cj.jdbc.Driver";
        userDB.url = "jdbc:mysql://localhost:3306/newsrrect?characterEncoding=UTF-8&serverTimezone=UTC";
        userDB.user = "root";
        userDB.password = "1234";
        dbConfigs.put("user", userDB);
        connectionPools.put("user", new Vector<>(10));
    }

    public static DBConnectionMgr getInstance() {
        if (instance == null) {
            synchronized (DBConnectionMgr.class) {
                if (instance == null) {
                    instance = new DBConnectionMgr();
                }
            }
        }
        return instance;
    }

    public void setOpenConnectionCount(int count) {
        _openConnections = count;
    }

    public void setEnableTrace(boolean enable) {
        _traceOn = enable;
    }

    /** 특정 데이터베이스의 연결 목록 반환 */
    public Vector getConnectionList(String dbName) {
        return connectionPools.get(dbName);
    }

    /** 특정 데이터베이스에 대해 지정된 수만큼 연결을 열고 풀에 추가 */
    public synchronized void setInitOpenConnections(String dbName, int count) throws SQLException {
        Vector<ConnectionObject> connections = connectionPools.get(dbName);
        if (connections == null) {
            throw new SQLException("Unknown database: " + dbName);
        }
        
        Connection c = null;
        ConnectionObject co = null;

        for (int i = 0; i < count; i++) {
            c = createConnection(dbName);
            co = new ConnectionObject(c, false);
            connections.addElement(co);
            trace("ConnectionPoolManager: Adding new DB connection to " + dbName + " pool (" + connections.size() + ")");
        }
    }

    /** 특정 데이터베이스의 연결 수 반환 */
    public int getConnectionCount(String dbName) {
        Vector<ConnectionObject> connections = connectionPools.get(dbName);
        return connections != null ? connections.size() : 0;
    }

    /** 기본 데이터베이스(news) 연결 반환 - 기존 호환성 유지 */
    public synchronized Connection getConnection() throws Exception {
        return getConnection("news");
    }
    

    /** 특정 데이터베이스의 연결 반환 */
    public synchronized Connection getConnection(String dbName) throws Exception {
    	 System.out.println("1. getConnection 요청 받음. 요청된 DB 키: [" + dbName + "]");
        Vector<ConnectionObject> connections = connectionPools.get(dbName);
        DatabaseConfig config = dbConfigs.get(dbName);
        
        if (connections == null || config == null) {
        	System.out.println("2. 오류: '" + dbName + "'에 해당하는 설정을 찾을 수 없음!");
            throw new Exception("Unknown database: " + dbName);
        }
        
        System.out.println("2. '" + dbName + "' 설정 찾음. 연결할 URL: " + config.url);

        if (!initialized) {
            // 모든 데이터베이스 드라이버 등록
            for (DatabaseConfig dbConfig : dbConfigs.values()) {
                Class c = Class.forName(dbConfig.driver);
                DriverManager.registerDriver((Driver) c.newInstance());
            }
            initialized = true;
        }

        Connection c = null;
        ConnectionObject co = null;
        boolean badConnection = false;

        // 기존 연결 중에서 사용 가능한 것 찾기
        for (int i = 0; i < connections.size(); i++) {
            co = (ConnectionObject) connections.elementAt(i);

            if (!co.inUse) {
                try {
                    badConnection = co.connection.isClosed();
                    if (!badConnection)
                        badConnection = (co.connection.getWarnings() != null);
                } catch (Exception e) {
                    badConnection = true;
                    e.printStackTrace();
                }

                if (badConnection) {
                    connections.removeElementAt(i);
                    trace("ConnectionPoolManager: Remove disconnected " + dbName + " DB connection #" + i);
                    continue;
                }

                c = co.connection;
                co.inUse = true;
                trace("ConnectionPoolManager: Using existing " + dbName + " DB connection #" + (i + 1));
                break;
            }
        }

        // 사용 가능한 연결이 없으면 새로 생성
        if (c == null) {
        	System.out.println("3. 사용 가능한 기존 연결 없음. 새 연결 생성 시도...");
            c = createConnection(dbName);
            co = new ConnectionObject(c, true);
            connections.addElement(co);
            trace("ConnectionPoolManager: Creating new " + dbName + " DB connection #" + connections.size());
        }

        return c;
    }

    /** 기존 호환성을 위한 freeConnection 메소드들 */
    public synchronized void freeConnection(Connection c) {
        freeConnectionFromAnyPool(c);
    }

    /** 모든 풀에서 해당 연결을 찾아서 해제 */
    private synchronized void freeConnectionFromAnyPool(Connection c) {
        if (c == null) return;

        for (Map.Entry<String, Vector<ConnectionObject>> entry : connectionPools.entrySet()) {
            Vector<ConnectionObject> connections = entry.getValue();
            String dbName = entry.getKey();
            
            for (int i = 0; i < connections.size(); i++) {
                ConnectionObject co = (ConnectionObject) connections.elementAt(i);
                if (c == co.connection) {
                    co.inUse = false;
                    trace("ConnectionPoolManager: Freed " + dbName + " DB connection");
                    
                    // 너무 많은 연결이 있으면 일부 제거
                    cleanupExcessConnections(connections);
                    return;
                }
            }
        }
    }

    private void cleanupExcessConnections(Vector<ConnectionObject> connections) {
        for (int i = 0; i < connections.size(); i++) {
            ConnectionObject co = (ConnectionObject) connections.elementAt(i);
            if ((i + 1) > _openConnections && !co.inUse) {
                removeConnection(co.connection, connections);
            }
        }
    }

    public void freeConnection(Connection c, PreparedStatement p, ResultSet r) {
        try {
            if (r != null) r.close();
            if (p != null) p.close();
            freeConnection(c);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void freeConnection(Connection c, Statement s, ResultSet r) {
        try {
            if (r != null) r.close();
            if (s != null) s.close();
            freeConnection(c);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void freeConnection(Connection c, PreparedStatement p) {
        try {
            if (p != null) p.close();
            freeConnection(c);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void freeConnection(Connection c, Statement s) {
        try {
            if (s != null) s.close();
            freeConnection(c);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /** 특정 연결을 모든 풀에서 제거 */
    public synchronized void removeConnection(Connection c) {
        if (c == null) return;

        for (Vector<ConnectionObject> connections : connectionPools.values()) {
            removeConnection(c, connections);
        }
    }

    private synchronized void removeConnection(Connection c, Vector<ConnectionObject> connections) {
        if (c == null) return;

        for (int i = 0; i < connections.size(); i++) {
            ConnectionObject co = (ConnectionObject) connections.elementAt(i);
            if (c == co.connection) {
                try {
                    c.close();
                    connections.removeElementAt(i);
                    trace("Removed " + c.toString());
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            }
        }
    }

    /** 특정 데이터베이스에 대한 연결 생성 */
    private Connection createConnection(String dbName) throws SQLException {
        DatabaseConfig config = dbConfigs.get(dbName);
        if (config == null) {
            throw new SQLException("Unknown database: " + dbName);
        }

        Connection con = null;
        try {
            Properties props = new Properties();
            props.put("user", config.user != null ? config.user : "");
            props.put("password", config.password != null ? config.password : "");

            con = DriverManager.getConnection(config.url, props);
        } catch (Throwable t) {
            throw new SQLException(t.getMessage());
        }

        return con;
    }

    /** 모든 데이터베이스의 사용하지 않는 연결 해제 */
    public void releaseFreeConnections() {
        trace("ConnectionPoolManager.releaseFreeConnections()");

        for (Map.Entry<String, Vector<ConnectionObject>> entry : connectionPools.entrySet()) {
            Vector<ConnectionObject> connections = entry.getValue();
            String dbName = entry.getKey();
            
            for (int i = connections.size() - 1; i >= 0; i--) {
                ConnectionObject co = (ConnectionObject) connections.elementAt(i);
                if (!co.inUse) {
                    removeConnection(co.connection, connections);
                }
            }
        }
    }

    /** 모든 연결 종료 및 풀 정리 */
    public void finalize() {
        trace("ConnectionPoolManager.finalize()");

        for (Vector<ConnectionObject> connections : connectionPools.values()) {
            for (int i = 0; i < connections.size(); i++) {
                ConnectionObject co = (ConnectionObject) connections.elementAt(i);
                try {
                    co.connection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                co = null;
            }
            connections.removeAllElements();
        }
        connectionPools.clear();
    }

    private void trace(String s) {
        if (_traceOn)
            System.err.println(s);
    }

    /** 데이터베이스 설정 추가/변경 */
    public void addDatabase(String dbName, String driver, String url, String user, String password) {
        DatabaseConfig config = new DatabaseConfig();
        config.driver = driver;
        config.url = url;
        config.user = user;
        config.password = password;
        
        dbConfigs.put(dbName, config);
        connectionPools.put(dbName, new Vector<>(10));
    }

    /** 사용 가능한 데이터베이스 이름 목록 반환 */
    public String[] getAvailableDatabases() {
        return dbConfigs.keySet().toArray(new String[0]);
    }
}

/** 데이터베이스 설정 정보를 담는 내부 클래스 */
class DatabaseConfig {
    public String driver;
    public String url;
    public String user;
    public String password;
}

class ConnectionObject {
    public java.sql.Connection connection = null;
    public boolean inUse = false;

    public ConnectionObject(Connection c, boolean useFlag) {
        connection = c;
        inUse = useFlag;
    }
}
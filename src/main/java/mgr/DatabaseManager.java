package mgr;

import beans.NewsArticleBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 뉴스 기사 데이터를 관리하는 매니저 클래스 (DBConnectionMgr 사용)
 */
public class DatabaseManager {
    
    private DBConnectionMgr dbMgr = DBConnectionMgr.getInstance();
    
    /**
     * 뉴스 기사를 데이터베이스에 저장
     */
    public boolean saveNewsArticle(NewsArticleBean article) {
        String sql = "INSERT IGNORE INTO news_articles (title, content, url, published_date, source, keywords) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, article.getTitle());
            pstmt.setString(2, article.getContent());
            pstmt.setString(3, article.getUrl());
            pstmt.setString(4, article.getPublishedDate());
            pstmt.setString(5, article.getSource());
            pstmt.setString(6, article.getKeywords());
            
            int result = pstmt.executeUpdate();
            boolean success = result > 0;
            
            if (success) {
                System.out.println("뉴스 기사 저장 성공: " + article.getTitle());
            }
            
            return success;
            
        } catch (Exception e) {
            System.err.println("뉴스 기사 저장 실패: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            dbMgr.freeConnection(conn, pstmt);
        }
    }
    
    /**
     * 여러 뉴스 기사를 배치로 저장
     */
    public int saveNewsArticles(List<NewsArticleBean> articles) {
        String sql = "INSERT IGNORE INTO news_articles (title, content, url, published_date, source, keywords) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        int savedCount = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            for (NewsArticleBean article : articles) {
                pstmt.setString(1, article.getTitle());
                pstmt.setString(2, article.getContent());
                pstmt.setString(3, article.getUrl());
                pstmt.setString(4, article.getPublishedDate());
                pstmt.setString(5, article.getSource());
                pstmt.setString(6, article.getKeywords());
                
                pstmt.addBatch();
            }
            
            int[] results = pstmt.executeBatch();
            for (int result : results) {
                if (result > 0) {
                    savedCount++;
                }
            }
            
            System.out.println("뉴스 기사 배치 저장 완료: " + savedCount + "/" + articles.size() + "건");
            
        } catch (Exception e) {
            System.err.println("뉴스 기사 배치 저장 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt);
        }
        
        return savedCount;
    }
    
    /**
     * 키워드로 관련 뉴스 기사 검색
     */
    public List<NewsArticleBean> getRelatedArticles(String[] keywords, int limit) {
        List<NewsArticleBean> articles = new ArrayList<>();
        
        if (keywords == null || keywords.length == 0) {
            return articles;
        }
        
        StringBuilder sql = new StringBuilder("SELECT * FROM news_articles WHERE ");
        List<String> conditions = new ArrayList<>();
        
        for (String keyword : keywords) {
            conditions.add("(title LIKE ? OR content LIKE ? OR keywords LIKE ?)");
        }
        
        sql.append(String.join(" OR ", conditions));
        sql.append(" ORDER BY created_at DESC LIMIT ?");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            for (String keyword : keywords) {
                String keywordLike = "%" + keyword + "%";
                pstmt.setString(paramIndex++, keywordLike);
                pstmt.setString(paramIndex++, keywordLike);
                pstmt.setString(paramIndex++, keywordLike);
            }
            pstmt.setInt(paramIndex, limit);
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                NewsArticleBean article = createNewsArticleFromResultSet(rs);
                articles.add(article);
            }
            
            System.out.println("관련 뉴스 기사 " + articles.size() + "건 조회 완료");
            
        } catch (Exception e) {
            System.err.println("관련 뉴스 기사 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt, rs);
        }
        
        return articles;
    }
    
    /**
     * 키워드 추출 로그 저장
     */
    public boolean saveKeywordExtraction(String sourceUrl, List<String> keywords, String method) {
        String sql = "INSERT INTO keyword_extractions (source_url, extracted_keywords, extraction_method) VALUES (?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            String keywordsStr = String.join(",", keywords);
            
            pstmt.setString(1, sourceUrl);
            pstmt.setString(2, keywordsStr);
            pstmt.setString(3, method);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                System.out.println("키워드 추출 로그 저장 성공");
                return true;
            }
            
        } catch (Exception e) {
            System.err.println("키워드 추출 로그 저장 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt);
        }
        
        return false;
    }
    
    /**
     * 뉴스 기사 테이블 초기화
     */
    public boolean initializeNewsTable() {
        String createNewsTable = "CREATE TABLE IF NOT EXISTS news_articles (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "title TEXT NOT NULL," +
                "content TEXT," +
                "url VARCHAR(1000)," +
                "published_date VARCHAR(50)," +
                "source VARCHAR(200)," +
                "view_count INT DEFAULT 0," +
                "keywords TEXT," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "UNIQUE INDEX idx_url (url(255))," +
                "INDEX idx_keywords (keywords(100))," +
                "INDEX idx_created_at (created_at)," +
                "INDEX idx_source (source)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        Connection conn = null;
        Statement stmt = null;
        
        try {
            conn = dbMgr.getConnection();
            stmt = conn.createStatement();
            
            stmt.executeUpdate(createNewsTable);
            System.out.println("news_articles 테이블 초기화 완료");
            return true;
            
        } catch (Exception e) {
            System.err.println("뉴스 테이블 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, stmt);
        }
        
        return false;
    }
    
    /**
     * 키워드 추출 테이블 초기화
     */
    public boolean initializeKeywordTable() {
        String createKeywordTable = "CREATE TABLE IF NOT EXISTS keyword_extractions (" +
                "id INT AUTO_INCREMENT PRIMARY KEY," +
                "source_url VARCHAR(1000) NOT NULL," +
                "extracted_keywords TEXT," +
                "extraction_method VARCHAR(50)," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "INDEX idx_source_url (source_url(200))," +
                "INDEX idx_created_at (created_at)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        Connection conn = null;
        Statement stmt = null;
        
        try {
            conn = dbMgr.getConnection();
            stmt = conn.createStatement();
            
            stmt.executeUpdate(createKeywordTable);
            System.out.println("keyword_extractions 테이블 초기화 완료");
            return true;
            
        } catch (Exception e) {
            System.err.println("키워드 테이블 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, stmt);
        }
        
        return false;
    }
    
    /**
     * ResultSet으로부터 NewsArticleBean 객체 생성
     */
    private NewsArticleBean createNewsArticleFromResultSet(ResultSet rs) throws SQLException {
        NewsArticleBean article = new NewsArticleBean();
        
        article.setId(rs.getInt("id"));
        article.setTitle(rs.getString("title"));
        article.setContent(rs.getString("content"));
        article.setUrl(rs.getString("url"));
        article.setPublishedDate(rs.getString("published_date"));
        article.setSource(rs.getString("source"));
        article.setViewCount(rs.getInt("view_count"));
        article.setKeywords(rs.getString("keywords"));
        article.setCreatedAt(rs.getTimestamp("created_at"));
        
        return article;
    }
}
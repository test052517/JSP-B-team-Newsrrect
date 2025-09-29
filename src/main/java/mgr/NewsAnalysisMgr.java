package mgr;

import beans.AnalysisResultBean;
import beans.NewsArticleBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

/**
 * 뉴스 분석 결과를 관리하는 매니저 클래스 (DBConnectionMgr 사용)
 */
public class NewsAnalysisMgr {
    
    private DBConnectionMgr dbMgr = DBConnectionMgr.getInstance();
    
    /**
     * 분석 결과를 데이터베이스에 저장
     */
    public int saveAnalysisResult(AnalysisResultBean analysisResult) {
        String sql = "INSERT INTO analysis_results (original_url, extracted_keywords, related_articles_count, " +
                    "summary, reliability_score, analysis_details, sentiment_analysis, processing_time) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            pstmt.setString(1, analysisResult.getOriginalUrl());
            pstmt.setString(2, analysisResult.getExtractedKeywords());
            pstmt.setInt(3, analysisResult.getRelatedArticlesCount());
            pstmt.setString(4, analysisResult.getSummary());
            pstmt.setDouble(5, analysisResult.getReliabilityScore());
            pstmt.setString(6, analysisResult.getAnalysisDetails());
            pstmt.setString(7, analysisResult.getSentimentAnalysis());
            pstmt.setInt(8, analysisResult.getProcessingTime());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    int generatedId = rs.getInt(1);
                    System.out.println("분석 결과 저장 성공. ID: " + generatedId);
                    return generatedId;
                }
            }
            
        } catch (Exception e) {
            System.err.println("분석 결과 저장 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt, rs);
        }
        
        return -1;
    }
    
    /**
     * 분석 기록 조회 (페이징)
     */
    public List<AnalysisResultBean> getAnalysisHistory(int limit, int offset) {
        List<AnalysisResultBean> results = new ArrayList<>();
        String sql = "SELECT * FROM analysis_results ORDER BY created_at DESC LIMIT ? OFFSET ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                AnalysisResultBean result = createAnalysisResultFromResultSet(rs);
                results.add(result);
            }
            
            System.out.println("분석 기록 " + results.size() + "건 조회 완료");
            
        } catch (Exception e) {
            System.err.println("분석 기록 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt, rs);
        }
        
        return results;
    }
    
    /**
     * ID로 특정 분석 결과 조회
     */
    public AnalysisResultBean getAnalysisById(int id) {
        String sql = "SELECT * FROM analysis_results WHERE id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setInt(1, id);
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                AnalysisResultBean result = createAnalysisResultFromResultSet(rs);
                System.out.println("분석 결과 조회 성공. ID: " + id);
                return result;
            }
            
        } catch (Exception e) {
            System.err.println("분석 결과 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt, rs);
        }
        
        return null;
    }
    
    /**
     * 통계 정보 조회
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        Connection conn = null;
        
        try {
            conn = dbMgr.getConnection();
            
            // 전체 분석 수
            String totalSql = "SELECT COUNT(*) as total FROM analysis_results";
            PreparedStatement pstmt1 = conn.prepareStatement(totalSql);
            ResultSet rs1 = pstmt1.executeQuery();
            if (rs1.next()) {
                stats.put("totalAnalyses", rs1.getInt("total"));
            }
            dbMgr.freeConnection(null, pstmt1, rs1);
            
            // 평균 신뢰도
            String avgSql = "SELECT AVG(reliability_score) as avg_score FROM analysis_results";
            PreparedStatement pstmt2 = conn.prepareStatement(avgSql);
            ResultSet rs2 = pstmt2.executeQuery();
            if (rs2.next()) {
                stats.put("averageReliability", Math.round(rs2.getDouble("avg_score") * 10.0) / 10.0);
            }
            dbMgr.freeConnection(null, pstmt2, rs2);
            
            // 신뢰도별 분포
            String distributionSql = "SELECT " +
                "SUM(CASE WHEN reliability_score >= 80 THEN 1 ELSE 0 END) as high," +
                "SUM(CASE WHEN reliability_score >= 60 AND reliability_score < 80 THEN 1 ELSE 0 END) as medium," +
                "SUM(CASE WHEN reliability_score < 60 THEN 1 ELSE 0 END) as low " +
                "FROM analysis_results";
                
            PreparedStatement pstmt3 = conn.prepareStatement(distributionSql);
            ResultSet rs3 = pstmt3.executeQuery();
            if (rs3.next()) {
                Map<String, Integer> distribution = new HashMap<>();
                distribution.put("high", rs3.getInt("high"));
                distribution.put("medium", rs3.getInt("medium"));
                distribution.put("low", rs3.getInt("low"));
                stats.put("reliabilityDistribution", distribution);
            }
            dbMgr.freeConnection(null, pstmt3, rs3);
            
            // 오늘 분석 수
            String todaySql = "SELECT COUNT(*) as today_count FROM analysis_results WHERE DATE(created_at) = CURDATE()";
            PreparedStatement pstmt4 = conn.prepareStatement(todaySql);
            ResultSet rs4 = pstmt4.executeQuery();
            if (rs4.next()) {
                stats.put("todayAnalyses", rs4.getInt("today_count"));
            }
            dbMgr.freeConnection(null, pstmt4, rs4);
            
            System.out.println("통계 정보 조회 완료");
            
        } catch (Exception e) {
            System.err.println("통계 정보 조회 실패: " + e.getMessage());
            e.printStackTrace();
            // 기본값 설정
            stats.put("totalAnalyses", 0);
            stats.put("averageReliability", 0.0);
            Map<String, Integer> defaultDist = new HashMap<>();
            defaultDist.put("high", 0);
            defaultDist.put("medium", 0);
            defaultDist.put("low", 0);
            stats.put("reliabilityDistribution", defaultDist);
            stats.put("todayAnalyses", 0);
        } finally {
            if (conn != null) {
                dbMgr.freeConnection(conn);
            }
        }
        
        return stats;
    }
    
    /**
     * URL로 기존 분석 결과 검색
     */
    public AnalysisResultBean findByUrl(String url) {
        String sql = "SELECT * FROM analysis_results WHERE original_url = ? ORDER BY created_at DESC LIMIT 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = dbMgr.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, url);
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return createAnalysisResultFromResultSet(rs);
            }
            
        } catch (Exception e) {
            System.err.println("URL 기반 분석 결과 조회 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, pstmt, rs);
        }
        
        return null;
    }
    
    /**
     * ResultSet으로부터 AnalysisResultBean 객체 생성
     */
    private AnalysisResultBean createAnalysisResultFromResultSet(ResultSet rs) throws SQLException {
        AnalysisResultBean result = new AnalysisResultBean();
        
        result.setId(rs.getInt("id"));
        result.setOriginalUrl(rs.getString("original_url"));
        result.setExtractedKeywords(rs.getString("extracted_keywords"));
        result.setRelatedArticlesCount(rs.getInt("related_articles_count"));
        result.setSummary(rs.getString("summary"));
        result.setReliabilityScore(rs.getDouble("reliability_score"));
        result.setAnalysisDetails(rs.getString("analysis_details"));
        result.setSentimentAnalysis(rs.getString("sentiment_analysis"));
        result.setProcessingTime(rs.getInt("processing_time"));
        result.setCreatedAt(rs.getTimestamp("created_at"));
        
        return result;
    }
    
    /**
     * 데이터베이스 테이블 초기화
     */
    public boolean initializeDatabase() {
        String createAnalysisResultsTable = "CREATE TABLE IF NOT EXISTS analysis_results (" +
            "id INT AUTO_INCREMENT PRIMARY KEY," +
            "original_url VARCHAR(1000) NOT NULL," +
            "extracted_keywords TEXT," +
            "related_articles_count INT DEFAULT 0," +
            "summary TEXT," +
            "reliability_score DECIMAL(5,2) DEFAULT 0.00," +
            "analysis_details TEXT," +
            "sentiment_analysis TEXT," +
            "processing_time INT DEFAULT 0," +
            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "INDEX idx_original_url (original_url(200))," +
            "INDEX idx_created_at (created_at)," +
            "INDEX idx_reliability_score (reliability_score)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
        
        Connection conn = null;
        Statement stmt = null;
        
        try {
            conn = dbMgr.getConnection();
            stmt = conn.createStatement();
            
            stmt.executeUpdate(createAnalysisResultsTable);
            System.out.println("analysis_results 테이블 초기화 완료");
            return true;
            
        } catch (Exception e) {
            System.err.println("테이블 초기화 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dbMgr.freeConnection(conn, stmt);
        }
        
        return false;
    }
}
package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import beans.PostReportBean;
import beans.postReportUserBean;

public class PostReportMgr {
    private DBConnectionMgr pool;
    private static final int REPORT_THRESHOLD = 5; // 신고 상태 변경 기준 횟수

    public PostReportMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    /**
     * 게시글 신고 접수
     */
    public boolean insertPostReport(PostReportBean report) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = pool.getConnection("user");
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 1. 신고 내용 삽입
            String sql = "INSERT INTO post_report (post_id, reporter_id, reason) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, report.getPostId());
            pstmt.setInt(2, report.getReporterId());
            pstmt.setString(3, report.getReason());
            
            int count = pstmt.executeUpdate();
            
            if (count == 1) {
                // 2. 신고 접수 성공 시 게시글의 report_count 업데이트 및 상태 확인
                updatePostReportCountAndStatus(conn, report.getPostId());
                result = true;
                conn.commit(); // 모든 작업 성공 시 트랜잭션 완료
            } else {
                conn.rollback(); // 실패 시 롤백
            }
            
        } catch(Exception e) {
            try {
                if (conn != null) conn.rollback(); // 예외 발생 시 롤백
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
        
        return result;
    }
    
    /**
     * 게시글 신고 횟수 업데이트 및 기준 충족 시 상태 변경 (트랜잭션 내부용)
     */
    private void updatePostReportCountAndStatus(Connection conn, int postId) throws Exception {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // 1. 신고 횟수 1 증가
            String updateSql = "UPDATE post SET report_count = report_count + 1 WHERE post_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();

            // 2. 현재 신고 횟수 확인
            String checkSql = "SELECT report_count FROM post WHERE post_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int currentReportCount = rs.getInt("report_count");
                
                // 3. 신고 횟수가 기준을 넘으면 상태를 '신고 처리 중'으로 변경
                if (currentReportCount >= REPORT_THRESHOLD) {
                    String statusSql = "UPDATE post SET status = '신고 처리 중' WHERE post_id = ?";
                    pstmt = conn.prepareStatement(statusSql);
                    pstmt.setInt(1, postId);
                    pstmt.executeUpdate();
                }
            }
        } catch(Exception e) {
            throw e; // 예외를 호출한 쪽으로 던져서 트랜잭션 롤백 처리
        } finally {
            // Connection은 insertPostReport에서 관리하므로 여기서 닫지 않음
        }
    }
    
    /**
     * 게시글 중복 신고 체크
     */
    public boolean isDuplicatePostReport(int reporterId, int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean isDuplicate = false;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) FROM post_report " +
                        "WHERE reporter_id = ? AND post_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reporterId);
            pstmt.setInt(2, postId);
            rs = pstmt.executeQuery();
            
            if(rs.next() && rs.getInt(1) > 0) {
                isDuplicate = true;
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return isDuplicate;
    }
    
    /**
     * 게시글 신고 목록 조회 (관리자용)
     */
    public Vector<PostReportBean> getPostReports(int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostReportBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT * FROM post_report ORDER BY reportPost_id DESC LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostReportBean bean = new PostReportBean();
                bean.setReportPostId(rs.getInt("reportPost_id"));
                bean.setPostId(rs.getInt("post_id"));
                bean.setReporterId(rs.getInt("reporter_id"));
                bean.setReason(rs.getString("reason"));
                vlist.add(bean);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }
    
    /**
     * 게시글 신고 목록 조회 (사용자 정보 포함 - 관리자용)
     */
    public Vector<postReportUserBean> getPostReportsWithUser(int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<postReportUserBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT pr.reportPost_id, pr.post_id, pr.reporter_id, pr.reason, " +
                        "u.user_id, u.nickname " +
                        "FROM post_report pr " +
                        "JOIN user u ON pr.reporter_id = u.user_id " +
                        "ORDER BY pr.reportPost_id DESC LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                postReportUserBean bean = new postReportUserBean();
                bean.setReportPostId(rs.getInt("reportPost_id"));
                bean.setUserId(rs.getInt("user_id"));
                bean.setNickname(rs.getString("nickname"));
                vlist.add(bean);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }
    
    /**
     * 게시글 신고 총 개수 조회
     */
    public int getPostReportCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) FROM post_report";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                count = rs.getInt(1);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return count;
    }
}
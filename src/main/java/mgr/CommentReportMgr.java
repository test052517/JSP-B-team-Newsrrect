package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import beans.CommentReportBean;
import beans.commentReportUserBean;

public class CommentReportMgr {
    private DBConnectionMgr pool;
    private static final int REPORT_THRESHOLD = 5; // 신고 상태 변경 기준 횟수

    public CommentReportMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    /**
     * 댓글 신고 접수
     */
    public boolean insertCommentReport(CommentReportBean report) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        try {
            conn = pool.getConnection("user");
            conn.setAutoCommit(false); // 트랜잭션 시작
            
            // 1. 신고 내용 삽입
            String sql = "INSERT INTO comment_report (comment_id, reporter_id, reason) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, report.getCommentId());
            pstmt.setInt(2, report.getReporterId());
            pstmt.setString(3, report.getReason());
            
            int count = pstmt.executeUpdate();

            if (count == 1) {
                // 2. 신고 접수 성공 시 댓글의 report_count 업데이트 및 상태 확인
                updateCommentReportCountAndStatus(conn, report.getCommentId());
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
     * 댓글 신고 횟수 업데이트 및 기준 충족 시 상태 변경 (트랜잭션 내부용)
     */
    private void updateCommentReportCountAndStatus(Connection conn, int commentId) throws Exception {
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 1. 신고 횟수 1 증가
            String updateSql = "UPDATE comment SET report_count = report_count + 1 WHERE comment_id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, commentId);
            pstmt.executeUpdate();

            // 2. 현재 신고 횟수 확인
            String checkSql = "SELECT report_count FROM comment WHERE comment_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, commentId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int currentReportCount = rs.getInt("report_count");
                
                // 3. 신고 횟수가 기준을 넘으면 상태를 '신고 처리 중'으로 변경
                if (currentReportCount >= REPORT_THRESHOLD) {
                    String statusSql = "UPDATE comment SET status = '신고 처리 중' WHERE comment_id = ?";
                    pstmt = conn.prepareStatement(statusSql);
                    pstmt.setInt(1, commentId);
                    pstmt.executeUpdate();
                }
            }
        } catch(Exception e) {
            throw e; // 예외를 호출한 쪽으로 던져서 트랜잭션 롤백 처리
        } finally {
            // Connection은 insertCommentReport에서 관리하므로 여기서 닫지 않음
        }
    }
    
    /**
     * 댓글 중복 신고 체크
     */
    public boolean isDuplicateCommentReport(int reporterId, int commentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean isDuplicate = false;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) FROM comment_report " +
                        "WHERE reporter_id = ? AND comment_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reporterId);
            pstmt.setInt(2, commentId);
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
     * 댓글 신고 목록 조회 (관리자용)
     */
    public Vector<CommentReportBean> getCommentReports(int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentReportBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT * FROM comment_report ORDER BY reportComment_id DESC LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                CommentReportBean bean = new CommentReportBean();
                bean.setReportCommentId(rs.getInt("reportComment_id"));
                bean.setCommentId(rs.getInt("comment_id"));
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
     * 댓글 신고 목록 조회 (사용자 정보 포함 - 관리자용)
     */
    public Vector<commentReportUserBean> getCommentReportsWithUser(int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<commentReportUserBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT cr.reportComment_id, cr.comment_id, cr.reporter_id, cr.reason, " +
                        "u.user_id, u.nickname " +
                        "FROM comment_report cr " +
                        "JOIN user u ON cr.reporter_id = u.user_id " +
                        "ORDER BY cr.reportComment_id DESC LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                commentReportUserBean bean = new commentReportUserBean();
                bean.setReportCommentId(rs.getInt("reportComment_id"));
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
     * 댓글 신고 총 개수 조회
     */
    public int getCommentReportCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) FROM comment_report";
            
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
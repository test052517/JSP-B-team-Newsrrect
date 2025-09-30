package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class DeleteMgr {

    private DBConnectionMgr pool;

    public DeleteMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    // 게시글 삭제 처리 (상태 변경 및 신고 기록 삭제)
    public boolean deletePost(int reportPostId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean flag = false;

        try {
            conn = pool.getConnection("user");
            conn.setAutoCommit(false); // 트랜잭션 시작

            // 1. 신고 ID로 원본 게시글 ID(post_id) 가져오기
            String getInfoSql = "SELECT post_id FROM post_report WHERE reportPost_id = ?";
            pstmt = conn.prepareStatement(getInfoSql);
            pstmt.setInt(1, reportPostId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int postId = rs.getInt("post_id");

                // 2. 원본 post 테이블의 status를 '삭제'로 변경
                String updateSql = "UPDATE post SET status = '삭제' WHERE post_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, postId);
                pstmt.executeUpdate();

                // 3. post_report 테이블에서 해당 신고 내역 삭제
                String deleteReportSql = "DELETE FROM post_report WHERE reportPost_id = ?";
                pstmt = conn.prepareStatement(deleteReportSql);
                pstmt.setInt(1, reportPostId);
                
                if (pstmt.executeUpdate() == 1) {
                    flag = true;
                    conn.commit(); // 모든 작업 성공 시 커밋
                } else {
                    conn.rollback();
                }
            }
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback(); // 오류 발생 시 롤백
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return flag;
    }

    // 댓글 삭제 처리 (상태 변경 및 신고 기록 삭제)
    public boolean deleteComment(int reportCommentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean flag = false;

        try {
            conn = pool.getConnection("user");
            conn.setAutoCommit(false); // 트랜잭션 시작

            // 1. 신고 ID로 원본 댓글 ID(comment_id) 가져오기
            String getInfoSql = "SELECT comment_id FROM comment_report WHERE reportComment_id = ?";
            pstmt = conn.prepareStatement(getInfoSql);
            pstmt.setInt(1, reportCommentId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int commentId = rs.getInt("comment_id");

                // 2. 원본 comment 테이블의 status를 '삭제'로 변경
                String updateSql = "UPDATE comment SET status = '삭제' WHERE comment_id = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setInt(1, commentId);
                pstmt.executeUpdate();

                // 3. comment_report 테이블에서 해당 신고 내역 삭제
                String deleteReportSql = "DELETE FROM comment_report WHERE reportComment_id = ?";
                pstmt = conn.prepareStatement(deleteReportSql);
                pstmt.setInt(1, reportCommentId);
                
                if (pstmt.executeUpdate() == 1) {
                    flag = true;
                    conn.commit(); // 모든 작업 성공 시 커밋
                } else {
                    conn.rollback();
                }
            }
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback(); // 오류 발생 시 롤백
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return flag;
    }
}
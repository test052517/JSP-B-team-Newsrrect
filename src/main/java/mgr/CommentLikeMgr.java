package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import beans.CommentLikeBean;

public class CommentLikeMgr {

    private DBConnectionMgr pool;

    public CommentLikeMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public boolean insertLike(int commentId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean flag = false;
        
        // created_at 컬럼에 DB의 현재 시간을 넣도록 NOW() 함수 추가
        String sql = "INSERT INTO Comment_like (comment_id, like_id, created_at) VALUES (?, ?, NOW())";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);
            
            if (pstmt.executeUpdate() == 1) {
                flag = true;
            }
        } catch (Exception e) {
            System.err.println("추천 기록 저장 실패 (중복이거나 DB 오류): " + e.getMessage());
        } finally {
            pool.freeConnection(conn, pstmt);
        }
        return flag;
    }

    public boolean isLiked(int commentId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean isLiked = false;
        
        String sql = "SELECT COUNT(*) FROM Comment_like WHERE comment_id = ? AND like_id = ?";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);
            rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                isLiked = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return isLiked;
    }
    
    public boolean deleteLike(int commentId, int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean flag = false;
        
        String sql = "DELETE FROM Comment_like WHERE comment_id = ? AND like_id = ?";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            pstmt.setInt(2, userId);
            
            if (pstmt.executeUpdate() == 1) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
        return flag;
    }
}
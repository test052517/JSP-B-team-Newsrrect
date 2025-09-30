package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import beans.CommentBean;

public class CommentMgr {

    private DBConnectionMgr pool;

    public CommentMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public boolean insertComment(CommentBean commentBean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean flag = false;
        String sql = "INSERT INTO comment (post_id, user_id, type, layer, parent_comment_id, content, status, created_at, judgment) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentBean.getPost_id());
            pstmt.setInt(2, commentBean.getUser_id());
            pstmt.setString(3, commentBean.getType());
            pstmt.setInt(4, commentBean.getLayer());

            if (commentBean.getParent_comment_id() > 0) { 
                pstmt.setInt(5, commentBean.getParent_comment_id());
            } else {
                pstmt.setNull(5, java.sql.Types.INTEGER);
            }
            
            pstmt.setString(6, commentBean.getContent());
            pstmt.setString(7, commentBean.getStatus());
            pstmt.setString(8, commentBean.getCreated_at());
            pstmt.setString(9, commentBean.getJudgment()); // 판정 값 설정
            
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

    public Vector<CommentBean> getCommentList(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();
        String sql = "SELECT c.*, u.nickname " +
                     "FROM comment c JOIN user u ON c.user_id = u.user_id " +
                     "WHERE c.post_id = ? AND c.status = '공개' " +
                     "ORDER BY c.upvotes DESC, c.comment_id ASC"; // 추천순, 그 다음 시간순으로 정렬

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CommentBean bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setPost_id(rs.getInt("post_id"));
                bean.setUser_id(rs.getInt("user_id"));
                bean.setContent(rs.getString("content"));
                bean.setCreated_at(rs.getString("created_at"));
                bean.setNickname(rs.getString("nickname")); 
                bean.setJudgment(rs.getString("judgment"));
                bean.setUpvotes(rs.getInt("upvotes"));
                
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }
    
    public String getPostType(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String type = null;
        String sql = "SELECT type FROM post WHERE post_id = ?";
        
        try {
            conn = pool.getConnection("user"); 
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                type = rs.getString("type");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return type;
    }
}


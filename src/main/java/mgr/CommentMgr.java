package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
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

            String judgment = commentBean.getJudgment();
            if (judgment == null || judgment.trim().isEmpty()) {
                pstmt.setNull(9, Types.VARCHAR); 
            } else {
                pstmt.setString(9, judgment); 
            }
            
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

    // 부모 댓글만 가져오기 (layer = 0인 댓글들)
    public Vector<CommentBean> getCommentList(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();
        String sql = "SELECT c.*, u.nickname " +
                     "FROM comment c JOIN user u ON c.user_id = u.user_id " +
                     "WHERE c.post_id = ? AND c.status = '공개' AND c.layer = 0 " +
                     "ORDER BY c.upvotes DESC, c.comment_id ASC";

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
    
    // 특정 댓글의 답글들을 가져오기 (모든 layer의 대댓글들)
    public Vector<CommentBean> getReplyList(int parentCommentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();
        
        String sql = "SELECT c.*, u.nickname " +
                     "FROM comment c JOIN user u ON c.user_id = u.user_id " +
                     "WHERE c.parent_comment_id = ? AND c.status = '공개' " +
                     "ORDER BY c.comment_id ASC";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, parentCommentId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CommentBean bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setPost_id(rs.getInt("post_id"));
                bean.setUser_id(rs.getInt("user_id"));
                bean.setParent_comment_id(rs.getInt("parent_comment_id"));
                bean.setLayer(rs.getInt("layer"));
                bean.setContent(rs.getString("content"));
                bean.setCreated_at(rs.getString("created_at"));
                bean.setNickname(rs.getString("nickname"));
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
    
    // 대대댓글 지원을 위한 새로운 메소드
    public Vector<CommentBean> getAllRepliesRecursive(int parentCommentId) {
        Vector<CommentBean> allReplies = new Vector<>();
        Vector<CommentBean> directReplies = getReplyList(parentCommentId);
        
        for(CommentBean reply : directReplies) {
            allReplies.add(reply);
            // 재귀적으로 답글의 답글들도 가져오기
            Vector<CommentBean> subReplies = getAllRepliesRecursive(reply.getComment_id());
            allReplies.addAll(subReplies);
        }
        
        return allReplies;
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
    
    public boolean upvoteComment(int commentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean flag = false;
        String sql = "UPDATE comment SET upvotes = upvotes + 1 WHERE comment_id = ?";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);

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
 // 이 코드를 CommentMgr.java 클래스 내부에 추가하세요.

    /**
     * 댓글 추천수를 1 감소시키는 메소드 (추천 취소용)
     * @param commentId 추천수를 감소시킬 댓글의 ID
     * @return 성공 시 true, 실패 시 false
     */
    public boolean downvoteComment(int commentId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean flag = false;

        try {
            con = pool.getConnection("user");
            // 추천수가 0보다 클 때만 감소시키도록 조건을 추가하는 것이 좋습니다.
            String sql = "UPDATE comment SET upvotes = upvotes - 1 WHERE comment_id = ? AND upvotes > 0";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            
            int result = pstmt.executeUpdate();
            
            if (result == 1) {
                flag = true; // 쿼리 실행 후 1개의 행이 영향을 받았다면 성공
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return flag;
    }
    
}
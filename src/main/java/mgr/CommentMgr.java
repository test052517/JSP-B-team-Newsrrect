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
        String sql = "INSERT INTO comment (post_id, user_id, type, layer, parent_comment_id, content, status, created_at, judgment, attache) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

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
            
            String attache = commentBean.getAttache();
            if (attache == null || attache.trim().isEmpty()) {
                pstmt.setNull(10, Types.VARCHAR); 
            } else {
                pstmt.setString(10, attache); 
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

    public Vector<CommentBean> getCommentList(int postId) {
        // 최신순을 기본값으로 사용
        return getCommentList(postId, "latest"); 
    }
    
    public Vector<CommentBean> getCommentList(int postId, String sort) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();
        
        String orderByClause;
        if ("upvotes".equalsIgnoreCase(sort)) {
            orderByClause = "ORDER BY c.upvotes DESC, c.comment_id DESC"; 
        } else { 
            orderByClause = "ORDER BY c.comment_id DESC";
        }
        
        String sql = "SELECT c.*, c.upvotes, u.nickname, u.point, u.role " + // c.upvotes를 명시적으로 추가
                "FROM comment c JOIN user u ON c.user_id = u.user_id " +
                "WHERE c.post_id = ? AND c.status = '공개' AND c.layer = 0 " +
                orderByClause;

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
                bean.setPoint(rs.getInt("point")); 
                bean.setRole(rs.getString("role"));
                bean.setAttache(rs.getString("attache")); 
                
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }
    
    // 대댓글
    public Vector<CommentBean> getReplyList(int parentCommentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();
        
        String sql = "SELECT c.*, u.nickname, u.point, u.role " +
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
                bean.setPoint(rs.getInt("point"));
                bean.setRole(rs.getString("role"));
                bean.setAttache(rs.getString("attache")); 
                
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }
    
    public Vector<CommentBean> getAllRepliesRecursive(int parentCommentId) {
        Vector<CommentBean> allReplies = new Vector<>();
        Vector<CommentBean> directReplies = getReplyList(parentCommentId);
        
        for(CommentBean reply : directReplies) {
            allReplies.add(reply);
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

    public boolean downvoteComment(int commentId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean flag = false;

        try {
            con = pool.getConnection("user");
            String sql = "UPDATE comment SET upvotes = upvotes - 1 WHERE comment_id = ? AND upvotes > 0";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            
            int result = pstmt.executeUpdate();
            
            if (result == 1) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return flag;
    }
    
    public int getCommentOwnerId(int commentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int ownerId = 0;
        String sql = "SELECT user_id FROM comment WHERE comment_id = ?";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                ownerId = rs.getInt("user_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return ownerId;
    }
}

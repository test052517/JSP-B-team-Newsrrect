package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import beans.PostBean;

public class WatchUserPostMgr {

    private DBConnectionMgr pool;

    public WatchUserPostMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public int getTotalCount(String type, String keyField, String keyWord) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int totalCount = 0;
        String sql;

        try {
            conn = pool.getConnection("user");
            if (keyWord == null || keyWord.trim().isEmpty()) {
                sql = "SELECT COUNT(*) FROM post WHERE type = ? AND status = '공개'";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, type);
            } else {
                sql = "SELECT COUNT(*) FROM post p JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.type = ? AND p.status = '공개' AND " + keyField + " LIKE ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, type);
                pstmt.setString(2, "%" + keyWord.trim() + "%");
            }
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalCount = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return totalCount;
    }

    public Vector<PostBean> getPostList(String type, String keyField, String keyWord, int start, int count) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        String sql;

        try {
            conn = pool.getConnection("user");
            if (keyWord == null || keyWord.trim().isEmpty()) {
                sql = "SELECT p.*, u.nickname " +
                      "FROM post p JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.type = ? AND p.status = '공개' " +
                      "ORDER BY p.post_id DESC LIMIT ?, ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, type);
                pstmt.setInt(2, start);
                pstmt.setInt(3, count);
            } else {
                sql = "SELECT p.*, u.nickname " +
                      "FROM post p JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.type = ? AND p.status = '공개' AND " + keyField + " LIKE ? " +
                      "ORDER BY p.post_id DESC LIMIT ?, ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, type);
                pstmt.setString(2, "%" + keyWord.trim() + "%");
                pstmt.setInt(3, start);
                pstmt.setInt(4, count);
            }
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setUserId(rs.getInt("user_id"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }
}

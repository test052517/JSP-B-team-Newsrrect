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
    // ==================== [새로 추가된 메서드 1] ====================
    /**
     * 공지사항 게시글 목록을 가져오는 메서드
     * @return Vector<PostBean> 공지사항 목록
     */
    public Vector<PostBean> getVerificationNotices() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> noticeList = new Vector<>();
        // 공지사항은 priority가 0보다 큰 게시물로 가정
        String sql = "SELECT p.*, u.nickname " +
                     "FROM post p JOIN user u ON p.user_id = u.user_id " +
                     "WHERE p.type = '정보' AND p.status = '공개' AND p.priority > 0 " +
                     "ORDER BY p.priority DESC, p.post_id DESC";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setUserId(rs.getInt("user_id"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                // 필요한 다른 정보들도 여기서 set 할 수 있습니다.
                noticeList.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return noticeList;
    }

    // ==================== [새로 추가된 메서드 2] ====================
    /**
     * 일반 게시글의 총 개수를 가져오는 메서드 (공지사항 제외)
     * @param type 게시판 타입 (예: "정보")
     * @param keyField 검색 필드
     * @param keyWord 검색어
     * @return int 일반 게시글의 총 개수
     */
    public int getRegularPostCount(String type, String keyField, String keyWord) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int totalCount = 0;
        String sql;

        try {
            conn = pool.getConnection("user");
            // 일반 게시글은 priority가 0인 게시물로 가정
            String priorityCondition = " AND p.priority = 0 ";
            
            if (keyWord == null || keyWord.trim().isEmpty()) {
                sql = "SELECT COUNT(*) FROM post p WHERE p.type = ? AND p.status = '공개'" + priorityCondition;
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, type);
            } else {
                sql = "SELECT COUNT(*) FROM post p JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.type = ? AND p.status = '공개' AND " + keyField + " LIKE ?" + priorityCondition;
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

    // ==================== [새로 추가된 메서드 3] ====================
    /**
     * 일반 게시글 목록을 가져오는 메서드 (공지사항 제외, 페이징 및 검색 적용)
     * @param type 게시판 타입
     * @param keyField 검색 필드
     * @param keyWord 검색어
     * @param start 시작 인덱스
     * @param count 가져올 개수
     * @return Vector<PostBean> 일반 게시글 목록
     */
    public Vector<PostBean> getRegularPostList(String type, String keyField, String keyWord, int start, int count) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        String sql;

        try {
            conn = pool.getConnection("user");
            // 일반 게시글은 priority가 0인 게시물로 가정
            String priorityCondition = " AND p.priority = 0 ";
            
            if (keyWord == null || keyWord.trim().isEmpty()) {
                sql = "SELECT p.*, u.nickname " +
                      "FROM post p JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.type = ? AND p.status = '공개' " + priorityCondition +
                      "ORDER BY p.post_id DESC LIMIT ?, ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, type);
                pstmt.setInt(2, start);
                pstmt.setInt(3, count);
            } else {
                sql = "SELECT p.*, u.nickname " +
                      "FROM post p JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.type = ? AND p.status = '공개' AND " + keyField + " LIKE ? " + priorityCondition +
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
    
    
    public void increaseViewCount(int postId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        
        try {
            con = pool.getConnection("user");
            // viewCount 컬럼의 값을 1 증가시키는 UPDATE 쿼리
            sql = "UPDATE post SET view_count = view_count + 1 WHERE post_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, postId);
            pstmt.executeUpdate(); // 쿼리 실행
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }
    
    public PostBean getPost(int postId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = null;
        PostBean post = null;

        try {
            con = pool.getConnection("user");
            // post 테이블과 user 테이블을 JOIN하여 게시물 정보와 작성자 닉네임을 함께 조회
            sql = "SELECT p.*, u.nickname FROM post p "
                + "JOIN user u ON p.user_id = u.user_id "
                + "WHERE p.post_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setUserId(rs.getInt("user_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setStatus(rs.getString("status"));
                post.setViewCount(rs.getInt("view_count"));
                post.setCreatedAt(rs.getString("created_at"));
                post.setReportCount(rs.getInt("report_count"));
                post.setRecommandCount(rs.getInt("recommand_count"));
                post.setPriority(rs.getInt("priority"));
                
                // JOIN을 통해 가져온 작성자 닉네임을 PostBean에 설정
                post.setNickname(rs.getString("nickname")); 
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return post;
    }
    public Vector<PostBean> getNoticesByType(String type) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> noticeList = new Vector<>();
        // 공지사항은 priority가 0보다 큰 게시물로 가정
        String sql = "SELECT p.*, u.nickname " +
                     "FROM post p JOIN user u ON p.user_id = u.user_id " +
                     "WHERE p.type = ? AND p.status = '공개' AND p.priority > 0 " +
                     "ORDER BY p.priority DESC, p.post_id DESC";

        try {
            conn = pool.getConnection("user");
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, type); // 인자로 받은 type을 사용
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setUserId(rs.getInt("user_id"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                noticeList.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return noticeList;
    }

}

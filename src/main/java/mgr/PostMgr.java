package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Vector;
import beans.PostBean;

public class PostMgr {
    private DBConnectionMgr pool;

    public PostMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    /**
     * 새로운 게시글 생성
     * @param bean 게시글 정보를 담고 있는 PostBean 객체
     */
    public void createPost(PostBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        try {
            con = pool.getConnection("user");
            // priority 컬럼을 포함하여 INSERT SQL 문을 수정
            sql = "INSERT INTO post(user_id, type, title, content, status, view_count, created_at, report_count, recommand_count, priority,attache) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
            
            pstmt = con.prepareStatement(sql);
            
            pstmt.setInt(1, bean.getUserId());
            pstmt.setString(2, bean.getType());
            pstmt.setString(3, bean.getTitle());
            pstmt.setString(4, bean.getContent());
            pstmt.setString(5, bean.getStatus());
            pstmt.setInt(6, bean.getViewCount());
            pstmt.setString(7, bean.getCreatedAt());
            pstmt.setInt(8, bean.getReportCount());
            pstmt.setInt(9, bean.getRecommandCount());
            pstmt.setInt(10, bean.getPriority()); // priority 값 설정
            
            pstmt.setString(11,bean.getAttache() );
            
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }

    /**
     * 특정 게시글 상세 조회 (사용자 닉네임 포함)
     * @param postId 조회할 게시글의 ID
     * @return PostBean 객체
     */
    public PostBean getPostByPostID(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        PostBean bean = null;
        
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT p.*, u.nickname " +
                         "FROM post p " +
                         "JOIN user u ON p.user_id = u.user_id " +
                         "WHERE p.post_id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setUserId(rs.getInt("user_id"));
                bean.setType(rs.getString("type"));
                bean.setTitle(rs.getString("title"));
                bean.setContent(rs.getString("content"));
                bean.setStatus(rs.getString("status"));
                bean.setViewCount(rs.getInt("view_count"));
                bean.setCreatedAt(rs.getString("created_at"));
                bean.setReportCount(rs.getInt("report_count"));
                bean.setRecommandCount(rs.getInt("recommand_count"));
                if(hasColumn(rs, "attache"))bean.setAttache(rs.getString("attache"));
                // priority 컬럼이 DB에 존재한다고 가정
                if (hasColumn(rs, "priority")) {
                    bean.setPriority(rs.getInt("priority"));
                }
                bean.setNickname(rs.getString("nickname"));
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return bean;
    }

    /**
     * 특정 게시글 조회 (getPost 메서드 - AdminInfoWatch.jsp에서 사용)
     */
    public PostBean getPost(int postId) {
        return getPostByPostID(postId);
    }

    /**
     * 승인 대기 중인 게시글 목록 조회
     */
    public Vector<PostBean> getPendingPosts(int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT p.post_id, p.title, p.created_at, u.nickname " +
                         "FROM post p " +
                         "JOIN user u ON p.user_id = u.user_id " +
                         "WHERE p.type = '정보' AND p.status = '비공개' " +
                         "ORDER BY p.created_at DESC " +
                         "LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setCreatedAt(rs.getString("created_at"));
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
     * 승인 대기 게시글 총 개수
     */
    public int getPendingPostCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT COUNT(*) FROM post WHERE type = '정보' AND status = '비공개'";
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
    
    /**
     * 게시글 승인
     */
    public boolean approvePost(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean flag = false;
        
        try {
            conn = pool.getConnection("user");
            String sql = "UPDATE post SET status = '공개' WHERE post_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            
            int result = pstmt.executeUpdate();
            if(result == 1) flag = true;
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
        return flag;
    }
    
    /**
     * 게시글 거절 (상태를 '삭제'로 변경)
     */
    public boolean rejectPost(int postId, String reason) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean flag = false;
        
        try {
            conn = pool.getConnection("user");
            String sql = "UPDATE post SET status = '삭제' WHERE post_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            
            int result = pstmt.executeUpdate();
            if(result == 1) flag = true;
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt);
        }
        return flag;
    }
    
    /**
     * 승인 대기 게시글 검색
     */
    public Vector<PostBean> searchPendingPosts(String searchType, String keyword, int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            String sql = "";
            
            String baseQuery = "SELECT p.post_id, p.title, p.created_at, u.nickname " +
                               "FROM post p JOIN user u ON p.user_id = u.user_id " +
                               "WHERE p.type = '정보' AND p.status = '비공개' AND ";
            String orderLimit = " ORDER BY p.created_at DESC LIMIT ?, ?";

            if("title".equals(searchType)) {
                sql = baseQuery + "p.title LIKE ?" + orderLimit;
            } else if("author".equals(searchType)) {
                sql = baseQuery + "u.nickname LIKE ?" + orderLimit;
            } else { // 'all' or default
                sql = baseQuery + "(p.title LIKE ? OR u.nickname LIKE ?)" + orderLimit;
            }
            
            pstmt = conn.prepareStatement(sql);
            
            if("title".equals(searchType) || "author".equals(searchType)) {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setInt(2, start);
                pstmt.setInt(3, limit);
            } else {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setInt(3, start);
                pstmt.setInt(4, limit);
            }
            
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setCreatedAt(rs.getString("created_at"));
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
     * 검색된 승인 대기 게시글의 총 개수
     */
    public int getSearchPendingPostCount(String searchType, String keyword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            String sql = "";
            String baseQuery = "SELECT COUNT(*) " +
                               "FROM post p JOIN user u ON p.user_id = u.user_id " +
                               "WHERE p.type = '정보' AND p.status = '비공개' AND ";

            if("title".equals(searchType)) {
                sql = baseQuery + "p.title LIKE ?";
            } else if("author".equals(searchType)) {
                sql = baseQuery + "u.nickname LIKE ?";
            } else {
                sql = baseQuery + "(p.title LIKE ? OR u.nickname LIKE ?)";
            }
            
            pstmt = conn.prepareStatement(sql);
            
            if("title".equals(searchType) || "author".equals(searchType)) {
                pstmt.setString(1, "%" + keyword + "%");
            } else {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
            }
            
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

    /**
     * 공개된 게시글 목록 조회 (페이징)
     */
    public Vector<PostBean> getPublicPosts(int start, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT p.post_id, p.user_id, p.type, p.title, p.content, " +
                        "p.view_count, p.report_count, p.created_at, p.recommand_count, " +
                        "u.nickname " +
                        "FROM post p " +
                        "JOIN user u ON p.user_id = u.user_id " +
                        "WHERE p.type = '정보' AND p.status = '공개' " +
                        "ORDER BY p.created_at DESC " +
                        "LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, pageSize);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setUserId(rs.getInt("user_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setViewCount(rs.getInt("view_count"));
                post.setReportCount(rs.getInt("report_count"));
                post.setCreatedAt(rs.getString("created_at"));
                post.setRecommandCount(rs.getInt("recommand_count"));
                post.setNickname(rs.getString("nickname"));
                vlist.add(post);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }

    /**
     * 공개된 게시글 총 개수 조회
     */
    public int getPublicPostCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) as cnt FROM post " +
                        "WHERE type = '정보' AND status = '공개'";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                count = rs.getInt("cnt");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * 공개된 게시글 검색 (페이징)
     */
    public Vector<PostBean> searchPublicPosts(String searchType, String keyword, int start, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT p.post_id, p.user_id, p.type, p.title, p.content, " +
                        "p.view_count, p.report_count, p.created_at, p.recommand_count, " +
                        "u.nickname " +
                        "FROM post p " +
                        "JOIN user u ON p.user_id = u.user_id " +
                        "WHERE p.type = '정보' AND p.status = '공개' AND ";
            
            if("title".equals(searchType)) {
                sql += "p.title LIKE ? ";
            } else if("content".equals(searchType)) {
                sql += "p.content LIKE ? ";
            } else if("author".equals(searchType)) {
                sql += "u.nickname LIKE ? ";
            } else { // 'all' or default
                sql += "(p.title LIKE ? OR p.content LIKE ? OR u.nickname LIKE ?) ";
            }
            
            sql += "ORDER BY p.created_at DESC LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            
            if("title".equals(searchType) || "content".equals(searchType) || "author".equals(searchType)) {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setInt(2, start);
                pstmt.setInt(3, pageSize);
            } else {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setString(3, "%" + keyword + "%");
                pstmt.setInt(4, start);
                pstmt.setInt(5, pageSize);
            }
            
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setUserId(rs.getInt("user_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setViewCount(rs.getInt("view_count"));
                post.setReportCount(rs.getInt("report_count"));
                post.setCreatedAt(rs.getString("created_at"));
                post.setRecommandCount(rs.getInt("recommand_count"));
                post.setNickname(rs.getString("nickname"));
                vlist.add(post);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }

    /**
     * 검색된 공개 게시글의 총 개수
     */
    public int getSearchPublicPostCount(String searchType, String keyword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) as cnt " +
                        "FROM post p JOIN user u ON p.user_id = u.user_id " +
                        "WHERE p.type = '정보' AND p.status = '공개' AND ";

            if("title".equals(searchType)) {
                sql += "p.title LIKE ?";
            } else if("content".equals(searchType)) {
                sql += "p.content LIKE ?";
            } else if("author".equals(searchType)) {
                sql += "u.nickname LIKE ?";
            } else {
                sql += "(p.title LIKE ? OR p.content LIKE ? OR u.nickname LIKE ?)";
            }
            
            pstmt = conn.prepareStatement(sql);
            
            if("title".equals(searchType) || "content".equals(searchType) || "author".equals(searchType)) {
                pstmt.setString(1, "%" + keyword + "%");
            } else {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setString(3, "%" + keyword + "%");
            }
            
            rs = pstmt.executeQuery();
            if(rs.next()) {
                count = rs.getInt("cnt");
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return count;
    }

    /**
     * ResultSet에 특정 컬럼이 있는지 확인하는 유틸리티 메소드
     */
    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    /**
     * 커뮤니티 게시글 목록 조회 (페이징)
     */
    public Vector<PostBean> getCommunityPosts(int start, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT p.post_id, p.user_id, p.type, p.title, p.content, " +
                        "p.view_count, p.report_count, p.created_at, p.recommand_count, " +
                        "u.nickname " +
                        "FROM post p " +
                        "JOIN user u ON p.user_id = u.user_id " +
                        "WHERE p.type = '소통' AND p.status = '공개' " +
                        "ORDER BY p.created_at DESC " +
                        "LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, pageSize);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setUserId(rs.getInt("user_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setViewCount(rs.getInt("view_count"));
                post.setReportCount(rs.getInt("report_count"));
                post.setCreatedAt(rs.getString("created_at"));
                post.setRecommandCount(rs.getInt("recommand_count"));
                post.setNickname(rs.getString("nickname"));
                vlist.add(post);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }

    /**
     * 커뮤니티 게시글 총 개수 조회
     */
    public int getCommunityPostCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) as cnt FROM post " +
                        "WHERE type = '소통' AND status = '공개'";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                count = rs.getInt("cnt");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * 커뮤니티 게시글 검색 (페이징)
     */
    public Vector<PostBean> searchCommunityPosts(String searchType, String keyword, int start, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT p.post_id, p.user_id, p.type, p.title, p.content, " +
                        "p.view_count, p.report_count, p.created_at, p.recommand_count, " +
                        "u.nickname " +
                        "FROM post p " +
                        "JOIN user u ON p.user_id = u.user_id " +
                        "WHERE p.type = '소통' AND p.status = '공개' AND ";
            
            if("title".equals(searchType)) {
                sql += "p.title LIKE ? ";
            } else if("content".equals(searchType)) {
                sql += "p.content LIKE ? ";
            } else if("author".equals(searchType)) {
                sql += "u.nickname LIKE ? ";
            } else { // 'all' or default
                sql += "(p.title LIKE ? OR p.content LIKE ? OR u.nickname LIKE ?) ";
            }
            
            sql += "ORDER BY p.created_at DESC LIMIT ?, ?";
            
            pstmt = conn.prepareStatement(sql);
            
            if("title".equals(searchType) || "content".equals(searchType) || "author".equals(searchType)) {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setInt(2, start);
                pstmt.setInt(3, pageSize);
            } else {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setString(3, "%" + keyword + "%");
                pstmt.setInt(4, start);
                pstmt.setInt(5, pageSize);
            }
            
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setUserId(rs.getInt("user_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setViewCount(rs.getInt("view_count"));
                post.setReportCount(rs.getInt("report_count"));
                post.setCreatedAt(rs.getString("created_at"));
                post.setRecommandCount(rs.getInt("recommand_count"));
                post.setNickname(rs.getString("nickname"));
                vlist.add(post);
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }

    /**
     * 검색된 커뮤니티 게시글의 총 개수
     */
    public int getSearchCommunityPostCount(String searchType, String keyword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT COUNT(*) as cnt " +
                        "FROM post p JOIN user u ON p.user_id = u.user_id " +
                        "WHERE p.type = '소통' AND p.status = '공개' AND ";

            if("title".equals(searchType)) {
                sql += "p.title LIKE ?";
            } else if("content".equals(searchType)) {
                sql += "p.content LIKE ?";
            } else if("author".equals(searchType)) {
                sql += "u.nickname LIKE ?";
            } else {
                sql += "(p.title LIKE ? OR p.content LIKE ? OR u.nickname LIKE ?)";
            }
            
            pstmt = conn.prepareStatement(sql);
            
            if("title".equals(searchType) || "content".equals(searchType) || "author".equals(searchType)) {
                pstmt.setString(1, "%" + keyword + "%");
            } else {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setString(3, "%" + keyword + "%");
            }
            
            rs = pstmt.executeQuery();
            if(rs.next()) {
                count = rs.getInt("cnt");
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return count;
    }
    
    /**
     * 커뮤니티 게시글 최신 6개 
     */
    public Vector<PostBean> newListPosts(String type) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT * FROM post WHERE type = ? AND status = '공개' order by post_id desc limit 6";
           
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, type);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setCreatedAt(rs.getString("created_at"));
                vlist.add(post);
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }

    /**
     * 오늘의 인기 검증 게시물 카드(조회수 높은 순으로 6개, 조회수 동일하면 post_id 순서대로)
     */
    public Vector<PostBean> todayInfoCards(String type) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection("user");
            
            String sql = "SELECT * FROM post WHERE type = ? AND status = '공개' order by view_count desc limit 6";
           
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, type);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                PostBean post = new PostBean();
                post.setPostId(rs.getInt("post_id"));
                post.setType(rs.getString("type"));
                post.setTitle(rs.getString("title"));
                post.setContent(rs.getString("content"));
                post.setViewCount(rs.getInt("view_count"));
                vlist.add(post);
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return vlist;
    }
    
    public int createPostAndGetId(PostBean postBean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int generatedId = 0;
        
        try {
            conn = pool.getConnection("user");
            String sql = "INSERT INTO post (user_id, type, title, content, status, view_count, created_at, report_count, recommand_count, priority, attache) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            pstmt.setInt(1, postBean.getUserId());
            pstmt.setString(2, postBean.getType());
            pstmt.setString(3, postBean.getTitle());
            pstmt.setString(4, postBean.getContent());
            pstmt.setString(5, postBean.getStatus());
            pstmt.setInt(6, postBean.getViewCount());
            pstmt.setString(7, postBean.getCreatedAt());
            pstmt.setInt(8, postBean.getReportCount());
            pstmt.setInt(9, postBean.getRecommandCount());
            pstmt.setInt(10, postBean.getPriority());
            pstmt.setString(11, postBean.getAttache());
            
            pstmt.executeUpdate();
            
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }

        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return generatedId;
    }
    
    /**
     * 오늘 업로드 정보 검증글 개수
     */
    public int getTodayInfoCount(String type) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = pool.getConnection("user");

            String sql = "SELECT COUNT(*) AS cnt FROM post WHERE type = ? AND status = '공개' and DATE(created_at) = CURDATE()";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, type);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return count;
    }
    
    /**
     * 전체 업로드 정보 검증글 개수
     */
    public int getInfoCount(String type) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = pool.getConnection("user");

            String sql = "SELECT COUNT(*) AS cnt FROM post WHERE type = ? AND status = '공개'";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, type);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt("cnt");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return count;
    }
    // JSP 파일에 필요한 신규 메소드 1: 공지사항 목록 가져오기
    public Vector<PostBean> getCommunityNotices() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT p.*, u.nickname FROM post p " +
                         "JOIN user u ON p.user_id = u.user_id " +
                         "WHERE p.priority = 1 ORDER BY p.post_id DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at")); // getFormattedDate()는 PostBean에서 처리
                bean.setPriority(rs.getInt("priority"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }

    // JSP 파일에 필요한 신규 메소드 2: 일반 게시글 목록 가져오기 (페이징)
    public Vector<PostBean> getRegularCommunityPosts(int start, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT p.*, u.nickname FROM post p " +
                         "JOIN user u ON p.user_id = u.user_id " +
                         "WHERE p.priority != 1 ORDER BY p.post_id DESC LIMIT ?, ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, pageSize);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                bean.setPriority(rs.getInt("priority"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }

    // JSP 파일에 필요한 신규 메소드 3: 일반 게시글 총 개수 가져오기
    public int getRegularCommunityPostCount() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int totalCount = 0;
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT count(*) FROM post WHERE priority != 1";
            pstmt = conn.prepareStatement(sql);
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

    // JSP 파일에 필요한 신규 메소드 4: 일반 게시글 검색하기 (페이징)
    public Vector<PostBean> searchRegularCommunityPosts(String searchType, String searchKeyword, int start, int pageSize) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        try {
            conn = pool.getConnection("user");
            String sql;
            if ("title".equals(searchType)) {
                sql = "SELECT p.*, u.nickname FROM post p " +
                      "JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.priority != 1 AND p.title LIKE ? ORDER BY p.post_id DESC LIMIT ?, ?";
            } else { // "nickname"
                sql = "SELECT p.*, u.nickname FROM post p " +
                      "JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.priority != 1 AND u.nickname LIKE ? ORDER BY p.post_id DESC LIMIT ?, ?";
            }
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + searchKeyword + "%");
            pstmt.setInt(2, start);
            pstmt.setInt(3, pageSize);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                 PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                bean.setPriority(rs.getInt("priority"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return vlist;
    }

    // JSP 파일에 필요한 신규 메소드 5: 일반 게시글 검색 결과 총 개수 가져오기
    public int getSearchRegularCommunityPostCount(String searchType, String searchKeyword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int totalCount = 0;
        try {
            conn = pool.getConnection("user");
            String sql;
            if ("title".equals(searchType)) {
                sql = "SELECT count(*) FROM post p " +
                      "WHERE p.priority != 1 AND p.title LIKE ?";
            } else { // "nickname"
                sql = "SELECT count(*) FROM post p " +
                      "JOIN user u ON p.user_id = u.user_id " +
                      "WHERE p.priority != 1 AND u.nickname LIKE ?";
            }
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + searchKeyword + "%");
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
    // ============== [ 정보 검증 게시판 (Verification) ] ==============

    // 정보 검증 게시판의 공지사항(priority=1) 목록 가져오기
    public Vector<PostBean> getVerificationNotices() {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        String sql = "SELECT p.*, u.nickname FROM post p JOIN user u ON p.user_id = u.user_id " +
                     "WHERE p.type = '정보' AND p.priority = 1 ORDER BY p.post_id DESC";
        try {
            con = pool.getConnection("user");
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                bean.setPriority(rs.getInt("priority"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }

    // 정보 검증 게시판의 일반 게시글(priority!=1) 목록 가져오기 (페이징)
    public Vector<PostBean> getRegularVerificationPosts(int start, int limit) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        String sql = "SELECT p.*, u.nickname FROM post p JOIN user u ON p.user_id = u.user_id " +
                     "WHERE p.type = '정보' AND p.priority != 1 ORDER BY p.post_id DESC LIMIT ?, ?";
        try {
            con = pool.getConnection("user");
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, start);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                bean.setPriority(rs.getInt("priority"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
    // 정보 검증 게시판의 일반 게시글 총 개수
    public int getRegularVerificationPostCount() {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int total = 0;
        String sql = "SELECT count(*) FROM post WHERE type = '정보' AND priority != 1";
        try {
            con = pool.getConnection("user");
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return total;
    }

    // 정보 검증 게시판의 일반 게시글 검색 (페이징)
    public Vector<PostBean> searchRegularVerificationPosts(String searchType, String keyword, int start, int limit) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        String sql = "SELECT p.*, u.nickname FROM post p JOIN user u ON p.user_id = u.user_id " +
                     "WHERE p.type = '정보' AND p.priority != 1 AND %s LIKE ? " +
                     "ORDER BY p.post_id DESC LIMIT ?, ?";

        String searchField = "title".equals(searchType) ? "p.title" : "u.nickname";
        sql = String.format(sql, searchField);
        
        try {
            con = pool.getConnection("user");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setInt(2, start);
            pstmt.setInt(3, limit);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setTitle(rs.getString("title"));
                bean.setNickname(rs.getString("nickname"));
                bean.setCreatedAt(rs.getString("created_at"));
                bean.setPriority(rs.getInt("priority"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
    // 정보 검증 게시판의 일반 게시글 검색 결과 총 개수
    public int getSearchRegularVerificationPostCount(String searchType, String keyword) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int total = 0;
        String sql = "SELECT count(*) FROM post p JOIN user u ON p.user_id = u.user_id " +
                     "WHERE p.type = '정보' AND p.priority != 1 AND %s LIKE ?";

        String searchField = "title".equals(searchType) ? "p.title" : "u.nickname";
        sql = String.format(sql, searchField);
        
        try {
            con = pool.getConnection("user");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return total;
    }
    


}
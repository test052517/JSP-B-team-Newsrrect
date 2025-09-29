package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
            con = pool.getConnection();
            // priority 컬럼을 포함하여 INSERT SQL 문을 수정
            sql = "INSERT INTO post(user_id, type, title, content, status, view_count, created_at, report_count, recommand_count, priority) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
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
            conn = pool.getConnection();
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
     * 승인 대기 중인 게시글 목록 조회
     */
    public Vector<PostBean> getPendingPosts(int start, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<PostBean> vlist = new Vector<>();
        
        try {
            conn = pool.getConnection();
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
            conn = pool.getConnection();
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
            conn = pool.getConnection();
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
            conn = pool.getConnection();
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
            conn = pool.getConnection();
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
 // PostMgr.java 파일에 추가하세요.

    /**
     * 검색된 승인 대기 게시글의 총 개수
     */
    public int getSearchPendingPostCount(String searchType, String keyword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = pool.getConnection();
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
}
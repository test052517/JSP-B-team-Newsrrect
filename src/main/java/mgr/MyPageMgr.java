package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import beans.MyPageStatsBean;
import beans.PostBean;
import beans.CommentBean;

// MyPage 관련 통계 및 활동 내역을 관리하는 매니저
public class MyPageMgr {

    private Connection conn;
    private DBConnectionMgr pool; // 기존 프로젝트의 DB Connection Pool 클래스를 사용 가정

    // 생성자에서 DB Connection Pool 초기화
    public MyPageMgr() {
    	System.out.println("[MyPageMgr] INFO: MyPageMgr 객체 생성 시도...");
        try {
            pool = DBConnectionMgr.getInstance(); 
            System.out.println("[MyPageMgr] INFO: DB Connection Pool 초기화 성공.");
        } catch (Exception e) {
        	System.out.println("[MyPageMgr] ERROR: DB Connection Pool 연결 실패: " + e.getMessage());
        }
    }

    // ==============================================================
    // 1. 사용자 통계 수치 조회 (작성 글, 댓글, 받은 추천 수)
    // ==============================================================
    public MyPageStatsBean getStats(int userId) {
    	System.out.println("[MyPageMgr] DEBUG: getStats(userId: " + userId + ") 호출됨."); // 👈 추가
        MyPageStatsBean bean = new MyPageStatsBean();
        
        // userId는 세션에서 가져온 사용자 ID
        String sql = 
                "SELECT " +
                        " (SELECT COUNT(*) FROM post WHERE user_id = ? AND status != '삭제') AS post_count, " + 
                        " (SELECT COUNT(*) FROM comment WHERE user_id = ? AND status != '삭제') AS comment_count, " +
                        " (SELECT COALESCE(SUM(upvotes), 0) FROM comment WHERE user_id = ? AND status != '삭제') AS received_recom_count"; 
        
        try {
        	conn = pool.getConnection("user");
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            // 쿼리 내 3개의 ?에 모두 userId 바인딩
            pstmt.setInt(1, userId); 
            pstmt.setInt(2, userId);
            pstmt.setInt(3, userId);
            
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                bean.setPostCount(rs.getInt("post_count"));
                bean.setCommentCount(rs.getInt("comment_count"));
                bean.setReceivedRecomCount(rs.getInt("received_recom_count"));
            }
            
            rs.close();
            pstmt.close();
        } catch (Exception e) {
        	System.out.println("사용자 통계 조회 오류: " + e.getMessage());
        } finally {
            pool.freeConnection(conn);
        }
        return bean;
    }

    // ==============================================================
    // 2. 최근 작성 게시글 목록 조회 (최신순 5개)
    // ==============================================================
    public List<PostBean> getRecentPosts(int userId) {
        List<PostBean> list = new ArrayList<>();
        
        // nickname은 JOIN이 필요 없으므로 post 테이블 컬럼만 조회
        String sql = 
                "SELECT post_id, type, title, created_at " +
                "FROM post " +
                "WHERE user_id = ? AND status = '공개' " + // 공개글만 조회
                "ORDER BY created_at DESC " +
                "LIMIT 5";

        try {
            conn = pool.getConnection("user");
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                PostBean bean = new PostBean();
                bean.setPostId(rs.getInt("post_id"));
                bean.setType(rs.getString("type"));
                bean.setTitle(rs.getString("title"));
                bean.setCreatedAt(rs.getString("created_at"));
                list.add(bean);
            }
            
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            System.out.println("최근 게시글 목록 조회 오류: " + e.getMessage());
        } finally {
            pool.freeConnection(conn);
        }
        return list;
    }
    
    // ==============================================================
    // 3. 최근 작성 댓글 목록 조회 (최신순 5개, 원문 글 제목 포함)
    // ==============================================================
    public List<CommentBean> getRecentComments(int userId) {
        List<CommentBean> list = new ArrayList<>();
        
        String sql = 
        		"SELECT C.comment_id, C.content, C.created_at, P.title AS post_title, P.post_id AS original_post_id, P.type AS post_type " + 
        		        "FROM comment C " +
        		        "JOIN post P ON C.post_id = P.post_id " +
        		        "WHERE C.user_id = ? AND C.status = '공개' " + 
        		        "ORDER BY C.created_at DESC " +
        		        "LIMIT 5";

        try {
            conn = pool.getConnection("user");
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                CommentBean bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setContent(rs.getString("content"));
                bean.setCreated_at(rs.getString("created_at"));
                
                // CommentBean에 추가한 마이페이지용 필드 설정
                bean.setOriginalPostTitle(rs.getString("post_title"));
                bean.setOriginalPostId(rs.getInt("original_post_id"));
                bean.setOriginalPostType(rs.getString("post_type"));
                
                list.add(bean);
            }
            
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            System.out.println("최근 댓글 목록 조회 오류: " + e.getMessage());
        } finally {
            pool.freeConnection(conn);
        }
        return list;
    }
    
    public boolean updateProfile(int userId, String introduce, String profileImageName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        
        String sql = "";
        
        if (profileImageName != null) {
            // 이미지도 변경할 경우: introduce와 profileimage 컬럼명을 사용
            sql = "UPDATE user SET introduce = ?, profileimage = ? WHERE user_id = ?";
        } else {
            // 자기소개만 변경할 경우
            sql = "UPDATE user SET introduce = ? WHERE user_id = ?";
        }

        try {
            conn = pool.getConnection("user"); 
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, introduce);
            
            if (profileImageName != null) {
                pstmt.setString(2, profileImageName);
                pstmt.setInt(3, userId);
            } else {
                pstmt.setInt(2, userId);
            }
            
            if (pstmt.executeUpdate() == 1) {
                result = true;
            }
            
        } catch (Exception e) {
            System.out.println("프로필 업데이트 오류: " + e.getMessage());
        } finally {
            pool.freeConnection(conn, pstmt); // getConnection()이 Connection, PreparedStatement, ResultSet을 받지 않는다면 수정 필요
        }
        return result;
    }
    
 // ==============================================================
 // 5. 사용자 정보 전체 조회 (세션 갱신용)
 // ==============================================================
 public beans.UserBean getUserById(int userId) {
     Connection conn = null;
     PreparedStatement pstmt = null;
     ResultSet rs = null;
     beans.UserBean user = null; // beans.UserBean으로 수정 (패키지명에 따라 변경 가능)
     
     // DB의 user 테이블에서 모든 컬럼을 조회하는 SQL
     String sql = "SELECT * FROM user WHERE user_id = ?"; 

     try {
         conn = pool.getConnection("user"); 
         pstmt = conn.prepareStatement(sql);
         pstmt.setInt(1, userId);
         rs = pstmt.executeQuery();

         if (rs.next()) {
             user = new beans.UserBean();
             user.setUserId(rs.getInt("user_id"));
             user.setEmail(rs.getString("email"));
             user.setPassword(rs.getString("password"));
             user.setRole(rs.getString("role"));
             user.setNickname(rs.getString("nickname"));
             user.setCreatedAt(rs.getString("created_at")); 
             user.setIsActive(rs.getInt("is_active"));
             user.setBanCount(rs.getInt("ban_count"));
             user.setReportCount(rs.getInt("report_count"));
             user.setPoint(rs.getInt("point"));
             user.setAttend(rs.getString("attend"));
             user.setIntroduce(rs.getString("introduce"));
             user.setProfileImage(rs.getString("profileimage")); 
         }
     } catch (Exception e) {
         System.out.println("사용자 정보 조회 오류: " + e.getMessage());
     } finally {
         pool.freeConnection(conn, pstmt, rs);
     }
     return user;
 }
}
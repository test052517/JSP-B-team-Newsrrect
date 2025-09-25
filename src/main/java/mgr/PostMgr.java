package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import beans.PostBean;

public class PostMgr {
		DBConnectionMgr pool;
		
		public PostMgr() {
			pool=DBConnectionMgr.getInstance();
		}
		
		public void createPost(int userid, String type, String title, String content, String status, int viewcount, String createdAt,  int reportCount, int recommandCount) {
		    Connection con = null;
		    PreparedStatement pstmt = null;
		    String sql = null;
		    try {
		        con = pool.getConnection();
		        // post_id 컬럼을 제거하고, VALUES 절의 물음표 개수를 맞춰줍니다.
		        sql = "INSERT INTO post(user_id, type, title, content, status, view_count, created_at, report_count, recommand_count) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
		        
		        pstmt = con.prepareStatement(sql);
		        
		        // post_id는 DB가 자동으로 생성하므로, pstmt.setInt(1, postid) 코드를 제거합니다.
		        pstmt.setInt(1, userid);
		        pstmt.setString(2, type);
		        pstmt.setString(3, title);
		        pstmt.setString(4, content);
		        pstmt.setString(5, status);
		        pstmt.setInt(6, viewcount);
		        pstmt.setString(7, createdAt);
		        
		        
		        pstmt.setInt(8, reportCount);
		        pstmt.setInt(9, recommandCount);
		        
		        pstmt.executeUpdate();
		    } catch (Exception e) {
		        e.printStackTrace();
		    } finally {
		        pool.freeConnection(con, pstmt);
		    }
		}
		

		
		
		public PostBean getPostByPostID(int postId) {
		    Connection con = null;
		    PreparedStatement pstmt = null;
		    ResultSet rs = null;
		    PostBean bean = null; // 데이터를 담을 객체를 초기값 null로 설정

		    try {
		        con = pool.getConnection();
		        String sql = "SELECT title, content FROM post WHERE post_id = ?";
		        pstmt = con.prepareStatement(sql);
		        pstmt.setInt(1, postId);
		        rs = pstmt.executeQuery();

		        if (rs.next()) {
		            // 결과가 있을 때만 객체를 생성하여 데이터를 담습니다.
		            bean = new PostBean(); 
		            bean.setPostId(postId);
		            bean.setTitle(rs.getString("title"));
		            bean.setContent(rs.getString("content"));
		        }

		    } catch (Exception e) {
		        e.printStackTrace();
		        bean = null; // 오류 발생 시 명시적으로 null 반환
		    } finally {
		        // 자원을 반드시 해제합니다.
		        pool.freeConnection(con, pstmt, rs);
		    }
		    return bean; // 데이터가 없거나 오류 발생 시 null이 반환됩니다.
		}
}

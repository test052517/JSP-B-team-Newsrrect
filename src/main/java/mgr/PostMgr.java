package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class PostMgr {
		DBConnectionMgr pool;
		
		public PostMgr() {
			pool=DBConnectionMgr.getInstance();
		}
		
		public void createPost(int userid, String type, String title, String content, String status, int viewcount, String createdAt, Integer attatchmentFileID, int reportCount, int recommandCount) {
		    Connection con = null;
		    PreparedStatement pstmt = null;
		    String sql = null;
		    try {
		        con = pool.getConnection();
		        // post_id 컬럼을 제거하고, VALUES 절의 물음표 개수를 맞춰줍니다.
		        sql = "INSERT INTO post(user_id, type, title, content, status, view_count, created_at, attachmentFile_id, report_count, recommand_count) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		        
		        pstmt = con.prepareStatement(sql);
		        
		        // post_id는 DB가 자동으로 생성하므로, pstmt.setInt(1, postid) 코드를 제거합니다.
		        pstmt.setInt(1, userid);
		        pstmt.setString(2, type);
		        pstmt.setString(3, title);
		        pstmt.setString(4, content);
		        pstmt.setString(5, status);
		        pstmt.setInt(6, viewcount);
		        pstmt.setString(7, createdAt);
		        
		        if (attatchmentFileID != null) {
		            pstmt.setInt(8, attatchmentFileID);
		        } else {
		            pstmt.setNull(8, java.sql.Types.INTEGER);
		        }
		        
		        pstmt.setInt(9, reportCount);
		        pstmt.setInt(10, recommandCount);
		        
		        pstmt.executeUpdate();
		    } catch (Exception e) {
		        e.printStackTrace();
		    } finally {
		        pool.freeConnection(con, pstmt);
		    }
		}
		
	    public ResultSet viewPostByPostID(int postid) {
	        Connection con = null;
	        PreparedStatement pstmt = null;
	        ResultSet rs = null;

	        try {
	            con = pool.getConnection();
	            String sql = "SELECT * FROM post WHERE post_id = ?";
	            pstmt = con.prepareStatement(sql);
	            pstmt.setInt(1, postid);
	            rs = pstmt.executeQuery();
	            
	            // ResultSet을 호출하는 곳으로 전달하기 위해 여기서 바로 반환합니다.
	            return rs;

	        } catch (Exception e) {
	            e.printStackTrace();
	            // 오류가 발생하면 자원을 정리하고 null을 반환합니다.
	            try {
	                if (rs != null) rs.close();
	                if (pstmt != null) pstmt.close();
	                if (con != null) con.close();
	            } catch (Exception ex) {
	                ex.printStackTrace();
	            }
	        }
	        return null;
	    }
		
		
}

package mgr;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import beans.UserBean;

public class UserMgr {
    private DBConnectionMgr pool;
    
    public UserMgr() {
        pool = DBConnectionMgr.getInstance();
    }
    
    /**
     * 로그인 처리
     * @param email 사용자 이메일
     * @param password 사용자 비밀번호
     * @return 로그인 성공시 UserBean 객체, 실패시 null
     */
    public UserBean Login(String email, String password) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        UserBean user = null;
        
        try {
            // "user" 데이터베이스 연결 (newsrrect 데이터베이스)
            con = pool.getConnection("user");
            
            // 로그인 쿼리 - is_active가 1인 활성 사용자만 로그인 가능
            String sql = "SELECT user_id, email, role, nickname, is_active FROM user WHERE email = ? AND password = ? AND is_active = 1";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = new UserBean();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setNickname(rs.getString("nickname"));
                
                System.out.println("로그인 성공: " + email + " (" + rs.getString("role") + ")");
            } else {
                System.out.println("로그인 실패: " + email + " - 이메일/비밀번호 불일치 또는 비활성 계정");
            }
            
        } catch (Exception e) {
            System.err.println("UserMgr.Login() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        
        return user;
    }
    
    /**
     * 사용자 정보 조회 (ID로)
     * @param userId 사용자 ID
     * @return UserBean 객체 또는 null
     */
    public UserBean getUserById(int userId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        UserBean user = null;
        
        try {
            con = pool.getConnection("user");
            String sql = "SELECT user_id, email, role, nickname, created_at, is_active, point FROM user WHERE user_id = ? AND is_active = 1";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = new UserBean();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setNickname(rs.getString("nickname"));
                // 필요한 경우 추가 필드들도 설정
            }
            
        } catch (Exception e) {
            System.err.println("UserMgr.getUserById() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        
        return user;
    }
    
    /**
     * 이메일 중복 확인
     * @param email 확인할 이메일
     * @return 중복시 true, 사용가능시 false
     */
    public boolean isEmailExists(String email) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean exists = false;
        
        try {
            con = pool.getConnection("user");
            String sql = "SELECT COUNT(*) FROM user WHERE email = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, email);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
            
        } catch (Exception e) {
            System.err.println("UserMgr.isEmailExists() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        
        return exists;
    }
    
    /**
     * 닉네임 중복 확인
     * @param nickname 확인할 닉네임
     * @return 중복시 true, 사용가능시 false
     */
    public boolean isNicknameExists(String nickname) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean exists = false;
        
        try {
            con = pool.getConnection("user");
            String sql = "SELECT COUNT(*) FROM user WHERE nickname = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, nickname);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
            
        } catch (Exception e) {
            System.err.println("UserMgr.isNicknameExists() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        
        return exists;
    }
    
    /**
     * 출석 처리
     * @param userId 사용자 ID
     * @return 처리 성공시 true
     */
    public boolean updateAttendance(int userId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = pool.getConnection("user");
            
            // 현재 시간으로 출석 시간 업데이트 및 포인트 지급
            String sql = "UPDATE user SET attend = NOW(), point = point + 10 WHERE user_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (Exception e) {
            System.err.println("UserMgr.updateAttendance() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        
        return false;
    }
    
    /**
     * 사용자 계정 비활성화
     * @param userId 사용자 ID
     * @return 처리 성공시 true
     */
    public boolean deactivateUser(int userId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = pool.getConnection("user");
            String sql = "UPDATE user SET is_active = 0 WHERE user_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (Exception e) {
            System.err.println("UserMgr.deactivateUser() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        
        return false;
    }
}
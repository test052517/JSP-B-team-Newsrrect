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
     * 회원가입
     * @param user UserBean 객체 (email, password, nickname, role 등 설정 필요)
     * @return 생성 성공 시 true, 실패 시 false
     */
    public boolean createUser(UserBean user) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean result = false;

        try {
            con = pool.getConnection("user");

            String sql = "INSERT INTO user (email, password, nickname, role, created_at, is_active, point) "
                       + "VALUES (?, ?, ?, ?, NOW(), 1, 0)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, user.getEmail());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getNickname());
            pstmt.setString(4, user.getRole());

            int rows = pstmt.executeUpdate();
            result = rows > 0;

            if (result) {
                System.out.println("회원가입 성공: " + user.getEmail() + " (" + user.getNickname() + ")");
            } else {
                System.out.println("회원가입 실패: " + user.getEmail());
            }

        } catch (Exception e) {
            System.err.println("UserMgr.createUser() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }

        return result;
    }

    
    /**
     * 로그인 처리
     * @param email 사용자 이메일
     * @param password 사용자 비밀번호
     * @return 로그인 성공시 UserBean 객체, 실패시 null
     */
    /**
     * 로그인 처리 (차단된 사용자도 조회 가능하도록 수정)
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
            con = pool.getConnection("user");
            
            // is_active 조건 제거 - 차단된 사용자도 조회 가능하도록
            String sql = "SELECT user_id, email, role, nickname, created_at, is_active, "
                    + "ban_count, report_count, point, attend, introduce "
                    + "FROM user WHERE email = ? AND password = ?";
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
                user.setCreatedAt(rs.getString("created_at"));
                user.setIsActive(rs.getInt("is_active"));
                user.setBanCount(rs.getInt("ban_count"));
                user.setReportCount(rs.getInt("report_count"));
                user.setPoint(rs.getInt("point"));
                user.setAttend(rs.getString("attend"));
                user.setIntroduce(rs.getString("introduce"));
                user.setProfileImage("");
                
                // 차단 여부 로그
                if (rs.getInt("is_active") == 0) {
                    System.out.println("로그인 시도 (차단된 계정): " + email);
                } else {
                    System.out.println("로그인 성공: " + email + " (" + rs.getString("role") + ")");
                }
            } else {
                System.out.println("로그인 실패: " + email + " - 이메일/비밀번호 불일치");
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
            
            // introduce와 profileImage 추가
            String sql = "SELECT user_id, email, role, nickname, created_at, is_active, point, " +
                         "ban_count, report_count, attend, introduce, profileImage " +
                         "FROM user WHERE user_id = ? AND is_active = 1";
            
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user = new UserBean();
                user.setUserId(rs.getInt("user_id"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setNickname(rs.getString("nickname"));
                user.setCreatedAt(rs.getString("created_at"));
                user.setIsActive(rs.getInt("is_active"));
                user.setPoint(rs.getInt("point"));
                user.setBanCount(rs.getInt("ban_count"));
                user.setReportCount(rs.getInt("report_count"));
                user.setAttend(rs.getString("attend"));
                
                // 이 두 줄 추가!
                user.setIntroduce(rs.getString("introduce"));
                user.setProfileImage(rs.getString("profileImage"));
            }
            
        } catch (Exception e) {
            System.err.println("UserMgr.getUserById() ì˜¤ë¥˜: " + e.getMessage());
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
    /**
     * 사용자 계정 삭제 (영구 삭제)
     * @param userId 사용자 ID
     * @return 처리 성공시 true
     */
    public boolean deleteUser(int userId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = pool.getConnection("user");
            String sql = "DELETE FROM user WHERE user_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, userId);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                System.out.println("사용자 삭제 성공: ID " + userId);
            }
            
            return result > 0;
            
        } catch (Exception e) {
            System.err.println("UserMgr.deleteUser() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        
        return false;
    }
    
    public boolean updatePassword(int userId, String currentPassword, String newPassword) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean result = false;

        String checkSql = "SELECT password FROM user WHERE user_id = ?";
        
        String updateSql = "UPDATE user SET password = ? WHERE user_id = ?";

        try {
            conn = pool.getConnection("user");
            
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getString("password").equals(currentPassword)) {
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, newPassword); 
                pstmt.setInt(2, userId);
                
                if (pstmt.executeUpdate() == 1) {
                    result = true;
                }
            }
            
        } catch (Exception e) {
            System.out.println("비밀번호 업데이트 오류: " + e.getMessage());
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        return result;
    }
    
    /**
     * 사용자의 총 포인트를 계산하고 DB에 업데이트합니다.
     * 계산 공식: (BEST 댓글 선정 수 * 20) + (총 추천 수 / 10)
     * @param userId 포인트를 업데이트할 사용자 ID
     * @return 업데이트 성공 시 true
     */
    public boolean calculateAndUpdateTotalPoints(int userId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean success = false;
        
        // BEST 댓글 선정 (+20점, upvotes >= 5개)
        // 받은 댓글 추천 수 (+총 추천수/10)
        String commentSql = 
                "SELECT " +
                "    SUM(CASE WHEN c.upvotes >= 5 THEN 20 ELSE 0 END) AS best_comment_points, " +
                "    TRUNCATE(COALESCE(SUM(c.upvotes), 0) / 10, 0) AS upvote_points " +
                "FROM comment c " +
                "WHERE c.user_id = ? AND c.status != '삭제'";

            String updateSql = "UPDATE user SET point = ? WHERE user_id = ?";
        
        try {
            con = pool.getConnection("user");
            
            pstmt = con.prepareStatement(commentSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            
            int totalCalculatedPoints = 0;
            
            if (rs.next()) {
                int bestCommentPoints = rs.getInt("best_comment_points");
                int upvotePoints = rs.getInt("upvote_points");
                
                totalCalculatedPoints = bestCommentPoints + upvotePoints;

                if (totalCalculatedPoints > 1000) {
                    totalCalculatedPoints = 1000;
                }
            }
            
            rs.close();
            pstmt.close();
            
            pstmt = con.prepareStatement(updateSql);
            pstmt.setInt(1, totalCalculatedPoints);
            pstmt.setInt(2, userId);
            
            success = pstmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.err.println("UserMgr.calculateAndUpdateTotalPoints() 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        
        return success;
    }
}
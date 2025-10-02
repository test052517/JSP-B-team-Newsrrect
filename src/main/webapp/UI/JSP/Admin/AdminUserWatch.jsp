<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="mgr.UserMgr" %>
<%@ page import="mgr.DBConnectionMgr" %>
<%@ page import="beans.UserBean" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>유저 상세 정보 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="../CSS/fonts.css">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'primary': '#5d74f8',
                        'primary-dark': '#4c63e7',
                        'primary-light': '#7d8ff9'
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-50 min-h-screen">
    <jsp:include page="../Common/AdminHeader.jsp" />

    <%
        // 차단 처리 로직
        String action = request.getParameter("action");
        if ("block".equals(action)) {
            String userId = request.getParameter("userId");
            String blockReason = request.getParameter("blockReason");
            String blockDuration = request.getParameter("blockDuration");
            String blockEndDate = request.getParameter("blockEndDate");
            
            if (userId != null && blockReason != null && !blockReason.trim().isEmpty()) {
                Connection con = null;
                PreparedStatement pstmt = null;
                
                try {
                    DBConnectionMgr pool = DBConnectionMgr.getInstance();
                    con = pool.getConnection("user");
                    
                    con.setAutoCommit(false);
                    
                    // ban 테이블에 차단 정보 저장
                    String sql1 = "INSERT INTO ban (banned_user_id, reason, ban_end_date) VALUES (?, ?, ?)";
                    pstmt = con.prepareStatement(sql1);
                    pstmt.setInt(1, Integer.parseInt(userId));
                    pstmt.setString(2, blockReason);
                    if ("permanent".equals(blockDuration)) {
                        pstmt.setString(3, null);
                    } else {
                        pstmt.setString(3, blockEndDate);
                    }
                    pstmt.executeUpdate();
                    pstmt.close();
                    
                    // user 테이블 업데이트
                    String sql2 = "UPDATE user SET ban_count = ban_count + 1, is_active = 0 WHERE user_id = ?";
                    pstmt = con.prepareStatement(sql2);
                    pstmt.setInt(1, Integer.parseInt(userId));
                    pstmt.executeUpdate();
                    
                    con.commit();
                    
                    String endDateMsg = "permanent".equals(blockDuration) ? "무기한" : blockEndDate;
                    out.println("<script>alert('사용자를 차단했습니다.\\n사유: " + blockReason + "\\n종료일: " + endDateMsg + "'); location.href='AdminUserWatch.jsp?user=" + userId + "';</script>");
                    
                } catch (Exception e) {
                    if (con != null) {
                        try { con.rollback(); } catch(Exception ex) {}
                    }
                    e.printStackTrace();
                    out.println("<script>alert('차단 처리 중 오류가 발생했습니다.'); history.back();</script>");
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                    if (con != null) {
                        try { 
                            con.setAutoCommit(true);
                            DBConnectionMgr.getInstance().freeConnection(con, pstmt);
                        } catch(Exception e) {}
                    }
                }
            }
        }
    
        String username = request.getParameter("user");
        if (username == null || username.isEmpty()) {
            username = "정보 없음";
        }

        // 사용자 정보 조회
        Map<String, Object> user = new HashMap<String, Object>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            DBConnectionMgr pool = DBConnectionMgr.getInstance();
            con = pool.getConnection("user");
            
            String sql = "SELECT u.user_id, u.nickname, u.introduce, u.created_at, u.ban_count, u.report_count, " +
                        "u.is_active, b.ban_end_date " +
                        "FROM user u " +
                        "LEFT JOIN (SELECT banned_user_id, MAX(ban_end_date) as ban_end_date FROM ban GROUP BY banned_user_id) b " +
                        "ON u.user_id = b.banned_user_id " +
                        "WHERE u.user_id = ? OR u.nickname = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                user.put("userId", Integer.valueOf(rs.getInt("user_id")));
                user.put("nickname", rs.getString("nickname"));
                String intro = rs.getString("introduce");
                user.put("intro", intro != null ? intro : "소개가 없습니다.");
                user.put("joinDate", rs.getString("created_at"));
                user.put("reportCount", Integer.valueOf(rs.getInt("report_count")));
                user.put("blockCount", Integer.valueOf(rs.getInt("ban_count")));
                user.put("isActive", Integer.valueOf(rs.getInt("is_active")));
                String banEndDate = rs.getString("ban_end_date");
                user.put("blockEndDate", banEndDate != null ? banEndDate : "없음");
            } else {
                user.put("userId", Integer.valueOf(0));
                user.put("nickname", username);
                user.put("intro", "안녕하세요. AI와 최신 기술에 관심이 많습니다.");
                user.put("joinDate", "2024-08-01");
                user.put("reportCount", Integer.valueOf(2));
                user.put("blockCount", Integer.valueOf(1));
                user.put("isActive", Integer.valueOf(1));
                user.put("blockEndDate", "2025-09-29");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (con != null) {
                try { 
                    DBConnectionMgr.getInstance().freeConnection(con, pstmt, rs);
                } catch(Exception e) {}
            }
        }

        List<Map<String, String>> posts = new ArrayList<Map<String, String>>();
        Map<String, String> post1 = new HashMap<String, String>();
        post1.put("type", "정보 검증");
        post1.put("title", "최신 AI 모델의 성능 검증 요청");
        post1.put("date", "2025-09-25");
        posts.add(post1);
        
        Map<String, String> post2 = new HashMap<String, String>();
        post2.put("type", "소통");
        post2.put("title", "플랫폼 개선 아이디어 제안합니다.");
        post2.put("date", "2025-09-23");
        posts.add(post2);

        List<Map<String, String>> comments = new ArrayList<Map<String, String>>();
        Map<String, String> comment1 = new HashMap<String, String>();
        comment1.put("type", "정보 검증");
        comment1.put("content", "정말 유용한 정보였습니다. 감사합니다.");
        comment1.put("originalAuthor", "user2");
        comment1.put("date", "2025-09-25");
        comments.add(comment1);
        
        Map<String, String> comment2 = new HashMap<String, String>();
        comment2.put("type", "소통");
        comment2.put("content", "UI가 직관적이어서 사용하기 편합니다.");
        comment2.put("originalAuthor", "user5");
        comment2.put("date", "2025-09-22");
        comments.add(comment2);
    %>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-8">
            <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">유저 / 신고 관리</h2>
            </div>
            
            <div class="p-6">
                <div class="bg-gray-100 rounded-lg p-6 mb-6">
                    <div class="flex items-start space-x-6">
                        <div class="flex-shrink-0">
                            <div class="w-24 h-24 bg-gray-300 rounded-full flex items-center justify-center">
                                <span class="text-gray-500">프로필</span>
                            </div>
                        </div>
                        
                        <div class="flex-1">
                            <h3 class="text-xl font-bold text-gray-900 mb-1">
                                <%= user.get("nickname") %>
                                <% 
                                Integer isActive = (Integer)user.get("isActive");
                                if (isActive != null && isActive.intValue() == 0) { 
                                %>
                                    <span class="text-red-600 text-sm">(차단됨)</span>
                                <% } %>
                            </h3>
                            <p class="text-gray-600"><%= user.get("intro") %></p>
                        </div>
                        
                        <div class="text-right text-sm space-y-1 text-gray-600">
                            <p><strong>가입 일자:</strong> <%= user.get("joinDate") %></p>
                            <p><strong>누적 신고:</strong> <%= user.get("reportCount") %>회</p>
                            <p><strong>누적 차단:</strong> <%= user.get("blockCount") %>회</p>
                            <p><strong>현재 차단 종료일:</strong> <%= user.get("blockEndDate") %></p>
                        </div>
                    </div>
                    
                    <form method="post" action="AdminUserWatch.jsp" onsubmit="return validateBlock();" class="mt-6 pt-6 border-t border-gray-200">
                        <input type="hidden" name="action" value="block">
                        <input type="hidden" name="user" value="<%= username %>">
                        <input type="hidden" name="userId" value="<%= user.get("userId") %>">
                        
                        <div class="space-y-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">차단 사유</label>
                                <textarea id="blockReason" name="blockReason" class="w-full h-24 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary" placeholder="차단 사유를 입력하세요"></textarea>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">차단 기간</label>
                                <div class="flex space-x-2">
                                    <select id="blockDuration" name="blockDuration" class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary">
                                        <option value="">기간 선택</option>
                                        <option value="7">7일</option>
                                        <option value="30">30일</option>
                                        <option value="90">90일</option>
                                        <option value="permanent">무기한</option>
                                    </select>
                                    <input type="text" id="blockEndDate" name="blockEndDate" class="flex-1 px-3 py-2 border border-gray-300 rounded-md bg-gray-100" placeholder="종료일자" readonly>
                                    <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700">차단</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-8">
            <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">게시글 (<%= posts.size() %>)</h2>
            </div>
            
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">구분</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">제목</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">날짜</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% if (posts.isEmpty()) { %>
                            <tr><td colspan="3" class="text-center py-10 text-gray-500">작성한 게시글이 없습니다.</td></tr>
                        <% } else { 
                            for (Map<String, String> post : posts) { %>
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= post.get("type") %></td>
                            <td class="px-6 py-4 text-sm text-gray-900"><a href="#" class="hover:underline"><%= post.get("title") %></a></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= post.get("date") %></td>
                        </tr>
                        <% } 
                        } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="px-6 py-4 border-b border-gray-200">
                <h2 class="text-xl font-semibold text-gray-900">댓글 (<%= comments.size() %>)</h2>
            </div>
            
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">구분</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">내용</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">원글 작성자</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">날짜</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% if (comments.isEmpty()) { %>
                            <tr><td colspan="4" class="text-center py-10 text-gray-500">작성한 댓글이 없습니다.</td></tr>
                        <% } else { 
                            for (Map<String, String> comment : comments) { %>
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= comment.get("type") %></td>
                            <td class="px-6 py-4 text-sm text-gray-900"><a href="#" class="hover:underline"><%= comment.get("content") %></a></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= comment.get("originalAuthor") %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= comment.get("date") %></td>
                        </tr>
                        <% } 
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <script>
        document.getElementById('blockDuration').addEventListener('change', function() {
            const duration = this.value;
            const endDateInput = document.getElementById('blockEndDate');
            
            if (duration === 'permanent') {
                endDateInput.value = '무기한';
            } else if (duration) {
                const days = parseInt(duration);
                const today = new Date();
                today.setDate(today.getDate() + days);
                
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                
                endDateInput.value = year + '-' + month + '-' + day;
            } else {
                endDateInput.value = '';
            }
        });

        function validateBlock() {
            const reason = document.getElementById('blockReason').value;
            const duration = document.getElementById('blockDuration').value;

            if (!reason.trim()) {
                alert('차단 사유를 입력해주세요.');
                return false;
            }
            if (!duration) {
                alert('차단 기간을 선택해주세요.');
                return false;
            }
            
            return confirm('정말 이 사용자를 차단하시겠습니까?');
        }
    </script>
</body>
</html>
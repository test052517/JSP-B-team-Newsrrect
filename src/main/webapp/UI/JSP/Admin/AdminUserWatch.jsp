<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="mgr.UserMgr" %>
<%@ page import="mgr.DBConnectionMgr" %>
<%@ page import="beans.UserBean" %>
<%@ page import="java.sql.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
    	String contextPath = request.getContextPath();
    
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
            
            String sql = "SELECT u.user_id, u.nickname, u.introduce, u.created_at, u.ban_count, u.report_count, u.profileImage, " +
                    "u.is_active, b.ban_end_date " +
                    "FROM user u " +
                    "LEFT JOIN (SELECT banned_user_id, MAX(ban_end_date) as ban_end_date FROM ban GROUP " + 
                    "BY banned_user_id) b " +
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
                String profileImage = rs.getString("profileImage");
                user.put("profileImage", profileImage != null ? profileImage : "");
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
     	// 사용자 ID가 유효할 때만 통계 및 활동 내역 조회
        Integer targetUserId = (Integer)user.get("userId"); // 유저 정보 조회 로직에서 추출된 userId

        if (targetUserId != null && targetUserId.intValue() > 0) {
            
            // MyPageMgr 객체 생성
            mgr.MyPageMgr mgr = new mgr.MyPageMgr(); 

            try {
                // 1. 통계 데이터 조회
                beans.MyPageStatsBean userStats = mgr.getStats(targetUserId.intValue());
                pageContext.setAttribute("userStats", userStats); // pageContext로 JSP에 전달

                // 2. 최근 게시글 목록 조회
                List<beans.PostBean> recentPosts = mgr.getRecentPosts(targetUserId.intValue());
                pageContext.setAttribute("recentPosts", recentPosts);

                // 3. 최근 댓글 목록 조회
                List<beans.CommentBean> recentComments = mgr.getRecentComments(targetUserId.intValue());
                pageContext.setAttribute("recentComments", recentComments);
                
            } catch (Exception e) {
                // 데이터 로드 오류 처리 (선택 사항)
                System.err.println("관리자 화면 데이터 로드 오류: " + e.getMessage());
            }
        }
        
        if (targetUserId != null && targetUserId.intValue() > 0) {
            
            // MyPageMgr 객체 생성
            mgr.MyPageMgr mgr = new mgr.MyPageMgr(); 

            try {
                // 1. 통계 데이터 조회
                beans.MyPageStatsBean userStats = mgr.getStats(targetUserId.intValue());
                pageContext.setAttribute("userStats", userStats); // pageContext로 JSP에 전달

                // 2. 최근 게시글 목록 조회
                List<beans.PostBean> recentPosts = mgr.getRecentPosts(targetUserId.intValue());
                pageContext.setAttribute("recentPosts", recentPosts);

                // 3. 최근 댓글 목록 조회
                List<beans.CommentBean> recentComments = mgr.getRecentComments(targetUserId.intValue());
                pageContext.setAttribute("recentComments", recentComments);
                
            } catch (Exception e) {
                // 데이터 로드 오류 처리 (선택 사항)
                System.err.println("관리자 화면 데이터 로드 오류: " + e.getMessage());
            }
        }
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
                            <div class="w-24 h-24 bg-white rounded-full flex items-center justify-center">
					        <%
					            // Map에서 profileImage 값 추출
					            String profileImage = (String)user.get("profileImage");
					            
					            // 이미지 경로 생성. 빈 문자열일 경우 기본 이미지 경로로 설정
					            String imageSrc;
					            String defaultImageSrc = contextPath + "/UI/JSP/IMAGES/default_profile.png";
					            
					            if (profileImage != null && !profileImage.isEmpty()) {
					                imageSrc = contextPath + "/uploads/profiles/" + profileImage;
					            } else {
					                imageSrc = defaultImageSrc;
					            }
					        %>
					        
					        <img src="<%= imageSrc %>"
					            alt="프로필 이미지" 
					            class="w-full h-full object-cover rounded-full"
					            onerror="this.onerror=null;this.src='<%= defaultImageSrc %>';"
						                />
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
	        <h2 class="text-xl font-semibold text-gray-900">게시글 (<c:out value="${fn:length(recentPosts)}" default="0" />)</h2>
	    </div>
	    
	    <div class="overflow-x-auto">
	        <table class="min-w-full divide-y divide-gray-200">
	            <thead class="bg-gray-50">
	                <tr>
	                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">번호</th>
	                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">제목</th>
	                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">작성일</th>
	                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">글 유형</th>
	                </tr>
	            </thead>
	            <tbody class="bg-white divide-y divide-gray-200">
	                <c:choose>
	                    <c:when test="${not empty recentPosts}">
	                        <c:forEach var="post" items="${recentPosts}" varStatus="status">
	                            <tr class="hover:bg-gray-50">
	                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
	                                    <c:out value="${fn:length(recentPosts) - status.index}" />
	                                </td>
	                                <td class="px-6 py-4 text-sm text-gray-900">
	                                    <c:choose>
	                                        <c:when test="${post.type eq '정보'}">
	                                            <%-- 경로 수정: Context Path와 절대 경로 삽입 --%>
	                                            <a href="<%= contextPath %>/UI/JSP/User/InfoWatch.jsp?id=${post.postId}" class="hover:underline">
	                                                <c:out value="${post.title}" />
	                                            </a>
	                                        </c:when>
	                                        <c:when test="${post.type eq '소통'}">
	                                            <%-- 경로 수정: Context Path와 절대 경로 삽입 --%>
	                                            <a href="<%= contextPath %>/UI/JSP/User/CommuWatch.jsp?id=${post.postId}" class="hover:underline">
	                                                <c:out value="${post.title}" />
	                                            </a>
	                                        </c:when>
	                                        <c:otherwise><c:out value="${post.title}" /></c:otherwise>
	                                    </c:choose>
	                                </td>
	                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
	                                    <c:out value="${post.formattedDate}" />
	                                </td>
	                                <td class="px-6 py-4 whitespace-nowrap">
	                                    <span class="px-2 py-1 text-xs font-semibold rounded-full 
	                                                  <c:if test='${post.type eq "정보"}'>bg-blue-100 text-blue-800</c:if>
	                                                  <c:if test='${post.type eq "소통"}'>bg-green-100 text-green-800</c:if>">
	                                        <c:out value="${post.type}" />
	                                    </span>
	                                </td>
	                            </tr>
	                        </c:forEach>
	                    </c:when>
	                    <c:otherwise>
	                        <tr><td colspan="4" class="text-center py-10 text-gray-500">작성한 게시글이 없습니다.</td></tr>
	                    </c:otherwise>
	                </c:choose>
	            </tbody>
	        </table>
	    </div>
	</div>

    <div class="bg-white rounded-lg shadow-sm border border-gray-200">
    <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-xl font-semibold text-gray-900">댓글 (<c:out value="${fn:length(recentComments)}" default="0" />)</h2>
    </div>
    
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">구분</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">내용</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">원글 제목</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">날짜</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                <c:choose>
                    <c:when test="${not empty recentComments}">
                        <c:forEach var="comment" items="${recentComments}" varStatus="status">
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <c:out value="${comment.originalPostType}" />
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-900">
                                    <c:choose>
                                        <c:when test="${comment.originalPostType eq '정보'}">
                                            <a href="InfoWatch.jsp?id=${comment.originalPostId}" class="hover:underline">
                                                <c:out value="${fn:substring(comment.content, 0, 30)}" />...
                                            </a>
                                        </c:when>
                                        <c:when test="${comment.originalPostType eq '소통'}">
                                            <a href="CommuWatch.jsp?id=${comment.originalPostId}" class="hover:underline">
                                                <c:out value="${fn:substring(comment.content, 0, 30)}" />...
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${fn:substring(comment.content, 0, 30)}" />...
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    <c:out value="${comment.originalPostTitle}" />
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    <c:out value="${comment.formattedDate}" />
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr><td colspan="4" class="text-center py-10 text-gray-500">작성한 댓글이 없습니다.</td></tr>
                    </c:otherwise>
                </c:choose>
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
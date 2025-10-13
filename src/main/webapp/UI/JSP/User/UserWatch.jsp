<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="mgr.UserMgr, beans.UserBean" %>
<%@ page import="mgr.MyPageMgr" %>
<%@ page import="java.util.List" %>

<%
    String contextPath = request.getContextPath();
    
    // 조회할 사용자 ID 파라미터 받기
    String targetUserIdStr = request.getParameter("user");
    if (targetUserIdStr == null || targetUserIdStr.isEmpty()) {
        out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); history.back();</script>");
        return;
    }
    
    int targetUserId = 0;
    try {
        targetUserId = Integer.parseInt(targetUserIdStr);
    } catch (NumberFormatException e) {
        out.println("<script>alert('잘못된 사용자 ID입니다.'); history.back();</script>");
        return;
    }
    
    // 사용자 정보 조회
    UserMgr userMgr = new UserMgr();
    UserBean targetUser = userMgr.getUserById(targetUserId);
    
    if (targetUser == null) {
        out.println("<script>alert('사용자 정보를 찾을 수 없습니다.'); history.back();</script>");
        return;
    }
    
    pageContext.setAttribute("user", targetUser);
    
    // 통계 및 활동 내역 조회
    MyPageMgr myPageMgr = new MyPageMgr();
    
    try {
        // 통계 데이터
        beans.MyPageStatsBean userStats = myPageMgr.getStats(targetUserId);
        pageContext.setAttribute("userStats", userStats);
        
        // 최근 게시글
        List<beans.PostBean> recentPosts = myPageMgr.getRecentPosts(targetUserId);
        pageContext.setAttribute("recentPosts", recentPosts);
        
        // 최근 댓글
        List<beans.CommentBean> recentComments = myPageMgr.getRecentComments(targetUserId);
        pageContext.setAttribute("recentComments", recentComments);
        
    } catch (Exception e) {
        System.err.println("사용자 정보 로드 오류: " + e.getMessage());
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 정보 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= contextPath %>/UI/JSP/CSS/fonts.css">
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
<body class="bg-white min-h-screen">
    <jsp:include page="../Common/Header.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">사용자 정보</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm">
            <div class="p-8">
                
                <!-- Profile Section -->
                <div class="bg-gray-100 rounded-lg p-6 mb-8 relative">
                    <div class="absolute top-4 right-4 text-sm text-gray-500">
                        <strong>가입 일자:</strong> 
                        <c:choose>
                            <c:when test="${not empty user.createdAt}">
                                <fmt:parseDate var="joinDateObj" 
                                               value="${user.createdAt}" 
                                               pattern="yyyy-MM-dd HH:mm:ss" 
                                               type="both" />
                                <fmt:formatDate value="${joinDateObj}" pattern="yyyy.MM.dd" />
                            </c:when>
                            <c:otherwise>-</c:otherwise>
                        </c:choose>
                        <br>
                        <strong>누적 포인트:</strong> 
                        <c:out value="${user.point}" default="0" />
                    </div>
                    
                    <div class="flex items-center">
                        <div class="relative">
                            <div class="w-32 h-32 bg-white rounded-full mr-6 flex-shrink-0 flex items-center justify-center"> 
                                <c:choose>
                                    <c:when test="${not empty user.profileImage}">
                                        <img src="<%= contextPath %>/uploads/profiles/<c:out value="${user.profileImage}" />"
                                            alt="프로필 이미지" 
                                            class="w-full h-full object-cover rounded-full"
                                            onerror="this.onerror=null; this.src='<%= contextPath %>/UI/JSP/IMAGES/default_profile.png';"
                                        />
                                    </c:when>
                                    <c:otherwise>
                                        <img src="<%= contextPath %>/UI/JSP/IMAGES/default_profile.png"
                                             alt="기본 이미지" 
                                             class="w-full h-full object-cover rounded-full"
                                        />
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <div class="flex-1">
                            <div class="mb-2">
                                <label class="block text-sm font-medium text-gray-700 mb-1">닉네임</label>
                                <div class="w-full max-w-sm px-3 py-2 border border-gray-200 rounded-md bg-gray-50">
                                    <c:out value='${not empty user.nickname ? user.nickname : "닉네임"}' />
                                </div>
                            </div>
                            <div class="mb-4">
                                <label class="block text-sm font-medium text-gray-700 mb-1">자기소개</label>
                                <div class="w-full max-w-lg px-3 py-2 border border-gray-200 rounded-md bg-gray-50 min-h-[80px]">
                                    <c:out value="${not empty user.introduce ? user.introduce : '자기 소개가 없습니다.'}" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Statistics -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="rounded-lg p-4 text-center" style="background-color: #85b9fd;"> 
                        <div class="text-2xl font-bold mb-1 text-white">
                            <c:out value="${userStats.postCount}" default="0"/>
                        </div>
                        <div class="text-sm text-white">작성한 게시글</div>
                    </div>
                    
                    <div class="rounded-lg p-4 text-center" style="background-color: #738dff;"> 
                        <div class="text-2xl font-bold mb-1 text-white">
                             <c:out value="${userStats.commentCount}" default="0"/>
                        </div>
                        <div class="text-sm text-white">작성한 댓글</div>
                    </div>
                    
                    <div class="rounded-lg p-4 text-center" style="background-color: #7a6bfe;">
                        <div class="text-2xl font-bold mb-1 text-white">
                             <c:out value="${userStats.receivedRecomCount}" default="0"/>
                        </div>
                        <div class="text-sm text-white">받은 추천</div>
                    </div>
                </div>

                <!-- Posts Section -->
                <div class="mb-8">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">
                        작성한 게시글(<c:out value="${fn:length(recentPosts)}" default="0"/>)
                    </h3>
                    <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
                        <table class="w-full">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">번호</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">제목</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">작성일</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">글 유형</th>
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
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <c:choose>
                                                        <c:when test="${post.type eq '정보'}">
                                                            <a href="<%= contextPath %>/UI/JSP/User/InfoWatch.jsp?id=${post.postId}" 
                                                               class="text-sm text-gray-900 hover:text-primary">
                                                                <c:out value="${post.title}" />
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${post.type eq '소통'}">
                                                            <a href="<%= contextPath %>/UI/JSP/User/CommuWatch.jsp?id=${post.postId}" 
                                                               class="text-sm text-gray-900 hover:text-primary">
                                                                <c:out value="${post.title}" />
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:out value="${post.title}" />
                                                        </c:otherwise>
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
                                        <tr>
                                            <td colspan="4" class="px-6 py-12 text-center text-gray-500">
                                                <div class="bg-gray-100 h-32 rounded-lg flex items-center justify-center">
                                                    <span class="text-gray-400">작성한 게시글이 없습니다.</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Comments Section -->
                <div>
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">
                        작성한 댓글(<c:out value="${fn:length(recentComments)}" default="0"/>)
                    </h3>
                    <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
                        <table class="w-full">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">번호</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">원문 제목</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">댓글 내용 미리보기</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">작성일</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <c:choose>
                                    <c:when test="${not empty recentComments}">
                                        <c:forEach var="comment" items="${recentComments}" varStatus="status">
                                            <tr class="hover:bg-gray-50">
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                                    <c:out value="${fn:length(recentComments) - status.index}" />
                                                </td>
                                                <td class="px-6 py-4">
                                                    <c:choose>
                                                        <c:when test="${comment.originalPostType eq '정보'}">
                                                            <a href="<%= contextPath %>/UI/JSP/User/InfoWatch.jsp?id=${comment.originalPostId}" 
                                                               class="text-sm text-gray-900 hover:text-primary truncate max-w-xs block">
                                                                <c:out value="${comment.originalPostTitle}" />
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${comment.originalPostType eq '소통'}">
                                                            <a href="<%= contextPath %>/UI/JSP/User/CommuWatch.jsp?id=${comment.originalPostId}" 
                                                               class="text-sm text-gray-900 hover:text-primary truncate max-w-xs block">
                                                                <c:out value="${comment.originalPostTitle}" />
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:out value="${comment.originalPostTitle}" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 truncate max-w-sm">
                                                     <c:out value="${fn:substring(comment.content, 0, 30)}" />...
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                    <c:out value="${comment.formattedDate}" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="px-6 py-12 text-center text-gray-500">
                                                <div class="bg-gray-100 h-32 rounded-lg flex items-center justify-center">
                                                    <span class="text-gray-400">작성한 댓글이 없습니다.</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />
</body>
</html>
<%-- 소통게시판 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector, mgr.WatchUserPostMgr, mgr.PostMgr, beans.PostBean" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>   
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
		// 세션에서 User 정보 가져옴
		beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
%>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 파라미터 가져오기
    String searchKeyword = request.getParameter("keyWord");
    String searchType = request.getParameter("keyField");
    String pageNum = request.getParameter("nowPage");

    // 페이지네이션 설정
    int pageSize = 10;
    int currentPage = 1;
    if (pageNum != null && !pageNum.equals("")) {
        currentPage = Integer.parseInt(pageNum);
    }
    int start = (currentPage - 1) * pageSize;

    PostMgr postMgr = new PostMgr();
    WatchUserPostMgr watchUserPostMgr = new WatchUserPostMgr();
    Vector<PostBean> noticeList = null;
    Vector<PostBean> postList = null;
    int totalCount = 0; // 페이지네이션을 위한 '일반 게시글'의 총 개수

    try {
        // 1. 공지사항 목록 가져오기 (항상 모든 공지사항을 가져옵니다)
        noticeList = postMgr.getCommunityNotices();

        // 2. 일반 게시글 목록 가져오기 (페이징 적용) - 공지사항 제외
        // PostMgr에 공지사항을 제외한 게시글만 가져오는 메서드가 필요합니다
        if(searchKeyword != null && !searchKeyword.trim().equals("")) {
            // 검색어가 있을 경우 - 공지사항 제외하고 검색
            // [수정필요] PostMgr.java에 공지를 제외한 일반 게시글을 검색하는 메서드가 필요합니다
            postList = postMgr.searchRegularCommunityPosts(searchType, searchKeyword, start, pageSize);
            totalCount = postMgr.getSearchRegularCommunityPostCount(searchType, searchKeyword);
        } else {
            // 검색어가 없을 경우 (전체 목록) - 공지사항 제외
            // [수정필요] PostMgr.java에 공지를 제외한 일반 게시글만 페이징하여 가져오는 메서드가 필요합니다
            postList = postMgr.getRegularCommunityPosts(start, pageSize);
            totalCount = postMgr.getRegularCommunityPostCount();
        }
    } catch(Exception e) {
        e.printStackTrace();
        // 오류 발생 시 초기화
        noticeList = new Vector<PostBean>();
        postList = new Vector<PostBean>();
        totalCount = 0;
    }
    
    // 전체 페이지 수 계산 (일반 게시글 기준)
    int totalPages = (int)Math.ceil((double)totalCount / pageSize);
    if(totalPages == 0) totalPages = 1;
    
    int pageBlock = 10;
    int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
    int endPage = startPage + pageBlock - 1;
    if(endPage > totalPages) endPage = totalPages;

    pageContext.setAttribute("noticeList", noticeList);
    pageContext.setAttribute("postList", postList);
    pageContext.setAttribute("totalCount", totalCount);
    pageContext.setAttribute("pageSize", pageSize);
    pageContext.setAttribute("currentPage", currentPage);
    pageContext.setAttribute("totalPages", totalPages);
    pageContext.setAttribute("startPage", startPage);
    pageContext.setAttribute("endPage", endPage);
    pageContext.setAttribute("searchType", searchType);
    pageContext.setAttribute("searchKeyword", searchKeyword);
    pageContext.setAttribute("start", start);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
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
<body class="min-h-screen bg-gray-50">
    <jsp:include page="../Common/Header.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">소통 게시판</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <!-- Board Controls -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Top Controls -->
                <div class="flex justify-between items-center mb-4">
                    <form action="CommuBoard.jsp" method="get" class="flex items-center space-x-4">
                        <div class="relative">
                            <select name="keyField" class="appearance-none bg-gray-100 border border-gray-200 rounded px-3 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-primary">
                                <option value="p.title" <%= "p.title".equals(searchType) ? "selected" : "" %>>제목</option>
                                <option value="u.nickname" <%= "u.nickname".equals(searchType) ? "selected" : "" %>>작성자</option>
                            </select>
                            <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                        </div>
                        
                        <input type="text" name="keyWord" value="<%= searchKeyword != null ? searchKeyword : "" %>" placeholder="검색어를 입력하세요" class="bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary w-64">
                        <button type="submit" class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark transition-colors text-sm font-medium">검색</button>
                    </form>
                    
                    <div class="text-sm text-gray-600 font-medium">
                        전체 <span class="text-primary font-bold"><%= totalCount %></span>건 / <span class="text-primary font-bold"><%= currentPage %></span> 페이지
                    </div>
                </div>

                <!-- Table Header -->
                <div class="bg-gray-100 rounded-t-lg border border-gray-200">
                    <div class="grid grid-cols-5 gap-4 py-3 px-4 text-sm font-semibold text-gray-900">
                        <div class="text-center">번호</div>
                        <div class="text-left col-span-2">제목</div>
                        <div class="text-center">작성자</div>
                        <div class="text-center">작성일</div>
                    </div>
                </div>

                <!-- Table Body -->
                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg">
                    <%-- 1. 공지사항 목록 출력 --%>
                    <%
                    if(noticeList != null && !noticeList.isEmpty()) {
                        for(PostBean notice : noticeList) {
                    %>
                    <div onclick="location.href='<%= request.getContextPath() %>/commu/watch.do?id=<%= notice.getPostId() %>&nowPage=<%= currentPage %>'" 
                         class="grid grid-cols-5 gap-4 py-4 px-4 border-b border-gray-100 hover:bg-blue-50 transition-colors duration-200 cursor-pointer group items-center font-semibold bg-blue-50/50">
                        <div class="text-sm text-center font-medium">
                            <span class="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-1 rounded-full">공지</span>
                        </div>
                        <div class="text-sm text-gray-900 font-medium col-span-2 group-hover:text-primary transition-colors">
                            <%= notice.getTitle() %>
                        </div>
                        <div class="text-sm text-gray-600 text-center"><%= notice.getNickname() %></div>
                        <div class="text-sm text-gray-600 text-center"><%= notice.getFormattedDate() %></div>
                    </div>
                    <%
                            }
                        }
                    %>

                    <%-- 2. 일반 게시글 목록 출력 --%>
                    <%
                    if(postList != null && !postList.isEmpty()) {
                        for(int i = 0; i < postList.size(); i++) {
                            PostBean post = postList.get(i);
                            int num = totalCount - (start + i);
                            boolean isLast = (i == postList.size() - 1);
                    %>
                    <div onclick="location.href='<%= request.getContextPath() %>/commu/watch.do?id=<%= post.getPostId() %>&nowPage=<%= currentPage %>'" 
                         class="grid grid-cols-5 gap-4 py-4 px-4 <%= !isLast ? "border-b border-gray-100" : "" %> hover:bg-blue-50 transition-colors duration-200 cursor-pointer group items-center">
                        <div class="text-sm text-gray-900 text-center font-medium"><%= num %></div>
                        <div class="text-sm text-gray-900 font-medium col-span-2 group-hover:text-primary transition-colors">
                            <%= post.getTitle() %>
                        </div>
                        <div class="text-sm text-gray-600 text-center"><%= post.getNickname() %></div>
                        <div class="text-sm text-gray-600 text-center"><%= post.getFormattedDate() %></div>
                    </div>
                    <%
                            }
                        }
                    %>
                    
                    <%-- 3. 게시글이 전혀 없을 경우 메시지 출력 --%>
                    <%
                    if((noticeList == null || noticeList.isEmpty()) && (postList == null || postList.isEmpty())) {
                    %>
                    <div class="py-12 text-center">
                        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
                        </svg>
                        <p class="mt-4 text-gray-500 font-medium">등록된 게시글이 없습니다.</p>
                    </div>
                    <%
                        }
                    %>
                </div>

                <!-- Pagination -->
                <div class="flex justify-center items-center mt-6 space-x-2">
                    <%
                        String searchParams = "";
                        if(searchKeyword != null && !searchKeyword.trim().equals("")) {
                            searchParams = "&keyField=" + (searchType != null ? searchType : "") + "&keyWord=" + searchKeyword;
                        }
                        
                        if(startPage > pageBlock) {
                    %>
                    <button onclick="location.href='CommuBoard.jsp?nowPage=<%= startPage - 1 %><%= searchParams %>'" 
                            class="p-2 text-primary hover:bg-primary hover:text-white border border-gray-200 rounded transition-all">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                        </svg>
                    </button>
                    <%
                        }
                        
                        for(int i = startPage; i <= endPage; i++) {
                            if(i == currentPage) {
                    %>
                    <button class="px-4 py-2 text-white bg-primary border border-primary rounded font-medium shadow-sm">
                        <%= i %>
                    </button>
                    <%
                            } else {
                    %>
                    <button onclick="location.href='CommuBoard.jsp?nowPage=<%= i %><%= searchParams %>'" 
                            class="px-4 py-2 text-primary hover:bg-primary hover:text-white border border-gray-200 rounded transition-all font-medium">
                        <%= i %>
                    </button>
                    <%
                            }
                        }
                        
                        if(endPage < totalPages) {
                    %>
                    <button onclick="location.href='CommuBoard.jsp?nowPage=<%= endPage + 1 %><%= searchParams %>'" 
                            class="p-2 text-primary hover:bg-primary hover:text-white border border-gray-200 rounded transition-all">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                        </svg>
                    </button>
                    <%
                        }
                    %>
                </div>

                <!-- Write Post Button -->
                <div class="flex justify-end mt-6">
                    <a href="CommuWrite.jsp" class="bg-primary text-white px-6 py-3 rounded-lg hover:bg-primary-dark transition-colors font-medium inline-flex items-center space-x-2 shadow-sm hover:shadow-md">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path>
                        </svg>
                        <span>글 작성</span>
                    </a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

</body>
</html>
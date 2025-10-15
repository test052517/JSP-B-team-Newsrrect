<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="beans.PostBean" %>
<%@ page import="mgr.PostMgr" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>정보 검증 게시판 - Newsrrect</title>
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
<%
    // 세션 체크
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if(userIdObj == null) {
        response.sendRedirect(request.getContextPath() + "/UI/JSP/Login/Login.jsp");
        return;
    }
    
    // 페이징 및 검색 파라미터
    int pageSize = 10;
    String pageNum = request.getParameter("page");
    if(pageNum == null) pageNum = "1";
    int currentPage = Integer.parseInt(pageNum);
    int start = (currentPage - 1) * pageSize;
    String searchType = request.getParameter("searchType");
    String searchKeyword = request.getParameter("searchKeyword");

    // 데이터 조회 로직
    PostMgr postMgr = new PostMgr();
    Vector<PostBean> noticeList = null;       // 공지사항 목록
    Vector<PostBean> regularPostList = null;  // 일반 게시글 목록
    int totalCount = 0;                       // 일반 게시글의 총 개수 (페이징 기준)
    
    try {
        // 1. 공지사항 목록 가져오기 (항상 모든 공지사항을 가져옵니다)
        noticeList = postMgr.getVerificationNotices();

        // 2. 일반 게시글 목록 가져오기 (페이징 및 검색 적용)
        if(searchKeyword != null && !searchKeyword.trim().equals("")) {
            // 검색어가 있을 경우
            regularPostList = postMgr.searchRegularVerificationPosts(searchType, searchKeyword, start, pageSize);
            totalCount = postMgr.getSearchRegularVerificationPostCount(searchType, searchKeyword);
        } else {
            // 검색어가 없을 경우
            regularPostList = postMgr.getRegularVerificationPosts(start, pageSize);
            totalCount = postMgr.getRegularVerificationPostCount();
        }
    } catch(Exception e) {
        e.printStackTrace();
        noticeList = new Vector<PostBean>();
        regularPostList = new Vector<PostBean>();
        totalCount = 0;
    }
    
    int totalPages = (int)Math.ceil((double)totalCount / pageSize);
    if(totalPages == 0) totalPages = 1;
%>
    <!-- Header -->
    <jsp:include page="../Common/AdminHeader.jsp" />

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">정보 검증 게시판</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <!-- Board Controls -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Top Controls -->
                <div class="flex justify-between items-center mb-4">
                    <form action="AdminInfo.jsp" method="get" class="flex items-center space-x-4">
                        <div class="relative">
                            <select name="searchType" class="appearance-none bg-gray-100 border border-gray-200 rounded px-3 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-primary">
                                <option value="" <%= (searchType == null || searchType.equals("")) ? "selected" : "" %>>전체</option>
                                <option value="title" <%= "title".equals(searchType) ? "selected" : "" %>>제목</option>
                                <%-- [수정] 검색 value를 nickname으로 변경 --%>
                                <option value="nickname" <%= "nickname".equals(searchType) ? "selected" : "" %>>작성자</option>
                            </select>
                            <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                        </div>
                        
                        <input type="text" name="searchKeyword" value="<%= searchKeyword != null ? searchKeyword : "" %>" placeholder="검색어를 입력하세요" class="bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary w-64">
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
                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg divide-y divide-gray-100">
                    <%
                        boolean noPosts = (noticeList == null || noticeList.isEmpty()) && (regularPostList == null || regularPostList.isEmpty());
                        if(noPosts) {
                    %>
                    <!-- 게시글이 하나도 없을 때 -->
                    <div class="py-12 text-center">
                        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        <p class="mt-4 text-gray-500 font-medium">등록된 게시글이 없습니다.</p>
                    </div>
                    <%
                        } else {
                            // 1. 공지사항 목록 출력
                            if(noticeList != null && !noticeList.isEmpty()) {
                                for(PostBean notice : noticeList) {
                    %>
                     <div onclick="location.href='AdminCommuWatch.jsp?postId=<%= notice.getPostId() %>'" 
                         class="grid grid-cols-5 gap-4 py-4 px-4 hover:bg-blue-50 transition-colors duration-200 cursor-pointer group items-center font-semibold bg-blue-50/50">
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
                            
                            // 2. 일반 게시글 목록 출력
                            if(regularPostList != null && !regularPostList.isEmpty()) {
                                for(int i = 0; i < regularPostList.size(); i++) {
                                    PostBean bean = regularPostList.get(i);
                                    int num = totalCount - (start + i);
                    %>
                    <div onclick="location.href='AdminInfoWatch.jsp?postId=<%= bean.getPostId() %>'" 
                         class="grid grid-cols-5 gap-4 py-4 px-4 hover:bg-blue-50 transition-colors duration-200 cursor-pointer group">
                        <div class="text-sm text-gray-900 text-center font-medium"><%= num %></div>
                        <div class="text-sm text-gray-900 font-medium col-span-2 group-hover:text-primary transition-colors truncate"><%= bean.getTitle() %></div>
                        <div class="text-sm text-gray-600 text-center"><%= bean.getNickname() %></div>
                        <div class="text-sm text-gray-600 text-center"><%= bean.getFormattedDate() %></div>
                    </div>
                    <%
                                }
                            }
                        }
                    %>
                </div>

                <!-- Pagination -->
                <div class="flex justify-center items-center mt-6 space-x-2">
                    <%
                        int pageBlock = 10;
                        int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
                        int endPage = startPage + pageBlock - 1;
                        if(endPage > totalPages) endPage = totalPages;
                        
                        String searchParams = "";
                        if(searchKeyword != null && !searchKeyword.trim().equals("")) {
                            searchParams = "&searchType=" + (searchType != null ? searchType : "") + "&searchKeyword=" + searchKeyword;
                        }
                        
                        if(startPage > pageBlock) {
                    %>
                    <button onclick="location.href='AdminInfo.jsp?page=<%= startPage - 1 %><%= searchParams %>'" 
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
                    <button onclick="location.href='AdminInfo.jsp?page=<%= i %><%= searchParams %>'" 
                            class="px-4 py-2 text-primary hover:bg-primary hover:text-white border border-gray-200 rounded transition-all font-medium">
                        <%= i %>
                    </button>
                    <%
                            }
                        }
                        
                        if(endPage < totalPages) {
                    %>
                    <button onclick="location.href='AdminInfo.jsp?page=<%= endPage + 1 %><%= searchParams %>'" 
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
                    <a href="AdminInfoWrite.jsp" class="bg-primary text-white px-6 py-3 rounded-lg hover:bg-primary-dark transition-colors font-medium inline-flex items-center space-x-2 shadow-sm hover:shadow-md">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path>
                        </svg>
                        <span>글 작성</span>
                    </a>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />
</body>
</html>

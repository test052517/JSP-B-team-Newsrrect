<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>정보 검증 게시판 관리 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="CSS/fonts.css">
    <link rel="stylesheet" href="styles/fonts.css">
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
<body class="min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <!-- Logo - Centered -->
                <div class="flex-shrink-0">
                    <a href="AdminMainPage.jsp"><h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1></a>
                </div>
                
                <!-- User Menu - Absolute positioned right -->
                <div class="absolute right-0 flex items-center space-x-4">
                    <a href="#" onclick="logout()" class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그아웃
                    </a>
                </div>
            </div>
        </div>
    </header>
    
    <!-- Navigation -->
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-16 py-4">
                <a href="AdminInfo.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="AdminCommu.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="AdminInfoBoard.jsp" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded font-paperozi-medium">정보 검증 게시판 관리</a>
                <a href="AdminUserReport.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">유저 / 신고 관리</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">정보 검증 게시판 관리</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <!-- Board Controls -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Top Controls -->
                <div class="flex justify-between items-center mb-4">
                    <form action="AdminInfoBoard.jsp" method="get" class="flex items-center space-x-4">
                        <!-- Dropdown for category/filter -->
                        <div class="relative">
                            <select name="searchType" class="appearance-none bg-gray-100 border border-gray-200 rounded px-3 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-primary">
                                <option value="">전체</option>
                                <option value="title">제목</option>
                                <option value="author">작성자</option>
                            </select>
                            <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                        </div>
                        
                        <!-- Search Input -->
                        <input type="text" name="searchKeyword" placeholder="검색어를 입력하세요" class="bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary w-64">
                        <button type="submit" class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark transition-colors">검색</button>
                    </form>
                    
                    <!-- Page Info -->
                    <div class="text-sm text-gray-600">
                        <%
                            Integer totalCount = (Integer) request.getAttribute("totalCount");
                            Integer currentPage = (Integer) request.getAttribute("currentPage");
                            if (totalCount == null) totalCount = 10;
                            if (currentPage == null) currentPage = 1;
                        %>
                        전체 <%= totalCount %> / <%= currentPage %> 페이지
                    </div>
                </div>

                <!-- Table Header -->
                <div class="bg-gray-100 rounded-t-lg">
                    <div class="grid grid-cols-4 gap-4 py-3 px-4 text-sm font-semibold text-gray-900">
                        <div class="text-left">번호</div>
                        <div class="text-left">제목</div>
                        <div class="text-left">작성자</div>
                        <div class="text-left">작성일</div>
                    </div>
                </div>

                <!-- Table Body -->
                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg">
                    <%
                        List<?> pendingPosts = (List<?>) request.getAttribute("pendingPosts");
                        if (pendingPosts != null && !pendingPosts.isEmpty()) {
                            // 실제 데이터 처리
                        } else {
                            // 샘플 데이터
                    %>
                    <!-- Table Row -->
                    <div onclick="location.href='AdminInfoSelect.jsp?postId=1'" class="grid grid-cols-4 gap-4 py-3 px-4 border-b border-gray-100 hover:bg-gray-50 transition-colors duration-200 cursor-pointer">
                        <div class="text-sm text-gray-900">1</div>
                        <div class="text-sm text-gray-900 font-medium">승인 대기중인 게시글</div>
                        <div class="text-sm text-gray-600">user1</div>
                        <div class="text-sm text-gray-600">09.25</div>
                    </div>
                    <%
                        }
                    %>
                </div>

                <!-- Pagination -->
                <div class="flex justify-center items-center mt-6 space-x-2">
                    <div class="flex space-x-1">
                        <%
                            Integer totalPages = (Integer) request.getAttribute("totalPages");
                            if (totalPages == null) totalPages = 9;
                            
                            for (int i = 1; i <= Math.min(totalPages, 9); i++) {
                                String activeClass = (i == currentPage) ? "text-white bg-primary" : "text-primary hover:text-white hover:bg-primary";
                        %>
                            <button onclick="location.href='AdminInfoBoard.jsp?page=<%= i %>'" class="px-3 py-2 text-sm font-medium <%= activeClass %> border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[<%= i %>]</button>
                        <%
                            }
                        %>
                        <span class="px-2 text-gray-400">....</span>
                    </div>
                    <button class="ml-4 px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />

    <script>
        function logout() {
            if(confirm('로그아웃 하시겠습니까?')) {
                location.href = 'Login.jsp';
            }
        }
    </script>
</body>
</html>
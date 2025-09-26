<%-- 소통게시판 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/fonts.css">
	<link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/styles.css">

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
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <div class="flex-shrink-0">
                    <a href="../../Html/MainPage.html"><h1 class="text-2xl font-bold text-primary" style="font-family: 'Aggravo', sans-serif;">Newsrrect</h1></a>
                </div>
                
                <div class="absolute right-0 flex items-center space-x-4">
                    <button class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그아웃
                    </button>
                </div>
            </div>
        </div>
    </header>
    
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-20 py-4">
                <a href="InfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="CommuBoard.jsp" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded font-paperozi-medium">소통 게시판</a>
                <a href="MyPage.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">마이 페이지</a>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="flex justify-between items-center mb-4">
                    <div class="flex items-center space-x-4">
                        <div class="relative">
                            <select class="appearance-none bg-gray-100 border border-gray-200 rounded px-3 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-primary">
                                <option>전체</option>
                                <option>제목</option>
                                <option>작성자</option>
                            </select>
                            <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                                </svg>
                            </div>
                        </div>
                        
                        <input type="text" placeholder="검색어를 입력하세요" class="bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary w-64">
                    </div>
                    
                    <div class="text-sm text-gray-600">
                        전체 10 / 1 페이지
                    </div>
                </div>

                <div class="bg-gray-100 rounded-t-lg">
                    <div class="grid grid-cols-4 gap-4 py-3 px-4 text-sm font-semibold text-gray-900">
                        <div class="text-left">번호</div>
                        <div class="text-left">제목</div>
                        <div class="text-left">작성자</div>
                        <div class="text-left">작성일</div>
                    </div>
                </div>

                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg">
                    <a href="CommuWatch.jsp" class="grid grid-cols-4 gap-4 py-3 px-4 border-b border-gray-100 hover:bg-gray-50 transition-colors duration-200 cursor-pointer">
                        <div class="text-sm text-gray-900">1</div>
                        <div class="text-sm text-gray-900 font-medium">test제목</div>
                        <div class="text-sm text-gray-600">user1</div>
                        <div class="text-sm text-gray-600">09.24</div>
                    </a>
                </div>

                <div class="flex justify-center items-center mt-6 space-x-2">
                    <div class="flex space-x-1">
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[1]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[2]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[3]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[4]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[5]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[6]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[7]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[8]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[9]</button>
                        <span class="px-2 text-gray-400">....</span>
                    </div>
                    <button class="ml-4 px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                        </svg>
                    </button>
                </div>

                <div class="flex justify-end mt-6">
                    <a href="../JSP/WritePost.jsp" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary-dark transition-colors font-medium inline-block">
                        글 작성
                    </a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

</body>
</html>
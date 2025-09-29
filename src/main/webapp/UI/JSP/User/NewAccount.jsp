<%-- 회원가입페이지 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>

    <%-- CSS 경로를 절대 경로로 수정하여 404 오류 방지 --%>
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
                    <a href="../../Html/MainPage.html"><h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1></a>
                </div>
                
                <div class="absolute right-0 flex items-center space-x-4">
                    <button class="text-primary hover:text-primary-dark text-sm font-medium" onclick="if(typeof loadLoginContent === 'function') { loadLoginContent(); } else { window.location.href = '../Login.jsp'; }">
                        로그인
                    </button>
                </div>
            </div>
        </div>
    </header>
    
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-20 py-4">
                <a href="InfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="CommuBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="MyPage.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">마이 페이지</a>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex justify-center items-center min-h-96">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 w-full max-w-md">
                <div class="space-y-6">
                	<div>
                        <label for="email" class="block text-sm font-medium text-gray-900 mb-2">이메일</label>
                        <input type="email" id="email" name="email" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="이메일을 입력하세요">
                    </div>
                    
                    <div>
                        <label for="nickname" class="block text-sm font-medium text-gray-900 mb-2">닉네임</label>
                        <div class="flex space-x-2">
                            <input type="text" id="nickname" name="nickname" class="flex-1 px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="닉네임을 입력하세요">
                            <button class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors text-sm font-medium">
                                중복확인
                            </button>
                        </div>
                    </div>
                    
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-900 mb-2">비밀번호</label>
                        <input type="password" id="password" name="password" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="비밀번호를 입력하세요">
                    </div>
                    
                    <div>
                        <label for="confirm-password" class="block text-sm font-medium text-gray-900 mb-2">비밀번호 확인</label>
                        <input type="password" id="confirm-password" name="confirm-password" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="비밀번호를 다시 입력하세요">
                    </div>
                    
                    <button class="w-full bg-primary text-white py-2 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                        회원가입
                    </button>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <script>
        // HTML 파일의 fetch 코드는 JSP include로 대체되어 제거되었습니다.
    </script>
</body>
</html>
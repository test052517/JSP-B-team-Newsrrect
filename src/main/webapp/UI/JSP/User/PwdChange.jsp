<%-- 비밀번호변경 페이지 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>비밀번호 변경 - Newsrrect</title>
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
<body class="bg-white min-h-screen">
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <div class="flex-shrink-0">
                    <a href="../../JSP/MainPage.jsp"><h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1></a>
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
                <a href="CommuBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="MyPage.jsp" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded font-paperozi-medium">마이 페이지</a>
            </div>
        </div>
    </nav>

    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="bg-white rounded-lg shadow-sm">
            <div class="p-8">
                <h2 class="text-3xl font-bold text-primary mb-8">비밀번호 변경</h2>
                
                <form class="space-y-6">
                    <div>
                        <label for="userId" class="block text-sm font-medium text-gray-700 mb-2">아이디</label>
                        <input type="text" id="userId" value="user1" readonly class="w-full px-4 py-3 bg-gray-100 border border-gray-200 rounded-lg text-gray-500 cursor-not-allowed">
                    </div>

                    <div>
                        <label for="currentPassword" class="block text-sm font-medium text-gray-700 mb-2">현재 비밀번호</label>
                        <input type="password" id="currentPassword" class="w-full px-4 py-3 bg-gray-100 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
                    </div>

                    <div class="border-t border-gray-200 my-6"></div>

                    <div>
                        <label for="newPassword" class="block text-sm font-medium text-gray-700 mb-2">새 비밀번호</label>
                        <input type="password" id="newPassword" class="w-full px-4 py-3 bg-gray-100 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
                    </div>

                    <div>
                        <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">비밀번호 확인</label>
                        <input type="password" id="confirmPassword" class="w-full px-4 py-3 bg-gray-100 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent">
                    </div>

                    <div class="flex justify-end pt-4">
                        <button type="submit" class="bg-gray-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-gray-700 transition-colors">
                            변경
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <footer class="bg-white border-t border-gray-200 mt-16">
        <%-- Footer.html 내용을 Common/Footer.jsp로 include 합니다. --%>
        <jsp:include page="../Common/Footer.jsp" />
    </footer>

    <script>
        document.querySelector('form').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const currentPassword = document.getElementById('currentPassword').value;
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (!currentPassword) {
                alert('현재 비밀번호를 입력해주세요.');
                return;
            }
            
            if (!newPassword) {
                alert('새 비밀번호를 입력해주세요.');
                return;
            }
            
            if (newPassword !== confirmPassword) {
                alert('새 비밀번호와 비밀번호 확인이 일치하지 않습니다.');
                return;
            }
            
            if (newPassword.length < 6) {
                alert('새 비밀번호는 6자 이상이어야 합니다.');
                return;
            }
            
            alert('비밀번호가 성공적으로 변경되었습니다.');
            
            document.getElementById('currentPassword').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';
        });
    </script>
</body>
</html>
<%-- 정보검증게시판 작성페이지 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 작성 - 정보 검증 게시판 - Newsrrect</title>
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
    <%-- Header.html 내용을 Common/Header.jsp로 include --%>
    <jsp:include page="../Common/Header.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <form class="space-y-6">
                    <div>
                        <label for="title" class="block text-sm font-medium text-gray-900 mb-2">제목</label>
                        <input type="text" id="title" name="title" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="제목을 입력하세요">
                    </div>
                    
                    <div>
                        <label for="content" class="block text-sm font-medium text-gray-900 mb-2">내용</label>
                        <textarea id="content" name="content" rows="15" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary resize-none" placeholder="글내용 들어갈곳"></textarea>
                    </div>
                    
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="goBack()" class="px-6 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors font-medium">
                            취소
                        </button>
                        <button type="submit" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors font-medium">
                            작성
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <script>
        function goBack() {
            history.back();
        }
    </script>
</body>
</html>
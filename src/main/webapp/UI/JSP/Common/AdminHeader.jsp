<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="bg-white shadow-sm border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-center items-center h-16 relative">
            <div class="flex-shrink-0">
                <a href="AdminMainPage.html"><h1 class="text-2xl font-bold text-primary" style="font-family: 'Aggravo', sans-serif;">Newsrrect</h1></a>
            </div>
            
            <div class="absolute right-0 flex items-center space-x-4">
                <a href="#" onclick="loadLoginContent()" class="text-primary hover:text-primary-dark text-sm font-medium">
                    로그인
                </a>
            </div>
        </div>
    </div>
</header>

<nav class="bg-white border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-center space-x-16 py-4">
            <a href="InfoBoard.html" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium" style="font-family: 'Paperozi', sans-serif;">정보 검증 게시판</a>
            <a href="CommuBoard.html" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium" style="font-family: 'Paperozi', sans-serif;">소통 게시판</a>
            <a href="AdminInfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium" style="font-family: 'Paperozi', sans-serif;">정보 검증 게시판 관리</a>
            <a href="AdminUserReport.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium" style="font-family: 'Paperozi', sans-serif;">유저 / 신고 관리</a>
        </div>
    </div>
</nav>
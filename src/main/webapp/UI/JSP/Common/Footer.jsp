
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<footer class="bg-[#392385] text-white py-12 mt-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
                <h4 class="text-lg font-semibold mb-4 font-newsrrect">Newsrrect</h4>
                <p class="text-white text-sm font-paperozi-regular">
                    AI 생성 정보를 검증하고 거짓 정보를 구분하는 신뢰할 수 있는 커뮤니티 플랫폼입니다.
                </p>
            </div>
            
            <div>
                <h5 class="font-medium mb-4 font-paperozi-medium">주요 페이지</h5>
                <ul class="space-y-2 text-sm text-white font-paperozi-regular">
                    <li>
                        <a href="<%= request.getContextPath() %>/UI/Html/MainPage.html" 
                           class="hover:text-gray-200 transition-colors">
                           메인 페이지
                        </a>
                    </li>
                    <li>
                        <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoBoard.jsp" 
                           class="hover:text-gray-200 transition-colors">
                           정보 검증 게시판
                        </a>
                    </li>
                    <li>
                        <a href="<%= request.getContextPath() %>/UI/JSP/User/CommuBoard.jsp" 
                           class="hover:text-gray-200 transition-colors">
                           소통 게시판
                        </a>
                    </li>
                    <li>
                        <a href="<%= request.getContextPath() %>/UI/JSP/User/MyPage.jsp" 
                           class="hover:text-gray-200 transition-colors">
                           마이페이지
                        </a>
                    </li>
                </ul>
            </div>
            
            <div>
                <h5 class="font-medium mb-4 font-paperozi-medium">커뮤니티</h5>
                <div class="relative group">
                    <a href="#" class="hover:text-gray-200 text-sm text-white block py-2 font-paperozi-regular">
                        공지사항
                    </a>
                    <div class="absolute left-0 top-full mt-1 bg-[#392385] opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 ease-in-out z-50 min-w-[120px]">
                        <ul class="py-2">
                            <li>
                                <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoBoard.jsp" 
                                   class="block px-4 py-2 text-sm text-white hover:bg-white/10 transition-colors duration-200 font-paperozi-regular">
                                   정보 검증
                                </a>
                            </li>
                            <li>
                                <a href="<%= request.getContextPath() %>/UI/JSP/User/CommuBoard.jsp" 
                                   class="block px-4 py-2 text-sm text-white hover:bg-white/10 transition-colors duration-200 font-paperozi-regular">
                                   소통
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div>
                <h5 class="font-medium mb-4 font-paperozi-medium">연락처</h5>
                <ul class="space-y-2 text-sm text-white font-paperozi-regular">
                    <li class="text-2xl font-bold">051-1234-5678</li>
                    <li>email : Newsrrect@gmail.com</li>
                </ul>
            </div>
        </div>
        
        <div class="border-t border-white mt-8 pt-8 text-center text-sm text-white">
            <p class="font-newsrrect">&copy; 2025 Newsrrect. All rights reserved.</p>
        </div>
    </div>
</footer>

<script>
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }

    function checkLoginAndRedirect(event) {
        // 로그인 상태 확인 (서버에서 확인)
        const isLoggedIn = ${sessionScope.user != null ? 'true' : 'false'};
        
        if (!isLoggedIn) {
            event.preventDefault();
            window.location.href = '<%= request.getContextPath() %>/UI/Html/Login.html';
        }
    }
</script>

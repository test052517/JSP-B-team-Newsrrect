<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header class="bg-white shadow-sm border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-center items-center h-16 relative">
            <div class="flex-shrink-0">
                <a href="<%= request.getContextPath() %>/UI/JSP/MainPage.jsp" class="hover:opacity-80 transition-opacity duration-200">
                    <h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1>
                </a>
            </div>
            
            <div class="absolute right-0 flex items-center space-x-4">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <span class="text-gray-700 text-sm">${sessionScope.user.username}님</span>
                        <a href="<%= request.getContextPath() %>/logout.do" 
                           class="text-primary hover:text-[#4c63e7] text-sm font-medium font-paperozi-medium transition-colors duration-200">
                            로그아웃
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="<%= request.getContextPath() %>/UI/Html/Login.html" 
                           class="text-primary hover:text-[#4c63e7] text-sm font-medium font-paperozi-medium transition-colors duration-200">
                            로그인
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</header>

<nav class="bg-white border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-center space-x-20 py-4">
            <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoBoard.jsp" 
               class="nav-link text-primary hover:text-white hover:bg-[#7d8ff9] px-3 py-2 text-sm font-medium font-paperozi-medium rounded transition-all duration-200 ease-in-out">
               정보 검증 게시판
            </a>
            <a href="<%= request.getContextPath() %>/UI/JSP/User/CommuBoard.jsp" 
               class="nav-link text-primary hover:text-white hover:bg-[#7d8ff9] px-3 py-2 text-sm font-medium font-paperozi-medium rounded transition-all duration-200 ease-in-out">
               소통 게시판
            </a>
            <a href="<%= request.getContextPath() %>/UI/JSP/User/MyPage.jsp" 
               class="nav-link text-primary hover:text-white hover:bg-[#7d8ff9] px-3 py-2 text-sm font-medium font-paperozi-medium rounded transition-all duration-200 ease-in-out">
               마이 페이지
            </a>
        </div>
    </div>
</nav>

<style>
    /* Active 상태의 링크에도 hover 효과 적용 */
    nav a.text-white.bg-primary {
        background-color: #5d74f8;
    }
    
    nav a.text-white.bg-primary:hover {
        background-color: #4c63e7 !important;
        transform: scale(1.02);
        box-shadow: 0 2px 4px rgba(93, 116, 248, 0.3);
    }
    
    /* 일반 링크 hover 효과 */
    nav a.nav-link:hover {
        transform: translateY(-1px);
        box-shadow: 0 2px 4px rgba(93, 116, 248, 0.2);
    }
    
    /* 로고 hover 효과 */
    header h1 {
        transition: all 0.3s ease;
    }
    
    header a:hover h1 {
        transform: scale(1.05);
    }
</style>
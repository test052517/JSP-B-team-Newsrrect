<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
		// 세션에서 User 정보 가져옴
		String role ="사용자";
		try{
			beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
			if(user.getRole()!=null)
			role = user.getRole();
			//System.out.println(role);	
		}catch(Exception e){
			//System.err.println("비로그인 상태");
		}
%>

<footer class="bg-[#392385] text-white py-8">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
            <!-- 회사 소개 -->
            <div>
                <h4 class="text-xl font-semibold mb-3 font-newsrrect">Newsrrect</h4>
                <p class="text-white text-sm font-paperozi-regular leading-relaxed">
                    AI 생성 정보를 검증하고 거짓 정보를 구분하는 신뢰할 수 있는 커뮤니티 플랫폼입니다.
                </p>
            </div>

            <!-- 주요 페이지 -->
            <div>
                <h5 class="font-semibold mb-3 font-paperozi-medium">주요 페이지</h5>
                <ul class="space-y-2 text-sm text-white font-paperozi-regular">
                    <li>
                    	<%if(role.equals("관리자")){ %>
                    	   <a href="<%= request.getContextPath() %>/UI/JSP/Admin/AdminMainPage.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                            메인 페이지
                        </a>
                    	<%} else{%>
                        <a href="<%= request.getContextPath() %>/UI/JSP/MainPage.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                            메인 페이지
                        </a>
                        <%}%>
                    </li>
                    <li>
                    	<%if(role.equals("관리자")){ %>
                    	    <a href="<%=request.getContextPath()%>/UI/JSP/Admin/AdminInfo.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                            정보 검증 게시판
                        </a>
                    	
                    	<%}else{ %>
                        <a href="${pageContext.request.contextPath}/info/watch.do"
                           class="hover:text-gray-300 transition-colors inline-block">
                            정보 검증 게시판
                        </a>
                        <%}%>
                    </li>
                    <li>
                    	<%if(role.equals("관리자")){ %>
                    	 <a href="<%= request.getContextPath() %>/UI/JSP/Admin/AdminCommu.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                            소통 게시판
                        </a>
                    	<%}else{%>
                        <a href="<%= request.getContextPath() %>/UI/JSP/User/CommuBoard.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                            소통 게시판
                        </a>
                        <%}%>
                    </li>
                    <li>
                    	<%if(role.equals("관리자")){ %>
                    		<a href="<%= request.getContextPath() %>/UI/JSP/Admin/AdminInfoBoard.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                            정보 검증 게시판 관리
                        </a>
                    	<%}else{%>
                        <a href="<%= request.getContextPath() %>/Servlet/MyPageServlet"
                           class="hover:text-gray-300 transition-colors inline-block">
                            마이페이지
                        </a>
                        <%}%>
                    </li>
                    <%if(role.equals("관리자")){ %>
                    <li>
                    	<a href="<%= request.getContextPath() %>/UI/JSP/Admin/AdminUserReport.jsp"
                           class="hover:text-gray-300 transition-colors inline-block">
                           유저/신고 관리
                        </a>
                    </li>
                    <%}%>
                </ul>
            </div>

            <!-- 연락처 -->
            <div>
                <h5 class="font-semibold mb-3 font-paperozi-medium">연락처</h5>
                <ul class="space-y-2 text-sm text-white font-paperozi-regular">
                    <li class="text-lg font-bold">051-1234-5678</li>
                    <li>Newsrrect@gmail.com</li>
                </ul>
            </div>
        </div>

        <!-- 하단 저작권 -->
        <div class="border-t border-white/30 pt-6 text-center">
            <p class="text-sm text-white/90 font-newsrrect">
                &copy; 2025 Newsrrect. All rights reserved.
            </p>
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
        const isLoggedIn = ${sessionScope.user != null ? 'true' : 'false'};
        
        if (!isLoggedIn) {
            event.preventDefault();
            window.location.href = '<%= request.getContextPath() %>/UI/Html/Login.html';
        }
    }
</script>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="mgr.UserMgr" %>
<%@ page import="beans.UserBean" %>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String errorMessage = null;
String successMessage = null;

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (email != null && !email.trim().isEmpty() && password != null && !password.trim().isEmpty()) {
        try {
            UserMgr userMgr = new UserMgr();
            UserBean user = userMgr.Login(email.trim(), password.trim());
            
            if (user != null) {
                // 세션에 사용자 정보 저장
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("email", user.getEmail());
                session.setAttribute("role", user.getRole());
                session.setAttribute("nickname", user.getNickname());
                
                // 로그인 성공 로그
                System.out.println("로그인 성공! 사용자: " + user.getNickname() + ", 역할: " + user.getRole());
                
                // 역할에 따른 리다이렉트
                String redirectUrl;
                if ("관리자".equals(user.getRole())) {
                    redirectUrl = "../JSP/AdminMainPage.jsp";
                } else {
                    redirectUrl = "../JSP/MainPage.jsp";
                }
                
                System.out.println("리다이렉트 URL: " + redirectUrl);
                response.sendRedirect(redirectUrl);
                return;
            } else {
                errorMessage = "이메일 또는 비밀번호가 올바르지 않습니다.";
            }
        } catch (Exception e) {
            errorMessage = "로그인 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
            e.printStackTrace(); // 서버 로그에 오류 기록
        }
    } else {
        errorMessage = "이메일과 비밀번호를 모두 입력해주세요.";
    }
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="CSS/fonts.css">
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
    <div id="header"></div>
    
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex justify-center items-center min-h-96">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 w-full max-w-md">
                <div class="text-center mb-8">
                    <h1 class="text-2xl font-bold text-gray-900 mb-2">로그인</h1>
                    <p class="text-gray-600">Newsrrect에 오신 것을 환영합니다</p>
                </div>

                <form method="POST" action="Login.jsp" class="space-y-6" onsubmit="return validateForm()">
                    <!-- 오류 메시지 -->
                    <% if (errorMessage != null) { %>
                    <div class="bg-red-50 border border-red-200 rounded-md p-3">
                        <div class="text-red-800 text-sm"><%= errorMessage %></div>
                    </div>
                    <% } %>

                    <!-- 성공 메시지 -->
                    <% if (successMessage != null) { %>
                    <div class="bg-green-50 border border-green-200 rounded-md p-3">
                        <div class="text-green-800 text-sm"><%= successMessage %></div>
                    </div>
                    <% } %>

                    <!-- 이메일 입력 -->
                    <div>
                        <label for="email" class="block text-sm font-medium text-gray-900 mb-2">이메일</label>
                        <input 
                            type="email" 
                            id="email" 
                            name="email" 
                            required
                            class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary transition-colors" 
                            placeholder="이메일을 입력하세요"
                            value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                        >
                    </div>

                    <!-- 비밀번호 입력 -->
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-900 mb-2">비밀번호</label>
                        <input 
                            type="password" 
                            id="password" 
                            name="password" 
                            required
                            class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary transition-colors" 
                            placeholder="비밀번호를 입력하세요"
                        >
                    </div>

                    <!-- 로그인 버튼 -->
                    <button 
                        type="submit" 
                        class="w-full bg-primary text-white py-2 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
                    >
                        로그인
                    </button>

                    <!-- 회원가입 링크 -->
                    <div class="text-center">
                        <p class="text-sm text-gray-600">
                            계정이 없으신가요? 
                            <a href="../Html/Join.html" class="text-primary hover:text-primary-dark font-medium">회원가입</a>
                        </p>
                    </div>
                </form>

                <!-- 테스트 계정 안내 (개발용) -->
                <div class="mt-6 p-3 bg-gray-50 rounded-md">
                    <p class="text-xs text-gray-600 mb-1">테스트 계정:</p>
                    <p class="text-xs text-gray-500">이메일: test@example.com</p>
                    <p class="text-xs text-gray-500">비밀번호: hashed_password_123</p>
                </div>
            </div>
        </div>
    </main>

    <div id="footer"></div>
    
    <script>
        // 폼 유효성 검사
        function validateForm() {
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value.trim();

            if (!email) {
                alert('이메일을 입력해주세요.');
                return false;
            }

            if (!password) {
                alert('비밀번호를 입력해주세요.');
                return false;
            }

            // 이메일 형식 검사
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert('올바른 이메일 형식을 입력해주세요.');
                return false;
            }

            return true;
        }

        // 헤더와 푸터 로드 (오류 방지 버전)
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM 로딩 완료');
            
            // 헤더 로드
            const headerElement = document.getElementById('header');
            const footerElement = document.getElementById('footer');
            
            if (headerElement) {
                console.log('헤더 엘리먼트 찾음, 로딩 시작...');
                
                fetch('../JSP/Common/Header.jsp')
                    .then(response => {
                        console.log('헤더 응답 상태:', response.status);
                        if (response.ok) {
                            return response.text();
                        }
                        throw new Error(`Header load failed with status: ${response.status}`);
                    })
                    .then(html => {
                        console.log('헤더 HTML 로딩 성공');
                        headerElement.innerHTML = html;
                        
                        // JSP 폴더에서 접근할 수 있도록 링크 수정
                        const headerLinks = document.querySelectorAll('#header a');
                        headerLinks.forEach(link => {
                            const href = link.getAttribute('href');
                            if (href && !href.startsWith('http') && !href.startsWith('../') && !href.startsWith('/')) {
                                link.setAttribute('href', '../Html/' + href);
                            }
                        });
                        console.log('헤더 링크 수정 완료');
                    })
                    .catch(error => {
                        console.error('헤더 로드 실패:', error);
                        // 헤더 로딩 실패시 기본 헤더 표시
                        headerElement.innerHTML = `
                            <div class="bg-white border-b border-gray-200">
                                <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                                    <div class="flex justify-between items-center py-4">
                                        <h1 class="text-xl font-bold text-primary">Newsrrect</h1>
                                        <nav>
                                            <a href="../Html/MainPage.html" class="text-gray-700 hover:text-primary">메인</a>
                                        </nav>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
            } else {
                console.warn('헤더 엘리먼트를 찾을 수 없습니다. id="header"가 있는지 확인하세요.');
            }
            
            // 푸터 로드
            if (footerElement) {
                console.log('푸터 엘리먼트 찾음, 로딩 시작...');
                
                fetch('../JSP/Common/Footer.jsp')
                    .then(response => {
                        console.log('푸터 응답 상태:', response.status);
                        if (response.ok) {
                            return response.text();
                        }
                        throw new Error(`Footer load failed with status: ${response.status}`);
                    })
                    .then(html => {
                        console.log('푸터 HTML 로딩 성공');
                        footerElement.innerHTML = html;
                    })
                    .catch(error => {
                        console.error('푸터 로드 실패:', error);
                        // 푸터 로딩 실패시 기본 푸터 표시
                        footerElement.innerHTML = `
                            <footer class="bg-gray-50 border-t border-gray-200">
                                <div class="max-w-7xl mx-auto px-4 py-6 text-center text-gray-600">
                                    <p>&copy; 2024 Newsrrect. All rights reserved.</p>
                                </div>
                            </footer>
                        `;
                    });
            } else {
                console.warn('푸터 엘리먼트를 찾을 수 없습니다. id="footer"가 있는지 확인하세요.');
            }

            // 개발 모드에서만 테스트 계정 자동 입력 (선택사항)
            if (window.location.hostname === 'localhost') {
                const emailInput = document.getElementById('email');
                const passwordInput = document.getElementById('password');
                
                if (emailInput && passwordInput) {
                    emailInput.addEventListener('dblclick', function() {
                        this.value = 'test@example.com';
                        passwordInput.value = 'hashed_password_123';
                        console.log('테스트 계정 자동 입력 완료');
                    });
                }
            }
        });

        document.addEventListener('keypress', function(event) {
            if (event.key === 'Enter') {
                const form = document.querySelector('form');
                if (form) {
                    if (validateForm()) {
                        form.submit();
                    }
                }
            }
        });
    </script>
</body>
</html>



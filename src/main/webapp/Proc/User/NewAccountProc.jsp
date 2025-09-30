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
    String nickname = request.getParameter("nickname");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm-password");

    if (email == null || email.trim().isEmpty() ||
        nickname == null || nickname.trim().isEmpty() ||
        password == null || password.trim().isEmpty() ||
        confirmPassword == null || confirmPassword.trim().isEmpty()) {
        errorMessage = "모든 필드를 입력해주세요.";
    } else if (!password.equals(confirmPassword)) {
        errorMessage = "비밀번호가 일치하지 않습니다.";
    } else {
        try {
            UserMgr userMgr = new UserMgr();

            // 이메일 중복 체크
            if (userMgr.isEmailExists(email.trim())) {
                errorMessage = "이미 사용 중인 이메일입니다.";
            }
            // 닉네임 중복 체크
            else if (userMgr.isNicknameExists(nickname.trim())) {
                errorMessage = "이미 사용 중인 닉네임입니다.";
            }
            else {
                // 새 사용자 생성
                UserBean newUser = new UserBean();
                newUser.setEmail(email.trim());
                newUser.setNickname(nickname.trim());
                newUser.setPassword(password.trim()); // UserBean에 password 필드 필요
                newUser.setRole("사용자"); // 기본 역할

                boolean created = userMgr.createUser(newUser); // UserMgr에 createUser 메서드 필요
                if (created) {
                    successMessage = "회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.";
                    response.setHeader("Refresh", "3; URL=" + request.getContextPath() + "/UI/JSP/Login.jsp"); // 3초 후 로그인 페이지 이동
                } else {
                    errorMessage = "회원가입 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
                }
            }
        } catch(Exception e) {
            errorMessage = "회원가입 처리 중 서버 오류가 발생했습니다.";
            // e.printStackTrace(); // 개발 중 디버그용
        }
    }
} else {
    errorMessage = "잘못된 접근입니다.";
}
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 처리 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white min-h-screen flex items-center justify-center">
    <div class="max-w-md w-full p-8 border border-gray-200 rounded-lg shadow-sm text-center">
        <% if (errorMessage != null) { %>
            <div class="bg-red-50 border border-red-200 rounded-md p-3 mb-4">
                <p class="text-red-800"><%= errorMessage %></p>
                <a href="<%= request.getContextPath() %>/UI/JSP/User/NewAccount.jsp" class="text-primary hover:text-primary-dark font-medium">회원가입 페이지로 돌아가기</a>
            </div>
        <% } else if (successMessage != null) { %>
            <div class="bg-green-50 border border-green-200 rounded-md p-3 mb-4">
                <p class="text-green-800"><%= successMessage %></p>
                <a href="<%= request.getContextPath() %>/UI/JSP/Login.jsp" class="text-primary hover:text-primary-dark font-medium">로그인 페이지로 이동</a>
            </div>
        <% } %>
    </div>
</body>
</html>

<%@ page contentType="text/plain; charset=UTF-8" %>
<%@ page import="mgr.UserMgr" %>
<%
String nickname = request.getParameter("nickname");
boolean exists = false;

if (nickname != null && !nickname.trim().isEmpty()) {
    UserMgr userMgr = new UserMgr();
    exists = userMgr.isNicknameExists(nickname.trim());
}

if (exists) {
    out.print("중복");
} else {
    out.print("사용가능");
}
%>
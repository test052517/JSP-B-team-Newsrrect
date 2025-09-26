<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String callback = request.getParameter("callback_func");
String uploadPath = request.getParameter("uploadPath");
String fileName = request.getParameter("fileName");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
</head>
<body>
    <script>
        console.log('Complete.jsp 실행됨');
        console.log('callback:', '<%=callback%>');
        console.log('uploadPath:', '<%=uploadPath%>');
        console.log('fileName:', '<%=fileName%>');
        
        try {
            if (parent && parent.window && parent.window['<%=callback%>']) {
                parent.window['<%=callback%>']('<%=uploadPath%>', '<%=fileName%>');
            } else {
                console.error('콜백 함수를 찾을 수 없습니다:', '<%=callback%>');
            }
        } catch(e) {
            console.error('콜백 오류:', e);
        }
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");
    String result = "failed";
    
    try {
        String saveDirectory = application.getRealPath("/upload");
        int maxPostSize = 10 * 1024 * 1024; // 10MB
        String encoding = "UTF-8";

        MultipartRequest multi = new MultipartRequest(
            request, 
            saveDirectory, 
            maxPostSize, 
            encoding, 
            new DefaultFileRenamePolicy()
        );

        String title = multi.getParameter("title");
        String content = multi.getParameter("ir1");
        
        int userId = 1; 
        String type = "정보";
        String status = "공개";
        int viewcount = 0;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String createdAt = sdf.format(new Date());
        int reportCount = 0;
        int recommandCount = 0;
        
        Integer attatchmentFileID = null; 

        PostMgr postMgr = new PostMgr();
        
        postMgr.createPost(
            userId, 
            type, 
            title, 
            content, 
            status, 
            viewcount, 
            createdAt, 
            reportCount, 
            recommandCount
        );
        
        result = "success";

    } catch (Exception e) {
        e.printStackTrace();
        result = "failed";
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Processing...</title>
</head>
<body>
    <script>
        const result = "<%= result %>";
        if (result === "success") {
            alert("게시물이 성공적으로 작성되었습니다.");
            window.location.href = "<%=request.getContextPath()%>/UI/Html/User/CommuBoard.html";
        } else {
            alert("게시물 작성에 실패했습니다. 관리자에게 문의하세요.");
            window.history.back();
        }
    </script>
</body>
</html>
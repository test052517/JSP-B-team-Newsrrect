<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.PostBean" %> <%-- PostBean 임포트 추가 --%>
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
        
        // [수정 1] PostBean 객체를 생성하여 폼 데이터를 담습니다.
        PostBean post = new PostBean();
        
        // 실제 운영 시에는 세션 등에서 사용자 정보를 가져와야 합니다.
        int userId = (int)session.getAttribute("userId");
        
        post.setUserId(userId);
        post.setTitle(title);
        post.setContent(content);
        post.setType("소통");
        post.setStatus("공개"); // 관리자가 승인하기 전까지 '비공개'로 설정할 수도 있습니다.
        post.setViewCount(0);
        post.setReportCount(0);
        post.setRecommandCount(0);
        post.setPriority(0); // 기본 우선순위

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        post.setCreatedAt(sdf.format(new Date()));

        // [수정 2] PostMgr를 생성하고 PostBean 객체를 전달합니다.
        PostMgr postMgr = new PostMgr();
        postMgr.createPost(post); // 여러 파라미터 대신 객체 하나만 전달
        
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
            // 성공 시 이동할 페이지 (게시판 목록 등)
            window.location.href = "<%=request.getContextPath()%>/UI/JSP/User/CommuBoard.jsp";
        } else {
            alert("게시물 작성에 실패했습니다. 관리자에게 문의하세요.");
            window.history.back();
        }
    </script>
</body>
</html>
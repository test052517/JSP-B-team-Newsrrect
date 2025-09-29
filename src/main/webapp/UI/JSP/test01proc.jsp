<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.PostBean" %> <%-- PostBean 임포트 추가 --%>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");
    String result = "failed";
    
    try {
        String saveDirectory = application.getRealPath("upload");
        
        File uploadDir = new File(saveDirectory);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
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
        
        // --- [수정 1] PostBean 객체를 생성하여 모든 데이터를 담습니다. ---
        PostBean post = new PostBean();

        // 실제 운영 시에는 세션에서 사용자 ID를 가져와야 합니다.
        int userId = 1; // 예: session.getAttribute("userId")

        post.setUserId(userId);
        post.setTitle(title);
        post.setContent(content);
        post.setType("정보");
        post.setStatus("공개");
        post.setViewCount(0);
        post.setReportCount(0);
        post.setRecommandCount(0);
        post.setPriority(0); // 기본 우선순위 설정

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        post.setCreatedAt(sdf.format(new Date()));
        
        // 파일 업로드 정보는 필요 시 post 객체에 추가할 수 있습니다.
        // String savedFileName = multi.getFilesystemName("your_file_input_name");
        // post.setFileName(savedFileName); 
        // ---------------------------------------------------------------------

        // DB 연결 및 데이터 삽입을 담당하는 Java 클래스 인스턴스 생성
        PostMgr postMgr = new PostMgr();
        
        // --- [수정 2] PostBean 객체를 전달하는 방식으로 메서드를 호출합니다. ---
        postMgr.createPost(post);
        
        result = "success";
    } catch (Exception e) {
        e.printStackTrace();
        result = "failed: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>처리중...</title>
</head>
<body>
<script>
    const result = "<%= result %>";
    if (result === "success") {
        alert("게시물이 성공적으로 작성되었습니다.");
        window.location.href = "test01.jsp"; // 게시물 목록 페이지 등으로 이동
    } else {
        alert("게시물 작성에 실패했습니다. 오류: " + result);
        window.history.back(); // 이전 페이지로 돌아가기
    }
</script>
</body>
</html>
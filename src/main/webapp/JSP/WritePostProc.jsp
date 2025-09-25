<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // 스크립트릿 내부에서는 웹 페이지에 직접적인 출력이 없으므로 응답을 버퍼링합니다.
    request.setCharacterEncoding("UTF-8");
    String result = "failed";
    
    try {
        // 파일을 저장할 서버 경로 (실제 환경에 맞게 수정이 필요할 수 있습니다)
        String saveDirectory = application.getRealPath("/upload");
        int maxPostSize = 10 * 1024 * 1024; // 최대 업로드 크기 (10MB)
        String encoding = "UTF-8";

        // MultipartRequest 객체 생성: 이 시점에서 파일 업로드와 폼 데이터 파싱이 완료됩니다.
        MultipartRequest multi = new MultipartRequest(
            request, 
            saveDirectory, 
            maxPostSize, 
            encoding, 
            new DefaultFileRenamePolicy()
        );

        // 폼 필드에서 데이터 가져오기
        String title = multi.getParameter("title");
        String content = multi.getParameter("ir1"); // WritePost.jsp의 textarea name 속성값
        
        // --- 데이터베이스에 필요한 더미 데이터 (실제 프로젝트에서는 세션, DB 시퀀스 등으로 대체해야 합니다) ---
        // 예: int userId = (int)session.getAttribute("userId");
        int userId = 1; 
        String type = "정보"; // 게시판 종류에 따라 동적으로 설정 가능
        String status = "공개";
        int viewcount = 0;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String createdAt = sdf.format(new Date());
        int reportCount = 0;
        int recommandCount = 0;
        // ---------------------------------------------------------------------

        // DB 연결 및 데이터 삽입을 담당하는 PostMgr 클래스 인스턴스 생성
        PostMgr postMgr = new PostMgr();
        
        // PostMgr의 createPost 메서드를 호출하여 게시글을 데이터베이스에 저장
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
        // 오류 발생 시 스택 트레이스를 콘솔에 출력하여 디버깅
        e.printStackTrace();
        result = "failed";
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
            // 요청에 따라 성공 시 CommuBoard.html로 이동합니다.
            window.location.href = "../Html/CommuBoard.html"; 
        } else {
            alert("게시물 작성에 실패했습니다. 관리자에게 문의하세요.");
            window.history.back(); // 실패 시 이전 페이지(글 작성 페이지)로 돌아갑니다.
        }
    </script>
</body>
</html>

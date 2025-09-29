<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.io.File" %>

<%
    String result = "failed";
    
    try {
        // 파일을 저장할 서버 경로
        String saveDirectory = application.getRealPath("upload");
        
        // 업로드 폴더가 없으면 생성
        File uploadDir = new File(saveDirectory);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        int maxPostSize = 10 * 1024 * 1024; // 최대 업로드 크기 (10MB)
        String encoding = "UTF-8";

        // MultipartRequest 객체 생성: 폼 데이터가 자동으로 파싱됩니다.
        MultipartRequest multi = new MultipartRequest(
            request, 
            saveDirectory, 
            maxPostSize, 
            encoding, 
            new DefaultFileRenamePolicy()
        );

        // 폼 필드에서 데이터 가져오기
        String title = multi.getParameter("title");
        String content = multi.getParameter("ir1"); // SmartEditor의 textarea 이름
        
        // 업로드된 파일 처리
        Integer attatchmentFileID = null;
        String uploadedFileName = null;
        
        Enumeration fileNames = multi.getFileNames();
        if (fileNames.hasMoreElements()) {
            String paramName = (String) fileNames.nextElement();
            String originalFileName = multi.getOriginalFileName(paramName);
            String savedFileName = multi.getFilesystemName(paramName);
            
            if (savedFileName != null) {
                uploadedFileName = savedFileName;
                // 실제 프로젝트에서는 파일 정보를 데이터베이스에 저장하고 ID를 받아와야 합니다
                // 지금은 임시로 null로 설정
                attatchmentFileID = null;
            }
        }
        
        // --- 데이터베이스에 필요한 더미 데이터 (실제 값으로 대체해야 합니다) ---
        // 예: 세션에서 사용자 ID를 가져오거나, DB 시퀀스로 post ID를 생성하는 로직을 추가해야 합니다.
        int postId = 2; 
        int userId = 1; // 예: session.getAttribute("userId")
        String type = "정보";
        String status = "공개";
        int viewcount = 0;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String createdAt = sdf.format(new Date());
        int reportCount = 0;
        int recommandCount = 0;
        // ---------------------------------------------------------------------

        // DB 연결 및 데이터 삽입을 담당하는 Java 클래스 인스턴스 생성
        PostMgr postMgr = new PostMgr();
        
        // createPost 메서드 호출
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
        // 오류 발생 시 스택 트레이스를 콘솔에 출력
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
        window.location.href = "test 01.jsp"; // 게시물 목록 페이지 등으로 이동
    } else {
        alert("게시물 작성에 실패했습니다. 오류: " + result);
        window.history.back(); // 이전 페이지로 돌아가기
    }
</script>
</body>
</html>
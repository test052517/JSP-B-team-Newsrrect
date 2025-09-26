<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>
<%@ page import="java.net.URLEncoder" %>

<%
    String sFileInfo = ""; // 콜백으로 넘길 파일 정보를 담는 변수

    try {
        // 1. 파일 저장 경로 설정 (프로젝트의 'upload' 폴더)
        String saveDirectory = application.getRealPath("/upload");
        
        // upload 폴더가 없으면 생성
        File dir = new File(saveDirectory);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        int maxPostSize = 10 * 1024 * 1024; // 10MB
        String encoding = "UTF-8";

        // 2. MultipartRequest 객체 생성 (파일 업로드 실행)
        MultipartRequest multi = new MultipartRequest(
            request,
            saveDirectory,
            maxPostSize,
            encoding,
            new DefaultFileRenamePolicy()
        );

        // 3. 업로드된 파일 정보 가져오기
        String originalFileName = multi.getOriginalFileName("Filedata"); // 원본 파일명
        String newFileName = multi.getFilesystemName("Filedata"); // 서버에 저장된 새 파일명

        // 4. 웹에서 접근 가능한 이미지 URL 생성
        // 예: http://localhost:8080/MyProject/upload/image.jpg
        String contextPath = request.getContextPath();
        String fileUrl = contextPath + "/upload/" + newFileName;

        // 5. 콜백 함수로 전달할 파라미터 조립
        // &bNewLine=true -> 에디터에 img 태그 삽입 후 한 줄 개행
        sFileInfo += "&bNewLine=true";
        sFileInfo += "&sFileName=" + URLEncoder.encode(originalFileName, "UTF-8"); // 원본 파일명
        sFileInfo += "&sFileURL=" + fileUrl; // 웹 경로

        // 6. 콜백 페이지로 리다이렉트
        // photo_uploader.html에 정의된 콜백 주소로 파라미터를 붙여서 보냅니다.
        String callbackURL = request.getParameter("callback") + "?callback_func=" + request.getParameter("callback_func");
        response.sendRedirect(callbackURL + sFileInfo);

    } catch (Exception e) {
        e.printStackTrace();
    }
%>
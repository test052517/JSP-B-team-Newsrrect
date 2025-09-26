<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // 이 파일은 스마트에디터의 표준 콜백 방식을 사용합니다.
    // 파일을 저장하고, callback.html로 파일 정보를 전달하여 리다이렉트합니다.

    String sFileInfo = ""; // 콜백으로 넘길 파일 정보

    try {
        // 1. 파일을 저장할 서버 경로를 지정합니다.
        // webapp 폴더 아래에 'upload'라는 이름의 폴더를 사용합니다.
        String saveDirectory = application.getRealPath("/upload");
        
        // upload 폴더가 없으면 새로 생성합니다.
        File dir = new File(saveDirectory);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        int maxPostSize = 10 * 1024 * 1024; // 10MB 제한
        String encoding = "UTF-8";

        // 2. 파일 업로드를 실행합니다.
        MultipartRequest multi = new MultipartRequest(
            request,
            saveDirectory,
            maxPostSize,
            encoding,
            new DefaultFileRenamePolicy()
        );

        // 3. 업로드된 파일 정보를 가져옵니다.
        String newFileName = multi.getFilesystemName("Filedata");
        
        // 파일이 정상적으로 수신되었는지 확인합니다.
        if (newFileName == null) {
            System.err.println("FileUploader.jsp Error: 파일 수신에 실패했습니다. cos.jar 라이브러리나 폼 설정을 확인하세요.");
            return;
        }
        
        String originalFileName = multi.getOriginalFileName("Filedata");

        // 4. 웹에서 접근 가능한 이미지 URL을 생성합니다.
        String contextPath = request.getContextPath();
        String fileUrl = contextPath + "/upload/" + URLEncoder.encode(newFileName, "UTF-8");

        // 5. 콜백 함수로 전달할 파라미터를 조립합니다.
        sFileInfo += "&bNewLine=true";
        sFileInfo += "&sFileName=" + URLEncoder.encode(originalFileName, "UTF-8");
        sFileInfo += "&sFileURL=" + fileUrl;

        // 6. 콜백 페이지로 리다이렉트합니다.
        String callbackURL = request.getParameter("callback") + "?callback_func=" + request.getParameter("callback_func");
        response.sendRedirect(callbackURL + sFileInfo);

    } catch (Exception e) {
        e.printStackTrace();
    }
%>
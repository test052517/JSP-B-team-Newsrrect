<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    // SmartEditor2에서 전달되는 callback_func 파라미터
    String callback = request.getParameter("callback_func"); 
    if (callback == null || callback.equals("null")) {
        callback = "se2_uploadCallback";  // 기본 콜백 함수 지정
    }

    // 업로드 저장 경로
    String savePath = application.getRealPath("/upload");
    java.io.File uploadDir = new java.io.File(savePath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();
    }

    String fileName = "";
    String filePath = "";
    try {
        // cos.jar 의 MultipartRequest 사용
        com.oreilly.servlet.MultipartRequest multi = new com.oreilly.servlet.MultipartRequest(
            request, savePath, 10*1024*1024, "UTF-8", new com.oreilly.servlet.multipart.DefaultFileRenamePolicy()
        );

        fileName = multi.getFilesystemName("Filedata");
        if (fileName != null) {
            filePath = "/upload/" + fileName; // 웹 접근 경로
        }
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<script type="text/javascript">
    // complete.jsp 로 결과 전달
    location.href = "complete.jsp?callback_func=<%=callback%>"
        + "&uploadPath=<%=filePath%>"
        + "&fileName=<%=fileName%>";
</script>

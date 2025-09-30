<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.nio.file.*, com.oreilly.servlet.*, com.oreilly.servlet.multipart.*, java.io.File, java.util.Date, java.text.SimpleDateFormat"
%>
<%
    response.setContentType("text/html; charset=UTF-8");

    String newFileName = null;
    String errorMessage = null;

    try {
        String workspaceProject_Path = "C:/JSP-B-team-Newsrrect/JSP-B-team-Newsrrect";
        String savePath = workspaceProject_Path + "/src/main/webapp/se2/upload";

        File uploadDir = new File(savePath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        MultipartRequest multi = new MultipartRequest(
            request, savePath, 10 * 1024 * 1024, "UTF-8", new DefaultFileRenamePolicy()
        );

        String originalFileName = multi.getFilesystemName("Filedata");
        if (originalFileName == null) {
            throw new Exception("파일 데이터를 찾을 수 없습니다. (Filedata 파라미터 확인)");
        }

        String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss_SSS").format(new Date());
        String fileExtension = "";
        int dotIndex = originalFileName.lastIndexOf(".");
        if (dotIndex != -1) {
            fileExtension = originalFileName.substring(dotIndex);
        }
        newFileName = timeStamp + fileExtension;

        Path sourcePath = Paths.get(savePath, originalFileName);
        Path targetPath = Paths.get(savePath, newFileName);
        Files.move(sourcePath, targetPath, StandardCopyOption.REPLACE_EXISTING);

    } catch (Exception e) {
        errorMessage = e.getMessage();
        e.printStackTrace();
    }
%>
<script>
try {
    <% if (errorMessage == null && newFileName != null) { %>
        var uploadPath = "/se2/upload/<%= newFileName %>";
        var fileName = "<%= newFileName %>";

        // alert(uploadPath); // 확인용 alert, 필요 없으면 삭제
        window.parent.se2_uploadCallback(uploadPath, fileName);
    <% } %>
} catch(e) {
    console.error(e);
}
</script>
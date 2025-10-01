<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.nio.file.*, com.oreilly.servlet.*, com.oreilly.servlet.multipart.*, java.io.File, java.util.Date, java.text.SimpleDateFormat"
%>
<%
response.setContentType("text/html; charset=UTF-8");

    String newFileName = null;
    String errorMessage = null;
    String callbackUrl = null;

    try {
        // 1. 경로 설정: 두 개의 경로를 모두 준비합니다.
        // (A) 소스 폴더 경로 (개발 편의용)
        String projectPath = application.getInitParameter("PROJECT_PATH");
        if (projectPath == null || projectPath.trim().isEmpty()) {
            throw new Exception("web.xml에 PROJECT_PATH가 설정되지 않았습니다.");
        }
        String sourceSavePath = projectPath + "/src/main/webapp/se2/upload";

        // (B) 서버 배포(메타데이터) 경로 (실제 웹 서비스용)
        // ... try 블록 시작 ...
		String deploySavePath = application.getRealPath("/se2/upload");
		System.out.println("▶ 실제 배포(메타데이터) 경로: " + deploySavePath); // 이 줄을 추가!
		// ...

		// 2. 두 경로에 폴더가 없으면 모두 생성합니다.
		File sourceDir = new File(sourceSavePath);
		File deployDir = new File(deploySavePath);
		if (!sourceDir.exists())
	sourceDir.mkdirs();
		if (!deployDir.exists())
	deployDir.mkdirs();

		// 3. 파일을 우선 서버 배포(메타데이터) 경로에 업로드합니다.
		MultipartRequest multi = new MultipartRequest(request, deploySavePath, 10 * 1024 * 1024, "UTF-8",
		new DefaultFileRenamePolicy());

		String originalFileName = multi.getFilesystemName("Filedata");
		if (originalFileName == null) {
	throw new Exception("파일 데이터를 찾을 수 없습니다. (Filedata 파라미터 확인)");
		}

		// 4. 파일명을 타임스탬프로 변경합니다.
		String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss_SSS").format(new Date());
		String fileExtension = "";
		int dotIndex = originalFileName.lastIndexOf(".");
		if (dotIndex != -1) {
	fileExtension = originalFileName.substring(dotIndex);
		}
		newFileName = timeStamp + fileExtension;

		// 5. 서버 배포 경로에 있는 원본 파일의 이름을 새 파일명으로 변경(move)합니다.
		Path sourceFileInDeploy = Paths.get(deploySavePath, originalFileName);
		Path targetFileInDeploy = Paths.get(deploySavePath, newFileName);
		Files.move(sourceFileInDeploy, targetFileInDeploy, StandardCopyOption.REPLACE_EXISTING);

		// 6. [핵심] 최종 파일을 소스 폴더 경로로 복사(copy)합니다.
		Path targetFileInSource = Paths.get(sourceSavePath, newFileName);
		Files.copy(targetFileInDeploy, targetFileInSource, StandardCopyOption.REPLACE_EXISTING);

		// 7. 브라우저에서 사용할 콜백 URL을 생성합니다. (서버 배포 경로 기준)
		String contextPath = request.getContextPath();
		callbackUrl = "/se2/upload/" + newFileName;

	} catch (Exception e) {
		errorMessage = e.getMessage();
		e.printStackTrace(); // 서버 로그에 에러 기록
	}
%>
<script>
try {
    <% if (errorMessage == null && callbackUrl != null) { %>
        // 성공: 부모창의 콜백 함수 호출 (경로는 서버 배포 경로의 URL)
        var uploadPath = "<%= callbackUrl %>";
        var fileName = "<%= newFileName %>";
        window.parent.se2_uploadCallback(uploadPath, fileName);

    <% } else { %>
        // 실패: 에러 메시지 출력
        var errorMsg = "<%= errorMessage != null ? errorMessage.replace("\"", "'").replace("\n", "\\n") : "알 수 없는 오류가 발생했습니다." %>";
        alert("이미지 업로드에 실패했습니다.\n" + errorMsg);
    <% } %>
} catch(e) {
    console.error("Callback script error:", e);
}
</script>
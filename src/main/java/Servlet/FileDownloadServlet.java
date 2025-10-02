package Servlet; // 프로젝트의 패키지 구조에 맞게 수정해주세요.

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/download.do")
public class FileDownloadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "upload";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 파일 이름 파라미터 가져오기
        String fileName = request.getParameter("file");
        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "파일 이름이 지정되지 않았습니다.");
            return;
        }
        
        // 2. 파일 경로 설정
        String applicationPath = getServletContext().getRealPath("");
        String downloadPath = applicationPath + File.separator + UPLOAD_DIR;
        String filePath = downloadPath + File.separator + fileName;
        
        File file = new File(filePath);
        
        if (file.exists() && file.isFile()) {
            // 3. 원본 파일 이름 추출 (UUID 제거)
            String originalFileName = fileName;
            int uuidIndex = fileName.indexOf("_");
            if (uuidIndex != -1) {
                originalFileName = fileName.substring(uuidIndex + 1);
            }

            // 4. HTTP 헤더 설정
            String mimeType = getServletContext().getMimeType(filePath);
            if (mimeType == null) {
                mimeType = "application/octet-stream";
            }
            response.setContentType(mimeType);
            
            // 한글 파일 이름 인코딩
            String encodedFileName = URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            
            response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);
            response.setContentLength((int) file.length());

            // 5. 파일 스트리밍
            try (FileInputStream inStream = new FileInputStream(file);
                 OutputStream outStream = response.getOutputStream()) {
                
                byte[] buffer = new byte[4096];
                int bytesRead = -1;
                while ((bytesRead = inStream.read(buffer)) != -1) {
                    outStream.write(buffer, 0, bytesRead);
                }
            }
        } else {
            // 파일이 없을 경우
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "요청한 파일을 찾을 수 없습니다.");
        }
    }
}

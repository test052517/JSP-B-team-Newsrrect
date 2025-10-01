package Servlet; // 프로젝트의 패키지 구조에 맞게 수정해주세요.

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.google.gson.Gson;

import beans.PostBean;
import beans.UserBean;
import mgr.PostMgr;

/**
 * CommuWriteProc.jsp의 로직을 서블릿으로 구현한 클래스.
 * submitContents.js의 fetch 요청을 받아 게시글과 파일을 저장하고 JSON으로 응답합니다.
 */
@WebServlet("/writeCommuPost.do")
@MultipartConfig
public class WriteCommuPostServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // JSP의 application.getRealPath("/upload")와 동일한 로직
    private static final String UPLOAD_DIR = "upload"; 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> responseData = new HashMap<>();
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        // CommuWriteProc.jsp의 세션 처리 로직
      /*  Integer userIdObject = (Integer) session.getAttribute("userId");
        if (userIdObject == null) {
            responseData.put("success", false);
            responseData.put("message", "로그인이 필요합니다.");
            out.print(new Gson().toJson(responseData));
            out.flush();
            return;
        }
        int userId = userIdObject;*/
        beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
        int userId = user.getUserId();


        try {
            // 1. 폼 데이터 추출 (JSP의 multi.getParameter 로직 대체)
            String title = getPartValue(request.getPart("title"));
            String content = getPartValue(request.getPart("ir1"));

            // --- 유효성 검사 ---
            if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty() || content.trim().equals("<p>&nbsp;</p>")) {
                throw new IllegalArgumentException("제목과 내용은 필수 입력 항목입니다.");
            }

            // 2. 파일 업로드 처리 (JSP의 MultipartRequest 로직 대체)
            String applicationPath = request.getServletContext().getRealPath("");
            String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
            
            File uploadDir = new File(uploadFilePath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            List<String> savedFileNames = new ArrayList<>();
            Collection<Part> fileParts = request.getParts().stream()
                .filter(part -> "files".equals(part.getName()) && part.getSize() > 0)
                .collect(Collectors.toList());

            for (Part filePart : fileParts) {
                String originalFileName = getFileName(filePart);
                if (originalFileName != null && !originalFileName.isEmpty()) {
                    String uniqueFileName = UUID.randomUUID().toString() + "_" + originalFileName;
                    filePart.write(uploadFilePath + File.separator + uniqueFileName);
                    savedFileNames.add(uniqueFileName);
                }
            }
            
            // 3. PostBean 객체 생성 및 데이터 설정 (JSP 로직과 동일)
            PostBean post = new PostBean();
            post.setUserId(userId);
            post.setTitle(title);
            post.setContent(content);
            post.setType("소통"); // JSP에서는 '정보', 이전 서블릿에서는 '소통' -> 필요에 맞게 수정
            post.setStatus("공개");
            post.setViewCount(0);
            post.setReportCount(0);
            post.setRecommandCount(0);
            post.setPriority(0);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            post.setCreatedAt(sdf.format(new Date()));

            // 4. PostMgr를 통해 DB에 저장 (JSP 로직과 동일)
            PostMgr postMgr = new PostMgr();
            // DB에 저장 후, 새로 생성된 postId를 반환받도록 PostMgr 수정 필요
            try {
            	postMgr.createPost(post);
            }catch(Exception e) {
            	throw new Exception("데이터베이스에 게시글을 생성하지 못했습니다.");
            }
           
            responseData.put("success", true);

        } catch (Exception e) {
            e.printStackTrace();
            // 6. 실패 시 JSON 응답 (JSP의 script 로직 대체)
            responseData.put("success", false);
            responseData.put("message", e.getMessage() != null ? e.getMessage() : "게시글 작성 중 오류가 발생했습니다.");
        }

        out.print(new Gson().toJson(responseData));
        out.flush();
    }

    // Multipart/form-data에서 텍스트 값을 추출하는 헬퍼 메서드
    private String getPartValue(Part part) throws IOException {
        if(part == null) return "";
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), StandardCharsets.UTF_8))) {
            return reader.lines().collect(Collectors.joining(System.lineSeparator()));
        }
    }

    // Part에서 원본 파일 이름을 추출하는 헬퍼 메서드
    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}


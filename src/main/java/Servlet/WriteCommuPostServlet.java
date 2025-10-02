package Servlet;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
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

@WebServlet("/writeCommuPost.do")
@MultipartConfig
public class WriteCommuPostServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // [수정] 저장 폴더 이름을 "UPload"로 변경
    private static final String UPLOAD_DIR = "UPload"; 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> responseData = new HashMap<>();
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        UserBean user = (UserBean)session.getAttribute("loggedInUser");
        if (user == null) {
            responseData.put("success", false);
            responseData.put("message", "로그인이 필요합니다.");
            out.print(new Gson().toJson(responseData));
            out.flush();
            return;
        }

        try {
            String title = getPartValue(request.getPart("title"));
            String content = getPartValue(request.getPart("ir1"));
            Part filePart = request.getPart("file");

            if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty() || content.trim().equals("<p>&nbsp;</p>")) {
                throw new IllegalArgumentException("제목과 내용은 필수 입력 항목입니다.");
            }

            String applicationPath = request.getServletContext().getRealPath("");
            String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
            
            File uploadDir = new File(uploadFilePath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String uniqueFileName = null;
            if (filePart != null && filePart.getSize() > 0) {
                String originalFileName = getFileName(filePart);
                if (originalFileName != null && !originalFileName.isEmpty()) {
                    
                    // [수정] 파일명 생성 방식을 SimpleDateFormat으로 변경
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
                    String timestamp = sdf.format(new Date());
                    
                    // 파일 확장자 추출
                    String extension = "";
                    int dotIndex = originalFileName.lastIndexOf('.');
                    if (dotIndex > 0 && dotIndex < originalFileName.length() - 1) {
                        extension = originalFileName.substring(dotIndex);
                    }
                    
                    uniqueFileName = timestamp + extension;
                    filePart.write(uploadFilePath + File.separator + uniqueFileName);
                }
            }
            
            PostBean post = new PostBean();
            post.setUserId(user.getUserId());
            post.setTitle(title);
            post.setContent(content);
            post.setType("소통");
            post.setStatus("공개");
            post.setViewCount(0);
            post.setReportCount(0);
            post.setRecommandCount(0);
            post.setPriority(0);
            post.setAttache(uniqueFileName);
            
            SimpleDateFormat postSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            post.setCreatedAt(postSdf.format(new Date()));

            PostMgr postMgr = new PostMgr();
            int newPostId = postMgr.createPostAndGetId(post); 

            if (newPostId > 0) {
                 responseData.put("success", true);
                 responseData.put("postId", newPostId);
            } else {
                 throw new Exception("데이터베이스에 게시글을 생성하지 못했습니다.");
            }
           
        } catch (Exception e) {
            e.printStackTrace();
            responseData.put("success", false);
            responseData.put("message", e.getMessage() != null ? e.getMessage() : "게시글 작성 중 오류가 발생했습니다.");
        }

        out.print(new Gson().toJson(responseData));
        out.flush();
    }

    private String getPartValue(Part part) throws IOException {
        if(part == null) return "";
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(part.getInputStream(), StandardCharsets.UTF_8))) {
            return reader.lines().collect(Collectors.joining(System.lineSeparator()));
        }
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}


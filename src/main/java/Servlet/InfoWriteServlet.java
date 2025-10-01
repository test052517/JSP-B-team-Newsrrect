package Servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import beans.PostBean;
import beans.UserBean;
import mgr.PostMgr;

@WebServlet("/writeInfoPost.do")
public class InfoWriteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        String jsonResponse = "{\"success\": false, \"message\": \"알 수 없는 오류가 발생했습니다.\"}";

        HttpSession session = request.getSession();
        // [수정] 세션에서 "loggedInUser" 라는 이름으로 UserBean을 가져옵니다.
        UserBean user = (UserBean) session.getAttribute("loggedInUser");

        if (user == null) {
            jsonResponse = "{\"success\": false, \"message\": \"로그인이 필요합니다.\"}";
            out.print(jsonResponse);
            out.flush();
            return;
        }

        String saveDirectory = getServletContext().getRealPath("/upload");
        File uploadDir = new File(saveDirectory);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        int maxPostSize = 10 * 1024 * 1024; // 10MB
        String encoding = "UTF-8";

        try {
            MultipartRequest multi = new MultipartRequest(
                request,
                saveDirectory,
                maxPostSize,
                encoding,
                new DefaultFileRenamePolicy()
            );

            String title = multi.getParameter("title");
            String content = multi.getParameter("content");

            if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
                jsonResponse = "{\"success\": false, \"message\": \"제목과 내용을 모두 입력해주세요.\"}";
            } else {
                PostBean postBean = new PostBean();
                postBean.setUserId(user.getUserId()); // 이제 user 객체가 null이 아니므로 안전하게 호출 가능
                postBean.setType("정보");
                postBean.setTitle(title);
                postBean.setContent(content);
                postBean.setStatus("비공개");
                postBean.setViewCount(0);
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                postBean.setCreatedAt(sdf.format(new Date()));
                postBean.setReportCount(0);
                postBean.setRecommandCount(0);
                postBean.setPriority(0);

                PostMgr postMgr = new PostMgr();
                int newPostId = postMgr.createPostAndGetId(postBean); 

                if (newPostId > 0) {
                     jsonResponse = String.format("{\"success\": true, \"postId\": %d}", newPostId);
                } else {
                     jsonResponse = "{\"success\": false, \"message\": \"게시글 DB 저장에 실패했습니다.\"}";
                }
            }
        } catch (Exception e) {
            e.printStackTrace(); // 콘솔에 에러 로그를 남겨서 디버깅을 쉽게 함
            jsonResponse = "{\"success\": false, \"message\": \"파일 업로드 또는 처리 중 오류가 발생했습니다.\"}";
        }
        
        out.print(jsonResponse);
        out.flush();
    }
}
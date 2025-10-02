package Servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID; 

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig; 
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part; 

import beans.UserBean;
import beans.CommentBean;
import mgr.CommentMgr;
import mgr.DBConnectionMgr;

@WebServlet("/submitCommuComment")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 5,   // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class CommuCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private CommentMgr commentMgr;
    private DBConnectionMgr pool;
    // 파일 업로드 경로 설정
    private static final String UPLOAD_DIR = "comment_file";
    
    @Override
    public void init() throws ServletException {
        commentMgr = new CommentMgr();
        pool = DBConnectionMgr.getInstance();
    }

    private void showAlertAndBack(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + message + "'); history.back();</script>");
        out.close();
    }

    // 부모 댓글의 layer를 조회하는 메소드
    private int getParentLayer(int parentCommentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int parentLayer = 0;
        
        try {
            conn = pool.getConnection("user");
            String sql = "SELECT layer FROM comment WHERE comment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, parentCommentId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                parentLayer = rs.getInt("layer");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(conn, pstmt, rs);
        }
        
        return parentLayer;
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/User/Login.jsp");
            return;
        }

        UserBean user = (UserBean) session.getAttribute("loggedInUser");
        int userId = user.getUserId();
        // [추가] userRole 확인
        String userRole = user.getRole() != null ? user.getRole() : "사용자"; 
        
        // --- 1. 파일 업로드 처리 및 파일명 확보 ---
        String uploadedFileName = null;
        
        // [핵심 수정] 요청의 Content-Type 확인: multipart/form-data 요청일 때만 파일 업로드 로직 실행
        String contentType = request.getContentType();
        boolean isMultipart = contentType != null && contentType.toLowerCase().contains("multipart/form-data");

        if (isMultipart) {
            String savePath = request.getServletContext().getRealPath("/") + UPLOAD_DIR; 
            File fileSaveDir = new File(savePath);
            
            // 폴더 생성 로직
            if (!fileSaveDir.exists()) {
                fileSaveDir.mkdirs();
                System.out.println("댓글 파일 저장 폴더 생성: " + savePath);
            }
            
            try {
                Part filePart = request.getPart("commentFile"); 
                
                String originalFileName = filePart.getSubmittedFileName();
                
                if (originalFileName != null && !originalFileName.isEmpty()) {
                    originalFileName = new File(originalFileName).getName();
                    
                    String extension = "";
                    int dotIndex = originalFileName.lastIndexOf('.');
                    if (dotIndex > 0) {
                        extension = originalFileName.substring(dotIndex);
                    }
                    String uniqueFileName = UUID.randomUUID().toString() + extension;
                    
                    // 파일 저장
                    String filePath = savePath + File.separator + uniqueFileName;
                    filePart.write(filePath);
                    uploadedFileName = uniqueFileName;
                    System.out.println("댓글 파일 업로드 성공: " + uploadedFileName);
                    System.out.println(">> 실제 저장 경로: " + filePath); // **추가된 코드**
                }
            } catch (Exception e) {
                System.err.println("댓글 파일 업로드 중 오류 발생: " + e.getMessage());
                e.printStackTrace(); // 예외 추적 출력
            }
        }
        
        String postIdStr = request.getParameter("postId");
        String content = request.getParameter("content");
        String nowPage = request.getParameter("nowPage");
        String parentIdParam = request.getParameter("parentCommentId");
        String sort = request.getParameter("sort");
        
        String judgment = null; 
        
        if (postIdStr == null || postIdStr.trim().isEmpty() || content == null || content.trim().isEmpty() || content.equals("<p>&nbsp;</p>")) {
            showAlertAndBack(response, "댓글 내용을 입력해주세요.");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdStr);
            
            String postType = commentMgr.getPostType(postId);
            if (postType == null || !"소통".equals(postType)) {
                 showAlertAndBack(response, "소통 게시물 정보를 찾을 수 없습니다.");
                 return;
            }
            
            CommentBean comment = new CommentBean();
            comment.setPost_id(postId);
            comment.setUser_id(userId);
            comment.setType(postType);
            comment.setContent(content.trim());
            comment.setJudgment(judgment); 
            comment.setStatus("공개");
            comment.setCreated_at(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            comment.setAttache(uploadedFileName); // 파일명 설정 (null일 경우 null 저장)
            
            // 대댓글 처리 로직
            if (parentIdParam != null && !parentIdParam.trim().isEmpty()) {
                try {
                    int parentCommentId = Integer.parseInt(parentIdParam);
                    comment.setParent_comment_id(parentCommentId);
                    
                    int parentLayer = getParentLayer(parentCommentId);
                    comment.setLayer(parentLayer + 1);
                } catch (NumberFormatException e) {
                    showAlertAndBack(response, "잘못된 부모 댓글 번호입니다.");
                    return;
                }
            } else {
                comment.setParent_comment_id(0);
                comment.setLayer(0);
            }
            
            boolean isSuccess = commentMgr.insertComment(comment);
            
            if (isSuccess) {
                String redirectUrl;
                if ("관리자".equals(userRole)) {
                    redirectUrl = request.getContextPath() + "/UI/JSP/Admin/AdminCommuWatch.jsp?postId=" + postId;
                } else {
                    redirectUrl = request.getContextPath() + "/UI/JSP/User/CommuWatch.jsp?id=" + postId;
                }
                
                if (nowPage != null && !nowPage.trim().isEmpty()) {
                    if ("관리자".equals(userRole)) {
                         redirectUrl += "&nowPage=" + nowPage;
                    } else {
                         redirectUrl += "&nowPage=" + nowPage;
                    }
                }
                
                if (sort != null && !sort.trim().isEmpty()) {
                    redirectUrl += "&sort=" + sort;
                }
                
                response.sendRedirect(redirectUrl);
            } else {
                showAlertAndBack(response, "댓글 등록에 실패했습니다.");
            }

        } catch (NumberFormatException e) {
            showAlertAndBack(response, "잘못된 게시물 번호입니다.");
        } catch (Exception e) {
            e.printStackTrace();
            showAlertAndBack(response, "댓글 등록 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
}

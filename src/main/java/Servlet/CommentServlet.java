package Servlet;

import java.io.File; // 파일 처리를 위한 import
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID; // 파일명 중복 방지를 위한 import

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig; // 파일 업로드 처리를 위한 어노테이션 추가
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part; // 파일 처리를 위한 Part 추가

import beans.UserBean;
import beans.CommentBean;
import mgr.CommentMgr;
import mgr.DBConnectionMgr;

@WebServlet("/submitComment")
// 파일 업로드를 위한 설정 (최상위 댓글 폼에서 사용 가능)
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 5,   // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class CommentServlet extends HttpServlet {
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

    /**
     * 부모 댓글의 layer를 조회하는 메소드
     * @param parentCommentId 부모 댓글 ID
     * @return 부모 댓글의 layer 값
     */
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

    /**
     * Part에서 파일 이름을 추출하는 메소드 (파일명 중복 방지 로직 포함)
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String cd : contentDisp.split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                // IE/Edge의 경우 전체 경로가 넘어오므로 파일명만 추출
                return fileName.substring(fileName.lastIndexOf('/') + 1)
                               .substring(fileName.lastIndexOf('\\') + 1);
            }
        }
        return null;
    }
    
    // 파일명 중복 방지를 위한 UUID 사용
    private String generateUniqueFileName(String originalFileName) {
        String extension = "";
        int dotIndex = originalFileName.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = originalFileName.substring(dotIndex);
        }
        return UUID.randomUUID().toString() + extension;
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 세션 체크
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/User/Login.jsp");
            return;
        }

        UserBean user = (UserBean) session.getAttribute("loggedInUser");
        int userId = user.getUserId();
        String userRole = user.getRole() != null ? user.getRole() : "사용자";
        
        String postIdStr = request.getParameter("postId");
        
        // request.getParameter() 호출 전에 파일 Part를 가져오기 위해 모든 Part를 검사
        Part filePart = null;
        String contentType = request.getContentType();
        boolean isMultipart = (contentType != null && contentType.startsWith("multipart/form-data"));
        
        if (isMultipart) {
            try {
                 // Multipart 요청인 경우에만 Part를 시도합니다.
                 filePart = request.getPart("commentFile");
            } catch (IllegalStateException e) {
                // maxFileSize 초과 등 MultipartConfig 관련 오류
                System.err.println("파일 Part 처리 중 오류 발생 (크기 초과 등): " + e.getMessage());
            } catch (Exception e) {
                System.err.println("파일 Part 처리 중 알 수 없는 오류 발생: " + e.getMessage());
            }
        }
        
        // --- 1. 폼 데이터 파라미터 받기 (Part 처리 후) ---
        String content = request.getParameter("content");
        String judgment = request.getParameter("judgment");
        String parentIdParam = request.getParameter("parentCommentId");

        // 답글인지 확인
        boolean isReply = (parentIdParam != null && !parentIdParam.trim().isEmpty());

        // --- 2. 파일 업로드 처리 및 파일명 확보 (원댓글만 해당, 답글은 파일 첨부 폼 사용 안 함) ---
        String uploadedFileName = null;
        
        if (filePart != null && filePart.getSize() > 0 && !isReply) {
            String originalFileName = getFileName(filePart);
            
            if (originalFileName != null && !originalFileName.isEmpty()) {
                String uniqueFileName = generateUniqueFileName(originalFileName);
                
                // 실제 저장 경로 (웹 어플리케이션 루트/comment_file)
                String savePath = request.getServletContext().getRealPath("/") + UPLOAD_DIR; 
                File fileSaveDir = new File(savePath);
                
                if (!fileSaveDir.exists()) {
                    fileSaveDir.mkdirs();
                }
                
                try {
                    // 파일을 저장
                    filePart.write(savePath + File.separator + uniqueFileName);
                    uploadedFileName = uniqueFileName;
                    System.out.println("댓글 파일 업로드 성공: " + uploadedFileName + " to " + savePath);
                } catch (IOException e) {
                    System.err.println("댓글 파일 저장 중 오류 발생 (권한 등): " + e.getMessage());
                    e.printStackTrace();
                    uploadedFileName = null; 
                }
            }
        }
        
        // 기본 필수 필드 검증
        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            showAlertAndBack(response, "게시물 ID가 누락되었습니다.");
            return;
        }
        
        if (content == null || content.trim().isEmpty() || content.equals("<p>&nbsp;</p>")) {
            showAlertAndBack(response, "내용을 입력해주세요.");
            return;
        }
        
        // 원댓글만 judgment 검증 (답글은 건너뛰기)
        if (!isReply && (judgment == null || judgment.trim().isEmpty())) {
            showAlertAndBack(response, "판정을 선택해주세요.");
            return;
        }

        try {
            int postId = Integer.parseInt(postIdStr);

            String postType = commentMgr.getPostType(postId);
            if (postType == null) {
                showAlertAndBack(response, "존재하지 않는 게시물입니다.");
                return;
            }

            CommentBean comment = new CommentBean();
            comment.setPost_id(postId);
            comment.setUser_id(userId);
            comment.setType(postType);
            comment.setContent(content.trim());
            comment.setAttache(uploadedFileName); // 첨부 파일명 설정 (null 가능)
            
            if (isReply) {
                comment.setJudgment(null);
            } else {
                comment.setJudgment(judgment.trim());
            }
            
            comment.setStatus("공개");
            comment.setCreated_at(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            
            // 대댓글 처리 로직 (layer 자동 계산)
            if (isReply) {
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
            	String sort = request.getParameter("sort");
                String redirectUrl;
                if ("관리자".equals(userRole)) {
                    redirectUrl = request.getContextPath() + "/UI/JSP/Admin/AdminInfoWatch.jsp?postId=" + postId;
                } else {
                    redirectUrl = request.getContextPath() + "/UI/JSP/User/InfoWatch.jsp?id=" + postId;
                    
                    if (sort != null && !sort.isEmpty()) {
                        redirectUrl += "&sort=" + sort;
                    }
                }
                response.sendRedirect(redirectUrl);
            } else {
                // DB 저장 실패 시 업로드된 파일 삭제 (클린업)
                if(uploadedFileName != null) { 
                    new File(request.getServletContext().getRealPath("/") + UPLOAD_DIR + File.separator + uploadedFileName).delete(); 
                }
                showAlertAndBack(response, "댓글 등록에 실패했습니다.");
            }

        } catch (NumberFormatException e) {
            showAlertAndBack(response, "잘못된 게시물 번호입니다.");
        } catch (Exception e) {
            e.printStackTrace();
            showAlertAndBack(response, "댓글 등록 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    private void showAlertAndBack(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<script>");
        out.println("alert('" + message.replace("'", "\\'") + "');");
        out.println("history.back();");
        out.println("</script>");
        out.flush();
    }
}

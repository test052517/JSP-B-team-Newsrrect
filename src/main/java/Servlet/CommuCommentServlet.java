package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import beans.UserBean;
import beans.CommentBean;
import mgr.CommentMgr;
import mgr.DBConnectionMgr;

@WebServlet("/submitCommuComment")
public class CommuCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private CommentMgr commentMgr;
    private DBConnectionMgr pool;
    
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
        
        String postIdStr = request.getParameter("postId");
        String content = request.getParameter("content");
        String nowPage = request.getParameter("nowPage");
        
        String judgment = null; 
        
        if (postIdStr == null || postIdStr.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            showAlertAndBack(response, "필수 정보가 누락되었습니다.");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdStr);
            
            String postType = commentMgr.getPostType(postId);
            if (postType == null) {
                 showAlertAndBack(response, "게시물 정보를 찾을 수 없습니다.");
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
            
            // 대댓글 처리 로직 (layer 자동 계산)
            String parentIdParam = request.getParameter("parentCommentId");
            if (parentIdParam != null && !parentIdParam.trim().isEmpty()) {
                try {
                    int parentCommentId = Integer.parseInt(parentIdParam);
                    comment.setParent_comment_id(parentCommentId);
                    
                    // 부모 댓글의 layer를 조회해서 +1로 설정
                    int parentLayer = getParentLayer(parentCommentId);
                    comment.setLayer(parentLayer + 1);
                    
                    System.out.println("답글 등록: 부모ID=" + parentCommentId + ", 부모Layer=" + parentLayer + ", 새댓글Layer=" + (parentLayer + 1));
                } catch (NumberFormatException e) {
                    showAlertAndBack(response, "잘못된 부모 댓글 번호입니다.");
                    return;
                }
            } else {
                // 일반 댓글 (최상위)
                comment.setParent_comment_id(0);
                comment.setLayer(0);
                System.out.println("일반 댓글 등록: Layer=0");
            }
            
            boolean isSuccess = commentMgr.insertComment(comment);
            
            if (isSuccess) {
                // 성공 시 같은 페이지로 리다이렉트 (nowPage 파라미터 유지)
                String redirectUrl = request.getContextPath() + "/UI/JSP/User/CommuWatch.jsp?id=" + postId;
                if (nowPage != null && !nowPage.trim().isEmpty()) {
                    redirectUrl += "&nowPage=" + nowPage;
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
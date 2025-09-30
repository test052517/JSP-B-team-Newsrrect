package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
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

@WebServlet("/submitComment")
public class CommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private CommentMgr commentMgr;
    
    @Override
    public void init() throws ServletException {
        commentMgr = new CommentMgr();
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
        String judgment = request.getParameter("judgment");

        if (postIdStr == null || postIdStr.trim().isEmpty() || content == null || content.trim().isEmpty() || judgment == null || judgment.trim().isEmpty()) {
            showAlertAndBack(response, "판정 및 댓글 내용을 모두 입력해주세요.");
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
            comment.setJudgment(judgment);
            comment.setStatus("공개");
            comment.setCreated_at(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            
            String parentIdParam = request.getParameter("parentCommentId");
            if (parentIdParam != null && !parentIdParam.trim().isEmpty()) {
                comment.setParent_comment_id(Integer.parseInt(parentIdParam));
                comment.setLayer(1);
            } else {
                comment.setParent_comment_id(0);
                comment.setLayer(0);
            }
            
            boolean isSuccess = commentMgr.insertComment(comment);
            
            if (isSuccess) {
            	response.sendRedirect(request.getContextPath() + "/UI/JSP/User/InfoWatch.jsp?id=" + postId);
            } else {
                showAlertAndBack(response, "댓글 등록에 실패했습니다.");
            }

        } catch (NumberFormatException e) {
            showAlertAndBack(response, "잘못된 게시물 번호입니다.");
        }
    }
    
    private void showAlertAndBack(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + message + "'); history.back();</script>");
        out.flush();
    }
}


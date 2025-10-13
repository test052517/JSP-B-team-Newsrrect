// CommentUpvoteServlet.java

package Servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import beans.UserBean;
import mgr.CommentMgr;
import mgr.CommentLikeMgr;
import mgr.UserMgr;

@WebServlet("/upvoteComment")
public class CommentUpvoteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private CommentMgr commentMgr;
    private CommentLikeMgr commentLikeMgr;
    private UserMgr userMgr; 
    
    @Override
    public void init() throws ServletException {
        commentMgr = new CommentMgr();
        commentLikeMgr = new CommentLikeMgr();
        userMgr = new UserMgr();
    }

    // ★★★ doGet을 doPost로 변경 ★★★
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // JSON 응답을 위한 기본 설정
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401 Unauthorized
            response.getWriter().write("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            return;
        }

        UserBean user = (UserBean) session.getAttribute("loggedInUser");
        int userId = user.getUserId();

        String commentIdStr = request.getParameter("commentId");

        if (commentIdStr == null || commentIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Bad Request
            response.getWriter().write("{\"success\": false, \"message\": \"댓글 ID가 누락되었습니다.\"}");
            return;
        }
        
        String responseMessage = ""; // 최종 응답 메시지 저장용
        boolean success = false;

        try {
            int commentId = Integer.parseInt(commentIdStr);
            int commentOwnerId = commentMgr.getCommentOwnerId(commentId);
            
            // 자신의 댓글 추천 방지 (선택 사항이나 논리적 오류 방지)
            if (commentOwnerId == userId) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"자신의 댓글은 추천할 수 없습니다.\"}");
                return;
            }
            
            // 추천 토글 로직 실행
            if (commentLikeMgr.isLiked(commentId, userId)) {
                // 추천 취소 로직
                commentLikeMgr.deleteLike(commentId, userId);
                success = commentMgr.downvoteComment(commentId); 
                responseMessage = "추천을 취소했습니다.";

            } else {
                // 추천 실행 로직
                commentLikeMgr.insertLike(commentId, userId);
                success = commentMgr.upvoteComment(commentId); 
                responseMessage = "댓글을 추천했습니다.";
            }
            
            // 포인트 재계산 및 최종 응답
            if (success) {
                userMgr.calculateAndUpdateTotalPoints(commentOwnerId);
                
                response.getWriter().write("{\"success\": true, \"message\": \"" + responseMessage + "\"}");
            } else {
                 response.getWriter().write("{\"success\": false, \"message\": \"" + responseMessage + " 처리 중 오류가 발생했습니다.\"}");
            }


        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"잘못된 댓글 번호입니다.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"서버 오류가 발생했습니다.\"}");
        }
    }
}
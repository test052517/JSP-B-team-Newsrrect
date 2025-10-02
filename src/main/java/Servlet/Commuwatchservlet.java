package Servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import beans.CommentBean;
import beans.PostBean;
import beans.UserBean;
import mgr.CommentLikeMgr;
import mgr.CommentMgr;
import mgr.WatchUserPostMgr; // PostMgr 대신 WatchUserPostMgr를 import

/**
 * CommuBoard.jsp에서 게시글 제목 클릭 시 요청을 처리하는 서블릿
 * 게시글 상세 정보 및 댓글을 조회하여 CommuWatch.jsp로 전달하는 컨트롤러 역할
 */
@WebServlet("/commu/watch.do")
public class Commuwatchservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // 1. 파라미터 받기 (게시물 ID 및 정렬 기준)
        String postIdStr = request.getParameter("id");
        String sort = request.getParameter("sort");

        // 정렬 기준 기본값 설정
        if (sort == null || (!"upvotes".equalsIgnoreCase(sort) && !"latest".equalsIgnoreCase(sort))) {
            sort = "latest"; 
        }

        // 2. 유효성 검사
        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp");
            return;
        }

        try {
            int postId = Integer.parseInt(postIdStr);
            
            // 3. 비즈니스 로직 처리 (DB 연동)
            // [수정] PostMgr 대신 WatchUserPostMgr 사용
            WatchUserPostMgr wupm = new WatchUserPostMgr();
            
            // 3-1. 조회수 증가
            wupm.increaseViewCount(postId);
            
            // 3-2. 게시물 상세 정보 가져오기
            PostBean post = wupm.getPost(postId);
            
            // 게시물이 없거나 "소통" 타입이 아니면 리다이렉트
            if (post == null || !"소통".equals(post.getType())) {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println("<script>alert('게시물이 존재하지 않거나 접근할 수 없습니다.'); location.href='" + request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp';</script>");
                return;
            }
            
            // 3-3. 댓글 목록 가져오기 (정렬 기준 적용)
            CommentMgr commentMgr = new CommentMgr();
            Vector<CommentBean> commentList = commentMgr.getCommentList(postId, sort);
            
            // 3-4. 베스트 댓글 선정
            CommentBean bestComment = null;
            int maxUpvotes = 0;
            for(CommentBean comment : commentList) {
                if (comment.getUpvotes() > 0 && comment.getUpvotes() > maxUpvotes) {
                    maxUpvotes = comment.getUpvotes();
                    bestComment = comment;
                }
            }

            // 3-5. 로그인 사용자의 댓글 추천 여부 확인
            Map<Integer, Boolean> likeMap = new HashMap<>();
            UserBean loggedInUser = (UserBean) session.getAttribute("loggedInUser");
            if (loggedInUser != null) {
                CommentLikeMgr commentLikeMgr = new CommentLikeMgr();
                for (CommentBean comment : commentList) {
                    boolean isLiked = commentLikeMgr.isLiked(comment.getComment_id(), loggedInUser.getUserId());
                    likeMap.put(comment.getComment_id(), isLiked);

                    // 답글 추천 여부도 확인
                    Vector<CommentBean> replyList = commentMgr.getAllRepliesRecursive(comment.getComment_id());
                    request.setAttribute("reply_" + comment.getComment_id(), replyList);
                    for (CommentBean reply : replyList) {
                        boolean isReplyLiked = commentLikeMgr.isLiked(reply.getComment_id(), loggedInUser.getUserId());
                        likeMap.put(reply.getComment_id(), isReplyLiked);
                    }
                }
            }
            
            // 4. request 객체에 결과 데이터 저장
            request.setAttribute("post", post);
            request.setAttribute("commentList", commentList);
            request.setAttribute("commentCount", commentList.size());
            request.setAttribute("sort", sort);

            // CommuWatch.jsp에서 사용할 nowPage 파라미터도 전달
            String nowPage = request.getParameter("nowPage");
            request.setAttribute("nowPage", nowPage != null ? nowPage : "1");

            request.setAttribute("bestComment", bestComment);
            request.setAttribute("likeMap", likeMap);
            request.setAttribute("loggedInUser", loggedInUser);


            // 5. View(JSP)로 포워딩
            RequestDispatcher dispatcher = request.getRequestDispatcher("/UI/JSP/User/CommuWatch.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("Invalid post ID format: " + postIdStr);
            response.sendRedirect(request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp?error=1");
        }
    }
}


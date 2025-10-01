package Servlet;

import java.io.IOException;
import java.util.Vector; // 댓글 목록을 위해 추가

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import beans.PostBean;
import beans.CommentBean; // 댓글 기능을 위해 CommentBean이 있다고 가정합니다.
import mgr.WatchUserPostMgr;
import mgr.CommentMgr; // 댓글 기능을 위해 CommentMgr가 있다고 가정합니다.

/**
 * CommuBoard.jsp에서 게시글 제목 클릭 시 요청을 처리하는 서블릿
 * 게시글 상세 정보 및 댓글을 조회하여 CommuWatch.jsp로 전달하는 컨트롤러 역할
 */
@WebServlet("/commu/watch.do") // 서블릿을 호출할 URL 매핑
public class Commuwatchservlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 파라미터 받기 (게시물 ID)
        String postIdStr = request.getParameter("id");
        
        // 2. 유효성 검사
        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            // id 파라미터가 없는 경우, 게시판 목록으로 리다이렉트
            response.sendRedirect(request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp");
            return;
        }

        try {
            int postId = Integer.parseInt(postIdStr);
            
            // 3. 비즈니스 로직 처리 (DB 연동)
            WatchUserPostMgr wupm = new WatchUserPostMgr();
            
            // 3-1. 조회수 증가
            wupm.increaseViewCount(postId);
            
            // 3-2. 게시물 상세 정보 가져오기
            PostBean post = wupm.getPost(postId);
            
            // 3-3. (선택) 댓글 목록 가져오기
            // CommentMgr 와 CommentBean 이 구현되어 있다고 가정합니다.
            CommentMgr commentMgr = new CommentMgr();
            Vector<CommentBean> commentList = commentMgr.getCommentList(postId);
            
            // 4. request 객체에 결과 데이터 저장
            // CommuWatch.jsp 에서는 이 데이터를 EL(${post.title})을 통해 사용할 수 있습니다.
            request.setAttribute("post", post);
            request.setAttribute("commentList", commentList);

            // 5. View(JSP)로 포워딩
            RequestDispatcher dispatcher = request.getRequestDispatcher("/UI/JSP/User/CommuWatch.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            // postId가 숫자가 아닌 경우
            System.err.println("Invalid post ID format: " + postIdStr);
            response.sendRedirect(request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            // 기타 예외 발생 시 에러 페이지나 게시판 목록으로 이동
            // 여기서는 간단하게 게시판 목록으로 리다이렉트합니다.
            response.sendRedirect(request.getContextPath() + "/UI/JSP/User/CommuBoard.jsp?error=1");
        }
    }
}
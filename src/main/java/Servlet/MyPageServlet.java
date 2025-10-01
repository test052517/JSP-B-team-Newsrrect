package Servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import beans.UserBean;
import beans.MyPageStatsBean;
import beans.PostBean;
import beans.CommentBean;
import mgr.MyPageMgr;

@WebServlet("/Servlet/MyPageServlet")
public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. 세션에서 로그인된 사용자 정보 (UserBean) 가져오기
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute("loggedInUser"); // UserBean 객체를 사용한다고 가정
        int userId = (user != null) ? user.getUserId() : 0;
        System.out.println("[MyPageServlet] DEBUG: 추출된 userId 값: " + userId); 
        
     // **디버깅 코드 시작**
        if (user == null) {
            System.out.println("[MyPageServlet] ERROR: loggedInUser 객체가 세션에 없습니다.");
            response.sendRedirect("JSP/Login.jsp");
            return;
        }

        // **이 부분이 중요:** userId 값이 1 이상인지 확인!
        if (userId <= 0) {
            System.out.println("[MyPageServlet] ERROR: userId가 유효하지 않습니다: " + userId);
            response.sendRedirect("JSP/Login.jsp"); // 또는 에러 페이지
            return;
        }
        
        // 로그인 체크: 사용자 정보가 없으면 로그인 페이지 등으로 리다이렉트 (필요에 따라 구현)
        if (user == null) {
            response.sendRedirect("JSP/Login.jsp"); // 로그인 페이지로 이동
            return;
        }
          
        // 2. MyPageMgr 객체 생성
        MyPageMgr mgr = new MyPageMgr();
        
        // 3. 데이터 조회 및 request 속성에 저장
        try {
            // A. 통계 데이터 조회 (작성 글, 댓글, 받은 추천 수)
            MyPageStatsBean stats = mgr.getStats(userId);
            request.setAttribute("userStats", stats);

            // B. 최근 작성 게시글 목록 조회 (최대 5개)
            List<PostBean> recentPosts = mgr.getRecentPosts(userId);
            request.setAttribute("recentPosts", recentPosts);

            // C. 최근 작성 댓글 목록 조회 (최대 5개)
            List<CommentBean> recentComments = mgr.getRecentComments(userId);
            request.setAttribute("recentComments", recentComments);

        } catch (Exception e) {
            System.err.println("MyPage 데이터 로드 중 오류 발생: " + e.getMessage());
            // 에러 처리 로직 (예: 에러 페이지로 포워딩 또는 빈 리스트 전달)
            request.setAttribute("errorMessage", "데이터를 불러오는 중 오류가 발생했습니다.");
            // 오류가 발생해도 페이지는 보여주되, 데이터는 null 또는 비어있는 상태로 넘어갑니다.
        }
        
        // 4. MyPage.jsp로 포워딩
        RequestDispatcher rd = request.getRequestDispatcher("/UI/JSP/User/MyPage.jsp"); 
        rd.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // GET 방식으로 처리하도록 유도하거나, 필요에 따라 POST 로직 구현
        doGet(request, response);
    }
}
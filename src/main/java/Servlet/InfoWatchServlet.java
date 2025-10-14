package Servlet;

import java.io.IOException;
import java.util.Vector;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import beans.PostBean;
import beans.CommentBean;
import mgr.WatchUserPostMgr;
import mgr.CommentMgr;

/**
 * 정보 게시판의 목록 조회/검색 및 게시글 상세 보기를 모두 처리하는 컨트롤러
 */
@WebServlet("/info/watch.do")
public class InfoWatchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String postIdStr = request.getParameter("id");

        if (postIdStr != null && !postIdStr.trim().isEmpty()) {
            // === 1. 게시글 상세 보기 로직 (id 파라미터가 있을 경우) ===
            // 이 부분은 변경할 필요가 없습니다.
            handlePostView(request, response, postIdStr);
        } else {
            // === 2. 게시글 목록 조회 및 검색 로직 (id 파라미터가 없을 경우) ===
            // 이 부분을 수정합니다.
            handleBoardList(request, response);
        }
    }

    /**
     * 게시글 상세 정보를 처리하는 메소드 (변경 없음)
     */
    private void handlePostView(HttpServletRequest request, HttpServletResponse response, String postIdStr) throws ServletException, IOException {
        try {
            int postId = Integer.parseInt(postIdStr);
            WatchUserPostMgr wupm = new WatchUserPostMgr();
            
            // 조회수 증가
            wupm.increaseViewCount(postId);
            
            // 게시물 상세 정보 가져오기
            PostBean post = wupm.getPost(postId);
            
            // 댓글 목록 가져오기
            CommentMgr commentMgr = new CommentMgr();
            Vector<CommentBean> commentList = commentMgr.getCommentList(postId);
            
            // request 객체에 결과 데이터 저장
            request.setAttribute("post", post);
            request.setAttribute("commentList", commentList);

            // View(JSP)로 포워딩
            RequestDispatcher dispatcher = request.getRequestDispatcher("/UI/JSP/User/InfoWatch.jsp");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            System.err.println("Invalid post ID format: " + postIdStr);
            response.sendRedirect(request.getContextPath() + "/info/watch.do"); // 목록으로 리다이렉트
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/info/watch.do?error=1"); // 에러 발생 시 목록으로
        }
    }

    /**
     * 게시판 목록 및 검색 결과를 처리하는 메소드 (수정됨)
     */
    private void handleBoardList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        WatchUserPostMgr watchUserPostMgr = new WatchUserPostMgr();
        
        // ==================== [수정 시작] ====================
        
        // 1. 공지사항 목록 가져오기 (페이징/검색과 무관하게 항상 모두 가져옴)
        // ※ WatchUserPostMgr에 getVerificationNotices() 메소드가 구현되어 있어야 합니다.
        Vector<PostBean> noticeList = watchUserPostMgr.getVerificationNotices();

        // 2. 일반 게시글에 대한 페이징 및 검색 처리
        
        // 페이징 변수
        int totalRecord = 0; // 일반 게시글의 총 개수
        int numPerPage = 10;
        int pagePerBlock = 10;
        int totalPage = 0;
        int nowPage = 1;
        
        // 검색 파라미터
        String keyField = request.getParameter("keyField");
        String keyWord = request.getParameter("keyWord");

        // 일반 게시글의 총 개수 가져오기 (검색어 유무에 따라)
        // ※ WatchUserPostMgr에 일반 게시글만 카운트하는 메소드가 필요합니다.
        totalRecord = watchUserPostMgr.getRegularPostCount("정보", keyField, keyWord);
        
        if (request.getParameter("nowPage") != null) {
            try {
                nowPage = Integer.parseInt(request.getParameter("nowPage"));
            } catch (NumberFormatException e) {}
        }
        
        int start = (nowPage * numPerPage) - numPerPage;
        
        // 일반 게시글 목록 가져오기 (페이징, 검색 적용)
        // ※ WatchUserPostMgr에 일반 게시글만 가져오는 메소드가 필요합니다.
        Vector<PostBean> regularPostList = watchUserPostMgr.getRegularPostList("정보", keyField, keyWord, start, numPerPage);
        
        totalPage = (int)Math.ceil((double)totalRecord / numPerPage);
        int nowBlock = (int)Math.ceil((double)nowPage / pagePerBlock);
        int pageStart = (nowBlock - 1) * pagePerBlock + 1;
        int pageEnd = Math.min(pageStart + pagePerBlock - 1, totalPage);

        // JSP로 전달할 데이터 설정
        request.setAttribute("noticeList", noticeList);             // 공지사항 목록
        request.setAttribute("regularPostList", regularPostList);   // 일반 게시글 목록
        
        // 페이징 및 검색 관련 데이터 (기존과 유사)
        request.setAttribute("totalRecord", totalRecord);
        request.setAttribute("numPerPage", numPerPage);
        request.setAttribute("nowPage", nowPage);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("pageStart", pageStart);
        request.setAttribute("pageEnd", pageEnd);
        request.setAttribute("nowBlock", nowBlock);
        request.setAttribute("totalBlock", (int)Math.ceil((double)totalPage / pagePerBlock));
        request.setAttribute("keyField", keyField);
        request.setAttribute("keyWord", keyWord);
        
        // ==================== [수정 끝] ====================
        
        // View(JSP)로 포워딩
        RequestDispatcher dispatcher = request.getRequestDispatcher("/UI/JSP/User/InfoBoard.jsp");
        dispatcher.forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
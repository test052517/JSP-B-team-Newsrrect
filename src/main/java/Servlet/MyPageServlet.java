package Servlet;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import beans.UserBean;
import beans.MyPageStatsBean;
import beans.PostBean;
import beans.CommentBean;
import mgr.MyPageMgr;

@WebServlet({"/Servlet/MyPageServlet", "/updateProfile.do"}) 
public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. 세션에서 로그인된 사용자 정보 (UserBean) 가져오기
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute("loggedInUser"); // UserBean 객체를 사용한다고 가정
        int userId = (user != null) ? user.getUserId() : 0;
        
        System.out.println("[MyPageServlet] DEBUG: 추출된 userId 값: " + userId); 
        
        // 로그인 체크: 사용자 정보가 없으면 로그인 페이지 등으로 리다이렉트 (필요에 따라 구현)
        if (user == null || userId <= 0) {
            // 1. 이동할 목표 URL을 미리 만들어 둡니다. (sendRedirect와 동일한 방식)
            String targetURL = request.getContextPath() + "/UI/JSP/Login.jsp";

            // 2. 응답 형식을 설정합니다.
            response.setContentType("text/html; charset=UTF-8");
            PrintWriter out = response.getWriter();

            // 3. alert와 location.href를 포함한 JavaScript 코드를 출력합니다.
            out.println("<script>");
            out.println("alert('로그인이 필요한 서비스 입니다.');");
            // 위 alert의 '확인'을 누르면 아래 코드가 실행됩니다.
            out.println("location.href='" + targetURL + "';"); 
            out.println("</script>");

            // 4. 자원을 해제하고 메서드 실행을 종료합니다.
            out.flush();
            return;
        }
          
        // 2. MyPageMgr 객체 생성
        MyPageMgr mgr = new MyPageMgr();
        UserBean updatedUser = mgr.getUserById(userId);
        
        if (updatedUser != null) {
            session.setAttribute("loggedInUser", updatedUser); // 세션 갱신
            user = updatedUser; // 현재 로직에서 사용할 user 객체도 갱신
        }
        
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
        
        // JSON 응답을 위한 설정
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
     // 1. 세션 사용자 정보 확인
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute("loggedInUser");
        
        if (user == null) {
            // 로그인 정보가 없으면 에러 응답
            out.print("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            out.flush();
            return;
        }

        // 파일이 저장될 서버상의 실제 경로 (예: 프로젝트의 /uploads/profiles 폴더)
        String saveDirectory = request.getServletContext().getRealPath("/uploads/profiles"); 
        
        // [수정] maxPostSize, encoding 변수 선언
        int maxPostSize = 1024 * 1024 * 5; // 5MB 제한
        String encoding = "UTF-8";
        
        File uploadDir = new File(saveDirectory);
        if (!uploadDir.exists()) {
            System.out.println("DEBUG: 업로드 폴더가 없어 생성 시도: " + saveDirectory);
            uploadDir.mkdirs(); // 폴더가 없으면 생성
        }
        
        System.out.println("DEBUG: 파일 업로드 처리 직전. saveDirectory: " + saveDirectory);
        
        // 기본 변수 선언
        String introduce = "";
        String newProfileImageName = null;
        String statusMessage = "프로필 업데이트 성공";

        try {
            // 3. MultipartRequest 생성 및 데이터 추출
            MultipartRequest multi = new MultipartRequest(request, saveDirectory, maxPostSize, encoding, new DefaultFileRenamePolicy());
            
            // [수정] introduce 변수 할당 코드를 한 번으로 통합
            introduce = multi.getParameter("introduce");
            System.out.println("DEBUG: MultipartRequest 성공. introduce: " + introduce); 
            
            // 파일 데이터 추출 (프로필 이미지)
            if (multi.getFilesystemName("profileImage") != null) {
                newProfileImageName = multi.getFilesystemName("profileImage"); 
            }
            
            // 4. DB 로직 실행 (MyPageMgr 사용)
            MyPageMgr mgr = new MyPageMgr();
            
            boolean success = mgr.updateProfile(
                user.getUserId(),               // 사용자 ID
                introduce,                      // 새 자기소개
                newProfileImageName             // 새 프로필 이미지 파일명 (null일 수 있음)
            );

            if (success) {
                // 세션 정보 업데이트
                user.setIntroduce(introduce);
                if (newProfileImageName != null) {
                    user.setProfileImage(newProfileImageName); 
                }
                session.setAttribute("loggedInUser", user);

                out.print("{\"success\": true, \"message\": \"프로필이 성공적으로 업데이트되었습니다.\"}");
            }  else {
                statusMessage = "프로필 업데이트 중 DB 오류가 발생했습니다.";
                out.print("{\"success\": false, \"message\": \"" + statusMessage + "\"}");
            }
            
        } catch (Exception e) {
            System.err.println("프로필 업데이트 서블릿 오류: " + e.getMessage());
            out.print("{\"success\": false, \"message\": \"서버 처리 중 오류가 발생했습니다.\"}");
        } finally {
            out.flush();
        }
    }   
}
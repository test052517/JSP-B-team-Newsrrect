package Servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import beans.UserBean;
import mgr.UserMgr; 

@WebServlet("/ChangePassword.do") 
public class ChangePasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        UserBean user = (UserBean) session.getAttribute("loggedInUser");
        
        if (user == null) {
            out.print("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            out.flush();
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        int userId = user.getUserId();
        
        try {
            UserMgr userMgr = new UserMgr();

            boolean success = userMgr.updatePassword(userId, currentPassword, newPassword);

            if (success) {
                out.print("{\"success\": true, \"message\": \"비밀번호가 성공적으로 변경되었습니다.\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"현재 비밀번호가 일치하지 않거나 변경에 실패했습니다.\"}");
            }
            
        } catch (Exception e) {
            System.err.println("비밀번호 변경 서블릿 오류: " + e.getMessage());
            out.print("{\"success\": false, \"message\": \"서버 오류가 발생했습니다.\"}");
        } finally {
            out.flush();
        }
    }
}
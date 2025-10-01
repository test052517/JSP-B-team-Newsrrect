<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="beans.UserBean, beans.CommentBean" %>
<%!

private String getPointImageFileName(int point) {
    if (point <= 100) {
        return "0.png";
    } else if (point < 200) {
        return "100.png";
    } else if (point < 300) {
        return "200.png";
    } else if (point < 400) {
        return "300.png";
    } else if (point < 500) {
        return "400.png";
    } else if (point < 600) {
        return "500.png";
    } else if (point < 700) {
        return "600.png";
    } else if (point < 800) {
        return "700.png";
    } else if (point < 900) {
        return "800.png";
    } else if (point < 1000) {
        return "900.png";
    } else { // 1000 초과
        return "1000.png";
    }
}
%>
<%
    Object userObject = request.getAttribute("userBean");
    String pointImage = "0.png"; // 기본값 설정
    String role = null;
    int point = 0;
    
    if (userObject != null) {
        
        // --- 1. 객체 타입 확인 및 point, role 추출 ---
        if (userObject instanceof UserBean) {
            UserBean user = (UserBean) userObject;
            point = user.getPoint();
            role = user.getRole();
        } else if (userObject instanceof CommentBean) {
            CommentBean comment = (CommentBean) userObject;
            point = comment.getPoint();
            role = comment.getRole(); // <<<<<<<<<<<<<<<< [수정] CommentBean에서 role 가져오기
            
        } else {
            System.err.println("PointProc.jsp: Unknown object type passed as userBean.");
        }
        
        // --- 2. 추출된 role 변수로 관리자/포인트 이미지 결정 ---
        if (role != null && role.equals("관리자")) {
            pointImage = "Admin.png"; 
        } else {
            pointImage = getPointImageFileName(point);
        }
    }

    String imagePath = request.getContextPath() + "/UI/JSP/point/" + pointImage;
    
    request.setAttribute("pointImagePath", imagePath);
%>

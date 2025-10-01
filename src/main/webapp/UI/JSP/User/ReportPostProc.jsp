<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.PostReportBean" %>
<%@ page import="mgr.PostReportMgr" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 로그인 확인
    beans.UserBean loggedInUser = (beans.UserBean)session.getAttribute("loggedInUser");
    if(loggedInUser == null) {
        out.println("<script>");
        out.println("alert('로그인이 필요합니다.');");
        out.println("location.href='" + request.getContextPath() + "/UI/JSP/Login/Login.jsp';");
        out.println("</script>");
        return;
    }
    
    String postIdStr = request.getParameter("postId");
    String reason = request.getParameter("reportReason");
    
    // 입력값 검증
    if(postIdStr == null || reason == null || reason.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('신고 사유를 입력해주세요.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }
    
    int postId = Integer.parseInt(postIdStr);
    int userId = loggedInUser.getUserId();
    
    PostReportMgr reportMgr = new PostReportMgr();
    
    // 중복 신고 체크
    if(reportMgr.isDuplicatePostReport(userId, postId)) {
        out.println("<script>");
        out.println("alert('이미 신고한 게시글입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }
    
    // 신고 접수
    PostReportBean report = new PostReportBean();
    report.setPostId(postId);
    report.setReporterId(userId);
    report.setReason(reason);
    
    boolean result = reportMgr.insertPostReport(report);
    
    if(result) {
        out.println("<script>");
        out.println("alert('신고가 접수되었습니다. 검토 후 조치하겠습니다.');");
        out.println("history.back();");
        out.println("</script>");
    } else {
        out.println("<script>");
        out.println("alert('신고 접수에 실패했습니다. 다시 시도해주세요.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>
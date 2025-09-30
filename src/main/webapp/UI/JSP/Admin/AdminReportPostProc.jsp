<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.PostReportBean" %>
<%@ page import="mgr.PostReportMgr" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if(userIdObj == null) {
        response.sendRedirect(request.getContextPath() + "/UI/JSP/Login/Login.jsp");
        return;
    }
    
    String postIdStr = request.getParameter("postId");
    String reason = request.getParameter("reportReason");
    
    if(postIdStr == null || reason == null || reason.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('신고 사유를 입력해주세요.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }
    
    int postId = Integer.parseInt(postIdStr);
    int userId = userIdObj.intValue();
    
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
        out.println("alert('신고가 접수되었습니다.');");
        out.println("history.back();");
        out.println("</script>");
    } else {
        out.println("<script>");
        out.println("alert('신고 접수에 실패했습니다.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>
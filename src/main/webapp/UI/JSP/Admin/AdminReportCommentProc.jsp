<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.CommentReportBean" %>
<%@ page import="mgr.CommentReportMgr" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if(userIdObj == null) {
        response.sendRedirect(request.getContextPath() + "/UI/JSP/Login/Login.jsp");
        return;
    }
    
    String commentIdStr = request.getParameter("commentId");
    String reason = request.getParameter("reportReason");
    
    if(commentIdStr == null || reason == null || reason.trim().isEmpty()) {
        out.println("<script>");
        out.println("alert('신고 사유를 입력해주세요.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }
    
    int commentId = Integer.parseInt(commentIdStr);
    int userId = userIdObj.intValue();
    
    CommentReportMgr reportMgr = new CommentReportMgr();
    
    // 중복 신고 체크
    if(reportMgr.isDuplicateCommentReport(userId, commentId)) {
        out.println("<script>");
        out.println("alert('이미 신고한 댓글입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }
    
    // 신고 접수
    CommentReportBean report = new CommentReportBean();
    report.setCommentId(commentId);
    report.setReporterId(userId);
    report.setReason(reason);
    
    boolean result = reportMgr.insertCommentReport(report);
    
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
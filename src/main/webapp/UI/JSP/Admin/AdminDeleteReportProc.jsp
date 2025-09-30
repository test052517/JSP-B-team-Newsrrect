<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mgr.DeleteMgr" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 관리자 세션 확인 로직 (필요 시 사용)
    
    String type = request.getParameter("type");
    String idStr = request.getParameter("id");

    if (type == null || idStr == null) {
        out.println("<script>");
        out.println("alert('잘못된 접근입니다.');");
        out.println("history.back();");
        out.println("</script>");
        return;
    }

    int reportId = Integer.parseInt(idStr);
    DeleteMgr deleteMgr = new DeleteMgr();
    boolean result = false;

    if (type.equals("게시글")) {
        result = deleteMgr.deletePost(reportId);
    } else if (type.equals("댓글")) {
        result = deleteMgr.deleteComment(reportId);
    }

    if (result) {
        out.println("<script>");
        out.println("alert('삭제 처리가 완료되었습니다.');");
        out.println("location.href = 'AdminUserReport.jsp';"); // 신고 목록 페이지로 이동
        out.println("</script>");
    } else {
        out.println("<script>");
        out.println("alert('삭제 처리에 실패했습니다. 다시 시도해 주세요.');");
        out.println("history.back();");
        out.println("</script>");
    }
%>
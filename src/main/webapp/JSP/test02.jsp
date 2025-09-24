<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="mgr.DBConnectionMgr" %>
<%@ page import="mgr.PostMgr" %>

<%
    String postIdStr = request.getParameter("post_id");
    int postId = 0;
    try {
        postId = Integer.parseInt(postIdStr);
    } catch (NumberFormatException e) {
        out.println("<p>유효하지 않은 게시물 ID입니다.</p>");
        return;
    }
    
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // PostMgr을 사용하지 않고 직접 DB 연결 및 쿼리 실행
        DBConnectionMgr pool = DBConnectionMgr.getInstance(); // ConnectionPool 객체를 가져와야 함
        con = pool.getConnection();
        String sql = "SELECT * FROM post WHERE post_id = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String title = rs.getString("title");
            String content = rs.getString("content");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %></title>
</head>
<body>
    <h1><%= title %></h1>
    <div>
        <%= content %>
    </div>
</body>
</html>
<%
        } else {
            out.println("<p>해당 게시물이 존재하지 않습니다.</p>");
        }

    } catch (Exception e) {
   
        e.printStackTrace();
    } finally {
        // 모든 자원을 여기서 직접 해제합니다.
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
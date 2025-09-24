<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.postBean" %>


<jsp:useBean id="postMgr" class="mgr.PostMgr" scope="page" />

<%
    String postIdStr = request.getParameter("post_id");
    int postId = 0;
    
    try {
        postId = Integer.parseInt(postIdStr);
    } catch (NumberFormatException e) {
        out.println("<p>유효하지 않은 게시물 ID입니다.</p>");
        return;
    }
    
    // postMgr 객체를 사용하여 getPostByPostID() 메서드를 호출합니다.
    postBean post = postMgr.getPostByPostID(postId);
    
    if (post != null) {
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= post.getTitle() %></title>
</head>
<body>
    <h1><%= post.getTitle() %></h1>
    <div>
        <%= post.getContent() %>
    </div>
</body>
</html>
<%
    } else {
        out.println("<p>해당 게시물이 존재하지 않습니다.</p>");
    }
%>
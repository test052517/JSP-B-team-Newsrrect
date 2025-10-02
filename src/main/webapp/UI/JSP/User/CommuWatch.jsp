<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mgr.PostMgr, beans.PostBean, mgr.CommentMgr, beans.CommentBean, mgr.CommentLikeMgr, java.util.Vector, java.util.HashMap, java.util.Map" %>
<%@ page import="mgr.UserMgr, beans.UserBean" %> <%-- [추가] UserMgr, UserBean import --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:useBean id="postMgr" class="mgr.PostMgr" scope="page" />
<jsp:useBean id="commentMgr" class="mgr.CommentMgr" scope="page" />
<jsp:useBean id="commentLikeMgr" class="mgr.CommentLikeMgr" scope="page" />

<%
    // [추가] 포인트 이미지 처리를 위한 UserMgr 인스턴스화
    UserMgr userMgr = new UserMgr();

    beans.UserBean loggedInUser = (beans.UserBean)session.getAttribute("loggedInUser");
    int postId = 0;
    String nowPage = request.getParameter("nowPage") != null ? request.getParameter("nowPage") : "1";
    
    if(request.getParameter("id") != null) {
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("CommuBoard.jsp");
            return;
        }
    } else {
        response.sendRedirect("CommuBoard.jsp");
        return;
    }
    
    PostBean post = postMgr.getPostByPostID(postId);
    
    if(post == null || !"소통".equals(post.getType())) {
        out.println("<script>alert('게시물이 존재하지 않거나 접근할 수 없습니다.'); location.href='CommuBoard.jsp';</script>");
        return;
    }
    
    String sort = request.getParameter("sort");
    if (sort == null || (!"upvotes".equalsIgnoreCase(sort) && !"latest".equalsIgnoreCase(sort))) {
        sort = "latest"; // 기본값 설정: 최신순
    }
    
    Vector<CommentBean> commentList = commentMgr.getCommentList(postId, sort);
    pageContext.setAttribute("sort", sort);
    
    // 추천 여부를 저장할 Map 생성
    Map<Integer, Boolean> likeMap = new HashMap<Integer, Boolean>();
    
    // 각 댓글의 답글 목록을 가져와서 request에 설정 (재귀적으로)
    for(CommentBean comment : commentList) {
        Vector<CommentBean> replyList = commentMgr.getAllRepliesRecursive(comment.getComment_id());
        request.setAttribute("reply_" + comment.getComment_id(), replyList);
        
        // 로그인한 사용자가 추천했는지 확인
        if(loggedInUser != null) {
            boolean isLiked = commentLikeMgr.isLiked(comment.getComment_id(), loggedInUser.getUserId());
            likeMap.put(comment.getComment_id(), isLiked);
            
            // 답글들도 추천 여부 확인
            for(CommentBean reply : replyList) {
                boolean isReplyLiked = commentLikeMgr.isLiked(reply.getComment_id(), loggedInUser.getUserId());
                likeMap.put(reply.getComment_id(), isReplyLiked);
            }
        }
    }
    
 // 베스트 댓글 선정 (추천 수가 가장 많거나, 추천수가 같을 경우 최신 댓글을 선택)
    CommentBean bestComment = null;
	int maxUpvotes = 0;
	for(CommentBean comment : commentList) {
	    if (comment.getUpvotes() > 0 && comment.getUpvotes() > maxUpvotes) {
	        maxUpvotes = comment.getUpvotes();
	        bestComment = comment;
	    }
	}
    
    request.setAttribute("likeMap", likeMap);
    request.setAttribute("bestComment", bestComment);
    
    pageContext.setAttribute("post", post);
    pageContext.setAttribute("commentList", commentList);
    pageContext.setAttribute("commentCount", commentList.size());
    pageContext.setAttribute("nowPage", nowPage);
    pageContext.setAttribute("loggedInUser", loggedInUser);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${post.title}" /> - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/styles.css">
    <script type="text/javascript" src="<%= request.getContextPath() %>/se2/js/HuskyEZCreator.js" charset="utf-8"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'primary': '#5d74f8',
                        'primary-dark': '#4c63e7',
                        'primary-light': '#7d8ff9'
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-white min-h-screen">
    <header class="bg-white shadow-sm border-b border-gray-200">
        <jsp:include page="../Common/Header.jsp" />
    </header>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900"><c:out value="${post.title}" /></h1>
                </div>

                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                
                                <%-- [수정 1] 게시글 작성자 닉네임 앞에 Point 이미지 삽입 --%>
                                <%
                                    // Post 작성자(UserBean) 조회 및 설정 (PostBean에는 point 정보가 없어 UserMgr 재조회 필요)
                                    if (post != null) {
                                        UserBean postAuthorUser = userMgr.getUserById(post.getUserId()); 
                                        if (postAuthorUser != null) {
                                            request.setAttribute("userBean", postAuthorUser);
                                        }
                                    }
                                %>
                                <jsp:include page="/UI/JSP/PointProc.jsp" /> 
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <img src="${pointImagePath}" alt="레벨" style="width: 20px; height: 20px; vertical-align: middle;">
                                    <span><c:out value="${post.nickname}" /></span>
                                </div>
                                <% request.removeAttribute("userBean"); %>

                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>${commentCount}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span>${post.viewCount}</span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span>${post.createdAt}</span>
                                <c:if test="${loggedInUser != null}">
                                    <button onclick="openReportModal(${post.postId})" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed post-content">
                        <c:out value="${post.content}" escapeXml="false" />
                    </div>
                </div>

                <div class="flex justify-between items-center mt-6">
                    <c:url var="listUrl" value="CommuBoard.jsp">
                        <c:param name="nowPage" value="${nowPage}" />
                    </c:url>
                    <a href="${listUrl}" class="bg-gray-200 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors font-medium">목록</a>
                    
                    <c:if test="${loggedInUser != null && loggedInUser.userId == post.userId}">
                        <div class="flex space-x-2">
                            <c:url var="editUrl" value="CommuEdit.jsp">
                                <c:param name="id" value="${post.postId}" />
                                <c:param name="nowPage" value="${nowPage}" />
                            </c:url>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <c:if test="${loggedInUser != null}">
                    <div class="mb-6">
                        <%-- 파일 첨부를 위해 enctype="multipart/form-data" 추가 --%>
                        <form action="${pageContext.request.contextPath}/submitCommuComment" method="post" id="commentForm" enctype="multipart/form-data">
                            <input type="hidden" name="postId" value="${post.postId}">
                            <input type="hidden" name="userId" value="${loggedInUser.userId}">
                            <input type="hidden" name="type" value="소통">
                            <input type="hidden" name="status" value="공개">
                            <input type="hidden" name="judgment" value="">
                            <input type="hidden" name="nowPage" value="${nowPage}">
                            <input type="hidden" name="sort" value="${sort}">  
                            <div class="mb-4">
                                <textarea name="content" id="ir1" rows="10" cols="100" style="width:100%; height:300px; display:none;"></textarea>
                            </div>
                            
                            <%-- START: 첨부 파일 추가 섹션 --%>
                            <div class="mb-4">
                                <div class="flex items-center space-x-2 mb-2">
                                    <%-- name="commentFile"로 파일 전송 --%>
                                    <input type="file" name="commentFile" id="comment-file" class="hidden"> <%-- 'multiple' 속성 제거 --%>
                                    <button type="button" onclick="document.getElementById('comment-file').click()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                                        첨부 파일
                                    </button>
                                    <span class="text-sm text-gray-500" id="file-count-display">파일을 선택하세요</span>
                                </div>
                                
                                <!-- 선택된 파일 목록 표시 -->
                                <div id="selected-files-display" class="hidden">
                                    <div class="bg-gray-50 border border-gray-200 rounded-md p-3">
                                        <div id="file-list-detail" class="space-y-1">
                                            <!-- 파일 목록이 여기에 삽입됩니다 -->
                                        </div>
                                        <div class="mt-2 text-right">
                                            <button type="button" onclick="clearFiles()" class="text-red-500 hover:text-red-700 text-sm font-medium">
                                                전체 삭제
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%-- END: 첨부 파일 추가 섹션 --%>

                            <div class="flex justify-end">
                                <button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">댓글등록</button>
                            </div>
                        </form>
                    </div>
                </c:if>
                <c:if test="${loggedInUser == null}">
                    <div class="text-center py-4 text-gray-500 border border-gray-200 rounded-lg mb-6">
                        로그인 후 댓글을 작성할 수 있습니다.
                    </div>
                </c:if>

                <div class="flex justify-between items-center mb-4 border-t pt-6">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 ${commentList.size()}개</h3>
                    <div class="flex space-x-2">
               
                        <select class="px-3 py-1 border border-gray-200 rounded text-sm" onchange="changeSort(this.value)">
                            <option value="upvotes" ${sort == 'upvotes' ? 'selected' : ''}>추천순</option>
                            <option value="latest" ${sort == 'latest' ? 'selected' : ''}>최신순</option>
                        </select>
     
                    </div>
                </div>

                <!-- BEST 댓글 섹션 -->
                <c:if test="${not empty bestComment && bestComment.upvotes > 0}">
                    <div class="mb-8 bg-blue-100 rounded-lg p-4">
                        <h4 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                            <span class="text-2xl mr-2"></span> BEST 댓글
                        </h4>
                        <div class="space-y-4">
                            <div class="border border rounded-lg p-4 bg-white shadow-md">
                                <div class="flex justify-between items-start mb-2">
                                    <div class="flex items-center space-x-2">
                                        <%-- [수정 2-1] BEST 댓글 작성자 CommentBean 설정 --%>
                                        <%
                                            beans.CommentBean bestCommentAuthor = (beans.CommentBean) pageContext.getAttribute("bestComment"); 
                                            if (bestCommentAuthor != null) {
                                                request.setAttribute("userBean", bestCommentAuthor); // CommentBean을 userBean으로 임시 사용
                                            }
                                        %>
                                        <jsp:include page="/UI/JSP/PointProc.jsp" /> 
                                        
                                        <img src="${pointImagePath}" alt="레벨" style="width: 20px; height: 20px; vertical-align: middle;">
                                        <span class="font-bold text-primary"><c:out value="${bestComment.nickname}" /></span>
                                        <% request.removeAttribute("userBean"); %>

                                        <span class="px-2 py-1 bg-yellow-100 text-yellow-800 text-xs font-semibold rounded">BEST</span>
                                    </div>
                                    <div class="flex items-center space-x-2">
                                        <span class="text-sm text-gray-500">${bestComment.formattedDate}</span>
                                        <c:if test="${loggedInUser != null}">
                                            <span class="text-gray-500 cursor-pointer hover:text-red-500" onclick="openCommentReportModal(${bestComment.comment_id})">🚨</span>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <p class="text-gray-900 font-medium"><c:out value="${bestComment.content}" escapeXml="false" /></p>
                                    
                                    <%-- [추가] BEST 댓글 첨부파일 표시 --%>
                                    <c:if test="${not empty bestComment.attache}">
                                        <div class="mt-2 p-2 bg-gray-100 border border-gray-300 rounded-md inline-flex items-center space-x-2 text-sm text-gray-700">
                                            <svg class="w-4 h-4 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L18 14"></path>
                                            </svg>
                                            <a href="<%= request.getContextPath() %>/comment_file/${bestComment.attache}" class="hover:underline" target="_blank">
                                                첨부파일 다운로드
                                            </a>
                                        </div>
                                    </c:if>
                                    
                                </div>
                                <div class="flex items-center space-x-4 text-sm">
                                    <c:choose>
                                        <c:when test="${loggedInUser != null}">
                                            <c:choose>
                                                <c:when test="${likeMap[bestComment.comment_id]}">
                                                    <button onclick="upvoteComment(${bestComment.comment_id}, ${post.postId})" 
                                                            class="flex items-center space-x-1 transition-colors text-red-500 font-semibold">
                                                        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                        </svg>
                                                        <span>추천 ${bestComment.upvotes}</span>
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button onclick="upvoteComment(${bestComment.comment_id}, ${post.postId})" 
                                                            class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                        </svg>
                                                        <span>추천 ${bestComment.upvotes}</span>
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="flex items-center space-x-1 text-gray-600">
                                                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                </svg>
                                                <span>추천 ${bestComment.upvotes}</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${loggedInUser != null}">
                                        <button onclick="toggleReplyForm(${bestComment.comment_id})" class="text-gray-600 hover:text-primary font-medium">답글쓰기</button>
                                    </c:if>
                                </div>
                                <c:if test="${loggedInUser != null}">
                                    <div id="replyForm_${bestComment.comment_id}" class="mt-4 hidden">
                                        <form action="${pageContext.request.contextPath}/submitCommuComment" method="post" class="reply-form">
                                            <input type="hidden" name="postId" value="${post.postId}">
                                            <input type="hidden" name="parentCommentId" value="${bestComment.comment_id}">
                                            <input type="hidden" name="userId" value="${loggedInUser.userId}">
                                            <input type="hidden" name="type" value="소통">
                                            <input type="hidden" name="status" value="공개">
                                            <input type="hidden" name="judgment" value="">
                                            <input type="hidden" name="nowPage" value="${nowPage}">
                                            <div class="flex space-x-2">
                                                <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                <button type="submit" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark text-sm whitespace-nowrap">등록</button>
                                            </div>
                                        </form>
                                    </div>
                                </c:if>
                                
                                <!-- 베스트 댓글의 답글들 -->
                                <div class="mt-4 ml-8 space-y-3">
                                    <c:set var="replyListKey" value="reply_${bestComment.comment_id}" />
                                    <c:forEach var="reply" items="${requestScope[replyListKey]}">
                                        
                                        <%-- [수정 3-1] 답글 작성자 CommentBean 설정 --%>
                                        <%
                                            beans.CommentBean currentReply = (beans.CommentBean) pageContext.getAttribute("reply"); 
                                            if (currentReply != null) {
                                                request.setAttribute("userBean", currentReply); // CommentBean을 userBean으로 임시 사용
                                            }
                                        %>
                                        <jsp:include page="/UI/JSP/PointProc.jsp" /> 
                                        <div class="border-l-2 border-primary pl-4 py-2" style="margin-left: ${reply.layer * 20}px;">
                                            <div class="flex justify-between items-start mb-2">
                                                <span class="font-semibold text-sm text-gray-700">
                                                    <c:forEach begin="1" end="${reply.layer}">↳ </c:forEach>
                                                    <img src="${pointImagePath}" alt="레벨" style="width: 15px; height: 15px; vertical-align: middle;">
                                                    <c:out value="${reply.nickname}" />
                                                </span>
                                                <% request.removeAttribute("userBean"); %>

                                                <div class="flex items-center space-x-2">
                                                    <span class="text-xs text-gray-500">${reply.formattedDate}</span>
                                                    <c:if test="${loggedInUser != null}">
                                                        <span class="text-gray-500 cursor-pointer text-xs hover:text-red-500" onclick="openCommentReportModal(${reply.comment_id})">🚨</span>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <p class="text-sm text-gray-900"><c:out value="${reply.content}" escapeXml="false" /></p>
                                            
                                            <%-- [추가] 답글 첨부파일 표시 --%>
                                            <c:if test="${not empty reply.attache}">
                                                <div class="mt-1 text-xs text-gray-500 flex items-center space-x-1">
                                                     <svg class="w-3 h-3 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L18 14"></path>
                                                    </svg>
                                                    <a href="<%= request.getContextPath() %>/comment_file/${reply.attache}" class="hover:underline" target="_blank">
                                                        첨부파일 다운로드
                                                    </a>
                                                </div>
                                            </c:if>
                                            
                                            <div class="flex items-center space-x-3 mt-2 text-xs">
                                                <c:choose>
                                                    <c:when test="${loggedInUser != null}">
                                                        <c:choose>
                                                            <c:when test="${likeMap[reply.comment_id]}">
                                                                <button onclick="upvoteComment(${reply.comment_id}, ${post.postId})" 
                                                                        class="flex items-center space-x-1 transition-colors text-red-500">
                                                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                    </svg>
                                                                    <span>추천 ${reply.upvotes}</span>
                                                                </button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button onclick="upvoteComment(${reply.comment_id}, ${post.postId})" 
                                                                        class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                    </svg>
                                                                    <span>추천 ${reply.upvotes}</span>
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="flex items-center space-x-1 text-gray-600">
                                                            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                            </svg>
                                                            <span>추천 ${reply.upvotes}</span>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <c:if test="${loggedInUser != null}">
                                                    <button onclick="toggleReplyForm(${reply.comment_id})" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                                </c:if>
                                            </div>

                                            <c:if test="${loggedInUser != null}">
                                                <div id="replyForm_${reply.comment_id}" class="mt-3 hidden">
                                                    <form action="${pageContext.request.contextPath}/submitCommuComment" method="post" class="reply-form">
                                                        <input type="hidden" name="postId" value="${post.postId}">
                                                        <input type="hidden" name="parentCommentId" value="${reply.comment_id}">
                                                        <input type="hidden" name="userId" value="${loggedInUser.userId}">
                                                        <input type="hidden" name="type" value="소통">
                                                        <input type="hidden" name="status" value="공개">
                                                        <input type="hidden" name="judgment" value="">
                                                        <input type="hidden" name="nowPage" value="${nowPage}">
                                                        <div class="flex space-x-2">
                                                            <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                            <button type="submit" class="px-3 py-1 bg-primary text-white rounded-lg hover:bg-primary-dark text-xs whitespace-nowrap">등록</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- 일반 댓글 목록 -->
                <div class="space-y-4">
                    <c:choose>
                        <c:when test="${commentCount > 0}">
                            <c:forEach var="comment" items="${commentList}">
                                <!-- 베스트 댓글은 제외 -->
                                <c:if test="${empty bestComment || comment.comment_id != bestComment.comment_id}">
                                    
                                    <%-- [수정 4-1] 일반 댓글 작성자 CommentBean 설정 --%>
                                    <%
                                        beans.CommentBean currentComment = (beans.CommentBean) pageContext.getAttribute("comment"); 
                                        if (currentComment != null) {
                                            request.setAttribute("userBean", currentComment); // CommentBean을 userBean으로 임시 사용
                                        }
                                    %>
                                    <jsp:include page="/UI/JSP/PointProc.jsp" /> 

                                    <div class="border border-gray-200 rounded-lg p-4 bg-white hover:shadow-md transition-shadow">
                                        <div class="flex justify-between items-start mb-2">
                                            <div class="flex items-center space-x-2">
                                                <img src="${pointImagePath}" alt="레벨" style="width: 20px; height: 20px; vertical-align: middle;">
                                                <span class="font-semibold"><c:out value="${comment.nickname}" /></span>
                                            </div>
                                            <% request.removeAttribute("userBean"); %>

                                            <div class="flex items-center space-x-2">
                                                <span class="text-sm text-gray-500">${comment.formattedDate}</span>
                                                <c:if test="${loggedInUser != null}">
                                                    <span class="text-gray-500 cursor-pointer hover:text-red-500" onclick="openCommentReportModal(${comment.comment_id})">🚨</span>
                                                </c:if>
                                            </div>
                                        </div>
                                        <div class="mb-3">
                                            <p class="text-gray-900"><c:out value="${comment.content}" escapeXml="false" /></p>
                                            
                                            <%-- [추가] 일반 댓글 첨부파일 표시 --%>
                                            <c:if test="${not empty comment.attache}">
                                                <div class="mt-2 p-2 bg-gray-100 border border-gray-300 rounded-md inline-flex items-center space-x-2 text-sm text-gray-700">
                                                     <svg class="w-4 h-4 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L18 14"></path>
                                                    </svg>
                                                    <a href="<%= request.getContextPath() %>/comment_file/${comment.attache}" class="hover:underline" target="_blank">
                                                        첨부파일 다운로드
                                                    </a>
                                                </div>
                                            </c:if>
                                        </div>
                                        <div class="flex items-center space-x-4 text-sm">
                                            <c:choose>
                                                <c:when test="${loggedInUser != null}">
                                                    <c:choose>
                                                        <c:when test="${likeMap[comment.comment_id]}">
                                                            <button onclick="upvoteComment(${comment.comment_id}, ${post.postId})" 
                                                                    class="flex items-center space-x-1 transition-colors text-red-500">
                                                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                </svg>
                                                                <span>추천 ${comment.upvotes}</span>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button onclick="upvoteComment(${comment.comment_id}, ${post.postId})" 
                                                                    class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                </svg>
                                                                <span>추천 ${comment.upvotes}</span>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="flex items-center space-x-1 text-gray-600">
                                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                        </svg>
                                                        <span>추천 ${comment.upvotes}</span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${loggedInUser != null}">
                                                <button onclick="toggleReplyForm(${comment.comment_id})" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                            </c:if>
                                        </div>
                                        <c:if test="${loggedInUser != null}">
                                            <div id="replyForm_${comment.comment_id}" class="mt-4 hidden">
                                                <form action="${pageContext.request.contextPath}/submitCommuComment" method="post" class="reply-form">
                                                    <input type="hidden" name="postId" value="${post.postId}">
                                                    <input type="hidden" name="parentCommentId" value="${comment.comment_id}">
                                                    <input type="hidden" name="userId" value="${loggedInUser.userId}">
                                                    <input type="hidden" name="type" value="소통">
                                                    <input type="hidden" name="status" value="공개">
                                                    <input type="hidden" name="judgment" value="">
                                                    <input type="hidden" name="nowPage" value="${nowPage}">
                                                    <div class="flex space-x-2">
                                                        <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                        <button type="submit" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark text-sm whitespace-nowrap">등록</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </c:if>
                                        
                                        <!-- 일반 댓글의 답글들 -->
                                        <div class="mt-4 ml-8 space-y-3">
                                            <c:set var="replyListKey" value="reply_${comment.comment_id}" />
                                            <c:forEach var="reply" items="${requestScope[replyListKey]}">
                                                
                                                <%-- [수정 5-1] 답글 작성자 CommentBean 설정 --%>
                                                <%
                                                    beans.CommentBean currentReply = (beans.CommentBean) pageContext.getAttribute("reply"); 
                                                    if (currentReply != null) {
                                                        request.setAttribute("userBean", currentReply); // CommentBean을 userBean으로 임시 사용
                                                    }
                                                %>
                                                <jsp:include page="/UI/JSP/PointProc.jsp" /> 

                                                <div class="border-l-2 border-primary pl-4 py-2" style="margin-left: ${reply.layer * 20}px;">
                                                    <div class="flex justify-between items-start mb-2">
                                                        <span class="font-semibold text-sm text-gray-700">
                                                            <c:forEach begin="1" end="${reply.layer}">↳ </c:forEach>
                                                            <img src="${pointImagePath}" alt="레벨" style="width: 15px; height: 15px; vertical-align: middle;">
                                                            <c:out value="${reply.nickname}" />
                                                        </span>
                                                        <% request.removeAttribute("userBean"); %>

                                                        <div class="flex items-center space-x-2">
                                                            <span class="text-xs text-gray-500">${reply.formattedDate}</span>
                                                            <c:if test="${loggedInUser != null}">
                                                                <span class="text-gray-500 cursor-pointer text-xs hover:text-red-500" onclick="openCommentReportModal(${reply.comment_id})">🚨</span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <p class="text-sm text-gray-900"><c:out value="${reply.content}" escapeXml="false" /></p>
                                                    
                                                    <%-- [추가] 답글 첨부파일 표시 --%>
                                                    <c:if test="${not empty reply.attache}">
                                                        <div class="mt-1 text-xs text-gray-500 flex items-center space-x-1">
                                                             <svg class="w-3 h-3 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L18 14"></path>
                                                            </svg>
                                                            <a href="<%= request.getContextPath() %>/comment_file/${reply.attache}" class="hover:underline" target="_blank">
                                                                첨부파일 다운로드
                                                            </a>
                                                        </div>
                                                    </c:if>
                                                    
                                                    <div class="flex items-center space-x-3 mt-2 text-xs">
                                                        <c:choose>
                                                            <c:when test="${loggedInUser != null}">
                                                                <c:choose>
                                                                    <c:when test="${likeMap[reply.comment_id]}">
                                                                        <button onclick="upvoteComment(${reply.comment_id}, ${post.postId})" 
                                                                                class="flex items-center space-x-1 transition-colors text-red-500">
                                                                            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                            </svg>
                                                                            <span>추천 ${reply.upvotes}</span>
                                                                        </button>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <button onclick="upvoteComment(${reply.comment_id}, ${post.postId})" 
                                                                                class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                            </svg>
                                                                            <span>추천 ${reply.upvotes}</span>
                                                                        </button>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="flex items-center space-x-1 text-gray-600">
                                                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                    </svg>
                                                                    <span>추천 ${reply.upvotes}</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${loggedInUser != null}">
                                                            <button onclick="toggleReplyForm(${reply.comment_id})" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                                        </c:if>
                                                    </div>

                                                    <c:if test="${loggedInUser != null}">
                                                        <div id="replyForm_${reply.comment_id}" class="mt-3 hidden">
                                                            <form action="${pageContext.request.contextPath}/submitCommuComment" method="post" class="reply-form">
                                                                <input type="hidden" name="postId" value="${post.postId}">
                                                                <input type="hidden" name="parentCommentId" value="${reply.comment_id}">
                                                                <input type="hidden" name="userId" value="${loggedInUser.userId}">
                                                                <input type="hidden" name="type" value="소통">
                                                                <input type="hidden" name="status" value="공개">
                                                                <input type="hidden" name="judgment" value="">
                                                                <input type="hidden" name="nowPage" value="${nowPage}">
                                                                <div class="flex space-x-2">
                                                                    <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                                    <button type="submit" class="px-3 py-1 bg-primary text-white rounded-lg hover:bg-primary-dark text-xs whitespace-nowrap">등록</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-8 text-gray-500">
                                아직 댓글이 없습니다. 첫 댓글을 작성해보세요!
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </main>

    <!-- 게시글 신고 모달 -->
    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md p-6">
            <h3 class="text-lg font-semibold">게시글 신고</h3>
            <div class="border-b my-2"></div>
            <p class="text-sm text-gray-600 mb-4">신고 사유를 작성해주세요.</p>
            <textarea id="postReportReason" class="w-full border rounded p-2" rows="3" placeholder="신고 사유를 입력하세요"></textarea>
            <div class="flex justify-end space-x-2 mt-4">
                <button onclick="closeReportModal()" class="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300">취소</button>
                <button onclick="submitReport()" class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">신고</button>
            </div>
        </div>
    </div>

    <!-- 댓글 신고 모달 -->
    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md p-6">
            <h3 class="text-lg font-semibold">댓글 신고</h3>
            <div class="border-b my-2"></div>
            <p class="text-sm text-gray-600 mb-4">신고 사유를 작성해주세요.</p>
            <input type="hidden" id="commentIdToReport">
            <textarea id="commentReportReason" class="w-full border rounded p-2" rows="3" placeholder="신고 사유를 입력하세요"></textarea>
            <div class="flex justify-end space-x-2 mt-4">
                <button onclick="closeCommentReportModal()" class="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300">취소</button>
                <button onclick="submitCommentReport()" class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">신고</button>
            </div>
        </div>
    </div>

    <footer class="bg-gray-100 mt-12">
        <jsp:include page="../Common/Footer.jsp" />
    </footer>

    <script>
        var oEditors = [];
        
        nhn.husky.EZCreator.createInIFrame({
            oAppRef: oEditors,
            elPlaceHolder: "ir1",
            sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html",
            fCreator: "createSEditor2"
        });
        
        function submitContents() {
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            var content = document.getElementById("ir1").value;
            
            if(content === '' || content === '<p>&nbsp;</p>' || content.trim() === '') {
                alert('댓글 내용을 입력해주세요.');
                return false;
            }
            
            document.getElementById("commentForm").submit();
        }
        
        // 답글 작성 폼 토글
        function toggleReplyForm(commentId) {
            var replyForm = document.getElementById('replyForm_' + commentId);
            if(replyForm.classList.contains('hidden')) {
                // 모든 답글 폼 숨기기
                document.querySelectorAll('[id^="replyForm_"]').forEach(function(form) {
                    form.classList.add('hidden');
                });
                // 선택한 답글 폼만 표시
                replyForm.classList.remove('hidden');
            } else {
                replyForm.classList.add('hidden');
            }
        }
        
        // 댓글 추천 기능
        function upvoteComment(commentId, postId) {
            <c:choose>
                <c:when test="${loggedInUser == null}">
                    alert('로그인이 필요한 기능입니다.');
                    return;
                </c:when>
                <c:otherwise>
                    fetch('${pageContext.request.contextPath}/upvoteComment', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'commentId=' + commentId + '&userId=${loggedInUser.userId}'
                    })
                    .then(response => response.json())
                    .then(data => {
                        if(data.success) {
                            // 페이지 새로고침으로 추천 상태 업데이트
                            location.reload();
                        } else {
                            alert(data.message || '추천 처리 중 오류가 발생했습니다.');
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('추천 처리 중 오류가 발생했습니다.');
                    });
                </c:otherwise>
            </c:choose>
        }
        
     // 게시글 신고 모달
        function openReportModal() { 
            document.getElementById('reportModal').classList.remove('hidden'); 
        }
        
        function closeReportModal() { 
            document.getElementById('reportModal').classList.add('hidden'); 
            document.getElementById('postReportReason').value = ''; 
        }
        
        function submitReport() {
            var reason = document.getElementById('postReportReason').value;
            if (!reason.trim()) { 
                alert('신고 사유를 입력해주세요.'); 
                return; 
            }
            
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '<%= request.getContextPath() %>/UI/JSP/User/ReportPostProc.jsp';
            
            var postIdInput = document.createElement('input');
            postIdInput.type = 'hidden';
            postIdInput.name = 'postId';
            postIdInput.value = '<%= postId %>';
            
            var reasonInput = document.createElement('input');
            reasonInput.type = 'hidden';
            reasonInput.name = 'reportReason';
            reasonInput.value = reason;
            
            form.appendChild(postIdInput);
            form.appendChild(reasonInput);
            document.body.appendChild(form);
            form.submit();
        }
        
     // 댓글 신고 모달
        function openCommentReportModal(commentId) {
            document.getElementById('commentIdToReport').value = commentId;
            document.getElementById('commentReportModal').classList.remove('hidden');
        }
        
        function closeCommentReportModal() { 
            document.getElementById('commentReportModal').classList.add('hidden'); 
            document.getElementById('commentReportReason').value = ''; 
        }
        
        function submitCommentReport() {
            var commentId = document.getElementById('commentIdToReport').value;
            var reason = document.getElementById('commentReportReason').value;
            if (!reason.trim()) { 
                alert('신고 사유를 입력해주세요.'); 
                return; 
            }
            
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '<%= request.getContextPath() %>/UI/JSP/User/ReportCommentProc.jsp';
            
            var commentIdInput = document.createElement('input');
            commentIdInput.type = 'hidden';
            commentIdInput.name = 'commentId';
            commentIdInput.value = commentId;
            
            var reasonInput = document.createElement('input');
            reasonInput.type = 'hidden';
            reasonInput.name = 'reportReason';
            reasonInput.value = reason;
            
            form.appendChild(commentIdInput);
            form.appendChild(reasonInput);
            document.body.appendChild(form);
            form.submit();
        }
        
        // 모달 외부 클릭시 닫기
        document.getElementById('reportModal').addEventListener('click', function(e) {
            if(e.target === this) {
                closeReportModal();
            }
        });
        
        document.getElementById('commentReportModal').addEventListener('click', function(e) {
            if(e.target === this) {
                closeCommentReportModal();
            }
        });
        
        // 파일 선택 초기화
        function clearFiles() {
            document.getElementById('comment-file').value = '';
            document.getElementById('selected-files-display').classList.add('hidden');
            document.getElementById('file-count-display').textContent = '파일을 선택하세요';
            document.getElementById('file-list-detail').innerHTML = '';
        }
        
        // 파일 첨부 핸들러
        function handleFileSelect(event) {
            const fileInput = event.target;
            const files = fileInput.files;
            const selectedFilesDisplay = document.getElementById('selected-files-display');
            const fileCountDisplay = document.getElementById('file-count-display');
            const fileListDetail = document.getElementById('file-list-detail');

            if (files.length === 1) {
                selectedFilesDisplay.classList.remove('hidden');
                fileCountDisplay.textContent = `1개 파일 선택됨`;
                
                fileListDetail.innerHTML = '';
                const file = files[0];
                const fileSizeKB = (file.size / 1024).toFixed(1);
                const fileItem = document.createElement('div');
                fileItem.className = 'flex items-center space-x-2 text-sm text-gray-700 p-1'; 
                fileItem.innerHTML = `
                    <svg class="w-4 h-4 text-primary flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    <span class="flex-1 truncate">${file.name}</span>
                    <span class="text-xs text-gray-500">${fileSizeKB}</span>
                `;
                fileListDetail.appendChild(fileItem);
                
            } else {
                clearFiles();
            }
        }
        
        function changeSort(sort) {
            const postId = '<c:out value="${post.postId}" />';
            const nowPage = '<c:out value="${nowPage}" />';
            
            window.location.href = '${pageContext.request.contextPath}/commu/watch.do?id=' + postId + '&sort=' + sort;
        }

        // 초기화 및 이벤트 리스너 설정
        document.addEventListener('DOMContentLoaded', function() {
            const fileInput = document.getElementById('comment-file');
            if (fileInput) {
                fileInput.addEventListener('change', handleFileSelect);
            }
        });
    </script>
</body>
</html>

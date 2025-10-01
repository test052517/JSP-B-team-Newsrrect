<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mgr.PostMgr, beans.PostBean, mgr.CommentMgr, beans.CommentBean, mgr.CommentLikeMgr, java.util.Vector, java.util.HashMap, java.util.Map" %>
<%@ page import="beans.AnalysisResultBean, mgr.NewsAnalysisMgr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="commentLikeMgr" class="mgr.CommentLikeMgr" scope="page" />
<%
    beans.UserBean loggedInUser = (beans.UserBean)session.getAttribute("loggedInUser");
    int postId = 0;
    if(request.getParameter("id") != null) {
        try {
            postId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("InfoBoard.jsp");
            return;
        }
    } else {
        response.sendRedirect("InfoBoard.jsp");
        return;
    }
    
    PostMgr postMgr = new PostMgr();
    PostBean post = postMgr.getPostByPostID(postId);
    
    if(post == null) {
        out.println("<script>alert('게시물이 존재하지 않습니다.'); location.href='InfoBoard.jsp';</script>");
        return;
    }
    pageContext.setAttribute("post", post);

    CommentMgr commentMgr = new CommentMgr();
    Vector<CommentBean> commentList = commentMgr.getCommentList(postId);
    
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
    
    // 베스트 댓글 선정 (추천 수가 가장 많은 댓글)
    CommentBean bestComment = null;
    int maxUpvotes = 0;
    for(CommentBean comment : commentList) {
        if(comment.getUpvotes() > maxUpvotes) {
            maxUpvotes = comment.getUpvotes();
            bestComment = comment;
        }
    }
    
    request.setAttribute("likeMap", likeMap);
    request.setAttribute("bestComment", bestComment);
    pageContext.setAttribute("commentList", commentList);
    
    // AI 분석 결과 조회 추가
    AnalysisResultBean analysisResult = null;
    
    try {
        NewsAnalysisMgr analysisMgr = new NewsAnalysisMgr();
        String content = post.getContent();
        
        if(content != null && !content.isEmpty()) {
            java.util.regex.Pattern urlPattern = java.util.regex.Pattern.compile(
                "(https?://[^\\s<>\"]+|www\\.[^\\s<>\"]+)",
                java.util.regex.Pattern.CASE_INSENSITIVE
            );
            java.util.regex.Matcher matcher = urlPattern.matcher(content);
            if(matcher.find()) {
                String originalUrl = matcher.group(1);
                if(originalUrl.startsWith("www.")) {
                    originalUrl = "http://" + originalUrl;
                }
                analysisResult = analysisMgr.findByUrl(originalUrl);
            }
        }
        
        if(analysisResult == null) {
            String textKey = "text:postId:" + postId;
            analysisResult = analysisMgr.findByUrl(textKey);
        }
    } catch(Exception e) {
        analysisResult = null;
    }
    
    pageContext.setAttribute("analysisResult", analysisResult);
    
    // 신뢰도 계산
    int trueCount = 0;
    int falseCount = 0;
    int ambiguousCount = 0;
    for(CommentBean comment : commentList) {
        if("참".equals(comment.getJudgment())) {
            trueCount++;
        } else if("거짓".equals(comment.getJudgment())) {
            falseCount++;
        } else if("모호".equals(comment.getJudgment())) {
            ambiguousCount++;
        }
    }
    int totalVotes = trueCount + falseCount + ambiguousCount;
    int reliability = (totalVotes == 0) ? 50 : (int)(((double)trueCount / totalVotes) * 100);

    pageContext.setAttribute("trueCount", trueCount);
    pageContext.setAttribute("falseCount", falseCount);
    pageContext.setAttribute("ambiguousCount", ambiguousCount);
    pageContext.setAttribute("reliability", reliability);
    pageContext.setAttribute("loggedInUser", loggedInUser);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${post.title}" /> - 정보 검증 게시판</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/styles.css">
    <script type="text/javascript" src="<%= request.getContextPath() %>/se2/js/HuskyEZCreator.js" charset="utf-8"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { 'primary': '#5d74f8', 'primary-dark': '#4c63e7', 'primary-light': '#7d8ff9' }
                }
            }
        }
    </script>
</head>
<body class="bg-white min-h-screen">
    <jsp:include page="../Common/Header.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900"><c:out value="${post.title}" /></h1>
                </div>

                <div class="mb-6">
                    <div class="bg-blue-50 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <span>작성자: <c:out value="${post.nickname}" /></span>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path></svg>
                                    <span>${commentList.size()}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                    <span>${post.viewCount}</span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span>${post.createdAt}</span>
                                <c:if test="${not empty loggedInUser}"><button onclick="openReportModal()" class="text-gray-500 hover:text-red-500">🚨</button></c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <c:if test="${not empty analysisResult}">
                <div class="mb-6">
                    <div class="bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-5">
                        <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                            <svg class="w-5 h-5 mr-2 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
                            </svg>
                            AI 분석 결과
                        </h3>
                        
                        <div class="mb-4">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-sm font-medium text-gray-700">AI 신뢰도 점수</span>
                                <span class="text-2xl font-bold text-primary">${analysisResult.reliabilityScore}%</span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-2">
                                <div class="h-2 rounded-full transition-all duration-500 ${analysisResult.reliabilityScore >= 80 ? 'bg-green-500' : analysisResult.reliabilityScore >= 60 ? 'bg-yellow-500' : 'bg-red-500'}" 
                                     style="width: ${analysisResult.reliabilityScore}%"></div>
                            </div>
                        </div>
                        
                        <c:if test="${not empty analysisResult.summary}">
                        <div class="bg-white rounded-md p-4 border border-blue-200">
                            <h4 class="text-sm font-semibold text-gray-800 mb-2">요약</h4>
                            <p class="text-sm text-gray-700 leading-relaxed"><c:out value="${analysisResult.summary}" /></p>
                        </div>
                        </c:if>
                    </div>
                </div>
                </c:if>

                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed min-h-[100px]"><c:out value="${post.content}" escapeXml="false" /></div>
                </div>

                <div class="mb-6">
                    <div class="mb-2">
                        <label class="block text-sm font-medium text-gray-900 mb-2">신뢰도 ${reliability}%</label>
                        <div class="w-full bg-gray-200 rounded-full h-2">
                            <div class="bg-primary h-2 rounded-full" style="width: ${reliability}%"></div>
                        </div>
                    </div>
                    <div class="flex justify-center space-x-8 mt-4">
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-green-100 text-green-800 rounded-full">
                            <span class="text-lg font-medium">참</span><span class="text-2xl font-bold">${trueCount}</span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-red-100 text-red-800 rounded-full">
                            <span class="text-lg font-medium">거짓</span><span class="text-2xl font-bold">${falseCount}</span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-yellow-100 text-yellow-800 rounded-full">
                            <span class="text-lg font-medium">모호</span><span class="text-2xl font-bold">${ambiguousCount}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <c:if test="${not empty loggedInUser}">
                    <div class="mb-6">
                        <form action="${pageContext.request.contextPath}/submitComment" method="post" id="commentForm">
                            <input type="hidden" name="postId" value="${post.postId}" />
                            <div class="mb-4">
                                <select name="judgment" class="w-32 px-3 py-2 border border-gray-200 rounded-md">
                                    <option value="">판정 선택</option><option value="참">참</option><option value="거짓">거짓</option><option value="모호">모호</option>
                                </select>
                            </div>
                            <div class="mb-4"><textarea name="content" id="ir1" rows="5" style="width:100%; display:none;"></textarea></div>
                            <div class="flex justify-end"><button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md">댓글등록</button></div>
                        </form>
                    </div>
                </c:if>

                <div class="flex justify-between items-center mb-4 border-t pt-6">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 ${commentList.size()}개</h3>
                </div>
                
                <!-- BEST 댓글 섹션 -->
                <c:if test="${not empty bestComment && bestComment.upvotes > 0}">
                    <div class="mb-8 bg-blue-100 rounded-lg p-4">
                        <h4 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                            <span class="text-2xl mr-2">⭐</span> BEST 댓글
                        </h4>
                        <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-md">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="font-bold text-primary"><c:out value="${bestComment.nickname}" /></span>
                                    <span class="px-2 py-1 bg-yellow-100 text-yellow-800 text-xs font-semibold rounded">BEST</span>
                                    <c:if test="${not empty bestComment.judgment}">
                                        <c:set var="judgmentColor" value="${bestComment.judgment == '참' ? 'green' : (bestComment.judgment == '거짓' ? 'red' : 'yellow')}" />
                                        <span class="px-2 py-1 bg-${judgmentColor}-100 text-${judgmentColor}-800 rounded text-sm">${bestComment.judgment}</span>
                                    </c:if>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500">${bestComment.formattedDate}</span>
                                    <c:if test="${not empty loggedInUser}"><span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${bestComment.comment_id})">🚨</span></c:if>
                                </div>
                            </div>
                            <div class="text-gray-900 mb-3 font-medium"><c:out value="${bestComment.content}" escapeXml="false" /></div>
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
                                <c:if test="${not empty loggedInUser}">
                                    <button onclick="toggleReplyForm(${bestComment.comment_id})" class="text-gray-600 hover:text-primary font-medium">답글쓰기</button>
                                </c:if>
                            </div>

                            <c:if test="${not empty loggedInUser}">
                                <div id="replyForm_${bestComment.comment_id}" class="mt-4 hidden">
                                    <form action="${pageContext.request.contextPath}/submitComment" method="post" class="reply-form">
                                        <input type="hidden" name="postId" value="${post.postId}">
                                        <input type="hidden" name="parentCommentId" value="${bestComment.comment_id}">
                                        <input type="hidden" name="type" value="정보">
                                        <input type="hidden" name="status" value="공개">
                                        <input type="hidden" name="judgment" value="">
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
                                    <div class="border-l-2 border-primary pl-4 py-2" style="margin-left: ${reply.layer * 20}px;">
                                        <div class="flex justify-between items-start mb-2">
                                            <div class="flex items-center space-x-2">
                                                <span class="font-semibold text-sm text-gray-700">
                                                    <c:forEach begin="1" end="${reply.layer}">↳ </c:forEach>
                                                    <c:out value="${reply.nickname}" />
                                                </span>
                                                <c:if test="${not empty reply.judgment}">
                                                    <c:set var="replyJudgmentColor" value="${reply.judgment == '참' ? 'green' : (reply.judgment == '거짓' ? 'red' : 'yellow')}" />
                                                    <span class="px-2 py-1 bg-${replyJudgmentColor}-100 text-${replyJudgmentColor}-800 rounded text-xs">${reply.judgment}</span>
                                                </c:if>
                                            </div>
                                            <div class="flex items-center space-x-2">
                                                <span class="text-xs text-gray-500">${reply.formattedDate}</span>
                                                <c:if test="${not empty loggedInUser}">
                                                    <span class="text-gray-500 cursor-pointer text-xs" onclick="openCommentReportModal(${reply.comment_id})">🚨</span>
                                                </c:if>
                                            </div>
                                        </div>
                                        <p class="text-sm text-gray-900"><c:out value="${reply.content}" escapeXml="false" /></p>
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
                                                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                        </svg>
                                                        <span>추천 ${reply.upvotes}</span>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty loggedInUser}">
                                                <button onclick="toggleReplyForm(${reply.comment_id})" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                            </c:if>
                                        </div>

                                        <c:if test="${not empty loggedInUser}">
                                            <div id="replyForm_${reply.comment_id}" class="mt-3 hidden">
                                                <form action="${pageContext.request.contextPath}/submitComment" method="post" class="reply-form">
                                                    <input type="hidden" name="postId" value="${post.postId}">
                                                    <input type="hidden" name="parentCommentId" value="${reply.comment_id}">
                                                    <input type="hidden" name="type" value="정보">
                                                    <input type="hidden" name="status" value="공개">
                                                    <input type="hidden" name="judgment" value="">
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
                </c:if>

                <!-- 일반 댓글 목록 -->
                <div class="space-y-4 pt-4">
                    <c:choose>
                        <c:when test="${not empty commentList}">
                             <c:forEach var="comment" items="${commentList}">
                                <!-- 베스트 댓글은 제외 -->
                                <c:if test="${empty bestComment || comment.comment_id != bestComment.comment_id}">
                                    <div class="border border-gray-200 rounded-lg p-4 bg-white hover:shadow-md transition-shadow">
                                        <div class="flex justify-between items-start mb-2">
                                            <div class="flex items-center space-x-2">
                                                <span class="font-semibold"><c:out value="${comment.nickname}" /></span>
                                                <c:if test="${not empty comment.judgment}">
                                                    <c:set var="judgmentColor" value="${comment.judgment == '참' ? 'green' : (comment.judgment == '거짓' ? 'red' : 'yellow')}" />
                                                    <span class="px-2 py-1 bg-${judgmentColor}-100 text-${judgmentColor}-800 rounded text-sm">${comment.judgment}</span>
                                                </c:if>
                                            </div>
                                            <div class="flex items-center space-x-2">
                                                <span class="text-sm text-gray-500">${comment.formattedDate}</span>
                                                <c:if test="${not empty loggedInUser}"><span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${comment.comment_id})">🚨</span></c:if>
                                            </div>
                                        </div>
                                        <div class="text-gray-900 mb-3"><c:out value="${comment.content}" escapeXml="false" /></div>
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
                                            <c:if test="${not empty loggedInUser}">
                                                <button onclick="toggleReplyForm(${comment.comment_id})" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                            </c:if>
                                        </div>

                                        <c:if test="${not empty loggedInUser}">
                                            <div id="replyForm_${comment.comment_id}" class="mt-4 hidden">
                                                <form action="${pageContext.request.contextPath}/submitComment" method="post" class="reply-form">
                                                    <input type="hidden" name="postId" value="${post.postId}">
                                                    <input type="hidden" name="parentCommentId" value="${comment.comment_id}">
                                                    <input type="hidden" name="type" value="정보">
                                                    <input type="hidden" name="status" value="공개">
                                                    <input type="hidden" name="judgment" value="">
                                                    <div class="flex space-x-2">
                                                        <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                        <button type="submit" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark text-sm whitespace-nowrap">등록</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </c:if>

                                        <!-- 일반 댓글의 답글 목록 -->
                                        <div class="mt-4 ml-8 space-y-3">
                                            <c:set var="replyListKey" value="reply_${comment.comment_id}" />
                                            <c:forEach var="reply" items="${requestScope[replyListKey]}">
                                                <div class="border-l-2 border-primary pl-4 py-2" style="margin-left: ${reply.layer * 20}px;">
                                                    <div class="flex justify-between items-start mb-2">
                                                        <div class="flex items-center space-x-2">
                                                            <span class="font-semibold text-sm text-gray-700">
                                                                <c:forEach begin="1" end="${reply.layer}">↳ </c:forEach>
                                                                <c:out value="${reply.nickname}" />
                                                            </span>
                                                            <c:if test="${not empty reply.judgment}">
                                                                <c:set var="replyJudgmentColor" value="${reply.judgment == '참' ? 'green' : (reply.judgment == '거짓' ? 'red' : 'yellow')}" />
                                                                <span class="px-2 py-1 bg-${replyJudgmentColor}-100 text-${replyJudgmentColor}-800 rounded text-xs">${reply.judgment}</span>
                                                            </c:if>
                                                        </div>
                                                        <div class="flex items-center space-x-2">
                                                            <span class="text-xs text-gray-500">${reply.formattedDate}</span>
                                                            <c:if test="${not empty loggedInUser}">
                                                                <span class="text-gray-500 cursor-pointer text-xs" onclick="openCommentReportModal(${reply.comment_id})">🚨</span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <p class="text-sm text-gray-900"><c:out value="${reply.content}" escapeXml="false" /></p>
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
                                                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                                    </svg>
                                                                    <span>추천 ${reply.upvotes}</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${not empty loggedInUser}">
                                                            <button onclick="toggleReplyForm(${reply.comment_id})" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                                        </c:if>
                                                    </div>

                                                    <c:if test="${not empty loggedInUser}">
                                                        <div id="replyForm_${reply.comment_id}" class="mt-3 hidden">
                                                            <form action="${pageContext.request.contextPath}/submitComment" method="post" class="reply-form">
                                                                <input type="hidden" name="postId" value="${post.postId}">
                                                                <input type="hidden" name="parentCommentId" value="${reply.comment_id}">
                                                                <input type="hidden" name="type" value="정보">
                                                                <input type="hidden" name="status" value="공개">
                                                                <input type="hidden" name="judgment" value="">
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
                            <div class="text-center py-8 text-gray-500">등록된 댓글이 없습니다.</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <div class="mt-8 text-center"><a href="InfoBoard.jsp" class="bg-gray-200 text-gray-800 px-6 py-2 rounded-lg">목록</a></div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />
    
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
    
    <script>
        var oEditors = [];
        if (document.getElementById("ir1")) {
            nhn.husky.EZCreator.createInIFrame({ oAppRef: oEditors, elPlaceHolder: "ir1", sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html", htParams: { bUseToolbar: true, bUseVerticalResizer: true, bUseModeChanger: true }, fCreator: "createSEditor2" });
        }
        
        function submitContents() {
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            var form = document.getElementById("commentForm");
            var content = form.content.value.replace(/<p>&nbsp;<\/p>/gi, "").trim();
            if(form.judgment.value === "") { alert("판정을 선택해주세요."); return; }
            if (content === "") { alert("내용을 입력해주세요."); oEditors.getById["ir1"].exec("FOCUS"); return; }
            form.submit();
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
        window.addEventListener('click', function(e) {
            if (e.target == document.getElementById('reportModal')) closeReportModal();
            if (e.target == document.getElementById('commentReportModal')) closeCommentReportModal();
        });

        // 답글 폼 토글 함수
        function toggleReplyForm(commentId) {
            var replyForm = document.getElementById('replyForm_' + commentId);
            if (replyForm) {
                document.querySelectorAll('[id^="replyForm_"]').forEach(function(form) {
                    if (form.id !== 'replyForm_' + commentId) {
                        form.classList.add('hidden');
                    }
                });
                replyForm.classList.toggle('hidden');
                if (!replyForm.classList.contains('hidden')) {
                    replyForm.querySelector('textarea').focus();
                }
            }
        }

        // 답글 폼 제출 처리
        document.addEventListener('submit', function(e) {
            if (e.target.classList.contains('reply-form')) {
                var textarea = e.target.querySelector('textarea[name="content"]');
                var content = textarea.value.trim();
                
                if (content === "") {
                    e.preventDefault();
                    alert("답글 내용을 입력해주세요.");
                    textarea.focus();
                    return false;
                }
            }
        });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.PostBean" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.CommentBean" %>
<%@ page import="mgr.CommentMgr" %>
<%@ page import="mgr.CommentLikeMgr" %>
<%@ page import="mgr.DBConnectionMgr" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="commentLikeMgr" class="mgr.CommentLikeMgr" scope="page" />
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 보기 - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
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
<body class="min-h-screen">
<%
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if(userIdObj == null) {
        response.sendRedirect(request.getContextPath() + "/UI/JSP/Login/Login.jsp");
        return;
    }

    String postIdStr = request.getParameter("postId");
    if(postIdStr == null || postIdStr.equals("")) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    
    int postId = Integer.parseInt(postIdStr);
    
    PostMgr postMgr = new PostMgr();
    PostBean post = postMgr.getPost(postId);
    
    if(post == null) {
        out.println("<script>alert('게시글을 찾을 수 없습니다.'); history.back();</script>");
        return;
    }
    
    CommentMgr commentMgr = new CommentMgr();
    Vector<CommentBean> commentList = commentMgr.getCommentList(postId);
    
    Map<Integer, Boolean> likeMap = new HashMap<Integer, Boolean>();
    
    for(CommentBean comment : commentList) {
        Vector<CommentBean> replyList = commentMgr.getAllRepliesRecursive(comment.getComment_id());
        request.setAttribute("reply_" + comment.getComment_id(), replyList);
        
        boolean isLiked = commentLikeMgr.isLiked(comment.getComment_id(), userIdObj);
        likeMap.put(comment.getComment_id(), isLiked);
        
        for(CommentBean reply : replyList) {
            boolean isReplyLiked = commentLikeMgr.isLiked(reply.getComment_id(), userIdObj);
            likeMap.put(reply.getComment_id(), isReplyLiked);
        }
    }
    
    CommentBean bestComment = null;
    int maxUpvotes = 0;
    for(CommentBean comment : commentList) {
        if(comment.getUpvotes() > maxUpvotes) {
            maxUpvotes = comment.getUpvotes();
            bestComment = comment;
        }
    }
    
    int commentCount = commentList.size();
%>

    <jsp:include page="../Common/AdminHeader.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900"><%= post.getTitle() %></h1>
                </div>

                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <span><%= post.getNickname() %></span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span><%= commentCount %></span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span><%= post.getViewCount() %></span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span><%= post.getCreatedAt() %></span>
                                <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed">
                        <p><%= post.getContent() != null ? post.getContent() : "" %></p>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <form id="commentForm" action="<%= request.getContextPath() %>/submitCommuComment" method="post">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <input type="hidden" name="userId" value="<%= userIdObj %>">
                    <input type="hidden" name="type" value="소통">
                    <input type="hidden" name="status" value="공개">
                    <input type="hidden" name="judgment" value="">
                    
                    <div class="mb-6">
                        <div class="mb-4">
                            <textarea name="content" id="ir1" rows="10" cols="100" style="width:100%; height:300px; display:none;"></textarea>
                        </div>
                        
                        <div class="flex justify-end">
                            <button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                                댓글등록
                            </button>
                        </div>
                    </div>
                </form>
                
                <div class="flex justify-between items-center mb-4 border-t pt-6">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 <%= commentCount %>개</h3>
                </div>

                <% if(bestComment != null && bestComment.getUpvotes() > 0) { %>
                <div class="mb-8 bg-blue-100 rounded-lg p-4">
                    <h4 class="text-lg font-bold text-gray-900 mb-4 flex items-center">
                        <span class="text-2xl mr-2">⭐</span> BEST 댓글
                    </h4>
                    <div class="border border-gray-200 rounded-lg p-4 bg-white shadow-md">
                        <div class="flex justify-between items-start mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="font-bold text-primary"><%= bestComment.getNickname() %></span>
                                <span class="px-2 py-1 bg-yellow-100 text-yellow-800 text-xs font-semibold rounded">BEST</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-sm text-gray-500"><%= bestComment.getCreated_at() %></span>
                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(<%= bestComment.getComment_id() %>)">🚨</span>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <p class="text-gray-900 font-medium"><%= bestComment.getContent() %></p>
                        </div>
                        
                        <div class="flex items-center space-x-4 text-sm">
                            <% if(likeMap.get(bestComment.getComment_id()) != null && likeMap.get(bestComment.getComment_id())) { %>
                                <button onclick="upvoteComment(<%= bestComment.getComment_id() %>, <%= postId %>)" 
                                        class="flex items-center space-x-1 transition-colors text-red-500 font-semibold">
                                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>추천 <%= bestComment.getUpvotes() %></span>
                                </button>
                            <% } else { %>
                                <button onclick="upvoteComment(<%= bestComment.getComment_id() %>, <%= postId %>)" 
                                        class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>추천 <%= bestComment.getUpvotes() %></span>
                                </button>
                            <% } %>
                            <button type="button" onclick="toggleReplyForm(<%= bestComment.getComment_id() %>)" class="text-gray-600 hover:text-primary font-medium">답글쓰기</button>
                        </div>

                        <div id="replyForm_<%= bestComment.getComment_id() %>" class="mt-4 hidden">
                            <form action="<%= request.getContextPath() %>/submitCommuComment" method="post" class="reply-form">
                                <input type="hidden" name="postId" value="<%= postId %>">
                                <input type="hidden" name="parentCommentId" value="<%= bestComment.getComment_id() %>">
                                <input type="hidden" name="userId" value="<%= userIdObj %>">
                                <input type="hidden" name="type" value="소통">
                                <input type="hidden" name="status" value="공개">
                                <input type="hidden" name="judgment" value="">
                                <div class="flex space-x-2">
                                    <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                    <button type="submit" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark text-sm whitespace-nowrap">등록</button>
                                </div>
                            </form>
                        </div>

                        <div class="mt-4 ml-8 space-y-3">
                            <%
                            @SuppressWarnings("unchecked")
                            Vector<CommentBean> bestReplyList = (Vector<CommentBean>) request.getAttribute("reply_" + bestComment.getComment_id());
                            if(bestReplyList != null) {
                                for(CommentBean reply : bestReplyList) {
                            %>
                                <div class="border-l-2 border-primary pl-4 py-2" style="margin-left: <%= reply.getLayer() * 20 %>px;">
                                    <div class="flex justify-between items-start mb-2">
                                        <span class="font-semibold text-sm text-gray-700">
                                            <% for(int i = 0; i < reply.getLayer(); i++) { %>↳ <% } %>
                                            <%= reply.getNickname() %>
                                        </span>
                                        <div class="flex items-center space-x-2">
                                            <span class="text-xs text-gray-500"><%= reply.getCreated_at() %></span>
                                            <span class="text-gray-500 cursor-pointer text-xs" onclick="openCommentReportModal(<%= reply.getComment_id() %>)">🚨</span>
                                        </div>
                                    </div>
                                    <p class="text-sm text-gray-900"><%= reply.getContent() %></p>
                                    <div class="flex items-center space-x-3 mt-2 text-xs">
                                        <% if(likeMap.get(reply.getComment_id()) != null && likeMap.get(reply.getComment_id())) { %>
                                            <button onclick="upvoteComment(<%= reply.getComment_id() %>, <%= postId %>)" 
                                                    class="flex items-center space-x-1 transition-colors text-red-500">
                                                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                </svg>
                                                <span>추천 <%= reply.getUpvotes() %></span>
                                            </button>
                                        <% } else { %>
                                            <button onclick="upvoteComment(<%= reply.getComment_id() %>, <%= postId %>)" 
                                                    class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 515.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                </svg>
                                                <span>추천 <%= reply.getUpvotes() %></span>
                                            </button>
                                        <% } %>
                                        <button onclick="toggleReplyForm(<%= reply.getComment_id() %>)" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                    </div>

                                    <div id="replyForm_<%= reply.getComment_id() %>" class="mt-3 hidden">
                                        <form action="<%= request.getContextPath() %>/submitCommuComment" method="post" class="reply-form">
                                            <input type="hidden" name="postId" value="<%= postId %>">
                                            <input type="hidden" name="parentCommentId" value="<%= reply.getComment_id() %>">
                                            <input type="hidden" name="userId" value="<%= userIdObj %>">
                                            <input type="hidden" name="type" value="소통">
                                            <input type="hidden" name="status" value="공개">
                                            <input type="hidden" name="judgment" value="">
                                            <div class="flex space-x-2">
                                                <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                <button type="submit" class="px-3 py-1 bg-primary text-white rounded-lg hover:bg-primary-dark text-xs whitespace-nowrap">등록</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            <%
                                }
                            }
                            %>
                        </div>
                    </div>
                </div>
                <% } %>

                <div class="space-y-4">
                    <% for(CommentBean comment : commentList) { 
                        if(bestComment != null && comment.getComment_id() == bestComment.getComment_id()) {
                            continue;
                        }
                    %>
                        <div class="border border-gray-200 rounded-lg p-4 bg-white hover:shadow-md transition-shadow">
                            <div class="flex justify-between items-start mb-2">
                                <span class="font-semibold"><%= comment.getNickname() %></span>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500"><%= comment.getCreated_at() %></span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(<%= comment.getComment_id() %>)">🚨</span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <p class="text-gray-900"><%= comment.getContent() %></p>
                            </div>
                            
                            <div class="flex items-center space-x-4 text-sm">
                                <% if(likeMap.get(comment.getComment_id()) != null && likeMap.get(comment.getComment_id())) { %>
                                    <button onclick="upvoteComment(<%= comment.getComment_id() %>, <%= postId %>)" 
                                            class="flex items-center space-x-1 transition-colors text-red-500">
                                        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 515.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                        </svg>
                                        <span>추천 <%= comment.getUpvotes() %></span>
                                    </button>
                                <% } else { %>
                                    <button onclick="upvoteComment(<%= comment.getComment_id() %>, <%= postId %>)" 
                                            class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                            <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 515.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                        </svg>
                                        <span>추천 <%= comment.getUpvotes() %></span>
                                    </button>
                                <% } %>
                                <button onclick="toggleReplyForm(<%= comment.getComment_id() %>)" class="text-gray-600 hover:text-primary">답글쓰기</button>
                            </div>

                            <div id="replyForm_<%= comment.getComment_id() %>" class="mt-4 hidden">
                                <form action="<%= request.getContextPath() %>/submitCommuComment" method="post" class="reply-form">
                                    <input type="hidden" name="postId" value="<%= postId %>">
                                    <input type="hidden" name="parentCommentId" value="<%= comment.getComment_id() %>">
                                    <input type="hidden" name="userId" value="<%= userIdObj %>">
                                    <input type="hidden" name="type" value="소통">
                                    <input type="hidden" name="status" value="공개">
                                    <input type="hidden" name="judgment" value="">
                                    <div class="flex space-x-2">
                                        <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                        <button type="submit" class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark text-sm whitespace-nowrap">등록</button>
                                    </div>
                                </form>
                            </div>

                            <div class="mt-4 ml-8 space-y-3">
                                <%
                                @SuppressWarnings("unchecked")
                                Vector<CommentBean> replyList = (Vector<CommentBean>) request.getAttribute("reply_" + comment.getComment_id());
                                if(replyList != null) {
                                    for(CommentBean reply : replyList) {
                                %>
                                    <div class="border-l-2 border-primary pl-4 py-2" style="margin-left: <%= reply.getLayer() * 20 %>px;">
                                        <div class="flex justify-between items-start mb-2">
                                            <span class="font-semibold text-sm text-gray-700">
                                                <% for(int i = 0; i < reply.getLayer(); i++) { %>↳ <% } %>
                                                <%= reply.getNickname() %>
                                            </span>
                                            <div class="flex items-center space-x-2">
                                                <span class="text-xs text-gray-500"><%= reply.getCreated_at() %></span>
                                                <span class="text-gray-500 cursor-pointer text-xs" onclick="openCommentReportModal(<%= reply.getComment_id() %>)">🚨</span>
                                            </div>
                                        </div>
                                        <p class="text-sm text-gray-900"><%= reply.getContent() %></p>
                                        <div class="flex items-center space-x-3 mt-2 text-xs">
                                            <% if(likeMap.get(reply.getComment_id()) != null && likeMap.get(reply.getComment_id())) { %>
                                                <button onclick="upvoteComment(<%= reply.getComment_id() %>, <%= postId %>)" 
                                                        class="flex items-center space-x-1 transition-colors text-red-500">
                                                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 515.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                    </svg>
                                                    <span>추천 <%= reply.getUpvotes() %></span>
                                                </button>
                                            <% } else { %>
                                                <button onclick="upvoteComment(<%= reply.getComment_id() %>, <%= postId %>)" 
                                                        class="flex items-center space-x-1 transition-colors text-gray-600 hover:text-red-500">
                                                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 20 20">
                                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 515.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                                    </svg>
                                                    <span>추천 <%= reply.getUpvotes() %></span>
                                                </button>
                                            <% } %>
                                            <button onclick="toggleReplyForm(<%= reply.getComment_id() %>)" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                        </div>

                                        <div id="replyForm_<%= reply.getComment_id() %>" class="mt-3 hidden">
                                            <form action="<%= request.getContextPath() %>/submitCommuComment" method="post" class="reply-form">
                                                <input type="hidden" name="postId" value="<%= postId %>">
                                                <input type="hidden" name="parentCommentId" value="<%= reply.getComment_id() %>">
                                                <input type="hidden" name="userId" value="<%= userIdObj %>">
                                                <input type="hidden" name="type" value="소통">
                                                <input type="hidden" name="status" value="공개">
                                                <input type="hidden" name="judgment" value="">
                                                <div class="flex space-x-2">
                                                    <textarea name="content" rows="2" class="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-primary focus:border-primary text-sm" placeholder="답글을 입력하세요..." required></textarea>
                                                    <button type="submit" class="px-3 py-1 bg-primary text-white rounded-lg hover:bg-primary-dark text-xs whitespace-nowrap">등록</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                <%
                                    }
                                }
                                %>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-md">
                <form action="<%= request.getContextPath() %>/UI/JSP/Admin/AdminReportPostProc.jsp" method="post">
                    <input type="hidden" name="postId" value="<%= postId %>"/>
                    <div class="p-6">
                        <h3 class="text-lg font-semibold text-gray-900 mb-2">신고하기</h3>
                        <div class="border-b border-gray-200 mb-4"></div>
                        <p class="text-gray-900 mb-4">해당 게시글을 아래와 같은 사유로 신고합니다.</p>
                        
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-900 mb-2">신고사유</label>
                            <textarea name="reportReason" class="w-full bg-gray-100 border border-gray-200 rounded-md p-3 text-gray-900" rows="3" placeholder="신고 사유를 입력해주세요" required></textarea>
                        </div>
                        
                        <div class="flex justify-end space-x-3">
                            <button type="button" onclick="closeReportModal()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                                취소
                            </button>
                            <button type="submit" class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors">
                                신고
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <form action="<%= request.getContextPath() %>/UI/JSP/Admin/AdminReportCommentProc.jsp" method="post">
                    <input type="hidden" name="commentId" id="reportCommentId"/>
                    <div class="p-6">
                        <h3 class="text-lg font-semibold text-gray-900 mb-2">신고하기</h3>
                        <div class="border-b border-gray-200 mb-4"></div>
                        <p class="text-sm text-gray-600 mb-4">해당 댓글을 아래와 같은 사유로 신고합니다.</p>
                    
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">신고사유</label>
                            <textarea name="reportReason" class="w-full bg-gray-100 p-3 rounded text-gray-600 border border-gray-200" rows="3" placeholder="신고 사유를 입력해주세요" required></textarea>
                        </div>
                        
                        <div class="flex justify-end space-x-3">
                            <button type="button" onclick="closeCommentReportModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                            <button type="submit" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">신고</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        var oEditors = [];
        nhn.husky.EZCreator.createInIFrame({
            oAppRef: oEditors,
            elPlaceHolder: "ir1",
            sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html",	
            htParams : {
                bUseToolbar : true,
                bUseVerticalResizer : true,
                bUseModeChanger : true,
            },
            fCreator: "createSEditor2"
        });

        function submitContents() {
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            var form = document.getElementById("commentForm");
            if(form.content.value == "<p>&nbsp;</p>" || form.content.value == "") {
                alert("내용을 입력해주세요.");
                oEditors.getById["ir1"].exec("FOCUS");
                return;
            }

            try {
                form.submit();
            } catch(e) {}
        }

        function upvoteComment(commentId, postId) {
            fetch('<%= request.getContextPath() %>/upvoteComment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'commentId=' + commentId + '&userId=<%= userIdObj %>'
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
        }

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

        function openReportModal() {
            document.getElementById('reportModal').classList.remove('hidden');
        }

        function closeReportModal() {
            document.getElementById('reportModal').classList.add('hidden');
        }

        function openCommentReportModal(commentId) {
            document.getElementById('reportCommentId').value = commentId;
            document.getElementById('commentReportModal').classList.remove('hidden');
        }

        function closeCommentReportModal() {
            document.getElementById('commentReportModal').classList.add('hidden');
        }

        document.getElementById('reportModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeReportModal();
            }
        });
        
        document.getElementById('commentReportModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeCommentReportModal();
            }
        });
    </script>
</body>
</html>
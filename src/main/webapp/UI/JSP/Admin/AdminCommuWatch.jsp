<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.PostBean" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.CommentBean" %>
<%@ page import="mgr.CommentMgr" %>
<%@ page import="mgr.DBConnectionMgr" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
    
    DBConnectionMgr pool = DBConnectionMgr.getInstance();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    int commentCount = 0;
    List<Map<String, Object>> comments = new ArrayList<>();
    try {
        conn = pool.getConnection("user");
        String countSql = "SELECT COUNT(*) as cnt FROM comment WHERE post_id = ? AND status = '공개'";
        pstmt = conn.prepareStatement(countSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        if(rs.next()) {
            commentCount = rs.getInt("cnt");
        }
        rs.close();
        pstmt.close();
        
        String commentSql = "SELECT c.comment_id, c.user_id, c.layer, c.parent_comment_id, c.content, " +
                          "c.upvotes, c.created_at, u.nickname " +
                          "FROM comment c " +
                          "JOIN user u ON c.user_id = u.user_id " +
                          "WHERE c.post_id = ? AND c.status = '공개' " +
                          "ORDER BY c.upvotes DESC, c.created_at ASC";
        pstmt = conn.prepareStatement(commentSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            Map<String, Object> comment = new HashMap<>();
            comment.put("id", rs.getInt("comment_id"));
            comment.put("author", rs.getString("nickname"));
            comment.put("content", rs.getString("content"));
            comment.put("date", rs.getString("created_at"));
            comment.put("recommendations", rs.getInt("upvotes"));
            comment.put("layer", rs.getInt("layer"));
            comment.put("isReply", rs.getInt("layer") > 0);
            comment.put("isBest", rs.getInt("upvotes") >= 50);
            comments.add(comment);
        }
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        pool.freeConnection(conn, pstmt, rs);
    }
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
                <form id="commentForm" action="<%= request.getContextPath() %>/UI/JSP/Admin/AdminCommentProc.jsp" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    
                    <div class="mb-6">
                        <div class="mb-4">
                            <textarea name="content" id="ir1" rows="10" cols="100" style="width:100%; height:300px; display:none;"></textarea>
                        </div>
                        
                        <div class="mb-4">
                            <div class="flex items-center space-x-2 mb-2">
                                <input type="file" id="comment-file" name="commentFile" class="hidden" multiple>
                                <button type="button" onclick="document.getElementById('comment-file').click()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                                    첨부 파일
                                </button>
                                <span id="file-name-display" class="text-sm text-gray-500">파일을 선택하세요</span>
                            </div>
                            
                            <div id="selected-files" class="hidden">
                                <div class="bg-gray-50 border border-gray-200 rounded-md p-3">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center space-x-2">
                                            <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                            </svg>
                                            <span class="text-sm text-gray-700" id="file-name">선택된 파일 없음</span>
                                        </div>
                                        <button type="button" onclick="clearFiles()" class="text-red-500 hover:text-red-700 text-sm">삭제</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="flex justify-end">
                            <button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                                댓글등록
                            </button>
                        </div>
                    </div>
                </form>
                
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 <%= comments.size() %>개</h3>
                </div>

                <div class="mb-8 bg-blue-100 rounded-lg p-4">
                    <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                    <div class="space-y-4">
                    <% for(Map<String, Object> comment : comments) { 
                        if((Boolean)comment.get("isBest")) {
                    %>
                    <div class="border border-gray-200 rounded-lg p-4 bg-white">
                        <div class="flex justify-between items-start mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="font-semibold text-primary">BEST <%= comment.get("author") %></span>
                                <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-sm text-gray-500"><%= comment.get("date") %></span>
                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(<%= comment.get("id") %>)">🚨</span>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <p class="text-gray-900"><%= comment.get("content") %></p>
                        </div>
                        
                        <div class="flex items-center space-x-4 text-sm">
                            <button type="button" class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                                <span>추천 <%= comment.get("recommendations") %></span>
                            </button>
                            <button type="button" class="text-gray-600 hover:text-primary">답글쓰기</button>
                        </div>
                    </div>
                    <% }} %>
                    </div>
                </div>

                <div>
                    <div class="space-y-4">
                    <% for(Map<String, Object> comment : comments) { 
                         if(!(Boolean)comment.get("isBest")) {
                            boolean isReply = (Boolean)comment.get("isReply");
                    %>
                    <div class="<%= isReply ? "ml-6" : "" %>">
                        <div class="border border-gray-200 rounded-lg p-4 bg-white">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <% if(isReply) { %><span class="text-gray-500">→</span><% } %>
                                    <span class="font-semibold"><%= comment.get("author") %></span>
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500"><%= comment.get("date") %></span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(<%= comment.get("id") %>)">🚨</span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <p class="text-gray-900 mb-2"><%= comment.get("content") %></p>
                            </div>
                            
                            <div class="flex items-center space-x-4 text-sm">
                                <button type="button" class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>추천 <%= comment.get("recommendations") %></span>
                                </button>
                                <button type="button" class="text-gray-600 hover:text-primary">답글쓰기</button>
                            </div>
                        </div>
                    </div>
                    <% }} %>
                    </div>
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
                    </div>
                    
                    <div class="p-6">
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

        document.getElementById('comment-file').addEventListener('change', function(e) {
            const files = e.target.files;
            const selectedFilesDiv = document.getElementById('selected-files');
            const fileNameSpan = document.getElementById('file-name');
            const fileNameDisplay = document.getElementById('file-name-display');
            
            if (files.length > 0) {
                selectedFilesDiv.classList.remove('hidden');
                fileNameDisplay.classList.add('hidden');
                if (files.length === 1) {
                    fileNameSpan.textContent = files[0].name;
                } else {
                    fileNameSpan.textContent = files.length + '개 파일 선택됨';
                }
            } else {
                selectedFilesDiv.classList.add('hidden');
                fileNameDisplay.classList.remove('hidden');
            }
        });

        function clearFiles() {
            document.getElementById('comment-file').value = '';
            document.getElementById('selected-files').classList.add('hidden');
            document.getElementById('file-name-display').classList.remove('hidden');
        }

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
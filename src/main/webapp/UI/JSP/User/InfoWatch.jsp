<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mgr.PostMgr, beans.PostBean, mgr.CommentMgr, beans.CommentBean, java.util.Vector" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
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
    pageContext.setAttribute("commentList", commentList);
    
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
    int reliability = (totalVotes == 0) ? 50 : (int)(((double)trueCount / totalVotes) * 100); // 판정이 없으면 50%

    pageContext.setAttribute("trueCount", trueCount);
    pageContext.setAttribute("falseCount", falseCount);
    pageContext.setAttribute("ambiguousCount", ambiguousCount);
    pageContext.setAttribute("reliability", reliability);

    // 현재 로그인한 사용자 정보
    beans.UserBean loggedInUser = (beans.UserBean)session.getAttribute("loggedInUser");
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
                            <div class="mb-4">
                                <div class="flex items-center space-x-2 mb-2">
                                    <input type="file" id="comment-file" name="attachments" class="hidden" multiple>
                                    <button type="button" onclick="document.getElementById('comment-file').click()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md">첨부 파일</button>
                                    <span class="text-sm text-gray-500">파일을 선택하세요</span>
                                </div>
                                <div id="selected-files" class="hidden"><div class="bg-gray-50 border p-3"><div class="flex items-center justify-between"><div class="flex items-center space-x-2"><span class="text-sm" id="file-name"></span></div><button type="button" onclick="clearFiles()" class="text-red-500 text-sm">삭제</button></div></div></div>
                            </div>
                            <div class="flex justify-end"><button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md">댓글등록</button></div>
                        </form>
                    </div>
                </c:if>

                <div class="flex justify-between items-center mb-4 border-t pt-6">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 ${commentList.size()}개</h3>
                </div>
                
                <c:if test="${not empty commentList}">
                    <div class="mb-8 bg-blue-50 rounded-lg p-4">
                        <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                        <div class="border border-gray-200 rounded-lg p-4 bg-white">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="font-semibold text-primary"><c:out value="${commentList[0].nickname}" /></span>
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path></svg>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500">${commentList[0].formattedDate}</span>
                                    <c:if test="${not empty loggedInUser}"><span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${commentList[0].comment_id})">🚨</span></c:if>
                                    <c:if test="${not empty commentList[0].judgment}">
                                        <c:set var="judgmentColor" value="${commentList[0].judgment == '참' ? 'green' : (commentList[0].judgment == '거짓' ? 'red' : 'yellow')}" />
                                        <span class="px-2 py-1 bg-${judgmentColor}-100 text-${judgmentColor}-800 rounded text-sm">${commentList[0].judgment}</span>
                                    </c:if>
                                </div>
                            </div>
                            <div class="text-gray-900 mb-3"><c:out value="${commentList[0].content}" escapeXml="false" /></div>
                            <div class="flex items-center space-x-4 text-sm">
                                <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path></svg>
                                    <span>추천 ${commentList[0].upvotes}</span>
                                </button>
                                <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                            </div>
                        </div>
                    </div>
                </c:if>

                <div class="space-y-4 pt-4">
                    <c:choose>
                        <c:when test="${not empty commentList}">
                             <c:forEach var="comment" items="${commentList}" begin="${commentList.size() > 0 ? 1 : 0}">
                                <div class="border border-gray-200 rounded-lg p-4 bg-white">
                                    <div class="flex justify-between items-start mb-2">
                                        <div class="flex items-center space-x-2"><span class="font-semibold"><c:out value="${comment.nickname}" /></span></div>
                                        <div class="flex items-center space-x-2">
                                            <span class="text-sm text-gray-500">${comment.formattedDate}</span>
                                            <c:if test="${not empty loggedInUser}"><span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${comment.comment_id})">🚨</span></c:if>
                                            <c:if test="${not empty comment.judgment}">
                                                <c:set var="judgmentColor" value="${comment.judgment == '참' ? 'green' : (comment.judgment == '거짓' ? 'red' : 'yellow')}" />
                                                <span class="px-2 py-1 bg-${judgmentColor}-100 text-${judgmentColor}-800 rounded text-sm">${comment.judgment}</span>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="text-gray-900 mb-3"><c:out value="${comment.content}" escapeXml="false" /></div>
                                    <div class="flex items-center space-x-4 text-sm">
                                        <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path></svg>
                                            <span>추천 ${comment.upvotes}</span>
                                        </button>
                                        <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                                    </div>
                                </div>
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
    
    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md p-6"><h3 class="text-lg font-semibold">게시글 신고</h3><div class="border-b my-2"></div><p class="text-sm text-gray-600 mb-4">신고 사유를 작성해주세요.</p><textarea id="postReportReason" class="w-full border rounded p-2" rows="3"></textarea><div class="flex justify-end space-x-2 mt-4"><button onclick="closeReportModal()" class="px-4 py-2 bg-gray-200 rounded">취소</button><button onclick="submitReport()" class="px-4 py-2 bg-red-600 text-white rounded">신고</button></div></div>
    </div>
    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md p-6"><h3 class="text-lg font-semibold">댓글 신고</h3><div class="border-b my-2"></div><p class="text-sm text-gray-600 mb-4">신고 사유를 작성해주세요.</p><input type="hidden" id="commentIdToReport"><textarea id="commentReportReason" class="w-full border rounded p-2" rows="3"></textarea><div class="flex justify-end space-x-2 mt-4"><button onclick="closeCommentReportModal()" class="px-4 py-2 bg-gray-200 rounded">취소</button><button onclick="submitCommentReport()" class="px-4 py-2 bg-red-600 text-white rounded">신고</button></div></div>
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
        function openReportModal() { document.getElementById('reportModal').classList.remove('hidden'); }
        function closeReportModal() { document.getElementById('reportModal').classList.add('hidden'); document.getElementById('postReportReason').value = ''; }
        function submitReport() {
            var reason = document.getElementById('postReportReason').value;
            if (!reason.trim()) { alert('신고 사유를 입력해주세요.'); return; }
            alert('게시글 신고가 접수되었습니다.'); closeReportModal();
        }
        function openCommentReportModal(commentId) {
            document.getElementById('commentIdToReport').value = commentId;
            document.getElementById('commentReportModal').classList.remove('hidden');
        }
        function closeCommentReportModal() { document.getElementById('commentReportModal').classList.add('hidden'); document.getElementById('commentReportReason').value = ''; }
        function submitCommentReport() {
            var commentId = document.getElementById('commentIdToReport').value;
            var reason = document.getElementById('commentReportReason').value;
            if (!reason.trim()) { alert('신고 사유를 입력해주세요.'); return; }
            alert('댓글(ID: ' + commentId + ') 신고가 접수되었습니다.'); closeCommentReportModal();
        }
        window.addEventListener('click', function(e) {
            if (e.target == document.getElementById('reportModal')) closeReportModal();
            if (e.target == document.getElementById('commentReportModal')) closeCommentReportModal();
        });
        document.getElementById('comment-file')?.addEventListener('change', function(e) {
            const files = e.target.files, div = document.getElementById('selected-files'), span = document.getElementById('file-name');
            if (files.length > 0) {
                div.classList.remove('hidden');
                span.textContent = files.length === 1 ? files[0].name : `${files.length}개 파일 선택됨`;
            } else { div.classList.add('hidden'); }
        });
        function clearFiles() {
            const input = document.getElementById('comment-file'); input.value = '';
            document.getElementById('selected-files').classList.add('hidden');
            document.getElementById('file-name').textContent = '';
        }
    </script>
</body>
</html>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.PostBean" %>
<%@ page import="mgr.PostMgr" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>정보 검증 게시판 관리 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="../../CSS/fonts.css">
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
<body class="min-h-screen bg-gray-50">
<%
    String postIdStr = request.getParameter("postId");
    if(postIdStr == null || postIdStr.equals("")) {
        response.sendRedirect("AdminInfoBoard.jsp");
        return;
    }
    
    int postId = Integer.parseInt(postIdStr);
    
    PostMgr postMgr = new PostMgr();
    PostBean post = postMgr.getPostByPostID(postId);
    
    if(post == null) {
        out.println("<script>alert('게시글을 찾을 수 없습니다.'); location.href='AdminInfoBoard.jsp';</script>");
        return;
    }
%>
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <div class="flex-shrink-0">
                    <a href="AdminMainPage.jsp"><h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1></a>
                </div>
                <div class="absolute right-0 flex items-center space-x-4">
                    <a href="#" onclick="logout()" class="text-primary hover:text-primary-dark text-sm font-medium">로그아웃</a>
                </div>
            </div>
        </div>
    </header>
    
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-16 py-4">
                <a href="AdminInfo.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="AdminCommu.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="AdminInfoBoard.jsp" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded font-paperozi-medium">정보 검증 게시판 관리</a>
                <a href="AdminUserReport.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">유저 / 신고 관리</a>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">정보 검증 게시판 관리</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <form id="approvalForm" action="processPost.jsp" method="post">
                <input type="hidden" name="postId" value="<%= post.getPostId() %>">
                
                <div class="p-6">
                    <div class="mb-4">
                        <span class="inline-block bg-primary text-white px-3 py-1 rounded-full text-sm font-medium">게시글 #<%= post.getPostId() %></span>
                        <span class="inline-block ml-2 <%= "비공개".equals(post.getStatus()) ? "bg-yellow-100 text-yellow-800" : "bg-gray-100 text-gray-800" %> px-3 py-1 rounded-full text-sm font-medium"><%= post.getStatus() %></span>
                    </div>

                    <div class="mb-4">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">제목</label>
                        <div class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-lg text-gray-900 font-medium"><%= post.getTitle() %></div>
                    </div>

                    <div class="mb-6">
                        <div class="bg-blue-50 border border-blue-100 rounded-lg p-4">
                            <div class="grid grid-cols-2 gap-4">
                                <div class="flex items-center space-x-2">
                                    <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                                    <div>
                                        <p class="text-xs text-gray-500">작성자</p>
                                        <p class="text-sm font-semibold text-gray-900"><%= post.getNickname() %></p>
                                    </div>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                                    <div>
                                        <p class="text-xs text-gray-500">작성일자</p>
                                        <%-- [수정] 메서드 이름 변경 --%>
                                        <p class="text-sm font-semibold text-gray-900"><%= post.getCreatedAt() %></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">글내용</label>
                        <div class="w-full px-4 py-6 bg-gray-50 border border-gray-200 rounded-lg text-gray-800 min-h-[200px] leading-relaxed">
                            <%= post.getContent() != null ? post.getContent().replace("\n", "<br>") : "" %>
                        </div>
                    </div>

                    <div class="mb-6">
                        <label class="block text-sm font-semibold text-gray-700 mb-3">게시글 통계</label>
                        <div class="grid grid-cols-3 gap-4">
                            <div class="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg border border-blue-200">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-xs text-blue-600 font-medium">조회수</p>
                                        <%-- [수정] 메서드 이름 변경 --%>
                                        <p class="text-2xl font-bold text-blue-700 mt-1"><%= post.getViewCount() %></p>
                                    </div>
                                    <svg class="w-8 h-8 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path></svg>
                                </div>
                            </div>
                            
                            <div class="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-lg border border-green-200">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-xs text-green-600 font-medium">추천수</p>
                                        <%-- [수정] 메서드 이름 변경 --%>
                                        <p class="text-2xl font-bold text-green-700 mt-1"><%= post.getRecommandCount() %></p>
                                    </div>
                                    <svg class="w-8 h-8 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5"></path></svg>
                                </div>
                            </div>
                            
                            <div class="bg-gradient-to-br from-red-50 to-red-100 p-4 rounded-lg border border-red-200">
                                <div class="flex items-center justify-between">
                                    <div>
                                        <p class="text-xs text-red-600 font-medium">신고수</p>
                                        <%-- [수정] 메서드 이름 변경 --%>
                                        <p class="text-2xl font-bold text-red-700 mt-1"><%= post.getReportCount() %></p>
                                    </div>
                                    <svg class="w-8 h-8 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>

        <div class="flex justify-center space-x-4 mb-8">
            <button onclick="approvePost()" class="group relative bg-green-600 text-white px-10 py-4 rounded-lg hover:bg-green-700 transition-all duration-300 font-semibold shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"><span class="flex items-center space-x-2"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg><span>승인</span></span></button>
            <button onclick="rejectPost()" class="group relative bg-red-600 text-white px-10 py-4 rounded-lg hover:bg-red-700 transition-all duration-300 font-semibold shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"><span class="flex items-center space-x-2"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg><span>거절</span></span></button>
            <button onclick="goBack()" class="group relative bg-gray-500 text-white px-10 py-4 rounded-lg hover:bg-gray-600 transition-all duration-300 font-semibold shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"><span class="flex items-center space-x-2"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg><span>목록으로</span></span></button>
        </div>
    </main>

    <div id="approvalModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-xl shadow-2xl max-w-md w-full transform transition-all">
            <div class="p-6"><div class="flex items-center justify-center w-12 h-12 mx-auto bg-green-100 rounded-full mb-4"><svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg></div><h3 class="text-xl font-bold text-gray-900 mb-2 text-center">게시글 승인</h3><p class="text-gray-600 mb-6 text-center">이 게시글을 승인하시겠습니까?<br><span class="text-sm text-gray-500">승인 시 게시판에 공개됩니다.</span></p><div class="flex space-x-3"><button onclick="closeModal()" class="flex-1 px-4 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors font-medium">취소</button><button onclick="confirmApproval()" class="flex-1 px-4 py-3 text-white bg-green-600 rounded-lg hover:bg-green-700 transition-colors font-medium">승인</button></div></div>
        </div>
    </div>
    <div id="rejectionModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-xl shadow-2xl max-w-md w-full transform transition-all">
            <form id="rejectionForm" action="processPost.jsp" method="post">
                <input type="hidden" name="postId" value="<%= post.getPostId() %>">
                <input type="hidden" name="action" value="reject">
                <div class="p-6"><div class="flex items-center justify-center w-12 h-12 mx-auto bg-red-100 rounded-full mb-4"><svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg></div><h3 class="text-xl font-bold text-gray-900 mb-2 text-center">게시글 거절</h3><p class="text-gray-600 mb-4 text-center text-sm">거절 사유를 입력해주세요.</p><div class="mb-4"><label class="block text-sm font-semibold text-gray-700 mb-2">거절 사유 <span class="text-red-500">*</span></label><textarea name="rejectionReason" class="w-full border border-gray-300 rounded-lg p-3 h-32 resize-none focus:ring-2 focus:ring-red-500 focus:border-red-500 focus:outline-none transition-all" placeholder="거절 사유를 상세히 입력해주세요..." required></textarea></div><div class="flex space-x-3"><button type="button" onclick="closeModal()" class="flex-1 px-4 py-3 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors font-medium">취소</button><button type="submit" class="flex-1 px-4 py-3 text-white bg-red-600 rounded-lg hover:bg-red-700 transition-colors font-medium">거절</button></div></div>
            </form>
        </div>
    </div>

    <jsp:include page="/UI/JSP/Common/Footer.jsp" />

    <script>
        function approvePost() {
            document.getElementById('approvalModal').classList.remove('hidden');
        }
        function rejectPost() {
            document.getElementById('rejectionModal').classList.remove('hidden');
        }
        function closeModal() {
            document.getElementById('approvalModal').classList.add('hidden');
            document.getElementById('rejectionModal').classList.add('hidden');
        }
        function confirmApproval() {
            const form = document.getElementById('approvalForm');
            const hiddenInput = document.createElement('input');
            hiddenInput.type = 'hidden';
            hiddenInput.name = 'action';
            hiddenInput.value = 'approve';
            form.appendChild(hiddenInput);
            form.submit();
        }
        function goBack() {
            location.href = 'AdminInfoBoard.jsp';
        }
        function logout() {
            if(confirm('로그아웃 하시겠습니까?')) {
                location.href = '../User/Login.jsp';
            }
        }
        window.onclick = function(event) {
            const approvalModal = document.getElementById('approvalModal');
            const rejectionModal = document.getElementById('rejectionModal');
            if (event.target === approvalModal) { closeModal(); }
            if (event.target === rejectionModal) { closeModal(); }
        }
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') { closeModal(); }
        });
    </script>
</body>
</html>
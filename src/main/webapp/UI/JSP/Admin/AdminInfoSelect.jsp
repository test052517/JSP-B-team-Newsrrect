<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>정보 검증 게시판 관리 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="CSS/fonts.css">
    <link rel="stylesheet" href="styles/fonts.css">
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
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <!-- Logo - Centered -->
                <div class="flex-shrink-0">
                    <a href="AdminMainPage.jsp"><h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1></a>
                </div>
                
                <!-- User Menu - Absolute positioned right -->
                <div class="absolute right-0 flex items-center space-x-4">
                    <a href="#" onclick="logout()" class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그아웃
                    </a>
                </div>
            </div>
        </div>
    </header>
    
    <!-- Navigation -->
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-16 py-4">
                <a href="AdminInfo.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="AdminCommu.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="AdminInfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판 관리</a>
                <a href="AdminUserReport.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">유저 / 신고 관리</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판 관리</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <!-- Post Review Content -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <form id="approvalForm" action="processPost.jsp" method="post">
                <%
                    String postId = request.getParameter("postId");
                    // 실제로는 데이터베이스에서 해당 게시글 정보를 가져와야 함
                    String postTitle = (String) request.getAttribute("postTitle");
                    String postAuthor = (String) request.getAttribute("postAuthor");
                    String postContent = (String) request.getAttribute("postContent");
                    String postDate = (String) request.getAttribute("postDate");
                    Double credibilityScore = (Double) request.getAttribute("credibilityScore");
                    
                    // 기본값 설정
                    if (postTitle == null) postTitle = "검증 대기중인 게시글 제목";
                    if (postAuthor == null) postAuthor = "작성자명";
                    if (postContent == null) postContent = "게시글 내용이 여기에 표시됩니다...";
                    if (postDate == null) postDate = "2024-09-25";
                    if (credibilityScore == null) credibilityScore = 65.0;
                %>
                
                <input type="hidden" name="postId" value="<%= postId %>">
                
                <div class="p-6">
                    <!-- Post Title -->
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">제목</label>
                        <div class="w-full px-4 py-3 bg-gray-100 border border-gray-200 rounded-lg text-gray-900">
                            <%= postTitle %>
                        </div>
                    </div>

                    <!-- Author and Date Info -->
                    <div class="mb-6">
                        <div class="bg-gray-100 border border-gray-200 rounded-md p-3">
                            <div class="flex justify-between items-center">
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-600">해당 글 작성자: <%= postAuthor %></span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-600">작성일자: <%= postDate %></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Post Content -->
                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-700 mb-2">글내용</label>
                        <div class="w-full px-4 py-8 bg-gray-100 border border-gray-200 rounded-lg text-gray-900 min-h-32">
                            <%= postContent %>
                        </div>
                    </div>

                    <!-- Credibility Rating (조건부 표시) -->
                    <%
                        String showCredibility = request.getParameter("showCredibility");
                        if ("true".equals(showCredibility) || credibilityScore != null) {
                    %>
                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-900 mb-2">신뢰도 <%= String.format("%.0f", credibilityScore) %>%</label>
                        <div class="w-full bg-gray-200 rounded-full h-2">
                            <div class="bg-primary h-2 rounded-full" style="width: <%= credibilityScore %>%"></div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </form>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-center space-x-4">
            <button onclick="approvePost()" class="bg-green-600 text-white px-8 py-3 rounded-lg hover:bg-green-700 transition-colors font-medium">
                승인
            </button>
            <button onclick="rejectPost()" class="bg-red-600 text-white px-8 py-3 rounded-lg hover:bg-red-700 transition-colors font-medium">
                거절
            </button>
            <button onclick="goBack()" class="bg-gray-500 text-white px-8 py-3 rounded-lg hover:bg-gray-600 transition-colors font-medium">
                목록으로
            </button>
        </div>
    </main>

    <!-- Approval Modal -->
    <div id="approvalModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">게시글 승인</h3>
                    <p class="text-gray-600 mb-6">이 게시글을 승인하시겠습니까?</p>
                    <div class="flex justify-end space-x-3">
                        <button onclick="closeModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                        <button onclick="confirmApproval()" class="px-4 py-2 text-white bg-green-600 rounded-md hover:bg-green-700">승인</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Rejection Modal -->
    <div id="rejectionModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <form id="rejectionForm" action="processPost.jsp" method="post">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <input type="hidden" name="action" value="reject">
                    
                    <div class="p-6">
                        <h3 class="text-lg font-semibold text-gray-900 mb-4">게시글 거절</h3>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-700 mb-2">거절 사유</label>
                            <textarea name="rejectionReason" class="w-full border border-gray-200 rounded-lg p-3 h-24 resize-none focus:ring-1 focus:ring-primary focus:border-primary focus:outline-none" placeholder="거절 사유를 입력하세요" required></textarea>
                        </div>
                        
                        <div class="flex justify-end space-x-3">
                            <button type="button" onclick="closeModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                            <button type="submit" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">거절</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />

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
            history.back();
        }

        function logout() {
            if(confirm('로그아웃 하시겠습니까?')) {
                location.href = 'Login.jsp';
            }
        }

        // 모달 외부 클릭시 닫기
        window.onclick = function(event) {
            const approvalModal = document.getElementById('approvalModal');
            const rejectionModal = document.getElementById('rejectionModal');
            
            if (event.target === approvalModal) {
                closeModal();
            }
            if (event.target === rejectionModal) {
                closeModal();
            }
        }

        // ESC 키로 모달 닫기
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });
    </script>
</body>
</html>
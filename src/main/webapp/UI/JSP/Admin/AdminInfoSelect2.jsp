<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
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
<body class="bg-gray-50 min-h-screen">
    <!-- Header -->
    <jsp:include page="../Common/AdminHeader.jsp" />

    <%
        // --- Mock Post Data (DB에서 postId로 조회했다고 가정) ---
        String postId = request.getParameter("postId");
        
        Map<String, Object> post = new HashMap<>();
        post.put("title", "AI가 생성한 이미지, 진짜와 가짜 구별법");
        post.put("author", "뉴스탐험가");
        post.put("date", "2025-09-26");
        post.put("content", "최근 AI 기술의 발전으로 진짜 같은 가짜 이미지를 쉽게 만들 수 있게 되었습니다. 이 글에서는 AI 생성 이미지의 특징과 구별법에 대해 심도 있게 알아보고자 합니다...");
        post.put("credibility", 65.0);
    %>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판 관리</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <!-- Post Review Content -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Post Title -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-2">제목</label>
                    <div class="w-full px-4 py-3 bg-gray-100 border border-gray-200 rounded-lg text-gray-900">
                        <%= post.get("title") %>
                    </div>
                </div>

                <!-- Author and Date Info -->
                <div class="mb-6">
                    <div class="bg-gray-100 border border-gray-200 rounded-md p-3">
                        <div class="flex justify-between items-center text-sm text-gray-600">
                            <span><strong>작성자:</strong> <%= post.get("author") %></span>
                            <span><strong>작성일:</strong> <%= post.get("date") %></span>
                        </div>
                    </div>
                </div>

                <!-- Post Content -->
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-2">내용</label>
                    <div class="w-full px-4 py-8 bg-gray-100 border border-gray-200 rounded-lg text-gray-800 min-h-[200px]">
                        <%= post.get("content") %>
                    </div>
                </div>

                <!-- Credibility Rating -->
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-900 mb-2">신뢰도 <%= String.format("%.0f", (Double)post.get("credibility")) %>%</label>
                    <div class="w-full bg-gray-200 rounded-full h-2.5">
                        <div class="bg-primary h-2.5 rounded-full" style="width: <%= post.get("credibility") %>%"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-center space-x-4">
            <button onclick="handleAction('approve')" class="bg-primary text-white px-8 py-3 rounded-lg hover:bg-primary-dark transition-colors font-medium">
                승인
            </button>
            <button onclick="handleAction('reject')" class="bg-red-600 text-white px-8 py-3 rounded-lg hover:bg-red-700 transition-colors font-medium">
                거절
            </button>
            <button onclick="window.history.back()" class="bg-gray-500 text-white px-8 py-3 rounded-lg hover:bg-gray-600 transition-colors font-medium">
                목록
            </button>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />

    <script>
        function handleAction(action) {
            if (action === 'approve') {
                alert('게시글이 승인되었습니다.');
                // 서버로 승인 요청 로직 추가
            } else if (action === 'reject') {
                if (confirm('게시글을 거절하시겠습니까?')) {
                    alert('게시글이 거절되었습니다.');
                    // 서버로 거절 요청 로직 추가
                }
            }
            // 목록 페이지로 이동
            window.location.href = 'AdminInfoBoard.jsp';
        }
    </script>
</body>
</html>

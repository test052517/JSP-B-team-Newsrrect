<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 보기 - 정보 검증 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="../CSS/fonts.css">
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
    <!-- Header -->
    <jsp:include page="../Common/AdminHeader.jsp" />

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <%
            // --- 게시글 데이터 (데이터베이스에서 가져왔다고 가정) ---
            String postId = request.getParameter("postId");
            // 실제로는 postId를 사용하여 DB에서 데이터를 조회해야 합니다.
            // 아래는 예시 데이터입니다.
            String postTitle = "AI가 생성한 이미지, 진짜와 가짜 구별법";
            String postAuthor = "뉴스탐험가";
            String postContent = "최근 AI 기술의 발전으로 진짜 같은 가짜 이미지를 쉽게 만들 수 있게 되었습니다. 이 글에서는 AI 생성 이미지의 특징과 구별법에 대해 심도 있게 알아보고자 합니다. 첫째, 손가락이나 치아 등 신체 일부의 어색함을 확인하세요. AI는 아직 복잡한 신체 구조를 완벽하게 구현하는 데 어려움을 겪습니다...";
            String postDate = "2025-09-26";
            int viewCount = 17441;
            int commentCount = 6;
            double credibilityScore = 65.0;

            // --- 댓글 데이터 (데이터베이스에서 가져왔다고 가정) ---
            List<Map<String, Object>> comments = new ArrayList<>();
            Map<String, Object> comment1 = new HashMap<>();
            comment1.put("id", 1);
            comment1.put("author", "팩트체커");
            comment1.put("content", "확실한 정보를 가져왔어요! 이 논문을 참고하시면 도움이 될 겁니다.");
            comment1.put("date", "2025-09-26");
            comment1.put("recommendations", 123);
            comment1.put("type", "참");
            comment1.put("isBest", true);
            comment1.put("isReply", false);
            comments.add(comment1);

            Map<String, Object> comment2 = new HashMap<>();
            comment2.put("id", 2);
            comment2.put("author", "지나가던행인");
            comment2.put("content", "좋은 정보네요~");
            comment2.put("date", "2025-09-26");
            comment2.put("recommendations", 45);
            comment2.put("type", "");
            comment2.put("isBest", false);
            comment2.put("isReply", true); // 답글
            comments.add(comment2);
            
            Map<String, Object> comment3 = new HashMap<>();
            comment3.put("id", 3);
            comment3.put("author", "반박전문");
            comment3.put("content", "이 정보는 거짓입니다! 증거 자료 제출합니다.");
            comment3.put("date", "2025-09-25");
            comment3.put("recommendations", 100);
            comment3.put("type", "거짓");
            comment3.put("isBest", true);
            comment3.put("isReply", false);
            comments.add(comment3);
        %>

        <!-- Post Content -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Post Title -->
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900"><%= postTitle %></h1>
                </div>

                <!-- Post Metadata -->
                <div class="mb-6">
                    <div class="bg-gray-50 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <span>작성자: <strong><%= postAuthor %></strong></span>
                                <span>조회수: <%= viewCount %></span>
                                <span>댓글: <%= commentCount %></span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span><%= postDate %></span>
                                <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Post Body -->
                <div class="mb-6 min-h-[150px]">
                    <div class="text-gray-800 leading-relaxed"><%= postContent %></div>
                </div>

                <!-- Credibility Rating -->
                <div class="mb-6">
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-900 mb-2">신뢰도 <%= String.format("%.0f", credibilityScore) %>%</label>
                        <div class="w-full bg-gray-200 rounded-full h-2.5">
                            <div class="bg-primary h-2.5 rounded-full" style="width: <%= credibilityScore %>%"></div>
                        </div>
                    </div>
                    
                    <div class="flex justify-center space-x-8">
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-green-100 text-green-800 rounded-full shadow">
                            <span class="text-lg font-medium">참</span>
                            <span class="text-2xl font-bold">23</span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-red-100 text-red-800 rounded-full shadow">
                            <span class="text-lg font-medium">거짓</span>
                            <span class="text-2xl font-bold">10</span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-yellow-100 text-yellow-800 rounded-full shadow">
                            <span class="text-lg font-medium">모호</span>
                            <span class="text-2xl font-bold">7</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Comment Section -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <!-- Comment Input -->
                <div class="mb-6">
                    <div class="mb-4 flex items-center gap-4">
                        <select class="w-32 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary">
                            <option>선택</option>
                            <option>참</option>
                            <option>거짓</option>
                            <option>모호</option>
                        </select>
                        <textarea class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary resize-none" rows="1" placeholder="댓글을 입력해주세요"></textarea>
                         <button class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                            등록
                        </button>
                    </div>
                </div>

                <!-- Comment List -->
                <div class="mb-8">
                    <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                    <div class="space-y-4">
                    <% for(Map<String, Object> comment : comments) { 
                        if((Boolean)comment.get("isBest")) {
                    %>
                        <div class="border border-blue-200 rounded-lg p-4 bg-blue-50">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="font-semibold text-primary"><%= comment.get("author") %></span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500"><%= comment.get("date") %></span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                                    <% String type = (String)comment.get("type");
                                       String badgeColor = "";
                                       if("참".equals(type)) badgeColor = "bg-green-100 text-green-800";
                                       else if("거짓".equals(type)) badgeColor = "bg-red-100 text-red-800";
                                    %>
                                    <span class="px-2 py-1 <%= badgeColor %> rounded text-sm"><%= type %></span>
                                </div>
                            </div>
                            <p class="text-gray-900 mb-3"><%= comment.get("content") %></p>
                            <div class="flex items-center space-x-4 text-sm">
                                <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                    <span>👍 추천 <%= comment.get("recommendations") %></span>
                                </button>
                                <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                            </div>
                        </div>
                    <% }} %>
                    </div>
                </div>
                
                <!-- Regular Comments -->
                <div>
                     <h4 class="text-lg font-semibold text-gray-900 mb-4">전체 댓글 <%= comments.size() %>개</h4>
                    <div class="space-y-4">
                     <% for(Map<String, Object> comment : comments) { 
                         if(!(Boolean)comment.get("isBest")) {
                             boolean isReply = (Boolean)comment.get("isReply");
                     %>
                        <div class="<%= isReply ? "ml-8" : "" %> border border-gray-200 rounded-lg p-4 bg-white">
                            <% if(isReply) { %><span class="text-gray-500">→</span><% } %>
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="font-semibold"><%= comment.get("author") %></span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500"><%= comment.get("date") %></span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                                </div>
                            </div>
                            <p class="text-gray-900 mb-3"><%= comment.get("content") %></p>
                            <div class="flex items-center space-x-4 text-sm">
                                <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                   <span>👍 추천 <%= comment.get("recommendations") %></span>
                                </button>
                                <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                            </div>
                        </div>
                    <% }} %>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="flex justify-center mt-8">
                    <nav class="flex items-center space-x-1">
                        <a href="#" class="px-3 py-2 text-gray-500 hover:bg-primary hover:text-white rounded-md">이전</a>
                        <a href="#" class="px-3 py-2 text-white bg-primary rounded-md">1</a>
                        <a href="#" class="px-3 py-2 text-gray-700 hover:bg-primary hover:text-white rounded-md">2</a>
                        <a href="#" class="px-3 py-2 text-gray-700 hover:bg-primary hover:text-white rounded-md">3</a>
                        <a href="#" class="px-3 py-2 text-gray-500 hover:bg-primary hover:text-white rounded-md">다음</a>
                    </nav>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />


    <!-- Modals -->
    <!-- Post Report Modal -->
    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md">
            <div class="p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">게시글 신고</h3>
                <p class="text-sm text-gray-600 mb-4">해당 게시글을 신고하시겠습니까?</p>
                <textarea class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary" rows="4" placeholder="신고 사유를 입력해주세요."></textarea>
                <div class="flex justify-end space-x-3 mt-4">
                    <button onclick="closeReportModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                    <button onclick="submitReport()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">신고</button>
                </div>
            </div>
        </div>
    </div>
    <!-- Comment Report Modal -->
    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
         <div class="bg-white rounded-lg shadow-xl w-full max-w-md">
            <div class="p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">댓글 신고</h3>
                <p class="text-sm text-gray-600 mb-4">해당 댓글을 신고하시겠습니까?</p>
                <textarea class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary" rows="4" placeholder="신고 사유를 입력해주세요."></textarea>
                <div class="flex justify-end space-x-3 mt-4">
                    <button onclick="closeCommentReportModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                    <button onclick="submitCommentReport()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">신고</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openReportModal() { document.getElementById('reportModal').classList.remove('hidden'); }
        function closeReportModal() { document.getElementById('reportModal').classList.add('hidden'); }
        function submitReport() {
            alert('게시글 신고가 접수되었습니다.');
            closeReportModal();
        }

        function openCommentReportModal() { document.getElementById('commentReportModal').classList.remove('hidden'); }
        function closeCommentReportModal() { document.getElementById('commentReportModal').classList.add('hidden'); }
        function submitCommentReport() {
            alert('댓글 신고가 접수되었습니다.');
            closeCommentReportModal();
        }

        // Logout function
        function logout() {
            // Add logout logic here, e.g., redirecting to a logout page or clearing session
            window.location.href = 'Login.jsp';
        }
    </script>
</body>
</html>

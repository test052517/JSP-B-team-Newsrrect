<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>유저 / 신고 관리 - Newsrrect</title>
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

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">유저 / 신고 관리</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <%
            // --- 신고 데이터 (데이터베이스에서 가져왔다고 가정) ---
            List<Map<String, String>> reportList = new ArrayList<>();
            Map<String, String> report1 = new HashMap<>();
            report1.put("id", "1");
            report1.put("board", "소통");
            report1.put("type", "댓글");
            report1.put("author", "user1");
            report1.put("reporter", "test");
            report1.put("date", "09.18");
            reportList.add(report1);

            Map<String, String> report2 = new HashMap<>();
            report2.put("id", "2");
            report2.put("board", "정보 검증");
            report2.put("type", "게시글");
            report2.put("author", "user2");
            report2.put("reporter", "test2");
            report2.put("date", "09.21");
            reportList.add(report2);
        %>

        <!-- Board Controls -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Top Controls -->
                <div class="flex justify-end items-center mb-4">
                    <div class="text-sm text-gray-600">
                        전체 <%= reportList.size() %>건 / 1 페이지
                    </div>
                </div>

                <!-- Table -->
                <div class="border border-gray-200 rounded-lg">
                    <!-- Table Header -->
                    <div class="bg-gray-100">
                        <div class="grid grid-cols-7 gap-4 py-3 px-4 text-sm font-semibold text-gray-700">
                            <div class="text-center">번호</div>
                            <div class="text-center">게시판</div>
                            <div class="text-center">구분</div>
                            <div class="text-center">작성자</div>
                            <div class="text-center">신고자</div>
                            <div class="text-center">작성일</div>
                            <div class="text-center">관리</div>
                        </div>
                    </div>

                    <!-- Table Body -->
                    <div>
                        <% for (Map<String, String> report : reportList) { %>
                        <div class="grid grid-cols-7 gap-4 py-3 px-4 text-sm border-b border-gray-100 hover:bg-gray-50 items-center">
                            <div class="text-center text-gray-900"><%= report.get("id") %></div>
                            <div class="text-center text-gray-900"><%= report.get("board") %></div>
                            <div class="text-center text-gray-900"><%= report.get("type") %></div>
                            <div class="text-center text-gray-900">
                                <a href="AdminUserWatch.jsp?user=<%= report.get("author") %>" class="text-primary hover:underline"><%= report.get("author") %></a>
                            </div>
                            <div class="text-center text-gray-900">
                                <a href="AdminUserWatch.jsp?user=<%= report.get("reporter") %>" class="text-primary hover:underline"><%= report.get("reporter") %></a>
                            </div>
                            <div class="text-center text-gray-900"><%= report.get("date") %></div>
                            <div class="text-center flex justify-center">
                                <button onclick="showDeletePopup('<%= report.get("type") %>')" class="w-7 h-7 bg-red-100 text-red-600 rounded flex items-center justify-center hover:bg-red-200 transition-colors" title="삭제">
                                    X
                                </button>
                            </div>
                        </div>
                        <% } %>
                         <%-- 데이터가 없을 경우 --%>
                        <% if (reportList.isEmpty()) { %>
                            <div class="text-center py-10 text-gray-500">신고 내역이 없습니다.</div>
                        <% } %>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="flex justify-center mt-8">
                    <nav class="flex items-center space-x-1">
                        <a href="#" class="px-3 py-2 text-gray-500 hover:bg-primary hover:text-white rounded-md">이전</a>
                        <a href="#" class="px-3 py-2 text-white bg-primary rounded-md">1</a>
                        <a href="#" class="px-3 py-2 text-gray-700 hover:bg-primary hover:text-white rounded-md">2</a>
                        <a href="#" class="px-3 py-2 text-gray-500 hover:bg-primary hover:text-white rounded-md">다음</a>
                    </nav>
                </div>
            </div>
        </div>
    </main>

    <!-- Modals (댓글/게시글 삭제) -->
    <div id="deleteModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div class="p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4" id="deleteModalTitle"></h3>
                <p class="text-sm text-gray-600 mb-4">해당 콘텐츠를 정말로 삭제하시겠습니까? 삭제 사유를 입력해주세요.</p>
                <textarea id="deleteReason" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary" rows="4" placeholder="삭제 사유"></textarea>
                <div class="flex justify-end space-x-3 mt-4">
                    <button onclick="closeDeleteModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                    <button onclick="confirmDelete()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">삭제</button>
                </div>
            </div>
        </div>
    </div>


    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />

    <script>
        let currentDeleteType = '';

        function showDeletePopup(type) {
            currentDeleteType = type;
            document.getElementById('deleteModalTitle').innerText = type + ' 삭제';
            document.getElementById('deleteModal').classList.remove('hidden');
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.add('hidden');
            document.getElementById('deleteReason').value = '';
        }
        
        function confirmDelete() {
            const deleteReason = document.getElementById('deleteReason').value;
            if (!deleteReason.trim()) {
                alert('삭제 사유를 입력해주세요.');
                return;
            }
            // 실제 삭제 로직 (e.g., 서버로 요청 전송)
            console.log(currentDeleteType + ' 삭제 완료. 사유: ' + deleteReason);
            alert('삭제가 완료되었습니다.');
            closeDeleteModal();
        }

        function logout() {
            window.location.href = 'Login.jsp';
        }

        // ESC 키 또는 모달 외부 클릭 시 닫기
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') closeDeleteModal();
        });
        document.getElementById('deleteModal').addEventListener('click', (event) => {
            if (event.target.id === 'deleteModal') closeDeleteModal();
        });
    </script>
</body>
</html>

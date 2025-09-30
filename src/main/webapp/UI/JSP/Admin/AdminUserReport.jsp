<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, mgr.DBConnectionMgr" %>
<%
    List<Map<String, String>> reportList = new ArrayList<>();
    DBConnectionMgr pool = DBConnectionMgr.getInstance();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    int totalRecord = 0;
    int pageSize = 10;
    int totalPage = 0;
    int nowPage = 1;

    if (request.getParameter("nowPage") != null) {
        nowPage = Integer.parseInt(request.getParameter("nowPage"));
    }
    int start = (nowPage * pageSize) - pageSize;

    try {
        conn = pool.getConnection("user");

        String countSql = "SELECT SUM(cnt) FROM ((SELECT COUNT(*) AS cnt FROM post_report) UNION ALL (SELECT COUNT(*) AS cnt FROM comment_report)) AS total";
        pstmt = conn.prepareStatement(countSql);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalRecord = rs.getInt(1);
        }
        totalPage = (int) Math.ceil((double) totalRecord / pageSize);
        pstmt.close();
        rs.close();

        // DB 스키마에 맞춰 'p.type'을 'board'로 가져오고, 날짜는 제거, 정렬은 id DESC로 수정
        String sql = "(SELECT pr.reportPost_id AS id, '게시글' AS type, p.type AS board, author.nickname AS author, reporter.nickname AS reporter " +
                     "FROM post_report pr " +
                     "JOIN post p ON pr.post_id = p.post_id " +
                     "JOIN user author ON p.user_id = author.user_id " +
                     "JOIN user reporter ON pr.reporter_id = reporter.user_id) " +
                     "UNION ALL " +
                     "(SELECT cr.reportComment_id AS id, '댓글' AS type, p.type AS board, author.nickname AS author, reporter.nickname AS reporter " +
                     "FROM comment_report cr " +
                     "JOIN comment c ON cr.comment_id = c.comment_id " +
                     "JOIN post p ON c.post_id = p.post_id " +
                     "JOIN user author ON c.user_id = author.user_id " +
                     "JOIN user reporter ON cr.reporter_id = reporter.user_id) " +
                     "ORDER BY id DESC LIMIT ?, ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, start);
        pstmt.setInt(2, pageSize);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, String> report = new HashMap<>();
            report.put("id", rs.getString("id"));
            report.put("type", rs.getString("type"));
            report.put("board", rs.getString("board")); // 'board' (p.type) 정보 추가
            report.put("author", rs.getString("author"));
            report.put("reporter", rs.getString("reporter"));
            reportList.add(report);
        }
    } catch (Exception e) {
        out.println("<div style='color:red; font-weight:bold; margin:20px;'>");
        out.println("데이터베이스 처리 중 오류가 발생했습니다.<br>");
        out.println("오류 메시지: " + e.getMessage());
        out.println("</div>");
        e.printStackTrace();
    } finally {
        pool.freeConnection(conn, pstmt, rs);
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>유저 / 신고 관리 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="../CSS/fonts.css">
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
<body class="bg-gray-50 min-h-screen">
    <jsp:include page="../Common/AdminHeader.jsp" />
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">유저 / 신고 관리</h2>
            <div class="border-t-2 border-primary"></div>
        </div>
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="flex justify-end items-center mb-4">
                    <div class="text-sm text-gray-600">전체 <%= totalRecord %>건 / <%= nowPage %> 페이지</div>
                </div>
                <div class="border border-gray-200 rounded-lg">
                    <div class="bg-gray-100">
                        <div class="grid grid-cols-6 gap-4 py-3 px-4 text-sm font-semibold text-gray-700">
                            <div class="text-center">번호</div>
                            <div class="text-center">게시판</div>
                            <div class="text-center">구분</div>
                            <div class="text-center">작성자</div>
                            <div class="text-center">신고자</div>
                            <div class="text-center">관리</div>
                        </div>
                    </div>
                    <div>
                        <% for (Map<String, String> report : reportList) { %>
                        <div class="grid grid-cols-6 gap-4 py-3 px-4 text-sm border-b border-gray-100 hover:bg-gray-50 items-center">
                            <div class="text-center text-gray-900"><%= report.get("id") %></div>
                            <div class="text-center text-gray-900"><%= report.get("board") %></div>
                            <div class="text-center text-gray-900"><%= report.get("type") %></div>
                            <div class="text-center text-gray-900"><a href="AdminUserWatch.jsp?user=<%= report.get("author") %>" class="text-primary hover:underline"><%= report.get("author") %></a></div>
                            <div class="text-center text-gray-900"><a href="AdminUserWatch.jsp?user=<%= report.get("reporter") %>" class="text-primary hover:underline"><%= report.get("reporter") %></a></div>
                            <div class="text-center flex justify-center">
                                <button onclick="showDeletePopup('<%= report.get("type") %>', '<%= report.get("id") %>')" class="w-7 h-7 bg-red-100 text-red-600 rounded flex items-center justify-center hover:bg-red-200 transition-colors" title="삭제">X</button>
                            </div>
                        </div>
                        <% } %>
                        <% if (reportList.isEmpty()) { %>
                            <div class="text-center py-10 text-gray-500">신고 내역이 없습니다.</div>
                        <% } %>
                    </div>
                </div>
                <div class="flex justify-center mt-8">
                    <nav class="flex items-center space-x-1">
                        <% if (nowPage > 1) { %><a href="AdminUserReport.jsp?nowPage=<%= nowPage - 1 %>" class="px-3 py-2 text-gray-500 hover:bg-primary hover:text-white rounded-md">이전</a><% } %>
                        <% for (int i = 1; i <= totalPage; i++) { %>
                            <% if (i == nowPage) { %><a href="#" class="px-3 py-2 text-white bg-primary rounded-md"><%= i %></a><% } else { %><a href="AdminUserReport.jsp?nowPage=<%= i %>" class="px-3 py-2 text-gray-700 hover:bg-primary hover:text-white rounded-md"><%= i %></a><% } %>
                        <% } %>
                        <% if (nowPage < totalPage) { %><a href="AdminUserReport.jsp?nowPage=<%= nowPage + 1 %>" class="px-3 py-2 text-gray-500 hover:bg-primary hover:text-white rounded-md">다음</a><% } %>
                    </nav>
                </div>
            </div>
        </div>
    </main>
    <div id="deleteModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
            <form id="deleteForm" action="AdminDeleteReportProc.jsp" method="post">
                <input type="hidden" id="deleteType" name="type">
                <input type="hidden" id="deleteId" name="id">
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4" id="deleteModalTitle"></h3>
                    <p class="text-sm text-gray-600 mb-4">해당 콘텐츠를 정말로 삭제하시겠습니까? 삭제 사유를 입력해주세요.</p>
                    <textarea id="deleteReason" name="reason" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary" rows="4" placeholder="삭제 사유"></textarea>
                    <div class="flex justify-end space-x-3 mt-4">
                        <button type="button" onclick="closeDeleteModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                        <button type="button" onclick="confirmDelete()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">삭제</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
    <jsp:include page="../Common/Footer.jsp" />
    <script>
        function showDeletePopup(type, id) {
            document.getElementById('deleteModalTitle').innerText = type + ' 삭제';
            document.getElementById('deleteType').value = type;
            document.getElementById('deleteId').value = id;
            document.getElementById('deleteModal').classList.remove('hidden');
        }
        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.add('hidden');
            document.getElementById('deleteReason').value = '';
            document.getElementById('deleteType').value = '';
            document.getElementById('deleteId').value = '';
        }
        function confirmDelete() {
            const deleteReason = document.getElementById('deleteReason').value;
            if (!deleteReason.trim()) {
                alert('삭제 사유를 입력해주세요.');
                return;
            }
            document.getElementById('deleteForm').submit();
        }
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') closeDeleteModal();
        });
        document.getElementById('deleteModal').addEventListener('click', (event) => {
            if (event.target.id === 'deleteModal') closeDeleteModal();
        });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.PostBean" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");
    String result = "failed";
    String errorMessage = "";
    String redirectUrl = ""; 

    // --- 1. 로그인 세션 검증 ---
    Integer sessionUserId = (Integer) session.getAttribute("userId");
    if (sessionUserId == null) {
        errorMessage = "로그인이 필요합니다. 로그인 페이지로 이동합니다.";
        redirectUrl = request.getContextPath() + "/UI/JSP/Login/Login.jsp";
    } else {
        try {
            String saveDirectory = application.getRealPath("/upload");
            File uploadDir = new File(saveDirectory);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            int maxPostSize = 10 * 1024 * 1024; // 10MB
            String encoding = "UTF-8";

            MultipartRequest multi = new MultipartRequest(
                request,
                saveDirectory,
                maxPostSize,
                encoding,
                new DefaultFileRenamePolicy()
            );

            String title = multi.getParameter("title");
            String content = multi.getParameter("ir1");
            String boardType = multi.getParameter("board");
            
            // --- 2. 입력값 유효성 검사 ---
            if (title == null || title.trim().isEmpty()) {
                errorMessage = "제목을 입력해주세요.";
            } else if (content == null || content.trim().isEmpty() || content.equals("<p>&nbsp;</p>")) {
                errorMessage = "내용을 입력해주세요.";
            } else {
                
                // --- 수정된 부분: PostBean 객체를 생성하고 값을 설정 ---
                PostBean postBean = new PostBean();
                
                String type = "commu".equals(boardType) ? "소통" : "정보";
                String status = "정보".equals(type) ? "비공개" : "공개";
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String createdAt = sdf.format(new Date());

                postBean.setUserId(sessionUserId);
                postBean.setType(type);
                postBean.setTitle(title);
                postBean.setContent(content);
                postBean.setStatus(status);
                postBean.setViewCount(0);
                postBean.setCreatedAt(createdAt);
                postBean.setReportCount(0);
                postBean.setRecommandCount(0);
                postBean.setPriority(0); // 기본 priority 설정

                PostMgr postMgr = new PostMgr();
                postMgr.createPost(postBean); // 수정된 메소드 호출 방식
                
                // PostMgr의 createPost 메소드가 void이므로, 예외가 발생하지 않으면 성공으로 간주
                result = "success";
                
                // --- 3. 게시판 타입에 따른 동적 리다이렉션 ---
                if ("정보".equals(type)) {
                    redirectUrl = "AdminInfo.jsp";
                } else {
                    redirectUrl = "AdminCommu.jsp"; 
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "게시글 처리 중 오류가 발생했습니다: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>처리 중...</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { 'primary': '#5d74f8', 'primary-dark': '#4c63e7' }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
    <div class="bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full mx-4">
        <% if("success".equals(result)) { %>
        <div class="flex items-center justify-center w-16 h-16 mx-auto bg-green-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>
        <h2 class="text-2xl font-bold text-gray-900 text-center mb-2">작성 완료</h2>
        <p class="text-gray-600 text-center mb-6">게시글이 성공적으로 작성되었습니다.</p>
        <% } else { %>
        <div class="flex items-center justify-center w-16 h-16 mx-auto bg-red-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
        </div>
        <h2 class="text-2xl font-bold text-gray-900 text-center mb-2">작성 실패</h2>
        <p class="text-gray-600 text-center mb-6">게시글 작성에 실패했습니다.<br><%= errorMessage %></p>
        <% } %>
        
        <div class="text-center text-sm text-gray-500 mb-4">잠시 후 자동으로 이동합니다...</div>
    </div>

    <script>
        const result = "<%= result %>";
        const redirectUrl = "<%= redirectUrl %>";
        
        setTimeout(function() {
            if (result === "success") {
                location.href = redirectUrl;
            } else {
                if (redirectUrl) {
                    location.href = redirectUrl;
                } else {
                    history.back();
                }
            }
        }, 2000);
    </script>
</body>
</html>
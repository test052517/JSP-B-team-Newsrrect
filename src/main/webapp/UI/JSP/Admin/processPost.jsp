<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mgr.PostMgr" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 파라미터 가져오기
    String postIdStr = request.getParameter("postId");
    String action = request.getParameter("action");
    
    if(postIdStr == null || action == null) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    
    int postId = Integer.parseInt(postIdStr);
    PostMgr postMgr = new PostMgr();
    boolean result = false;
    String message = "";
    String icon = "success";
    
    if("approve".equals(action)) {
        // 승인 처리
        result = postMgr.approvePost(postId);
        if(result) {
            message = "게시글이 성공적으로 승인되었습니다.";
            icon = "success";
        } else {
            message = "게시글 승인에 실패했습니다.";
            icon = "error";
        }
    } else if("reject".equals(action)) {
        // 거절 처리
        String rejectionReason = request.getParameter("rejectionReason");
        result = postMgr.rejectPost(postId, rejectionReason);
        if(result) {
            message = "게시글이 거절되었습니다.";
            icon = "success";
        } else {
            message = "게시글 거절에 실패했습니다.";
            icon = "error";
        }
    } else {
        message = "잘못된 요청입니다.";
        icon = "error";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>처리 결과</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'primary': '#5d74f8',
                        'primary-dark': '#4c63e7'
                    }
                }
            }
        }
    </script>
    <style>
        .modal-enter {
            animation: modalEnter 0.3s ease-out;
        }
        
        @keyframes modalEnter {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
    </style>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
    <div class="modal-enter bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full mx-4">
        <% if("success".equals(icon)) { %>
        <div class="flex items-center justify-center w-16 h-16 mx-auto bg-green-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
        </div>
        <% } else { %>
        <div class="flex items-center justify-center w-16 h-16 mx-auto bg-red-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
        </div>
        <% } %>
        
        <h2 class="text-2xl font-bold text-gray-900 text-center mb-2">
            <%= "success".equals(icon) ? "처리 완료" : "처리 실패" %>
        </h2>
        <p class="text-gray-600 text-center mb-6"><%= message %></p>
        
        <div class="space-y-3">
            <button onclick="location.href='AdminInfoBoard.jsp'" 
                    class="w-full px-6 py-3 bg-primary text-white rounded-lg hover:bg-primary-dark transition-colors font-medium">
                목록으로 돌아가기
            </button>
        </div>
        
        <p class="text-sm text-gray-500 text-center mt-4">3초 후 자동으로 이동합니다...</p>
    </div>

    <script>
        // 3초 후 자동으로 목록 페이지로 이동
        setTimeout(function() {
            location.href = 'AdminInfoBoard.jsp';
        }, 3000);
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 보기 - 소통 게시판 - Newsrrect</title>
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
                    <a href="#" onclick="loadLoginContent()" class="text-primary hover:text-primary-dark text-sm font-medium">
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
                <a href="AdminCommu.jsp" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded font-paperozi-medium">소통 게시판</a>
                <a href="AdminInfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판 관리</a>
                <a href="AdminUserReport.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">유저 / 신고 관리</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <!-- Post Content -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Post Title -->
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900">${post.title}</h1>
                </div>

                <!-- Post Metadata -->
                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <span>${post.authorRole}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>${post.commentCount}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span>${post.viewCount}</span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span><fmt:formatDate value="${post.createDate}" pattern="yyyy.MM.dd"/></span>
                                <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Post Body -->
                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed">
                        <c:out value="${post.content}" escapeXml="false"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- Comment Section -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <!-- Comment Input -->
                <div class="mb-6">
                    <form action="addComment.jsp" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="postId" value="${post.id}"/>
                        
                        <!-- Comment Text Area -->
                        <div class="mb-4">
                            <textarea name="commentContent" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary resize-none" rows="4" placeholder="댓글을 입력해주세요" required></textarea>
                        </div>
                        
                        <!-- File Upload Section -->
                        <div class="mb-4">
                            <div class="flex items-center space-x-2 mb-2">
                                <input type="file" id="comment-file" name="attachmentFile" class="hidden" multiple>
                                <button type="button" onclick="document.getElementById('comment-file').click()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                                    첨부 파일
                                </button>
                                <span class="text-sm text-gray-500">파일을 선택하세요</span>
                            </div>
                            
                            <!-- Selected Files Display -->
                            <div id="selected-files" class="hidden">
                                <div class="bg-gray-50 border border-gray-200 rounded-md p-3">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center space-x-2">
                                            <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                            </svg>
                                            <span class="text-sm text-gray-700" id="file-name">선택된 파일 없음</span>
                                        </div>
                                        <button type="button" onclick="clearFiles()" class="text-red-500 hover:text-red-700 text-sm">
                                            삭제
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Submit Button -->
                        <div class="flex justify-end">
                            <button type="submit" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                                댓글등록
                            </button>
                        </div>
                    </form>
                </div>

                <!-- BEST Comments -->
                <c:if test="${not empty bestComments}">
                    <div class="mb-8 bg-blue-100 rounded-lg p-4">
                        <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                        <div class="space-y-4">
                            <c:forEach var="comment" items="${bestComments}">
                                <div class="border border-gray-200 rounded-lg p-4 bg-white">
                                    <div class="flex justify-between items-start mb-2">
                                        <div class="flex items-center space-x-2">
                                            <span class="font-semibold text-primary">BEST ${comment.author}</span>
                                            <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                            </svg>
                                        </div>
                                        <div class="flex items-center space-x-2">
                                            <span class="text-sm text-gray-500">
                                                <fmt:formatDate value="${comment.createDate}" pattern="yyyy.MM.dd"/>
                                            </span>
                                            <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${comment.id})">🚨</span>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <p class="text-gray-900"><c:out value="${comment.content}"/></p>
                                    </div>
                                    
                                    <div class="flex items-center space-x-4 text-sm">
                                        <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500" onclick="likeComment(${comment.id})">
                                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                            </svg>
                                            <span>추천 ${comment.likeCount}</span>
                                        </button>
                                        <button class="text-gray-600 hover:text-primary" onclick="showReplyForm(${comment.id})">답글쓰기</button>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- Regular Comments -->
                <div class="space-y-4">
                    <c:forEach var="comment" items="${regularComments}">
                        <div class="border border-gray-200 rounded-lg p-4 bg-white">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="font-semibold">${comment.author}</span>
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500">
                                        <fmt:formatDate value="${comment.createDate}" pattern="yyyy.MM.dd"/>
                                    </span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${comment.id})">🚨</span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <p class="text-gray-900"><c:out value="${comment.content}"/></p>
                            </div>
                            
                            <div class="flex items-center space-x-4 text-sm">
                                <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500" onclick="likeComment(${comment.id})">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>추천 ${comment.likeCount}</span>
                                </button>
                                <button class="text-gray-600 hover:text-primary" onclick="showReplyForm(${comment.id})">답글쓰기</button>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Comment Pagination -->
                <c:if test="${totalCommentPages > 1}">
                    <div class="flex justify-center items-center mt-6 space-x-2">
                        <div class="flex space-x-1">
                            <c:forEach var="i" begin="1" end="${totalCommentPages}">
                                <c:choose>
                                    <c:when test="${i == currentCommentPage}">
                                        <button class="px-3 py-2 text-sm font-medium text-white bg-primary border border-gray-200 rounded">[${i}]</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button onclick="location.href='AdminCommuWatch.jsp?postId=${post.id}&commentPage=${i}'" class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[${i}]</button>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                        <c:if test="${currentCommentPage < totalCommentPages}">
                            <button onclick="location.href='AdminCommuWatch.jsp?postId=${post.id}&commentPage=${currentCommentPage + 1}'" class="ml-4 px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                </svg>
                            </button>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>
    </main>

    <!-- Report Modal -->
    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-md">
                <!-- Modal Header -->
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">신고하기</h3>
                    <div class="border-b border-gray-200 mb-4"></div>
                </div>
                
                <!-- Modal Content -->
                <form action="reportPost.jsp" method="post">
                    <input type="hidden" name="postId" value="${post.id}"/>
                    <div class="p-6">
                        <p class="text-gray-900 mb-4">해당 게시글을 아래와 같은 사유로 신고합니다.</p>
                        
                        <!-- Post Information -->
                        <div class="mb-4">
                            <div class="bg-gray-100 border border-gray-200 rounded-md p-3 mb-2">
                                <div class="flex justify-between">
                                    <span class="text-gray-900">${post.title}</span>
                                    <span class="text-gray-900">${post.author}</span>
                                </div>
                            </div>
                            <div class="bg-gray-100 border border-gray-200 rounded-md p-3">
                                <span class="text-gray-900">${post.content}</span>
                            </div>
                        </div>
                        
                        <!-- Report Reason -->
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-900 mb-2">신고사유</label>
                            <textarea name="reportReason" class="w-full border border-gray-200 rounded-md p-3 h-20" placeholder="신고 사유를 입력하세요" required></textarea>
                        </div>
                        
                        <!-- Action Buttons -->
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

    <!-- Comment Report Modal -->
    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <form action="reportComment.jsp" method="post">
                    <input type="hidden" name="commentId" id="reportCommentId"/>
                    <div class="p-6">
                        <h3 class="text-lg font-semibold text-gray-900 mb-2">신고하기</h3>
                        <div class="border-b border-gray-200 mb-4"></div>
                        <p class="text-sm text-gray-600 mb-4">해당 댓글을 아래와 같은 사유로 신고합니다.</p>
                        
                        <div class="mb-6">
                            <label class="block text-sm font-medium text-gray-700 mb-2">신고사유</label>
                            <textarea name="reportReason" class="w-full border border-gray-200 rounded-lg p-3 h-20" placeholder="신고 사유를 입력하세요" required></textarea>
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

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />

    <script>
        // File selection functionality
        document.getElementById('comment-file').addEventListener('change', function(e) {
            const files = e.target.files;
            const selectedFilesDiv = document.getElementById('selected-files');
            const fileNameSpan = document.getElementById('file-name');
            
            if (files.length > 0) {
                selectedFilesDiv.classList.remove('hidden');
                if (files.length === 1) {
                    fileNameSpan.textContent = files[0].name;
                } else {
                    fileNameSpan.textContent = `${files.length}개 파일 선택됨`;
                }
            } else {
                selectedFilesDiv.classList.add('hidden');
            }
        });

        // Clear files function
        function clearFiles() {
            document.getElementById('comment-file').value = '';
            document.getElementById('selected-files').classList.add('hidden');
            document.getElementById('file-name').textContent = '선택된 파일 없음';
        }

        // Report modal functions
        function openReportModal() {
            document.getElementById('reportModal').classList.remove('hidden');
        }

        function closeReportModal() {
            document.getElementById('reportModal').classList.add('hidden');
        }

        // Comment Report Modal Functions
        function openCommentReportModal(commentId) {
            document.getElementById('reportCommentId').value = commentId;
            document.getElementById('commentReportModal').classList.remove('hidden');
        }

        function closeCommentReportModal() {
            document.getElementById('commentReportModal').classList.add('hidden');
        }

        // Like comment function
        function likeComment(commentId) {
            fetch('likeComment.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'commentId=' + commentId
            })
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    location.reload();
                }
            })
            .catch(error => console.error('Error:', error));
        }

        // Show reply form
        function showReplyForm(commentId) {
            // Reply form implementation
            console.log('Show reply form for comment:', commentId);
        }

        // Close modal when clicking outside
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

        function loadLoginContent() {
            location.href = 'Login.jsp';
        }
    </script>
</body>
</html>
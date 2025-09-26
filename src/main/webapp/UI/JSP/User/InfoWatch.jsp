<%-- JSTL Core 라이브러리 선언 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 🚩 핵심 수정: 이 파일 내의 ${...} 구문을 서버의 EL로 해석하지 않도록 설정 --%>
<%@ page isELIgnored="true" %> 
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%-- 게시글 제목을 동적으로 표시 --%>
    <title>${post.title} - 정보 검증 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
<<<<<<< HEAD
    <link rel="stylesheet" href="<c:url value='/CSS/fonts.css'/>">
    
=======
	
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/styles.css">

>>>>>>> 5caaaced9bef18ac2f7504d2fd21dca36e768360
    <script>
        // tailwind config (기존과 동일)
    </script>
</head>
<body class="bg-white min-h-screen">
<<<<<<< HEAD
    <%-- Header와 Nav는 Common/Header.jsp로 통합하여 관리하는 것을 권장 --%>
    <jsp:include page="../Common/Header.jsp" />
=======
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <div class="flex-shrink-0">
                    <%-- 🚩 MainPage.html 경로 수정: 현재 JSP 위치에서 ../../Html/로 수정합니다. --%>
                    <a href="../../Html/MainPage.html"><h1 class="text-2xl font-bold text-primary" style="font-family: 'Aggravo', sans-serif;">Newsrrect</h1></a>
                </div>
                
                <div class="absolute right-0 flex items-center space-x-4">
                    <button class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그아웃
                    </button>
                </div>
            </div>
        </div>
    </header>
    
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-20 py-4">
                <a href="InfoBoard.jsp" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded font-paperozi-medium">정보 검증 게시판</a>
                <a href="CommuBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="MyPage.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">마이 페이지</a>
            </div>
        </div>
    </nav>
>>>>>>> 5caaaced9bef18ac2f7504d2fd21dca36e768360

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <%-- ==================== 게시글 상세 내용 (데이터 동적 출력) ==================== --%>
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="mb-4">
                    <%-- JSTL Expression Language(EL)로 데이터 출력 --%>
                    <h1 class="text-2xl font-bold text-gray-900">${post.title}</h1>
                </div>

                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <span>${post.author}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <%-- SVG 아이콘 --%>
                                    <span>${post.commentCount}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <%-- SVG 아이콘 --%>
                                    <span>${post.viewCount}</span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span>${post.creationDate}</span>
                                <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed">
                        <%-- HTML 태그가 포함될 수 있으므로 unescapeXml=false 처리 또는 별도 라이브러리 사용 권장 --%>
                        <p>${post.content}</p>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-900 mb-2">신뢰도 ${post.reliability}%</label>
                        <div class="w-full bg-gray-200 rounded-full h-2">
                            <div class="bg-primary h-2 rounded-full" style="width: ${post.reliability}%"></div>
                        </div>
                    </div>
                    
                    <div class="flex justify-center space-x-8">
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-green-100 text-green-800 rounded-full">
                            <span class="text-lg font-medium">참</span>
                            <span class="text-2xl font-bold">${post.trueCount}</span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-red-100 text-red-800 rounded-full">
                            <span class="text-lg font-medium">거짓</span>
                            <span class="text-2xl font-bold">${post.falseCount}</span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-yellow-100 text-yellow-800 rounded-full">
                            <span class="text-lg font-medium">모호</span>
                            <span class="text-2xl font-bold">${post.ambiguousCount}</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ==================== 댓글 작성 및 목록 ==================== --%>
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 ${commentList.size()}개</h3>
                    </div>
                
                <%-- BEST 댓글 --%>
                <%-- ... (BEST 댓글도 c:forEach로 반복 처리 가능) ... --%>

                <%-- ==================== 일반 댓글 목록 (c:forEach로 동적 생성) ==================== --%>
                <div class="space-y-4">
                    <%-- 서블릿에서 전달한 댓글 목록(commentList)을 반복 --%>
                    <c:forEach var="comment" items="${commentList}">
                        <%-- 각 댓글의 정보를 동적으로 출력. comment.id 와 같이 객체의 필드에 접근 --%>
                        <div class="border border-gray-200 rounded-lg p-4 bg-white" data-comment-id="${comment.id}">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="font-semibold">${comment.author}</span>
                                    <%-- SVG 아이콘 --%>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500">${comment.creationDate}</span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${comment.id})">🚨</span>
                                    <%-- 평가(참/거짓/모호)에 따라 동적으로 클래스 변경 --%>
                                    <span class="px-2 py-1 ${comment.voteClass} rounded text-sm">${comment.voteType}</span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <p class="text-gray-900 mb-2">${comment.content}</p>
                                </div>
                            
                            <div class="flex items-center space-x-4 text-sm">
                                <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                    <%-- SVG 아이콘 --%>
                                    <span>추천 ${comment.likes}</span>
                                </button>
                                <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                                <%-- id를 동적으로 생성 --%>
                                <input type="file" id="file-comment-${comment.id}" class="hidden comment-file-input" multiple>
                                <button onclick="document.getElementById('file-comment-${comment.id}').click()" class="text-gray-600 hover:text-primary">첨부파일</button>
                            </div>
                            
                            <%-- 선택된 파일 표시 영역. id를 동적으로 생성 --%>
                            <div id="selected-files-comment-${comment.id}" class="hidden mt-3 p-3 bg-gray-50 rounded-md">
                                <div class="bg-white border border-gray-200 rounded-md p-2">
                                    <div id="file-list-comment-${comment.id}" class="space-y-1"></div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />
    
    <script>
    // ... (모달 관련 함수는 기존과 거의 동일) ...

    document.addEventListener('DOMContentLoaded', function() {
        // 클래스로 모든 댓글의 파일 입력 요소를 찾음
        const fileInputs = document.querySelectorAll('.comment-file-input');
        
        // 각 파일 입력 요소에 대해 이벤트 리스너를 설정
        fileInputs.forEach(fileInput => {
            // data- 속성에서 댓글 ID를 가져옴
            const commentId = fileInput.id.split('-').pop();
            
            fileInput.addEventListener('change', function(e) {
                const files = e.target.files;
                const selectedFilesDiv = document.getElementById(`selected-files-comment-${commentId}`);
                const fileListDiv = document.getElementById(`file-list-comment-${commentId}`);
                
                if (files.length > 0) {
                    selectedFilesDiv.classList.remove('hidden');
<<<<<<< HEAD
                    fileListDiv.innerHTML = ''; // 목록 초기화

                    Array.from(files).forEach(file => {
                        const fileItemHTML = `
                            <div class="flex items-center justify-between p-1">
=======
                    fileList.innerHTML = '';
                    
                    // 파일 수 표시 업데이트
                    if (fileCountSpan) {
                        fileCountSpan.textContent = files.length;
                        fileCountSpan.classList.remove('hidden');
                    }
                    
                    // 모든 댓글에서 이미지 파일만 댓글 내용에 표시
                    if (attachedFilesDiv) {
                        const imageFiles = Array.from(files).filter(file => file.type.startsWith('image/'));
                        if (imageFiles.length > 0) {
                            attachedFilesDiv.classList.remove('hidden');
                            // 이미지 미리보기 생성
                            const reader = new FileReader();
                            reader.onload = function(e) {
                                attachedFilesDiv.innerHTML = `
                                    <img src="${e.target.result}" alt="${imageFiles[0].name}" class="max-w-full h-auto rounded-lg border border-gray-200" style="max-height: 200px;">
                                `;
                            };
                            reader.readAsDataURL(imageFiles[0]);
                        } else {
                            attachedFilesDiv.classList.add('hidden');
                        }
                    }
                    
                    Array.from(files).forEach((file, index) => {
                        const fileItem = document.createElement('div');
                        fileItem.className = 'flex items-center p-2 bg-white rounded border';
                        // 🚩 EL 오류가 났던 ${...} 코드가 JavaScript 문자열 템플릿 리터럴로 정상 동작합니다.
                        fileItem.innerHTML = `
                            <div class="flex items-center space-x-2">
                                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                </svg>
>>>>>>> 5caaaced9bef18ac2f7504d2fd21dca36e768360
                                <span class="text-sm text-gray-700">${file.name}</span>
                                <span class="text-xs text-gray-500">${(file.size / 1024).toFixed(1)}KB</span>
                            </div>`;
                        fileListDiv.innerHTML += fileItemHTML;
                    });
                } else {
                    selectedFilesDiv.classList.add('hidden');
                }
            });
        });
    });
    </script>
</body>
</html>
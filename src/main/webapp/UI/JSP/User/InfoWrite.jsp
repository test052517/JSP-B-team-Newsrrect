	<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
	<%
		// 세션에서 User 정보 가져옴
		beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
%>
	<!DOCTYPE html>
	<html lang="ko">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>글 작성 - 정보 검증 게시판 - Newsrrect</title>
	    <script src="https://cdn.tailwindcss.com"></script>
	
	    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
	
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
	<body class="bg-white min-h-screen">
	        <!-- Header -->
	        <%//System.out.println("현재 로그인 한 유저: "+user.getRole()); %>
	    <%try{ %>
    	<%if(user.getRole().equals("관리자")){%>
        <jsp:include page="../Common/AdminHeader.jsp" />
    	<%}else{ %>
    	<jsp:include page ="../Common/Header.jsp"/>
    	<%}
	    }catch(Exception e){%>
        <script>
            alert('로그인이 필요한 서비스 입니다.');
            location.href = '../Login.jsp'; // JavaScript 방식의 리다이렉트
        </script>
	    <%}%>
	
	    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
	        <div class="mb-6">
	            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판</h2>
	            <div class="border-t border-gray-200"></div>
	        </div>
	
	        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
	            <div class="p-6">
	                <form id="writeForm" action="${pageContext.request.contextPath}/writeInfoPost.do" method="post" enctype="multipart/form-data" class="space-y-6">
	                    <!-- 제목 입력 -->
	                    <div>
	                        <label for="title" class="block text-sm font-medium text-gray-900 mb-2">
	                            제목 <span class="text-red-500">*</span>
	                        </label>
	                        <input type="text" id="title" name="title" 
	                               class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" 
	                               placeholder="제목을 입력하세요"
	                               maxlength="100"
	                               required>
	                        <div class="text-sm text-gray-500 mt-1">
	                            <span id="titleCount">0</span>/100자
	                        </div>
	                    </div>
	
	                    <!-- 내용 입력 -->
	                    <div>
	                        <label for="content" class="block text-sm font-medium text-gray-900 mb-2">
	                            내용 <span class="text-red-500">*</span>
	                        </label>
	                        <textarea id="content" name="content" rows="15" 
	                                  class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary resize-none" 
	                                  placeholder="• 검증하고 싶은 정보를 최소 50자 이상으로 작성해주세요&#10;• 출처나 관련 링크를 기재하되 텍스트와 같이 쓰면 정확도가 낮아지니 이 점 유의해주세요&#10;• 개인정보나 민감한 정보는 포함하지 마세요&#10;• 허위 정보 유포나 악의적인 목적의 글은 삭제될 수 있습니다"
	                                  maxlength="2000"
	                                  required></textarea>
	                        <div class="text-sm text-gray-500 mt-1">
	                            <span id="contentCount">0</span>/2000자
	                        </div>
	                    </div>
	
	                    <!-- 파일 업로드 -->
	                    <div>
	                        <label class="block text-sm font-medium text-gray-900 mb-2">첨부 파일</label>
	                        <div class="flex items-center space-x-2 mb-2">
	                            <input type="file" id="attachments" name="attachments" class="hidden" multiple accept="image/*,application/pdf,.doc,.docx,.txt">
	                            <button type="button" onclick="document.getElementById('attachments').click()" 
	                                    class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
	                                파일 선택
	                            </button>
	                            <span class="text-sm text-gray-500">이미지, PDF, 문서 파일 (최대 5개, 각 10MB 이하)</span>
	                        </div>
	                        
	                        <div id="selectedFiles" class="hidden">
	                            <div class="bg-gray-50 border border-gray-200 rounded-md p-3">
	                                <div class="flex items-center justify-between mb-2">
	                                    <span class="text-sm font-medium text-gray-700">선택된 파일</span>
	                                    <button type="button" onclick="clearAllFiles()" class="text-red-500 hover:text-red-700 text-sm">
	                                        모두 삭제
	                                    </button>
	                                </div>
	                                <div id="fileList" class="space-y-2"></div>
	                            </div>
	                        </div>
	                    </div>
	
	                    <!-- 버튼 -->
	                    <div class="flex justify-end space-x-3">
	                        <button type="button" onclick="goBack()" 
	                                class="px-6 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors font-medium">
	                            취소
	                        </button>
	                        <button type="submit" id="submitBtn"
	                                class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors font-medium">
	                            작성 완료
	                        </button>
	                    </div>
	                </form>
	            </div>
	        </div>
	    </main>	
	
	    <jsp:include page="../Common/Footer.jsp" />
	
	    <script>
	        const contextPath = '<%= request.getContextPath() %>';
	        let selectedFiles = [];
	
	        // 제목 글자 수 카운트
	        const titleInput = document.getElementById('title');
	        const titleCount = document.getElementById('titleCount');
	        titleInput.addEventListener('input', function() {
	            titleCount.textContent = this.value.length;
	        });
	
	        // 내용 글자 수 카운트
	        const contentTextarea = document.getElementById('content');
	        const contentCount = document.getElementById('contentCount');
	        contentTextarea.addEventListener('input', function() {
	            contentCount.textContent = this.value.length;
	        });
	
	        // 파일 업로드 처리
	        const attachmentsInput = document.getElementById('attachments');
	        const selectedFilesDiv = document.getElementById('selectedFiles');
	        const fileListDiv = document.getElementById('fileList');
	
	        attachmentsInput.addEventListener('change', function(e) {
	            const files = Array.from(e.target.files);
	            
	            if (selectedFiles.length + files.length > 5) {
	                alert('최대 5개의 파일만 업로드할 수 있습니다.');
	                return;
	            }
	
	            files.forEach(file => {
	                if (file.size > 10 * 1024 * 1024) {
	                    alert(file.name + '은(는) 10MB를 초과합니다.');
	                    return;
	                }
	                selectedFiles.push(file);
	            });
	
	            updateFileList();
	            e.target.value = '';
	        });
	
	        function updateFileList() {
	            if (selectedFiles.length === 0) {
	                selectedFilesDiv.classList.add('hidden');
	                return;
	            }
	
	            selectedFilesDiv.classList.remove('hidden');
	            fileListDiv.innerHTML = '';
	
	            selectedFiles.forEach((file, index) => {
	                const fileItem = document.createElement('div');
	                fileItem.className = 'flex items-center justify-between p-2 bg-white rounded border';
	                
	                const fileSizeMB = (file.size / 1024 / 1024).toFixed(2);
	                fileItem.innerHTML = 
	                    '<div class="flex items-center space-x-2">' +
	                        '<svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
	                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>' +
	                        '</svg>' +
	                        '<span class="text-sm text-gray-700">' + file.name + '</span>' +
	                        '<span class="text-xs text-gray-500">(' + fileSizeMB + 'MB)</span>' +
	                    '</div>' +
	                    '<button type="button" onclick="removeFile(' + index + ')" class="text-red-500 hover:text-red-700">' +
	                        '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">' +
	                            '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>' +
	                        '</svg>' +
	                    '</button>';
	                
	                fileListDiv.appendChild(fileItem);
	            });
	        }
	
	        function removeFile(index) {
	            selectedFiles.splice(index, 1);
	            updateFileList();
	        }
	
	        function clearAllFiles() {
	            selectedFiles = [];
	            updateFileList();
	        }
	
	        // 폼 제출 처리
	        document.getElementById('writeForm').addEventListener('submit', function(e) {
	            e.preventDefault();
	            
	            const title = titleInput.value.trim();
	            const content = contentTextarea.value.trim();
	            
	            if (!title) {
	                alert('제목을 입력해주세요.');
	                titleInput.focus();
	                return;
	            }
	            
	            if (!content) {
	                alert('내용을 입력해주세요.');
	                contentTextarea.focus();
	                return;
	            }
	
	            // 로딩 상태
	            const submitBtn = document.getElementById('submitBtn');
	            submitBtn.disabled = true;
	            submitBtn.textContent = '작성 중...';
	
	            // FormData 생성
	            const formData = new FormData(this);
	            
	            // 선택된 파일들 추가
	            selectedFiles.forEach(file => {
	                formData.append('files', file);
	            });
	
	            // 서버로 전송
	            fetch(this.action, {
	                method: 'POST',
	                body: formData
	            })
	            .then(response => response.json())
	            .then(data => {
	                if (data.success) {
	                    alert('게시글이 성공적으로 작성되었습니다.');
	                    location.href = contextPath + '/info/watch.do';
	                } else {
	                    alert(data.message || '게시글 작성에 실패했습니다.');
	                    submitBtn.disabled = false;
	                    submitBtn.textContent = '작성 완료';
	                }
	            })
	            .catch(error => {
	                console.error('Error:', error);
	                alert('게시글 작성 중 오류가 발생했습니다.');
	                submitBtn.disabled = false;
	                submitBtn.textContent = '작성 완료';
	            });
	        });
	
	        function goBack() {
	            if (titleInput.value.trim() || contentTextarea.value.trim() || selectedFiles.length > 0) {
	                if (confirm('작성 중인 내용이 있습니다. 정말 취소하시겠습니까?')) {
	                    window.location.href = contextPath + '/UI/JSP/User/InfoBoard.jsp';
	                }
	            } else {
	                window.location.href = contextPath + '/UI/JSP/User/InfoBoard.jsp';
	            }
	        }
	
	        // 페이지 떠날 때 경고
	        window.addEventListener('beforeunload', function(e) {
	            if (titleInput.value.trim() || contentTextarea.value.trim() || selectedFiles.length > 0) {
	                e.preventDefault();
	                e.returnValue = '';
	            }
	        });
	
	        // 로그인 체크
	        <c:if test="${empty sessionScope.user}">
	            alert('로그인이 필요합니다.');
	            location.href = contextPath + '/UI/JSP/Login.jsp';
	        </c:if>
	    </script>
	</body>
	</html>
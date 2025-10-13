<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");

//user.equals(null) -> user == null 로 수정
if (user == null) {
%>
<script>
	alert('로그인이 필요한 서비스 입니다.');
	location.href = '../Login.jsp'; // JavaScript 방식의 리다이렉트
</script>
<%
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 작성 - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/styles.css">
    <script type="text/javascript" src="<%= request.getContextPath() %>/se2/js/HuskyEZCreator.js" charset="utf-8"></script>
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
    <jsp:include page="../Common/Header.jsp"/>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <form id="writeForm" class="space-y-6">
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
                    
                    <div>
                        <label for="ir1" class="block text-sm font-medium text-gray-900 mb-2">
                            내용 <span class="text-red-500">*</span>
                        </label>
                        <textarea name="ir1" id="ir1" rows="10" style="width:100%; height:400px;"></textarea>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-900 mb-2">파일첨부</label>
                        <div class="flex items-center space-x-2 mb-2">
                            <input type="file" id="fileInput" name="file" class="hidden" accept="image/*,application/pdf,.doc,.docx,.txt">
                            <button type="button" onclick="document.getElementById('fileInput').click()" 
                                    class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                                파일 선택
                            </button>
                            <span id="fileInfo" class="text-sm text-gray-600">선택된 파일 없음</span>
                        </div>
                    </div>

                    <div class="bg-blue-50 border border-blue-200 rounded-md p-4">
                        <h4 class="text-sm font-medium text-blue-900 mb-2">📝 작성 가이드라인</h4>
                        <ul class="text-sm text-blue-800 space-y-1">
                            <li>• 다른 사용자를 존중하는 언어를 사용해주세요</li>
                            <li>• 개인정보나 민감한 정보는 포함하지 마세요</li>
                            <li>• 허위 정보 유포나 악의적인 목적의 글은 삭제될 수 있습니다</li>
                            <li>• 건전한 토론 문화를 만들어 주세요</li>
                        </ul>
                    </div>
                    
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="goBack()" 
                                class="px-6 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors font-medium">
                            취소
                        </button>
                        <button type="button" id="submitBtn" onclick="submitContents()" 
                                class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors font-medium">
                            작성
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <script>
        let oEditors = [];
        const contextPath = '<%= request.getContextPath() %>';

        // [수정] 전역 변수로 선언만 해둡니다.
        let fileInput;
        let fileInfo;
        let titleInput;

        // 파일 선택을 취소하는 함수
        function clearFile() {
            if (fileInput) fileInput.value = '';
            if (fileInfo) fileInfo.textContent = '선택된 파일 없음';
        }

        // DOM 로딩이 완료된 후 스크립트를 실행합니다.
        document.addEventListener('DOMContentLoaded', function() {
            // 1. 스마트에디터 초기화
            nhn.husky.EZCreator.createInIFrame({
                oAppRef: oEditors,
                elPlaceHolder: "ir1",
                sSkinURI: contextPath + "/se2/SmartEditor2Skin.html",
                fCreator: "createSEditor2"
            });

            // 2. HTML 요소들을 변수에 할당합니다.
            fileInput = document.getElementById('fileInput');
            fileInfo = document.getElementById('fileInfo');
            titleInput = document.getElementById('title');

            // 3. 파일 선택(change) 이벤트 리스너를 등록합니다.
            fileInput.addEventListener('change', function(e) {
                if (e.target.files.length > 0) {
                    const file = e.target.files[0];
                    const fileSizeKB = (file.size / 1024).toFixed(1);

                    if (file.size > 10 * 1024 * 1024) {
                        alert('최대 10MB의 파일만 업로드할 수 있습니다.');
                        clearFile();
                        return;
                    }
                    
                    fileInfo.innerHTML = `
                        <span class="font-medium text-gray-800">${file.name}</span>
                        <span class="text-gray-500">(${fileSizeKB} KB)</span>
                        <button type="button" onclick="clearFile()" class="ml-2 text-red-500 hover:text-red-700 text-sm font-semibold">[삭제]</button>
                    `;
                } else {
                    clearFile();
                }
            });

            // 4. 제목 글자 수 카운트 이벤트 리스너를 등록합니다.
            titleInput.addEventListener('input', function() {
                document.getElementById('titleCount').textContent = this.value.length;
            });
        });

        // 폼 전송 함수
        function submitContents() {
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            
            if (!titleInput.value.trim()) {
                alert("제목을 입력해주세요.");
                return;
            }

            const content = document.getElementById("ir1").value.trim();
            if (!content || content === "<p>&nbsp;</p>" || content === "<p><br></p>") {
                alert("내용을 입력해주세요.");
                return;
            }

            const submitBtn = document.getElementById('submitBtn');
            submitBtn.disabled = true;
            submitBtn.textContent = '작성 중...';
            
            const formData = new FormData(document.getElementById('writeForm'));
            
            fetch(contextPath + '/writeCommuPost.do', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) throw new Error('서버 응답 오류');
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert('게시글이 성공적으로 작성되었습니다.');
                    location.href = contextPath + '/commu/watch.do?id=' + data.postId;
                } else {
                    throw new Error(data.message || '게시글 작성 실패');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('게시글 작성 중 오류가 발생했습니다: ' + error.message);
                submitBtn.disabled = false;
                submitBtn.textContent = '작성';
            });
        }

        // 취소 함수
        function goBack() {
            if (titleInput.value.trim() || fileInput.files.length > 0) {
                if (confirm('작성 중인 내용이 있습니다. 정말 취소하시겠습니까?')) {
                    window.location.href = contextPath + '/UI/JSP/User/CommuBoard.jsp';
                }
            } else {
                window.location.href = contextPath + '/UI/JSP/User/CommuBoard.jsp';
            }
        }
    </script>
</body>
</html>
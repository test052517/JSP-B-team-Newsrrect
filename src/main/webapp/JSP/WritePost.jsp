<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 작성 - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
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
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <!-- Logo - Centered -->
                <div class="flex-shrink-0">
                    <a href="MainPage.html"><h1 class="text-2xl font-bold text-primary">Newsrrect</h1></a>
                </div>
                
                <!-- User Menu - Absolute positioned right -->
                <div class="absolute right-0 flex items-center space-x-4">
                    <button class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그아웃
                    </button>
                </div>
            </div>
        </div>
    </header>
    
    <!-- Navigation -->
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-20 py-4">
                <a href="InfoBoard.html" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium">정보 검증 게시판</a>
                <a href="CommuBoard.html" class="text-white bg-primary px-3 py-2 text-sm font-medium rounded">소통 게시판</a>
                <a href="MyPage.html" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium">마이 페이지</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-300"></div>
        </div>

        <!-- Write Form -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <!-- 폼 전송을 위해 action, method, enctype, id 속성을 추가합니다. -->
                <form id="writeForm" class="space-y-6" action="WritePostProc.jsp" method="post" enctype="multipart/form-data">
                    <!-- Title Input -->
                    <div>
                        <label for="title" class="block text-sm font-medium text-gray-900 mb-2">제목</label>
                        <input type="text" id="title" name="title" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="제목을 입력하세요" required>
                    </div>
                    
                    <!-- Content Input -->
                    <div>
                        <label for="content" class="block text-sm font-medium text-gray-900 mb-2">내용</label>
                        <%-- 
                          include 태그를 div로 감싸고 CSS 클래스를 적용하여 정렬과 크기를 조절할 수 있습니다.
                          예: w-full (너비 100%), mx-auto (가운데 정렬) 
                        --%>
                        <div class="w-full, mx-auto">
                            <%@ include file="/se2/SmartEditor.jsp" %>
                        </div>
                    </div>
                    
                    <!-- File Upload -->
                    <div>
                        <label for="file" class="block text-sm font-medium text-gray-900 mb-2">파일첨부</label>
                        <input type="file" id="file" name="file" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" multiple>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="location.href='CommuBoard.html'" class="px-6 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors font-medium">
                            취소
                        </button>
                        <!-- type을 "button"으로 변경하고 onclick 이벤트를 추가합니다. -->
                        <button type="button" onclick="submitContents()" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors font-medium">
                            작성
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
                <div>
                    <h4 class="text-lg font-semibold mb-4">Newsrrect</h4>
                    <p class="text-gray-400 text-sm">AI 생성 정보를 검증하고 거짓 정보를 구분하는 신뢰할 수 있는 플랫폼입니다.</p>
                </div>
                <div>
                    <h5 class="font-medium mb-4">검증 도구</h5>
                    <ul class="space-y-2 text-sm text-gray-400">
                        <li><a href="#" class="hover:text-white">텍스트 검증</a></li>
                        <li><a href="#" class="hover:text-white">이미지 검증</a></li>
                        <li><a href="#" class="hover:text-white">비디오 검증</a></li>
                        <li><a href="#" class="hover:text-white">출처 검증</a></li>
                    </ul>
                </div>
                <div>
                    <h5 class="font-medium mb-4">서비스</h5>
                    <ul class="space-y-2 text-sm text-gray-400">
                        <li><a href="#" class="hover:text-white">API 서비스</a></li>
                        <li><a href="#" class="hover:text-white">구독 서비스</a></li>
                        <li><a href="#" class="hover:text-white">알림 설정</a></li>
                        <li><a href="#" class="hover:text-white">고객 지원</a></li>
                    </ul>
                </div>
                <div>
                    <h5 class="font-medium mb-4">연락처</h5>
                    <ul class="space-y-2 text-sm text-gray-400">
                        <li>이메일: info@newsrrect.com</li>
                        <li>전화: 02-1234-5678</li>
                        <li>주소: 서울시 강남구</li>
                    </ul>
                </div>
            </div>
            <div class="border-t border-gray-800 mt-8 pt-8 text-center text-sm text-gray-400">
                <p>&copy; 2024 Newsrrect. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        function submitContents() {
            // SmartEditor의 내용을 실제 textarea(ir1)에 업데이트합니다.
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);

            // 제목이 비어있는지 확인
            const title = document.getElementById("title").value;
            if (title.trim() === "") {
                alert("제목을 입력해주세요.");
                document.getElementById("title").focus();
                return;
            }

            // 내용이 비어있는지 확인 (SmartEditor가 생성하는 실제 내용을 기준으로)
            const content = document.getElementById("ir1").value;
            // HTML 태그를 제거하고 순수 텍스트만으로 비어있는지 검사할 수 있습니다.
            // "<p>&nbsp;</p>" 와 같은 기본값만 있는 경우를 체크합니다.
            if (content === "" || content === "<p>&nbsp;</p>" || content === "<p><br></p>") {
                alert("내용을 입력해주세요.");
                oEditors.getById["ir1"].exec("FOCUS");
                return;
            }

            // 폼을 전송합니다.
            document.getElementById("writeForm").submit();
        }
    </script>
</body>
</html>


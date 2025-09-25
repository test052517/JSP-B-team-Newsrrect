<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 작성 - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
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
<body class="bg-white min-h-screen">
    <!-- Header -->
    <div id="header"></div>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <!-- Write Form -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <form class="space-y-6">
                    <!-- Title Input -->
                    <div>
                        <label for="title" class="block text-sm font-medium text-gray-900 mb-2">제목</label>
                        <input type="text" id="title" name="title" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="제목을 입력하세요">
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
                        <input type="file" id="file" name="file" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" multiple>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="goBack()" class="px-6 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors font-medium">
                            취소
                        </button>
                        <button type="submit" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors font-medium">
                            작성
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <div id="footer"></div>

    <script>
        // 헤더와 푸터 로드
        document.addEventListener('DOMContentLoaded', function() {
            // 헤더 로드
            fetch('../Common/Header.html')
                .then(response => response.text())
                .then(html => {
                    document.getElementById('header').innerHTML = html;
                    // 소통 게시판 네비게이션 활성화
                    setTimeout(() => {
                        const commuNav = document.querySelector('a[href="CommuBoard.html"]');
                        if (commuNav) {
                            commuNav.className = 'text-white bg-primary px-3 py-2 text-sm font-medium rounded';
                        }
                    }, 100);
                })
                .catch(error => {
                    console.error('Error loading header:', error);
                });
            
            // 푸터 로드
            fetch('../Common/Footer.html')
                .then(response => response.text())
                .then(html => {
                    document.getElementById('footer').innerHTML = html;
                })
                .catch(error => {
                    console.error('Error loading footer:', error);
                });
        });
        
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

        function goBack() {
            history.back();
        }
        
    </script>
</body>
</html>


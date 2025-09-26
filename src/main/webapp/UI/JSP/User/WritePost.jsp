<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 작성 - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <%-- 스마트에디터 필수 Javascript 라이브러리 로드 --%>
    <script type="text/javascript" src="<%= request.getContextPath() %>/se2/js/HuskyEZCreator.js" charset="utf-8"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles/fonts.css">
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
    <div id="header"></div>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <form id="writeForm" action="WritePostProc.jsp" method="post" enctype="multipart/form-data" class="space-y-6">
                    <div>
                        <label for="title" class="block text-sm font-medium text-gray-900 mb-2">제목</label>
                        <input type="text" id="title" name="title" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="제목을 입력하세요" required>
                    </div>
                    
                   <div>
                        <label for="ir1" class="block text-sm font-medium text-gray-900 mb-2">내용</label>
                        <textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:412px; display:none;"></textarea>
                    </div>
                    
                    <div>
                        <label for="file" class="block text-sm font-medium text-gray-900 mb-2">파일첨부</label>
                        <input type="file" id="file" name="file" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary">
                    </div>
                    
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="goBack()" class="px-6 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors font-medium">
                            취소
                        </button>
                        <button type="button" onclick="submitContents()" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors font-medium">
                            작성
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <div id="footer"></div>

    <script>
        let oEditors = []; // 스마트에디터 객체를 담을 전역 변수
        const contextPath = '<%= request.getContextPath() %>'; // 전역으로 contextPath 선언

        // DOM 로딩이 완료된 후 스크립트 실행
        document.addEventListener('DOMContentLoaded', function() {
            
            // --- ★ 수정: 스마트에디터 초기화를 DOMContentLoaded 안으로 이동 ---
            // 페이지가 완전히 그려진 후 에디터를 생성하여 오류를 방지합니다.
            nhn.husky.EZCreator.createInIFrame({
                oAppRef: oEditors,
                elPlaceHolder: "ir1",
                sSkinURI: contextPath + "/se2/SmartEditor2Skin.html",
                htParams: {
                    bUseToolbar: true,
                    fOnBeforeUnload: function(){},
                    sUploadURL: contextPath + "/FileUploader.jsp" // 가장 간단한 경로로 수정
                },
                fCreator: "createSEditor2"
            });

            // --- 헤더 로드 ---
            fetch(contextPath + '../Common/header.jsp')
            fetch(contextPath + '/UI/JSP/Common/Header.jsp')
            fetch(contextPath + '/Html/Common/Header.html')
                .then(response => response.text())
                .then(html => {
                    document.getElementById('header').innerHTML = html;
                    const commuNav = document.querySelector('a[href*="CommuBoard.html"]');
                    if (commuNav) {
                        commuNav.className = 'text-white bg-primary px-3 py-2 text-sm font-medium rounded';
                    }
                })
                .catch(error => console.error('Error loading header:', error));
            
            // --- 푸터 로드 ---
            fetch(contextPath + '/UI/Html/Common/Footer.html')
            fetch(contextPath + '/UI/Html/Common/Footer.html')
                .then(response => response.text())
                .then(html => document.getElementById('footer').innerHTML = html)
                .catch(error => console.error('Error loading footer:', error));
        });
        
        // --- 폼 전송 함수 ---
        function submitContents() {
            // SmartEditor의 내용을 실제 textarea(ir1)에 업데이트합니다.
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);

            const title = document.getElementById("title").value;
            if (title.trim() === "") {
                alert("제목을 입력해주세요.");
                document.getElementById("title").focus();
                return;
            }

            const content = document.getElementById("ir1").value;
            if (content.trim() === "" || content.trim() === "<p>&nbsp;</p>" || content.trim() === "<p><br></p>") {
                alert("내용을 입력해주세요.");
                oEditors.getById["ir1"].exec("FOCUS");
                return;
            }
            
            // 폼을 전송합니다.
            document.getElementById("writeForm").submit();
        }

        // --- 취소 함수 ---
        function goBack() {
            // --- ★ 수정: 안정적인 절대 경로를 사용하도록 수정 ---
            window.location.href = contextPath + '/Html/CommuBoard.html';
        }
    </script>
</body>
</html>
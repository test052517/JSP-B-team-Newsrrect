<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 보기 - 소통 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/styles.css">
    
    <!-- SmartEditor2 스크립트 추가 -->
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
    <header class="bg-white shadow-sm border-b border-gray-200">
        <jsp:include page="../Common/Header.jsp" />
    </header>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">소통 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900">제목</h1>
                </div>

                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <span>학생</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>3</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span>17441</span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span>작성일자</span>
                                <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed">
                        <p>글내용</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <!-- Comment Input with SmartEditor -->
                <div class="mb-6">
                    <form action="#" method="post" id="commentForm">
                        <div class="mb-4">
                            <textarea name="content" id="ir1" rows="10" cols="100" style="width:100%; height:300px; display:none;"></textarea>
                        </div>
                        <div class="flex justify-end">
                            <button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                                댓글등록
                            </button>
                        </div>
                    </form>
                </div>

                <div class="mb-8 bg-blue-100 rounded-lg p-4">
                    <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                    <div class="space-y-4">
                    <div class="border border-gray-200 rounded-lg p-4 bg-white">
                        <div class="flex justify-between items-start mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="font-semibold text-primary">BEST 사용자1</span>
                                <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-sm text-gray-500">작성일자</span>
                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <p class="text-gray-900">확실한 정보를 가져왔어요!</p>
                        </div>
                        
                        <div class="flex items-center space-x-4 text-sm">
                            <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                                <span>추천 123</span>
                            </button>
                            <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                        </div>
                    </div>

                    <div class="ml-6">
                        <div class="border border-gray-200 rounded-lg p-4 bg-white">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <span class="text-gray-500">→</span>
                                    <span class="font-semibold">사용자2</span>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500">작성일자</span>
                                    <span class="text-gray-500 cursor-pointer">🚨</span>
                                </div>
                            </div>
                            
                            <p class="text-gray-900 mb-2">좋은 정보네요~</p>
                            
                            <div class="flex items-center space-x-4 text-sm">
                                <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>추천 45</span>
                                </button>
                                <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                            </div>
                        </div>
                    </div>
                    </div>
                </div>

                <div class="space-y-4">
                    <div class="border border-gray-200 rounded-lg p-4 bg-white">
                        <div class="flex justify-between items-start mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="font-semibold">사용자4</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-sm text-gray-500">작성일자</span>
                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <p class="text-gray-900 mb-2">일반 댓글입니다.</p>
                        </div>
                        
                        <div class="flex items-center space-x-4 text-sm">
                            <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                                <span>추천 12</span>
                            </button>
                            <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                        </div>
                    </div>
                </div>

                <div class="flex justify-center items-center mt-6 space-x-2">
                    <div class="flex space-x-1">
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[1]</button>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <!-- Report Modal Content -->
    </div>

    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <!-- Comment Report Modal Content -->
    </div>

    <script>
        // SmartEditor2 초기화
        var oEditors = [];
        nhn.husky.EZCreator.createInIFrame({
            oAppRef: oEditors,
            elPlaceHolder: "ir1",
            sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html",	
            htParams : {
                bUseToolbar : true,
                bUseVerticalResizer : true,
                bUseModeChanger : true,
            },
            fCreator: "createSEditor2"
        });

        function submitContents() {
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            var form = document.getElementById("commentForm");
            if(form.content.value == "<p>&nbsp;</p>" || form.content.value == "") {
                alert("내용을 입력해주세요.");
                oEditors.getById["ir1"].exec("FOCUS");
                return;
            }
            try {
                form.submit();
            } catch(e) {}
        }

        // Modal functions
        function openReportModal() { /* ... */ }
        function closeReportModal() { /* ... */ }
        function submitReport() { /* ... */ }
        function openCommentReportModal() { /* ... */ }
        function closeCommentReportModal() { /* ... */ }
        function submitCommentReport() { /* ... */ }
    </script>
</body>
</html>

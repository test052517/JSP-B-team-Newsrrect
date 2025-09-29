<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 보기 - 정보 검증 게시판 - Newsrrect</title>
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
    <!-- Header Include -->
    <jsp:include page="../Common/Header.jsp" />

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Board Title -->
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <!-- Post Content -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- Post Title -->
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900">
                        <c:out value="${post.title}" />
                    </h1>
                </div>

                <!-- Post Metadata -->
                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <span><c:out value="${post.author}" /></span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>${post.commentCount}</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 S0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span>${post.viewCount}</span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span>${post.creationDate}</span>
                                <%-- <c:if test="${not empty sessionScope.user}"> --%>
                                    <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                                <%-- </c:if> --%>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Post Body -->
                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed">
                        <p><c:out value="${post.content}" escapeXml="false" /></p>
                    </div>
                </div>

                <!-- Credibility Rating -->
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

        <!-- Comment Section -->
        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <!-- Comment Input -->
                <%-- <c:if test="${not empty sessionScope.user}"> --%>
                    <div class="mb-6">
                        <form action="<%= request.getContextPath() %>/addComment.do" method="post" id="commentForm" enctype="multipart/form-data">
                            <input type="hidden" name="postId" value="${post.id}" />
                            
                            <!-- Rating Selection -->
                            <div class="mb-4">
                                <select name="rating" class="w-32 px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary">
                                    <option value="">선택</option>
                                    <option value="true">참</option>
                                    <option value="false">거짓</option>
                                    <option value="ambiguous">모호</option>
                                </select>
                            </div>
                            
                            <!-- SmartEditor2 Text Area -->
                            <div class="mb-4">
                                <textarea name="content" id="ir1" rows="10" cols="100" style="width:100%; height:300px; display:none;"></textarea>
                            </div>

                            <!-- File Upload Section -->
                            <div class="mb-4">
                                <div class="flex items-center space-x-2 mb-2">
                                    <input type="file" id="comment-file" name="attachments" class="hidden" multiple>
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
                                <button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                                    댓글등록
                                </button>
                            </div>
                        </form>
                    </div>
                <%-- </c:if> --%>

                <!-- Comment List Header -->
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 ${commentList.size()}개</h3>
                    <div class="flex space-x-2">
                        <select class="px-3 py-1 border border-gray-200 rounded text-sm">
                            <option>추천순</option>
                            <option>최신순</option>
                            <option>등록순</option>
                        </select>
                    </div>
                </div>

                <!-- BEST Comments (UI Example) -->
                <div class="mb-8 bg-blue-100 rounded-lg p-4">
                    <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                    <div class="space-y-4">
                    <!-- BEST 댓글 예시 1 -->
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
                                <span class="px-2 py-1 bg-green-100 text-green-800 rounded text-sm">참</span>
                            </div>
                        </div>
                        <p class="text-gray-900 mb-3">확실한 정보를 가져왔어요!</p>
                        <div class="flex items-center space-x-4 text-sm">
                            <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path></svg>
                                <span>추천 123</span>
                            </button>
                            <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                        </div>
                    </div>
                     <!-- BEST 댓글에 대한 답글 예시 -->
                    <div class="ml-6 border border-gray-200 rounded-lg p-4 bg-white">
                        <div class="flex justify-between items-start mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="text-gray-500">→</span>
                                <span class="font-semibold">사용자2</span>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-sm text-gray-500">작성일자</span>
                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                            </div>
                        </div>
                        <p class="text-gray-900 mb-2">좋은 정보네요~</p>
                        <div class="flex items-center space-x-4 text-sm">
                            <button class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path></svg>
                                <span>추천 45</span>
                            </button>
                            <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                        </div>
                    </div>
                    </div>
                </div>

                <!-- Regular Comments -->
                <div class="space-y-4">
                    <c:choose>
                        <c:when test="${not empty commentList}">
                            <c:forEach var="comment" items="${commentList}">
                                <div class="border border-gray-200 rounded-lg p-4 bg-white">
                                    <div class="flex justify-between items-start mb-2">
                                        <div class="flex items-center space-x-2">
                                            <span class="font-semibold"><c:out value="${comment.author}" /></span>
                                        </div>
                                        <div class="flex items-center space-x-2">
                                            <span class="text-sm text-gray-500">${comment.creationDate}</span>
                                            <%-- <c:if test="${not empty sessionScope.user}"> --%>
                                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal(${comment.id})">🚨</span>
                                            <%-- </c:if> --%>
                                            <c:if test="${not empty comment.voteType}">
                                                <span class="px-2 py-1 ${comment.voteClass} rounded text-sm">${comment.voteType}</span>
                                            </c:if>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <%-- SmartEditor로 작성된 내용은 HTML 태그를 포함하므로 escapeXml="false" 처리 필수 --%>
                                        <div class="text-gray-900 mb-2"><c:out value="${comment.content}" escapeXml="false" /></div>
                                    </div>
                                    
                                    <div class="flex items-center space-x-4 text-sm">
                                        <button onclick="toggleLike(${comment.id})" class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                            </svg>
                                            <span>추천 ${comment.likes}</span>
                                        </button>
                                        <%-- <c:if test="${not empty sessionScope.user}"> --%>
                                            <button class="text-gray-600 hover:text-primary">답글쓰기</button>
                                        <%-- </c:if> --%>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-8 text-gray-500">
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                 <!-- Comment Pagination -->
                <div class="flex justify-center items-center mt-6 space-x-2">
                    <div class="flex space-x-1">
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[1]</button>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer Include -->
    <jsp:include page="../Common/Footer.jsp" />

    <!-- Post Report Modal -->
    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-md">
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">게시글 신고하기</h3>
                    <div class="border-b border-gray-200 mb-4"></div>
                    <p class="text-sm text-gray-600 mb-4">해당 게시글을 신고하시겠습니까?</p>
                    <div class="flex justify-end space-x-3">
                        <button onclick="closeReportModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                        <button onclick="submitReport()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">신고</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Comment Report Modal -->
    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">댓글 신고하기</h3>
                    <div class="border-b border-gray-200 mb-4"></div>
                    <p class="text-sm text-gray-600 mb-4">해당 댓글을 신고하시겠습니까?</p>
                    <input type="hidden" id="commentIdToReport" value="">
                    <div class="flex justify-end space-x-3">
                        <button onclick="closeCommentReportModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                        <button onclick="submitCommentReport()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">신고</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
    // SmartEditor2 초기화 및 제출 스크립트
    var oEditors = [];

    nhn.husky.EZCreator.createInIFrame({
        oAppRef: oEditors,
        elPlaceHolder: "ir1",
        sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html",	
        htParams : {
            bUseToolbar : true,				// 툴바 사용
            bUseVerticalResizer : true,		// 크기 조절바 사용
            bUseModeChanger : true			// 모드 탭 사용
        },
        fOnAppLoad : function(){
            // 에디터에 이미지 팝업을 띄울 때 photo_uploader.jsp를 호출하도록 설정
            oEditors.getById["ir1"].exec("LOAD_PHOTO_UPLOAD_URL", ["<%=request.getContextPath()%>/se2/photo_uploader.jsp"]);
        },
        fOnBeforeUnload : function(){},
        fCreator: "createSEditor2"
    });

    function submitContents() {
        oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
        
        var form = document.getElementById("commentForm");
        if(form.content.value == "<p>&nbsp;</p>" || form.content.value == "") {
            alert("내용을 입력해주세요.");
            oEditors.getById["ir1"].exec("FOCUS"); // 에디터에 포커스를 줍니다.
            return;
        }

        try {
            form.submit();
        } catch(e) {
            console.error(e);
        }
    }


    // Post Report Modal
    function openReportModal() {
        document.getElementById('reportModal').classList.remove('hidden');
    }
    function closeReportModal() {
        document.getElementById('reportModal').classList.add('hidden');
    }
    function submitReport() {
        alert('게시글 신고가 접수되었습니다.');
        closeReportModal();
    }

    // Comment Report Modal
    function openCommentReportModal(commentId) {
        document.getElementById('commentIdToReport').value = commentId;
        document.getElementById('commentReportModal').classList.remove('hidden');
    }
    function closeCommentReportModal() {
        document.getElementById('commentReportModal').classList.add('hidden');
    }
    function submitCommentReport() {
        const commentId = document.getElementById('commentIdToReport').value;
        alert('댓글(ID: ' + commentId + ') 신고가 접수되었습니다.');
        closeCommentReportModal();
    }

    // Modal 외부 클릭 시 닫기
    window.addEventListener('click', function(e) {
        if (e.target == document.getElementById('reportModal')) {
            closeReportModal();
        }
        if (e.target == document.getElementById('commentReportModal')) {
            closeCommentReportModal();
        }
    });

    // 추천 토글
    function toggleLike(commentId) {
        fetch('<%= request.getContextPath() %>/toggleLike.do', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'commentId=' + commentId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload(); 
            } else {
                alert(data.message || '추천 처리 중 오류가 발생했습니다.');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('추천 처리 중 오류가 발생했습니다.');
        });
    }

    // 파일 선택 처리 스크립트
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

    // 파일 선택 초기화 함수
    function clearFiles() {
        const fileInput = document.getElementById('comment-file');
        fileInput.value = ''; // Clear the file input
        
        const selectedFilesDiv = document.getElementById('selected-files');
        selectedFilesDiv.classList.add('hidden');
        
        const fileNameSpan = document.getElementById('file-name');
        fileNameSpan.textContent = '선택된 파일 없음';
    }

    </script>
</body>
</html>


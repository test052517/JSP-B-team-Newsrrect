<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
		// 세션에서 User 정보 가져옴
		beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이 페이지 - Newsrrect</title>
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
    <jsp:include page="../Common/Header.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">마이 페이지</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm">
            <div class="p-8">
                
                <!-- Profile Section -->
                <div class="bg-gray-100 rounded-lg p-6 mb-8 relative">
                    <div class="absolute top-4 right-4 text-sm text-gray-500">
                        가입일: 
                        <c:choose>
                            <c:when test="${not empty user.createdAt}">
                                <fmt:parseDate var="joinDateObj" 
                                               value="${user.createdAt}" 
                                               pattern="yyyy-MM-dd HH:mm:ss" 
                                               type="both" />
                                <fmt:formatDate value="${joinDateObj}" pattern="yyyy.MM.dd" />
                            </c:when>
                            <c:otherwise>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <form id="profileForm" action="<%= request.getContextPath() %>/updateProfile.do" method="post" enctype="multipart/form-data">
                        <div class="flex items-center">
                            <div class="relative">
                                <input type="file" id="profileImageInput" name="profileImage" accept="image/*" class="hidden" onchange="handleImageUpload(event)">
                                <div id="profileImageContainer" class="w-32 h-32 bg-gray-400 rounded-full mr-6 flex-shrink-0 cursor-pointer hover:bg-gray-500 transition-colors flex items-center justify-center" onclick="document.getElementById('profileImageInput').click()">
                                    <c:choose>
                                        <c:when test="${not empty user.profileImage}">
                                            <img id="profileImage" src="<%= request.getContextPath() %>/uploads/profiles/${user.profileImage}" 
                                                 alt="프로필 이미지" class="w-full h-full object-cover rounded-full">
                                        </c:when>
                                        <c:otherwise>
                                            <img id="profileImage" src="" alt="프로필 이미지" class="w-full h-full object-cover rounded-full hidden">
                                            <span id="profileImagePlaceholder" class="text-white text-sm font-medium">이미지 선택</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            
                            <div class="flex-1">
                                <div class="mb-2">
                                    <label for="nickname" class="block text-sm font-medium text-gray-700 mb-1">닉네임</label>
                                    <input type="text" id="nickname" name="nickname" 
                                           value="<c:out value='${not empty user.nickname ? user.nickname : "닉네임"}' />"
                                           class="w-full max-w-sm px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
                                           maxlength="20" readonly>
                                </div>
                                <div class="mb-4">
                                    <label for="introduce" class="block text-sm font-medium text-gray-700 mb-1">자기소개</label>
                                    <textarea id="introduce" name="introduce" rows="3"
                                              class="w-full max-w-lg px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                                              placeholder="자기소개를 입력하세요" maxlength="200" readonly><c:out value="${not empty user.introduce ? user.introduce : '자기 소개'}" /></textarea>
                                    <div class="text-sm text-gray-500 mt-1">
                                        <span id="introduceCount">${not empty user.introduce ? fn:length(user.introduce) : 0}</span>/200자
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="absolute bottom-4 right-4">
                            <button type="button" id="editBtn" onclick="toggleEdit()" 
                                    class="bg-gray-600 text-white px-4 py-2 rounded text-sm font-medium hover:bg-gray-700 transition-colors">
                                수정
                            </button>
                            <button type="submit" id="saveBtn" 
                                    class="bg-primary text-white px-4 py-2 rounded text-sm font-medium hover:bg-primary-dark transition-colors hidden">
                                저장
                            </button>
                            <button type="button" id="cancelBtn" onclick="cancelEdit()"
                                    class="bg-gray-400 text-white px-4 py-2 rounded text-sm font-medium hover:bg-gray-500 transition-colors hidden ml-2">
                                취소
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Statistics -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-blue-50 rounded-lg p-4 text-center">
                        <div class="text-2xl font-bold text-blue-600 mb-1">
                            ${not empty userStats.postCount ? userStats.postCount : 1234}
                        </div>
                        <div class="text-sm text-blue-800">작성한 게시글</div>
                    </div>
                    <div class="bg-green-50 rounded-lg p-4 text-center">
                        <div class="text-2xl font-bold text-green-600 mb-1">
                            ${not empty userStats.commentCount ? userStats.commentCount : 1234}
                        </div>
                        <div class="text-sm text-green-800">작성한 댓글</div>
                    </div>
                    <div class="bg-purple-50 rounded-lg p-4 text-center">
                        <div class="text-2xl font-bold text-purple-600 mb-1">
                            ${not empty userStats.likeCount ? userStats.likeCount : 567}
                        </div>
                        <div class="text-sm text-purple-800">받은 추천</div>
                    </div>
                </div>

                <!-- Posts Section -->
                <div class="mb-8">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">
                        작성한 게시글(${not empty userPosts ? fn:length(userPosts) : 1234})
                    </h3>
                    <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
                        <table class="w-full">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">번호</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">제목</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">작성일</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">글 심사상태</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <c:choose>
                                    <c:when test="${not empty userPosts}">
                                        <c:forEach var="post" items="${userPosts}">
                                            <tr class="hover:bg-gray-50">
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${post.id}</td>
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoWatch.jsp?id=${post.id}" 
                                                       class="text-sm text-gray-900 hover:text-primary">
                                                        <c:out value="${post.title}" />
                                                    </a>
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                    <fmt:formatDate value="${post.createdDate}" pattern="yyyy.MM.dd" />
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <span class="px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">
                                                        일반
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="px-6 py-12 text-center text-gray-500">
                                                <div class="bg-gray-100 h-32 rounded-lg flex items-center justify-center">
                                                    <span class="text-gray-400">작성한 게시글이 없습니다.</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Comments Section -->
                <div class="mb-8">
                    <h3 class="text-xl font-semibold text-gray-900 mb-4">
                        작성한 댓글(${not empty userComments ? fn:length(userComments) : 1234})
                    </h3>
                    <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
                        <table class="w-full">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">번호</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">제목</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">원글 작성자</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">작성일</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <c:choose>
                                    <c:when test="${not empty userComments}">
                                        <c:forEach var="comment" items="${userComments}">
                                            <tr class="hover:bg-gray-50">
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${comment.id}</td>
                                                <td class="px-6 py-4">
                                                    <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoWatch.jsp?id=${comment.postId}" 
                                                       class="text-sm text-gray-900 hover:text-primary">
                                                        <c:out value="${comment.postTitle}" />
                                                    </a>
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                                                    <c:out value="${comment.postAuthor}" />
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                                    <fmt:formatDate value="${comment.createdDate}" pattern="yyyy.MM.dd" />
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="4" class="px-6 py-12 text-center text-gray-500">
                                                <div class="bg-gray-100 h-32 rounded-lg flex items-center justify-center">
                                                    <span class="text-gray-400">작성한 댓글이 없습니다.</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex justify-between">
                    <button onclick="openWithdrawalModal()" 
                            class="bg-gray-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-gray-700 transition-colors">
                        탈퇴
                    </button>
                    <a href="<%= request.getContextPath() %>/UI/JSP/User/PwdChange.jsp" 
                       class="bg-gray-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-gray-700 transition-colors inline-block">
                        비밀번호 변경
                    </a>
                </div>
            </div>
        </div>
    </main>

    <!-- Withdrawal Modal -->
    <div id="withdrawalModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50 flex items-center justify-center">
        <div class="bg-white rounded-lg p-8 max-w-md w-full mx-4">
            <div class="text-center">
                <h3 class="text-lg font-bold text-gray-900 mb-4">정말 탈퇴하시겠습니까?</h3>
                <p class="text-gray-600 mb-6">탈퇴 버튼 선택 시, 계정은 삭제되며 복구되지 않습니다.</p>
                <form action="<%= request.getContextPath() %>/withdrawal.do" method="post">
                    <div class="flex space-x-4">
                        <button type="button" onclick="closeWithdrawalModal()" 
                                class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-lg font-medium hover:bg-gray-400 transition-colors">
                            취소
                        </button>
                        <button type="submit" 
                                class="flex-1 bg-gray-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-gray-700 transition-colors">
                            탈퇴
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="../Common/Footer.jsp" />

    <script>
        let isEditing = false;
        let originalNickname = '';
        let originalintroduce = '';

        const introduceTextarea = document.getElementById('introduce');
        const introduceCount = document.getElementById('introduceCount');

        if (introduceTextarea) {
        	introduceTextarea.addEventListener('input', function() {
        		introduceCount.textContent = this.value.length;
            });
        }

        function handleImageUpload(event) {
            const file = event.target.files[0];
            if (file) {
                if (file.size > 5 * 1024 * 1024) {
                    alert('프로필 이미지는 5MB 이하만 업로드 가능합니다.');
                    event.target.value = '';
                    return;
                }

                if (!file.type.startsWith('image/')) {
                    alert('이미지 파일만 업로드 가능합니다.');
                    event.target.value = '';
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(e) {
                    const profileImage = document.getElementById('profileImage');
                    const profileImagePlaceholder = document.getElementById('profileImagePlaceholder');
                    
                    profileImage.src = e.target.result;
                    profileImage.classList.remove('hidden');
                    if (profileImagePlaceholder) {
                        profileImagePlaceholder.classList.add('hidden');
                    }
                };
                reader.readAsDataURL(file);
            }
        }

        function toggleEdit() {
            const nicknameInput = document.getElementById('nickname');
            const introduceTextarea = document.getElementById('introduce');
            const editBtn = document.getElementById('editBtn');
            const saveBtn = document.getElementById('saveBtn');
            const cancelBtn = document.getElementById('cancelBtn');

            if (!isEditing) {
                originalNickname = nicknameInput.value;
                originalIntroduce = introduceTextarea.value;
                
                nicknameInput.readOnly = false;
                introduceTextarea.readOnly = false;
                nicknameInput.focus();
                
                editBtn.classList.add('hidden');
                saveBtn.classList.remove('hidden');
                cancelBtn.classList.remove('hidden');
                
                isEditing = true;
            }
        }

        function cancelEdit() {
            const nicknameInput = document.getElementById('nickname');
            const introduceTextarea = document.getElementById('introduce');
            const editBtn = document.getElementById('editBtn');
            const saveBtn = document.getElementById('saveBtn');
            const cancelBtn = document.getElementById('cancelBtn');
            const profileImageInput = document.getElementById('profileImageInput');

            nicknameInput.value = originalNickname;
            introduceTextarea.value = originalIntroduce;
            introduceCount.textContent = originalIntroduce.length;
            
            profileImageInput.value = '';

            nicknameInput.readOnly = true;
            introduceTextarea.readOnly = true;
            
            editBtn.classList.remove('hidden');
            saveBtn.classList.add('hidden');
            cancelBtn.classList.add('hidden');
            
            isEditing = false;
        }

        const profileForm = document.getElementById('profileForm');
        if (profileForm) {
            profileForm.addEventListener('submit', function(e) {
                e.preventDefault();
                
                const nickname = document.getElementById('nickname').value.trim();
                const introduce = document.getElementById('introduce').value.trim();
                
                if (!nickname) {
                    alert('닉네임을 입력해주세요.');
                    return;
                }

                if (nickname.length < 2 || nickname.length > 20) {
                    alert('닉네임은 2-20자 사이여야 합니다.');
                    return;
                }

                if (introduce.length > 200) {
                    alert('자기소개는 200자 이하여야 합니다.');
                    return;
                }

                const saveBtn = document.getElementById('saveBtn');
                saveBtn.disabled = true;
                saveBtn.textContent = '저장중...';

                const formData = new FormData(this);

                fetch(this.action, {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('프로필이 성공적으로 업데이트되었습니다.');
                        location.reload();
                    } else {
                        alert(data.message || '프로필 업데이트에 실패했습니다.');
                        saveBtn.disabled = false;
                        saveBtn.textContent = '저장';
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('프로필 업데이트 중 오류가 발생했습니다.');
                    saveBtn.disabled = false;
                    saveBtn.textContent = '저장';
                });
            });
        }

        function openWithdrawalModal() {
            document.getElementById('withdrawalModal').classList.remove('hidden');
        }

        function closeWithdrawalModal() {
            document.getElementById('withdrawalModal').classList.add('hidden');
        }

        const withdrawalModal = document.getElementById('withdrawalModal');
        if (withdrawalModal) {
            withdrawalModal.addEventListener('click', function(e) {
                if (e.target === this) {
                    closeWithdrawalModal();
                }
            });
        }

        window.addEventListener('beforeunload', function(e) {
            if (isEditing) {
                e.preventDefault();
                e.returnValue = '';
            }
        });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
		// 세션에서 User 정보 가져옴
		beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
%>
<%
    if (user == null) {
        String redirectUrl = request.getContextPath() + "/UI/JSP/Login.jsp";
        
        out.println("<script>");
        out.println("alert('로그인이 필요한 서비스입니다.');");
        out.println("window.location.replace('" + redirectUrl + "');");
        out.println("</script>");

        return; 
    }
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
                        <strong>가입 일자:</strong> 
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
                        <br>
				        <strong>누적 신고:</strong>
				        <c:out value="${user.reportCount}" default="0" />회
				
				        <br>
				        <strong>누적 차단:</strong> 
				        <c:out value="${user.banCount}" default="0" />회
				        
				        <br>
				        <strong>누적 포인트:</strong> 
				        <c:out value="${user.point}" default="0" />
                    </div>
                    
                    <form id="profileForm" action="<%= request.getContextPath() %>/updateProfile.do" method="post" enctype="multipart/form-data">
                        <div class="flex items-center">
                            <div class="relative">
						    <input type="file" id="profileImageInput" name="profileImage" accept="image/*" class="hidden" onchange="handleImageUpload(event)" disabled>
						    
						    <div id="profileImageContainer" 
						         class="w-32 h-32 bg-white rounded-full mr-6 flex-shrink-0 cursor-pointer flex items-center justify-center"> 
						        <c:choose>
						            <c:when test="${not empty user.profileImage}">
						                <img id="profileImage" 
										    src="<%= request.getContextPath() %>/uploads/profiles/<c:out value="${user.profileImage}" />"
										    alt="프로필 이미지" 
										    class="w-full h-full object-cover rounded-full"
										    onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/UI/JSP/IMAGES/default_profile.png';"
										/>
						            </c:when>
						            <c:otherwise>
						                <img id="profileImage" 
							                 src="<%= request.getContextPath() %>/UI/JSP/IMAGES/default_profile.png"
							                 alt="기본 이미지" 
							                 class="w-full h-full object-cover rounded-full"
							            />
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
			    <div class="rounded-lg p-4 text-center" style="background-color: #85b9fd;"> 
			        <div class="text-2xl font-bold mb-1 text-white">
			            <c:out value="${userStats.postCount}" default="0"/>
			        </div>
			        <div class="text-sm text-white">작성한 게시글</div>
			    </div>
			    
			    <div class="rounded-lg p-4 text-center" style="background-color: #738dff;"> 
			        <div class="text-2xl font-bold mb-1 text-white">
			             <c:out value="${userStats.commentCount}" default="0"/>
			        </div>
			        <div class="text-sm text-white">작성한 댓글</div>
			    </div>
			    
			    <div class="rounded-lg p-4 text-center" style="background-color: #7a6bfe;">
			        <div class="text-2xl font-bold mb-1 text-white">
			             <c:out value="${userStats.receivedRecomCount}" default="0"/>
			        </div>
			        <div class="text-sm text-white">받은 추천</div>
			    </div>
			</div>

                <!-- Posts Section -->
                <div class="mb-8">
			    <h3 class="text-xl font-semibold text-gray-900 mb-4">
			        작성한 게시글(<c:out value="${fn:length(recentPosts)}" default="0"/>)
			    </h3>
			    <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
			        <table class="w-full">
			            <thead class="bg-gray-50">
			                <tr>
			                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">번호</th>
			                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">제목</th>
			                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">작성일</th>
			                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">글 유형</th>
			                </tr>
			            </thead>
			            <tbody class="bg-white divide-y divide-gray-200">
			                <c:choose>
			                    <c:when test="${not empty recentPosts}">
			                        <c:forEach var="post" items="${recentPosts}" varStatus="status">
			                            <tr class="hover:bg-gray-50">
			                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
			                                    <c:out value="${fn:length(recentPosts) - status.index}" />
			                                </td>
											<td class="px-6 py-4 whitespace-nowrap">
											    <c:choose>
											        <c:when test="${post.type eq '정보'}">
											            <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoWatch.jsp?id=${post.postId}" 
											               class="text-sm text-gray-900 hover:text-primary">
											                <c:out value="${post.title}" />
											            </a>
											        </c:when>
											        <c:when test="${post.type eq '소통'}">
											            <a href="<%= request.getContextPath() %>/UI/JSP/User/CommuWatch.jsp?id=${post.postId}" 
											               class="text-sm text-gray-900 hover:text-primary">
											                <c:out value="${post.title}" />
											            </a>
											        </c:when>
											        <c:otherwise>
											            <c:out value="${post.title}" />
											        </c:otherwise>
											    </c:choose>
											</td>
			                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
			                                    <c:out value="${post.formattedDate}" /> 
			                                </td>
			                                <td class="px-6 py-4 whitespace-nowrap">
			                                    <span class="px-2 py-1 text-xs font-semibold rounded-full 
			                                          <c:if test='${post.type eq "정보"}'>bg-blue-100 text-blue-800</c:if>
			                                          <c:if test='${post.type eq "소통"}'>bg-green-100 text-green-800</c:if>">
			                                        <c:out value="${post.type}" />
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
				        작성한 댓글(<c:out value="${fn:length(recentComments)}" default="0"/>)
				    </h3>
				    <div class="bg-white border border-gray-200 rounded-lg overflow-hidden">
				        <table class="w-full">
				            <thead class="bg-gray-50">
				                <tr>
				                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">번호</th>
				                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">원문 제목</th>
				                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">댓글 내용 미리보기</th>
				                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">작성일</th>
				                </tr>
				            </thead>
				            <tbody class="bg-white divide-y divide-gray-200">
				                <c:choose>
				                    <c:when test="${not empty recentComments}">
				                        <c:forEach var="comment" items="${recentComments}" varStatus="status">
				                            <tr class="hover:bg-gray-50">
				                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
				                                    <c:out value="${fn:length(recentComments) - status.index}" />
				                                </td>
												<td class="px-6 py-4">
												    <c:choose>
												        <%-- 댓글의 원문 글 type이 '정보'일 경우 InfoWatch.jsp로 연결 --%>
												        <c:when test="${comment.originalPostType eq '정보'}">
												            <a href="<%= request.getContextPath() %>/UI/JSP/User/InfoWatch.jsp?id=${comment.originalPostId}" 
												               class="text-sm text-gray-900 hover:text-primary truncate max-w-xs block">
												                <c:out value="${comment.originalPostTitle}" />
												            </a>
												        </c:when>
												        <%-- 댓글의 원문 글 type이 '소통'일 경우 CommuWatch.jsp로 연결 --%>
												        <c:when test="${comment.originalPostType eq '소통'}">
												            <a href="<%= request.getContextPath() %>/UI/JSP/User/CommuWatch.jsp?id=${comment.originalPostId}" 
												               class="text-sm text-gray-900 hover:text-primary truncate max-w-xs block">
												                <c:out value="${comment.originalPostTitle}" />
												            </a>
												        </c:when>
												        <c:otherwise>
												            <c:out value="${comment.originalPostTitle}" />
												        </c:otherwise>
												    </c:choose>
												</td>
				                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 truncate max-w-sm">
				                                     <c:out value="${fn:substring(comment.content, 0, 30)}" />...
				                                </td>
				                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
				                                    <c:out value="${comment.formattedDate}" />
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
            const profileImageInput = document.getElementById('profileImageInput');
            const profileImageContainer = document.getElementById('profileImageContainer'); // UI 제어용
            const profileImagePlaceholder = document.getElementById('profileImagePlaceholder'); // 이미지 선택 텍스트
            
            if (!isEditing) {
                originalNickname = nicknameInput.value;
                originalIntroduce = introduceTextarea.value;
                
                introduceTextarea.readOnly = false;
                
                profileImageInput.readOnly = false;
                profileImageInput.disabled = false;
                
                
                // UI (이미지 오버레이/텍스트) 활성화
                if (profileImageContainer) {
                    profileImageContainer.classList.add('hover:bg-gray-500', 'transition-colors');
                    profileImageContainer.onclick = function() {
                        document.getElementById('profileImageInput').click();
                    };
                }
                if (profileImagePlaceholder) {
                    profileImagePlaceholder.classList.remove('hidden'); 
                }

                nicknameInput.focus();
                
                // 버튼 전환
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
            const introduceCount = document.getElementById('introduceCount');
            const profileImageContainer = document.getElementById('profileImageContainer');
            const profileImagePlaceholder = document.getElementById('profileImagePlaceholder');

            nicknameInput.value = originalNickname;
            introduceTextarea.value = originalIntroduce;

            if (introduceCount) {
                introduceCount.textContent = originalIntroduce.length; 
            }
            
            profileImageInput.value = '';
            profileImageInput.disabled = true;
            profileImageInput.readOnly = true;
            introduceTextarea.readOnly = true; 

            if (profileImagePlaceholder) {
                profileImagePlaceholder.classList.add('hidden'); 
            }
            if (profileImageContainer) {
                profileImageContainer.classList.remove('hover:bg-gray-500', 'transition-colors');
                profileImageContainer.onclick = null;
            }
            
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
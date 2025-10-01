<%-- 회원가입페이지 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 - Newsrrect</title>
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
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <div class="flex-shrink-0">
                    <a href="<%= request.getContextPath() %>/UI/JSP/MainPage.jsp"><h1 class="text-2xl font-bold text-primary font-newsrrect">Newsrrect</h1></a>
                </div>
                
                <div class="absolute right-0 flex items-center space-x-4">
                    <button class="text-primary hover:text-primary-dark text-sm font-medium" onclick="if(typeof loadLoginContent === 'function') { loadLoginContent(); } else { window.location.href = '../Login.jsp'; }">
                        로그인
                    </button>
                </div>
            </div>
        </div>
    </header>
    
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-20 py-4">
                <a href="InfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="CommuBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="MyPage.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">마이 페이지</a>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="flex justify-center items-center min-h-96">
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 w-full max-w-md">
                <form id="signupForm" action="../../../Proc/User/NewAccountProc.jsp" method="post" class="space-y-6">
                	<div>
                        <label for="email" class="block text-sm font-medium text-gray-900 mb-2">이메일</label>
                        <div class="flex space-x-2">
                            <input type="email" id="email" name="email" 
                                   class="flex-1 px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" 
                                   placeholder="이메일을 입력하세요">
                            <button type="button" id="sendVerificationBtn"
                                    class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors text-sm font-medium">
                                인증코드 발송
                            </button>
                        </div>
                        <p id="emailCheckResult" class="text-sm mt-1"></p>
                    </div>

                    <div id="verificationCodeSection" class="hidden">
                        <label for="verificationCode" class="block text-sm font-medium text-gray-900 mb-2">인증코드</label>
                        <div class="flex space-x-2">
                            <input type="text" id="verificationCode" name="verificationCode"
                                   class="flex-1 px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary"
                                   placeholder="인증코드 6자리를 입력하세요" maxlength="6">
                            <button type="button" id="verifyCodeBtn"
                                    class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors text-sm font-medium">
                                인증확인
                            </button>
                        </div>
                        <p id="verificationResult" class="text-sm mt-1"></p>
                        <p id="timerDisplay" class="text-sm mt-1 text-gray-600"></p>
                    </div>
                    
                    <div>
					    <label for="nickname" class="block text-sm font-medium text-gray-900 mb-2">닉네임</label>
					    <div class="flex space-x-2">
					        <input type="text" id="nickname" name="nickname"
					               class="flex-1 px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary"
					               placeholder="닉네임을 입력하세요">
					        <button type="button" id="checkNicknameBtn"
					                class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors text-sm font-medium">
					            중복확인
					        </button>
					    </div>
					    <p id="nicknameCheckResult" class="text-sm mt-1"></p>
					</div>
                    
                    <div>
                        <label for="password" class="block text-sm font-medium text-gray-900 mb-2">비밀번호</label>
                        <input type="password" id="password" name="password" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="비밀번호를 입력하세요">
                        <p class="text-red-600 text-sm mt-1 hidden">비밀번호를 입력해주세요</p>
                    </div>
                    
                    <div>
                        <label for="confirm-password" class="block text-sm font-medium text-gray-900 mb-2">비밀번호 확인</label>
                        <input type="password" id="confirm-password" name="confirm-password" class="w-full px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary" placeholder="비밀번호를 다시 입력하세요">
                        <p class="text-red-600 text-sm mt-1 hidden">비밀번호 확인을 입력해주세요</p>
                    </div>
                    
                    <button type="submit" class="w-full bg-primary text-white py-2 px-4 rounded-md hover:bg-primary-dark transition-colors font-medium">
                        회원가입
                    </button>
                </form>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <script>
        let isEmailVerified = false;
        let isNicknameChecked = false;
        let verificationTimer = null;
        let timeLeft = 300; // 5분 (300초)

        // 타이머 표시 함수
        function startTimer() {
            const timerDisplay = document.getElementById('timerDisplay');
            timeLeft = 300;
            
            if (verificationTimer) clearInterval(verificationTimer);
            
            verificationTimer = setInterval(() => {
                timeLeft--;
                const minutes = Math.floor(timeLeft / 60);
                const seconds = timeLeft % 60;
                timerDisplay.textContent = `남은 시간: ${minutes}:${seconds.toString().padStart(2, '0')}`;
                
                if (timeLeft <= 0) {
                    clearInterval(verificationTimer);
                    timerDisplay.textContent = '인증 시간이 만료되었습니다. 다시 발송해주세요.';
                    timerDisplay.style.color = 'red';
                }
            }, 1000);
        }

        // 인증코드 발송
        document.getElementById('sendVerificationBtn').addEventListener('click', function() {
            const email = document.getElementById('email').value.trim();
            const resultEl = document.getElementById('emailCheckResult');

            if (!email) {
                resultEl.textContent = '이메일을 입력해주세요.';
                resultEl.style.color = 'red';
                return;
            }

            // 이메일 형식 검증
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                resultEl.textContent = '올바른 이메일 형식이 아닙니다.';
                resultEl.style.color = 'red';
                return;
            }

            this.disabled = true;
            this.textContent = '발송 중...';

            // 서버에 인증코드 발송 요청
            fetch('SendVerificationEmail.jsp?email=' + encodeURIComponent(email))
                .then(response => response.text())
                .then(data => {
                    data = data.trim();
                    if (data === '성공') {
                        resultEl.textContent = '인증코드가 발송되었습니다. 이메일을 확인해주세요.';
                        resultEl.style.color = 'green';
                        document.getElementById('verificationCodeSection').classList.remove('hidden');
                        startTimer();
                        this.textContent = '재발송';
                    } else {
                        resultEl.textContent = data || '인증코드 발송에 실패했습니다.';
                        resultEl.style.color = 'red';
                        this.textContent = '인증코드 발송';
                    }
                    this.disabled = false;
                })
                .catch(err => {
                    console.error(err);
                    resultEl.textContent = '인증코드 발송 중 오류가 발생했습니다.';
                    resultEl.style.color = 'red';
                    this.disabled = false;
                    this.textContent = '인증코드 발송';
                });
        });

        // 인증코드 확인
        document.getElementById('verifyCodeBtn').addEventListener('click', function() {
            const email = document.getElementById('email').value.trim();
            const code = document.getElementById('verificationCode').value.trim();
            const resultEl = document.getElementById('verificationResult');

            if (!code) {
                resultEl.textContent = '인증코드를 입력해주세요.';
                resultEl.style.color = 'red';
                return;
            }

            if (timeLeft <= 0) {
                resultEl.textContent = '인증 시간이 만료되었습니다. 인증코드를 재발송해주세요.';
                resultEl.style.color = 'red';
                return;
            }

            this.disabled = true;

            fetch('VerifyEmailCode.jsp?email=' + encodeURIComponent(email) + '&code=' + encodeURIComponent(code))
                .then(response => response.text())
                .then(data => {
                    data = data.trim();
                    if (data === '성공') {
                        resultEl.textContent = '이메일 인증이 완료되었습니다.';
                        resultEl.style.color = 'green';
                        isEmailVerified = true;
                        clearInterval(verificationTimer);
                        document.getElementById('timerDisplay').textContent = '';
                        document.getElementById('email').readOnly = true;
                        document.getElementById('verificationCode').readOnly = true;
                        this.disabled = true;
                        document.getElementById('sendVerificationBtn').disabled = true;
                    } else {
                        resultEl.textContent = '인증코드가 일치하지 않습니다.';
                        resultEl.style.color = 'red';
                        this.disabled = false;
                    }
                })
                .catch(err => {
                    console.error(err);
                    resultEl.textContent = '인증 확인 중 오류가 발생했습니다.';
                    resultEl.style.color = 'red';
                    this.disabled = false;
                });
        });

        // 닉네임 중복 확인
        document.getElementById('checkNicknameBtn').addEventListener('click', function() {
            const nickname = document.getElementById('nickname').value.trim();
            const resultEl = document.getElementById('nicknameCheckResult');

            if (!nickname) {
                resultEl.textContent = '닉네임을 입력해주세요.';
                resultEl.style.color = 'red';
                return;
            }

            fetch('CheckNickname.jsp?nickname=' + encodeURIComponent(nickname))
                .then(response => response.text())
                .then(data => {
				    data = data.trim();
				    if (data === '중복') {
				        resultEl.textContent = '이미 사용 중인 닉네임입니다.';
				        resultEl.style.color = 'red';
				        isNicknameChecked = false;
				    } else {
				        resultEl.textContent = '사용 가능한 닉네임입니다.';
				        resultEl.style.color = 'green';
				        isNicknameChecked = true;
				    }
				})
                .catch(err => {
                    console.error(err);
                    resultEl.textContent = '중복 확인 중 오류가 발생했습니다.';
                    resultEl.style.color = 'red';
                });
        });

        // 폼 제출 시 유효성 검사
        const form = document.getElementById('signupForm');
        form.addEventListener('submit', function(e) {
            let valid = true;

            // 이메일 인증 확인
            if (!isEmailVerified) {
                alert('이메일 인증을 완료해주세요.');
                e.preventDefault();
                return;
            }

            // 닉네임 중복 확인
            if (!isNicknameChecked) {
                alert('닉네임 중복 확인을 해주세요.');
                e.preventDefault();
                return;
            }

            const fields = ['email','nickname','password','confirm-password'];
            fields.forEach(id => {
                const input = document.getElementById(id);
                const errorMsg = input.nextElementSibling;
                if (errorMsg && errorMsg.tagName === "P" && errorMsg.classList.contains("text-red-600")) {
                    if (!input.value.trim()) {
                        errorMsg.classList.remove('hidden');
                        valid = false;
                    } else {
                        errorMsg.classList.add('hidden');
                    }
                }
            });

            const password = document.getElementById('password').value.trim();
            const confirm = document.getElementById('confirm-password').value.trim();
            const confirmError = document.getElementById('confirm-password').nextElementSibling;
            if (password && confirm && password !== confirm) {
                confirmError.textContent = '비밀번호가 일치하지 않습니다';
                confirmError.classList.remove('hidden');
                valid = false;
            }

            if (!valid) e.preventDefault();
        });
    </script>
</body>
</html>
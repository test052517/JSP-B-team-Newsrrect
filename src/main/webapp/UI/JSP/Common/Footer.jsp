<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<footer class="bg-[#392385] text-white py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
                <h4 class="text-lg font-semibold mb-4" style="font-family: 'Aggravo', sans-serif;">Newsrrect</h4>
                <p class="text-white text-sm">AI 생성 정보를 검증하고 거짓 정보를 구분하는 신뢰할 수 있는 커뮤니티 플랫폼입니다.</p>
            </div>
            <div>
                <h5 class="font-medium mb-4">주요 페이지</h5>
                <ul class="space-y-2 text-sm text-white">
                    <li><a href="MainPage.html" class="hover:text-white" onclick="scrollToTop()">메인 페이지</a></li>
                    <li><a href="InfoBoard.html" class="hover:text-white">정보 검증 게시판</a></li>
                    <li><a href="CommuBoard.html" class="hover:text-white">소통 게시판</a></li>
                    <li><a href="MyPage.html" class="hover:text-white" onclick="checkLoginAndRedirect(event)">마이페이지</a></li>
                </ul>
            </div>
            <div>
                <h5 class="font-medium mb-4">커뮤니티</h5>
                <div class="relative group">
                    <a href="#" class="hover:text-white text-sm text-white block py-2">공지사항</a>
                    <div class="absolute left-0 top-full mt-1 bg-[#392385] opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 ease-in-out z-50 min-w-[120px]">
                        <ul class="py-2">
                            <li><a href="InfoBoard.html" class="block px-4 py-2 text-sm text-white hover:bg-white/10 transition-colors duration-200">정보 검증</a></li>
                            <li><a href="CommuBoard.html" class="block px-4 py-2 text-sm text-white hover:bg-white/10 transition-colors duration-200">소통</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div>
                <h5 class="font-medium mb-4">연락처</h5>
                <ul class="space-y-2 text-sm text-white">
                    <li class="text-2xl font-bold">051-1234-5678</li>
                    <li>email : Newsrrect@gmail.com</li>
                </ul>
            </div>
        </div>
        <div class="border-t border-white mt-8 pt-8 text-center text-sm text-white">
            <p style="font-family: 'Aggravo', sans-serif;">&copy; 2025 Newsrrect. All rights reserved.</p>
        </div>
    </div>
</footer>

<script>
    function scrollToTop() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }

    function checkLoginAndRedirect(event) {
        // 로그인 상태 확인 (실제 구현에서는 서버에서 확인)
        // 예: const isLoggedIn = ${sessionScope.user != null};
        const isLoggedIn = false; // 임시로 false로 설정
        
        if (!isLoggedIn) {
            event.preventDefault();
            // 로그인 페이지로 이동하거나 로그인 모달 표시
            window.location.href = 'Login.html';
        }
    }
</script>
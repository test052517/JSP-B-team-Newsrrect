<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
		//세션에서 email 가져옴
		String email = (String)session.getAttribute("email");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Newsrrect - 관리자 페이지</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="CSS/fonts.css">
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
<body class="min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center items-center h-16 relative">
                <!-- Logo - Centered -->
                <div class="flex-shrink-0">
                    <h1 class="text-2xl font-bold text-primary font-newsrrect"
                    style="
                    background-image: linear-gradient(to bottom, #738dff, #6179f8);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                    color: transparent; /* fallback */">Newsrrect</h1>
                </div>
                
                <!-- User Menu - Absolute positioned right -->
                <div class="absolute right-0 flex items-center space-x-4">
                    <%if(email!=null){ %>
                    <a href="../JSP/Logout.jsp" class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그아웃
                    </a>
                    <%}else{%>
                  <a href="../JSP/Login.jsp" class="text-primary hover:text-primary-dark text-sm font-medium">
                        로그인
                    </a>
                  <% } %>
                </div>
            </div>
        </div>
    </header>
    
    <!-- Navigation -->
    <nav class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-center space-x-16 py-4">
                <a href="AdminInfo.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판</a>
                <a href="AdminCommu.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">소통 게시판</a>
                <a href="AdminInfoBoard.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">정보 검증 게시판 관리</a>
                <a href="AdminUserReport.jsp" class="text-primary hover:text-primary-dark px-3 py-2 text-sm font-medium font-paperozi-medium">유저 / 신고 관리</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main>
        <!-- 첫 번째 섹션: 후기 캐러셀 영역 -->
        <div class="w-full py-16" style="background-image: linear-gradient(to bottom, #738dff, #6179f8);">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <section class="mb-12">
                    <div class="text-center mb-8">
                        <h2 class="text-3xl font-bold text-white mb-4 font-paperozi-semibold">오늘의 인기 검증 게시물</h2>
                    </div>
                
                    <!-- Featured Post Carousel -->
                    <div class="relative" id="carouselWrapper">
                        <div class="carousel-container relative overflow-hidden">
                            <div class="carousel-track flex transition-transform duration-500 ease-in-out" id="carouselTrack">
                                <!-- JSP에서 동적으로 생성된 카드들 -->
                                <c:choose>
                                    <c:when test="${not empty featuredPosts}">
                                        <c:forEach var="featuredPost" items="${featuredPosts}" varStatus="status">
                                            <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
                                                <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
                                                    <div class="w-16 h-16 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold text-xl mx-auto mb-6">
                                                        ${featuredPost.author.substring(0,1).toUpperCase()}
                                                    </div>
                                                    <h3 class="text-xl font-semibold text-gray-900 mb-6">
                                                        <c:out value="${featuredPost.title}"/>
                                                    </h3>
                                                    <p class="text-gray-700 leading-relaxed">
                                                        <c:out value="${featuredPost.summary}"/>
                                                    </p>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- 기본 카드들 (데이터가 없을 때) -->
                                        <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
                                            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
                                                <div class="w-16 h-16 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold text-xl mx-auto mb-6">
                                                    A
                                                </div>
                                                <h3 class="text-xl font-semibold text-gray-900 mb-6">정치 관련 정보 검증</h3>
                                                <p class="text-gray-700 leading-relaxed">
                                                    정말 유용한 정보였어요! 정치 관련해서 헷갈렸던 부분이 명확해졌습니다. 
                                                    검증된 정보라서 믿고 참고할 수 있었어요. 앞으로도 이런 신뢰할 수 있는 정보를 
                                                    계속 제공해주시면 좋겠습니다.
                                                </p>
                                            </div>
                                        </div>
                                        
                                        <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
                                            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
                                                <div class="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center text-white font-bold text-xl mx-auto mb-6">
                                                    B
                                                </div>
                                                <h3 class="text-xl font-semibold text-gray-900 mb-6">경제 뉴스 검증</h3>
                                                <p class="text-gray-700 leading-relaxed">
                                                    경제 관련 정보가 너무 많아서 무엇이 진짜인지 헷갈렸는데, 
                                                    여기서 검증된 정보를 보고 안심이 되었어요. 특히 투자 관련해서 
                                                    잘못된 정보로 인한 손실을 방지할 수 있었습니다.
                                                </p>
                                            </div>
                                        </div>
                                        
                                        <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
                                            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
                                                <div class="w-16 h-16 bg-purple-500 rounded-full flex items-center justify-center text-white font-bold text-xl mx-auto mb-6">
                                                    C
                                                </div>
                                                <h3 class="text-xl font-semibold text-gray-900 mb-6">과학 연구 검증</h3>
                                                <p class="text-gray-700 leading-relaxed">
                                                    과학적 근거가 명확한 정보를 제공해주셔서 정말 감사합니다. 
                                                    연구 결과를 바탕으로 한 검증된 정보라서 신뢰할 수 있었어요. 
                                                    이런 플랫폼이 있어서 정말 다행입니다.
                                                </p>
                                            </div>
                                        </div>
                                        
                                        <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
                                            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
                                                <div class="w-16 h-16 bg-orange-500 rounded-full flex items-center justify-center text-white font-bold text-xl mx-auto mb-6">
                                                    D
                                                </div>
                                                <h3 class="text-xl font-semibold text-gray-900 mb-6">사회 이슈 검증</h3>
                                                <p class="text-gray-700 leading-relaxed">
                                                    사회적 이슈에 대한 정확한 정보를 제공해주셔서 정말 도움이 되었습니다. 
                                                    다양한 관점에서 검증된 정보를 볼 수 있어서 균형잡힌 시각을 갖게 되었어요.
                                                </p>
                                            </div>
                                        </div>
                                        
                                        <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
                                            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
                                                <div class="w-16 h-16 bg-pink-500 rounded-full flex items-center justify-center text-white font-bold text-xl mx-auto mb-6">
                                                    E
                                                </div>
                                                <h3 class="text-xl font-semibold text-gray-900 mb-6">문화 콘텐츠 검증</h3>
                                                <p class="text-gray-700 leading-relaxed">
                                                    문화 관련 정보의 진위를 확인할 수 있어서 정말 유용했습니다. 
                                                    잘못된 정보로 인한 오해를 방지할 수 있어서 감사합니다.
                                                </p>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        
                        <!-- Navigation Arrows -->
                        <button id="prevBtn" class="absolute left-4 top-1/2 transform -translate-y-1/2 w-12 h-12 bg-white rounded-full shadow-lg border border-gray-200 flex items-center justify-center hover:bg-primary hover:border-primary hover:shadow-xl hover:scale-110 transition-all duration-300 ease-in-out group" onclick="slide('prev')">
                            <svg class="w-6 h-6 text-gray-600 group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                            </svg>
                        </button>
                        <button id="nextBtn" class="absolute right-4 top-1/2 transform -translate-y-1/2 w-12 h-12 bg-white rounded-full shadow-lg border border-gray-200 flex items-center justify-center hover:bg-primary hover:border-primary hover:shadow-xl hover:scale-110 transition-all duration-300 ease-in-out group" onclick="slide('next')">
                            <svg class="w-6 h-6 text-gray-600 group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                            </svg>
                        </button>
                    </div>
                </section>
            </div>
        </div>

        <!-- 두 번째 섹션: 중간 영역 -->
        <div class="w-full"> 
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-center min-h-[500px]">
                <div class="w-full"> 
                    <section>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto"> 
                            <!-- Today's Upload Statistics -->
                            <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                                <h3 class="text-lg font-medium text-gray-900 mb-4" style="font-family: 'Paperozi', sans-serif; font-weight: 400;">금일 업로드 정보 검증글</h3>
                                <div class="text-4xl font-bold text-primary mb-2">
                                    <c:choose>
                                        <c:when test="${not empty todayUploadCount}">
                                            <fmt:formatNumber value="${todayUploadCount}" pattern="#,###"/>
                                        </c:when>
                                        <c:otherwise>
                                            34,567
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="text-gray-900" style="font-family: 'Paperozi', sans-serif; font-weight: 400;">건</div>
                            </div>
                            
                            <!-- Total Upload Statistics -->
                            <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                                <h3 class="text-lg font-medium text-gray-900 mb-4" style="font-family: 'Paperozi', sans-serif; font-weight: 400;">전체 업로드 정보 검증글</h3>
                                <div class="text-4xl font-bold text-primary mb-2">
                                    <c:choose>
                                        <c:when test="${not empty totalUploadCount}">
                                            <fmt:formatNumber value="${totalUploadCount}" pattern="#,###"/>
                                        </c:when>
                                        <c:otherwise>
                                            1,234,567
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="text-gray-900" style="font-family: 'Paperozi', sans-serif; font-weight: 400;">건</div>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </div>

        <!-- 세 번째 섹션: 게시판 미리보기 영역 -->
        <div class="w-full bg-[#eff3ff] py-16">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <!-- Board Previews Section -->
                <section class="mb-12">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <!-- Information Verification Board -->
                        <div class="text-center">
                            <div class="flex items-center justify-between mb-4">
                                <h3 class="text-xl font-semibold text-[#333437] font-paperozi-semibold">정보 검증 게시판</h3>
                                <button onclick="location.href='AdminInfo.jsp'" class="w-8 h-8 bg-white rounded-full flex items-center justify-center hover:bg-primary hover:text-white transition-all duration-300 ease-in-out group">
                                    <svg class="w-5 h-5 text-primary group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                                    </svg>
                                </button>
                            </div>
                            <div class="bg-white rounded-lg h-64 overflow-hidden">
                                <!-- 최근 정보 검증 게시글 목록 -->
                                <div class="p-4">
                                    <c:choose>
                                        <c:when test="${not empty recentInfoPosts}">
                                            <c:forEach var="infoPost" items="${recentInfoPosts}" varStatus="status">
                                                <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                                                    <div class="flex-1 text-left">
                                                        <div class="text-sm text-gray-900 truncate">
                                                            <c:out value="${infoPost.title}"/>
                                                        </div>
                                                        <div class="text-xs text-gray-500">${infoPost.author}</div>
                                                    </div>
                                                    <div class="text-xs text-gray-400">
                                                        <fmt:formatDate value="${infoPost.createDate}" pattern="MM.dd"/>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center text-gray-500 py-8">등록된 게시글이 없습니다.</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Communication Board -->
                        <div class="text-center">
                            <div class="flex items-center justify-between mb-4">
                                <h3 class="text-xl font-semibold text-[#333437] font-paperozi-semibold">소통 게시판</h3>
                                <button onclick="location.href='AdminCommu.jsp'" class="w-8 h-8 bg-white rounded-full flex items-center justify-center hover:bg-primary hover:text-white transition-all duration-300 ease-in-out group">
                                    <svg class="w-5 h-5 text-primary group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                                    </svg>
                                </button>
                            </div>
                            <div class="bg-white rounded-lg h-64 overflow-hidden">
                                <!-- 최근 소통 게시글 목록 -->
                                <div class="p-4">
                                    <c:choose>
                                        <c:when test="${not empty recentCommuPosts}">
                                            <c:forEach var="commuPost" items="${recentCommuPosts}" varStatus="status">
                                                <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                                                    <div class="flex-1 text-left">
                                                        <div class="text-sm text-gray-900 truncate">
                                                            <c:out value="${commuPost.title}"/>
                                                        </div>
                                                        <div class="text-xs text-gray-500">${commuPost.author}</div>
                                                    </div>
                                                    <div class="text-xs text-gray-400">
                                                        <fmt:formatDate value="${commuPost.createDate}" pattern="MM.dd"/>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center text-gray-500 py-8">등록된 게시글이 없습니다.</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="../Common/Footer.jsp" />

    <script>
    let currentIndex = 0;
    const track = document.getElementById('carouselTrack');
    const cards = document.querySelectorAll('.review-card');
    const carouselWrapper = document.getElementById('carouselWrapper');
    const totalCards = cards.length;

    // 실제 CSS와 일치하는 값
    const CARD_WIDTH = 500; 
    const CARD_MARGIN = 15;
    const STEP_SIZE = CARD_WIDTH + CARD_MARGIN * 2; // 500px + 30px = 530px

    // maxIndex는 카드 총 개수에 따라 설정
    const maxIndex = totalCards > 0 ? totalCards - 1 : 0;

    // 중앙 정렬 로직
    function updateCarousel() {
        if (totalCards === 0) return;

        // 컨테이너 폭의 절반
        const containerWidth = carouselWrapper.offsetWidth;
        const containerHalfWidth = containerWidth / 2;
        
        // 현재 선택된 카드까지의 왼쪽 누적 거리
        const cardCenterOffset = currentIndex * STEP_SIZE + (CARD_WIDTH / 2) + CARD_MARGIN;
        
        // 최종 이동 거리: 선택된 카드의 중심을 중앙에 맞추기 위한 트랙의 이동 값
        const translateX = containerHalfWidth - cardCenterOffset;
        
        track.style.transform = `translateX(${translateX}px)`;
        
        // 중앙 위치에 따른 투명화 로직
        cards.forEach((card, index) => {
            const distance = Math.abs(index - currentIndex);
            
            let opacityValue;
            if (distance === 0) {
                opacityValue = 1; // 중앙 카드는 완전 불투명
            } else if (distance === 1) {
                opacityValue = 0.5; // 바로 옆 카드는 반투명 
            } else {
                opacityValue = 0.2; // 그 외 카드는 거의 보이지 않음
            }
            
            // CSS 스타일 적용
            card.style.opacity = opacityValue;
            card.style.pointerEvents = (distance < 2) ? 'auto' : 'none';
            card.style.transition = 'opacity 0.5s ease-in-out';
        }); 
        
        // 버튼 상태 업데이트
        const prevBtn = document.getElementById('prevBtn');
        const nextBtn = document.getElementById('nextBtn');
        
        if (prevBtn) prevBtn.disabled = currentIndex === 0;
        if (nextBtn) nextBtn.disabled = currentIndex >= maxIndex; 
    }

    // 슬라이드 함수 
    function slide(direction) {
        if (direction === 'next' && currentIndex < maxIndex) {
            currentIndex++;
        } else if (direction === 'prev' && currentIndex > 0) {
            currentIndex--;
        }
        updateCarousel();
    }

    function goToSlide(index) {
        if (index >= 0 && index <= maxIndex) {
            currentIndex = index;
            updateCarousel();
        }
    }

    // 로그아웃 함수
    function logout() {
        if(confirm('로그아웃 하시겠습니까?')) {
            location.href = 'Login.jsp';
        }
    }

    // 초기 로딩
    document.addEventListener('DOMContentLoaded', () => {
        // 슬라이드 초기 상태 설정
        updateCarousel();
        
        // 창크기 변동 시 업데이트 
        window.addEventListener('resize', updateCarousel); 
        
        // 키보드 이벤트 리스너
        document.addEventListener('keydown', function(e) {
            if (e.key === 'ArrowLeft') {
                slide('prev');
            } else if (e.key === 'ArrowRight') {
                slide('next');
            }
        });
    });
    </script>
</body>
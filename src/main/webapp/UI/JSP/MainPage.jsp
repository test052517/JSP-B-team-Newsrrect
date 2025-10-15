<%@page import="beans.PostBean"%>
<%@page import="java.util.Vector"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:useBean id="pMgr" class="mgr.PostMgr"/>
<%
		// 세션에서 User 정보 가져옴
		beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Newsrrect - AI 정보 검증 플랫폼</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
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
    <jsp:include page ="Common/Header.jsp"/>
<%--     	<%if(user.getRole().equals("관리자")){%>
        <jsp:include page="Common/AdminHeader.jsp" />
    	<%}else{ %>
    	
    	<%} %> --%>

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
                        <%
                            	Vector<PostBean> featuredPosts = pMgr.todayInfoCards("정보");
                        %>
                        <c:set scope="request" var="featuredPosts" value="<%=featuredPosts%>" />
                            <div class="carousel-track flex transition-transform duration-500 ease-in-out" id="carouselTrack">
                                <!-- JSP에서 동적으로 생성된 카드들 -->
								<c:choose>
								    <c:when test="${not empty featuredPosts}">
								        <c:forEach var="featuredPost" items="${featuredPosts}" varStatus="status">
								            <c:url var="watchUrl" value="/info/watch.do">
								                <c:param name="id" value="${featuredPost.postId}" />
								            </c:url>
								            
								            <c:set var="colorClass" value="bg-blue-200 text-blue-800" />
								            <c:choose>
								                <c:when test="${status.index eq 0}"><c:set var="colorClass" value="bg-blue-800 text-white" /></c:when>
								                <c:when test="${status.index eq 1}"><c:set var="colorClass" value="bg-blue-600 text-white" /></c:when>
								                <c:when test="${status.index eq 2}"><c:set var="colorClass" value="bg-blue-400 text-white" /></c:when>
								                <c:when test="${status.index eq 3}"><c:set var="colorClass" value="bg-blue-300 text-blue-800" /></c:when>
								                <c:when test="${status.index ge 4}"><c:set var="colorClass" value="bg-blue-200 text-blue-800" /></c:when>
								            </c:choose>
								            
								            <a href="${watchUrl}">
								                <div class="review-card flex-shrink-0" style="width: 500px; margin: 0 15px;">
								                    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8 h-full text-center">
								                        
								                        <div class="w-16 h-16 ${colorClass} rounded-full flex items-center justify-center font-bold text-xl mx-auto mb-6">
								                            ${featuredPost.viewCount}
								                        </div>
								                        <h3 class="text-xl font-semibold text-gray-900 mb-6">
								                            <c:out value="${featuredPost.title}"/>
								                        </h3>
								                        <p class="text-gray-700 leading-relaxed">
								                            <c:choose>
								                                <c:when test="${fn:length(featuredPost.content) > 100}">
								                                    <c:out value="${fn:substring(featuredPost.content, 0, 100)}..."/>
								                                </c:when>
								                                <c:otherwise>
								                                    <c:out value="${featuredPost.content}"/>
								                                </c:otherwise>
								                            </c:choose>
								                        </p>
								                    </div>
								                </div>
								            </a>
								        </c:forEach>
								    </c:when>
								    <c:otherwise>
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
                                <h3 class="text-lg font-medium text-gray-900 mb-4 font-paperozi-medium">금일 업로드 정보 검증글</h3>
                                <div class="text-4xl font-bold text-primary mb-2">
                                <%
                                int todayUploadCount = pMgr.getTodayInfoCount("정보");
                            	%>
                            	<c:set scope="request" var="todayUploadCount" value="<%=todayUploadCount%>" />
                                    <c:choose>
                                        <c:when test="${not empty todayUploadCount}">
                                            <fmt:formatNumber value="${todayUploadCount}" pattern="#,###"/>
                                        </c:when>
                                        <c:otherwise>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="text-gray-900 font-paperozi-medium">건</div>
                            </div>
                            
                            <!-- Total Upload Statistics -->
                            <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200 text-center">
                                <h3 class="text-lg font-medium text-gray-900 mb-4 font-paperozi-medium">전체 업로드 정보 검증글</h3>
                                <div class="text-4xl font-bold text-primary mb-2">
                                <%
                                int totalUploadCount = pMgr.getInfoCount("정보");
                            	%>
                            	<c:set scope="request" var="totalUploadCount" value="<%=totalUploadCount%>" />
                                    <c:choose>
                                        <c:when test="${not empty totalUploadCount}">
                                            <fmt:formatNumber value="${totalUploadCount}" pattern="#,###"/>
                                        </c:when>
                                        <c:otherwise>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="text-gray-900 font-paperozi-medium">건</div>
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
                                <button onclick="location.href='${pageContext.request.contextPath}/info/watch.do'" class="w-8 h-8 bg-white rounded-full flex items-center justify-center hover:bg-primary hover:text-white transition-all duration-300 ease-in-out group">
                                    <svg class="w-5 h-5 text-primary group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                                    </svg>
                                </button>
                            </div>
                            <div class="bg-white rounded-lg min-h-56 overflow-hidden">
                            <%
                            	Vector <PostBean> recentInfoPosts = pMgr.newListPosts("정보");
                            %>
                            <c:set scope="request" var="recentInfoPosts" value="<%=recentInfoPosts%>" />
                                <!-- 최근 정보 검증 게시글 목록 -->
                                <div class="p-4">
                                    <c:choose>
                                        <c:when test="${not empty recentInfoPosts}">
                                            <c:forEach var="infoPost" items="${recentInfoPosts}" varStatus="status">
                                                <c:url var="watchUrl" value="/info/watch.do">
				                                    <c:param name="id" value="${infoPost.postId}" />
				                                </c:url>
                                                <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                                                    <div class="flex-1 text-left">
                                                        <div class="text-sm text-gray-900 truncate">
                                                            <a href="${watchUrl}"><c:out value="${infoPost.title}"/></a>
                                                        </div>
                                                    </div>
                                                    <div class="text-xs text-gray-400">
                                                        <div class="text-xs text-gray-500">${infoPost.createdAt}</div>
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
                                <button onclick="location.href='../JSP/User/CommuBoard.jsp'" class="w-8 h-8 bg-white rounded-full flex items-center justify-center hover:bg-primary hover:text-white transition-all duration-300 ease-in-out group">
                                    <svg class="w-5 h-5 text-primary group-hover:text-white transition-colors duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                                    </svg>
                                </button>
                            </div>
                            <div class="bg-white rounded-lg min-h-56 overflow-hidden">
                            <%
                            	Vector <PostBean> recentCommuPosts = pMgr.newListPosts("소통");
                            %>
                            <c:set scope="request" var="recentCommuPosts" value="<%=recentCommuPosts%>" />
                                <!-- 최근 소통 게시글 목록 -->
                                <div class="p-4">
                                    <c:choose>
                                        <c:when test="${not empty recentCommuPosts}">
                                            <c:forEach var="commuPost" items="${recentCommuPosts}" varStatus="status">
                                            <c:url var="watchUrl" value="/commu/watch.do">
				                                    <c:param name="id" value="${commuPost.postId}" />
				                            </c:url>
                                                <div class="flex justify-between items-center py-2 border-b border-gray-100 last:border-b-0">
                                                    <div class="flex-1 text-left">
                                                        <div class="text-sm text-gray-900 truncate">
                                                            <a href="${watchUrl}"><c:out value="${commuPost.title}"/></a>
                                                        </div>
                                                    </div>
                                                    <div class="text-xs text-gray-400">
                                                        <div class="text-xs text-gray-500">${commuPost.createdAt}</div>
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
    <jsp:include page="Common/Footer.jsp" />

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
        
        //track.style.transform = `translateX(${translateX}px)`;
		$('#carouselTrack').css('transform', 'translateX(' + translateX + 'px)');
        
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
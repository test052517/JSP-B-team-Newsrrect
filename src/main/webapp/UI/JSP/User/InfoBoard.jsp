<%-- 정보검증게시판 (View) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
		// 세션에서 User 정보 가져옴
		beans.UserBean user = (beans.UserBean)session.getAttribute("loggedInUser");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>정보 검증 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/UI/JSP/CSS/fonts.css">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        'sans': ['Noto Sans KR', 'ui-sans-serif', 'system-ui'],
                        'aggro': ['Aggravo', 'Noto Sans KR', 'sans-serif'],
                        'paperozi': ['Paperozi', 'Noto Sans KR', 'sans-serif']
                    },
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
        	<%if(user.getRole().equals("관리자")){%>
        <jsp:include page="../Common/AdminHeader.jsp" />
    	<%}else{ %>
    	<jsp:include page ="../Common/Header.jsp"/>
    	<%} %>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi font-semibold">정보 검증 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- [수정] 검색 폼 action을 서블릿 URL로 변경 -->
                <form name="searchFrm" method="get" action="${pageContext.request.contextPath}/info/watch.do">
                    <div class="flex justify-between items-center mb-4">
                        <div class="flex items-center space-x-2">
                            <div class="relative">
                                <select name="keyField" class="appearance-none bg-gray-100 border border-gray-200 rounded px-3 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-primary">
                                    <option value="p.title" <c:if test="${keyField eq 'p.title'}">selected</c:if>>제목</option>
                                    <option value="u.nickname" <c:if test="${keyField eq 'u.nickname'}">selected</c:if>>작성자</option>
                                </select>
                                <div class="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                                </div>
                            </div>
                            <input type="text" name="keyWord" value="${keyWord != null ? keyWord : ''}" placeholder="검색어를 입력하세요" class="bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary w-64">
                            <button type="submit" class="bg-primary text-white px-4 py-2 rounded-lg text-sm hover:bg-primary-dark">검색</button>
                        </div>
                        <div class="text-sm text-gray-600">
                            전체 ${totalRecord}개 / ${nowPage} 페이지
                        </div>
                    </div>
                </form>

                <div class="bg-gray-100 rounded-t-lg">
                    <div class="grid grid-cols-12 gap-4 py-3 px-4 text-sm font-semibold text-gray-900">
                        <div class="col-span-1 text-left">번호</div>
                        <div class="col-span-7 text-left">제목</div>
                        <div class="col-span-2 text-left">작성자</div>
                        <div class="col-span-2 text-left">작성일</div>
                    </div>
                </div>

                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg">
                    <c:choose>
                        <c:when test="${not empty postList}">
                            <c:forEach var="post" items="${postList}" varStatus="status">
                                <!-- [수정] 게시글 상세 보기 링크를 서블릿 URL로 변경 -->
                                <c:url var="watchUrl" value="/info/watch.do">
                                    <c:param name="id" value="${post.postId}" />
                                    <c:param name="nowPage" value="${nowPage}" />
                                </c:url>
                                <a href="${watchUrl}" class="grid grid-cols-12 gap-4 py-3 px-4 border-b border-gray-100 last:border-b-0 hover:bg-gray-50 transition-colors duration-200 cursor-pointer">
                                    <div class="col-span-1 text-sm text-gray-900">${totalRecord - ((nowPage - 1) * numPerPage) - status.index}</div>
                                    <div class="col-span-7 text-sm text-gray-900 font-medium truncate">${post.title}</div>
                                    <div class="col-span-2 text-sm text-gray-600">${post.nickname}</div>
                                    <div class="col-span-2 text-sm text-gray-600">${post.formattedDate}</div>
                                </a>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-10 text-gray-500">
                                게시물이 없습니다.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="flex justify-center items-center mt-6 space-x-2">
                    <c:if test="${nowBlock > 1}">
                        <!-- [수정] 페이징 링크를 서블릿 URL로 변경 -->
                        <c:url var="prevUrl" value="/info/watch.do">
                            <c:param name="nowPage" value="${pageStart - 1}" />
                            <c:if test="${not empty keyWord}"><c:param name="keyField" value="${keyField}" /><c:param name="keyWord" value="${keyWord}" /></c:if>
                        </c:url>
                        <a href="${prevUrl}" class="px-3 py-2 text-sm font-medium text-primary border border-gray-200 rounded">이전</a>
                    </c:if>
                    
                    <c:forEach begin="${pageStart}" end="${pageEnd}" var="i">
                        <c:url var="pageUrl" value="/info/watch.do">
                            <c:param name="nowPage" value="${i}" />
                            <c:if test="${not empty keyWord}"><c:param name="keyField" value="${keyField}" /><c:param name="keyWord" value="${keyWord}" /></c:if>
                        </c:url>
                        <c:choose>
                            <c:when test="${nowPage eq i}">
                                <a href="${pageUrl}" class="px-3 py-2 text-sm font-medium bg-primary text-white border border-gray-200 rounded">[${i}]</a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageUrl}" class="px-3 py-2 text-sm font-medium text-primary border border-gray-200 rounded hover:bg-primary hover:text-white transition-all duration-300">[${i}]</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:if test="${nowBlock < totalBlock}">
                         <c:url var="nextUrl" value="/info/watch.do">
                            <c:param name="nowPage" value="${pageEnd + 1}" />
                            <c:if test="${not empty keyWord}"><c:param name="keyField" value="${keyField}" /><c:param name="keyWord" value="${keyWord}" /></c:if>
                        </c:url>
                         <a href="${nextUrl}" class="px-3 py-2 text-sm font-medium text-primary border border-gray-200 rounded">다음</a>
                    </c:if>
                </div>

                <div class="flex justify-end mt-6">
                    <a href="${pageContext.request.contextPath}/UI/JSP/User/InfoWrite.jsp" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary-dark transition-colors font-medium inline-block">
                        글 작성
                    </a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />
</body>
</html>

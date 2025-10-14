<%-- 정보검증게시판 (View) - 공지사항 기능 추가 --%>
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
<body class="min-h-screen bg-gray-50">
    <% 
        if (user != null && "관리자".equals(user.getRole())) { 
    %>
    <jsp:include page="../Common/AdminHeader.jsp" />
    <% 
        } else { 
    %>
    <jsp:include page="../Common/Header.jsp"/>
    <%}%>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">정보 검증 게시판</h2>
            <div class="border-t-2 border-primary"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
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
                            <%-- [수정] 페이징의 기준은 일반 게시글이므로 totalRecord 사용 --%>
                            전체 ${totalRecord}개 / ${nowPage} 페이지
                        </div>
                    </div>
                </form>

                <div class="bg-gray-100 rounded-t-lg border border-gray-200">
                    <div class="grid grid-cols-5 gap-4 py-3 px-4 text-sm font-semibold text-gray-900">
                        <div class="text-center">번호</div>
                        <div class="text-left col-span-2">제목</div>
                        <div class="text-center">작성자</div>
                        <div class="text-center">작성일</div>
                    </div>
                </div>

                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg divide-y divide-gray-100">
                    <c:choose>
                        <c:when test="${empty noticeList and empty regularPostList}">
                            <div class="py-12 text-center">
                                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
                                <p class="mt-4 text-gray-500 font-medium">등록된 게시글이 없습니다.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
<c:if test="${not empty noticeList}">
    <c:forEach var="notice" items="${noticeList}">
        <c:url var="watchUrl" value="/info/watch.do">
            <c:param name="id" value="${notice.postId}" />
        </c:url>
        
        <a href="${watchUrl}" class="grid grid-cols-5 gap-4 py-4 px-4 bg-blue-50/50 hover:bg-blue-100 transition-colors duration-200 cursor-pointer group items-center font-semibold"> 
            
            <div class="text-center font-medium">
                <span class="bg-primary text-white text-xs font-semibold px-2.5 py-1 rounded-full">공지</span>
            </div>
            <div class="col-span-2 text-sm text-gray-900 font-medium group-hover:text-primary transition-colors truncate">${notice.title}</div>  
            <div class="text-center text-sm text-gray-600">${notice.nickname}</div>
            <div class="text-center text-sm text-gray-600">${notice.formattedDate}</div>
        </a>
    </c:forEach>
</c:if>
                            
<c:if test="${not empty regularPostList}">
    <c:forEach var="post" items="${regularPostList}" varStatus="status">
        <a href="${watchUrl}" class="grid grid-cols-5 gap-4 py-4 px-4 hover:bg-blue-50 transition-colors duration-200 cursor-pointer group items-center">
            
            <div class="text-center text-sm text-gray-900">${totalRecord - ((nowPage - 1) * numPerPage) - status.index}</div>
            <div class="col-span-2 text-sm text-gray-900 font-medium group-hover:text-primary transition-colors truncate">${post.title}</div> 

            <div class="text-center text-sm text-gray-600">${post.nickname}</div>
            <div class="text-center text-sm text-gray-600">${post.formattedDate}</div>
        </a>
    </c:forEach>
</c:if>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="flex justify-center items-center mt-6 space-x-2">
                    <%-- 페이징 로직은 기존과 동일 --%>
                    <c:if test="${nowBlock > 1}">
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
				    <a href="${pageContext.request.contextPath}/UI/JSP/User/InfoWrite.jsp" class="bg-primary text-white px-6 py-3 rounded-lg hover:bg-primary-dark transition-colors font-medium inline-flex items-center space-x-2 shadow-sm hover:shadow-md">
				                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
				                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path>
				                        </svg>
				        <span>글 작성</span>
				    </a>
				</div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />
</body>
</html>
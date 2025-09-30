<%-- 정보검증게시판 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Vector, mgr.WatchUserPostMgr, beans.PostBean" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    WatchUserPostMgr watchUserPostMgr = new WatchUserPostMgr();
    
    // 페이징
    int totalRecord = 0;     // 전체 게시물 수
    int numPerPage = 10;     // 페이지당 표시할 게시물 수
    int pagePerBlock = 10;   // 블록당 표시할 페이지 수
    int totalPage = 0;       // 전체 페이지 수
    int nowPage = 1;         // 현재 페이지
    
    String keyField = request.getParameter("keyField");
    String keyWord = request.getParameter("keyWord");

    totalRecord = watchUserPostMgr.getTotalCount("정보", keyField, keyWord);
    
    if (request.getParameter("nowPage") != null) {
        try {
            nowPage = Integer.parseInt(request.getParameter("nowPage"));
        } catch (NumberFormatException e) {
        }
    }
    
    int start = (nowPage * numPerPage) - numPerPage;
    Vector<PostBean> postList = watchUserPostMgr.getPostList("정보", keyField, keyWord, start, numPerPage);
    totalPage = (int)Math.ceil((double)totalRecord / numPerPage);
    int nowBlock = (int)Math.ceil((double)nowPage / pagePerBlock);
    int pageStart = (nowBlock - 1) * pagePerBlock + 1;
    int pageEnd = Math.min(pageStart + pagePerBlock - 1, totalPage);

    pageContext.setAttribute("postList", postList);
    pageContext.setAttribute("totalRecord", totalRecord);
    pageContext.setAttribute("numPerPage", numPerPage);
    pageContext.setAttribute("nowPage", nowPage);
    pageContext.setAttribute("totalPage", totalPage);
    pageContext.setAttribute("pageStart", pageStart);
    pageContext.setAttribute("pageEnd", pageEnd);
    pageContext.setAttribute("nowBlock", nowBlock);
    pageContext.setAttribute("totalBlock", (int)Math.ceil((double)totalPage / pagePerBlock));
    pageContext.setAttribute("keyField", keyField);
    pageContext.setAttribute("keyWord", keyWord);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>정보 검증 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { 'primary': '#5d74f8', 'primary-dark': '#4c63e7', 'primary-light': '#7d8ff9' }
                }
            }
        }
    </script>
</head>
<body class="bg-white min-h-screen">
    <jsp:include page="../Common/Header.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4 font-paperozi-semibold">정보 검증 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <!-- 검색 폼 -->
                <form name="searchFrm" method="get" action="InfoBoard.jsp">
                    <div class="flex justify-between items-center mb-4">
                        <div class="flex items-center space-x-2">
                            <div class="relative">
                                <select name="keyField" class="appearance-none bg-gray-100 border border-gray-200 rounded px-3 py-2 pr-8 text-sm focus:outline-none focus:ring-2 focus:ring-primary">
                                    <option value="p.title" ${keyField eq 'p.title' ? 'selected' : ''}>제목</option>
                                    <option value="u.nickname" ${keyField eq 'u.nickname' ? 'selected' : ''}>작성자</option>
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

                <!-- 게시물 목록 헤더 -->
                <div class="bg-gray-100 rounded-t-lg">
                    <div class="grid grid-cols-12 gap-4 py-3 px-4 text-sm font-semibold text-gray-900">
                        <div class="col-span-1 text-left">번호</div>
                        <div class="col-span-7 text-left">제목</div>
                        <div class="col-span-2 text-left">작성자</div>
                        <div class="col-span-2 text-left">작성일</div>
                    </div>
                </div>

                <!-- 게시물 목록 본문 -->
                <div class="bg-white border border-gray-200 border-t-0 rounded-b-lg">
                    <c:choose>
                        <c:when test="${not empty postList}">
                            <c:forEach var="post" items="${postList}" varStatus="status">
                                <c:url var="watchUrl" value="InfoWatch.jsp">
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

                <!-- 페이징 -->
                <div class="flex justify-center items-center mt-6 space-x-2">
                    <c:if test="${nowBlock > 1}">
                        <c:url var="prevUrl" value="InfoBoard.jsp">
                            <c:param name="nowPage" value="${pageStart - 1}" />
                            <c:if test="${not empty keyWord}"><c:param name="keyField" value="${keyField}" /><c:param name="keyWord" value="${keyWord}" /></c:if>
                        </c:url>
                        <a href="${prevUrl}" class="px-3 py-2 text-sm font-medium text-primary border border-gray-200 rounded">이전</a>
                    </c:if>
                    
                    <c:forEach begin="${pageStart}" end="${pageEnd}" var="i">
                        <c:url var="pageUrl" value="InfoBoard.jsp">
                            <c:param name="nowPage" value="${i}" />
                            <c:if test="${not empty keyWord}"><c:param name="keyField" value="${keyField}" /><c:param name="keyWord" value="${keyWord}" /></c:if>
                        </c:url>
                        <a href="${pageUrl}" class="px-3 py-2 text-sm font-medium ${nowPage eq i ? 'bg-primary text-white' : 'text-primary'} border border-gray-200 rounded hover:bg-primary hover:text-white transition-all duration-300">
                           [${i}]
                        </a>
                    </c:forEach>

                    <c:if test="${nowBlock < totalBlock}">
                         <c:url var="nextUrl" value="InfoBoard.jsp">
                            <c:param name="nowPage" value="${pageEnd + 1}" />
                            <c:if test="${not empty keyWord}"><c:param name="keyField" value="${keyField}" /><c:param name="keyWord" value="${keyWord}" /></c:if>
                        </c:url>
                         <a href="${nextUrl}" class="px-3 py-2 text-sm font-medium text-primary border border-gray-200 rounded">다음</a>
                    </c:if>
                </div>

                <div class="flex justify-end mt-6">
                    <a href="InfoWrite.jsp" class="bg-primary text-white px-6 py-2 rounded-lg hover:bg-primary-dark transition-colors font-medium inline-block">
                        글 작성
                    </a>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />
</body>
</html>


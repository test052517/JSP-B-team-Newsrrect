<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="beans.PostBean" %>
<%@ page import="mgr.PostMgr" %>
<%@ page import="beans.AnalysisResultBean" %>
<%@ page import="mgr.NewsAnalysisMgr" %>
<%@ page import="java.sql.*" %>
<%@ page import="mgr.DBConnectionMgr" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>글 보기 - 정보 검증 게시판 - Newsrrect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/UI/JSP/CSS/fonts.css">
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
<body class="min-h-screen">
<%
    Integer userIdObj = (Integer) session.getAttribute("userId");
    if(userIdObj == null) {
        response.sendRedirect(request.getContextPath() + "/UI/JSP/Login/Login.jsp");
        return;
    }

    String postIdStr = request.getParameter("postId");
    if(postIdStr == null || postIdStr.equals("")) {
        out.println("<script>alert('잘못된 접근입니다.'); history.back();</script>");
        return;
    }
    
    int postId = Integer.parseInt(postIdStr);
    
    PostMgr postMgr = new PostMgr();
    PostBean post = postMgr.getPost(postId);
    
    if(post == null) {
        out.println("<script>alert('게시글을 찾을 수 없습니다.'); history.back();</script>");
        return;
    }
    
    // news_analysis DB에서 분석 결과 조회
    AnalysisResultBean analysisResult = null;
    
    try {
        NewsAnalysisMgr analysisMgr = new NewsAnalysisMgr();
        
        System.out.println("=== 분석 결과 조회 시작 ===");
        System.out.println("Post ID: " + postId);
        
        // 방법 1: 게시글 내용에서 URL 추출하여 조회
        String content = post.getContent();
        System.out.println("게시글 내용 길이: " + (content != null ? content.length() : 0));
        
        if(content != null && !content.isEmpty()) {
            // URL 패턴 매칭
            java.util.regex.Pattern urlPattern = java.util.regex.Pattern.compile(
                "(https?://[^\\s<>\"]+|www\\.[^\\s<>\"]+)",
                java.util.regex.Pattern.CASE_INSENSITIVE
            );
            java.util.regex.Matcher matcher = urlPattern.matcher(content);
            if(matcher.find()) {
                String originalUrl = matcher.group(1);
                if(originalUrl.startsWith("www.")) {
                    originalUrl = "http://" + originalUrl;
                }
                System.out.println("추출된 URL: " + originalUrl);
                
                // news_analysis DB에서 URL로 분석 결과 조회
                analysisResult = analysisMgr.findByUrl(originalUrl);
                System.out.println("URL 기반 조회: " + (analysisResult != null ? "성공" : "실패"));
            } else {
                System.out.println("URL 패턴 매칭 실패 - 텍스트 분석으로 추정");
            }
        }
        
        // 방법 2: 텍스트 분석 - postId 기반 조회
        if(analysisResult == null) {
            System.out.println("텍스트 분석 결과 조회 시도 (postId 기반)...");
            String textKey = "text:postId:" + postId;
            System.out.println("검색 키: " + textKey);
            analysisResult = analysisMgr.findByUrl(textKey);
            System.out.println("postId 기반 조회(" + textKey + "): " + (analysisResult != null ? "성공" : "실패"));
        }
        
        if(analysisResult != null) {
            System.out.println("=== 최종 분석 결과 조회 성공! ===");
            System.out.println("- 신뢰도: " + analysisResult.getReliabilityScore());
            System.out.println("- 요약 길이: " + (analysisResult.getSummary() != null ? analysisResult.getSummary().length() : 0));
        } else {
            System.out.println("=== 분석 결과 없음 ===");
        }
    } catch(Exception e) {
        System.err.println("분석 결과 조회 중 오류 발생: " + e.getMessage());
        e.printStackTrace();
        analysisResult = null;
    }
    
    DBConnectionMgr pool = DBConnectionMgr.getInstance();
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    int trueCount = 0;
    int falseCount = 0;
    int ambiguousCount = 0;
    int totalJudgmentCount = 0;
    int commentCount = 0;
    double credibilityScore = 0.0;
    
    List<Map<String, Object>> comments = new ArrayList<>();
    
    try {
        conn = pool.getConnection("user");
        
        String countSql = "SELECT COUNT(*) as cnt FROM comment WHERE post_id = ? AND status = '공개'";
        pstmt = conn.prepareStatement(countSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        if(rs.next()) {
            commentCount = rs.getInt("cnt");
        }
        rs.close();
        pstmt.close();
        
        String judgmentSql = "SELECT judgment, COUNT(*) as cnt FROM comment " +
                           "WHERE post_id = ? AND status = '공개' AND judgment IS NOT NULL " +
                           "GROUP BY judgment";
        pstmt = conn.prepareStatement(judgmentSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            String judgment = rs.getString("judgment");
            int cnt = rs.getInt("cnt");
            
            if("참".equals(judgment)) {
                trueCount = cnt;
            } else if("거짓".equals(judgment)) {
                falseCount = cnt;
            } else if("모호".equals(judgment)) {
                ambiguousCount = cnt;
            }
        }
        
        totalJudgmentCount = trueCount + falseCount + ambiguousCount;
        
        if(totalJudgmentCount > 0) {
            credibilityScore = ((trueCount * 100.0) + (ambiguousCount * 50.0)) / totalJudgmentCount;
        }
        
        rs.close();
        pstmt.close();
        
        String commentSql = "SELECT c.comment_id, c.user_id, c.layer, c.parent_comment_id, c.content, " +
                          "c.judgment, c.upvotes, c.created_at, u.nickname " +
                          "FROM comment c " +
                          "JOIN user u ON c.user_id = u.user_id " +
                          "WHERE c.post_id = ? AND c.status = '공개' " +
                          "ORDER BY c.upvotes DESC, c.created_at ASC";
        pstmt = conn.prepareStatement(commentSql);
        pstmt.setInt(1, postId);
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            Map<String, Object> comment = new HashMap<>();
            comment.put("id", rs.getInt("comment_id"));
            comment.put("author", rs.getString("nickname"));
            comment.put("content", rs.getString("content"));
            comment.put("date", rs.getString("created_at"));
            comment.put("recommendations", rs.getInt("upvotes"));
            comment.put("type", rs.getString("judgment") != null ? rs.getString("judgment") : "");
            comment.put("layer", rs.getInt("layer"));
            comment.put("isReply", rs.getInt("layer") > 0);
            comment.put("isBest", rs.getInt("upvotes") >= 50);
            comments.add(comment);
        }
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        pool.freeConnection(conn, pstmt, rs);
    }
    
    double truePercent = totalJudgmentCount > 0 ? (trueCount * 100.0 / totalJudgmentCount) : 0;
    double falsePercent = totalJudgmentCount > 0 ? (falseCount * 100.0 / totalJudgmentCount) : 0;
    double ambiguousPercent = totalJudgmentCount > 0 ? (ambiguousCount * 100.0 / totalJudgmentCount) : 0;
%>

    <jsp:include page="../Common/AdminHeader.jsp" />

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-6">
            <h2 class="text-3xl font-bold text-primary mb-4">정보 검증 게시판</h2>
            <div class="border-t border-gray-200"></div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div class="p-6">
                <div class="mb-4">
                    <h1 class="text-2xl font-bold text-gray-900"><%= post.getTitle() %></h1>
                </div>

                <div class="mb-6">
                    <div class="bg-blue-100 border border-gray-200 rounded-md p-3">
                        <div class="flex items-center justify-between text-sm text-gray-600">
                            <div class="flex items-center space-x-4">
                                <div class="flex items-center space-x-1">
                                    <div class="w-3 h-3 bg-gray-600 rounded"></div>
                                    <span><%= post.getNickname() %></span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10c0 3.866-3.582 7-8 7a8.841 8.841 0 01-4.083-.98L2 17l1.338-3.123C2.493 12.767 2 11.434 2 10c0-3.866 3.582-7 8-7s8 3.134 8 7zM7 9H5v2h2V9zm8 0h-2v2h2V9zM9 9h2v2H9V9z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span><%= commentCount %></span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                    </svg>
                                    <span><%= post.getViewCount() %></span>
                                </div>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span><%= post.getCreatedAt() %></span>
                                <button onclick="openReportModal()" class="text-gray-500 hover:text-red-500 transition-colors">🚨</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- AI 분석 결과 섹션 -->
                <% if(analysisResult != null) { %>
                <div class="mb-6">
                    <div class="bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-5">
                        <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                            <svg class="w-5 h-5 mr-2 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
                            </svg>
                            AI 분석 결과
                        </h3>
                        
                        <div class="mb-4">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-sm font-medium text-gray-700">AI 신뢰도 점수</span>
                                <span class="text-2xl font-bold text-primary"><%= String.format("%.1f", analysisResult.getReliabilityScore()) %>%</span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-2">
                                <div class="<%= analysisResult.getReliabilityScore() >= 80 ? "bg-green-500" : analysisResult.getReliabilityScore() >= 60 ? "bg-yellow-500" : "bg-red-500" %> h-2 rounded-full transition-all duration-500" 
                                     style="width: <%= analysisResult.getReliabilityScore() %>%"></div>
                            </div>
                            <p class="text-xs text-gray-600 mt-1">
                                <% if(analysisResult.getReliabilityScore() >= 80) { %>
                                    높은 신뢰도 - AI가 이 정보를 신뢰할 수 있다고 판단했습니다.
                                <% } else if(analysisResult.getReliabilityScore() >= 60) { %>
                                    보통 신뢰도 - AI가 이 정보의 일부 내용에 의문을 제기했습니다.
                                <% } else { %>
                                    낮은 신뢰도 - AI가 이 정보의 신뢰성을 의심하고 있습니다.
                                <% } %>
                            </p>
                        </div>
                        
                        <% if(analysisResult.getSummary() != null && !analysisResult.getSummary().isEmpty()) { %>
                        <div class="bg-white rounded-md p-4 border border-blue-200">
                            <h4 class="text-sm font-semibold text-gray-800 mb-2 flex items-center">
                                <svg class="w-4 h-4 mr-1 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7"></path>
                                </svg>
                                요약
                            </h4>
                            <p class="text-sm text-gray-700 leading-relaxed"><%= analysisResult.getSummary() %></p>
                        </div>
                        <% } %>
                        
                        <!-- 키워드 섹션이 제거되었습니다. -->
                        
                        <div class="mt-3 text-xs text-gray-600">
                            <span class="font-medium">관련 기사:</span> <%= analysisResult.getRelatedArticlesCount() %>건 발견
                        </div>
                    </div>
                </div>
                <% } %>

                <div class="mb-6">
                    <div class="text-gray-900 leading-relaxed">
                        <p><%= post.getContent() != null ? post.getContent() : "" %></p>
                    </div>
                </div>

                <div class="mb-6">
                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-900 mb-2">신뢰도 <%= String.format("%.0f", credibilityScore) %>%</label>
                        <div class="w-full bg-gray-200 rounded-full h-2">
                            <div class="bg-primary h-2 rounded-full" style="width: <%= credibilityScore %>%"></div>
                        </div>
                    </div>
                    
                    <div class="flex justify-center space-x-8">
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-green-100 text-green-800 rounded-full">
                            <span class="text-lg font-medium">참</span>
                            <span class="text-2xl font-bold"><%= trueCount %></span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-red-100 text-red-800 rounded-full">
                            <span class="text-lg font-medium">거짓</span>
                            <span class="text-2xl font-bold"><%= falseCount %></span>
                        </div>
                        <div class="flex flex-col items-center justify-center w-28 h-28 bg-yellow-100 text-yellow-800 rounded-full">
                            <span class="text-lg font-medium">모호</span>
                            <span class="text-2xl font-bold"><%= ambiguousCount %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm border border-gray-200">
            <div class="p-6">
                <form id="commentForm" action="#" method="post" enctype="multipart/form-data">
                    <div class="mb-6">
                        <div class="mb-4">
                            <select name="commentType" class="w-32 px-3 py-2 border border-gray-200 rounded-md focus:outline-none focus:ring-2 focus:ring-primary">
                                <option>선택</option>
                                <option>참</option>
                                <option>거짓</option>
                                <option>모호</option>
                            </select>
                        </div>
                        
                        <div class="mb-4">
                             <textarea name="content" id="ir1" rows="10" cols="100" style="width:100%; height:300px; display:none;"></textarea>
                        </div>
                        
                        <div class="mb-4">
                            <div class="flex items-center space-x-2 mb-2">
                                <input type="file" id="comment-file" name="commentFile" class="hidden" multiple>
                                <button type="button" onclick="document.getElementById('comment-file').click()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                                    첨부 파일
                                </button>
                                <span id="file-name-display" class="text-sm text-gray-500">파일을 선택하세요</span>
                            </div>
                            
                            <div id="selected-files" class="hidden">
                                <div class="bg-gray-50 border border-gray-200 rounded-md p-3">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center space-x-2">
                                            <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                                            </svg>
                                            <span class="text-sm text-gray-700" id="file-name">선택된 파일 없음</span>
                                        </div>
                                        <button type="button" onclick="clearFiles()" class="text-red-500 hover:text-red-700 text-sm">삭제</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="flex justify-end">
                            <button type="button" onclick="submitContents();" class="px-6 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition-colors">
                                댓글등록
                            </button>
                        </div>
                    </div>
                </form>
                
                <div class="flex justify-between items-center mb-4">
                    <h3 class="text-lg font-semibold text-gray-900">전체 댓글 <%= comments.size() %>개</h3>
                    <div class="flex space-x-2">
                        <select class="px-3 py-1 border border-gray-200 rounded text-sm">
                            <option>추천순</option>
                            <option>최신순</option>
                            <option>등록순</option>
                        </select>
                    </div>
                </div>

                <div class="mb-8 bg-blue-100 rounded-lg p-4">
                    <h4 class="text-lg font-semibold text-gray-900 mb-4">BEST 댓글</h4>
                    <div class="space-y-4">
                    <% for(Map<String, Object> comment : comments) { 
                        if((Boolean)comment.get("isBest")) {
                            String type = (String)comment.get("type");
                            String badgeColor = "";
                            if("참".equals(type)) badgeColor = "bg-green-100 text-green-800";
                            else if("거짓".equals(type)) badgeColor = "bg-red-100 text-red-800";
                            else if("모호".equals(type)) badgeColor = "bg-yellow-100 text-yellow-800";
                    %>
                    <div class="border border-gray-200 rounded-lg p-4 bg-white">
                        <div class="flex justify-between items-start mb-2">
                            <div class="flex items-center space-x-2">
                                <span class="font-semibold text-primary">BEST <%= comment.get("author") %></span>
                                <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                            </div>
                            <div class="flex items-center space-x-2">
                                <span class="text-sm text-gray-500"><%= comment.get("date") %></span>
                                <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                                <% if(!"".equals(type)) { %>
                                <span class="px-2 py-1 <%= badgeColor %> rounded text-sm"><%= type %></span>
                                <% } %>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <p class="text-gray-900"><%= comment.get("content") %></p>
                            <div id="attached-files-comment<%= comment.get("id") %>" class="hidden mt-2"></div>
                        </div>
                        
                        <div class="flex items-center space-x-4 text-sm">
                            <button type="button" class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                </svg>
                                <span>추천 <%= comment.get("recommendations") %></span>
                            </button>
                            <button type="button" class="text-gray-600 hover:text-primary">답글쓰기</button>
                            <input type="file" id="file-comment<%= comment.get("id") %>" class="hidden" multiple>
                            <button type="button" onclick="document.getElementById('file-comment<%= comment.get("id") %>').click()" class="text-gray-600 hover:text-primary">첨부파일</button>
                        </div>
                        
                        <div id="selected-files-comment<%= comment.get("id") %>" class="hidden mt-3 p-3 bg-gray-50 rounded-md">
                            <div class="bg-white border border-gray-200 rounded-md p-2">
                                <div id="file-list-comment<%= comment.get("id") %>" class="space-y-1"></div>
                            </div>
                        </div>
                    </div>
                    <% }} %>
                    </div>
                </div>

                <div>
                    <div class="space-y-4">
                    <% for(Map<String, Object> comment : comments) { 
                         if(!(Boolean)comment.get("isBest")) {
                            boolean isReply = (Boolean)comment.get("isReply");
                            String type = (String)comment.get("type");
                            String badgeColor = "";
                            if("참".equals(type)) badgeColor = "bg-green-100 text-green-800";
                            else if("거짓".equals(type)) badgeColor = "bg-red-100 text-red-800";
                            else if("모호".equals(type)) badgeColor = "bg-yellow-100 text-yellow-800";
                    %>
                    <div class="<%= isReply ? "ml-6" : "" %>">
                        <div class="border border-gray-200 rounded-lg p-4 bg-white">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex items-center space-x-2">
                                    <% if(isReply) { %><span class="text-gray-500">→</span><% } %>
                                    <span class="font-semibold"><%= comment.get("author") %></span>
                                    <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                </div>
                                <div class="flex items-center space-x-2">
                                    <span class="text-sm text-gray-500"><%= comment.get("date") %></span>
                                    <span class="text-gray-500 cursor-pointer" onclick="openCommentReportModal()">🚨</span>
                                    <% if(!"".equals(type)) { %>
                                        <span class="px-2 py-1 <%= badgeColor %> rounded text-sm"><%= type %></span>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <p class="text-gray-900 mb-2"><%= comment.get("content") %></p>
                                <div id="attached-files-comment<%= comment.get("id") %>" class="hidden mt-2"></div>
                            </div>
                            
                            <div class="flex items-center space-x-4 text-sm">
                                <button type="button" class="flex items-center space-x-1 text-gray-600 hover:text-red-500">
                                    <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd"></path>
                                    </svg>
                                    <span>추천 <%= comment.get("recommendations") %></span>
                                </button>
                                <button type="button" class="text-gray-600 hover:text-primary">답글쓰기</button>
                                <input type="file" id="file-comment<%= comment.get("id") %>" class="hidden" multiple>
                                <button type="button" onclick="document.getElementById('file-comment<%= comment.get("id") %>').click()" class="text-gray-600 hover:text-primary">첨부파일</button>
                            </div>
                            
                            <div id="selected-files-comment<%= comment.get("id") %>" class="hidden mt-3 p-3 bg-gray-50 rounded-md">
                                <div class="bg-white border border-gray-200 rounded-md p-2">
                                    <div id="file-list-comment<%= comment.get("id") %>" class="space-y-1"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% }} %>
                    </div>
                </div>

                <div class="flex justify-center items-center mt-6 space-x-2">
                    <div class="flex space-x-1">
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[1]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[2]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[3]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[4]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[5]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[6]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[7]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[8]</button>
                        <button class="px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">[9]</button>
                        <span class="px-2 text-gray-400">....</span>
                    </div>
                    <button class="ml-4 px-3 py-2 text-sm font-medium text-primary hover:text-white hover:bg-primary border border-gray-200 rounded transition-all duration-300 ease-in-out hover:scale-105 hover:shadow-md">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="../Common/Footer.jsp" />

    <div id="reportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-lg w-full max-w-md">
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">신고하기</h3>
                    <div class="border-b border-gray-200 mb-4"></div>
                </div>
                
                <div class="p-6">
                    <p class="text-gray-900 mb-4">해당 게시글을 아래와 같은 사유로 신고합니다.</p>
                    
                    <div class="mb-4">
                        <div class="bg-gray-100 border border-gray-200 rounded-md p-3 mb-2">
                            <div class="flex justify-between">
                                <span class="text-gray-900"><%= post.getTitle() %></span>
                                <span class="text-gray-900"><%= post.getNickname() %></span>
                            </div>
                        </div>
                        <div class="bg-gray-100 border border-gray-200 rounded-md p-3">
                            <span class="text-gray-900"><%= post.getContent() != null && post.getContent().length() > 50 ? post.getContent().substring(0, 50) + "..." : post.getContent() %></span>
                        </div>
                    </div>
                    
                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-900 mb-2">신고사유</label>
                        <textarea class="w-full bg-gray-100 border border-gray-200 rounded-md p-3 text-gray-900" rows="3" placeholder="신고 사유를 입력해주세요"></textarea>
                    </div>
                    
                    <div class="flex justify-end space-x-3">
                        <button onclick="closeReportModal()" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 transition-colors">
                            취소
                        </button>
                        <button onclick="submitReport()" class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors">
                            신고
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="commentReportModal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <div class="p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-2">신고하기</h3>
                    <div class="border-b border-gray-200 mb-4"></div>
                    <p class="text-sm text-gray-600 mb-4">해당 댓글을 아래와 같은 사유로 신고합니다.</p>
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">작성자</label>
                        <div class="bg-gray-100 p-3 rounded text-gray-600">작성자</div>
                    </div>
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">댓글 내용</label>
                        <div class="bg-gray-100 p-3 rounded text-gray-600">댓글 내용</div>
                    </div>
                    
                    <div class="mb-6">
                        <label class="block text-sm font-medium text-gray-700 mb-2">신고사유</label>
                        <textarea class="w-full bg-gray-100 p-3 rounded text-gray-600 border border-gray-200" rows="3" placeholder="신고 사유를 입력해주세요"></textarea>
                    </div>
                    
                    <div class="flex justify-end space-x-3">
                        <button onclick="closeCommentReportModal()" class="px-4 py-2 text-gray-600 bg-gray-200 rounded-md hover:bg-gray-300">취소</button>
                        <button onclick="submitCommentReport()" class="px-4 py-2 text-white bg-red-600 rounded-md hover:bg-red-700">신고</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        var oEditors = [];

        nhn.husky.EZCreator.createInIFrame({
            oAppRef: oEditors,
            elPlaceHolder: "ir1",
            sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html",	
            htParams : {
                bUseToolbar : true,
                bUseVerticalResizer : true,
                bUseModeChanger : true,
            },
            fCreator: "createSEditor2"
        });

        function submitContents() {
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            var form = document.getElementById("commentForm");

            if(form.content.value == "<p>&nbsp;</p>" || form.content.value == "") {
                alert("내용을 입력해주세요.");
                oEditors.getById["ir1"].exec("FOCUS");
                return;
            }

            try {
                form.submit();
            } catch(e) {}
        }

        document.getElementById('comment-file').addEventListener('change', function(e) {
            const files = e.target.files;
            const selectedFilesDiv = document.getElementById('selected-files');
            const fileNameSpan = document.getElementById('file-name');
            const fileNameDisplay = document.getElementById('file-name-display');
            
            if (files.length > 0) {
                selectedFilesDiv.classList.remove('hidden');
                fileNameDisplay.classList.add('hidden');
                if (files.length === 1) {
                    fileNameSpan.textContent = files[0].name;
                } else {
                    fileNameSpan.textContent = files.length + '개 파일 선택됨';
                }
            } else {
                selectedFilesDiv.classList.add('hidden');
                fileNameDisplay.classList.remove('hidden');
            }
        });

        function clearFiles() {
            document.getElementById('comment-file').value = '';
            document.getElementById('selected-files').classList.add('hidden');
            document.getElementById('file-name-display').classList.remove('hidden');
        }

        function openReportModal() {
            document.getElementById('reportModal').classList.remove('hidden');
        }

        function closeReportModal() {
            document.getElementById('reportModal').classList.add('hidden');
        }

        function submitReport() {
            alert('신고가 접수되었습니다.');
            closeReportModal();
        }

        function openCommentReportModal() {
            document.getElementById('commentReportModal').classList.remove('hidden');
        }

        function closeCommentReportModal() {
            document.getElementById('commentReportModal').classList.add('hidden');
        }

        function submitCommentReport() {
            alert('댓글 신고가 접수되었습니다.');
            closeCommentReportModal();
        }

        document.getElementById('reportModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeReportModal();
            }
        });

        document.getElementById('commentReportModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeCommentReportModal();
            }
        });

        function setupFileUpload(commentId) {
            const fileInput = document.getElementById('file-comment' + commentId);
            if (!fileInput) return;

            const selectedFilesDiv = document.getElementById('selected-files-comment' + commentId);
            const fileList = document.getElementById('file-list-comment' + commentId);
            const attachedFilesDiv = document.getElementById('attached-files-comment' + commentId);

            fileInput.addEventListener('change', function(e) {
                const files = e.target.files;
                
                if (files.length > 0) {
                    selectedFilesDiv.classList.remove('hidden');
                    fileList.innerHTML = '';
                    
                    if (attachedFilesDiv) {
                        const imageFiles = Array.from(files).filter(file => file.type.startsWith('image/'));
                        if (imageFiles.length > 0) {
                            attachedFilesDiv.classList.remove('hidden');
                            const reader = new FileReader();
                            reader.onload = function(e) {
                                attachedFilesDiv.innerHTML = '<img src="' + e.target.result + '" alt="' + imageFiles[0].name + '" class="max-w-full h-auto rounded-lg border border-gray-200" style="max-height: 200px;">';
                            };
                            reader.readAsDataURL(imageFiles[0]);
                        } else {
                            attachedFilesDiv.classList.add('hidden');
                        }
                    }
                    
                    Array.from(files).forEach(function(file, index) {
                        const fileItem = document.createElement('div');
                        fileItem.className = 'flex items-center p-2 bg-white rounded border';
                        fileItem.innerHTML = 
                            '<div class="flex items-center space-x-2">' +
                                '<svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>' +
                                '<span class="text-sm text-gray-700">' + file.name + '</span>' +
                                '<span class="text-xs text-gray-500">(' + (file.size / 1024).toFixed(1) + 'KB)</span>' +
                            '</div>';
                        fileList.appendChild(fileItem);
                    });
                } else {
                    selectedFilesDiv.classList.add('hidden');
                    if (attachedFilesDiv) {
                        attachedFilesDiv.classList.add('hidden');
                    }
                }
            });
        }

        document.addEventListener('DOMContentLoaded', function() {
            <% for(Map<String, Object> comment : comments) { %>
            setupFileUpload(<%= comment.get("id") %>);
            <% } %>
        });
    </script>
</body>
</html>


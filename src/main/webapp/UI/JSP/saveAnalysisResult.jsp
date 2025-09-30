<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%@ page import="mgr.NewsAnalysisMgr" %>
<%@ page import="beans.AnalysisResultBean" %>
<%@ page import="java.io.BufferedReader" %>
<%
    response.setContentType("application/json;charset=UTF-8");
    
    try {
        // JSON 데이터 읽기
        StringBuilder sb = new StringBuilder();
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        
        String jsonString = sb.toString();
        System.out.println("받은 JSON 데이터: " + jsonString);
        
        // 수동 JSON 파싱
        String originalUrl = extractJsonValue(jsonString, "originalUrl");
        String keywords = extractJsonValue(jsonString, "keywords");
        String summary = extractJsonValue(jsonString, "summary");
        String analysisDetails = extractJsonValue(jsonString, "analysisDetails");
        
        int relatedArticlesCount = 0;
        double reliabilityScore = 0.0;
        int processingTime = 0;
        
        try {
            String articlesCountStr = extractJsonValue(jsonString, "relatedArticlesCount");
            if(articlesCountStr != null && !articlesCountStr.isEmpty()) {
                relatedArticlesCount = Integer.parseInt(articlesCountStr);
            }
        } catch(Exception e) {
            System.err.println("relatedArticlesCount 파싱 오류: " + e.getMessage());
        }
        
        try {
            String scoreStr = extractJsonValue(jsonString, "reliabilityScore");
            if(scoreStr != null && !scoreStr.isEmpty()) {
                reliabilityScore = Double.parseDouble(scoreStr);
            }
        } catch(Exception e) {
            System.err.println("reliabilityScore 파싱 오류: " + e.getMessage());
        }
        
        try {
            String timeStr = extractJsonValue(jsonString, "processingTime");
            if(timeStr != null && !timeStr.isEmpty()) {
                processingTime = Integer.parseInt(timeStr);
            }
        } catch(Exception e) {
            System.err.println("processingTime 파싱 오류: " + e.getMessage());
        }
        
        // AnalysisResultBean 생성
        AnalysisResultBean analysisResult = new AnalysisResultBean();
        analysisResult.setOriginalUrl(originalUrl);
        analysisResult.setExtractedKeywords(keywords);
        analysisResult.setRelatedArticlesCount(relatedArticlesCount);
        analysisResult.setSummary(summary);
        analysisResult.setReliabilityScore(reliabilityScore);
        analysisResult.setAnalysisDetails(analysisDetails);
        analysisResult.setProcessingTime(processingTime);
        
        // DB 저장
        NewsAnalysisMgr analysisMgr = new NewsAnalysisMgr();
        int analysisId = analysisMgr.saveAnalysisResult(analysisResult);
        
        System.out.println("분석 결과 저장 성공 - ID: " + analysisId + ", URL: " + originalUrl);
        
        // 성공 응답
        out.print("{\"success\":true,\"analysisId\":" + analysisId + "}");
        
    } catch(Exception e) {
        System.err.println("분석 결과 저장 실패: " + e.getMessage());
        e.printStackTrace();
        
        out.print("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
    }
%>

<%!
    // JSON에서 값 추출하는 헬퍼 메소드
    private String extractJsonValue(String json, String key) {
        try {
            String searchKey = "\"" + key + "\"";
            int keyIndex = json.indexOf(searchKey);
            if(keyIndex == -1) return null;
            
            int colonIndex = json.indexOf(":", keyIndex);
            if(colonIndex == -1) return null;
            
            // 값의 시작 찾기
            int valueStart = colonIndex + 1;
            while(valueStart < json.length() && (json.charAt(valueStart) == ' ' || json.charAt(valueStart) == '\t')) {
                valueStart++;
            }
            
            if(valueStart >= json.length()) return null;
            
            // 문자열 값인 경우
            if(json.charAt(valueStart) == '"') {
                int valueEnd = valueStart + 1;
                while(valueEnd < json.length()) {
                    if(json.charAt(valueEnd) == '"' && json.charAt(valueEnd - 1) != '\\') {
                        return json.substring(valueStart + 1, valueEnd);
                    }
                    valueEnd++;
                }
            } 
            // 숫자 값인 경우
            else {
                int valueEnd = valueStart;
                while(valueEnd < json.length() && 
                      json.charAt(valueEnd) != ',' && 
                      json.charAt(valueEnd) != '}' && 
                      json.charAt(valueEnd) != ']') {
                    valueEnd++;
                }
                return json.substring(valueStart, valueEnd).trim();
            }
        } catch(Exception e) {
            System.err.println("JSON 파싱 오류 (key=" + key + "): " + e.getMessage());
        }
        return null;
    }
    
    // JSON 문자열 이스케이프
    private String escapeJson(String str) {
        if(str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
%>
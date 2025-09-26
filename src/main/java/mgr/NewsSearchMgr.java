package mgr;

import beans.NewsArticleBean;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.*;
import java.util.regex.Pattern;

/**
 * 네이버 뉴스 API를 통한 뉴스 검색 Manager
 */
public class NewsSearchMgr {
    
    private final String CLIENT_ID = "0DqSka16EfKk0If8DuuH";
    private final String CLIENT_SECRET = "x92TmUhBE8";
    private final String API_URL = "https://openapi.naver.com/v1/search/news.json";
    private final int REQUEST_TIMEOUT = 10000;
    
    /**
     * 키워드로 관련 뉴스 검색
     */
    public List<NewsArticleBean> searchRelatedNews(List<String> keywords, int maxCount) {
        try {
            System.out.println("네이버 뉴스 검색 시작: " + keywords);
            
            // 검색 쿼리 생성
            String query = buildSearchQuery(keywords);
            if (query.isEmpty()) {
                System.err.println("검색 쿼리 생성 실패");
                return new ArrayList<>();
            }
            
            // API 호출
            String jsonResponse = callNaverNewsAPI(query, maxCount);
            if (jsonResponse == null) {
                System.err.println("네이버 API 호출 실패");
                return new ArrayList<>();
            }
            
            // JSON 파싱 및 뉴스 기사 변환
            List<NewsArticleBean> articles = parseNewsResponse(jsonResponse, keywords);
            
            // 관련성으로 정렬
            articles = rankArticlesByRelevance(articles, keywords);
            
            System.out.println("뉴스 검색 완료: " + articles.size() + "건");
            return articles;
            
        } catch (Exception e) {
            System.err.println("뉴스 검색 오류: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    /**
     * 검색 쿼리 생성
     */
    private String buildSearchQuery(List<String> keywords) {
        if (keywords == null || keywords.isEmpty()) {
            return "";
        }
        
        // 상위 3개 키워드만 사용하여 쿼리 생성
        List<String> topKeywords = keywords.subList(0, Math.min(3, keywords.size()));
        
        StringBuilder query = new StringBuilder();
        for (int i = 0; i < topKeywords.size(); i++) {
            if (i > 0) query.append(" ");
            query.append(topKeywords.get(i));
        }
        
        return query.toString();
    }
    
    /**
     * 네이버 뉴스 API 호출
     */
    private String callNaverNewsAPI(String query, int count) {
        try {
            // URL 인코딩
            String encodedQuery = URLEncoder.encode(query, "UTF-8");
            String apiUrl = API_URL + "?query=" + encodedQuery + "&display=" + Math.min(count, 100) + "&sort=sim";
            
            // HTTP 연결 설정
            URL url = new URL(apiUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("X-Naver-Client-Id", CLIENT_ID);
            connection.setRequestProperty("X-Naver-Client-Secret", CLIENT_SECRET);
            connection.setConnectTimeout(REQUEST_TIMEOUT);
            connection.setReadTimeout(REQUEST_TIMEOUT);
            
            // 응답 코드 확인
            int responseCode = connection.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK) {
                System.err.println("네이버 API 오류 코드: " + responseCode);
                
                // 오류 메시지 읽기
                try (BufferedReader errorReader = new BufferedReader(
                        new InputStreamReader(connection.getErrorStream(), "UTF-8"))) {
                    String errorLine;
                    while ((errorLine = errorReader.readLine()) != null) {
                        System.err.println("API 오류: " + errorLine);
                    }
                }
                return null;
            }
            
            // 응답 읽기
            StringBuilder response = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(connection.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
            }
            
            return response.toString();
            
        } catch (Exception e) {
            System.err.println("네이버 API 호출 오류: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * JSON 응답을 뉴스 기사 리스트로 변환
     */
    private List<NewsArticleBean> parseNewsResponse(String jsonResponse, List<String> keywords) {
        List<NewsArticleBean> articles = new ArrayList<>();
        
        try {
            JsonObject jsonObject = JsonParser.parseString(jsonResponse).getAsJsonObject();
            JsonArray items = jsonObject.getAsJsonArray("items");
            
            if (items == null) {
                System.err.println("검색 결과가 없습니다.");
                return articles;
            }
            
            String keywordsStr = String.join(",", keywords);
            
            for (JsonElement item : items) {
                JsonObject newsItem = item.getAsJsonObject();
                
                try {
                    NewsArticleBean article = new NewsArticleBean();
                    
                    // 제목과 내용에서 HTML 태그 제거
                    String title = cleanHtmlTags(getJsonString(newsItem, "title"));
                    String description = cleanHtmlTags(getJsonString(newsItem, "description"));
                    
                    article.setTitle(title);
                    article.setContent(description);
                    article.setUrl(getJsonString(newsItem, "originallink"));
                    article.setPublishedDate(parseDate(getJsonString(newsItem, "pubDate")));
                    article.setSource(cleanHtmlTags(getJsonString(newsItem, "bloggername")));
                    article.setKeywords(keywordsStr);
                    
                    // 유효한 기사만 추가
                    if (!title.isEmpty() && !description.isEmpty()) {
                        articles.add(article);
                    }
                    
                } catch (Exception e) {
                    System.err.println("개별 뉴스 파싱 오류: " + e.getMessage());
                    continue;
                }
            }
            
        } catch (Exception e) {
            System.err.println("JSON 파싱 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        return articles;
    }
    
    /**
     * JSON 객체에서 문자열 값 안전하게 가져오기
     */
    private String getJsonString(JsonObject obj, String key) {
        JsonElement element = obj.get(key);
        return (element != null && !element.isJsonNull()) ? element.getAsString() : "";
    }
    
    /**
     * HTML 태그 및 특수문자 정리
     */
    private String cleanHtmlTags(String text) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        
        // HTML 태그 제거
        text = text.replaceAll("<[^>]*>", "");
        
        // HTML 엔티티 디코딩
        text = text.replace("&lt;", "<")
                  .replace("&gt;", ">")
                  .replace("&amp;", "&")
                  .replace("&quot;", "\"")
                  .replace("&#39;", "'")
                  .replace("&nbsp;", " ");
        
        // 연속된 공백 정리
        text = text.replaceAll("\\s+", " ");
        
        return text.trim();
    }
    
    /**
     * 날짜 문자열 파싱
     */
    private String parseDate(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) {
            return "";
        }
        
        try {
            // RFC 2822 형식 파싱 시도 (예: "Tue, 19 Dec 2023 09:00:00 +0900")
            java.text.SimpleDateFormat inputFormat = new java.text.SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss Z", Locale.ENGLISH);
            java.text.SimpleDateFormat outputFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            
            Date date = inputFormat.parse(dateStr);
            return outputFormat.format(date);
            
        } catch (Exception e) {
            // 파싱 실패시 원본 반환
            return dateStr;
        }
    }
    
    /**
     * 키워드 관련성으로 기사 순위 매기기
     */
    private List<NewsArticleBean> rankArticlesByRelevance(List<NewsArticleBean> articles, List<String> keywords) {
        for (NewsArticleBean article : articles) {
            int relevanceScore = 0;
            String title = article.getTitle().toLowerCase();
            String content = article.getContent().toLowerCase();
            
            for (String keyword : keywords) {
                String keywordLower = keyword.toLowerCase();
                
                // 제목에 키워드 포함시 높은 점수
                if (title.contains(keywordLower)) {
                    relevanceScore += 3;
                }
                
                // 내용에 키워드 포함시 낮은 점수
                if (content.contains(keywordLower)) {
                    relevanceScore += 1;
                }
            }
            
            // 출처가 있으면 가산점
            if (article.getSource() != null && !article.getSource().isEmpty()) {
                relevanceScore += 1;
            }
            
            // relevanceScore는 별도 필드가 없으므로 viewCount에 임시 저장
            article.setViewCount(relevanceScore);
        }
        
        // 관련성 점수로 정렬 (내림차순)
        articles.sort((a, b) -> Integer.compare(b.getViewCount(), a.getViewCount()));
        
        return articles;
    }
}
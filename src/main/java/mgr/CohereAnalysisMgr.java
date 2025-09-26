package mgr;

import beans.NewsArticleBean;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonArray;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

/**
 * Cohere API를 사용한 고급 텍스트 분석 Manager
 */
public class CohereAnalysisMgr {
    
    private String COHERE_API_KEY;
    private final String COHERE_BASE_URL = "https://api.cohere.ai/v1";
    private final int REQUEST_TIMEOUT = 30000; // 30초
    
    public CohereAnalysisMgr() {
        loadApiConfig();
    }
    
    /**
     * API 설정을 properties 파일에서 로드
     */
    private void loadApiConfig() {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("config.properties")) {
            Properties prop = new Properties();
            if (input != null) {
                prop.load(input);
                COHERE_API_KEY = prop.getProperty("cohere.api.key");
            }
            
            if (COHERE_API_KEY == null || COHERE_API_KEY.trim().isEmpty()) {
                System.err.println("Cohere API 키가 설정되지 않았습니다. config.properties에 cohere.api.key를 추가하세요.");
                COHERE_API_KEY = "YOUR_COHERE_API_KEY";
            }
            
        } catch (Exception e) {
            System.err.println("API 설정 로드 실패: " + e.getMessage());
            COHERE_API_KEY = "YOUR_COHERE_API_KEY";
        }
    }
    
    /**
     * API 키를 직접 설정하는 메소드
     */
    public void setApiKey(String apiKey) {
        this.COHERE_API_KEY = apiKey;
    }
    
    /**
     * 뉴스 기사들을 종합하여 고급 요약 생성
     */
    public String generateAdvancedSummary(String originalUrl, List<String> keywords, List<NewsArticleBean> articles) {
        if ("59qrJhWKhPGA9WcMvFYGdHiA5YCIpIqORC23TwZx".equals(COHERE_API_KEY)) {
            return generateFallbackSummary(keywords, articles);
        }
        
        try {
            StringBuilder prompt = new StringBuilder();
            prompt.append("다음은 뉴스 기사 분석 요청입니다:\n\n");
            prompt.append("분석 대상 URL: ").append(originalUrl).append("\n");
            prompt.append("추출된 키워드: ").append(String.join(", ", keywords)).append("\n\n");
            prompt.append("관련 기사들:\n");
            
            int maxArticles = Math.min(articles.size(), 5); // 최대 5개 기사만 사용
            for (int i = 0; i < maxArticles; i++) {
                NewsArticleBean article = articles.get(i);
                prompt.append(String.format("%d. 제목: %s\n", i + 1, article.getTitle()));
                prompt.append(String.format("   내용: %s\n", 
                    article.getContent().length() > 200 ? 
                    article.getContent().substring(0, 200) + "..." : 
                    article.getContent()));
                prompt.append(String.format("   출처: %s\n\n", article.getSource()));
            }
            
            prompt.append("위 정보를 바탕으로 다음 형식으로 분석해주세요:\n");
            prompt.append("1. 주요 내용 요약 (3-4문장)\n");
            prompt.append("2. 신뢰성 평가 (관련 기사 수, 출처 다양성 고려)\n");
            prompt.append("3. 주요 이슈 및 관점\n");
            prompt.append("4. 결론 및 권장사항");
            
            String response = callCohereGenerate(prompt.toString());
            return response != null ? response : generateFallbackSummary(keywords, articles);
            
        } catch (Exception e) {
            System.err.println("Cohere 요약 생성 실패: " + e.getMessage());
            return generateFallbackSummary(keywords, articles);
        }
    }
    
    /**
     * 감정 분석 수행
     */
    public String performSentimentAnalysis(List<NewsArticleBean> articles) {
        if ("59qrJhWKhPGA9WcMvFYGdHiA5YCIpIqORC23TwZx".equals(COHERE_API_KEY)) {
            return performFallbackSentimentAnalysis(articles);
        }
        
        try {
            StringBuilder textToAnalyze = new StringBuilder();
            int maxArticles = Math.min(articles.size(), 3);
            
            for (int i = 0; i < maxArticles; i++) {
                NewsArticleBean article = articles.get(i);
                textToAnalyze.append(article.getTitle()).append(". ");
                textToAnalyze.append(article.getContent()).append(" ");
            }
            
            String text = textToAnalyze.toString();
            if (text.length() > 2000) {
                text = text.substring(0, 2000);
            }
            
            String sentiment = callCohereClassify(text);
            return sentiment != null ? sentiment : performFallbackSentimentAnalysis(articles);
            
        } catch (Exception e) {
            System.err.println("Cohere 감정 분석 실패: " + e.getMessage());
            return performFallbackSentimentAnalysis(articles);
        }
    }
    
    /**
     * 키워드 추출 및 개선
     */
    public List<String> extractEnhancedKeywords(String content, List<String> existingKeywords) {
        if ("59qrJhWKhPGA9WcMvFYGdHiA5YCIpIqORC23TwZx".equals(COHERE_API_KEY)) {
            return existingKeywords; // 기존 키워드 반환
        }
        
        try {
            StringBuilder prompt = new StringBuilder();
            prompt.append("다음 텍스트에서 가장 중요한 키워드 8개를 추출해주세요:\n\n");
            prompt.append(content.length() > 1500 ? content.substring(0, 1500) + "..." : content);
            prompt.append("\n\n기존 키워드: ").append(String.join(", ", existingKeywords));
            prompt.append("\n\n응답 형식: 키워드1, 키워드2, 키워드3, ...");
            
            String response = callCohereGenerate(prompt.toString());
            if (response != null) {
                String[] newKeywords = response.replaceAll("[^가-힣a-zA-Z,\\s]", "")
                                               .split(",");
                List<String> enhancedKeywords = new ArrayList<>();
                for (String keyword : newKeywords) {
                    String cleaned = keyword.trim();
                    if (!cleaned.isEmpty() && cleaned.length() > 1) {
                        enhancedKeywords.add(cleaned);
                    }
                }
                return enhancedKeywords.isEmpty() ? existingKeywords : enhancedKeywords;
            }
            
        } catch (Exception e) {
            System.err.println("Cohere 키워드 추출 실패: " + e.getMessage());
        }
        
        return existingKeywords;
    }
    
    /**
     * 신뢰도 분석
     */
    public double analyzeCredibility(String originalUrl, List<NewsArticleBean> articles) {
        if ("59qrJhWKhPGA9WcMvFYGdHiA5YCIpIqORC23TwZx".equals(COHERE_API_KEY)) {
            return calculateBasicCredibility(articles);
        }
        
        try {
            StringBuilder prompt = new StringBuilder();
            prompt.append("다음 뉴스 기사의 신뢰도를 0-100점으로 평가해주세요:\n\n");
            prompt.append("원본 URL: ").append(originalUrl).append("\n");
            prompt.append("관련 기사 수: ").append(articles.size()).append("개\n\n");
            
            // 출처 분석
            Set<String> sources = new HashSet<>();
            for (NewsArticleBean article : articles) {
                if (article.getSource() != null && !article.getSource().trim().isEmpty()) {
                    sources.add(article.getSource());
                }
            }
            prompt.append("관련 기사 출처: ").append(String.join(", ", sources)).append("\n\n");
            
            // 상위 3개 기사 내용
            int maxArticles = Math.min(articles.size(), 3);
            for (int i = 0; i < maxArticles; i++) {
                NewsArticleBean article = articles.get(i);
                prompt.append(String.format("관련기사 %d: %s\n", i + 1, article.getTitle()));
            }
            
            prompt.append("\n평가 기준:\n");
            prompt.append("- 관련 기사 수 (많을수록 높은 점수)\n");
            prompt.append("- 출처 다양성 (다양한 언론사일수록 높은 점수)\n");
            prompt.append("- 내용 일관성\n");
            prompt.append("응답: 점수만 숫자로 (예: 75)");
            
            String response = callCohereGenerate(prompt.toString());
            if (response != null) {
                try {
                    String scoreStr = response.replaceAll("[^0-9.]", "");
                    double score = Double.parseDouble(scoreStr);
                    return Math.max(0, Math.min(100, score)); // 0-100 범위로 제한
                } catch (NumberFormatException e) {
                    System.err.println("신뢰도 점수 파싱 실패: " + response);
                }
            }
            
        } catch (Exception e) {
            System.err.println("Cohere 신뢰도 분석 실패: " + e.getMessage());
        }
        
        return calculateBasicCredibility(articles);
    }
    
    /**
     * Cohere Generate API 호출
     */
    private String callCohereGenerate(String prompt) {
        try {
            URL url = new URL(COHERE_BASE_URL + "/generate");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Authorization", "Bearer " + COHERE_API_KEY);
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setDoOutput(true);
            connection.setConnectTimeout(REQUEST_TIMEOUT);
            connection.setReadTimeout(REQUEST_TIMEOUT);
            
            // 요청 바디 구성
            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("model", "command-light");
            requestBody.addProperty("prompt", prompt);
            requestBody.addProperty("max_tokens", 500);
            requestBody.addProperty("temperature", 0.3);
            requestBody.addProperty("k", 0);
            JsonArray stopSequences = new JsonArray();
            requestBody.add("stop_sequences", stopSequences);
            requestBody.addProperty("return_likelihoods", "NONE");
            
            try (OutputStreamWriter writer = new OutputStreamWriter(connection.getOutputStream(), "UTF-8")) {
                writer.write(requestBody.toString());
                writer.flush();
            }
            
            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(connection.getInputStream(), "UTF-8"))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                    
                    JsonObject responseJson = JsonParser.parseString(response.toString()).getAsJsonObject();
                    JsonArray generations = responseJson.getAsJsonArray("generations");
                    if (generations.size() > 0) {
                        return generations.get(0).getAsJsonObject().get("text").getAsString().trim();
                    }
                }
            } else {
                System.err.println("Cohere API 오류: " + responseCode);
                try (BufferedReader errorReader = new BufferedReader(
                        new InputStreamReader(connection.getErrorStream(), "UTF-8"))) {
                    String errorLine;
                    while ((errorLine = errorReader.readLine()) != null) {
                        System.err.println("오류 내용: " + errorLine);
                    }
                }
            }
            
        } catch (Exception e) {
            System.err.println("Cohere Generate API 호출 실패: " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Cohere Classify API 호출 (감정 분석)
     */
    private String callCohereClassify(String text) {
        try {
            URL url = new URL(COHERE_BASE_URL + "/classify");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Authorization", "Bearer " + COHERE_API_KEY);
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setDoOutput(true);
            connection.setConnectTimeout(REQUEST_TIMEOUT);
            connection.setReadTimeout(REQUEST_TIMEOUT);
            
            // 감정 분석용 예제 데이터 (간단한 분류)
            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("model", "embed-multilingual-v2.0");
            
            JsonArray inputs = new JsonArray();
            inputs.add(text);
            requestBody.add("inputs", inputs);
            
            JsonArray examples = new JsonArray();
            
            // 긍정 예제
            JsonObject pos1 = new JsonObject();
            pos1.addProperty("text", "좋은 소식이다 성공적으로 진행되고 있다");
            pos1.addProperty("label", "긍정");
            examples.add(pos1);
            
            JsonObject pos2 = new JsonObject();
            pos2.addProperty("text", "발전하고 개선되어 증가했다");
            pos2.addProperty("label", "긍정");
            examples.add(pos2);
            
            // 부정 예제
            JsonObject neg1 = new JsonObject();
            neg1.addProperty("text", "문제가 발생했다 실패했다 감소했다");
            neg1.addProperty("label", "부정");
            examples.add(neg1);
            
            JsonObject neg2 = new JsonObject();
            neg2.addProperty("text", "사고가 났다 하락했다 문제가 있다");
            neg2.addProperty("label", "부정");
            examples.add(neg2);
            
            // 중립 예제
            JsonObject neu1 = new JsonObject();
            neu1.addProperty("text", "회의가 열렸다 발표했다 진행되고 있다");
            neu1.addProperty("label", "중립");
            examples.add(neu1);
            
            requestBody.add("examples", examples);
            
            try (OutputStreamWriter writer = new OutputStreamWriter(connection.getOutputStream(), "UTF-8")) {
                writer.write(requestBody.toString());
                writer.flush();
            }
            
            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(connection.getInputStream(), "UTF-8"))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                    
                    JsonObject responseJson = JsonParser.parseString(response.toString()).getAsJsonObject();
                    JsonArray classifications = responseJson.getAsJsonArray("classifications");
                    if (classifications.size() > 0) {
                        String prediction = classifications.get(0).getAsJsonObject()
                                          .get("prediction").getAsString();
                        return prediction;
                    }
                }
            }
            
        } catch (Exception e) {
            System.err.println("Cohere Classify API 호출 실패: " + e.getMessage());
        }
        
        return null;
    }
    
    // Fallback 메소드들 (API 키가 없을 때 사용)
    private String generateFallbackSummary(List<String> keywords, List<NewsArticleBean> articles) {
        StringBuilder summary = new StringBuilder();
        summary.append("주요 키워드: ").append(String.join(", ", keywords)).append("\n\n");
        summary.append("관련 기사 ").append(articles.size()).append("건을 분석한 결과:\n");
        
        if (articles.size() > 0) {
            summary.append("주요 관련 기사:\n");
            int count = Math.min(3, articles.size());
            for (int i = 0; i < count; i++) {
                summary.append("- ").append(articles.get(i).getTitle()).append("\n");
            }
        }
        
        return summary.toString();
    }
    
    private String performFallbackSentimentAnalysis(List<NewsArticleBean> articles) {
        if (articles.isEmpty()) return "중립";
        
        String[] positiveWords = {"발전", "성공", "개선", "증가", "상승", "좋은", "긍정"};
        String[] negativeWords = {"사고", "문제", "실패", "감소", "하락", "나쁜", "부정"};
        
        int positiveCount = 0;
        int negativeCount = 0;
        
        for (NewsArticleBean article : articles) {
            String content = (article.getTitle() + " " + article.getContent()).toLowerCase();
            
            for (String word : positiveWords) {
                if (content.contains(word)) positiveCount++;
            }
            
            for (String word : negativeWords) {
                if (content.contains(word)) negativeCount++;
            }
        }
        
        if (positiveCount > negativeCount * 1.5) {
            return "긍정";
        } else if (negativeCount > positiveCount * 1.5) {
            return "부정";
        }
        
        return "중립";
    }
    
    private double calculateBasicCredibility(List<NewsArticleBean> articles) {
        if (articles.isEmpty()) return 30.0;
        
        double baseScore = 50.0;
        baseScore += Math.min(articles.size() * 3, 30);
        
        long uniqueSources = articles.stream()
                .map(NewsArticleBean::getSource)
                .filter(source -> source != null && !source.isEmpty())
                .distinct()
                .count();
        
        if (uniqueSources > 1) {
            baseScore += 10;
        }
        
        return Math.min(baseScore, 95.0);
    }
}
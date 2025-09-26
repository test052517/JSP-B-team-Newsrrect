package beans;


import java.sql.Timestamp;

/**
 * 뉴스 분석 결과 정보를 담는 Bean 클래스
 */
public class AnalysisResultBean {
    private int id;
    private String originalUrl;
    private String extractedKeywords;
    private int relatedArticlesCount;
    private String summary;
    private double reliabilityScore;
    private String analysisDetails;
    private String sentimentAnalysis;
    private int processingTime;
    private Timestamp createdAt;
    
    // 기본 생성자
    public AnalysisResultBean() {}
    
    // 매개변수 생성자
    public AnalysisResultBean(String originalUrl, String extractedKeywords, 
                             int relatedArticlesCount, String summary, 
                             double reliabilityScore, String analysisDetails) {
        this.originalUrl = originalUrl;
        this.extractedKeywords = extractedKeywords;
        this.relatedArticlesCount = relatedArticlesCount;
        this.summary = summary;
        this.reliabilityScore = reliabilityScore;
        this.analysisDetails = analysisDetails;
    }
    
    // Getter 메소드들
    public int getId() {
        return id;
    }
    
    public String getOriginalUrl() {
        return originalUrl;
    }
    
    public String getExtractedKeywords() {
        return extractedKeywords;
    }
    
    public int getRelatedArticlesCount() {
        return relatedArticlesCount;
    }
    
    public String getSummary() {
        return summary;
    }
    
    public double getReliabilityScore() {
        return reliabilityScore;
    }
    
    public String getAnalysisDetails() {
        return analysisDetails;
    }
    
    public String getSentimentAnalysis() {
        return sentimentAnalysis;
    }
    
    public int getProcessingTime() {
        return processingTime;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    // Setter 메소드들
    public void setId(int id) {
        this.id = id;
    }
    
    public void setOriginalUrl(String originalUrl) {
        this.originalUrl = originalUrl;
    }
    
    public void setExtractedKeywords(String extractedKeywords) {
        this.extractedKeywords = extractedKeywords;
    }
    
    public void setRelatedArticlesCount(int relatedArticlesCount) {
        this.relatedArticlesCount = relatedArticlesCount;
    }
    
    public void setSummary(String summary) {
        this.summary = summary;
    }
    
    public void setReliabilityScore(double reliabilityScore) {
        this.reliabilityScore = reliabilityScore;
    }
    
    public void setAnalysisDetails(String analysisDetails) {
        this.analysisDetails = analysisDetails;
    }
    
    public void setSentimentAnalysis(String sentimentAnalysis) {
        this.sentimentAnalysis = sentimentAnalysis;
    }
    
    public void setProcessingTime(int processingTime) {
        this.processingTime = processingTime;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // 신뢰도 등급 반환 메소드
    public String getReliabilityGrade() {
        if (reliabilityScore >= 80) {
            return "HIGH";
        } else if (reliabilityScore >= 60) {
            return "MEDIUM";
        } else {
            return "LOW";
        }
    }
    
    // 키워드를 배열로 반환
    public String[] getKeywordsArray() {
        if (extractedKeywords != null && !extractedKeywords.isEmpty()) {
            return extractedKeywords.split(",");
        }
        return new String[0];
    }
    
    @Override
    public String toString() {
        return "AnalysisResultBean{" +
                "id=" + id +
                ", originalUrl='" + originalUrl + '\'' +
                ", reliabilityScore=" + reliabilityScore +
                ", relatedArticlesCount=" + relatedArticlesCount +
                ", createdAt=" + createdAt +
                '}';
    }
}
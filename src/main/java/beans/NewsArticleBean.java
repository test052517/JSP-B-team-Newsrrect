package beans;

import java.sql.Timestamp;

/**
 * 뉴스 기사 정보를 담는 Bean 클래스
 */
public class NewsArticleBean {
    private int id;
    private String title;
    private String content;
    private String url;
    private String publishedDate;
    private String source;
    private int viewCount;
    private String keywords;
    private Timestamp createdAt;
    
    // 기본 생성자
    public NewsArticleBean() {}
    
    // 매개변수 생성자
    public NewsArticleBean(String title, String content, String url, String publishedDate, 
                          String source, String keywords) {
        this.title = title;
        this.content = content;
        this.url = url;
        this.publishedDate = publishedDate;
        this.source = source;
        this.keywords = keywords;
        this.viewCount = 0;
    }
    
    // Getter 메소드들
    public int getId() {
        return id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public String getContent() {
        return content;
    }
    
    public String getUrl() {
        return url;
    }
    
    public String getPublishedDate() {
        return publishedDate;
    }
    
    public String getSource() {
        return source;
    }
    
    public int getViewCount() {
        return viewCount;
    }
    
    public String getKeywords() {
        return keywords;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    // Setter 메소드들
    public void setId(int id) {
        this.id = id;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public void setUrl(String url) {
        this.url = url;
    }
    
    public void setPublishedDate(String publishedDate) {
        this.publishedDate = publishedDate;
    }
    
    public void setSource(String source) {
        this.source = source;
    }
    
    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }
    
    public void setKeywords(String keywords) {
        this.keywords = keywords;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return "NewsArticleBean{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", url='" + url + '\'' +
                ", source='" + source + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
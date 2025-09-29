package beans;

/**
 * 게시글 정보를 담는 Bean 클래스
 */
public class PostBean {
    // 기본 필드
    private int postId;
    private int userId;
    private String type;
    private String title;
    private String content;
    private String status;
    private int viewCount;
    private String createdAt;
    private int reportCount;
    private int recommandCount;
    private int priority;
    
    // JOIN을 위한 추가 필드
    private String nickname;
    
    // 기본 생성자
    public PostBean() {}

    // Getters and Setters
	public int getPostId() {
		return postId;
	}
	public void setPostId(int postId) {
		this.postId = postId;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public int getViewCount() {
		return viewCount;
	}
	public void setViewCount(int viewCount) {
		this.viewCount = viewCount;
	}
	public String getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(String createdAt) {
		this.createdAt = createdAt;
	}
	public int getReportCount() {
		return reportCount;
	}
	public void setReportCount(int reportCount) {
		this.reportCount = reportCount;
	}
	public int getRecommandCount() {
		return recommandCount;
	}
	public void setRecommandCount(int recommandCount) {
		this.recommandCount = recommandCount;
	}
	public int getPriority() {
		return priority;
	}
	public void setPriority(int priority) {
		this.priority = priority;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}

    /**
     * 날짜 포맷 변환 (yyyy-MM-dd HH:mm:ss -> MM.dd)
     */
    public String getFormattedDate() {
        if(createdAt == null || createdAt.length() < 10) {
            return createdAt;
        }
        String[] parts = createdAt.substring(0, 10).split("-");
        if(parts.length == 3) {
            return parts[1] + "." + parts[2];
        }
        return createdAt;
    }
}
package beans;

public class CommentBean{

    private int commentId;
    private int postId;
    private int userId;
    private String type;
    private int layer;
    private Integer parentCommentId;
    private String content;
    private String judgment;
    private String status;
    private int upvotes;
    private String createdAt;
    private int reportCount;
    
	public int getCommentId() {
		return commentId;
	}
	public void setCommentId(int commentId) {
		this.commentId = commentId;
	}
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
	public int getLayer() {
		return layer;
	}
	public void setLayer(int layer) {
		this.layer = layer;
	}
	public Integer getParentCommentId() {
		return parentCommentId;
	}
	public void setParentCommentId(Integer parentCommentId) {
		this.parentCommentId = parentCommentId;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getJudgment() {
		return judgment;
	}
	public void setJudgment(String judgment) {
		this.judgment = judgment;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public int getUpvotes() {
		return upvotes;
	}
	public void setUpvotes(int upvotes) {
		this.upvotes = upvotes;
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
}
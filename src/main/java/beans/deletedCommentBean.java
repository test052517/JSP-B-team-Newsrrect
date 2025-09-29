package beans;

public class deletedCommentBean {
	private int deletedCommentId;
    private int commentId;
    private int userId;
    private String type;
    private String content;
    private String reason;
    
	public int getDeletedCommentId() {
		return deletedCommentId;
	}
	public void setDeletedCommentId(int deletedCommentId) {
		this.deletedCommentId = deletedCommentId;
	}
	public int getCommentId() {
		return commentId;
	}
	public void setCommentId(int commentId) {
		this.commentId = commentId;
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
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getReason() {
		return reason;
	}
	public void setReason(String reason) {
		this.reason = reason;
	}
}

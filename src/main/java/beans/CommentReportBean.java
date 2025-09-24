package beans;

public class CommentReportBean{

    private int reportCommentId;
    private int commentId;
    private int reporterId;
    private String reason;
    
	public int getReportCommentId() {
		return reportCommentId;
	}
	public void setReportCommentId(int reportCommentId) {
		this.reportCommentId = reportCommentId;
	}
	public int getCommentId() {
		return commentId;
	}
	public void setCommentId(int commentId) {
		this.commentId = commentId;
	}
	public int getReporterId() {
		return reporterId;
	}
	public void setReporterId(int reporterId) {
		this.reporterId = reporterId;
	}
	public String getReason() {
		return reason;
	}
	public void setReason(String reason) {
		this.reason = reason;
	}
}
package beans;

public class PostReportBean{

    private int reportPostId;
    private int postId;
    private int reporterId;
    private String reason;
    
	public int getReportPostId() {
		return reportPostId;
	}
	public void setReportPostId(int reportPostId) {
		this.reportPostId = reportPostId;
	}
	public int getPostId() {
		return postId;
	}
	public void setPostId(int postId) {
		this.postId = postId;
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

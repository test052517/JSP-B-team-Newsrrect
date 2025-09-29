package beans;

public class postReportUserBean {
	private int reportUserId;
    private int logId;
    private String nickname;
    private int userId;
    private int reportPostId;
    
	public int getReportUserId() {
		return reportUserId;
	}
	public void setReportUserId(int reportUserId) {
		this.reportUserId = reportUserId;
	}
	public int getLogId() {
		return logId;
	}
	public void setLogId(int logId) {
		this.logId = logId;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	public int getReportPostId() {
		return reportPostId;
	}
	public void setReportPostId(int reportPostId) {
		this.reportPostId = reportPostId;
	}
}

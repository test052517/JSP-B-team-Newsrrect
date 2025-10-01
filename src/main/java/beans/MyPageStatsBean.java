package beans;

public class MyPageStatsBean {
	private int postCount;
	private int commentCount;
	private int receivedRecomCount;
	
	public MyPageStatsBean() {}

	public MyPageStatsBean(int postCount, int commentCount, int receivedRecomCount) {
        this.postCount = postCount;
        this.commentCount = commentCount;
        this.receivedRecomCount = receivedRecomCount;
    }
	
	public int getPostCount() {
		return postCount;
	}
	public void setPostCount(int postCount) {
		this.postCount = postCount;
	}
	public int getCommentCount() {
		return commentCount;
	}
	public void setCommentCount(int commentCount) {
		this.commentCount = commentCount;
	}
	public int getReceivedRecomCount() {
		return receivedRecomCount;
	}
	public void setReceivedRecomCount(int receivedRecomCount) {
		this.receivedRecomCount = receivedRecomCount;
	}
}

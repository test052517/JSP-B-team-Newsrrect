package beans;

public class BanBean{

    private int banId;
    private int bannedUserId;
    private String reason;
    private String banEndDate;
    
	public int getBanId() {
		return banId;
	}
	public void setBanId(int banId) {
		this.banId = banId;
	}
	public int getBannedUserId() {
		return bannedUserId;
	}
	public void setBannedUserId(int bannedUserId) {
		this.bannedUserId = bannedUserId;
	}
	public String getReason() {
		return reason;
	}
	public void setReason(String reason) {
		this.reason = reason;
	}
	public String getBanEndDate() {
		return banEndDate;
	}
	public void setBanEndDate(String banEndDate) {
		this.banEndDate = banEndDate;
	}
}
package beans;

public class CommentBean {

    private int comment_id;
    private int post_id;
    private int user_id;
    private String type;
    private int layer;
    private int parent_comment_id;
    private String content;
    private String judgment;
    private String status;
    private int upvotes;
    private String created_at;
    private int report_count;
    
    // ===============================================================
    // [추가] 화면 표시를 위해 JOIN된 사용자 닉네임을 임시로 담을 필드
    // ===============================================================
    private String nickname;
    private String originalPostTitle;
    private int originalPostId;
    
    // --- 기존 Getter/Setter 메소드 ---
    public int getComment_id() {
        return comment_id;
    }

    public void setComment_id(int comment_id) {
        this.comment_id = comment_id;
    }

    public int getPost_id() {
        return post_id;
    }

    public void setPost_id(int post_id) {
        this.post_id = post_id;
    }

    public int getUser_id() {
        return user_id;
    }

    public void setUser_id(int user_id) {
        this.user_id = user_id;
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

    public int getParent_comment_id() {
        return parent_comment_id;
    }

    public void setParent_comment_id(int parent_comment_id) {
        this.parent_comment_id = parent_comment_id;
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

    public String getCreated_at() {
        return created_at;
    }

    public void setCreated_at(String created_at) {
        this.created_at = created_at;
    }

    public int getReport_count() {
        return report_count;
    }

    public void setReport_count(int report_count) {
        this.report_count = report_count;
    }
    
    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getOriginalPostTitle() {
        return originalPostTitle;
    }

    public void setOriginalPostTitle(String originalPostTitle) {
        this.originalPostTitle = originalPostTitle;
    }

    public int getOriginalPostId() {
        return originalPostId;
    }

    public void setOriginalPostId(int originalPostId) {
        this.originalPostId = originalPostId;
    }
    
    public String getFormattedDate() {
        if (created_at == null || created_at.length() < 10) {
            return created_at;
        }
        return created_at.substring(0, 10).replace("-", ".");
    }
}


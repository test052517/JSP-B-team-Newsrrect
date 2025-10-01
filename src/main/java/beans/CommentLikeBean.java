package beans;

public class CommentLikeBean {

    private int likeComment_id;
    private int comment_id;
    private int like_id; // user_id를 의미

    // --- Getter/Setter 메소드 ---

    public int getLikeComment_id() {
        return likeComment_id;
    }

    public void setLikeComment_id(int likeComment_id) {
        this.likeComment_id = likeComment_id;
    }

    public int getComment_id() {
        return comment_id;
    }

    public void setComment_id(int comment_id) {
        this.comment_id = comment_id;
    }

    public int getLike_id() {
        return like_id;
    }

    public void setLike_id(int like_id) {
        this.like_id = like_id;
    }
}
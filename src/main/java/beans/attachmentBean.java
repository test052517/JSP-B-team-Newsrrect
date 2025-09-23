package beans;

import java.sql.Blob;

public class attachmentBean {
	private int attachmentFileId;
    private Blob file;
    
	public int getAttachmentFileId() {
		return attachmentFileId;
	}
	public void setAttachmentFileId(int attachmentFileId) {
		this.attachmentFileId = attachmentFileId;
	}
	public Blob getFile() {
		return file;
	}
	public void setFile(Blob file) {
		this.file = file;
	}
}

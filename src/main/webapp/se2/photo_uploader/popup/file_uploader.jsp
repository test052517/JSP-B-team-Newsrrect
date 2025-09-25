<%@page import="java.util.Date"%>
<%@page import="java.util.Locale"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="java.io.File"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
		String uploadPath = "/uploadfile/smartEditor/";
		StringBuffer buffer = new StringBuffer();
		String filename = "";

		if(request.getContentLength() > 10*1024*1024 ){
%>
	<script>alert("업로드 용량(총 10Mytes)을 초과하였습니다.");history.back();</script>
<%
	return;

} else {
	
	try {
				
		/* String path = GetProperties.SMART_EDITOR_UPLOAD_PATH; */
		/* String path = "C:/java/dental/WebContent/boarder/se2/upload"; */
		/* String path = "/se2/upload"; */
		String path = request.getContextPath() + "/JSP-B-team-Newsrrect/src/main/webapp/se2/upload";
		MultipartRequest multi=new MultipartRequest(request, path, 15*1024*1024, "UTF-8", new DefaultFileRenamePolicy());
	
		java.text.SimpleDateFormat formatter2 = new java.text.SimpleDateFormat ("yyyy_MM_dd_HHmmss", java.util.Locale.KOREA);
		int cnt = 1;
		String upfile = (multi.getFilesystemName("Filedata"));
		if (!upfile.equals("")) {
			String dateString = formatter2.format(new java.util.Date());
			String moveFileName = dateString + upfile.substring(upfile.lastIndexOf(".") );
			String fileExt = upfile.substring(upfile.lastIndexOf(".") + 1);
			File sourceFile = new File(path + File.separator + upfile);
			File targetFile = new File(path + File.separator + moveFileName);
			sourceFile.renameTo(targetFile);
			filename = moveFileName;
			//System.out.println("upfile : " + upfile);
			//System.out.println("targetFile : " + targetFile);
			//System.out.println("moveFileName : " + moveFileName);
			//System.out.println("filename : " + filename);
			//System.out.println("moveFileName : " + moveFileName);
			
			sourceFile.delete();
			
			%>
			<form id="fileform" name="fileform" method="post">
				<input type="hidden" name="filename" value="<%=filename%>">
				<input type="hidden" name="uploadPath" value="<%=uploadPath%>">
				<input type="hidden" name="fcode" value="<%=uploadPath%>">
			</form>
			<%
		}
	} catch (Exception e) {
		System.out.println("e : " + e.getMessage());
	}
}
%>
<script type="text/javascript">
	function fileAttach(){ 
		f = document.fileform;
		fpath = f.uploadPath.value;
	    fname = f.filename.value; 
	    fcode = fpath + fname;
	    try{
	    	alert(fname);
             window.opener.pasteHTML(fname); 
	    	 window.close(); 
	    }catch(e){ 
//             alert(e); 
	    } 
	} 
	fileAttach();
	this.window.close();
</script>

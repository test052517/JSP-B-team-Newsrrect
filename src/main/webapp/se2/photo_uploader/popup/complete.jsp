<%-- <%@page import="kr.co.techinmotion.common.GetProperties"%> --%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>공모페이지</title>
<link rel=styleSheet href="contestcss/css.css" type="text/css">
<%
	System.out.println(1212);
	MultipartRequest multi = null;

	String uname = "";
	String fullhnum = "";
	String fullcnum = "";
	String fname = "";
	String fcontent = "";
	String file1 = "";
	String file2 = "";
	String realFilename1 = "";
	String realFilename2 = "";
	String saveFilename1 = "";
	String saveFilename2 = "";
	String f_ext = "";
	String ch = "";

	String fsize = "";
	String ftype = "";

	for (int i = 1; i <= 3; i++) {
		ch += (char) ((Math.random() * 26) + 97);
	}

	SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss",
			Locale.KOREA);
	Date currentTime = new Date();
	String dTime = formatter.format(currentTime);
	String name = "/"+dTime + ch;
	//System.out.println(dTime+ch);

	try {

		//		String path = "C:/FileSave";    // 저장할 디렉토리 (절대경로)
		//      String path = GetProperties.SMART_EDITOR_UPLOAD_PATH;
		String path = "C:/JSP-B-team-Newsrrect/JSP-B-team-Newsrrect/src/main/webapp/se2/upload";
		
		System.out.println(path);
		int size = 15 * 1024 * 1024; // 15메가까지 제한 넘어서면 예외발생
		//    up=new MultipartRequest(request, path, size, new DefaultFileRenamePolicy());
		

		fname = request.getHeader("file-name");
		fsize = request.getHeader("file-size");
		ftype = request.getHeader("file-Type");
		String[] array;
		array = fname.split("\\.");
		
		multi = new MultipartRequest(request, path, size,"UTF-8", new DefaultFileRenamePolicy());

		uname = multi.getParameter("uname");

		fullhnum = multi.getParameter("fullhnum");

		fullcnum = multi.getParameter("fullcnum");

		fname = multi.getParameter("fname");

		fcontent = multi.getParameter("fcontent");

		file1 =  multi.getParameter("filename1");

		file2 = multi.getParameter("filename2");

		

		int intFile1 = file1.lastIndexOf("\\");

		int intFile2 = file2.lastIndexOf("\\");

		

		realFilename1 = file1.substring(intFile1+1);

		realFilename2 = file2.substring(intFile2+1);

		

		saveFilename1 = "poster_"+uname+"("+fullcnum +")_"+ realFilename1;

		saveFilename2 = "poster_"+uname+"("+fullcnum +")_"+ realFilename2;



		Enumeration e=multi.getFileNames();  // 폼의 이름 반환



		File file=new File(path+"/"+realFilename1); //원본파일부르기 

		file.renameTo(new File(path+"/"+saveFilename1)); //파일이름변경

		

		file=new File(path+"/"+realFilename2); //원본파일부르기 

		file.renameTo(new File(path+"/"+saveFilename2)); //파일이름변경

		
		
		//String strFilename = name+"."+array[1];
// 		String strFilename = fname;
// 		String strFilenameOutput = new String(
// 				strFilename.getBytes("euc-kr"), "8859_1");
// 		File file = new File(path + strFilename);
// 		byte b[] = new byte[(int) file.length()];
// 		response.setHeader("Content-Disposition",
// 				"attachment;filename=" + strFilenameOutput);
// 		response.setHeader("Content-Length",
// 				String.valueOf(file.length()));
// 		if (file.isFile()) {
// 			BufferedInputStream fin = new BufferedInputStream(
// 					new FileInputStream(file));
// 			BufferedOutputStream outs = new BufferedOutputStream(
// 					response.getOutputStream());
// 			int read = 0;
// 			while ((read = fin.read(b)) != -1) {
// 				outs.write(b, 0, read);
// 			}
// 			outs.close();
// 			fin.close();
// 		}
	} catch (Exception e) {
		System.out.println("e : " + e.getMessage());
	}
%>

</head>
<body>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시물 작성</title>
    
    <script>
        function post() {
            // SmartEditor의 내용을 textarea로 업데이트합니다.
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            
            const titleInput = document.getElementById('postTitle');
            const title = titleInput.value;
            const content = document.getElementById('ir1').value;

            if (title.trim() === "") {
                alert("제목을 입력해주세요.");
                return;
            }
            if (content.trim() === "" || content === "<p>&nbsp;</p>") {
                alert("내용을 입력해주세요.");
                return;
            }
            
            // 폼을 직접 제출합니다.
            document.getElementById('postForm').submit();
        }
    </script>
</head>
<body>

    <h1>게시물 작성</h1>
    
    <form id="postForm" action="test01proc.jsp" method="post" enctype="multipart/form-data">
        <label for="postTitle">제목:</label>
        <input type="text" id="postTitle" name="title" required>
        
        <br><br>
        
       	<%@ include file ="/se2/SmartEditor.jsp" %>
        
        <br><br>
        
        <button type="button" onclick="post()">게시물 등록</button>
    </form>
    
        <h1>게시물 조회</h1>
    
    <form action="test02.jsp" method="get">
        <label for="postid">게시물 ID를 입력하세요:</label>
        <input type="number" id="postid" name="post_id" required>
        
        <br><br>
        
        <button type="submit">게시물 찾기</button>
    </form>

</body>
</html>
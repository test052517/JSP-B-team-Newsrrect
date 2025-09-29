<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시물 작성</title>
    
    <script>
        function post() {
            // SmartEditor의 내용을 textarea로 업데이트합니다.
            if (typeof oEditors !== 'undefined' && oEditors.length > 0) {
                oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
            }
            
            const titleInput = document.getElementById('postTitle');
            const title = titleInput.value;
            const content = document.getElementById('ir1').value;

            if (title.trim() === "") {
                alert("제목을 입력해주세요.");
                titleInput.focus();
                return;
            }
            if (content.trim() === "" || content === "<p>&nbsp;</p>" || content === "<p><br></p>") {
                alert("내용을 입력해주세요.");
                if (typeof oEditors !== 'undefined' && oEditors.length > 0) {
                    oEditors.getById["ir1"].exec("FOCUS");
                }
                return;
            }
            
            // 폼을 직접 제출합니다.
            document.getElementById('postForm').submit();
        }
        
        // 페이지 로드 시 에디터 초기화 확인
        window.onload = function() {
            // SmartEditor가 로드될 때까지 잠시 대기
            setTimeout(function() {
                if (typeof oEditors === 'undefined') {
                    console.warn('SmartEditor가 제대로 로드되지 않았습니다.');
                }
            }, 2000);
        };
    </script>
</head>
<body>

    <h1>게시물 작성</h1>
    
    <form id="postForm" action="test01proc.jsp" method="post" enctype="multipart/form-data">
        <div style="margin-bottom: 10px;">
            <label for="postTitle">제목:</label>
            <input type="text" id="postTitle" name="title" required style="width: 100%; padding: 5px; margin-top: 5px;">
        </div>
        
        <div style="margin-bottom: 10px;">
            <label>내용:</label>
        </div>
        
        <div style="margin-bottom: 10px;">
            <%@ include file="/se2/SmartEditor.jsp" %>
        </div>
        
        <div style="margin-bottom: 10px;">
            <label for="fileUpload">파일 첨부:</label>
            <input type="file" id="fileUpload" name="file" accept="image/*" style="margin-top: 5px;">
        </div>
        
        <div style="margin-bottom: 20px;">
            <button type="button" onclick="post()" style="background-color: #007bff; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;">게시물 등록</button>
            <button type="button" onclick="history.back()" style="background-color: #6c757d; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-left: 10px;">취소</button>
        </div>
    </form>
    
    <hr style="margin: 30px 0;">
    
    <h2>게시물 조회</h2>
    
    <form action="test02.jsp" method="get">
        <div style="margin-bottom: 10px;">
            <label for="postid">게시물 ID를 입력하세요:</label>
            <input type="number" id="postid" name="post_id" required style="padding: 5px; margin-left: 10px;">
        </div>
        
        <div>
            <button type="submit" style="background-color: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer;">게시물 찾기</button>
        </div>
    </form>

    <script>
        // 버튼 hover 효과
        document.querySelectorAll('button').forEach(function(button) {
            button.addEventListener('mouseenter', function() {
                this.style.opacity = '0.8';
            });
            button.addEventListener('mouseleave', function() {
                this.style.opacity = '1';
            });
        });
    </script>

</body>
</html>
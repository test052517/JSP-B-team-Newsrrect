<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>네이버 :: Smart Editor 2 &#8482;</title>
<script type="text/javascript" src="<%= request.getContextPath() %>/se2/js/HuskyEZCreator.js" charset="utf-8"></script>
<style>
    #photoToggleContainer {
        margin-bottom: 10px; padding: 8px; border: 1px solid #ddd;
        border-radius: 5px; display: inline-block; font-size: 14px;
    }
    #photoToggleContainer label { cursor: pointer; user-select: none; }
</style>
</head>
<body>

<div id="photoToggleContainer">
    <label>
        <input type="checkbox" id="photoToggleCheckbox" checked="checked" />
        <strong>사진 첨부 기능 사용</strong>
    </label>
</div>

<form action="#" method="post">
	<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:75%; height:412px; display:none;"></textarea>
</form>

<script type="text/javascript">
var oEditors = [];
var sLang = "ko_KR";

/**
 * 1. 에디터 스킨(iframe)으로부터 호출될 함수 (가장 중요)
 * 이제 인자로 iframe의 window 객체를 직접 받습니다.
 * @param {Window} editorWindow - iframe의 window 객체
 */
function onEditorSkinReady(editorWindow) {
    console.log("✅ 에디터 스킨으로부터 '준비 완료' 신호와 함께 'iframe 참조'를 받았습니다.");

    const photoCheckbox = document.getElementById("photoToggleCheckbox");
    
    // 전달받은 editorWindow 객체에서 .frameElement 속성을 통해 iframe 요소를 직접 얻습니다.
    // 더 이상 ID로 찾을 필요가 없습니다.
    const editorFrame = editorWindow.frameElement;

    if (!editorFrame) {
        console.error("치명적 오류: iframe 참조를 받았으나 frameElement를 얻을 수 없습니다.");
        return;
    }

    // 사진 버튼 제어 함수
    function setPhotoButtonVisibility(isVisible) {
        try {
            // editorFrame.contentWindow는 editorWindow와 같습니다.
            editorWindow.togglePhotoFeature(isVisible);
        } catch (e) {
            console.error("에디터 내부 함수 호출에 실패했습니다.", e);
        }
    }

    // 체크박스에 이벤트 리스너를 연결합니다.
    photoCheckbox.addEventListener("change", function() {
        setPhotoButtonVisibility(this.checked);
    });

    // 최초 로딩 시, 체크박스 상태에 맞춰 버튼을 설정합니다.
    setPhotoButtonVisibility(photoCheckbox.checked);
}


// 2. 에디터 생성
nhn.husky.EZCreator.createInIFrame({
    oAppRef: oEditors,
    elPlaceHolder: "ir1",
    sSkinURI: "<%= request.getContextPath() %>/se2/SmartEditor2Skin.html",
    htParams : {
        bUseToolbar : true,
        bUseVerticalResizer : true,
        bUseModeChanger : true,
        I18N_LOCALE : sLang
    },
    fOnAppLoad : function(){},
    fCreator: "createSEditor2"
});


// (이하 다른 함수들은 기존과 동일합니다)
function pasteHTML(filepath) {
	 var sHTML = '<img src="./upload/'+filepath+'">';
	oEditors.getById["ir1"].exec("PASTE_HTML", [sHTML]);
}

function showHTML() {
	var sHTML = oEditors.getById["ir1"].getIR();
	alert(sHTML);
}
	
function submitContents(elClickedObj) {
	oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);
	try {
		elClickedObj.form.submit();
	} catch(e) {}
}

function setDefaultFont() {
	var sDefaultFont = '궁서';
	var nFontSize = 24;
	oEditors.getById["ir1"].setDefaultFont(sDefaultFont, nFontSize);
}
</script>
</body>
</html>
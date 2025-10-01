<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 응답 캐싱 방지
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String email = request.getParameter("email");
    String code = request.getParameter("code");
    
    if (email == null || email.trim().isEmpty() || code == null || code.trim().isEmpty()) {
        out.print("이메일과 인증코드를 입력해주세요.");
        return;
    }
    
    String sessionCode = (String) session.getAttribute("verificationCode");
    String sessionEmail = (String) session.getAttribute("verificationEmail");
    Long codeGeneratedTime = (Long) session.getAttribute("codeGeneratedTime");
    
    if (sessionCode == null || sessionEmail == null || codeGeneratedTime == null) {
        out.print("인증코드를 먼저 발송해주세요.");
        return;
    }
    
    // 5분(300000ms) 경과 확인
    long currentTime = System.currentTimeMillis();
    long elapsedTime = currentTime - codeGeneratedTime;
    
    if (elapsedTime > 300000) {
        session.removeAttribute("verificationCode");
        session.removeAttribute("verificationEmail");
        session.removeAttribute("codeGeneratedTime");
        out.print("인증 시간이 만료되었습니다. 인증코드를 다시 발송해주세요.");
        return;
    }
    
    // 이메일과 코드 확인
    if (sessionEmail.equals(email) && sessionCode.equals(code)) {
        // 인증 성공 - 세션에 인증 완료 표시
        session.setAttribute("emailVerified", true);
        session.setAttribute("verifiedEmail", email);
        
        // 인증코드 정보 삭제
        session.removeAttribute("verificationCode");
        session.removeAttribute("codeGeneratedTime");
        
        out.print("성공");
    } else {
        out.print("인증코드가 일치하지 않습니다.");
    }
%>
<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Properties" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.util.Random" %>
<%
    // 응답 캐싱 방지
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String email = request.getParameter("email");
    
    if (email == null || email.trim().isEmpty()) {
        out.print("이메일을 입력해주세요.");
        return;
    }

    // 6자리 랜덤 인증코드 생성
    Random random = new Random();
    String verificationCode = String.format("%06d", random.nextInt(1000000));
    
    // 세션에 인증코드와 생성 시간 저장
    session.setAttribute("verificationCode", verificationCode);
    session.setAttribute("verificationEmail", email);
    session.setAttribute("codeGeneratedTime", System.currentTimeMillis());
    
    try {
        // 이메일 설정 (Gmail 기준)
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        
        // TLS 프로토콜 명시적 설정
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        
        // 추가 보안 설정
        props.put("mail.smtp.ssl.checkserveridentity", "true");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        
        // 발신자 이메일 계정 정보 (실제 사용 시 보안 방식으로 관리 필요)
        final String username = "eleft94@gmail.com"; // 실제 이메일로 변경
        final String password = "skddnusdaqqtcppb"; // 앱 비밀번호로 변경
        
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        // 디버그 모드 활성화 (개발 시에만 사용, 배포 시 제거)
        // mailSession.setDebug(true);
        
        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(username));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
        message.setSubject("[Newsrrect] 이메일 인증 코드");
        
        String htmlContent = 
            "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>" +
            "<h2 style='color: #5d74f8;'>Newsrrect 이메일 인증</h2>" +
            "<p>안녕하세요,</p>" +
            "<p>회원가입을 위한 인증코드를 안내드립니다.</p>" +
            "<div style='background-color: #f5f5f5; padding: 20px; margin: 20px 0; text-align: center;'>" +
            "<h1 style='color: #5d74f8; margin: 0; letter-spacing: 5px;'>" + verificationCode + "</h1>" +
            "</div>" +
            "<p>위 인증코드를 회원가입 페이지에 입력해주세요.</p>" +
            "<p style='color: #666; font-size: 12px;'>본 인증코드는 5분간 유효합니다.</p>" +
            "<p style='color: #666; font-size: 12px;'>본인이 요청하지 않은 경우, 이 메일을 무시하셔도 됩니다.</p>" +
            "</div>";
        
        message.setContent(htmlContent, "text/html; charset=UTF-8");
        
        Transport.send(message);
        
        out.print("성공");
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("이메일 발송에 실패했습니다: " + e.getMessage());
    }
%>
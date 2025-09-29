package Servlet;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CharacterEncodingFilter implements Filter {
    
    private String encoding = "UTF-8";
    private boolean forceRequestEncoding = false;
    private boolean forceResponseEncoding = false;
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String encodingParam = filterConfig.getInitParameter("encoding");
        if (encodingParam != null) {
            encoding = encodingParam;
        }
        
        String forceEncodingParam = filterConfig.getInitParameter("forceEncoding");
        if (forceEncodingParam != null) {
            forceRequestEncoding = Boolean.parseBoolean(forceEncodingParam);
            forceResponseEncoding = Boolean.parseBoolean(forceEncodingParam);
        }
        
        String forceRequestParam = filterConfig.getInitParameter("forceRequestEncoding");
        if (forceRequestParam != null) {
            forceRequestEncoding = Boolean.parseBoolean(forceRequestParam);
        }
        
        String forceResponseParam = filterConfig.getInitParameter("forceResponseEncoding");
        if (forceResponseParam != null) {
            forceResponseEncoding = Boolean.parseBoolean(forceResponseParam);
        }
        
        System.out.println("CharacterEncodingFilter 초기화:");
        System.out.println("  - encoding: " + encoding);
        System.out.println("  - forceRequestEncoding: " + forceRequestEncoding);
        System.out.println("  - forceResponseEncoding: " + forceResponseEncoding);
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                        FilterChain chain) throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // 요청 인코딩 설정
        if (forceRequestEncoding || request.getCharacterEncoding() == null) {
            System.out.println("요청 인코딩 설정: " + encoding + " (기존: " + request.getCharacterEncoding() + ")");
            request.setCharacterEncoding(encoding);
        }
        
        // 응답 인코딩 설정
        if (forceResponseEncoding || response.getCharacterEncoding() == null || 
            "ISO-8859-1".equals(response.getCharacterEncoding())) {
            System.out.println("응답 인코딩 설정: " + encoding + " (기존: " + response.getCharacterEncoding() + ")");
            response.setCharacterEncoding(encoding);
        }
        
        // Content-Type에 charset 추가 (JSON API 요청의 경우)
        String requestURI = httpRequest.getRequestURI();
        if (requestURI.startsWith("/api/")) {
            httpResponse.setContentType("application/json; charset=" + encoding);
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        System.out.println("CharacterEncodingFilter 종료");
    }
}
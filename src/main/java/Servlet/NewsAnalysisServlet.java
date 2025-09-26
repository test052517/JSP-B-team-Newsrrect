package Servlet;

import javax.servlet.ServletException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class NewsAnalysisServlet extends HttpServlet {
    
    private static final String FLASK_API_URL = "http://localhost:5000/analyze";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 인코딩 설정
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // CORS 헤더 설정
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        
        try {
            System.out.println("=== 뉴스 분석 요청 시작 ===");
            
            // Form 파라미터 읽기
            String url = request.getParameter("url");
            String text = request.getParameter("text");
            String type = request.getParameter("type");
            
            System.out.println("Form 파라미터:");
            System.out.println("- url: " + url);
            System.out.println("- text: " + (text != null ? text.substring(0, Math.min(text.length(), 100)) + "..." : "null"));
            System.out.println("- type: " + type);
            
            // 입력 검증
            if ((url == null || url.trim().isEmpty()) && 
                (text == null || text.trim().isEmpty())) {
                sendErrorResponse(response, "분석할 URL 또는 텍스트를 입력해주세요.");
                return;
            }
            
            // JSON 생성
            String jsonPayload = createJsonPayload(url, text, type);
            
            if (jsonPayload == null || jsonPayload.trim().isEmpty()) {
                sendErrorResponse(response, "요청 데이터가 비어있습니다.");
                return;
            }
            
            System.out.println("Flask API로 전송할 JSON: " + jsonPayload);
            
            // Flask API 호출
            String result = callFlaskApi(jsonPayload);
            System.out.println("Flask API 응답 길이: " + result.length());
            
            // 결과 반환
            response.getWriter().write(result);
            System.out.println("=== 뉴스 분석 요청 완료 ===");
            
        } catch (Exception e) {
            System.err.println("분석 요청 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, "서버 내부 오류: " + e.getMessage());
        }
    }
    
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
    
    private String createJsonPayload(String url, String text, String type) {
        StringBuilder json = new StringBuilder("{");
        boolean hasData = false;
        
        if ("url".equals(type) && url != null && !url.trim().isEmpty()) {
            json.append("\"type\":\"url\",");
            json.append("\"url\":\"").append(escapeJson(url.trim())).append("\"");
            hasData = true;
        } else if ("text".equals(type) && text != null && !text.trim().isEmpty()) {
            json.append("\"type\":\"text\",");
            json.append("\"text\":\"").append(escapeJson(text.trim())).append("\"");
            hasData = true;
        } else {
            if (url != null && !url.trim().isEmpty()) {
                json.append("\"url\":\"").append(escapeJson(url.trim())).append("\"");
                hasData = true;
            }
            
            if (text != null && !text.trim().isEmpty()) {
                if (hasData) json.append(",");
                json.append("\"text\":\"").append(escapeJson(text.trim())).append("\"");
                hasData = true;
            }
        }
        
        json.append("}");
        return hasData ? json.toString() : null;
    }
    
    private String escapeJson(String text) {
        if (text == null) return "";
        
        return text.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    private String callFlaskApi(String jsonPayload) throws IOException {
        URL url = new URL(FLASK_API_URL);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        try {
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            connection.setRequestProperty("Accept", "application/json");
            connection.setDoOutput(true);
            connection.setConnectTimeout(30000);
            connection.setReadTimeout(120000);
            
            try (OutputStreamWriter writer = new OutputStreamWriter(
                    connection.getOutputStream(), StandardCharsets.UTF_8)) {
                writer.write(jsonPayload);
                writer.flush();
            }
            
            int responseCode = connection.getResponseCode();
            System.out.println("Flask API 응답 코드: " + responseCode);
            
            BufferedReader reader;
            if (responseCode >= 200 && responseCode < 300) {
                reader = new BufferedReader(new InputStreamReader(
                    connection.getInputStream(), StandardCharsets.UTF_8));
            } else {
                reader = new BufferedReader(new InputStreamReader(
                    connection.getErrorStream(), StandardCharsets.UTF_8));
            }
            
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();
            
            String result = response.toString();
            
            if (responseCode >= 400) {
                throw new IOException("Flask API 오류: " + responseCode + " - " + result);
            }
            
            return result;
            
        } finally {
            connection.disconnect();
        }
    }
    
    private void sendErrorResponse(HttpServletResponse response, String errorMessage) 
            throws IOException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        String errorJson = "{\"success\":false,\"error\":\"" + escapeJson(errorMessage) + "\"}";
        response.getWriter().write(errorJson);
    }
}
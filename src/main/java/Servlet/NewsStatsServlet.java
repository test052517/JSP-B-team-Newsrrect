package Servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class NewsStatsServlet extends HttpServlet {
    
    private static final String FLASK_API_URL = "http://localhost:5000/api/stats";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 응답 설정
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        
        try {
            System.out.println("통계 조회 요청: " + FLASK_API_URL);
            
            // Flask API 호출
            String result = callFlaskGetApi(FLASK_API_URL);
            
            // 결과 반환
            response.getWriter().write(result);
            
        } catch (Exception e) {
            System.err.println("통계 조회 중 오류: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(response, "통계 조회 오류: " + e.getMessage());
        }
    }
    
    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // CORS preflight 요청 처리
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
    
    /**
     * Flask GET API 호출
     */
    private String callFlaskGetApi(String apiUrl) throws IOException {
        URL url = new URL(apiUrl);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        try {
            // 연결 설정
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Accept", "application/json");
            connection.setConnectTimeout(10000); // 10초
            connection.setReadTimeout(30000);    // 30초
            
            // 응답 읽기
            int responseCode = connection.getResponseCode();
            System.out.println("Flask Stats API 응답 코드: " + responseCode);
            
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
            
            return response.toString();
            
        } catch (IOException e) {
            System.err.println("Flask Stats API 호출 실패: " + e.getMessage());
            throw e;
        } finally {
            connection.disconnect();
        }
    }
    
    /**
     * 에러 응답 전송
     */
    private void sendErrorResponse(HttpServletResponse response, String errorMessage) 
            throws IOException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        
        // JSON 수동 생성
        String escapedMessage = errorMessage.replace("\\", "\\\\").replace("\"", "\\\"");
        String errorJson = "{\"success\":false,\"error\":\"" + escapedMessage + "\"}";
        response.getWriter().write(errorJson);
    }
}
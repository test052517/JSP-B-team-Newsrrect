-- MySQL 데이터베이스 생성 스크립트
-- news_analysis 데이터베이스 및 테이블 생성

-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS news_analysis 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 데이터베이스 사용
USE news_analysis;

-- 1. 뉴스 기사 테이블 (수정된 버전)
CREATE TABLE IF NOT EXISTS news_articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title TEXT NOT NULL COMMENT '뉴스 제목',
    content TEXT COMMENT '뉴스 내용/요약',
    -- 여기서 UNIQUE 키워드 제거
    url VARCHAR(1000) COMMENT '뉴스 URL', 
    published_date VARCHAR(50) COMMENT '발행 날짜',
    source VARCHAR(200) COMMENT '뉴스 출처',
    view_count INT DEFAULT 0 COMMENT '조회수',
    keywords TEXT COMMENT '관련 키워드 (쉼표 구분)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성 시간',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 시간',
    
    -- 인덱스 설정
    INDEX idx_keywords (keywords(100)),
    INDEX idx_created_at (created_at),
    -- 아래 줄을 UNIQUE INDEX로 변경하고 길이를 255로 지정
    UNIQUE INDEX idx_url (url(255)), 
    INDEX idx_source (source),
    INDEX idx_published_date (published_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='뉴스 기사 정보 테이블';

-- 2. 분석 결과 테이블
CREATE TABLE IF NOT EXISTS analysis_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    original_url VARCHAR(1000) NOT NULL COMMENT '원본 뉴스 URL',
    extracted_keywords TEXT COMMENT '추출된 키워드',
    related_articles_count INT COMMENT '관련 기사 수',
    summary TEXT COMMENT '종합 요약',
    reliability_score DECIMAL(5,2) COMMENT '신뢰성 점수 (0-100)',
    analysis_details TEXT COMMENT '분석 상세 내용',
    sentiment_analysis TEXT COMMENT '감정 분석 결과',
    processing_time INT COMMENT '처리 시간(초)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '분석 시간',
    
    -- 인덱스 설정
    INDEX idx_original_url (original_url(200)),
    INDEX idx_created_at (created_at),
    INDEX idx_reliability_score (reliability_score),
    INDEX idx_keywords (extracted_keywords(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='뉴스 분석 결과 테이블';

-- 3. 키워드 추출 로그 테이블
CREATE TABLE IF NOT EXISTS keyword_extractions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    source_url VARCHAR(1000) NOT NULL COMMENT '소스 URL',
    extracted_keywords TEXT COMMENT '추출된 키워드',
    extraction_method VARCHAR(50) COMMENT '추출 방법 (cohere, etc)',
    success BOOLEAN DEFAULT TRUE COMMENT '추출 성공 여부',
    error_message TEXT COMMENT '오류 메시지',
    processing_time DECIMAL(8,2) COMMENT '처리 시간(초)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '추출 시간',
    
    -- 인덱스 설정
    INDEX idx_source_url (source_url(200)),
    INDEX idx_created_at (created_at),
    INDEX idx_method (extraction_method),
    INDEX idx_success (success)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='키워드 추출 로그 테이블';

-- 4. 시스템 로그 테이블
CREATE TABLE IF NOT EXISTS system_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_level ENUM('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL') DEFAULT 'INFO',
    module_name VARCHAR(100) COMMENT '모듈명',
    function_name VARCHAR(100) COMMENT '함수명',
    message TEXT COMMENT '로그 메시지',
    user_ip VARCHAR(45) COMMENT '사용자 IP',
    request_url VARCHAR(500) COMMENT '요청 URL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '로그 시간',
    
    -- 인덱스 설정
    INDEX idx_log_level (log_level),
    INDEX idx_created_at (created_at),
    INDEX idx_module (module_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='시스템 로그 테이블';

-- 5. API 사용량 추적 테이블
CREATE TABLE IF NOT EXISTS api_usage_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    api_provider VARCHAR(50) NOT NULL COMMENT 'API 제공자 (cohere, naver)',
    endpoint VARCHAR(200) COMMENT 'API 엔드포인트',
    request_data TEXT COMMENT '요청 데이터',
    response_status INT COMMENT '응답 상태 코드',
    processing_time DECIMAL(8,3) COMMENT '처리 시간(초)',
    tokens_used INT COMMENT '사용된 토큰 수',
    cost DECIMAL(10,4) COMMENT '비용',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '사용 시간',
    
    -- 인덱스 설정
    INDEX idx_api_provider (api_provider),
    INDEX idx_created_at (created_at),
    INDEX idx_response_status (response_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='API 사용량 추적 테이블';

-- 6. 사용자 세션 테이블 (확장용)
CREATE TABLE IF NOT EXISTS user_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) UNIQUE NOT NULL COMMENT '세션 ID',
    user_ip VARCHAR(45) COMMENT '사용자 IP',
    user_agent TEXT COMMENT '사용자 에이전트',
    analyses_count INT DEFAULT 0 COMMENT '분석 횟수',
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '세션 생성 시간',
    
    -- 인덱스 설정
    INDEX idx_session_id (session_id),
    INDEX idx_last_activity (last_activity),
    INDEX idx_user_ip (user_ip)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='사용자 세션 추적 테이블';

-- ============================================
-- 데이터베이스 뷰(View) 생성
-- ============================================

-- 1. 분석 통계 뷰
CREATE OR REPLACE VIEW analysis_stats AS
SELECT 
    COUNT(*) as total_analyses,
    AVG(reliability_score) as avg_reliability_score,
    MIN(reliability_score) as min_reliability_score,
    MAX(reliability_score) as max_reliability_score,
    SUM(CASE WHEN reliability_score >= 80 THEN 1 ELSE 0 END) as high_reliability_count,
    SUM(CASE WHEN reliability_score >= 60 AND reliability_score < 80 THEN 1 ELSE 0 END) as medium_reliability_count,
    SUM(CASE WHEN reliability_score < 60 THEN 1 ELSE 0 END) as low_reliability_count,
    COUNT(DISTINCT DATE(created_at)) as analysis_days,
    AVG(related_articles_count) as avg_articles_per_analysis
FROM analysis_results;

-- 2. 일별 분석 통계 뷰
CREATE OR REPLACE VIEW daily_analysis_stats AS
SELECT 
    DATE(created_at) as analysis_date,
    COUNT(*) as analyses_count,
    AVG(reliability_score) as avg_reliability,
    MAX(reliability_score) as max_reliability,
    MIN(reliability_score) as min_reliability
FROM analysis_results 
GROUP BY DATE(created_at)
ORDER BY analysis_date DESC;

-- 3. 최근 고신뢰도 뉴스 뷰
CREATE OR REPLACE VIEW recent_high_reliability_news AS
SELECT 
    ar.id,
    ar.original_url,
    ar.extracted_keywords,
    ar.reliability_score,
    ar.summary,
    ar.created_at
FROM analysis_results ar
WHERE ar.reliability_score >= 80
ORDER BY ar.created_at DESC
LIMIT 20;

-- ============================================
-- 저장 프로시저(Stored Procedures) 생성
-- ============================================

-- 1. 오래된 데이터 정리 프로시저
DELIMITER //
CREATE PROCEDURE CleanupOldData(IN days_to_keep INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- 오래된 뉴스 기사 삭제
    DELETE FROM news_articles 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    -- 오래된 키워드 추출 로그 삭제  
    DELETE FROM keyword_extractions 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    -- 오래된 시스템 로그 삭제
    DELETE FROM system_logs 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    -- 오래된 API 사용 로그 삭제
    DELETE FROM api_usage_logs 
    WHERE created_at < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    COMMIT;
    
    SELECT 'Old data cleanup completed successfully' as message;
END //
DELIMITER ;

-- 2. 통계 요약 프로시저
DELIMITER //
CREATE PROCEDURE GetAnalysisStatsSummary(IN last_days INT)
BEGIN
    SELECT 
        COUNT(*) as total_analyses,
        AVG(reliability_score) as avg_reliability,
        SUM(CASE WHEN reliability_score >= 80 THEN 1 ELSE 0 END) as high_reliability,
        SUM(CASE WHEN reliability_score >= 60 AND reliability_score < 80 THEN 1 ELSE 0 END) as medium_reliability,
        SUM(CASE WHEN reliability_score < 60 THEN 1 ELSE 0 END) as low_reliability,
        COUNT(DISTINCT DATE(created_at)) as active_days
    FROM analysis_results 
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL last_days DAY);
END //
DELIMITER ;

-- ============================================
-- 초기 데이터 삽입 (테스트용)
-- ============================================

-- 시스템 설정 확인을 위한 더미 데이터 (선택사항)
INSERT IGNORE INTO system_logs (log_level, module_name, message) 
VALUES ('INFO', 'database_setup', 'MySQL 데이터베이스 초기화 완료');

-- ============================================
-- 권한 설정 (필요시)
-- ============================================

-- 애플리케이션 사용자 생성 및 권한 부여 (선택사항)
-- CREATE USER IF NOT EXISTS 'news_app'@'localhost' IDENTIFIED BY 'secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON news_analysis.* TO 'news_app'@'localhost';
-- FLUSH PRIVILEGES;

-- ============================================
-- 데이터베이스 최적화
-- ============================================

-- 테이블 최적화
OPTIMIZE TABLE news_articles;
OPTIMIZE TABLE analysis_results;
OPTIMIZE TABLE keyword_extractions;
OPTIMIZE TABLE system_logs;
OPTIMIZE TABLE api_usage_logs;
OPTIMIZE TABLE user_sessions;

-- 완료 메시지
SELECT 'News Analysis Database Setup Complete!' as status,
       VERSION() as mysql_version,
       NOW() as setup_time;
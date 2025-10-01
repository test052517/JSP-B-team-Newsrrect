CREATE DATABASE newsrrect;
USE newsrrect;

-- 1. user 테이블
CREATE TABLE `user` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('관리자', '사용자') NOT NULL DEFAULT '사용자',
    `nickname` VARCHAR(100) UNIQUE NOT NULL,
    `created_at` VARCHAR(19) NOT NULL,
    `is_active` INT(1) NOT NULL DEFAULT 1,
    `ban_count` INT NOT NULL DEFAULT 0,
    `report_count` INT NOT NULL DEFAULT 0,
    `point` INT NOT NULL DEFAULT 0,
    `attend` VARCHAR(19),
    `introduce` TEXT(1000),
    `profileimage` VARCHAR(255)
);

-- 2. post 테이블
CREATE TABLE `post` (
    `post_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `title` VARCHAR(300) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `status` ENUM('비공개', '공개', '신고 처리 중', '삭제') NOT NULL,
    `view_count` INT NOT NULL DEFAULT 0,
    `created_at` VARCHAR(19) NOT NULL,
    `report_count` INT NOT NULL DEFAULT 0,
    `recommand_count` INT NOT NULL DEFAULT 0,
    `priority` INT NOT NULL DEFAULT 0,
    INDEX idx_status (status),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at),
    `attache` VARCHAR(255)
);

-- 3. comment 테이블
CREATE TABLE `comment` (
    `comment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `post_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `layer` INT NOT NULL DEFAULT 0,
    `parent_comment_id` INT NULL,
    `content` TEXT NOT NULL,
    `judgment` ENUM('참', '거짓', '모호') NULL,
    `status` ENUM('비공개', '공개', '신고 처리 중', '삭제') NOT NULL,
    `upvotes` INT NOT NULL DEFAULT 0,
    `created_at` VARCHAR(19) NOT NULL,
    `report_count` INT NOT NULL DEFAULT 0,
    INDEX idx_judgment (judgment),
    INDEX idx_post_id (post_id),
    INDEX idx_created_at (created_at),
    `attache` VARCHAR(255)
);

-- 4. post_report 테이블
CREATE TABLE `post_report` (
    `reportPost_id` INT AUTO_INCREMENT PRIMARY KEY,
    `post_id` INT NOT NULL,
    `reporter_id` INT NOT NULL,
    `reason` VARCHAR(500),
    INDEX idx_post_id (post_id),
    INDEX idx_reporter_id (reporter_id)
);

-- 5. comment_report 테이블
CREATE TABLE `comment_report` (
    `reportComment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `comment_id` INT NOT NULL,
    `reporter_id` INT NOT NULL,
    `reason` VARCHAR(500), 
    INDEX idx_comment_id (comment_id),
    INDEX idx_reporter_id (reporter_id)
);

-- 6. ban 테이블
CREATE TABLE `ban` (
    `ban_id` INT AUTO_INCREMENT PRIMARY KEY,
    `banned_user_id` INT NOT NULL,
    `reason` VARCHAR(500),
    `ban_end_date` VARCHAR(19) NULL,
    INDEX idx_banned_user (banned_user_id)
);

-- 7. Comment_like 테이블
CREATE TABLE `Comment_like` (
    `likeComment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `comment_id` INT NOT NULL,
    `like_id` INT NOT NULL, -- (user_id)
    `created_at` VARCHAR(19) NOT NULL,
    
    UNIQUE KEY `uk_comment_user_like` (`comment_id`, `like_id`) 
);

-- ============================================
-- 외래키(FK) 제약조건 추가
-- ============================================

-- post 테이블 FK
ALTER TABLE `post`
    ADD CONSTRAINT `fk_post_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE;

-- comment 테이블 FK
ALTER TABLE `comment`
    ADD CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `post`(`post_id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_comment_id`) REFERENCES `comment`(`comment_id`) ON DELETE CASCADE;

-- post_report 테이블 FK
ALTER TABLE `post_report`
    ADD CONSTRAINT `fk_post_report_post` FOREIGN KEY (`post_id`) REFERENCES `post`(`post_id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_post_report_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE;

-- comment_report 테이블 FK
ALTER TABLE `comment_report`
    ADD CONSTRAINT `fk_comment_report_comment` FOREIGN KEY (`comment_id`) REFERENCES `comment`(`comment_id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_comment_report_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE;

-- ban 테이블 FK
ALTER TABLE `ban`
    ADD CONSTRAINT `fk_ban_banned_user` FOREIGN KEY (`banned_user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE;
    
-- Comment_like 테이블 FK
ALTER TABLE `Comment_like`
    ADD CONSTRAINT `fk_comment_like_comment` FOREIGN KEY (`comment_id`) REFERENCES `comment`(`comment_id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_comment_like_user` FOREIGN KEY (`like_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE;

DROP TRIGGER IF EXISTS after_post_report_insert;

-- 2. 새로운 트리거를 생성합니다.
DELIMITER $$
CREATE TRIGGER after_post_report_insert
AFTER INSERT ON post_report
FOR EACH ROW
BEGIN
    -- post 테이블의 report_count를 1 증가시킵니다.
    UPDATE post 
    SET report_count = report_count + 1 
    WHERE post_id = NEW.post_id;

    -- report_count가 5 이상이고, 현재 상태가 '공개'인 경우에만 '신고 처리 중'으로 변경합니다.
    UPDATE post
    SET status = '신고 처리 중'
    WHERE post_id = NEW.post_id 
      AND report_count >= 5
      AND status = '공개';
END$$
DELIMITER ;
    
    -- 1. 기존 트리거가 있다면 삭제합니다.
DROP TRIGGER IF EXISTS after_comment_report_insert;

-- 2. 새로운 트리거를 생성합니다.
DELIMITER $$
CREATE TRIGGER after_comment_report_insert
AFTER INSERT ON comment_report
FOR EACH ROW
BEGIN
    -- comment 테이블의 report_count를 1 증가시킵니다.
    UPDATE comment 
    SET report_count = report_count + 1 
    WHERE comment_id = NEW.comment_id;
    
    -- report_count가 5 이상이고, 현재 상태가 '공개'인 경우에만 '신고 처리 중'으로 변경합니다.
    UPDATE comment
    SET status = '신고 처리 중'
    WHERE comment_id = NEW.comment_id 
      AND report_count >= 5
      AND status = '공개';
END$$
DELIMITER ;
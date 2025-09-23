CREATE DATABASE newsrrect;
USE newsrrect;

-- 1. user 테이블
CREATE TABLE `user` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('관리자', '사용자') NOT NULL,
    `nickname` VARCHAR(100) UNIQUE NOT NULL,
    `created_at` VARCHAR(19) NOT NULL,
    `is_active` INT(1) NOT NULL,
    `point` INT NOT NULL,
    `image` BLOB,
    `attend` VARCHAR(19) NOT NULL,
    `introduce` TEXT
);

-- 2. attachment 테이블
CREATE TABLE `attachment` (
    `attachmentFile_id` INT AUTO_INCREMENT PRIMARY KEY,
    `file` BLOB NOT NULL
);

-- 3. post 테이블
CREATE TABLE `post` (
    `post_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `title` VARCHAR(300) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `status` ENUM('비공개', '공개', '신고 처리 중') NOT NULL,
    `view_count` INT NOT NULL,
    `created_at` VARCHAR(19) NOT NULL,
    `attachmentFile_id` INT,
    `report_count` INT NOT NULL,
    `recommand_count` INT NOT NULL,
    INDEX (status),
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`attachmentFile_id`) REFERENCES `attachment`(`attachmentFile_id`)
);

-- 4. comment 테이블
CREATE TABLE `comment` (
    `comment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `post_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `layer` INT NOT NULL,
    `content` LONGTEXT NOT NULL,
    `judgment` ENUM('참', '거짓', '모호'),
    `upvotes` INT NOT NULL,
    `created_at` VARCHAR(19) NOT NULL,
    `attachmentFile_id` INT,
    `report_count` INT NOT NULL,
    INDEX (judgment),
    FOREIGN KEY (`post_id`) REFERENCES `post`(`post_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`attachmentFile_id`) REFERENCES `attachment`(`attachmentFile_id`)
);

-- 6. post_report 테이블 (수정됨)
CREATE TABLE `post_report` (
    `reportPost_id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(300) NOT NULL,
    `post_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `reason` VARCHAR(255),
    `attachment_id` INT,
    `reported_id` INT NOT NULL,
    FOREIGN KEY (`post_id`) REFERENCES `post`(`post_id`),
    FOREIGN KEY (`reported_id`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`attachment_id`) REFERENCES `attachment`(`attachmentFile_id`)
);

-- 7. comment_report 테이블 (수정됨)
CREATE TABLE `comment_report` (
    `reportComment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `comment_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `reason` VARCHAR(255),
    `attachment_id` INT,
    `reported_id` INT NOT NULL,
    FOREIGN KEY (`comment_id`) REFERENCES `comment`(`comment_id`),
    FOREIGN KEY (`reported_id`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`attachment_id`) REFERENCES `attachment`(`attachmentFile_id`)
);

-- 8. post_report_user 테이블 (수정됨)
CREATE TABLE `post_report_user` (
    `reportUser_ID` INT AUTO_INCREMENT PRIMARY KEY,
    `log_id` INT NOT NULL,
    `nickname` VARCHAR(100) NOT NULL,
    `user_id` INT NOT NULL,
    `reportPost_id` INT NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`nickname`) REFERENCES `user`(`nickname`),
    FOREIGN KEY (`log_id`) REFERENCES `post_report`(`reportPost_id`),
    FOREIGN KEY (`reportPost_id`) REFERENCES `post_report`(`reportPost_id`)
);

-- 9. comment_report_user 테이블 (수정됨)
CREATE TABLE `comment_report_user` (
    `reportUser_ID` INT AUTO_INCREMENT PRIMARY KEY,
    `log_id` INT NOT NULL,
    `nickname` VARCHAR(100) NOT NULL,
    `user_id` INT NOT NULL,
    `reportComment_id` INT NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`nickname`) REFERENCES `user`(`nickname`),
    FOREIGN KEY (`log_id`) REFERENCES `comment_report`(`reportComment_id`),
    FOREIGN KEY (`reportComment_id`) REFERENCES `comment_report`(`reportComment_id`)
);

-- 10. deleted_posts 테이블 (수정됨)
CREATE TABLE `deleted_posts` (
    `deleted_id` INT AUTO_INCREMENT PRIMARY KEY,
    `post_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `title` VARCHAR(300) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `reason` VARCHAR(500) NOT NULL,
    FOREIGN KEY (`post_id`) REFERENCES `post`(`post_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`)
);

-- 11. deleted_comment 테이블 (수정됨)
CREATE TABLE `deleted_comment` (
    `deletedComment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `comment_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `type` ENUM('정보', '소통') NOT NULL,
    `content` LONGTEXT NOT NULL,
    `reason` VARCHAR(500) NOT NULL,
    FOREIGN KEY (`comment_id`) REFERENCES `comment`(`comment_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`)
);

-- 12. ban 테이블
CREATE TABLE `ban` (
    `ban_id` INT AUTO_INCREMENT PRIMARY KEY,
    `ban_user` INT NOT NULL,
    `nickname` VARCHAR(100) NOT NULL,
    `reason` VARCHAR(255),
    `ban_date` VARCHAR(19),
    FOREIGN KEY (`ban_user`) REFERENCES `user`(`user_id`),
    FOREIGN KEY (`nickname`) REFERENCES `user`(`nickname`)
);
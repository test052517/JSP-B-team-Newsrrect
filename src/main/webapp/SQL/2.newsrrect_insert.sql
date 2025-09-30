INSERT INTO `user` (
    `email`,
    `password`,
    `role`,
    `nickname`,
    `created_at`,
    `is_active`,
    `ban_count`,
    `report_count`,
    `point`,
    `attend`,
    `introduce`
) VALUES (
    'test@example.com',
    'hashed_password_123',
    '사용자',
    '테스트유저1234',
    '2025-09-26 14:30:00',
    1,
    0,
    0,
    100,
    '2025-09-26 09:00:00',
    '안녕하세요! 새로 가입한 테스트 유저입니다. 뉴스렉트에서 좋은 기사들을 많이 읽고 싶어요!'
);

INSERT INTO `post` (`post_id`, `user_id`, `type`, `title`, `content`, `status`, `view_count`, `created_at`, `report_count`, `recommand_count`, `priority`) VALUES (1, 1, '정보', '2025년 최신 기술 트렌드 분석', '올해 주목해야 할 주요 기술 트렌드는 AI, 양자 컴퓨팅, 그리고 지속 가능한 기술입니다. 특히 생성형 AI는 모든 산업 분야에 큰 영향을 미칠 것으로 보입니다.', '공개', 152, '2025-09-27 10:00:00', 0, 15, 0);
INSERT INTO `post` (`post_id`, `user_id`, `type`, `title`, `content`, `status`, `view_count`, `created_at`, `report_count`, `recommand_count`, `priority`) VALUES (2, 1, '소통', '뉴스렉트 사용자분들, 가장 인상 깊었던 뉴스는 무엇인가요?', '최근에 접한 뉴스 중에서 오랫동안 기억에 남거나, 큰 영향을 주었던 뉴스가 있다면 함께 이야기 나누고 싶습니다. 댓글로 자유롭게 공유해주세요!', '공개', 89, '2025-09-27 14:20:00', 0, 8, 0);
INSERT INTO `post` (`post_id`, `user_id`, `type`, `title`, `content`, `status`, `view_count`, `created_at`, `report_count`, `recommand_count`, `priority`) VALUES (3, 1, '정보', '[스크랩] 기후 변화가 우리 식탁에 미치는 영향', '기후 변화로 인해 주요 곡물 생산량이 감소하고 있으며, 이는 곧 식량 가격 상승으로 이어질 수 있다는 전문가들의 경고가 나왔습니다. 이에 대한 대비가 필요해 보입니다.', '공개', 234, '2025-09-28 09:30:00', 0, 25, 0);
INSERT INTO `post` (`post_id`, `user_id`, `type`, `title`, `content`, `status`, `view_count`, `created_at`, `report_count`, `recommand_count`, `priority`) VALUES (4, 1, '소통', '다들 주말 계획 있으신가요?', '이번 주말 날씨가 정말 좋다고 하네요. 다들 어떤 계획을 가지고 계신지 궁금합니다. 좋은 장소나 활동이 있다면 추천 부탁드립니다!', '공개', 45, '2025-09-28 17:55:00', 0, 3, 0);

INSERT INTO `comment` (`post_id`, `user_id`, `type`, `content`, `status`, `created_at`) VALUES
(1, 1, '정보', '양자 컴퓨팅에 대한 부분이 특히 흥미롭네요. 잘 읽었습니다!', '공개', '2025-09-27 11:15:00'),
(1, 1, '정보', '생성형 AI가 산업에 미치는 영향에 대해 더 자세한 분석 자료가 있을까요?', '공개', '2025-09-27 13:40:00'),
(1, 1, '정보', '정리해주셔서 감사합니다. 최신 기술 트렌드를 한눈에 파악하기 좋네요.', '공개', '2025-09-27 16:22:00');

-- Post ID 2번 글 ('가장 인상 깊었던 뉴스는?')에 대한 댓글 3개
INSERT INTO `comment` (`post_id`, `user_id`, `type`, `content`, `status`, `created_at`) VALUES
(2, 1, '소통', '저는 최근에 읽은 우주 탐사 관련 뉴스가 가장 기억에 남아요. 인간의 도전 정신이 느껴져서 좋았습니다.', '공개', '2025-09-27 18:05:00'),
(2, 1, '소통', '며칠 전 지역 사회에 훈훈한 소식을 전해준 뉴스를 보고 마음이 따뜻해졌습니다.', '공개', '2025-09-27 21:19:00'),
(2, 1, '소통', '다들 다양한 뉴스를 보고 계시는군요! 저는 경제 동향 관련 뉴스를 주로 봅니다.', '공개', '2025-09-28 08:55:00');

-- Post ID 3번 글 ('기후 변화가 식탁에 미치는 영향')에 대한 댓글 3개
INSERT INTO `comment` (`post_id`, `user_id`, `type`, `content`, `status`, `created_at`) VALUES
(3, 1, '정보', '정말 심각한 문제네요. 스크랩해주셔서 감사합니다. 경각심을 가져야겠어요.', '공개', '2025-09-28 10:30:00'),
(3, 1, '정보', '생각보다 우리 생활에 더 가까운 문제였군요. 앞으로 식료품 소비 습관을 바꿔봐야겠습니다.', '공개', '2025-09-28 14:00:00'),
(3, 1, '정보', '좋은 의견들 감사합니다. 작은 실천부터 시작하는 것이 중요하겠네요.', '공개', '2025-09-28 15:20:00');

-- Post ID 4번 글 ('주말 계획 있으신가요?')에 대한 댓글 3개
INSERT INTO `comment` (`post_id`, `user_id`, `type`, `content`, `status`, `created_at`) VALUES
(4, 1, '소통', '저는 이번 주말에 가족들이랑 같이 공원에 나들이 가기로 했어요!', '공개', '2025-09-28 18:00:00'),
(4, 1, '소통', '날씨가 좋아서 자전거 라이딩을 계획 중입니다. 생각만 해도 신나네요!', '공개', '2025-09-28 19:15:00'),
(4, 1, '소통', '저는 그냥 집에서 편하게 쉬려구요. 다들 즐거운 주말 보내세요!', '공개', '2025-09-28 22:05:00');

-- 1. 기존에 같은 이름의 트리거가 있다면 삭제합니다.
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


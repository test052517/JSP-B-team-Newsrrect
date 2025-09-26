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
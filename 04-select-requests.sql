-- 1. Отримати список викладачів та кількість їхніх курсів
SELECT
    u.last_name || ' ' || u.first_name || ' ' || u.patronymic AS teacher_full_name,
    COUNT(c.id) AS courses_count
FROM teachers t
JOIN users u ON u.id = t.user_id
LEFT JOIN courses c ON c.teacher_id = t.id
GROUP BY u.last_name, u.first_name, u.patronymic, t.id
ORDER BY courses_count DESC;

-- 2. Показати матеріали курсу з їхніми темами
SELECT
    c.name AS course_name,
    tp.seq_id AS topic_number,
    tp.name AS topic_name,
    m.name AS material_name
FROM materials m
JOIN topics tp ON tp.id = m.topic_id
JOIN courses c ON c.id = tp.course_id
ORDER BY c.name, tp.seq_id;

-- 3. Знайти студентів, які не здали жодного тесту
SELECT
    u.last_name || ' ' || u.first_name AS student_name,
    sg.name AS group_name
FROM students s
JOIN users u ON u.id = s.user_id
JOIN study_groups sg ON sg.id = s.study_group_id
WHERE s.id NOT IN (
    SELECT DISTINCT student_id 
    FROM done_tests
);

-- 4. Отримати файли, прикріплені до питань тестів
SELECT
    te.name AS test_name,
    tq.name AS question_name,
    f.filename,
    f.mime_type,
    f.size_bytes
FROM files f
JOIN test_questions tq ON tq.id = f.test_question_id
JOIN tests te ON te.id = tq.test_id
WHERE f.test_question_id IS NOT NULL;

-- 5. Показати тести з прострочених матеріалів
SELECT
    te.name AS test_name,
    m.name AS material_name,
    mt.deadline,
    mt.max_rate
FROM materials_tests mt
JOIN tests te ON te.id = mt.test_id
JOIN materials m ON m.id = mt.material_id
WHERE mt.deadline < NOW();

-- 6. Отримати середній бал студентів за виконані завдання по групах
SELECT
    sg.name AS group_name,
    AVG(dt.rate) AS average_rate
FROM done_tasks dt
JOIN students s ON s.id = dt.student_id
JOIN study_groups sg ON sg.id = s.study_group_id
GROUP BY sg.name
ORDER BY average_rate DESC;

-- 7. Знайти викладачів, які мають права оцінювання на курсах інших викладачів
SELECT
    u2.last_name || ' ' || u2.first_name AS course_owner,
    u1.last_name || ' ' || u1.first_name AS accessor_teacher,
    c.name AS course_name
FROM course_access_lists cal
JOIN teachers t1 ON t1.id = cal.teacher_id
JOIN users u1 ON u1.id = t1.user_id
JOIN courses c ON c.id = cal.course_id
JOIN teachers t2 ON t2.id = c.teacher_id
JOIN users u2 ON u2.id = t2.user_id
WHERE t1.id != t2.id AND cal.rate = TRUE;

-- 8. Показати завдання без жодної здачі
SELECT
    m.name AS material_name,
    t.max_rate
FROM tasks t
JOIN materials m ON m.id = t.material_id
LEFT JOIN done_tasks dt ON dt.task_id = t.id
WHERE dt.id IS NULL;

-- 9. Отримати файли, прикріплені до виконаних завдань студентів
SELECT
    u.last_name || ' ' || u.first_name AS student_name,
    m.name AS material_name,
    f.filename,
    f.created_at
FROM files f
JOIN done_tasks dt ON dt.id = f.done_task_id
JOIN students s ON s.id = dt.student_id
JOIN users u ON u.id = s.user_id
JOIN tasks t ON t.id = dt.task_id
JOIN materials m ON m.id = t.material_id
WHERE f.done_task_id IS NOT NULL;

-- 10. Показати варіанти відповідей із прикріпленими файлами
SELECT
    tq.name AS question_name,
    qo.option AS option_text,
    f.filename,
    f.mime_type
FROM files f
JOIN question_options qo ON qo.id = f.question_option_id
JOIN test_questions tq ON tq.id = qo.test_question_id
WHERE f.question_option_id IS NOT NULL;

-- 11. Знайти курси без жодної призначеної групи
SELECT
    c.name AS course_name,
    u.last_name || ' ' || u.first_name AS teacher_name
FROM courses c
JOIN teachers t ON t.id = c.teacher_id
JOIN users u ON u.id = t.user_id
LEFT JOIN courses_study_groups csg ON csg.course_id = c.id
WHERE csg.id IS NULL;

-- 12. Отримати кількість правильних та неправильних відповідей у кожному питанні
SELECT
    te.name AS test_name,
    tq.name AS question_name,
    SUM(CASE WHEN qo.is_correct THEN 1 ELSE 0 END) AS correct_options,
    SUM(CASE WHEN NOT qo.is_correct THEN 1 ELSE 0 END) AS incorrect_options
FROM question_options qo
JOIN test_questions tq ON tq.id = qo.test_question_id
JOIN tests te ON te.id = tq.test_id
GROUP BY te.name, tq.name, tq.id
ORDER BY te.name;

-- 13. Показати студентів та їхні результати тестів із часом здачі
SELECT
    u.last_name || ' ' || u.first_name AS student_name,
    te.name AS test_name,
    dt.rate AS received_rate,
    mt.max_rate,
    dt.passed_at
FROM done_tests dt
JOIN students s ON s.id = dt.student_id
JOIN users u ON u.id = s.user_id
JOIN materials_tests mt ON mt.id = dt.material_tests_id
JOIN tests te ON te.id = mt.test_id
ORDER BY dt.passed_at DESC;

-- 14. Знайти теми курсів без матеріалів
SELECT
    c.name AS course_name,
    tp.name AS topic_name,
    tp.seq_id
FROM topics tp
JOIN courses c ON c.id = tp.course_id
LEFT JOIN materials m ON m.topic_id = tp.id
WHERE m.id IS NULL;

-- 15. Отримати студентів з балом вище середнього по їхній групі
SELECT
    u.last_name || ' ' || u.first_name AS student_name,
    sg.name AS group_name,
    AVG(dt.rate) AS student_avg_rate
FROM done_tasks dt
JOIN students s ON s.id = dt.student_id
JOIN users u ON u.id = s.user_id
JOIN study_groups sg ON sg.id = s.study_group_id
GROUP BY s.id, u.last_name, u.first_name, sg.name, sg.id
HAVING AVG(dt.rate) > (
    SELECT AVG(dt2.rate)
    FROM done_tasks dt2
    JOIN students s2 ON s2.id = dt2.student_id
    WHERE s2.study_group_id = sg.id
);

-- 16. Показати файли матеріалів з інформацією про теми
SELECT
    c.name AS course_name,
    tp.name AS topic_name,
    m.name AS material_name,
    f.filename,
    f.size_bytes
FROM files f
JOIN materials m ON m.id = f.material_id
JOIN topics tp ON tp.id = m.topic_id
JOIN courses c ON c.id = tp.course_id
WHERE f.material_id IS NOT NULL
ORDER BY c.name, tp.seq_id;

-- 17. Знайти тести з максимальною кількістю питань
SELECT
    te.name AS test_name,
    COUNT(tq.id) AS questions_count
FROM tests te
JOIN test_questions tq ON tq.test_id = te.id
GROUP BY te.id, te.name
HAVING COUNT(tq.id) = (
    SELECT MAX(q_count)
    FROM (
        SELECT COUNT(*) AS q_count
        FROM test_questions
        GROUP BY test_id
    ) AS subquery
);

-- 18. Отримати загальний розмір файлів по типах MIME
SELECT
    f.mime_type,
    COUNT(f.id) AS files_count,
    SUM(f.size_bytes) AS total_size_bytes,
    ROUND(SUM(f.size_bytes) / 1024.0 / 1024.0, 2) AS total_size_mb
FROM files f
WHERE f.material_id IS NOT NULL
GROUP BY f.mime_type
ORDER BY total_size_bytes DESC;

-- 19. Показати курси та кількість їхні активні тести з дедлайнами
SELECT
    c.name AS course_name,
    COUNT(DISTINCT mt.test_id) AS active_tests_count,
    MIN(mt.deadline) AS nearest_deadline
FROM courses c
JOIN topics tp ON tp.course_id = c.id
JOIN materials m ON m.topic_id = tp.id
JOIN materials_tests mt ON mt.material_id = m.id
WHERE mt.deadline > NOW()
GROUP BY c.id, c.name
ORDER BY nearest_deadline;

-- 20. Знайти курси, де є завдання з максимальним балом вище за середній (з підзапитом)
SELECT
    c.name AS course_name,
    u.last_name || ' ' || u.first_name AS teacher_name,
    MAX(t.max_rate) AS highest_task_rate
FROM courses c
JOIN teachers tea ON tea.id = c.teacher_id
JOIN users u ON u.id = tea.user_id
JOIN topics tp ON tp.course_id = c.id
JOIN materials m ON m.topic_id = tp.id
JOIN tasks t ON t.material_id = m.id
GROUP BY c.id, c.name, u.last_name, u.first_name
HAVING MAX(t.max_rate) > (
    SELECT AVG(max_rate)
    FROM tasks
);
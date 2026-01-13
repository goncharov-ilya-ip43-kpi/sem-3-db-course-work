-- СТВОРЕННЯ



-- Отримати ПІБ усіх студентів і їхні навчальні групи
CREATE VIEW v_students_by_groups AS
SELECT
    u.last_name,
    u.first_name,
    u.patronymic,
    sg.name AS study_group_name,
    sg.semester
FROM students s
JOIN users u ON u.id = s.user_id
JOIN study_groups sg ON sg.id = s.study_group_id;

-- Отрмати курси, призначені групи і ПІБ викладачів
CREATE VIEW v_courses_for_groups AS
SELECT
    c.id AS course_id,
    c.name AS course_name,
    STRING_AGG(sg.name, ', ' ORDER BY sg.name) AS study_groups,
    u.last_name AS teacher_last_name,
    u.first_name AS teacher_first_name
FROM courses c
JOIN teachers t ON t.id = c.teacher_id
JOIN users u ON u.id = t.user_id
JOIN courses_study_groups csg ON csg.course_id = c.id
JOIN study_groups sg ON sg.id = csg.study_group_id
GROUP BY c.id, c.name, u.last_name, u.first_name;;

-- Отримати результати навчання студентів
CREATE VIEW v_student_learning_results AS
SELECT
    s.id AS student_id,
    u.last_name,
    u.first_name,
    c.id AS course_id,
    c.name AS course_name,
    COALESCE(SUM(dt.rate), 0) AS tasks_rate,
    COALESCE(SUM(dtest.rate), 0) AS tests_rate
FROM students s
JOIN users u ON u.id = s.user_id
JOIN study_groups sg ON sg.id = s.study_group_id
JOIN courses_study_groups csg ON csg.study_group_id = sg.id
JOIN courses c ON c.id = csg.course_id
LEFT JOIN topics tp ON tp.course_id = c.id
LEFT JOIN materials m ON m.topic_id = tp.id
LEFT JOIN tasks tsk ON tsk.material_id = m.id
LEFT JOIN done_tasks dt ON dt.task_id = tsk.id AND dt.student_id = s.id
LEFT JOIN materials_tests mt ON mt.material_id = m.id
LEFT JOIN done_tests dtest ON dtest.material_tests_id = mt.id AND dtest.student_id = s.id
GROUP BY
    s.id, u.last_name, u.first_name, c.id, c.name;



-- ТЕСТУВАННЯ



SELECT * FROM v_students_by_groups;
SELECT * FROM v_courses_for_groups;
SELECT * FROM v_student_learning_results;
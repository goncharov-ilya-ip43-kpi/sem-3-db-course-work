-- СТВОРЕННЯ



-- Обчислює загальний бал студента по курсу
CREATE OR REPLACE FUNCTION get_student_course_total_rate(p_student_id INT, p_course_id INT)
RETURNS INT AS $$
DECLARE
    total_rate INT;
BEGIN
    SELECT COALESCE(SUM(dt.rate), 0) + COALESCE(SUM(dtest.rate), 0)
    INTO total_rate
    FROM students s
    JOIN study_groups sg ON sg.id = s.study_group_id
    JOIN courses_study_groups csg ON csg.study_group_id = sg.id
    JOIN courses c ON c.id = csg.course_id
    LEFT JOIN topics tp ON tp.course_id = c.id
    LEFT JOIN materials m ON m.topic_id = tp.id
    LEFT JOIN tasks tsk ON tsk.material_id = m.id
    LEFT JOIN done_tasks dt ON dt.task_id = tsk.id AND dt.student_id = s.id
    LEFT JOIN materials_tests mt ON mt.material_id = m.id
    LEFT JOIN done_tests dtest ON dtest.material_tests_id = mt.id AND dtest.student_id = s.id
    WHERE s.id = p_student_id AND c.id = p_course_id;
    
    RETURN total_rate;
END;
$$ LANGUAGE plpgsql;

-- Повертає кількість непрочитаних матеріалів студента по курсу
CREATE OR REPLACE FUNCTION get_unread_materials_count(p_student_id INT, p_course_id INT)
RETURNS INT AS $$
DECLARE
    unread_count INT;
BEGIN
    SELECT COUNT(DISTINCT m.id)
    INTO unread_count
    FROM materials m
    JOIN topics tp ON tp.id = m.topic_id
    JOIN courses c ON c.id = tp.course_id
    JOIN courses_study_groups csg ON csg.course_id = c.id
    JOIN students s ON s.study_group_id = csg.study_group_id
    LEFT JOIN tasks tsk ON tsk.material_id = m.id
    LEFT JOIN done_tasks dt ON dt.task_id = tsk.id AND dt.student_id = s.id
    LEFT JOIN materials_tests mt ON mt.material_id = m.id
    LEFT JOIN done_tests dtest ON dtest.material_tests_id = mt.id AND dtest.student_id = s.id
    WHERE s.id = p_student_id 
        AND c.id = p_course_id
        AND dt.id IS NULL 
        AND dtest.id IS NULL;
    
    RETURN unread_count;
END;
$$ LANGUAGE plpgsql;

-- Перевіряє чи студент має доступ до курсу
CREATE OR REPLACE FUNCTION check_student_course_access(p_student_id INT, p_course_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    has_access BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1
        FROM students s
        JOIN courses_study_groups csg ON csg.study_group_id = s.study_group_id
        WHERE s.id = p_student_id AND csg.course_id = p_course_id
    ) INTO has_access;
    
    RETURN has_access;
END;
$$ LANGUAGE plpgsql;

-- Обчислює максимально можливий бал по курсу
CREATE OR REPLACE FUNCTION get_course_max_rate(p_course_id INT)
RETURNS INT AS $$
DECLARE
    max_rate INT;
BEGIN
    SELECT COALESCE(SUM(tsk.max_rate), 0) + COALESCE(SUM(mt.max_rate), 0)
    INTO max_rate
    FROM courses c
    LEFT JOIN topics tp ON tp.course_id = c.id
    LEFT JOIN materials m ON m.topic_id = tp.id
    LEFT JOIN tasks tsk ON tsk.material_id = m.id
    LEFT JOIN materials_tests mt ON mt.material_id = m.id
    WHERE c.id = p_course_id;
    
    RETURN max_rate;
END;
$$ LANGUAGE plpgsql;

-- Повертає список студентів групи з їхніми email-адресами
CREATE OR REPLACE FUNCTION get_group_students_info(p_study_group_id INT)
RETURNS TABLE(
    student_id INT,
    full_name TEXT,
    login VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        u.last_name || ' ' || u.first_name || ' ' || u.patronymic,
        u.login
    FROM students s
    JOIN users u ON u.id = s.user_id
    WHERE s.study_group_id = p_study_group_id
    ORDER BY u.last_name, u.first_name;
END;
$$ LANGUAGE plpgsql;



-- ТЕСТУВАННЯ



-- Тест функції обчислення загального балу студента
SELECT get_student_course_total_rate(1, 1) AS total_rate;

-- Тест функції підрахунку непрочитаних матеріалів
SELECT get_unread_materials_count(1, 1) AS unread_materials;

-- Тест функції перевірки доступу студента до курсу
SELECT check_student_course_access(1, 1) AS has_access;

-- Тест функції обчислення максимального балу курсу
SELECT get_course_max_rate(1) AS max_course_rate;

-- Тест функції отримання інформації про студентів групи
SELECT * FROM get_group_students_info(1);
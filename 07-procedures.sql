-- СТВОРЕННЯ



-- Додає нового студента до групи
CREATE OR REPLACE PROCEDURE add_student_to_group(
    p_login VARCHAR,
    p_password TEXT,
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_patronymic VARCHAR,
    p_study_group_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_user_id INT;
BEGIN
    INSERT INTO users (login, password, first_name, last_name, patronymic)
    VALUES (p_login, p_password, p_first_name, p_last_name, p_patronymic)
    RETURNING id INTO v_user_id;
    
    INSERT INTO students (user_id, study_group_id)
    VALUES (v_user_id, p_study_group_id);
    
    RAISE NOTICE 'Студента % % додано до групи', p_last_name, p_first_name;
END;
$$;

-- Переносить студента в іншу групу
CREATE OR REPLACE PROCEDURE transfer_student_to_group(
    p_student_id INT,
    p_new_study_group_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_old_group_name VARCHAR;
    v_new_group_name VARCHAR;
BEGIN
    SELECT sg.name INTO v_old_group_name
    FROM students s
    JOIN study_groups sg ON sg.id = s.study_group_id
    WHERE s.id = p_student_id;
    
    UPDATE students
    SET study_group_id = p_new_study_group_id
    WHERE id = p_student_id;
    
    SELECT name INTO v_new_group_name
    FROM study_groups
    WHERE id = p_new_study_group_id;
    
    RAISE NOTICE 'Студента переведено з групи % до групи %', v_old_group_name, v_new_group_name;
END;
$$;

-- Видаляє всі матеріали теми разом з пов'язаними даними
CREATE OR REPLACE PROCEDURE delete_topic_with_materials(p_topic_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_materials_count INT;
BEGIN
    SELECT COUNT(*) INTO v_materials_count
    FROM materials
    WHERE topic_id = p_topic_id;
    
    DELETE FROM done_tasks
    WHERE task_id IN (
        SELECT t.id FROM tasks t
        JOIN materials m ON m.id = t.material_id
        WHERE m.topic_id = p_topic_id
    );
    
    DELETE FROM done_tests
    WHERE material_tests_id IN (
        SELECT mt.id FROM materials_tests mt
        JOIN materials m ON m.id = mt.material_id
        WHERE m.topic_id = p_topic_id
    );
    
    DELETE FROM tasks
    WHERE material_id IN (
        SELECT id FROM materials WHERE topic_id = p_topic_id
    );
    
    DELETE FROM materials_tests
    WHERE material_id IN (
        SELECT id FROM materials WHERE topic_id = p_topic_id
    );
    
    DELETE FROM materials
    WHERE topic_id = p_topic_id;
    
    DELETE FROM topics
    WHERE id = p_topic_id;
    
    RAISE NOTICE 'Видалено тему разом з % матеріалами', v_materials_count;
END;
$$;

-- Оновлює семестр для всіх студентів групи
CREATE OR REPLACE PROCEDURE update_group_semester(
    p_study_group_id INT,
    p_new_semester SMALLINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_students_count INT;
BEGIN
    SELECT COUNT(*) INTO v_students_count
    FROM students
    WHERE study_group_id = p_study_group_id;
    
    UPDATE study_groups
    SET semester = p_new_semester
    WHERE id = p_study_group_id;
    
    RAISE NOTICE 'Оновлено семестр для групи (% студентів)', v_students_count;
END;
$$;

-- Призначає курс для групи
CREATE OR REPLACE PROCEDURE assign_course_to_group(
    p_course_id INT,
    p_study_group_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO courses_study_groups (course_id, study_group_id)
    VALUES (p_course_id, p_study_group_id)
    ON CONFLICT (course_id, study_group_id) DO NOTHING;
    
    RAISE NOTICE 'Курс призначено для групи';
END;
$$;



-- ТЕСТУВАННЯ ПРОЦЕДУР



CALL add_student_to_group('test_student', 'password123', 'Іван', 'Петренко', 'Олександрович', 1);

CALL transfer_student_to_group(1, 2);

CALL delete_topic_with_materials(1);

CALL update_group_semester(1, 3);

CALL assign_course_to_group(1, 1);
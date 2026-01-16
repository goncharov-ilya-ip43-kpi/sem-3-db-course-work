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

-- Рахує кількість файлів, що належать до матеріалів чи питань тесту
CREATE OR REPLACE PROCEDURE count_files_for_material_or_test(
    p_material_id INT DEFAULT NULL,
    p_test_question_id INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_files_count INT;
BEGIN
    IF p_material_id IS NULL AND p_test_question_id IS NULL THEN
        RAISE NOTICE 'Потрібно вказати material_id або test_question_id';
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_files_count
    FROM files
    WHERE (material_id = p_material_id OR p_material_id IS NULL)
      AND (test_question_id = p_test_question_id OR p_test_question_id IS NULL);

    RAISE NOTICE 'Знайдено % файлів', v_files_count;
END;
$$;

-- Оновлює семестр для групи
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



-- ТЕСТУВАННЯ



CALL add_student_to_group('test_student', 'password123', 'Іван', 'Петренко', 'Олександрович', 1);

CALL transfer_student_to_group(1, 2);

CALL count_files_for_material_or_test(p_material_id => 1, p_test_question_id => NULL);

CALL update_group_semester(1, 3::smallint);

CALL assign_course_to_group(1, 1);
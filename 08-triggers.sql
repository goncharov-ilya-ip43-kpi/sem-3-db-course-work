-- СТВОРЕННЯ



-- Забороняє встановлювати оцінку за завдання вище максимально дозволеної
CREATE OR REPLACE FUNCTION trg_done_tasks_rate_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rate IS NOT NULL
       AND NEW.rate > (SELECT max_rate FROM tasks WHERE id = NEW.task_id) THEN
        RAISE EXCEPTION 'Rate exceeds max_rate';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER done_tasks_rate_limit
BEFORE INSERT OR UPDATE ON done_tasks
FOR EACH ROW
EXECUTE FUNCTION trg_done_tasks_rate_limit();


-- Забороняє здачу завдання після дедлайну
CREATE OR REPLACE FUNCTION trg_done_tasks_deadline()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT deadline FROM tasks WHERE id = NEW.task_id) IS NOT NULL
       AND NOW() > (SELECT deadline FROM tasks WHERE id = NEW.task_id) THEN
        RAISE EXCEPTION 'Task deadline exceeded';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER done_tasks_deadline
BEFORE INSERT ON done_tasks
FOR EACH ROW
EXECUTE FUNCTION trg_done_tasks_deadline();


-- Забороняє студенту проходити тест, якщо матеріал не доступний його групі
CREATE OR REPLACE FUNCTION trg_done_tests_group_access()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM materials_tests mt
        JOIN materials m ON m.id = mt.material_id
        JOIN topics t ON t.id = m.topic_id
        JOIN courses c ON c.id = t.course_id
        JOIN courses_study_groups csg ON csg.course_id = c.id
        JOIN students s ON s.study_group_id = csg.study_group_id
        WHERE mt.id = NEW.material_tests_id
          AND s.id = NEW.student_id
    ) THEN
        RAISE EXCEPTION 'Student has no access to this test';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER done_tests_group_access
BEFORE INSERT ON done_tests
FOR EACH ROW
EXECUTE FUNCTION trg_done_tests_group_access();


-- Забороняє більше одного правильного варіанту для питання з одиничним вибором
CREATE OR REPLACE FUNCTION trg_single_question_one_correct()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_correct = TRUE
       AND (SELECT type FROM test_questions WHERE id = NEW.test_question_id) = 'single'
       AND EXISTS (
           SELECT 1
           FROM question_options
           WHERE test_question_id = NEW.test_question_id
             AND is_correct = TRUE
       ) THEN
        RAISE EXCEPTION 'Only one correct option allowed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER single_question_one_correct
BEFORE INSERT ON question_options
FOR EACH ROW
EXECUTE FUNCTION trg_single_question_one_correct();



-- Тестування



INSERT INTO done_tasks (task_id, student_id, rate)
VALUES (1, 1, 999);

INSERT INTO done_tasks (task_id, student_id, rate)
VALUES (1, 1, 1);

INSERT INTO done_tests (student_id, material_tests_id, rate)
VALUES (1, 1, 10);

INSERT INTO question_options (test_question_id, seq_id, option, is_correct)
VALUES (1, 1, 'A', TRUE);


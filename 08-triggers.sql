-- СТВОРЕННЯ



-- Перевіряє що оцінка за завдання не перевищує максимум
CREATE OR REPLACE FUNCTION check_done_task_rate()
RETURNS TRIGGER AS $$
DECLARE
    v_max_rate SMALLINT;
BEGIN
    SELECT max_rate INTO v_max_rate
    FROM tasks
    WHERE id = NEW.task_id;
    
    IF NEW.rate > v_max_rate THEN
        RAISE EXCEPTION 'Оцінка % перевищує максимальну оцінку % для завдання', NEW.rate, v_max_rate;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_done_task_rate
BEFORE INSERT OR UPDATE ON done_tasks
FOR EACH ROW
EXECUTE FUNCTION check_done_task_rate();

-- Перевіряє що оцінка за тест не перевищує максимум
CREATE OR REPLACE FUNCTION check_done_test_rate()
RETURNS TRIGGER AS $$
DECLARE
    v_max_rate SMALLINT;
BEGIN
    SELECT max_rate INTO v_max_rate
    FROM materials_tests
    WHERE id = NEW.material_tests_id;
    
    IF NEW.rate > v_max_rate THEN
        RAISE EXCEPTION 'Оцінка % перевищує максимальну оцінку % для тесту', NEW.rate, v_max_rate;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_done_test_rate
BEFORE INSERT OR UPDATE ON done_tests
FOR EACH ROW
EXECUTE FUNCTION check_done_test_rate();

-- Автоматично встановлює timestamp при здачі тесту
CREATE OR REPLACE FUNCTION set_test_passed_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.passed_at IS NULL THEN
        NEW.passed_at := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_test_passed_timestamp
BEFORE INSERT ON done_tests
FOR EACH ROW
EXECUTE FUNCTION set_test_passed_timestamp();

-- Перевіряє що в тесті типу single є лише одна правильна відповідь
CREATE OR REPLACE FUNCTION check_single_question_correct_answer()
RETURNS TRIGGER AS $$
DECLARE
    v_question_type question_types;
    v_correct_count INT;
BEGIN
    SELECT type INTO v_question_type
    FROM test_questions
    WHERE id = NEW.test_question_id;
    
    IF v_question_type = 'single' AND NEW.is_correct = TRUE THEN
        SELECT COUNT(*) INTO v_correct_count
        FROM question_options
        WHERE test_question_id = NEW.test_question_id 
            AND is_correct = TRUE
            AND id != COALESCE(NEW.id, -1);
        
        IF v_correct_count > 0 THEN
            RAISE EXCEPTION 'Питання типу single може мати лише одну правильну відповідь';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_single_question_correct_answer
BEFORE INSERT OR UPDATE ON question_options
FOR EACH ROW
EXECUTE FUNCTION check_single_question_correct_answer();

-- Логує створення нових файлів у системі
CREATE TABLE IF NOT EXISTS files_audit_log (
    id SERIAL PRIMARY KEY,
    file_id INT NOT NULL,
    filename TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION log_new_file()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO files_audit_log (file_id, filename)
    VALUES (NEW.id, NEW.filename);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_new_file
AFTER INSERT ON files
FOR EACH ROW
EXECUTE FUNCTION log_new_file();



-- ТЕСТУВАННЯ



INSERT INTO done_tasks (task_id, student_id, rate) VALUES (1, 1, 999);

INSERT INTO done_tests (student_id, material_tests_id, rate) VALUES (1, 1, 999);

INSERT INTO done_tests (student_id, material_tests_id, rate) VALUES (1, 1, 50);

INSERT INTO question_options (test_question_id, seq_id, option, is_correct) VALUES (1, 1, 'Відповідь 1', TRUE);

INSERT INTO files (path, filename, mime_type, size_bytes) VALUES ('/uploads', 'test.pdf', 'application/pdf', 1024);
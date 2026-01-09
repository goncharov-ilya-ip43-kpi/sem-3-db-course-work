-- 1
CREATE TABLE IF NOT EXISTS users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login VARCHAR(30) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    patronymic VARCHAR(30) NOT NULL
);

-- 2
CREATE TABLE IF NOT EXISTS study_groups (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(10) NOT NULL UNIQUE,
    semester SMALLINT NOT NULL CHECK(semester > 0 AND semester < 20)
);

-- 3
CREATE TABLE IF NOT EXISTS students (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    study_group_id INT NOT NULL REFERENCES study_groups(id),

    UNIQUE (user_id, study_group_id)
);

-- 4
CREATE TABLE IF NOT EXISTS teachers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES users(id)
);

-- 5
CREATE TABLE IF NOT EXISTS courses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    teacher_id INT NOT NULL REFERENCES teachers(id),
    name VARCHAR(100) NOT NULL
);

-- 6
CREATE TABLE IF NOT EXISTS courses_study_groups (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(id),
    study_group_id INT NOT NULL REFERENCES study_groups(id),

    UNIQUE (course_id, study_group_id)
);

-- 7
CREATE TABLE IF NOT EXISTS course_access_lists (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    teacher_id INT NOT NULL REFERENCES teachers(id),
    course_id INT NOT NULL REFERENCES courses(id),
    rate BOOLEAN NOT NULL,
    write BOOLEAN NOT NULL,
    manage_students BOOLEAN NOT NULL,

    UNIQUE (teacher_id, course_id)
);


-- 8
CREATE TABLE IF NOT EXISTS topics (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses(id),
    seq_id INT NOT NULL CHECK (seq_id > 0),
    name VARCHAR(100) NOT NULL,
    description VARCHAR(3000)
);

-- 9
CREATE TABLE IF NOT EXISTS materials (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    topic_id INT NOT NULL REFERENCES topics(id),
    name VARCHAR(100),
    description VARCHAR(3000),

    UNIQUE(topic_id, name)
);

-- 10
CREATE TABLE IF NOT EXISTS tasks (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_id INT NOT NULL REFERENCES materials(id),
    max_rate SMALLINT NOT NULL CHECK (max_rate >= 0)
);

-- 11
CREATE TABLE IF NOT EXISTS done_tasks (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id INT NOT NULL REFERENCES tasks(id),
    student_id INT NOT NULL REFERENCES students(id),
    rate SMALLINT CHECK (rate >= 0),

    UNIQUE (task_id, student_id)
);

-- 12
CREATE TABLE IF NOT EXISTS tests (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- 13
CREATE TABLE IF NOT EXISTS materials_tests (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_id INT NOT NULL REFERENCES materials(id),
    test_id INT NOT NULL REFERENCES tests(id),
    max_rate SMALLINT NOT NULL CHECK (max_rate >= 0),
    deadline TIMESTAMP WITH TIME ZONE,

    UNIQUE (material_id, test_id)
);

-- 14
CREATE TABLE IF NOT EXISTS test_questions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    test_id INT NOT NULL REFERENCES tests(id),
    name VARCHAR(100) NOT NULL,
    description VARCHAR(3000) NOT NULL,
    max_rate SMALLINT NOT NULL CHECK (max_rate >= 0)
);

-- 15
CREATE TABLE IF NOT EXISTS question_options (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    test_question_id INT NOT NULL REFERENCES test_questions(id),
    seq_id SMALLINT NOT NULL CHECK (seq_id > 0),
    option VARCHAR(3000) NOT NULL,

    UNIQUE(test_question_id, seq_id)
);

-- 16
CREATE TABLE IF NOT EXISTS question_answers (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_option_id INT NOT NULL UNIQUE REFERENCES question_options(id)
);

-- 17
CREATE TABLE IF NOT EXISTS done_tests (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT NOT NULL REFERENCES students(id),
    material_tests_id INT NOT NULL REFERENCES materials_tests(id),
    rate SMALLINT CHECK (rate >= 0),
    passed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 18
CREATE TABLE IF NOT EXISTS files (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    path TEXT NOT NULL,
    filename TEXT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE (path, filename)
);

-- 19
CREATE TABLE IF NOT EXISTS options_files (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_option_id INT NOT NULL REFERENCES question_options(id),
    file_id INT NOT NULL REFERENCES files(id),

    UNIQUE (question_option_id, file_id)
);

-- 20
CREATE TABLE IF NOT EXISTS question_files (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    test_question_id INT NOT NULL REFERENCES test_questions(id),
    file_id INT NOT NULL REFERENCES files(id),

    UNIQUE (test_question_id, file_id)
);

-- 21
CREATE TABLE IF NOT EXISTS done_tasks_files (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    done_task_id INT NOT NULL REFERENCES done_tasks(id),
    file_id INT NOT NULL REFERENCES files(id),

    UNIQUE (done_task_id, file_id)
);

-- 22
CREATE TABLE IF NOT EXISTS material_files (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_id INT NOT NULL REFERENCES materials(id),
    file_id INT NOT NULL REFERENCES files(id),

    UNIQUE (material_id, file_id)
);
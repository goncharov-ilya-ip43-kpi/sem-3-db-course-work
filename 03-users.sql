BEGIN;

-- Створення ролей і користувачів
CREATE ROLE role_teacher;
CREATE ROLE role_student;

CREATE USER teacher_user WITH PASSWORD 'teacher_pass';
CREATE USER student_user WITH PASSWORD 'student_pass';

GRANT role_teacher TO teacher_user;
GRANT role_student TO student_user;

-- Видання дозволів викладачам
GRANT SELECT ON
    users,
    study_groups,
    students
TO role_teacher;

GRANT SELECT, INSERT, UPDATE, DELETE ON
    courses,
    courses_study_groups,
    course_access_lists,
    topics,
    materials,
    tasks,
    tests,
    materials_tests,
    test_questions,
    question_options
TO role_teacher;

GRANT SELECT, INSERT, UPDATE ON
    done_tasks,
    done_tests
TO role_teacher;

GRANT SELECT, INSERT ON
    files
TO role_teacher;

-- Видання дозволів студентам
GRANT SELECT ON
    study_groups,
    courses,
    courses_study_groups,
    topics,
    materials,
    tasks,
    tests,
    materials_tests,
    test_questions,
    question_options
TO role_student;

GRANT SELECT, INSERT ON
    done_tasks,
    done_tests,
    files
TO role_student;

COMMIT;
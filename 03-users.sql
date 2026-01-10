BEGIN;

-- Creating roles and users
CREATE ROLE role_teacher;
CREATE ROLE role_student;

CREATE USER teacher_user WITH PASSWORD 'teacher_pass';
CREATE USER student_user WITH PASSWORD 'student_pass';

GRANT role_teacher TO teacher_user;
GRANT role_student TO student_user;

-- Granting permissions for teachers on tables
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
    files,
    material_files,
    question_files,
    options_files,
    done_tasks_files
TO role_teacher;

-- Granting permissions for students on tables
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
    question_options,
    files,
    material_files,
    question_files,
    options_files
TO role_student;

GRANT SELECT, INSERT ON
    done_tasks,
    done_tests,
    done_tasks_files
TO role_student;

-- Granting permissions on views
GRANT SELECT ON
    v_students_by_groups,
    v_courses_for_groups
TO role_teacher;

GRANT SELECT ON
    v_student_learning_results
TO role_teacher, role_student;

COMMIT;
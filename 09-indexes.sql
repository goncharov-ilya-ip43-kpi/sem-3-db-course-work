-- Композитний індекс для прискорення пошуку завдань студента з дедлайном
CREATE INDEX idx_tasks_deadline_material ON tasks(deadline, material_id) 
WHERE deadline IS NOT NULL;

-- Знайти всі завдання з наближеними дедлайнами для конкретного студента
EXPLAIN ANALYZE
SELECT 
    u.last_name || ' ' || u.first_name AS student_name,
    c.name AS course_name,
    m.name AS material_name,
    t.max_rate,
    t.deadline,
    CASE 
        WHEN dt.id IS NOT NULL THEN 'Здано'
        ELSE 'Не здано'
    END AS status
FROM tasks t
JOIN materials m ON m.id = t.material_id
JOIN topics tp ON tp.id = m.topic_id
JOIN courses c ON c.id = tp.course_id
JOIN courses_study_groups csg ON csg.course_id = c.id
JOIN students s ON s.study_group_id = csg.study_group_id
JOIN users u ON u.id = s.user_id
LEFT JOIN done_tasks dt ON dt.task_id = t.id AND dt.student_id = s.id
WHERE s.id = 1
    AND t.deadline IS NOT NULL
    AND t.deadline > NOW()
    AND t.deadline < NOW() + INTERVAL '7 days'
ORDER BY t.deadline;
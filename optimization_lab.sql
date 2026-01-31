-- -------------------------------------------------------------
-- PERFORMANCE TUNING LAB
-- Objective: Optimize queries for a high-volume attendance table
-- -------------------------------------------------------------

-- SCENARIO: The admin dashboard is loading slowly when fetching 
-- a specific student's attendance history.

-- 1. THE SLOW QUERY
-- We want to find all 'Late' records for student ID 45 in the last month.
-- Without indexes, MySQL must scan ALL 100,000 rows (Full Table Scan).

SELECT * FROM attendance_logs 
WHERE student_id = 45 
AND scan_timestamp > DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- 2. PROOF OF SLOWNESS (Using EXPLAIN)
-- Run this to see the 'rows' column. It will likely show ~100,000 rows scanned.
EXPLAIN SELECT * FROM attendance_logs 
WHERE student_id = 45 
AND scan_timestamp > DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- -------------------------------------------------------------
-- THE SOLUTION: INDEXING STRATEGY
-- -------------------------------------------------------------

-- 3. Create a Composite Index
-- We index both 'student_id' (for filtering user) and 'scan_timestamp' (for filtering time).
-- This creates a sorted lookup structure.
CREATE INDEX idx_student_time ON attendance_logs(student_id, scan_timestamp);

-- 4. THE FAST QUERY
-- Run the exact same query again. It should be nearly instant.
SELECT * FROM attendance_logs 
WHERE student_id = 45 
AND scan_timestamp > DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- 5. PROOF OF SPEED
-- Run EXPLAIN again. The 'rows' column should drop from ~100,000 to < 50.
-- The 'key' column will now show 'idx_student_time'.
EXPLAIN SELECT * FROM attendance_logs 
WHERE student_id = 45 
AND scan_timestamp > DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- -------------------------------------------------------------
-- ANALYTICAL QUERIES (Reporting)
-- -------------------------------------------------------------

-- 6. Attendance Rate per Student
SELECT 
    s.full_name,
    COUNT(*) AS total_classes,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_count,
    ROUND(SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS attendance_rate
FROM attendance_logs a
JOIN students s ON a.student_id = s.student_id
GROUP BY s.student_id
ORDER BY attendance_rate DESC
LIMIT 10;

-- 7. "Habitual Latecomers" Report
SELECT s.full_name, COUNT(*) as late_count
FROM attendance_logs a
JOIN students s ON a.student_id = s.student_id
WHERE a.status = 'Late'
GROUP BY s.student_id
HAVING late_count > 5
ORDER BY late_count DESC;

-- 8. Low Confidence Detections (AI Monitor)
SELECT 
    l.log_id,
    s.full_name,
    l.confidence_score,
    l.scan_timestamp
FROM attendance_logs l
JOIN students s ON l.student_id = s.student_id
WHERE l.confidence_score < 90.0
ORDER BY l.confidence_score ASC
LIMIT 10;
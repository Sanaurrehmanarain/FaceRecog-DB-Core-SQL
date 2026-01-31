-- 1. Create Database
CREATE DATABASE IF NOT EXISTS attendance_db;
USE attendance_db;

-- 2. Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    face_embedding BLOB, -- Placeholder for AI face vector bytes
    enrollment_date DATE DEFAULT (CURRENT_DATE)
);

-- 3. Classes/Course Table (To link attendance to a subject)
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(50) NOT NULL,
    schedule_time TIME NOT NULL -- e.g., '09:00:00'
);

-- 4. Attendance Logs (The high-volume table)
CREATE TABLE attendance_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    scan_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Present', 'Late', 'Absent') DEFAULT 'Present',
    confidence_score FLOAT, -- AI confidence (e.g., 98.5%)
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Professors (
    professor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(100),
    department VARCHAR(100),
    professor_id INT,
    FOREIGN KEY (professor_id) REFERENCES Professors(professor_id)
);

CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade INT,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE Mandatory_Courses (
    course_id INT PRIMARY KEY,
    department VARCHAR(100),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);


INSERT INTO Students (student_id, name, email) VALUES
(1, 'Alice Brown', 'alice@uni.edu'),
(2, 'Bob Smith', 'bob@uni.edu'),
(3, 'Carol Jones', 'carol@uni.edu'),
(4, 'Dan Miller', 'dan@uni.edu'),
(5, 'Eve Davis', 'eve@uni.edu');

INSERT INTO Professors (professor_id, name, department) VALUES
(1, 'Dr. Newton', 'Physics'),
(2, 'Dr. Einstein', 'Math'),
(3, 'Dr. Curie', 'Chemistry'),
(4, 'Dr. Ada', 'Computer Science');

INSERT INTO Courses (course_id, title, department, professor_id) VALUES
(101, 'Mechanics', 'Physics', 1),
(102, 'Quantum Physics', 'Physics', 1),
(201, 'Calculus I', 'Math', 2),
(202, 'Algebra', 'Math', 2),
(301, 'Organic Chemistry', 'Chemistry', 3),
(401, 'Data Structures', 'Computer Science', 4);

INSERT INTO Enrollments (enrollment_id, student_id, course_id, grade) VALUES
(1, 1, 101, 85),
(2, 1, 201, 90),
(3, 2, 101, 78),
(4, 2, 301, 88),
(5, 3, 201, NULL),
(6, 3, 202, 76),
(7, 4, 401, 92),
(8, 1, 202, 80);

INSERT INTO Mandatory_Courses (course_id, department) VALUES
(101, 'Physics'),
(201, 'Math'),
(401, 'Computer Science');

-- --List all students along with the courses they are enrolled in and the professor teaching the course.
select students.name, Courses.title, Professors.name from students 
inner join enrollments on students.student_id=enrollments.student_id
inner join courses on courses.course_id=Enrollments.course_id
inner join professors on professors.professor_id = courses.professor_id ;

-- --Find courses that have no students enrolled.
SELECT Courses.course_id, title
FROM Courses LEFT JOIN Enrollments  ON Courses.course_id = Enrollments.course_id
WHERE Enrollments.enrollment_id IS NULL;

-- --Retrieve a list of students who have taken at least 2 different courses.
select Enrollments.student_id, students.name, GROUP_CONCAT(DISTINCT courses.title) AS courses_taken from Courses 
inner join Enrollments on courses.course_id=enrollments.course_id 
inner join Students  on Students.student_id=Enrollments.student_id
group by Enrollments.student_id, students.name
having count(distinct courses.title)>=2;
 
-- --Show the professor with the highest number of enrolled students.
SELECT professors.name, COUNT(DISTINCT enrollments.student_id) AS total_std
FROM Professors inner join courses ON professors.professor_id = courses.professor_id
inner join Enrollments ON enrollments.course_id = courses.course_id
GROUP BY professors.name ORDER BY total_std DESC LIMIT 1;

-- --Get students who are enrolled in courses taught by a specific professor.
select  students.name, courses.title, professors.name from Enrollments 
inner join students on students.student_id=Enrollments.student_id
inner join courses on courses.course_id=Enrollments.course_id
inner join professors on professors.professor_id=courses.professor_id
order by students.name;

-- --Find students who have never enrolled in any course.
select students.name, students.student_id from students 
left join enrollments on students.student_id=enrollments.student_id
where enrollments.course_id is null ;

-- --Retrieve the average grade per course along with the professor’s name.
select professors.name, avg(grade) as avg_grade,  courses.title
from professors inner join courses on professors.professor_id=courses.professor_id
inner join enrollments on enrollments.course_id=courses.course_id
group by professors.name, courses.title ;

-- --Find the department with the most courses and the total number of students.
select department,count(distinct courses.course_id) as courses_count, count(distinct Students.student_id) as total_students
from Courses left join Enrollments  on Enrollments.course_id=courses.course_id
left join Students on Students.student_id = enrollments.student_id
group by department order by courses_count desc; 
 
-- --Get students who are enrolled in a course but have not yet received a grade.
select students.student_id,students.name, Enrollments.course_id, grade from students inner join enrollments
on students.student_id=enrollments.student_id where grade is null;

-- --Identify students who have taken all mandatory courses.
select students.student_id,students.name from students 
inner join enrollments on students.student_id=enrollments.student_id 
inner join Mandatory_Courses on Mandatory_Courses.course_id=enrollments.course_id 
group by students.student_id,students.name
HAVING COUNT(DISTINCT enrollments.course_id) = (SELECT COUNT(*) FROM Mandatory_Courses);

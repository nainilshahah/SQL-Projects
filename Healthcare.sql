CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    dob DATE,
    gender VARCHAR(10)
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialty VARCHAR(100)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

CREATE TABLE Prescriptions (
    prescription_id INT PRIMARY KEY,
    appointment_id INT,
    medicine_name VARCHAR(100),
    dosage VARCHAR(50),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

INSERT INTO Patients VALUES
(1, 'Alice', '1990-03-15', 'Female'),
(2, 'Bob', '1985-06-22', 'Male'),
(3, 'Charlie', '2000-12-02', 'Male'),
(4, 'Diana', '1978-09-30', 'Female'),
(5, 'Eve', '1995-01-10', 'Female');

INSERT INTO Doctors VALUES
(1, 'Dr. Smith', 'Cardiology'),
(2, 'Dr. Jones', 'Neurology'),
(3, 'Dr. Patel', 'Orthopedics'),
(4, 'Dr. Brown', 'General Medicine');

INSERT INTO Appointments VALUES
(1, 1, 1, '2024-09-01'),
(2, 1, 2, '2024-11-10'),
(3, 2, 1, '2024-11-15'),
(4, 3, 3, '2024-12-05'),
(5, 3, 2, '2025-01-20'),
(6, 3, 1, '2025-02-14'),
(7, 4, 4, '2023-09-14'),
(8, 5, 2, '2025-03-01'),
(9, 2, 4, '2024-05-20'),
(10, 2, 3, '2025-03-21');

INSERT INTO Prescriptions VALUES
(1, 1, 'Aspirin', '100mg'),
(2, 2, 'Ibuprofen', '200mg'),
(3, 3, 'Lipitor', '10mg'),
(4, 4, 'Metformin', '500mg'),
(5, 6, 'Aspirin', '100mg'),
(6, 8, 'Amoxicillin', '250mg'),
(7, 10, 'Aspirin', '100mg'),
(8, 6, 'Aspirin', '100mg'),
(9, 6, 'Aspirin', '100mg'),
(10, 6, 'Aspirin', '100mg'),
(11, 6, 'Aspirin', '100mg'),
(12, 6, 'Aspirin', '100mg');

-- --Retrieve all appointments along with patient and doctor details.
select  Patients.name,appointment_id, Gender, DOB, Doctors.name, Doctors.specialty, (Appointment_date)
from appointments inner join patients on Appointments.patient_id=patients.patient_id
inner join doctors on doctors.doctor_id=appointments.doctor_id;

-- --Find doctors who have the highest number of appointments.-----(COUNT(appointment_id) AS APPT IS APPROACH RIGHT?)

SELECT Doctors.NAME, COUNT(appointment_id) AS APPT FROM Doctors INNER JOIN Appointments 
ON Doctors.doctor_id=Appointments.doctor_id GROUP BY Doctors.NAME HAVING 
APPT=(SELECT MAX(CNT) FROM (SELECT COUNT(*) AS CNT FROM APPOINTMENTS GROUP BY doctor_id) AS DAC);

-- --List patients who have visited more than 3 different doctors.

SELECT Patients.name AS patient_name, COUNT(DISTINCT Appointments.doctor_id) AS doctor_count
FROM Appointments inner JOIN Patients ON Appointments.patient_id = Patients.patient_id
GROUP BY Patients.patient_id, Patients.name
HAVING COUNT(DISTINCT Appointments.doctor_id) >=3;

-- --Get patients who have an appointment but no prescription.

select patients.name, appointment_date, prescription_id from patients 
inner join Appointments on patients.patient_id =Appointments.patient_id 
left join Prescriptions on Prescriptions.appointment_id=Appointments.appointment_id
where prescription_id is null;

-- --Find the total number of appointments per doctor for a given month.

select Doctors.doctor_id, MONTHNAME(appointment_date) AS month, Doctors.name, count(*) as noapp
from doctors inner join appointments on doctors.doctor_id = appointments.doctor_id 
group by Doctors.doctor_id, Doctors.name, month;

-- --Retrieve all prescriptions along with patient and doctor details.
select appointment_date, doctors.name as DN, specialty, Patients.name as PN, medicine_name, dosage from Patients 
inner join Appointments on Appointments.patient_id = Patients.patient_id 
inner join Doctors on Doctors.doctor_id = Appointments.doctor_id
inner join Prescriptions  on Prescriptions .appointment_id = Appointments.appointment_id;

-- --Find patients who have not visited the hospital in the last 6 months.
select patients.name, patient_id from patients where patient_id 
not in ( select distinct patient_id from appointments where appointment_date >= DATE_SUB(curdate(), interval 6 month));

-- --Get a list of doctors along with their specialties and the number of patients they have treated.

select doctors.name, specialty ,count(distinct patients.patient_id) as pid from doctors 
inner join Appointments on doctors.doctor_id=Appointments.doctor_id
inner join patients on Appointments.patient_id=patients.patient_id
group by doctors.name, specialty;

-- --Find doctors who have prescribed a specific medicine more than 5 times.
select doctors.name, medicine_name, count(medicine_name) as count_Med from Appointments 
inner join Doctors on doctors.doctor_id=Appointments.doctor_id
inner join Prescriptions on Prescriptions.appointment_id=Appointments.appointment_id
group by doctors.name, medicine_name
having count(medicine_name) > 5;

-- --Retrieve the top 3 most commonly prescribed medicines.
select medicine_name, count(*) as no_med from Prescriptions 
group by medicine_name ORDER BY no_med DESC limit 3;
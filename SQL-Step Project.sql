/* Step project SQL
2025-01-14 зі змінами, враховуючи коментарі ментора
і змінами при підготовці фінального проекту
by OT */

-- Частина 1

-- 1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.

SELECT 
    YEAR(es.from_date) AS report_year, -- Витягуємо рік із дати початку дії зарплати
    AVG(es.salary) AS avg_salary -- Обчислюємо середню зарплату для кожного року
FROM 
    employees.salaries es-- Таблиця зарплат у базі даних employees

GROUP BY 
    report_year -- Групуємо записи за роками
HAVING 
    report_year BETWEEN MIN(report_year) AND 2005 -- Обмежуємо роки 
ORDER BY 
    report_year; -- Сортуємо результати за роками у зростаючому порядку

/* 2. Покажіть середню зарплату співробітників по кожному відділу. 
Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників. */

-- Обчислення середньої зарплати співробітників по кожному відділу
SELECT 
    d.dept_name AS department_name, -- Назва відділу
    AVG(s.salary) AS avg_salary -- Середня зарплата у відділі
FROM 
    employees.departments d -- Таблиця відділів
JOIN 
    employees.dept_emp de ON d.dept_no = de.dept_no -- Об'єднання з таблицею призначень співробітників
JOIN 
    employees.salaries s ON de.emp_no = s.emp_no -- Об'єднання з таблицею зарплат
WHERE 
    de.to_date = '9999-01-01' -- Тільки поточні призначення співробітників до відділів
    AND s.to_date = '9999-01-01' -- Тільки поточні зарплати співробітників
GROUP BY 
    d.dept_name -- Групування за назвою відділу
ORDER BY 
    department_name; -- Сортування за алфавітом назв відділів

-- варіант по-іншому перепишу умову, чз BETWEEN і зроблю округлення

-- Обчислення середньої зарплати співробітників по кожному відділу з поточною датою
SELECT 
    d.dept_name AS department_name, -- Назва відділу
    ROUND(AVG(s.salary),0) AS avg_salary -- Середня зарплата у відділі
FROM 
    employees.departments d -- Таблиця відділів
JOIN 
    employees.dept_emp de ON d.dept_no = de.dept_no -- Об'єднання з таблицею призначень співробітників
JOIN 
    employees.salaries s ON de.emp_no = s.emp_no -- Об'єднання з таблицею зарплат
WHERE 
    de.to_date BETWEEN CURRENT_DATE AND '9999-01-01' -- Тільки актуальні призначення співробітників до відділів
    AND s.to_date BETWEEN CURRENT_DATE AND '9999-01-01' -- Тільки актуальні зарплати співробітників
GROUP BY 
    d.dept_name -- Групування за назвою відділу
ORDER BY 
    department_name; -- Сортування за алфавітом назв відділів
    
-- запит виконується приблизно 2с, а 1-ий варіант приблизно 11с - значна різниця

-- 3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік

-- Середня зарплата співробітників по кожному відділу за кожний рік
/* запит для обчислення середньої зарплати співробітників по кожному відділу за кожен рік. */

SELECT 
    d.dept_name AS department_name, -- Назва відділу
    YEAR(s.from_date) AS report_year, -- Рік, за який проводиться розрахунок
    ROUND(AVG(s.salary),2) AS avg_salary -- Середня зарплата у відділі за рік
FROM 
    employees.departments d -- Таблиця відділів
JOIN 
    employees.dept_emp de ON d.dept_no = de.dept_no -- Об'єднання з таблицею призначень співробітників
JOIN 
    employees.salaries s ON de.emp_no = s.emp_no -- Об'єднання з таблицею зарплат

GROUP BY 
    department_name, -- Групування за назвою відділу
    report_year -- Групування за роком
ORDER BY 
    department_name, -- Сортування за алфавітом назв відділів
	report_year; -- Сортування за роком
    
-- 4. Покажіть відділи в яких зараз працює більше 15000 співробітників.

-- Вивести відділи, де зараз працює більше 15000 співробітників

SELECT 
    d.dept_name, -- Назва відділу
    COUNT(de.emp_no) AS employee_count -- Кількість співробітників у відділі
FROM 
    employees.departments d -- Таблиця відділів
JOIN 
    employees.dept_emp de -- Зв'язок співробітників із відділами
    ON d.dept_no = de.dept_no
WHERE 
    CURRENT_DATE() BETWEEN de.from_date AND de.to_date -- Тільки актуальні призначення 
GROUP BY 
    d.dept_name -- Групуємо за назвами відділів
HAVING 
    employee_count > 15000  
ORDER BY 
    employee_count DESC; -- Сортуємо за кількістю працівників у спадному порядку

-- перевіримо ефективність

EXPLAIN
SELECT 
    d.dept_name, -- Назва відділу
    COUNT(de.emp_no) AS employee_count -- Кількість співробітників у відділі
FROM 
    employees.departments d -- Таблиця відділів
JOIN 
    employees.dept_emp de -- Зв'язок співробітників із відділами
    ON d.dept_no = de.dept_no
WHERE 
    CURRENT_DATE() BETWEEN de.from_date AND de.to_date -- Тільки актуальні призначення 
GROUP BY 
    d.dept_name -- Групуємо за назвами відділів
HAVING 
    COUNT(de.emp_no) > 15000 -- Фільтруємо відділи з більш ніж 15000 співробітниками
ORDER BY 
    employee_count DESC; -- Сортуємо за кількістю працівників у спадному порядку
    
    -- Додамо індекс для колонки to_date у таблиці dept_emp:
    
    CREATE INDEX idx_dept_emp_todate ON employees.dept_emp (to_date);
    
-- знову запустимо код

    -- запит обрабляється швидше, але не дуже суттєво
    
  -- 5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище
  -- коментар Максима: В 5 завданні йдеться про загальний стаж роботи.
-- Знайти менеджера, який працює найдовше, і вивести інформацію про нього
SELECT 
    de.emp_no, -- Номер співробітника
    d.dept_name, -- Назва відділу
    e.hire_date, -- Дата прийому на роботу
    e.last_name, -- Прізвище менеджера
    e.first_name 
FROM 
    employees.dept_manager de -- Таблиця менеджерів відділів
INNER JOIN
    employees.departments d -- Таблиця відділів
    ON de.dept_no = d.dept_no
INNER JOIN
    employees.employees e -- Таблиця співробітників
    ON de.emp_no = e.emp_no
WHERE 
    CURRENT_DATE() BETWEEN e.hire_date AND de.to_date -- Тільки актуальні призначення 
ORDER BY 
    de.from_date  -- Сортуємо за датою початку роботи в порядку зростання
LIMIT 1; -- Беремо лише одного менеджера

-- варіант 1 - загальний стаж - все одно не та відповідь, ніж 2 варіант

SELECT 
    de.emp_no AS manager_no,              -- Номер співробітника
    d.dept_name AS department_name,       -- Назва відділу
    e.hire_date AS start_date,            -- Дата прийому на роботу
    e.last_name AS last_name,             -- Прізвище менеджера
    e.first_name AS first_name,           -- Ім'я менеджера
    TIMESTAMPDIFF(YEAR, e.hire_date, CURRENT_DATE()) AS total_years_worked -- Загальний стаж у роках
FROM 
    employees.dept_manager de             -- Таблиця менеджерів відділів
INNER JOIN
    employees.departments d               -- Таблиця відділів
    ON de.dept_no = d.dept_no
INNER JOIN
    employees.employees e                 -- Таблиця співробітників
    ON de.emp_no = e.emp_no
WHERE 
    CURRENT_DATE() BETWEEN e.hire_date AND de.to_date -- Актуальні співробітники
ORDER BY 
    total_years_worked DESC,              -- Сортуємо за загальним стажем у зворотному порядку
    de.from_date                          -- Додаткове сортування за датою призначення
LIMIT 1;                                  -- Беремо лише одного співробітника


-- варіант 2 - використаємо функцію TIMESTAMPDIFF

-- Знаходимо менеджера з найдовшим стажем роботи
SELECT 
    dm.emp_no AS manager_no,               -- Номер менеджера
    d.dept_no AS department_code,          -- Код відділу
    e.hire_date AS start_date,            -- Дата прийому на роботу
    e.last_name AS last_name,             -- Прізвище менеджера
    e.first_name AS first_name,
    TIMESTAMPDIFF(YEAR, dm.from_date, CURRENT_DATE) AS work_years -- Стаж роботи в днях. Можна використати MONTH: для підрахунку в місяцях або YEAR: для підрахунку в роках.
FROM 
    employees.dept_manager AS dm
INNER JOIN 
    employees.employees AS e ON dm.emp_no = e.emp_no
INNER JOIN 
    employees.departments AS d ON dm.dept_no = d.dept_no
WHERE 
    dm.from_date <= dm.to_date -- Перевірка на коректність дат
ORDER BY 
    work_years DESC             -- Сортуємо за стажем у зворотному порядку
LIMIT 1;                       -- Вибираємо лише першого менеджера

/* 
У твоєму запиті ти розраховуєш тривалість роботи менеджера у конкретному департаменті (тобто стаж менеджера на цій конкретній посаді).

Що означає "загальний стаж роботи"?
Коментар Максима може натякати на те, що замість обчислення стажу менеджера в межах конкретної посади або департаменту, 
потрібно підрахувати загальну тривалість роботи співробітника у компанії — 
від дати найму (hire_date) до сьогоднішньої дати (або дати звільнення, якщо є). */

-- Модифікуємо твій запит так, щоб враховувати загальний період роботи в компанії:

SELECT 
    e.emp_no AS manager_no,               -- Номер менеджера
    e.last_name AS last_name,             -- Прізвище менеджера
    e.first_name AS first_name,           -- Ім'я менеджера
    e.hire_date AS start_date,            -- Дата найму
    TIMESTAMPDIFF(YEAR, e.hire_date, CURRENT_DATE) AS total_years_worked -- Загальний стаж у роках
FROM 
    employees.employees AS e
ORDER BY 
    total_years_worked DESC
LIMIT 1;

  
-- 6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.

-- Знайти топ-10 співробітників із найбільшою різницею між їхньою зарплатою 
-- та середньою зарплатою у їхньому відділі

SELECT 
    e.emp_no, -- Номер співробітника
    e.first_name, -- Ім'я співробітника
    e.last_name, -- Прізвище співробітника
    d.dept_name, -- Назва відділу
    s.salary, -- Зарплата співробітника
    AVG(salary) OVER (PARTITION BY d.dept_no) AS avg_salary_in_dept, -- Середня зарплата у відділі
    s.salary - AVG(salary) OVER (PARTITION BY d.dept_no) AS salary_diff -- Різниця між зарплатою і середньою зарплатою
FROM 
    employees.employees e -- Таблиця співробітників
JOIN 
    employees.dept_emp de -- Таблиця призначень співробітників до відділів
    ON e.emp_no = de.emp_no
JOIN 
    employees.departments d -- Таблиця відділів
    ON de.dept_no = d.dept_no
JOIN 
    employees.salaries s -- Таблиця зарплат
    ON e.emp_no = s.emp_no
WHERE 
     de.to_date > CURRENT_DATE -- Тільки актуальні призначення співробітників
   AND s.to_date > CURRENT_DATE -- Тільки актуальні зарплати
    -- CURRENT_DATE() BETWEEN de.from_date AND de.to_date  -- з такою умовою виконується довше на 8 секунд
    -- AND CURRENT_DATE() BETWEEN s.from_date AND s.to_date
    
ORDER BY 
    salary_diff DESC -- Сортуємо за найбільшою різницею між зарплатою і середньою зарплатою
LIMIT 10; -- Беремо лише топ-10 співробітників

-- 1 варіант виконується досить довго, в 3 р довше, ніж варіант 2

-- 2 варіант 

-- Створення CTE для обчислення середніх зарплат у кожному відділі


WITH AvgDeptSalaries AS (
    SELECT 
        de.dept_no, -- Код відділу
        AVG(s.salary) AS avg_salary -- Середня зарплата у відділі
    FROM 
        employees.dept_emp de -- Таблиця призначень співробітників до відділів
    JOIN 
        employees.salaries s -- Таблиця зарплат
        ON de.emp_no = s.emp_no
    WHERE 
        de.to_date > CURRENT_DATE -- Тільки актуальні призначення співробітників
        AND s.to_date > CURRENT_DATE -- Тільки актуальні зарплати
    GROUP BY 
        de.dept_no -- Групування за відділами
)
-- Основний запит для отримання топ-10 співробітників з найбільшою різницею в зарплаті
SELECT 
    e.emp_no, -- Номер співробітника
    e.first_name, -- Ім'я співробітника
    e.last_name, -- Прізвище співробітника
    d.dept_name, -- Назва відділу
    s.salary, -- Зарплата співробітника
    ads.avg_salary, -- Середня зарплата у відділі
    s.salary - ads.avg_salary AS salary_diff -- Різниця між зарплатою співробітника і середньою зарплатою
FROM 
    employees.employees e -- Таблиця співробітників
JOIN 
    employees.dept_emp de -- Таблиця призначень співробітників до відділів
    ON e.emp_no = de.emp_no
JOIN 
    employees.departments d -- Таблиця відділів
    ON de.dept_no = d.dept_no
JOIN 
    employees.salaries s -- Таблиця зарплат
    ON e.emp_no = s.emp_no
JOIN 
    AvgDeptSalaries ads -- CTE з середніми зарплатами у відділах
    ON de.dept_no = ads.dept_no
WHERE 
    de.to_date > CURRENT_DATE -- Тільки актуальні призначення співробітників
    AND s.to_date > CURRENT_DATE -- Тільки актуальні зарплати
ORDER BY 
    salary_diff DESC -- Сортування за найбільшою різницею
LIMIT 10; -- Вибір лише топ-10 співробітників

/*Оптимізація. Створимо індекси для стовпців, які використовуються у фільтрах і приєднаннях 
і запустимо верхній код знову. Є покращення, швидше приблизно на 1с */

CREATE INDEX idx_dept_emp_to_date ON employees.dept_emp (to_date);
CREATE INDEX idx_salaries_to_date ON employees.salaries (to_date);

-- Варіант коду з використанням CTE працює в 2 рази швидше (приблизно на 10с швидше)

-- 7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, прізвище ім’я менеджера, 
-- дату прийому на роботу менеджера і дату коли він став менеджером відділу

-- Використання CTE для обчислення рангу менеджерів у кожному відділі

-- варіант з віконною функцією

WITH ManagerRank AS (
    SELECT 
        d.dept_name AS department_name,       -- Назва відділу
        dm.dept_no AS department_code,        -- Код відділу
        e.emp_no AS employee_code,            -- Код співробітника
        CONCAT(e.first_name, ' ', e.last_name) AS manager_name, -- Ім’я та прізвище менеджера в одній колонці
        e.hire_date AS hire_date,             -- Дата прийому на роботу менеджера
        dm.from_date AS manager_start_date,   -- Дата, коли він став менеджером
        ROW_NUMBER() OVER (
            PARTITION BY dm.dept_no
            ORDER BY dm.from_date ASC          -- Історична дата початку роботи
        ) AS rank_in_department                -- Порядковий номер менеджера в межах відділу
    FROM 
        employees.dept_manager AS dm           -- Таблиця менеджерів відділів
    JOIN 
        employees.employees AS e ON dm.emp_no = e.emp_no -- З'єднання з таблицею співробітників
    JOIN 
        employees.departments AS d ON dm.dept_no = d.dept_no -- З'єднання з таблицею відділів
)
SELECT 
    mr.department_name AS department_name,  -- Назва відділу
    mr.department_code AS department_code,  -- Код відділу
    mr.employee_code AS employee_code,      -- Код співробітника
    mr.manager_name AS manager_name,        -- Ім’я та прізвище менеджера
    mr.hire_date AS hire_date,              -- Дата прийому на роботу менеджера
    mr.manager_start_date AS start_date     -- Дата, коли він став менеджером
FROM 
    ManagerRank AS mr
WHERE 
    mr.rank_in_department = 2;              -- Другий менеджер за історичною датою початку роботи

-- або використаємо COUNT.

WITH ManagerRank AS (
    SELECT 
        d.dept_name AS department_name,       -- Назва відділу
        dm.dept_no AS department_code,        -- Код відділу
        e.emp_no AS employee_code,            -- Код співробітника
        CONCAT(e.first_name, ' ', e.last_name) AS manager_name, -- Ім’я та прізвище менеджера в одній колонці
        e.hire_date AS hire_date,             -- Дата прийому на роботу менеджера
        dm.from_date AS manager_start_date,   -- Дата, коли він став менеджером
        COUNT(dm.from_date) OVER (
            PARTITION BY dm.dept_no
            ORDER BY dm.from_date ASC          -- Історична дата початку роботи
        ) AS rank_in_department                -- Порядковий номер менеджера в межах відділу
    FROM 
        employees.dept_manager AS dm           -- Таблиця менеджерів відділів
    JOIN 
        employees.employees AS e ON dm.emp_no = e.emp_no -- З'єднання з таблицею співробітників
    JOIN 
        employees.departments AS d ON dm.dept_no = d.dept_no -- З'єднання з таблицею відділів
)
SELECT 
    mr.department_name AS department_name,  -- Назва відділу
    mr.department_code AS department_code,  -- Код відділу
    mr.employee_code AS employee_code,      -- Код співробітника
    mr.manager_name AS manager_name,        -- Ім’я та прізвище менеджера
    mr.hire_date AS hire_date,              -- Дата прийому на роботу менеджера
    mr.manager_start_date AS start_date     -- Дата, коли він став менеджером
FROM 
    ManagerRank AS mr
WHERE 
    mr.rank_in_department = 2;              -- Другий менеджер за історичною датою початку роботи

-- варіант без віконних функцій від Максима

-- CTE (Common Table Expression) для підрахунку кількості записів менеджерів
WITH ManagerCounts AS (
  SELECT 
    mg1.dept_no,               -- Номер департаменту
    mg1.emp_no,                -- Ідентифікатор працівника
    mg1.from_date,             -- Дата, коли працівник став менеджером
    COUNT(mg2.from_date) AS manager_count -- Кількість записів про менеджера
  FROM 
    employees.dept_manager AS mg1 -- Перша копія таблиці dept_manager
  INNER JOIN 
    employees.dept_manager AS mg2 -- Друга копія таблиці dept_manager
  ON 
    (mg1.dept_no = mg2.dept_no    -- Той самий департамент
     AND mg1.from_date >= mg2.from_date) -- Дата призначення менеджера mg1 >= mg2
  GROUP BY 
    mg1.dept_no, mg1.emp_no               -- Групування за номером департаменту і працівником
)

-- Основний запит для отримання потрібних даних
SELECT 
  dp.dept_name,                       -- Назва департаменту
  CONCAT(ee.first_name, '_', ee.last_name) AS full_name, -- Ім'я та прізвище працівника
  ee.hire_date,                       -- Дата прийому на роботу працівника
  mg.dept_no,                         -- Номер департаменту
  mg.from_date AS date_became_manager -- Дата призначення менеджером
FROM 
  employees.employees ee              -- Таблиця з інформацією про працівників
INNER JOIN 
  ManagerCounts AS mg                 -- З'єднання з результатом CTE
  ON 
    (ee.emp_no = mg.emp_no            -- Співставлення працівників
     AND mg.manager_count = 2)        -- Фільтр: залишаємо лише тих, хто був менеджером 2 рази
INNER JOIN 
  employees.departments AS dp         -- З'єднання з таблицею департаментів
  ON 
    (dp.dept_no = mg.dept_no)         -- З'єднання за номером департаменту
ORDER BY 
  dp.dept_name;                       -- Сортування за назвою департаменту

/* Спочатку створюється CTE, яке визначає кількість випадків, коли працівник був менеджером в таблиці "dept_manager". 
Таблиця "dept_manager" приєднується двічі. Використовується порівняння дат призначення менеджерів, 
щоб визначити, скільки разів працівник був менеджером в тому ж департаменті. 
Результат групується за номером департаменту та номером працівника.

Потім проводиться основний запит SELECT, який об'єднує таблиці "employees", наше СТЕ та "departments" 
для отримання інформації про працівників, які були менеджерами двох або більше департаментів. 
Вибираються поля, такі як назва департаменту, повне ім'я працівника, дата прийому на роботу, 
номер департаменту та дата, коли працівник став менеджером в цьому департаменті.

Результат сортується за назвою департаменту. */



-- Частина 2 

-- Дизайн бази даних:

-- 1. Створення бази даних і таблиць

-- 1. Видалення бази даних, якщо вона існує
DROP DATABASE IF EXISTS course_management;

-- 2. Створення бази даних
CREATE DATABASE IF NOT EXISTS course_management;
USE course_management; -- Якщо вже використовуємо базу даних за допомогою команди USE, 
-- тоді далі базу даних можна не вказувати:

-- 3. Створення таблиці teachers
CREATE TABLE IF NOT EXISTS teachers (
    teacher_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100),
    phone_no VARCHAR(15)
);

-- 4. Створення таблиці courses
CREATE TABLE IF NOT EXISTS courses (
    course_no INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100),
    start_date DATE,
    end_date DATE
);

-- 5. Створення таблиці students
CREATE TABLE IF NOT EXISTS students (
    student_no INT AUTO_INCREMENT PRIMARY KEY,
    teacher_no INT NOT NULL, 
    course_no INT NOT NULL,
    /* INT NOT NULL Тоді буде повна відповідність між суттю первинних ключів в 
    2 таблицях та зовнішніми ключами в таблиці студентів. 
    Оскільки первинні ключі є NOT NULL за замовченням.*/
    
    student_name VARCHAR(100),
    email VARCHAR(100),
    birth_date DATE,
    FOREIGN KEY (teacher_no) REFERENCES teachers(teacher_no),
    FOREIGN KEY (course_no) REFERENCES courses(course_no)
);

-- 5. Створення таблиці students 
/* ON DELETE CASCADE та ON UPDATE CASCADE:
Ці параметри визначають, що відбудеться при видаленні чи оновленні записів у пов’язаних таблицях. 
Наприклад, при видаленні викладача всі пов'язані студенти будуть також видалені. */

DROP TABLE IF EXISTS students;

CREATE TABLE IF NOT EXISTS students (
    student_no INT AUTO_INCREMENT PRIMARY KEY,       -- Унікальний номер студента
    teacher_no INT,                                  -- Посилання на таблицю teachers
    course_no INT,                                   -- Посилання на таблицю courses
    student_name VARCHAR(100),                       -- Ім'я студента
    email VARCHAR(100),                              -- Електронна адреса
    birth_date DATE,                                 -- Дата народження
    CONSTRAINT fk_teacher FOREIGN KEY (teacher_no)   -- Оголошення зовнішнього ключа для teacher_no
        REFERENCES teachers(teacher_no)             -- Посилання на таблицю teachers
        ON DELETE CASCADE ON UPDATE CASCADE,        -- Дії при оновленні або видаленні запису
    CONSTRAINT fk_course FOREIGN KEY (course_no)    -- Оголошення зовнішнього ключа для course_no
        REFERENCES courses(course_no)               -- Посилання на таблицю courses
        ON DELETE CASCADE ON UPDATE CASCADE         -- Дії при оновленні або видаленні запису
);


-- 2. Заповнення таблиць даними

-- Початок транзакції
START TRANSACTION;

-- Вставка даних у таблицю teachers
INSERT INTO teachers (teacher_name, phone_no)
VALUES 
    ('John Smith', '1234567890'),
    ('Emily Johnson', '2345678901'),
    ('Michael Brown', '3456789012');

-- Вставка даних у таблицю courses
INSERT INTO courses (course_name, start_date, end_date)
VALUES 
    ('Mathematics', '2025-01-01', '2025-06-01'),
    ('History', '2025-02-01', '2025-07-01'),
    ('Physics', '2025-03-01', '2025-08-01');

-- Вставка даних у таблицю students
INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
VALUES 
    (1, 1, 'Alice Johnson', 'alice@example.com', '2000-01-15'),
    (1, 1, 'Bob Williams', 'bob@example.com', '1999-02-20'),
    (2, 2, 'Charlie Davis', 'charlie@example.com', '2001-03-10'),
    (2, 2, 'Diana Wilson', 'diana@example.com', '1998-04-25'),
    (3, 3, 'Eve Harris', 'eve@example.com', '2002-05-30'),
    (3, 3, 'Frank White', 'frank@example.com', '2000-06-15'),
    (3, 3, 'Grace Clark', 'grace@example.com', '2001-07-20');

-- Завершення транзакції
COMMIT;

-- 3. Запит: кількість студентів для кожного викладача

SELECT 
    t.teacher_no,
    t.teacher_name,
    COUNT(s.student_no) AS student_count
FROM 
    teachers t
LEFT JOIN 
    students s ON t.teacher_no = s.teacher_no
GROUP BY 
    t.teacher_no, t.teacher_name;
    
/* можна використати INNER JOIN, якщо ми хочемо враховувати тільки тих викладачів, які мають хоча б одного студента. 
LEFT JOIN підходить, якщо потрібно вивести всіх викладачів, навіть тих, у яких немає студентів. */
    
-- варіант 2 з INNER JOIN

-- 3. Запит: кількість студентів для кожного викладача
SELECT 
    t.teacher_no,                  -- Номер викладача
    t.teacher_name,                -- Ім'я викладача
    COUNT(s.student_no) AS student_count -- Кількість студентів
FROM 
    teachers t
INNER JOIN 
    students s ON t.teacher_no = s.teacher_no -- З'єднання по номеру викладача
GROUP BY 
    t.teacher_no, t.teacher_name; -- Групування за викладачем


-- 4. Додавання дубльованих рядків у таблицю students

-- Додавання дублюючих записів
INSERT INTO course_management.students (teacher_no, course_no, student_name, email, birth_date)
SELECT 
    s.teacher_no, s.course_no, s.student_name, s.email, s.birth_date
FROM 
    course_management.students AS s
LIMIT 3;


-- перевіримо, чи створилися дубльовані рядки
SELECT * 
	FROM course_management.students;


-- 5. Напишіть запит який виведе дублюючі рядки в таблиці students

SELECT 
    s.teacher_no,          -- Ідентифікатор викладача
    s.course_no,           -- Ідентифікатор курсу
    s.student_name,        -- Ім'я студента
    s.email,               -- Електронна адреса студента
    s.birth_date,          -- Дата народження студента
    COUNT(s.student_no) AS duplicate_count -- Підрахунок за унікальним полем student_no
FROM 
    students AS s
GROUP BY 
    s.teacher_no,          -- Групуємо за ідентифікатором викладача
    s.course_no,           -- Групуємо за ідентифікатором курсу
    s.student_name,        -- Групуємо за ім'ям студента
    s.email,               -- Групуємо за електронною адресою
    s.birth_date           -- Групуємо за датою народження
HAVING 
    duplicate_count > 1; -- Вибираємо лише записи з дублюванням

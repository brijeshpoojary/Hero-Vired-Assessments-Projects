-- 1. Employee Productivity Analysis:
-- Identify employees with the highest total hours worked and least absenteeism.
select employeeid,employeename,sum(total_hours)+sum(overtime_hours) as total_hours,sum(days_absent) as absenteeism 
from attendance_records 
group by employeeid,employeename 
order by total_hours desc,absenteeism asc;

-- 2. Departmental Training Impact:
-- Analyze how training programs improve departmental performance.
select tp.department_id,
avg(case 
		when e.performance_score='Excellent' then 5
        when e.performance_score='Good' then 4
        when e.performance_score='Average' then 3
        else null
	END) AS avg_performance,AVG(tp.feedback_score) as avg_feedback
FROM training_programs tp
JOIN employee_details e
ON tp.employeeid= e.employeeid
GROUP BY tp.department_id 
ORDER BY department_id;

-- 3. Project Budget Efficiency:
-- Evaluate the efficiency of project budgets by calculating costs per hour worked.
select project_id,project_name,budget/sum(hours_worked) as cost_per_hour 
from project_assignments 
group by project_id,project_name
order by cost_per_hour desc;

-- 4. Attendance Consistency:
-- Measure attendance trends and identify departments with significant deviations.
select e.department_id,e.employeename,a.total_hours,
avg(a.total_hours) over(partition by e.department_id) as avg_hours,
a.total_hours-avg(a.total_hours) over(partition by e.department_id) as deviation
from employee_details as e join attendance_records as a on e.employeeid=a.employeeid;

-- 5. Training and Project Success Correlation:
-- Link training technologies with project milestones to assess the real-world impact of training.
SELECT t.technologies_covered,
       e.department_id,
       Sum(p.milestones_achieved)      AS total_milestones_achieved,
       Round(Avg(t.feedback_score), 2) AS avg_feedback_score,
       Sum(p.budget)                   AS total_budget
FROM   training_programs AS t
       JOIN employee_details AS e ON t.employeeid = e.employeeid
       JOIN project_assignments AS p ON p.employeeid = e.employeeid
GROUP  BY e.department_id,t.technologies_covered
ORDER  BY total_milestones_achieved DESC; 

-- 6. High-Impact Employees:
-- Identify employees who significantly contribute to high-budget projects while maintaining excellent performance scores.
SELECT e.employeeid,e.employeename,p.project_id,p.project_name,e.performance_score,p.budget
FROM   employee_details AS e
       JOIN project_assignments AS p
         ON e.employeeid = p.employeeid
WHERE  e.performance_score = 'Excellent'
       AND p.budget > (SELECT Avg(budget) FROM project_assignments)
ORDER  BY p.budget DESC; 

-- 7. Cross-Analysis of Training and Project Success
-- Identify employees who have undergone training in specific technologies and contributed to high-performing projects using those technologies
select t.employeeid,t.employeename,t.technologies_covered 
from training_programs as t where t.completion_status='Completed';

-- Department-Wise Training Impact
-- Evaluate the impact of training programs on departmental performance by correlating training feedback scores with project milestones.
SELECT E.department_id,
       Avg(T.feedback_score)      AVG_FEEDBACK,
       Avg(P.milestones_achieved) AVG_MILESTONE,
       Count(P.project_id)        NO_OF_PROJECTS
FROM   employee_details E
       JOIN training_programs T
         ON E.employeeid = T.employeeid
       JOIN project_assignments P
         ON E.employeeid = P.employeeid
GROUP  BY E.department_id
ORDER  BY avg_feedback DESC,
          avg_milestone DESC; 

-- Employee Performance and Contribution Analysis
-- Identify employees who consistently perform well across projects and have high attendance, with consideration for their training feedback.

-- Cross-Analysis of Training and Project Success
-- Identify employees who have undergone training in specific technologies and contributed to high-performing projects using those technologies.

-- Use case of CTE 
WITH training_technologies
     AS (SELECT e.employeeid,
                e.department_id,
                tf.technologies_covered,
                tf.feedback_score
         FROM   training_programs AS tf
                JOIN employee_details AS e
                  ON tf.employeeid = e.employeeid),
     project_performance
     AS (SELECT pm.project_id,
				pm.employeeid,
                pm.milestones_achieved,
                pm.budget
         FROM   project_assignments AS pm)
SELECT tt.technologies_covered,
       tt.department_id,
       Avg(tt.feedback_score)      AS avg_feedback_score,
       Sum(pp.milestones_achieved) AS total_milestones,
       Sum(pp.budget)              AS total_project_budget
FROM   training_technologies AS tt
       JOIN project_performance AS pp
         ON tt.employeeid = pp.employeeid
GROUP  BY tt.technologies_covered,
          tt.department_id
ORDER  BY total_milestones DESC; 
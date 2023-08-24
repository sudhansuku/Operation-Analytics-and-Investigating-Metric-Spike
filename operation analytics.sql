use job_data;

/* Table: job_data
job_id: unique identifier of jobs
actor_id: unique identifier of actor
event: decision/skip/transfer
language: language of the content
time_spent: time spent to review the job in seconds
org: organization of the actor
ds: date in the yyyy/mm/dd format. It is stored in the form of text and we use presto to run. no need for date function
*/

/*
Number of jobs reviewed: Amount of jobs reviewed over time.
task: Calculate the number of jobs reviewed per hour per day for November 2020?
*/
with jobs_review_per_hr as (
select ds as "review date", round(count(job_id)/sum(time_spent)*3600) as "review_per_hr"
from job_data
where month(ds) = 11
group by ds
) select round(sum(review_per_hr)/30) as "jobs reviewed per hr per day"
  from jobs_review_per_hr;
  /* no. of jobs reviewed per hour per day for November 2020 is 55 */
  
/* 
Throughput: It is the no. of events happening per second.
task: Let’s say the above metric is called throughput. 
Calculate 7 day rolling average of throughput? For throughput,
do you prefer daily metric or 7-day rolling and why?
*/
with jobs_review_per_sec as (
select ds as "review_date", round(count(job_id)/sum(time_spent),3) as "jobs_review_per_sec"
from job_data
where month(ds) = 11
group by ds
) select * , round(avg(jobs_review_per_sec) over(order by review_date rows between 6 preceding and current row),3) as "7-days rolling average"
  from jobs_review_per_sec;
  
/*
Percentage share of each language: Share of each language for different contents.
task: Calculate the percentage share of each language in the last 30 days?
*/
select language,  round(count(*)/sum(count(*)) over()*100,2) as "percentage share(%)"
from job_data
where month(ds) = 11
group by language
order by round(count(*)/sum(count(*)) over()*100,2) desc ;

/*
Duplicate rows: Rows that have the same value present in them.
task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?
*/
select *, count(*) as "count_of_dulplicate_rows"
from job_data
group by ds, job_id, actor_id, event, language, time_spent, org
having count(*) > 1;


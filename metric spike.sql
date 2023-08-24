/* Case Study 2 (Investigating metric spike) */

/* User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
Your task: Calculate the weekly user engagement?
*/
select concat("week-",week(occurred_at)," ",year(occurred_at)) as "week number", count(user_id) as "count of weekly engagement"
from events_table
where event_type = "engagement"
group by 1
order by  1;

/* User Growth: Amount of users growing over time for a product.
Your task: Calculate the user growth for product?
*/ 
with new_active_users as (
select   date_format(activated_at,"%M %Y") as "Months", count(user_id) as "New_users"
from users
where state = "active"
group by 1
) select *, round((New_users/lag(New_users,1,160) over(order by "Months") -1)*100,2) as "% growth rate"
  from new_active_users;
-- users are increasing month by month and has increase from 160 in jan 2013 to 1031 aug 2014

/* Weekly Retention: Users getting retained weekly after signing-up for a product.
Your task: Calculate the weekly retention of users-sign up cohort?
*/
with signup_users as (
select user_id, week(occurred_at) as "sign_up_week"
from events_table
where event_type = "signup_flow" and event_name = "complete_signup"
), 
engagement_users as (
select user_id, week(occurred_at) as "first_engagement_week"
from events_table
where event_type = "engagement"
),
cal_table as (
select e.user_id, e.first_engagement_week as "week_num", first_engagement_week - sign_up_week as "retention_week"
from engagement_users e left join signup_users s on e.user_id = s.user_id
) select week_num, sum( case when retention_week = 1 then 1 else 0 end ) as "No. of users weekly retain" 
  from cal_table
  group by week_num
  order by week_num;

/*Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
Your task: Calculate the weekly engagement per device?
*/


/* Email Engagement: Users engaging with the email service.
Your task: Calculate the email engagement metrics?
*/
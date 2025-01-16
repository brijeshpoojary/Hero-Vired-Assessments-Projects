-- Identifying Active Users: SocialHive’s marketing team wants to send a “thank you” message to all users who have interacted with the platform. 
-- Define “interaction” as posting, liking a post, or sending a message. Provide a list of users who have engaged in any of these activities.
select distinct u.username
from users u 
join likes l on u.user_id=l.user_id 
join posts p on u.user_id=p.user_id
join messages m on u.user_id=m.sender_id;

-- Posts Without Engagement: The product manager suspects that some posts lack proper targeting or visuals. 
-- Identify all posts that haven’t received any likes to help refine the content strategy.
select post_id, content, created_at 
from posts 
where post_id not in (select post_id from likes);

-- First-Time Liker : To analyze user behavior, SocialHive’s analytics team wants to identify users who liked a post for the first time. 
-- Generate a list of the first recorded likes for each user, along with the corresponding post. 
select l.user_id,
u.username,
p.content,
l.liked_at
from likes l
join users u on u.user_id=l.user_id
join posts p on p.post_id=l.post_id 
order by 1,4;

-- Top Engaged Posts: The analytics team needs to identify the top 5 most engaging posts based on the number of likes. 
-- Include the usernames of the users who created these posts to analyze content trends.
select u.username,
p.post_id,
p.content,
count(l.like_id) as no_of_likes
from posts p
join users u on u.user_id=p.user_id
join likes l on p.post_id=l.post_id 
group by 1,2,3
order by 4 desc 
limit 5;

-- Cross-Platform Influencers: SocialHive wants to identify content creators who focus solely on posting content but do not engage through messaging. 
-- Find users who have received a significant number of likes on their posts but have not sent or received any messages.
select u.user_id, 
u.username,
p.post_id,
p.content,
count(l.like_id) as no_of_likes
from posts p
join users u on u.user_id=p.user_id
join likes l on p.post_id=l.post_id 
where p.user_id not in (select sender_id from messages) AND
p.user_id not in (select receiver_id from messages)
group by 1,2,3
order by 4 desc ;

-- User Pair Insights : A researcher studying user engagement wants to identify user pairs (sender and receiver) 
-- who have exchanged messages with each other more than 3 times.
select distinct m.sender_id,
m.receiver_id
from messages m ;

-- Weekly Engagement Metrics : Management needs a report summarizing the number of posts created and total likes received weekly. 
-- Focus on weeks with more than 50 posts created to identify high-activity periods.
select week(p.created_at) as week,
count(distinct p.post_id) as post_created,
count(l.like_id) as likes
from posts p
left join likes l on p.post_id=l.post_id
group by 1
having count(p.post_id)>50
order by 1;

-- Engagement Timing :A behavioral analyst is studying user activity patterns. 
-- Identify users who liked a post within 5 minutes of its creation to understand content that drives immediate engagement.
select u.username,
p.post_id,
p.content,
p.created_at,
l.liked_at,
timediff(p.created_at,l.liked_at)
from users u
join likes l on l.user_id=u.user_id
join posts p on l.post_id=p.post_id;

-- User Contribution Score : SocialHive wants to rank “power users” by calculating a contribution score:
-- +2 points for each post created.
-- +1 point for each like given.
-- +1 point for each message sent. Generate a ranked list of users with their total contribution scores.

-- Sentiment Analysis Pipeline: The team is building a sentiment analysis tool to train models using user messages. 
-- Extract all messages containing keywords like “great,” “happy,” or “excited.” Include the sender and receiver details for messages sent after January 2023.

-- Debugging Challenges
-- 1. Identifying Inactive Users
-- Management wants to find users who have never interacted with the platform (no likes, posts, or messages).
-- Flawed Query:
SELECT user_id
FROM users
WHERE user_id NOT IN (
    SELECT DISTINCT user_id FROM likes
    UNION ALL
    SELECT DISTINCT sender_id FROM messages
    UNION ALL
    SELECT DISTINCT user_id FROM posts
);
-- The Query is correct and fetching the expected results

-- 2. Weekly Activity Report : The analytics team needs a report showing the number of posts created and the total likes received weekly. 
-- Focus only on weeks where more than 50 posts were created.
-- Flawed Query:
SELECT 
    WEEK(created_at) AS week_number, 
    COUNT(post_id) AS total_posts, 
    (SELECT COUNT(*) FROM likes) AS total_likes
FROM posts
GROUP BY WEEK(created_at)
HAVING total_posts > 50;

-- Corrected Query:
SELECT 
    WEEK(posts.created_at) AS week_number, 
    COUNT(distinct posts.post_id) AS total_posts, 
    count(distinct likes.like_id) AS total_likes
FROM posts left join likes on likes.post_id=posts.post_id
GROUP BY WEEK(created_at)
HAVING total_posts > 50
order by 1 asc;
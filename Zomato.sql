/*1. What is the total amount each customer spent on zomato.*/


select u.userid,sum(price) from users u join sales s on u.userid = s.userid
join product p on s.product_id = p.product_id group by u.userid

/*2. How many days each customer visited Zomato.*/

select userid,count(created_date) from sales group by userid

/* Q3. What was the first product purchased by each customer? */
with b as(
select * from(
select *,rank() over(partition by sales.userid order by sales.created_date) as r from sales)j
where r = 1)

select b.userid,p.product_name from b join product p on 
b.product_id = p.product_id

/* 4. What is the most purchased item on the menu ?*/

with a as(
select product_id,count(product_id) as tot from sales group by product_id)

select product_id,tot from (
select *,rank() over(order by tot desc) as r from a)t where r = 1

/* 5. Which item is most popular for each customer ? */
select userid,product_id from(
select userid,product_id,rank() over(partition by userid order by c desc) r from(
select userid,product_id,count(product_id) as c from sales group by userid,product_id)a)g
where r = 1

/* 6. which item was purchased first by customer after they become a member?*/

select userid,product_id from(
select b.userid,created_date,product_id,gold_signup_date,
rank() over(partition by b.userid order by created_date) r
from
sales a join goldusers_signup b on a.userid = b.userid where created_date > gold_signup_date)g
where r = 1

/* 7. Which item was purchased just before the customer become a member */

select userid,product_id from(
select b.userid,created_date,product_id,gold_signup_date,
rank() over(partition by b.userid order by created_date desc) r
from
sales a join goldusers_signup b on a.userid = b.userid where created_date < gold_signup_date)h
where r = 1

/* 8. What is the total orders and amount spent before each customer become a member */

select userid,count(created_date) order_purchased,sum(price) from(
select c.*,d.price from
(select b.userid,created_date,product_id,gold_signup_date
from
sales a join goldusers_signup b on a.userid = b.userid where created_date < gold_signup_date)c
join product d on c.product_id = d.product_id)e group by userid;

/*9. if buying each product generates zomato points and each product generates different points,
for p1 5rs = 1, p2 10rs = 5,p3 5rs =1..  calculate points collected by each customer.*/

with pts as(
SELECT s.userid,COUNT(s.created_date) AS m,s.product_id,p.price,
CASE 
        WHEN s.product_id = 1 THEN p.price / 5 * COUNT(s.created_date)
        WHEN s.product_id = 2 THEN p.price / 10 * COUNT(s.created_date)
        WHEN s.product_id = 3 THEN p.price / 5 * COUNT(s.created_date)
    END AS total_pts
FROM sales s 
JOIN product p ON s.product_id = p.product_id
GROUP BY s.userid, s.product_id, p.price
ORDER BY s.userid)

select pts.userid,sum(pts.total_pts) from pts group by pts.userid






/* In this lab you will practice MySQL Subqueries, Temp Tables, and Action Queries. 
You will use the publications database. You can find it in Ironhack's database. */

use publications;

/*In this challenge you'll find out who are the top 3 most profiting authors */

/*Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
Write a SELECT query to obtain the following output:

Title ID
Author ID
Advance of each title and author
The formula is:
advance = titles.advance * titleauthor.royaltyper / 100 

Royalty of each sale
The formula is:
sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100

*/

select * from sales;

select sales.title_id, titleauthor.au_id, round(titles.advance * titleauthor.royaltyper / 100) as advance, round(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as royalty
from sales
inner join titleauthor 
on titleauthor.title_id = sales.title_id
inner join titles
on titles.title_id = titleauthor.title_id
order by royalty desc;

/*Using the output from Step 1, write a query, containing a subquery, to obtain the following output:

Title ID
Author ID
Aggregated royalties of each title for each author
Hint: use the SUM subquery and group by both au_id and title_id
In the output of this step, each title should appear only once for each author.*/

select title_id, au_id, sum(royalty) as sum_royalty,sum(advance) as sum_advance
from (select sales.title_id, titleauthor.au_id, round(titles.advance * titleauthor.royaltyper / 100) as advance, round(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as royalty
from sales
inner join titleauthor 
on titleauthor.title_id = sales.title_id
inner join titles
on titles.title_id = titleauthor.title_id
order by royalty desc) sub1
group by title_id, au_id
order by sum_royalty desc;

/* Now that each title has exactly one row for each author where the advance and royalties are available, we are ready to obtain
 the eventual output. Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:
Author ID
Profits of each author by aggregating the advance and total royalties of each title
Sort the output based on a total profits from high to low, and limit the number of rows to 3.*/


Select au_id, (sum_royalty + sum_advance) as Profits
from (select title_id, au_id, sum(royalty) as sum_royalty,sum(advance) as sum_advance
from (select sales.title_id, titleauthor.au_id, round(titles.advance * titleauthor.royaltyper / 100) as advance, round(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as royalty
from sales
inner join titleauthor 
on titleauthor.title_id = sales.title_id
inner join titles
on titles.title_id = titleauthor.title_id
order by royalty desc) sub1
group by title_id, au_id
order by sum_royalty desc) sub2
order by Profits desc;


/* In the previous challenge, you have developed your solution the following way:
Derived tables (subqueries).(see reference)
We'd like you to try the other way:
Creating MySQL temporary tables and query the temporary tables in the subsequent steps.
Include your alternative solution in solutions.sql.*/


select sales.title_id, titleauthor.au_id, round(titles.advance * titleauthor.royaltyper / 100) as advance, round(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as royalty
from sales
inner join titleauthor 
on titleauthor.title_id = sales.title_id
inner join titles
on titles.title_id = titleauthor.title_id
order by royalty desc;

create temporary table sub1
select sales.title_id, titleauthor.au_id, round(titles.advance * titleauthor.royaltyper / 100) as advance, round(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) as royalty
from sales
inner join titleauthor 
on titleauthor.title_id = sales.title_id
inner join titles
on titles.title_id = titleauthor.title_id
order by royalty desc;

select title_id, au_id, sum(royalty) as sum_royalty,sum(advance) as sum_advance
from sub1
group by title_id, au_id
order by sum_royalty desc;

create temporary table sub2
select title_id, au_id, sum(royalty) as sum_royalty,sum(advance) as sum_advance
from sub1
group by title_id, au_id
order by sum_royalty desc;

Select au_id, (sum_royalty + sum_advance) as Profits
from sub2
order by Profits desc;

/* Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors 
to hold the data about the most profiting authors. The table should have 2 columns:
au_id - Author ID
profits - The profits of the author aggregating the advances and royalties
Include your solution in solutions.sql. */


Create table most_profiting_table
Select au_id, (sum_royalty + sum_advance) as Profits
from sub2
order by Profits desc;

select * from most_profiting_table;

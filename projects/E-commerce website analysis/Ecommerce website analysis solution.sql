
/*
YOUR OBJECTIVES:
Tell the story of your company's growth, using
trended performance data
• Use the database to explain some of the details
around your growth story, and quantify the
revenue impact of some of your wins
Analyze current performance, and use the data
available to assess upcoming opportunities*/

/*1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions
and orders so that we can showcase the growth there?*/

DROP table  if exists gsearch;
CREATE TEMPORARY TABLE gsearch
SELECT website_sessions.website_session_id
, website_sessions.created_at
, website_sessions.utm_source
, orders.order_id
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
AND website_sessions.created_at <= '2012-11-27';

SELECT min(date(website_sessions.created_at)) AS date_str
, count(website_sessions.website_session_id) AS all_session
, count(gsearch.utm_source) AS gcount
, count(gsearch.utm_source)/count(website_sessions.website_session_id)*100 AS gsearch_prcnt
, count(gsearch.order_id) AS order_cnt
, count(gsearch.order_id)/count(gsearch.utm_source)*100 AS oder_prcnt
FROM website_sessions
LEFT JOIN gsearch
ON gsearch.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at <= '2012-11-27'
GROUP BY year(website_sessions.created_at)
, month(website_sessions.created_at);

/* 2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.*/


SELECT YER
, MNT
, utm_source
, nonbrand
, nonbrand_ord
, nonbrand_ord/nonbrand AS nonbrnd_ord_pcent
, brand
, brand_ord
, brand_ord/brand AS brnd_ord_pcent
FROM (SELECT -- website_session_id
year(website_sessions.created_at) AS YER
, month(website_sessions.created_at) AS MNT
, utm_source
, COUNT(Distinct CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE null END) AS 'nonbrand'
, COUNT(Distinct CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE null END) AS 'nonbrand_ord'
, COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE null END) AS 'brand'
, COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE null END) AS 'brand_ord'
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign IN ('nonbrand', 'brand')
AND website_sessions.created_at <= '2012-11-27'
GROUP BY -- utm_campaign
 year(website_sessions.created_at)
, month(website_sessions.created_at)) a;

/* 3.While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.*/

SELECT YER
, MNT
, mobile
, mobile_order
, mobile_order/mobile AS mobile_ord_pcent
, desktop
, desktop_order
, desktop_order/desktop AS desktop_ord_pcent
FROM (SELECT year(website_sessions.created_at) AS YER
, month(website_sessions.created_at) AS MNT
, COUNT(website_sessions.website_session_id) session
, COUNT(Distinct CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE null END) AS 'mobile'
, COUNT(Distinct CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE null END) AS 'mobile_order'
, COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE null END) AS 'desktop'
, COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE null END) AS 'desktop_order'
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE utm_campaign = 'nonbrand'
AND utm_source = 'gsearch'
AND website_sessions.created_at <= '2012-11-27'
GROUP BY year(website_sessions.created_at) 
, month(website_sessions.created_at)) a ;

/* 4. I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from
Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels? */

SELECT year(website_sessions.created_at) AS YER
, month(website_sessions.created_at) AS MNT
-- , utm_source
, website_sessions.website_session_id
-- , orders.order_id
, COUNT(Distinct CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE null END) AS 'gsearch'
, COUNT(Distinct CASE WHEN utm_source = 'gsearch' THEN orders.order_id ELSE null END) AS 'gsearch_order'
, COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE null END) AS 'bsearch'
, COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN orders.order_id ELSE null END) AS 'bsearch_order'
, COUNT(DISTINCT CASE WHEN utm_source is Null AND http_referer is not null THEN website_sessions.website_session_id ELSE null END) AS 'orgnicsearch'
, COUNT(DISTINCT CASE WHEN utm_source is Null AND http_referer is not null THEN orders.order_id ELSE null END) AS 'orgnicsearch_order'
, COUNT(DISTINCT CASE WHEN utm_source is Null AND http_referer is null THEN website_sessions.website_session_id ELSE null END) AS 'directsearch'
, COUNT(DISTINCT CASE WHEN utm_source is Null AND http_referer is  null THEN orders.order_id ELSE null END) AS 'directsearch_order'
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id 
WHERE website_sessions.created_at <= '2012-11-27'
GROUP BY year(website_sessions.created_at) 
, month(website_sessions.created_at);

/* 5. I'd like to tell the story of our website performance improvements over the course of the first 8 months.
Could you pull session to order conversion rates, by month? */

SELECT year(website_sessions.created_at) AS YER
, month(website_sessions.created_at) AS MNT
, COUNT(distinct website_sessions.website_session_id) session
, Count(distinct order_id) AS order_cnt
, Count(distinct order_id) / COUNT(distinct website_sessions.website_session_id) as order_ratio
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at <= '2012-11-27'
GROUP BY year(website_sessions.created_at) 
, month(website_sessions.created_at);


/* 6. For the landing page test you analyzed previous it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 - Jul 28).*/

SELECT  a.pageview_url
,  count(CASE WHEN a.products_page = '1' THEN a.website_session_id ELSE null END) AS to_products
, count(CASE WHEN a.fuzzy_page = '1' THEN a.website_session_id ELSE null END) AS to_fuzzy
,   count(CASE WHEN a.cart_page = '1' THEN a.website_session_id ELSE null END) AS to_cart
,  count(CASE WHEN a.shipping_page = '1' THEN a.website_session_id ELSE null END) AS to_shipping
, count(CASE WHEN a.billing_page = '1' THEN a.website_session_id ELSE null END) AS to_billing
,  count(CASE WHEN a.thank_page = '1' THEN a.website_session_id ELSE null END) AS to_thankyou
FROM (SELECT  website_sessions.website_session_id
, website_pageviews.pageview_url
, count(distinct CASE WHEN pageview_url = '/products' THEN website_sessions.website_session_id ELSE null END) AS products_page
, count(distinct CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_sessions.website_session_id ELSE null END) AS fuzzy_page
, count(distinct CASE WHEN pageview_url = '/cart' THEN website_sessions.website_session_id ELSE null END) AS cart_page
, count(distinct CASE WHEN pageview_url = '/shipping' THEN website_sessions.website_session_id ELSE null END)  AS shipping_page
, count(distinct CASE WHEN pageview_url = '/billing' THEN website_sessions.website_session_id ELSE null END) AS billing_page
, count(distinct CASE WHEN pageview_url = '/thank-you-for-your-order' THEN website_sessions.website_session_id ELSE null END) AS thank_page
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
-- AND  pageview_url in  ('/home', '/lander-1')
AND website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
GROUP BY website_sessions.website_session_id )a
WHERE pageview_url in  ('/home', '/lander-1')
GROUP BY a.pageview_url;

/* 7. I'd love for you to quantify the impact of our billing test, (Sep 10 - Nov 10), in terms of 
revenue per billing page session for the past month to understand monthly impact. */

SELECT  website_pageviews.pageview_url
, COUNT(distinct website_pageviews.website_session_id) AS sessions
, COUNT(Distinct orders.order_id) AS order_cnt
, SUM(orders.price_usd)
,  SUM(orders.cogs_usd)
, (SUM(orders.price_usd) - SUM(orders.cogs_usd)) AS REvenue
, ((SUM(orders.price_usd) - SUM(orders.cogs_usd))/COUNT(distinct website_pageviews.website_session_id)) AS revenue_per_page
FROM website_pageviews
LEFT JOIN orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at Between '2012-09-10' AND '2012-11-10'
AND website_pageviews.pageview_url in ('/billing', '/billing-2')
GROUP BY pageview_url;

/* 8. First, I'd like to show our volume growth. Can you pull overall session and order volume, trended by quarter
for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.*/

SELECT year(website_sessions.created_at) year
, quarter(website_sessions.created_at) quater
, count(distinct website_sessions.website_session_id) as session 
, count(distinct order_id) as order_volume
FROM website_sessions
LEFT JOIN ORDERS
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at <= '2015-03-20'
GROUP BY year(website_sessions.created_at) 
, quarter(website_sessions.created_at);

/* 9. Next, let's showcase all of our efficiency improvements. I would love to show quarterly figures since we
launched, for session-to-order conversion rate, revenue per order, and revenue per session */

SELECT year(website_sessions.created_at) year
, quarter(website_sessions.created_at) quater
, count(distinct website_sessions.website_session_id) as session 
, count(distinct order_id) as order_volume
, count(distinct order_id)/count(distinct website_sessions.website_session_id) AS sess_ordr_ctr
, sum(orders.price_usd) AS revenue
, sum(orders.price_usd)/count(distinct order_id) As rev_per_order
, sum(orders.price_usd)/count(distinct website_sessions.website_session_id) As rev_per_sess
FROM website_sessions
LEFT JOIN ORDERS
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at <= '2015-03-20'
GROUP BY year(website_sessions.created_at) 
, quarter(website_sessions.created_at);


/* 10. I'd like to show how we've grown specific channels. Could you pull a quarterly view of orders from search
nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?*/

SELECT year(website_sessions.created_at) year
, quarter(website_sessions.created_at) quater
, count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.website_session_id else null end) AS 'gsearch_nonbrnd'
, count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then orders.website_session_id else null end) AS 'bsearch_nonbrnd'
,  count(distinct case when utm_campaign = 'brand' then orders.website_session_id else null end) AS 'brand'
, count(distinct case when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then orders.website_session_id else null end) AS 'organic'
, count(distinct case when utm_source is null and http_referer is null then orders.website_session_id else null end) AS 'direct'
FROM ORDERS
LEFT JOIN website_sessions
ON website_sessions.website_session_id = orders.website_session_id 
WHERE website_sessions.created_at <= '2015-03-20'
GROUP BY year(website_sessions.created_at) 
, quarter(website_sessions.created_at) ;

/* 11. Next, let's show the overall session-to-order conversion rate trends for those same channels, by quarter.
Please also make a note of an periods where we made major improvements or optimizations */

SELECT year(website_sessions.created_at) year
, quarter(website_sessions.created_at) quater
, count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then orders.website_session_id else null end)/ count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as 'gsearch_nonbrnd_ctr'
, count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then orders.website_session_id else null end)/count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) AS 'bsearch_nonbrnd_ctr'
, count(distinct case when utm_campaign = 'brand' then orders.website_session_id else null end) / count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) AS 'brand_ctr'
, count(distinct case when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then orders.website_session_id else null end)/count(distinct case when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then website_sessions.website_session_id else null end) AS 'organic_ctr'
, count(distinct case when utm_source is null and http_referer is null then orders.website_session_id else null end)/count(distinct case when utm_source is null and http_referer is null then website_sessions.website_session_id else null end) AS 'direct_ctr'
FROM ORDERS
RIGHT JOIN website_sessions
ON website_sessions.website_session_id = orders.website_session_id 
WHERE website_sessions.created_at <= '2015-03-20'
GROUP BY year(website_sessions.created_at) 
, quarter(website_sessions.created_at) ;

/* 12. We've come a long way since the days of selling a single product. Let's pull monthly trending for revenue
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.*/

SELECT year(Orders.created_at) yr
, month(Orders.created_at) mn
-- , sum(items_purchased) as sales
, sum(price_usd) as rev
, sum(case when primary_product_id = '1' then price_usd else null end) As prdkt_1
, sum(case when primary_product_id = '1' then (price_usd-cogs_usd) else null end) As prdkt_1_margin
,sum(case when primary_product_id = '2' then price_usd else null end) As prdkt_2
, sum(case when primary_product_id = '2' then (price_usd-cogs_usd) else null end) As prdkt_2_margin
, sum(case when primary_product_id = '3' then price_usd else null end) As prdkt_3
, sum(case when primary_product_id = '3' then (price_usd-cogs_usd) else null end) As prdkt_3_margin
, sum(case when primary_product_id = '4' then price_usd else null end) As prdkt_4
, sum(case when primary_product_id = '4' then (price_usd-cogs_usd) else null end) As prdkt_4_margin
-- , price_usd
-- , cogs_usd
FROM Orders
WHERE Orders.created_at <= '2015-03-20'
GROUP BY year(Orders.created_at) 
, month(Orders.created_at);

/* 13. Let's dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products
page, and show how the % of those sessions clicking through another page has changed over time, along with
a view of how conversion from /products to placing an order has improved.*/


DROP TABLE IF EXISTS pdct_sess;
CREATE TEMPORARY TABLE pdct_sess
SELECT year(website_pageviews.created_at) yr
, month(website_pageviews.created_at) mn
, website_pageviews.website_pageview_id
, website_pageviews.website_session_id
, (case when pageview_url ='/products' then website_pageviews.website_session_id else null end ) as prdkt_pg_sess
FROM website_pageviews
WHERE website_pageviews.created_at <= '2015-03-20';



DROP TABLE IF EXISTS page_sess;
CREATE TEMPORARY TABLE page_sess
SELECT yr
, mn
, pdct_sess.website_pageview_id
, pdct_sess.website_session_id
, prdkt_pg_sess
, (case when pdct_sess.website_session_id = prdkt_pg_sess then pdct_sess.website_pageview_id else null end ) as prdkt_pg_id
FROM pdct_sess;

DROP TABLE IF EXISTS page_view;
CREATE TEMPORARY TABLE page_view
SELECT yr
, mn
-- , page_sess.website_pageview_id
, page_sess.website_session_id
, prdkt_pg_sess
, prdkt_pg_id
-- , website_pageviews.website_pageview_id
, (case when website_pageviews.website_pageview_id > page_sess.prdkt_pg_id then website_pageviews.website_pageview_id else null end) as web_pg_id
FROM page_sess
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = page_sess.website_session_id
group by 4,6;


SELECT pdct_sess.yr
, pdct_sess.mn
, count(distinct pdct_sess.prdkt_pg_sess) sess
, count(distinct  a.web_pg_id) next_pg
, count(distinct  a.web_pg_id)/count(distinct pdct_sess.prdkt_pg_sess) as nxt_pg_conv_rate
, count(distinct order_id) as ordrs
, count(distinct order_id)/count(distinct pdct_sess.prdkt_pg_sess) sess_order_conv_rate
FROM 
(SELECT yr
, mn
-- , page_sess.website_pageview_id
, page_view.website_session_id
, prdkt_pg_sess
, prdkt_pg_id
,  web_pg_id
, order_id
FROM page_view
left join orders
on orders.website_session_id = page_view.website_session_id
WHERE web_pg_id is not null
group by 4 ) a
right join pdct_sess
on pdct_sess.website_session_id = a.website_session_id
GROUP BY pdct_sess.yr
, pdct_sess.mn;


/* 14. We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell
item). Could you please pull sales data since then, and show how well each product cross-sells from one another?*/

DROP TABLE IF EXISTS crss_sell;
CREATE TEMPORARY TABLE crss_sell
select a.order_id
, a.website_session_id
, a.primary_product_id
, Order_items.product_id 
from (SELECT order_id
, website_session_id
, primary_product_id 
FROM Orders
where created_at > '2014-12-05'
and created_at <= '2015-03-20') a
left join Order_items
on Order_items.order_id =a.order_id
where is_primary_item = '0';

SELECT primary_product_id
, count(distinct order_id) as ordr
, count( case when product_id ='1' then order_id else null end) sold_p1
, count( case when product_id ='2' then order_id else null end) sold_p2
, count( case when product_id ='3' then order_id else null end) sold_p3
, count( case when product_id ='4' then order_id else null end) sold_p4
, count( case when product_id ='1' then order_id else null end)/count(distinct order_id) as sold_p1_rt
, count( case when product_id ='2' then order_id else null end)/count(distinct order_id) as sold_p2_rt
, count( case when product_id ='3' then order_id else null end)/count(distinct order_id) as sold_p3_rt
, count( case when product_id ='4' then order_id else null end)/count(distinct order_id) as sold_p4_rt
FROM crss_sell
GROUP BY 1;



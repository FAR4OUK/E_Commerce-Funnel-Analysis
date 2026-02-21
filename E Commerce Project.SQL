

---- Defining Our Website Funnel to Detect Our Users' Behavior ----
WITH Funnel AS ( SELECT

COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS STEP_1,
COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS STEP_2,
COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS STEP_3,
COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS STEP_4,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS STEP_5
FROM E_COMMERCE
)

SELECT * FROM Funnel;

------- Determine The Conversion Rate Between Each Step of the Funnel AND We'll Determine the OVERALL CONVERSION RATE From The First Step to The Last Step
SELECT
ROUND(STEP_2 * 100.0 / STEP_1, 2) AS CR_VIEW_TO_CART,
ROUND(STEP_3 * 100.0 / STEP_2, 2) AS CR_CART_TO_CHECKOUT,
ROUND(STEP_4 * 100.0 / STEP_3, 2) AS CR_CHECKOUT_TO_PAYMENT,
ROUND(STEP_5 * 100.0 / STEP_4, 2) AS CR_PAYMENT_TO_PURCHASE,
ROUND(STEP_5 * 100.0 / STEP_1, 2) AS OVERALL_CONVERSION_RATE
FROM Funnel;

-- From This Analysis, We Can See That The CR_PAYMENT_TO_PURCHASE is The highest , 
--Which indicates That There's No Technical Issues During Payment
-- However, The CR_VIEW_TO_CART is The lowest , 
--Which Indicates That There's A Problem During This Step ( Maybe The Products are the problem ( Price or the product itself idk...))

-- Let's Dig Into Source Funnel To See Which Traffic Source is The Best and Which One is The Worst

WITH Source_Funnel AS ( SELECT
traffic_source,
COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS STEP_1,
COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS STEP_2,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS STEP_5
FROM E_COMMERCE
GROUP BY traffic_source
)

SELECT traffic_source, STEP_1, STEP_2, STEP_5,
ROUND(STEP_2 * 100.0 / STEP_1, 2) AS CR_VIEW_TO_CART,
ROUND(STEP_5 * 100.0 / STEP_2, 2) AS CR_CART_TO_PURCHASE,
ROUND(STEP_5 * 100.0 / STEP_1, 2) AS OVERALL_CONVERSION_RATE
FROM Source_Funnel
ORDER BY STEP_5 DESC;



-- TIME TO CONVERSION ANALYSIS --

WITH User_journey AS ( SELECT
user_id,
MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS View_time,
MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS Cart_time,
MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS Purchase_time
FROM E_commerce
GROUP BY user_id
HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL

)

SELECT COUNT(*) AS TOTAL_USERSCONVERTED,
ROUND(AVG(DATEDIFF(MINUTE, View_time, Cart_time)),2) AS AVG_TIME_TO_CART,
ROUND(AVG(DATEDIFF(MINUTE, Cart_time, Purchase_time)),2) AS AVG_TIME_TO_PURCHASE,
ROUND(AVG(DATEDIFF(MINUTE, View_time, Purchase_time)),2) AS AVG_TIME_TO_CONVERSION
FROM User_journey;


-- Revenue Funnel Analysis --
WITH Revenue_Funnel AS ( SELECT

COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS Total_visitors,
COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS Total_buyers,
SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS Total_revenue,
COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS Total_orders

FROM E_commerce
)
---- Calculating AOV (Average Order Value) and ARPU (Average Revenue Per Buyer) And ARPV (Average Revenue Per Visitor) to Understand The Revenue Generated From Each User and Each Order
SELECT Total_visitors, Total_buyers, ROUND(Total_revenue, 2) AS Total_revenue, Total_orders,
ROUND(TOTAL_REVENUE/ Total_orders, 2) AS AOV,
ROUND(TOTAL_REVENUE/ Total_buyers, 2) AS ARPB,
ROUND(TOTAL_REVENUE/ Total_visitors, 2) AS ARPV
FROM Revenue_Funnel;
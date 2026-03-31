# Project Background
Olist is a Brazil-based e-commerce platform that enables small and medium-sized businesses to sell their products through major online marketplaces. It provides an integrated solution that helps sellers manage orders, payments, and logistics in a centralized system.

This analysis aims to explore these challenges by examining sales trends, customer segmentation, product performance, and shipment efficiency. By leveraging data-driven insights, this project seeks to identify key factors affecting business performance and provide actionable recommendations to improve revenue growth, customer retention, and overall customer experience. 


# Data Structure
The dataset contains details of 100,000 orders spanning from 2016 to 2018. The schema is shown below : 
![alt text](Schema.svg)

# Executive Summary
We focused on the following KPIs:
- **Sales Performance** : The value purchase of the customers and revenue growth over 2017 and 2018. Further analysis is segmented by product category and customer state
- **Customer Behavior** : The segmentation of the customer and cohort-based retention. This includes comparing the number of customers with total orders
- **Product Performance** : Evaluates top-selling categories, average review scores, and repeat purchase rates by product category.
- **Shipment Performance** :The average delivery duration across customer states and analyzes how shipment delays impact customer review scores. 

## Sales Performance
- Overall revenue increased by **20%** from 2017 to 2018, with notable monthly spikes in January **(+26.94%)** and March **(+16.85%)**
- **Paraíba (PB)** recorded the highest average sales value at **$272.73**, despite having only **516 customers**. In contrast, **São Paulo (SP)** had the largest customer base, with **over 40,000 customers**,with a lower average value **($148.84)**.
- Revenue and order volume grew steadily throughout 2017, peaking at **$1.2M** in November, before stabilizing in 2018.
## Customer Behavior
- High Value Segment **(25% of customers)** account for **59.65%** of revenue **($9.55M)**
- Mid Value Segment **(50% of customers)** drives **33.8%** of revenue **($5.41M)**
- Low Value Segment **(25% of customers)** generates **6.6%** of revenue **($1.04M)**
- The minimal gap between total customers and total orders indicates that most customers make only a single purchase, resulting in very low retention rates **(<1% across cohorts)**.
## Product Performance
- health beauty and sport leisure have both high quantity and high ratings **(around 4.15 – 4.18)**, while bed bath table exhibit high quantity but relatively lower ratings **(around 3.97 – 4.02)**. In contrast, auto, and garden tools achieve relatively high ratings **(above 4.10)** despite having lower quantity, and a number of products display both low quantity and lower ratings **(around 4.00 or below)**
- Overall repeat purchase rate is low **(1.47%)**, with most categories remaining below **5%**, suggesting limited customer loyalty across products.
## Shipment Performance
- **Early deliveries** (faster than estimated) receive the highest ratings **(4.29)**, while **very late deliveries** (more than three days beyond the estimated delivery date) have the lowest ratings **(1.86)**. Late deliveries **(3.29)** show higher ratings than **on-time (2.47)** deliveries.
- Average freight peaked at around **$30** in September, coinciding with the lowest review score **(1.0)**. In contrast, December recorded the lowest freight **($8.72)** and the highest review score **(5.0)**. Furthermore, periods with moderate freight levels **(~$21 – $23)** consistently maintained high review scores **(~4.0 – 4.5)**
# Recommendations
- With retention rates below 1%, most customers make only a single purchase. **Implement loyalty programs, personalized marketing, and retargeting strategies to increase repeat purchases**.
- High shipping costs (up to $30) are strongly associated with low customer satisfaction (1.0 rating). **Introduce cost optimization strategies such as shipping subsidies, dynamic pricing, or free shipping thresholds, while improving delivery speed**.
- Regions like São Paulo have a large customer base but lower average order value. **Apply bundling, upselling, and promotional strategies to increase revenue per transaction**.
- The top 25% of customers contribute nearly 60% of revenue. Focus on retention and engagement strategies such as **exclusive offers, priority service, and personalized experiences**.
- Categories like **bed bath & table** show high sales but relatively lower ratings. **Investigate product quality, descriptions, and customer expectations to improve satisfaction**.
- Early deliveries achieve the highest ratings (4.29), highlighting the importance of faster delivery. **Improve logistics efficiency and provide more accurate delivery estimates to align with customer expectations**.
# Dashboard
The interactive Power BI Dashboard can be found [here](https://app.powerbi.com/view?r=eyJrIjoiNmQ1YmQ2ZjMtNWEwMS00MjhiLWI2M2QtODJlMzdiN2M4MzRlIiwidCI6IjQ3ZDY2NGIzLWQ5ZjctNDM3NC1iMmFkLWU1ZTI5NjA3ZjIwYSJ9) 

![alt text](Dashboard.jpg)
# Data Source
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
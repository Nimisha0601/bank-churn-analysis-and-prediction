USE Project;

SELECT * FROM BankChurn;
 
-- ## Let's find out the patterns that are leading to churn in the bank.
-- Who are they (demographics)?

-- What do they do (behavior)?

-- What do they have (products, balance)?

-- What are they lacking (features not used)?


-- Overall Churn in the Bank
SELECT COUNT(*) AS 'total_customers', (SELECT COUNT(*) FROM BankChurn WHERE Exited = 1) AS 'Exited_customers' FROM BankChurn;
-->> Out of 10000 customers, 2037 have exited from the bank.


-----------------------------------------------**** Churn + Active Members ****------------------------------------------------------
SELECT IsActiveMember, COUNT(*) AS 'total_members_active' FROM BankChurn
WHERE Exited = 1
GROUP BY IsActiveMember;
-- >> Out of total customers who exited, 1302 are Active customers while 735 are Inactive customers.
-- >> Meaning, more people were inactive who left the Bank.


--Q1. Why 1302 people were Inactive?
--Q2. 735 were active but still left the Bank. Why so?



-- What is the Avg Balance of people who were active and who were inactive.
SELECT IsActiveMember, ROUND(AVG(Balance),2) AS 'avg_balance' FROM BankChurn
WHERE Exited = 1
GROUP BY IsActiveMember;
-- >> Avg balance is around 90000 for both active and inactive customers. <<



SELECT IsActiveMember, ROUND(AVG(NumOfProducts),2) AS 'avg_num_of_products' FROM BankChurn
WHERE Exited = 1
GROUP BY IsActiveMember;
-->> Avg num of products is 1 <<



-- How many number of products were the customers using who Exited and were also active?
SELECT NumOfProducts, COUNT(*) AS 'Exited_Active_Customers' FROM BankChurn
WHERE Exited = 1 AND IsActiveMember = 1
GROUP BY NumOfProducts
ORDER BY Exited_Active_Customers DESC;
-- >> The customers who were active and Exited had been using only 1(majorly) - 2 products.
-- They should have been offered more bank products in order to retain.<<



-- How many number of products were the customers using who Exited and were  Inactive?
SELECT NumOfProducts, COUNT(*) AS 'Exited_Inactive_Customers' FROM BankChurn
WHERE Exited = 1 AND IsActiveMember = 0
GROUP BY NumOfProducts
ORDER BY Exited_Inactive_Customers DESC;
-- >> The customers who were Inactive and Exited had also been using only 1 product majorly


-- What is the Avg account balance of customers who Exited and were Active
SELECT NumOfProducts, COUNT(*) AS 'Exited_Active_Customers', ROUND(AVG(Balance),2) AS 'Avg_Balance' FROM BankChurn
WHERE Exited = 1 AND IsActiveMember = 1
GROUP BY NumOfProducts
ORDER BY Exited_Active_Customers DESC;
-- >> A fairly good amount of avg account balance is seen over here of customers who exited and were active.
-- Q. Was the service not good?


SELECT Tenure, NumOfProducts, COUNT(*) AS 'Exited_Active_Customers', ROUND(AVG(Balance),2) AS 'Avg_Balance' FROM BankChurn
WHERE Exited = 1 AND IsActiveMember = 1 AND Tenure > 5 AND Gender = 'Male'
GROUP BY Tenure, NumOfProducts
ORDER BY Tenure ASC, Exited_Active_Customers DESC;

-- How many Exited customers had zero balance and whether they were active or not
SELECT IsActiveMember, COUNT(*) AS 'Exited_Customers' FROM BankChurn
WHERE Exited = 1 AND Balance = 0
GROUP BY IsActiveMember;



----------------------------------------**** CREATING FUNCTION FOR AGE BRACKET ****-------------------------------------------------
CREATE FUNCTION FUNC_AgeBracket (@Age INT)
RETURNS VARCHAR(25)
AS
BEGIN
	DECLARE @Age_Bracket VARCHAR(20)

	SET @Age_Bracket = CASE WHEN @Age <=30 THEN '18-30'
							WHEN @Age >=31 AND @Age <=40 THEN '31-40'
						    WHEN @Age >=41 AND @Age <=50 THEN '41-50'
							WHEN @Age >=51 AND @Age <=60 THEN '51-60'
							WHEN @Age >=61 AND @Age <=70 THEN '61-70'
							ELSE 'Above 70'
				       END
	RETURN @Age_Bracket
END;

----------------------------------------**** CREATING FUNCTION FOR BALANCE BRACKET ****-------------------------------------------------
CREATE FUNCTION FUNC_BalBracket (@Bal INT)
RETURNS VARCHAR(40)
AS
BEGIN
	DECLARE @Bal_Bracket VARCHAR(40)

	SET @Bal_Bracket =  CASE WHEN @Bal = 0 THEN '0'
							 WHEN @Bal > 0 AND @Bal <= 50000 THEN '(<50K) Low'
							 WHEN @Bal > 50000 AND @Bal <= 100000 THEN '(51K - 100K) Medium'
							 WHEN @Bal > 100000 AND @Bal <= 200000 THEN '(101K - 200K) High'
						ELSE 'Above 200K Very High'
				       END
	RETURN @Bal_Bracket
END;

----------------------------------------**** CREATING FUNCTION FOR CREDIT SCORE RANGE ****-------------------------------------------------
CREATE FUNCTION FUNC_CrScoreBracket (@CS INT)
RETURNS VARCHAR(40)
AS
BEGIN
	DECLARE @CS_Bracket VARCHAR(40)

	SET @CS_Bracket = CASE WHEN @CS >=300 AND @CS <=579 THEN '300-579 Poor'
						   WHEN @CS >=580 AND @CS <=669 THEN '580-669 Fair'
						   WHEN @CS >=670 AND @CS <=739 THEN '670-739 Good'
						   WHEN @CS >=740 AND @CS <=799 THEN '740-799 Very Good'
						   ELSE '800-850 Excellent'
					  END
	RETURN @CS_Bracket
END;




-----------------------------------------------**** Churn based on Age brackets ****------------------------------------------------

SELECT DBO.FUNC_AgeBracket(Age) AS 'Age_Bracket', COUNT(*) AS 'Total_Exited'
FROM BankChurn
WHERE Exited = 1
GROUP BY DBO.FUNC_AgeBracket(Age)
ORDER BY Total_Exited DESC;
-- >> We observe that most of the churn has happened between the Age 31-60.
-- Older people i.e. above 60 and customers with Age less than 31 has churned less as compared to the above age group.



---------------------------------------------**** Credit Score + Churn count ****-----------------------------------------------------
SELECT DBO.FUNC_CrScoreBracket(CreditScore) AS 'Credit_score_range', COUNT(*) AS 'Total_Exited'
FROM BankChurn
WHERE Exited = 1
GROUP BY DBO.FUNC_CrScoreBracket(CreditScore)
ORDER BY Total_Exited DESC;
-- >> We observe that majority of the churned customers have a poor - fair credit score.


-- Gender based churn
SELECT Gender, COUNT(*) AS 'Churned_customers' FROM BankChurn
WHERE Exited = 1
GROUP BY Gender;
-- Male - 898, Female - 1139(highest churn)

-- Geography based Churn Count
SELECT Geography, COUNT(*) AS Churned_Customers
FROM BankChurn
WHERE Exited = 1
GROUP BY Geography;
-- >> Germany and Spain has highest churn count with 814 and 810 resp.


-- Geography based Churn rate
SELECT Geography, FLOOR(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0/COUNT(*)) AS 'Churn_rate'
FROM BankChurn
GROUP BY Geography;


-- Total Customers using different number of products and their Churn rate.
SELECT NumofProducts, COUNT(*) AS 'Total_customers',
SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS 'Churned_Customers',
ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)* 100.0/ COUNT(*),2) AS Churn_rate_percentage FROM BankChurn
GROUP BY Numofproducts
ORDER BY NumOfProducts;
-- >> People using 1-2 products are high, but their churn rate is low.
-- >> Whereas, People using 3-4 products are having a very high churn rate. Here we are losing high-valued customer; which is not good for bank's revenue. <<



---------------------------------------------**** Balance Bracket Vs Churn ****---------------------------------------------------

SELECT DBO.FUNC_BalBracket(Balance) AS 'Balance_Bracket',
COUNT(*) AS 'Total_customers',
SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS 'Churned_Customers',
ROUND(SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)* 100.0/ COUNT(*),2) AS Churn_rate_percentage
FROM BankChurn
GROUP BY DBO.FUNC_BalBracket(Balance)
ORDER BY Churned_Customers DESC;

-- >>  Very High Balance Customers Have the Highest Churn Rate
--	55.88% churn among customers with balance >200K — this is a serious issue.
-- Even though they are few in number (34 customers), these are likely high net-worth individuals (HNI).
-- Losing them likely means a bigger loss in revenue and relationship value than regular customers.
-- Business Insight: The bank must prioritize retention strategies for this segment, maybe personalized services or wealth management.

-- *Action Area*									*Why*
-- High-Value Retention Plan						>200K balance clients churn the most proportionally.
-- Upselling/Engagement Campaign					101K–200K group is big in number; modest churn can mean high revenue loss.
-- Targeted Campaign for Low Balance				High churn from low balance — check service quality & experience here.
-- Low Focus on Zero Balance						Losing them isn’t financially heavy — but converting them could be a win.

-- Summary:
--Customers with higher balances are churning more proportionally, and these customers are likely more profitable.
--This indicates a serious service quality, satisfaction, or unmet expectation issue among the bank's top-tier clients.
--Immediate attention is needed on client relationship management for high-net-worth customers.



----------------------------------------**** Churn by Balance + Active Status ****------------------------------------------------

SELECT DBO.FUNC_BalBracket(Balance) AS Balance_Bracket, IsActiveMember, COUNT(*) AS Total_Customers
FROM BankChurn WHERE Exited = 1
GROUP BY DBO.FUNC_BalBracket(Balance), IsActiveMember
ORDER BY Balance_Bracket, IsActiveMember;
-- >>  High balance customers churning despite being active. Customers with Balance between 101K - 200K and above.


----------------------------------------**** Churn by Balance + Number of Products ****------------------------------------------------

SELECT DBO.FUNC_BalBracket(Balance) AS Balance_Bracket, NumOfProducts, COUNT(*) AS Churned_Customers
FROM BankChurn
WHERE Exited = 1
GROUP BY  DBO.FUNC_BalBracket(Balance), NumOfProducts
ORDER BY Balance_Bracket, NumOfProducts;
-->> Customers with 1 product show the highest churn across all balance brackets, especially in the High (101K–200K) and 0 balance groups.
-- Churn drops significantly as the number of products increases. This indicates that cross-selling could reduce churn. <<



-----------------------------------------**** Churn by Gender + Balance Bracket **** ---------------------------------------------------

SELECT Gender, DBO.FUNC_BalBracket(Balance) AS Balance_Bracket, COUNT(*) AS Churned_Customers
FROM BankChurn
WHERE Exited = 1
GROUP BY Gender, DBO.FUNC_BalBracket(Balance)
ORDER BY Churned_Customers DESC;
-- >> Female customers churn more than males across all balance brackets, especially in the High (101K–200K) and 0 balance groups.
-- This suggests that female customers may need more personalized engagement or support to reduce churn.
-- >> While the churn count is low in the Above 200K balance bracket due to fewer customers, the churn rate is the highest,
-- indicating that high-value customers are leaving more proportionally.
-- This signals an urgent need for retention strategies tailored to premium customers. <<<<



-----------------------------------------**** Churn by Geography + Balance Bracket ****---------------------------------------------

SELECT Geography, DBO.FUNC_BalBracket(Balance) AS Balance_Bracket, COUNT(*) AS Churned_Customers
FROM BankChurn
WHERE Exited = 1
GROUP BY Geography, DBO.FUNC_BalBracket(Balance)
ORDER BY Geography, Churned_Customers DESC;
--*Germany* has the highest churn among high-balance customers (101K–200K), with 706 exits, suggesting a serious retention issue
-- with affluent German clients.

--*France* shows a concerning churn among customers with zero balance (337 exits) — possibly indicating dormant or dissatisfied low-engagement users.

--*Spain's* churn is more evenly spread, but even here, high-balance customers are leaving, especially in the 101K–200K bracket.

--**Recommendation:**
--For Germany: Focus on premium service improvements and loyalty programs.
--For France: Investigate reasons behind zero-balance customer exits — maybe upsell or engage them better.
--For Spain: Continue balanced engagement strategies, but don't neglect high-value customers.


-----------------------------------------**** Churn by Tenure + Active Member + Balance ****---------------------------------------------

SELECT Tenure, IsActiveMember, DBO.FUNC_BalBracket(Balance) AS Balance_Bracket, COUNT(*) AS Churned_Customers
FROM BankChurn
WHERE Exited = 1
GROUP BY Tenure, IsActiveMember, DBO.FUNC_BalBracket(Balance)
ORDER BY Tenure, Balance_Bracket;

-- Observations:
--Customers with low tenure (0–2 years) and high balances (101K–200K) are churning more when they are inactive. For example:
--Tenure = 1 & Inactive in (101K–200K): 93 churns
--enure = 1 & Active in (101K–200K): 46 churns

-- *Insight:* High-value customers who don’t engage early are at high risk. Early-stage retention efforts should be stronger for high-balance clients.
--			  Churn is significantly higher for inactive members across most tenure levels, regardless of balance. This pattern is consistent:
--			  Tenure 3, Inactive (101K–200K): 73 churns
--			  Tenure 3, Active (101K–200K): 47 churns
--			  Tenure 5, Inactive (101K–200K): 66 churns
--			  Tenure 5, Active (101K–200K): 54 churns
--			  Insight: Inactivity is a stronger churn signal than even low tenure. Retention programs should prioritize re-engaging inactive users,
--					   especially those with high balances.


--------------------------------------------**** Correlation Check via SQL (for numeric variables) ****------------------------------------------
SELECT 
  AVG(CAST(Exited AS FLOAT)) AS Churn_Rate,
  AVG(Age) AS Avg_Age,
  AVG(Balance) AS Avg_Balance,
  AVG(CreditScore) AS Avg_CreditScore,
  AVG(Tenure) AS Avg_Tenure
FROM BankChurn
GROUP BY NumOfProducts

--**Higher Churn Rate (0.82 to 1) is seen among:**
--	Older customers (Avg Age: 43–45)
--	Lower to moderate credit scores (648–653)
--	Medium account balances (~75K–94K)

--**Lowest Churn (7.6%) is for:**
--	Younger customers (Age ~37)
--	Lowest average balance (~51K)
--	Likely less committed, but also lower risk customers.

----------------------------------------------****** SUMMARY OF THE ANALYSIS ******----------------------------------------------------------

-- >> FINDINGS <<
-- 1. Overall churn rate: 20%
-- 2. Most churned segment: High balance, active, only 1 product.
--Concerning groups: Females, Germans, short-tenure customers, multi-product churners.

-- >> WHAT NEEDS ATTENTION? <<
-- 1. Prevent loss of high-value clients with better service and engagement.
-- 2. Onboard and educate new users more effectively.
-- 3. Cross-sell to single-product users before they churn.
-- 4. Localize and personalize customer experience by gender and geography.

-- >> WHAT ACTIONS TO TAKE? <<
-- 1. Build targeted retention campaigns for each group.
-- 2. Launch customer success initiatives (RM, onboarding, cross-sell).
-- 3. Set up monitoring dashboards to track high-risk customers.
-- 4. Continuously collect and act on feedback.


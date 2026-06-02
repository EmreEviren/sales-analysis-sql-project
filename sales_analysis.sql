/*
=========================================================
SQL Sales Analysis Project
=========================================================

Bu projede Superstore veri seti kullanılarak satış analizi yapılmıştır.

Proje içerisinde:

- Veri kontrolü
- Veri kalitesi analizi
- KPI analizi
- Kategori analizi
- Şehir / bölge analizi
- Ürün analizi
- Müşteri analizi
- Window Function kullanımı
- CTE kullanımı

gibi temel veri analizi işlemleri gerçekleştirilmiştir.

Kullanılan SQL Konuları:

- GROUP BY
- ORDER BY
- HAVING
- CASE WHEN
- Aggregate Functions
- CTE
- ROW_NUMBER()
- RANK()

=========================================================
*/





-- Superstore veri analizi projesi için veritabanını oluşturuyorum. 
CREATE DATABASE SalesAnalysis


-- Veri setini saklamak için ana tabloyu oluşturuyorum.
CREATE TABLE Superstore (
    Row_ID INT PRIMARY KEY,

    Order_ID NVARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode NVARCHAR(50),

    Customer_ID NVARCHAR(50),
    Customer_Name NVARCHAR(100),
    Segment NVARCHAR(50),

    Country NVARCHAR(50),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Postal_Code NVARCHAR(20),
    Region NVARCHAR(50),

    Product_ID NVARCHAR(50),
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(50),
    Product_Name NVARCHAR(255),

    Sales DECIMAL(18,2) NULL,
    Quantity INT NULL,
    Discount DECIMAL(18,2) NULL,
    Profit DECIMAL(18,2) NULL
)

-- Veri setinin doğru yüklenip yüklenmediğini kontrol etmek için
-- tablodaki ilk kayıtları görüntülüyorum.
SELECT TOP 10 *
FROM SampleSuperstore



-- Veri setindeki toplam kayıt sayısını kontrol ediyorum.
-- Bu kontrol veri aktarımı sırasında eksik kayıt olup olmadığını anlamak için önemlidir.
SELECT
    COUNT(*) AS Total_Row_Count
FROM SampleSuperstore


-- Kritik alanlarda eksik veri kontrolü yapıyorum.
-- Özellikle satış ve kâr alanlarında NULL değer olup olmadığını analiz ediyorum.
SELECT
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Missing_Profit,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity
FROM SampleSuperstore



-- Tekrar eden kayıt olup olmadığını kontrol ediyorum.
-- Row_ID alanı benzersiz olması gerektiği için duplicate kayıtları analiz ediyorum.
SELECT
    Row_ID,
    COUNT(*) AS Repeat_Count
FROM SampleSuperstore
GROUP BY Row_ID
HAVING COUNT(*) > 1





-- Veri setinin genel satış performansını özetliyorum.
-- Bu bölüm toplam satış, toplam kâr, sipariş sayısı ve müşteri sayısı gibi temel KPI değerlerini gösterir.
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM SampleSuperstore



-- Genel kârlılık oranını hesaplıyorum.
-- Profit Margin, toplam satışın yüzde kaçının kâra dönüştüğünü gösterir.
SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS Profit_Margin
FROM SampleSuperstore


-- Kategorilere göre toplam satış ve kâr performansını inceliyorum.
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM SampleSuperstore
GROUP BY Category
ORDER BY Total_Sales DESC


-- Kategorilerin kârlılık oranlarını hesaplıyorum.
SELECT
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(SUM(Profit) * 100.0 / SUM(Sales), 2) AS Profit_Margin
FROM SampleSuperstore
GROUP BY Category
ORDER BY Profit_Margin DESC



-- Her kategori içinde en yüksek satış yapan ürünü analiz ediyorum.
SELECT *
FROM
(
    SELECT
        Category,
        Product_Name,
        SUM(Sales) AS Total_Sales,

        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY SUM(Sales) DESC
        ) AS Row_Num

    FROM SampleSuperstore
    GROUP BY Category, Product_Name
) x
WHERE Row_Num = 1


-- En yüksek satış yapılan şehirleri analiz ediyorum.
SELECT TOP 10
    City,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM SampleSuperstore
GROUP BY City
ORDER BY Total_Sales DESC




-- Bölgelere göre satış ve kâr performansını analiz ediyorum.
SELECT
    Region,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM SampleSuperstore
GROUP BY Region
ORDER BY Total_Sales DESC



-- En yüksek kâr sağlayan ürünleri analiz ediyorum.
SELECT TOP 10
    Product_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM SampleSuperstore
GROUP BY Product_Name
ORDER BY Total_Profit DESC



-- Zarar eden ürünleri analiz ediyorum.
SELECT TOP 10
    Product_Name,
    SUM(Profit) AS Total_Profit
FROM SampleSuperstore
GROUP BY Product_Name
ORDER BY Total_Profit ASC


-- En yüksek satış yapılan ürünleri analiz ediyorum.
SELECT TOP 10
    Product_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Quantity) AS Total_Quantity
FROM SampleSuperstore
GROUP BY Product_Name
ORDER BY Total_Sales DESC



-- En fazla satış yapan müşterileri analiz ediyorum.
SELECT TOP 10
    Customer_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM SampleSuperstore
GROUP BY Customer_Name
ORDER BY Total_Sales DESC


-- En fazla sipariş oluşturan müşterileri analiz ediyorum.
SELECT TOP 10
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders
FROM SampleSuperstore
GROUP BY Customer_Name
ORDER BY Total_Orders DESC



-- Müşterileri toplam kâr değerine göre segmentlere ayırıyorum.
SELECT
    Customer_Name,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,

    CASE
        WHEN SUM(Profit) >= 5000 THEN 'High Value'
        WHEN SUM(Profit) >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment

FROM SampleSuperstore
GROUP BY Customer_Name
ORDER BY Total_Profit DESC

-- Ortalama satış değerinin üzerinde kalan ürünleri analiz ediyorum.
WITH ProductSales AS
(
    SELECT
        Product_Name,
        SUM(Sales) AS Total_Sales
    FROM SampleSuperstore
    GROUP BY Product_Name
)

SELECT *
FROM ProductSales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM ProductSales
)
ORDER BY Total_Sales DESC

-- Her kategori içindeki en kârlı ilk 3 ürünü analiz ediyorum.
SELECT *
FROM
(
    SELECT
        Category,
        Product_Name,
        SUM(Profit) AS Total_Profit,

        RANK() OVER
        (
            PARTITION BY Category
            ORDER BY SUM(Profit) DESC
        ) AS Profit_Rank

    FROM SampleSuperstore
    GROUP BY Category, Product_Name

) x

WHERE Profit_Rank <= 3



-- Ortalama satış değerinin üzerinde kalan ürünleri analiz ediyorum.
WITH ProductSales AS
(
    SELECT
        Product_Name,
        SUM(Sales) AS Total_Sales
    FROM SampleSuperstore
    GROUP BY Product_Name
)

SELECT *
FROM ProductSales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM ProductSales
)
ORDER BY Total_Sales DESC






/*
Proje Sonuçları:

- Teknoloji kategorisi satış ve kârlılık açısından öne çıkmıştır.
- Bazı ürünlerde yüksek satış olmasına rağmen düşük kâr elde edilmiştir.
- Belirli şehirler toplam satış performansında diğer şehirlerin önüne geçmiştir.
- Zarar eden ürünler tespit edilerek iyileştirme alanları belirlenmiştir.
- Müşteri segmentasyonu sayesinde yüksek değerli müşteriler analiz edilmiştir.
*/
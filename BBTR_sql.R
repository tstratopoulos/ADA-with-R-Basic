# Set working directory to source file location
library(data.table)
tStores <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tStores.csv")
str(tStores)

library(sqldf)
dt1_a <- sqldf("SELECT Store, City, Location, SqFt FROM tStores")
str(dt1_a)

dt1_b <- sqldf("SELECT tStores.* FROM tStores")
str(dt1_b)

dt1_c <- sqldf("SELECT Store, SqFt FROM tStores")
str(dt1_c)

dt1_d <- sqldf("SELECT Store, SqFt FROM tStores WHERE SqFt>19500")
str(dt1_d)

dt1_e <- sqldf("SELECT DISTINCT(City) FROM tStores")
str(dt1_e)

# Aggregate data
dt1_f <- sqldf("SELECT DISTINCT(City), count(Store) AS storeCount
               FROM tStores GROUP BY City")
str(dt1_f)
sqldf("SELECT DISTINCT dt1_f.storeCount FROM dt1_f")

dt1_g <- sqldf("SELECT DISTINCT(City), count(Store) AS storeCount
               FROM tStores GROUP BY City HAVING count(Store)>1")
dt1_g

# direct them to https://www.w3schools.com/sql/sql_in.asp for the next one
dt1_h <- sqldf("SELECT City, storeCount
               FROM dt1_g 
               WHERE City IN ('HORNSEY', 'MOUNTMEND')")
dt1_h

tSales <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tSales.csv")
names(tSales)
names(tSales)[1] <- "salesID"
str(tSales)

dt2_a <- sqldf("
  SELECT Store, sum(SalesQuantity) AS salesQ_Store, 
    avg(SalesPrice) AS avgPrice_Store,
    sum(SalesPrice*SalesQuantity) AS revenue_Store
    FROM tSales GROUP BY Store")
str(dt2_a)

str(tSales$SalesDate)
tSales$SalesDate <- as.Date(tSales$SalesDate, "%Y-%m-%d")
tSales$month <- as.numeric(format(as.Date(tSales$SalesDate), "%m"))
str(tSales$month)

dt2_b <- sqldf("
SELECT month, 
  sum(SalesQuantity) AS salesQ_Month, 
  sum(SalesQuantity)/count(DISTINCT(Store)) AS salesQ_Month_avgStore, 
  avg(SalesPrice) AS avgPrice_Month,
  sum(SalesPrice*SalesQuantity) AS revenue_Month,
  sum(SalesPrice*SalesQuantity)/count(DISTINCT(Store)) AS revenue_Month_avgStore
FROM tSales GROUP BY month")
str(dt2_b)

dt2_c <- sqldf("
SELECT Store, month, 
  sum(SalesQuantity) AS store_salesQ_Month, 
  avg(SalesPrice) AS store_avgPrice_Month,
  sum(SalesPrice*SalesQuantity) AS store_revenue_Month
FROM tSales GROUP BY Store, month")
str(dt2_c)
sqldf("SELECT dt2_c.* FROM dt2_c WHERE Store=10")

# merge two files
nrow(dt2_a)
nrow(tStores)
dt3_a <- sqldf("SELECT dt2_a.*, City, SqFt 
  FROM dt2_a INNER JOIN tStores ON dt2_a.Store=tStores.Store")
str(dt3_a)

# left join
nrow(tStores)
names(tStores)
nrow(dt1_g)
names(dt1_g)

dt3_b1 <- sqldf("SELECT tStores.*, storeCount 
  FROM tStores INNER JOIN dt1_g ON tStores.City=dt1_g.City")
str(dt3_b1)

dt3_b2 <- sqldf("SELECT tStores.*, storeCount 
  FROM tStores LEFT JOIN dt1_g ON tStores.City=dt1_g.City")
str(dt3_b2)

dt3_b3 <- sqldf("SELECT dt3_b2.*, 
  CASE
    WHEN storeCount> 2 THEN 'large'
    WHEN storeCount =2 THEN 'average'
    ELSE 'small'
  END AS marketSize
    FROM dt3_b2")
str(dt3_b3)
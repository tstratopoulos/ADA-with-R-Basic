############################################################
# Statistical outliers - in store size and in sales volume and quantity
library(data.table)
tStores <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tStores.csv")
names(tStores)
summary(tStores$SqFt)

IQR(tStores$SqFt)
lw <- quantile(tStores$SqFt,.25)-1.5*IQR(tStores$SqFt)
lw
uw <- quantile(tStores$SqFt,.75)+1.5*IQR(tStores$SqFt)
uw

library(ggplot2)
g4_storeSizeBPlot <- ggplot(tStores, aes(x=Store, y=SqFt)) + geom_boxplot()
g4_storeSizeBPlot

g4_storeSizeBPlot <- g4_storeSizeBPlot + geom_boxplot(outlier.color = "red")
g4_storeSizeBPlot

tStores$sqftOutlier <- ifelse(tStores$SqFt<lw|tStores$SqFt>uw,1,0)
tStores[tStores$sqftOutlier==1,]

tStores[tStores$SqFt<lw|tStores$SqFt>uw,]

# practice problems
# Are there outliers in prices of products sold?
# Are there outliers in quantity sold?

############################################################
# Aggregate data by store
tSales <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tSales.csv")
names(tSales)
names(tSales)[1] <- "salesID"
str(tSales)

library(sqldf)
dt1_a <- sqldf("
  SELECT Store, sum(SalesQuantity) AS salesQ_Store, 
    avg(SalesPrice) AS avgPrice_Store,
    sum(SalesPrice*SalesQuantity) AS revenue_Store
  FROM tSales GROUP BY Store")
names(dt1_a)
summary(dt1_a[,2:4])

# merge two files
dt1_b <- sqldf("SELECT dt1_a.*, SqFt, 
  CASE
    WHEN SqFt> 19500 THEN 'sqftOutlier'
    WHEN SqFt> 10200 THEN 'Q4'
    WHEN SqFt> 6400  THEN 'Q3'
    WHEN SqFt> 4000  THEN 'Q2'
    ELSE 'Q1'
  END AS storeSize
    FROM dt1_a INNER JOIN tStores ON dt1_a.Store=tStores.Store")
names(dt1_b)
dt1_b$Store <- as.factor(dt1_b$Store)

ggplot(dt1_b,aes(storeSize, salesQ_Store))+geom_boxplot(outlier.color = "red")

#practice problem - boxplot for price and revenue_Store
  #ggplot(dt1_b,aes(storeSize, avgPrice_Store))+geom_boxplot(outlier.color = "blue")
  #ggplot(dt1_b,aes(storeSize, revenue_Store))+geom_boxplot(outlier.color = "green")
# end practice

head(dt1_b[order(-dt1_b$salesQ_Store),],10)

# practice problem - identify the outliers produced by stores in Q2

############################################################
# Patterns - over time
str(tSales$SalesDate)
tSales$SalesDate <- as.Date(tSales$SalesDate, "%Y-%m-%d")
tSales$month <- as.numeric(format(as.Date(tSales$SalesDate), "%m"))
str(tSales$month)

dt2_a <- sqldf("
SELECT month, 
  sum(SalesQuantity) AS salesQ_Month, 
  sum(SalesQuantity)/count(DISTINCT(Store)) AS salesQ_Month_avgStore, 
  avg(SalesPrice) AS avgPrice_Month,
  sum(SalesPrice*SalesQuantity) AS revenue_Month,
  sum(SalesPrice*SalesQuantity)/count(DISTINCT(Store)) AS revenue_Month_avgStore
FROM tSales GROUP BY month")
names(dt2_a)
head(dt2_a)
summary(dt2_a[,2:6])

g4_salesQ_Month <- ggplot(dt2_a, aes(x=month)) +  
  geom_point(aes(y=salesQ_Month))+
  geom_line(aes(y=salesQ_Month))+
  scale_x_continuous(breaks=seq(1, 12, 1))
g4_salesQ_Month

g4_salesQ_Month_avgStore <- ggplot(dt2_a, aes(x=month)) +  
  geom_point(aes(y=salesQ_Month_avgStore))+
  geom_line(aes(y=salesQ_Month_avgStore))+
  scale_x_continuous(breaks=seq(1, 12, 1))
g4_salesQ_Month_avgStore

#practice problem - repeat for revenue
  # g4_revenue_Month <- ggplot(dt2_a, aes(x=month)) +  
  #   geom_point(aes(y=revenue_Month))+
  #   geom_line(aes(y=revenue_Month))+
  #   scale_x_continuous(breaks=seq(1, 12, 1))
  # g4_revenue_Month
  # 
  # g4_revenue_Month_avgStore <- ggplot(dt2_a, aes(x=month)) +  
  #   geom_point(aes(y=revenue_Month_avgStore))+
  #   geom_line(aes(y=revenue_Month_avgStore))+
  #   scale_x_continuous(breaks=seq(1, 12, 1))
  # g4_revenue_Month_avgStore
# end practice

dt2_b <- sqldf("
SELECT Store, month, 
  sum(SalesQuantity) AS store_salesQ_Month, 
  avg(SalesPrice) AS store_avgPrice_Month,
  sum(SalesPrice*SalesQuantity) AS store_revenue_Month
FROM tSales GROUP BY Store, month")
names(dt2_b)
head(dt2_b)
summary(dt2_b[,3:5])


dt2_c <- dt2_b[dt2_b$Store %in% c(76,69,50),]
head(dt2_c,12)
dt2_c$Store <- as.factor(dt2_c$Store)

g4_store_salesQ_Month <- ggplot(dt2_c, aes(x=month)) +  
    geom_point(aes(y=store_salesQ_Month, color=Store))+
    geom_line(aes(y=store_salesQ_Month, color=Store))+
    scale_x_continuous(breaks=seq(1, 12, 1))
g4_store_salesQ_Month

g4_store_salesQ_Month <- g4_store_salesQ_Month +
  geom_point(data=dt2_a, aes(y=salesQ_Month_avgStore, color="avgStore"))+
  geom_line(data=dt2_a, aes(y=salesQ_Month_avgStore, color="avgStore"))
g4_store_salesQ_Month

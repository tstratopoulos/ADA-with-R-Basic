# set working directory to source file location
library(data.table)
tStores <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tStores.csv")
names(tStores)
str(tStores)
head(tStores)
head(tStores,3)

tStores[1:3,]
tStores[1:3, 2:4]
tStores[, 2:4]

head(tStores[,2:4],3)
tail(tStores[,2:4],3)

head(tStores[order(tStores$SqFt),2:4],3)
head(tStores[order(-tStores$SqFt),2:4],3)

min(tStores$SqFt)
max(tStores$SqFt)
median(tStores$SqFt)
quantile(tStores$SqFt, .5)
quantile(tStores$SqFt, .25)
quantile(tStores$SqFt, .75)
mean(tStores$SqFt)

summary(tStores$SqFt)

library(ggplot2)
storeSizeHistogram <- qplot(tStores$SqFt, geom="histogram")
storeSizeHistogram

storeSizeHistogram <- storeSizeHistogram + xlab("Store Size (Sq.Ft)")
storeSizeHistogram

storeSizeHistogram <- storeSizeHistogram + ylab("Count (Frequency)")
storeSizeHistogram


tSales <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tSales.csv")
names(tSales)
names(tSales)[1] <- "salesID"
str(tSales)
head(tSales)

tProducts <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tProducts.csv")
names(tProducts)
str(tProducts)
head(tProducts)

tVendors <- fread("E:/Dropbox/Teaching/Classes/Data4Teaching/HUB/BBTR/BBTR_Data_20160630/BBTR_20160630_rdb/tVendors.csv")
names(tVendors)
str(tVendors)
head(tVendors)

library(sqldf)

tSalesByProduct <- sqldf("
  SELECT Brand, sum(SalesQuantity) AS sumQSales, avg(SalesPrice) AS avgPrice,
    max(SalesPrice) AS maxPrice, min(SalesPrice) AS minPrice, 
    (max(SalesPrice)-min(SalesPrice)) AS rangePrice
  FROM tSales GROUP BY Brand")
names(tSalesByProduct)
head(tSalesByProduct,5)
summary(tSalesByProduct$avgPrice)
summary(tSalesByProduct[,2:6])
tSalesByProduct[tSalesByProduct$rangePrice>100,]

library(ggplot2)
storeSizeHistogram <- qplot(tStores$SqFt, geom="histogram")
storeSizeHistogram

storeSizeHistogram <- storeSizeHistogram + xlab("Store Size (Sq.Ft)")
storeSizeHistogram

storeSizeHistogram <- storeSizeHistogram + ylab("Count (Frequency)")
storeSizeHistogram

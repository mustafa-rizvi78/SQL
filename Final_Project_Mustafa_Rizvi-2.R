
# Mustafa Rizvi
# Final Project - ITM 324
# R Program to analyze San Francisco City Reported Crime Cases


install.packages("sqldf")  # This libraray is used to query out the data in SQL language. 
                           # I specifically used this library since I have initimate familiarity with SQL langauge.
install.packages("Hmisc")  # This library is used to generate descriptive statistics.
install.packages("gridExtra")  # This library is used to prettify exported PDF output
    


library(gridExtra)  # for PDF formatting

library(sqldf)
crime_data <- read.csv(file="SFPD_Incidents_Previous_Three_Months.csv",header=TRUE,sep=",")

crime_data_table_1 <- sqldf("SELECT 
	                   Category,
	                   total_cases,
	                   ROUND((total_arrested/total_cases)*100,2)                     AS arrested_percentage,
	                   -- ROUND((total_not_prosecuted_percentage/total_cases)*100,2) AS not_prosecuted_percentage,
	                   -- ROUND((total_none_percentage/total_cases)*100,2)           AS none_percentage,
	                   -- ROUND((total_other_punishments/total_cases)*100,2)         AS other_punishments_percentage,
	                   ROUND((total_non_arrested_outcome/total_cases)*100,2)         AS non_arrested_outcome_percentage
	            FROM 
	            (       
	            SELECT Category, 
	                   CAST(COUNT(*) AS REAL)              AS Total_Cases,
	                   CAST(COUNT(
	                   	   CASE 
	                        WHEN Resolution IN ('ARREST, BOOKED','ARREST, CITED') THEN IncidntNum 
	                                                                              ELSE NULL
	                       END
	                       ) AS REAL)                  AS total_arrested,
                        CAST(COUNT(
                        	CASE 
                        	     WHEN Resolution IN ('NOT PROSECUTED') THEN IncidntNum 
                        	                                           ELSE NULL
                        	END                                           
                        	) AS REAL)                  AS total_not_prosecuted_percentage,
                         CAST(COUNT(
                         	 CASE 
                         	     WHEN Resolution IN ('NONE')  THEN IncidntNum
                         	                                  ELSE NULL
                             END
                         	)  AS REAL)                 AS total_none_percentage,
                          CAST(COUNT(
                         	 CASE 
                         	     WHEN Resolution NOT IN ('NONE','NOT PROSECUTED','ARREST, BOOKED','ARREST, CITED')  THEN IncidntNum
                         	                                                                                        ELSE NULL
                             END
                         	)  AS REAL)                 AS total_other_punishments,
                          CAST(COUNT(
                                  CASE 
                         	     WHEN Resolution NOT IN ('ARREST, BOOKED','ARREST, CITED')  THEN IncidntNum
                         	                                                                ELSE NULL
                             END
                         	)  AS REAL)                 AS total_non_arrested_outcome
	            FROM crime_data 
	            GROUP BY Category 
	            ORDER BY 2 DESC
	            ) AS a"
	            )

pdf("total_cases_by_category.pdf")
grid.table(crime_data_table_1)
dev.off()

report_cases_by_district <- sqldf("
	                               SELECT PdDistrict, 
	                                      CAST(COUNT(*) AS REAL)                                                                   AS Total_Cases,
	                                      ROUND((CAST(COUNT(*) AS REAL) / CAST((SELECT COUNT(*) FROM crime_data) AS REAL)*100),2)  AS cases_percentages
                                   FROM crime_data
                                   GROUP BY PdDistrict
                                   ORDER BY 2 DESC
                                   "
	                              )

pdf("total_cases_by_district.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="total_cases_by_district.png", width=1000, height=1000)
grid.table(report_cases_by_district)
dev.off()

report_cases_by_arrest_non_arrest <- sqldf("
	                                         SELECT   Category,
	                                                  CASE 
	                                                     WHEN Resolution IN ('ARREST, BOOKED','ARREST, CITED') THEN 'Arrested'
	                                                                                                           ELSE 'Non-Arrested'
	                                                   END                   AS case_outcome, 
	                                                CAST(COUNT(*) AS REAL)   AS Total_Cases,
	                                      ROUND((CAST(COUNT(*) AS REAL) / CAST((SELECT COUNT(*) FROM crime_data) AS REAL)*100),2)  AS cases_percentages
                                   FROM crime_data
                                   GROUP BY 1,2
                                   ORDER BY 1 DESC
                                  "
	                              )

pdf("total_cases_by_arrest_non_arrest_outcome.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="total_cases_by_arrest_non_arrest_outcome.png", width=1000, height=1000)
grid.table(report_cases_by_arrest_non_arrest)
dev.off()

crime_data <- within(crime_data, { 
                                   arrest_non_arrest <- ""
                                   arrest_non_arrest[Resolution=="ARREST, BOOKED" | Resolution=="ARREST, CITED"] <- "Arrested"
                                   arrest_non_arrest[Resolution!="ARREST, BOOKED" & Resolution!="ARREST, CITED"] <- "Non-Arrested"
 
                                }
                   )             

# Boxplot

total_cases_by_category <- data.frame()
total_cases_by_category <- crime_data_table_1[1:35,]



pdf("boxplot_of_total_cases_by_outcome.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="boxplot_of_total_cases_by_outcome.png", width=1000, height=1000)
boxplot(Total_Cases ~ case_outcome, data=report_cases_by_arrest_non_arrest,
  notch=TRUE,
  varwidth=TRUE,
  col="red",
  main="Total Cases By Case Outcome (Arrest vs Non-Arrest)",
  xlab=" Arrest vs Non-Arrest",
  ylab="Total Cases")
dev.off()

# Pie and Bar Charts

total_cases_by_category <- crime_data_table_1[1:10,]


pdf("pie_chart_of_total_cases_by_category.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="pie_chart_of_total_cases_by_category.png", width=1000, height=1000)
lbls <- paste(total_cases_by_category$Category, total_cases_by_category$total_cases)
pie(total_cases_by_category$total_cases, labels =lbls, edges = 200, radius = 0.8, main="Pie Chart of Top 10 Crime Incidents by Category (San Francisco City Area)")
dev.off()

pdf("pie_chart_of_arrest_percentage_by_category.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="pie_chart_of_arrest_percentage_by_category.png", width=1000, height=1000)
lbls <- paste(total_cases_by_category$Category, total_cases_by_category$arrested_percentage)
lbls <- paste(lbls,"%",sep="")
pie(total_cases_by_category$arrested_percentage, labels =lbls, main="Pie Chart of Top 10 Arrest % by Category (San Francisco City Area)")


pdf("pie_chart_of_total_cases_by_district.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="pie_chart_of_total_cases_by_district.png", width=1000, height=1000)
lbls <- paste(report_cases_by_district$PdDistrict, report_cases_by_district$cases_percentages)
lbls <- paste(lbls,"%",sep="")
pie(report_cases_by_district$Total_Cases, labels =lbls, main="Pie Chart of Crime Incidents % by District (San Francisco City Area)")
dev.off()

pdf("barplot_of_total_cases_by_district.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="barplot_of_total_cases_by_district.png", width=1000, height=1000)
counts <- table(crime_data$PdDistrict)
barplot(counts, 
	    main="Crime Incidents by District (San Francisco City Area)",
        xlab="Number of Crime Incidents", col=c("red","sienna","palevioletred1","royalblue2","red","sienna","palevioletred1","royalblue2","red","sienna"),
        legend = rownames(counts)
       ) 
dev.off()

pdf("barplot_of_total_cases_by_arrest_non_arrest.pdf")
# Exported the charts in png format just to import that into the MS Word document
# png(filename="barplot_of_total_cases_by_arrest_non_arrest.png", width=1000, height=1000)
counts <- table(crime_data$arrest_non_arrest)
barplot(counts, 
	    main="Crime Incidents by Outcome (Arrest vs Non-Arrest)",
        xlab="Number of Crime Incidents by Outcome (Arrest vs Non-Arrest)", col=c("red","sienna"),
        legend = rownames(counts)
       ) 
dev.off()


# descriptive statistics

summary(crime_data)
library(psych)
describe(crime_data)

library(Hmisc)
describe(crime_data)



# t-test code

library(MASS)
t.test(Total_Cases ~  case_outcome, data=report_cases_by_arrest_non_arrest)
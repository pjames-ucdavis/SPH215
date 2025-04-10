1   +  1
"hello world"

3 > 2
2>3
"jacob" == "jacob"
2*3
2/3
log(1)
log(0)
c(4, 16, 9)
c("jacob", "anne", "gwen")
b <- "hello world"
b
v1 <- c(4, 16, 9)
v1
e123 <- c(4, 16, 9)
!!! <- c(4, 16, 9)
james <- "james"
james

typeof(b)
typeof(v1)
test <- c(FALSE, TRUE)
typeof(test)

length(b)
b
v1
length(v1)
is.numeric(b)
is.numeric(v1)
x1 <- c("1", "2")
typeof(x1)
x2 <- as.numeric(v1)
typeof(x2)
rm(x2)

v2 <- c(5,12,25)
data.frame(v1,v2)
df1 <- data.frame(v1, v2)
View(df1)
v3 <- c("jacob", "anne", "gwen")
df2 <- data.frame(v1, v3)
df2
class(df2)
dim(df1)
dim(df2)
colnames(df1)
colnames(df2)
df1$v1
df1$v1

df1[1,2]
df1[2,]
? seq
seq(from = 2, to = 10, by =2)
seq(1, 10)
install.packages("tidyverse")
library(tidyverse)
install.packages("nycflights13")
library(nycflights13)
nyctibble <- flights
class(nyctibble)
nycdf <- as.data.frame(flights)
class(nycdf)
nyctibble
nycdf
View(nyctibble)
names(nyctibble)
as_tibble(nycdf)

ca1 <- read_csv("https://raw.githubusercontent.com/pjames-ucdavis/SPH215/refs/heads/main/lab1dataset1.csv")
ca2 <- read_csv("https://raw.githubusercontent.com/pjames-ucdavis/SPH215/refs/heads/main/lab1dataset2.csv")
glimpse(ca1)
glimpse(ca2)

names(ca1)
rename(ca1, medinc = "Estimated median income of a household, between 2014-2018.")

ca1 <- rename(ca1, 
              medinc = "Estimated median income of a household, between 2014-2018.",
              GEOID = "Formatted FIPS")
ca1
ca2 <- select(ca2, GEOID, tpoprE, nhwhiteE, nhblkE, nhasnE, hispE)
ca2
ca1 <- select(ca1, -"FIPS Code")
ca1
ca2 <- mutate(ca2, pwhite = nhwhiteE/tpoprE, pasian = nhasnE/tpoprE, 
       pblack = nhblkE/tpoprE, phisp = hispE/tpoprE)
glimpse(ca2)
ca2 <- mutate(ca2, pwhite = nhwhiteE/tpoprE, pasian = nhasnE/tpoprE, 
              pblack = nhblkE/tpoprE, phisp = hispE/tpoprE,
              mhisp = case_when(phisp > 0.5 ~ "Majority",
                                TRUE ~ "Not Majority"))
glimpse(ca2)
class(ca1$GEOID)
class(ca2$GEOID)
cacounty <- left_join(ca1, ca2, by = "GEOID")
glimpse(cacounty)

filter(cacounty, GEOID == "06067")

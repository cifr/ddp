library(plyr)
library(stats)

if (!exists("ddp")) {
    furl <- 'https://data.gov.sg/dataset/resale-flat-prices/download'
    fzip <- 'resale-flat-prices.zip'

    download.file(furl, destfile=fzip, mode='wb', quiet=TRUE)
    
    fn <- unzip(fzip, list=TRUE)$Name
    fdat <- fn[grep("onwards", fn)[1]]
    unzip(fzip, files=c(fdat))
    
    ddp <- read.csv(fdat, as.is=TRUE)
    ddp$month <- as.Date(paste0(ddp$month, "-01"), "%Y-%m-%d")
    ddp$town <- factor(ddp$town)
    ddp$flat_type <- factor(ddp$flat_type)
    ddp$flat_model <- factor(ddp$flat_model)
    ddp$storey_range <- factor(ddp$storey_range)

    ddp <- mutate(ddp, age_year=as.numeric(format(Sys.Date(), "%Y"))-lease_commence_date)
    ddp <- ddp[, c("month", "town", "flat_type", "floor_area_sqm", "flat_model", 
                "age_year", "storey_range", "resale_price")]

    ddp.lm0 <- lm(resale_price ~ flat_type + town + floor_area_sqm + age_year + storey_range, data=ddp)
    
    ddp.towns <- levels(ddp$town)
    ddp.flat_types <- levels(ddp$flat_type)
    ddp.storey_range <- levels(ddp$storey_range)
}

getFloorLimits <- function(flat_type) {
    xdf <- ddp[ddp$flat_type==flat_type,]
    c(min(xdf$floor_area_sqm), max(xdf$floor_area_sqm))
}

ddp.default <- ddp[sample(nrow(ddp), 1),]
ddp.default_floor_limits <- getFloorLimits(ddp.default$flat_type)
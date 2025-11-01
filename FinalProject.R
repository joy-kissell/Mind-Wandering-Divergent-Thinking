#reading in dataset
setwd

ECDTdata = read.csv("ExecutiveControlDivergentThinking.csv")
CreativeBrickTask = read.csv("BrickTask.csv")
CreativeKnifeTask = read.csv("KnifeTask.csv")

#renaming the participant ID columns the same thing before merging

colnames(CreativeBrickTask)[1]= "ID"
colnames(CreativeKnifeTask)[1] = "ID"
colnames(ECDTdata)[1] = "ID"

#switching the creative tasks to wide format before merging
library(reshape2)
for (id in unique(CreativeBrickTask$ID)) {
  #moving responses into one column
  responses = paste(CreativeBrickTask$Problem1RESP[CreativeBrickTask$ID == id], collapse = ", ")
  CreativeBrickTask$Response[CreativeBrickTask$ID == id] = responses
}
CreativeBrickTaskWide = dcast(CreativeBrickTask,ID ~ "AllResponses", value.var="Response", 
                              fun.aggregate = toString, drop = FALSE) 

for (id in unique(CreativeKnifeTask$ID)) {
  #moving responses into one column
  responses = paste(CreativeKnifeTask$Problem1.RESP[CreativeKnifeTask$ID == id], collapse = ", ")
  CreativeKnifeTask$Response[CreativeKnifeTask$ID == id] = responses
}
CreativeKnifeTaskWide = dcast(CreativeKnifeTask,ID ~ "AllResponses", value.var="Response", 
                              fun.aggregate = toString, drop = FALSE) 

#merging the datasets
CreativeTasks <- merge(CreativeBrickTaskWide, CreativeKnifeTaskWide, by = "ID", suffixes = c("Brick", "Knife"))
allECDTdata = merge(ECDTdata, CreativeTasks, by = "ID")

#saving this to a csv
write.csv(allECDTdata, "allECDTdata.csv")

library(psych)

#cleaning Data
allECDTdata$AllResponsesBrick = tolower(allECDTdata$AllResponsesBrick)
allECDTdata$AllResponsesKnife = tolower(allECDTdata$AllResponsesKnife)

#removing all unnecessary spaces in the response columns
allECDTdata$AllResponsesBrick = gsub("\\s*,", ",", allECDTdata$AllResponsesBrick)
allECDTdata$AllResponsesKnife = gsub("\\s*,", ",", allECDTdata$AllResponsesKnife)


#combining frequency of creative & highly creative thoughts from all raters
allECDTdata$CreativeResponseFreqBrick = apply(allECDTdata[, c("Brick_MJK45", 
                                                              "Brick_MSW45", "Brick_RAB45", 
                                                              "Brick_RMR45", "Brick_JM45")], 1, mean)
summary(allECDTdata$CreativeResponseFreqBrick)

allECDTdata$CreativeResponseFreqKnife = apply(allECDTdata[, c("Knife_MJK45", 
                                                              "Knife_MSW45", "Knife_RAB45", 
                                                              "Knife_RMR45", "Knife_MM45",
                                                              "Knife_JM45")], 1, mean)
summary(allECDTdata$CreativeResponseFreqKnife)
#removing individual rater scores from dataset
allECDTdata = subset(allECDTdata, select = -c(Brick_MJK45, Brick_MSW45, Brick_RAB45, 
                                              Brick_RMR45, Brick_JM45,Knife_MJK45,
                                              Knife_MSW45, Knife_RAB45,Knife_RMR45,
                                              Knife_MM45,Knife_JM45))

#finding common responses in brick/knife task to later analyze if it's correlated to rating
drawPattern = grepl("draw|drawing",allECDTdata$AllResponsesBrick)
sum(drawPattern)
breakPattern = grepl("break", allECDTdata$AllResponsesBrick)
sum(breakPattern)

#captures carve, carving, carver
carvePattern = grepl("\\bcarv[a-z]{1,3}\\b",allECDTdata$AllResponsesKnife)
sum(carvePattern)
cutPattern = grepl("cut", allECDTdata$AllResponsesKnife)
sum(cutPattern)

#marking if participant gave a common response
allECDTdata$CommonBrick = ifelse(drawPattern|breakPattern, "common", "uncommon")
allECDTdata$CommonKnife = ifelse(carvePattern|cutPattern, "common", "uncommon")
library(ggplot2)
pdf("commonCounts.pdf")

CreativeBrickPlot = ggplot(allECDTdata, aes(x = CommonBrick, fill = CommonBrick))+
  geom_bar(position = "dodge")+
  scale_fill_manual(values= c("common" = "blue", "uncommon" = "lightblue"))+
  labs(title = "Count of Creative Brick Answers", x = "Creative Brick Response Type", y = "Count")
CreativeKnifePlot = ggplot(allECDTdata, aes(x = CommonKnife, fill = CommonKnife))+
  geom_bar(position = "dodge")+
  scale_fill_manual(values= c("common" = "purple", "uncommon" = "lavender"))+
  labs(title = "Count of Creative Knife Answers", x = "Creative Knife Response Type", y = "Count")
print(CreativeBrickPlot)
print(CreativeKnifePlot)
dev.off()

#getting rid of empty columns
allECDTdata = subset(allECDTdata, select = -c(nfl_mw, antia.er, Flag))

#only want to keep the mind-wandering measures
allECDTdata = subset(allECDTdata, select = -c(sart_d, sart_rtsd, plf_ler.b.resid, nst_incon.rt, antil.er, sspan, ospan, rspan, rotsp, runsp, upd))
colnames(allECDTdata)[2:5] = c("MindWanderingRate_SART", "MindWanderingRate_NST", "MindWanderingRate_AF", "MindWanderingRate_NB")
#sustained attention response task, number stroop flanker, arrow flanker, n-back

#to check the structure of the data 
str(allECDTdata)
write.csv(allECDTdata, "allECDTdata.csv")

#Analyzing Data_____________________________________________________________________________________________________________________________________________
#looking at whether having a common response is a predictor of interviewer-rated frequency of creative responses
CommonResponseCreativeRatingBrick = lm(CreativeResponseFreqBrick~CommonBrick, data = allECDTdata)
CommonResponseCreativeRatingKnife = lm(CreativeResponseFreqKnife~CommonKnife, data = allECDTdata)

#look at whether mind wandering during each task predicts frequency of creative responses
MindWanderingCreativeThinking = lm(CreativeResponseFreqBrick+CreativeResponseFreqKnife~MindWanderingRate_SART+
                                     MindWanderingRate_NST+ MindWanderingRate_AF+ MindWanderingRate_NB, data = allECDTdata)
sink("lmResults.txt")
summary(CommonResponseCreativeRatingBrick)
summary(CommonResponseCreativeRatingKnife)
summary(MindWanderingCreativeThinking)
sink()
#checking statistical assumptions
pdf("plotlm.pdf")
lmCommonBrick = plot(CommonResponseCreativeRatingBrick)
lmCommonKnife = plot(CommonResponseCreativeRatingKnife)
lmMWCT = plot(MindWanderingCreativeThinking)
dev.off()

#checking for normality
shapiro.test(allECDTdata$CreativeResponseFreqBrick)
shapiro.test(allECDTdata$CreativeResponseFreqKnife)

#checking for homogeneity of variance
library(car)
leveneTest(CreativeResponseFreqBrick~CommonBrick, data = allECDTdata)
leveneTest(CreativeResponseFreqKnife~CommonKnife, data = allECDTdata)

#scatterplot to look at distribution and see if there are outliers
BrickScatterPlot= ggplot(allECDTdata, aes(x=CommonBrick, y=CreativeResponseFreqBrick, color = CommonBrick))+
  geom_point()+ labs(title = "Presence of Common Responses and Creative Response Frequency", x= "Common Brick Response", 
                   y = "Creative Response Frequency", color = "Common Brick Response")+
  scale_y_continuous(breaks = seq(min(allECDTdata$CreativeResponseFreqBrick), max(allECDTdata$CreativeResponseFreqBrick), by = .25),
                     labels = scales::number_format(accuracy = .01))
KnifeScatterPlot= ggplot(allECDTdata, aes(x=CommonKnife, y=CreativeResponseFreqKnife, color = CommonKnife))+
  geom_point()+ labs(title = "Presence of Common Responses and Creative Response Frequency", x= "Common Knife Response", 
                     y = "Creative Response Frequency", color = "Common Knife Response")+
  scale_y_continuous(breaks = seq(min(allECDTdata$CreativeResponseFreqKnife), max(allECDTdata$CreativeResponseFreqKnife), by = .25),
                     labels = scales::number_format(accuracy = .01))
pdf("ECDTScatterPlot.pdf")
print(BrickScatterPlot)
print(KnifeScatterPlot)
dev.off()

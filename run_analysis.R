setwd("D:\\Rwork\\data\\UCI HAR Dataset")


## read train and test data
readData <- function(type){
  
  subject<- read.csv(paste(".\\",type,"\\subject_",type,".txt", sep=""))
  
  X<- read.csv(paste(".\\",type,"\\X_",type,".txt", sep=""))

  y<- read.csv(paste(".\\",type,"\\y_",type,".txt", sep=""))  
  
  bax<- read.csv(paste(".\\",type,"\\Inertial Signals\\body_acc_x_",type,".txt", sep=""))
  
  bay<- read.csv(paste(".\\",type,"\\Inertial Signals\\body_acc_y_",type,".txt", sep=""))
  
  baz<- read.csv(paste(".\\",type,"\\Inertial Signals\\body_acc_z_",type,".txt", sep="")) 
  
  bgx<- read.csv(paste(".\\",type,"\\Inertial Signals\\body_gyro_x_",type,".txt", sep="")) 
  
  bgy<- read.csv(paste(".\\",type,"\\Inertial Signals\\body_gyro_y_",type,".txt", sep="")) 
  
  bgz<- read.csv(paste(".\\",type,"\\Inertial Signals\\body_gyro_z_",type,".txt", sep=""))
  
  tax<- read.csv(paste(".\\",type,"\\Inertial Signals\\total_acc_x_",type,".txt", sep="")) 
  
  tay<- read.csv(paste(".\\",type,"\\Inertial Signals\\total_acc_y_",type,".txt", sep="")) 
  
  taz<- read.csv(paste(".\\",type,"\\Inertial Signals\\total_acc_z_",type,".txt", sep="")) 
  
  md<- data.frame("type"=type,"subject"=subject[[1]],"features"=X[[1]],"act_id"=y[[1]],"body_acc_x"=bax[[1]],
                  "body_acc_y"=bay[[1]],"body_acc_z"=baz[[1]],"body_gyro_x"=bgx[[1]],"body_gyro_y"=bgy[[1]],
                  "body_gyro_z"=bgz[[1]],"total_acc_x"=tax[[1]],"total_acc_y"=tay[[1]],"total_acc_z"=taz[[1]])
  
  return (md)
  
}


train<- readData("train")
test<- readData("test")
md<- rbind(train,test)  ##merge two data sets into one

## label the activity
act<- read.csv("activity_labels.txt",header=FALSE)
library(dplyr)
act<- mutate(act, act_id=substr(V1,0,1), activity=substr(V1,2, nchar(as.character(V1))))
act<- mutate(act, V1=NULL)

md<- merge(md,act, by="act_id")
md<- mutate(md, act_id=NULL)



##analyse features
features<- read.csv("features.txt", header=F, sep="\n")
v<- unlist(strsplit(as.character(features$V1), " "))
mm<- matrix(v, ncol=2, byrow=TRUE)
fm<- as.data.frame(mm)
colnames(fm)<- c("f_id","f_name")

meanfm<- fm[grep("mean", fm$f_name),]
stdfm<- fm[grep("std", fm$f_name),]


##add rows of mean and st values
addrow<- function (themd){
  
  mean_matrix<- matrix( ncol=nrow(meanfm), byrow=TRUE)
  mean_matrix<- NULL
  
  std_matrix<- matrix( ncol=nrow(stdfm), byrow=TRUE)
  std_matrix<- NULL
  
  xmd<- themd$features
  
  for (i in 1:nrow(md)){
    f<- xmd[i]
    ls<- strsplit(as.character(f), split=" ")
    m1<- data.frame("fvalue"=ls[[1]])
    m1<- filter(m1,fvalue!="")
    
    mean_values<-m1[as.numeric(meanfm$f_id),1]  ## select the mean feature value
    mean_matrix<- rbind(mean_matrix, as.character(mean_values))
    
    std_values<-m1[as.numeric(stdfm$f_id),1] ## select the std feature value
    std_matrix<- rbind(std_matrix, as.character(std_values))
    
    
  }
  
  colnames(mean_matrix)<- as.character(meanfm$f_name) 
  themd<- cbind(themd,mean_matrix) ##add mean feature data set 
  
  colnames(std_matrix)<- as.character(stdfm$f_name)
  themd<- cbind(themd,std_matrix) ##add std feature data set 
  
  return (themd)
  
}

md<- addrow(md)

colnames(md)[14:92]<- gsub("-","_",colnames(md)[14:92])
colnames(md)[14:92]<- sub("\\(\\)","fun",colnames(md)[14:92])

write.table(md, file=".\\mergedata.txt", append=FALSE, col.names = TRUE, row.names = FALSE)

##add a second data set for the mean of values
gb<- group_by(md,subject,activity)
mymean<- function (d) { return (mean(as.numeric(format(d,scientific = FALSE))))}
s<- summarise_at(gb, c(14:92), mymean)
write.table(s, file=".\\meandata.txt", append=FALSE, col.names = TRUE, row.names = FALSE)





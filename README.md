# Cleaning-data-course-project

step 1: I created a function called readData to read "train" and "test" data.
Then I merged two datasets into one.

step2: I read activity labels data and split it into two columns.
Then I merge it with the data set which was made by step 1.
And I can get the activity name of each record.

step3: I read features data and alse split it into two columns.
Then I only pick out "mean" and "std" feature from it.

step4: I created a function called addrow to pick out "mean" and "std" value from all features.
Then I add new columns to put these new values and labeled them with new names.
And I wrote the new data set into a txt file.

step5: I grouped by the new data set with "subject" and "activity".
Then I summarise it to get the average value of each feature.
And I wrote the data set into a txt file.

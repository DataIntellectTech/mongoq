# Comments Database

The following example demonstrates the use of the mongoq library to act as a document store backing to kdb+
Internet forum comments are loaded in from a text file, and saved to a kdb+ database. The text fields are stored in MongoDB, with the MongoDB id field maintained in the kdb+ table.

There are two components to the example - a loader script and a client script with example queries
For the dataset we sourced about 1Gb (uncompressed) of reddit posts, thanks to reddit user [twentythree-nineteen in this thread](http://www.reddit.com/r/datasets/comments/26ijdl/15_million_reddit_comments_from_november_sql_and/)
Dropbox link to zip file [here](https://www.dropbox.com/s/v1wthwif6m3tf3h/comments.sql.zip)

## Loader

This sort of data is relatively hard to parse because of the mess of delimiters contained within the comment fields. I picked the sql file to process as it is easier to identify genuine breaks between records rather than newlines embedded in the comments. 

## Client script

The client script loads and initiallises the mongoq library, then loads the comments database which was saved by the loader. Some sample queries are then printed to screen.

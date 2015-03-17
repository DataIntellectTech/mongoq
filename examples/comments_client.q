
\l mongo.q

.mg.initdb`kdb;

\l mydb

topics:{[term] 10 sublist select score, subreddit, title:60 sublist' link_title from `score xdesc 0!select max score, first subreddit by link_title from .mg.search[`comments;term]} 

threads:{[term]
  t:comments comments[`mgid] bin m:.mg.searchid[`comments;term];
  t:(`$.mg.find[`comments;m;`subreddit]),'t;
  r:`threads xdesc select threads:count distinct link_id, comments:count i by subreddit from t; 
  r}


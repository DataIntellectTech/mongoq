if[not 2<=count .z.x;-1"Usage q comments_load.q DB FILE";exit 1]

db:hsym`$.z.x 0;
file:hsym`$.z.x 1;

\l mongo.q

c:`subreddit_id`link_title`banned_by`subreddit`likes`replies`id`gilded`author`parent_id`approved_by`body`edited`author_flair_css_class`downs`body_html`link_id`score_hidden`name`created`created_datetime`author_flair_text`created_utc`ups`num_reports`distinguished`word_count`word_length`kincaid!"SSISIISISSI*BSI*SBSSPSSIIIIFF";


inquotes:{mod[sums (x="\"") and not["\\"=prev x] and not["\\"=prev prev x];2]}
niq:{not mod[sums (x="'") and not ("'"=prev x) or "'"=next x;2]}

pf:"SI*BPF"!({`$1_'-1_'trim x};"I"$;{1_'-1_'trim x};"B"$;"P"$;"F"$);

td:(`symbol$())!`timespan$();

parsedata:{[f;i;l]
  -1"Processing - ",(neg[count string fs]$string floor i%1024*1024)," of ",string[fs:`int$hcount[f]%1024*1024]," MB : ",string[.1*`int$1000*i%hcount f],"%";
  st:.z.p;
  x:`char$read1(f;i;l);
  td[`reading]+:(st:.z.p)-st;
  sor:ss[x;"\n('"];
  eor:ss[x;"),\n"];
  x:@[x;;:;" "] where (x in "\":\\{}[];") or x<32;
  d:min each sor group eor eor binr sor;
  lines:(2+value d)_ x;
  lines:",",'(0^-2+key[d]-value d)#'lines;
  delims:where each (","=lines)and niq each lines;
  linesok:where count[c]=count each delims;
  t:key[c]!flip 1_''delims[linesok] _' lines[linesok];
  t:flip pf[c]@'t;
  td[`parsing]+:(st:.z.p)-st;
  if[count t;processdata[t]];
  i+0^key[d] last linesok};

processdata:{[t]
  mgcols:`link_title`subreddit`body`body_html`author_flair_text;
  st:.z.p;
  oid:.mg.add[`comments;mgcols#t];
  td[`mongoinsert]+:(st:.z.p)-st;
  (` sv db,`comments`) upsert .Q.en[db] (mgcols _ t),'([]mgid:oid);
  td[`kdbwrite]+:(st:.z.p)-st;
 };

/ initialise mongo client 
.mg.initdb[`kdb];
/ clear any mongo data from previous loads
.mg.dropc[`comments];
/ similarly, blow away any kdb data from last load
system"rm -rf ",1 _ string db;
/ parse file in 10Mb chunks 
parsedata[file;;10000000]/[0];
st:.z.p;
/ generate text index on body field
.mg.addindex[`comments;.j.j enlist[`body]!enlist `text]
td[`mongoindex]+:.z.p-st;
td[`TOTAL]:sum td;

/ Print timing results
-1@'{h,x,h:enlist " #"l=l:x 0}"# ",/:(` vs .Q.s td),\:" #";
exit 0;

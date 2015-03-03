
\d .mg

lib:`$":/home/jgrant/mongo/bin/mongoq";
initc:lib 2: (`mongo_init;3);
insertc:lib 2: (`mongo_bulkinsert;2);
selectc:lib 2: (`mongo_find;3);
deletec:lib 2: (`mongo_delete;2);
dropc:lib 2: (`mongo_drop;1);
cleanupc:lib 2: (`mongo_cleanup;1);

ID:`$"_id";
OID:`$"$oid";

oidenc:{-9!0x01000000,reverse[0x0 vs `int$14+16*count x],0x0200,reverse[0x0 vs `int$count x],raze 0x00000000,/:raze each "X"$0N 2#/:x}
oiddec:{raze each string 4_'0N 16#14_-8!x}

oidin:{enlist[`$"_id"]!enlist enlist[`$"$in"]!enlist (enlist`$"$oid")!/:enlist each x}

proj:{.j.j ((),x)!count[x]#1b}

add:{[t;x]oidenc insertc[t;.j.j each $[99=p:type x;enlist x;p in 10 98h;x;'`type]]};
find:{[t;q;c]
  jq:.j.j oidin o:oiddec $[0<type q;q;enlist q];
  d:@[.j.k;;{(`symbol$())!()}] each selectc . (t;jq;proj c);
  if[not count d;:()];
  k:(@[{@[;OID] x ID};;24#"0"]each d)!ID _/: d;
  k $[0<type q;o;first o]}

search:{[t;s]
  jq:.j.j enlist[`$"$text"]!enlist enlist[`$"$search"]!enlist raze string s;
  d:@[.j.k;;{(`symbol$())!()}] each selectc . (t;jq;proj ID);
  if[not count d;:()];
  r:eval[(?;d;();();(),ID)]@\: OID;
  oidenc r}

init:{[host;port;db]initc[host;port;db]};
initdb:{[db]init[`localhost^`$getenv`MONGOHOST;27017i^"I"$getenv`MONGOPORT;db]}

\d .


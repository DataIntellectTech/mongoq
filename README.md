# mongoq

## About
A C shared lib along with associated q functions to allow push/pull access to mongoDB from within kdb+

## Installation

- Install the mongo c driver libraries | [repo](https://github.com/mongodb/mongo-c-driver) | [instructions](https://github.com/mongodb/mongo-c-driver/blob/master/TUTORIAL.md)
- Clone the mongoq git repo
- Compile shared object using platform specific instructions below

###### Linux (64 bit)
```
gcc -o bin/mongoq.so c/mongoq.c $(pkg-config --cflags --libs libmongoc-1.0) -I./ -shared -fPIC
```
###### Linux (32 bit)
```
insert linux 32 compilation line here
```
###### Windows
```
insert windows compilation line here
```
###### MacOS
```
insert macOS compilation line here
```

- copy the shared library file from the bin folder to the location of your q executable - e.g. $QHOME/l32
- copy mongo.q to $QHOME

## Usage

#### Load and initialise library

This assumes there is a MongoDB server running on the local machine on the standard port - amend the connection details as required for your MongoDB setup
```
\l mongo.q
.mg.init[`localhost;27017;`kdb]
```

#### Insert data to MongoDB

```
q).mg.add[`test] `a`b`c!(1;`xyz;12t) / single record
00000000-54ef-b9bd-dfa8-32369e099741
q)r:.mg.add[`test] ([]time:3 4t;sym:`IBM`MSFT;price:23.4 56.7) / table
```

#### Query data from MongoDB

The '.mg.add' function returns a 16 byte UID type, which maps to the MongoDB ObjectID key of the inserted record. We can use these ids to retrieve data:
```
q).mg.find[`test;;()] r / all fields for id(s) r in table 'test'
time           sym    price
---------------------------
"03:00:00.000" "IBM"  23.4
"04:00:00.000" "MSFT" 56.7
q).mg.find[`test;;`sym`price] r / only sym & price fields
sym    price
------------
"IBM"  23.4
"MSFT" 56.7
```

## Examples

- [Comments database](examples/COMMENTS.md)

## Notes 

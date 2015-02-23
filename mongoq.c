#define KXVER 3
#include <bcon.h>
#include <bson.h>
#include <mongoc.h>
#include <stdio.h>
#include <stdlib.h>
#include"k.h"

bool initialised = false;
mongoc_client_t *client;
char *database;

K mongo_init(K qhost, K qport, K qdatabase)
{
   char *host;
   int port;
   host = qhost->s;
   port = qport->i;
   database = qdatabase->s;   
   char *uri;
   
   mongoc_init ();

   uri = bson_strdup_printf ("mongodb://%s:%d/%s?ssl=%s",
	                                host,
		                        port,
		                        database,
		                        "false");

   if (!(client = mongoc_client_new (uri))) {
   	mongoc_cleanup ();
   	krr("Invalid connection details");
	return (K)0;
   } 
   initialised = true;
   return (K)0;
}

K mongo_cleanup(K x)
{
   mongoc_client_destroy (client);
   mongoc_cleanup ();
   initialised = false;
   return (K)0;
}

K mongo_delete(K qtable, K qquery)
{
  mongoc_collection_t *collection;
  bson_error_t error;
  bson_t *doc;
  collection = mongoc_client_get_collection (client, database, qtable->s);
  doc = bson_new_from_json(kC(qquery),qquery->n,&error);
  mongoc_collection_remove (collection, MONGOC_REMOVE_NONE, doc, NULL, &error);
  bson_destroy(doc);
  mongoc_collection_destroy (collection);
  return (K)0;
}


K mongo_bulkinsert(K table, K records)
{
   mongoc_collection_t *collection;
  mongoc_bulk_operation_t *bulk;
  bson_error_t error;
  bson_t *doc;
  bson_oid_t oid;
  bson_t reply;
  char *str;
  bool ret;
  int i;
  char oidstr[25];
  K qoids,qoid;

   collection = mongoc_client_get_collection (client, database, table->s);
  bulk = mongoc_collection_create_bulk_operation (collection, true, NULL);
  qoids = ktn(0, records->n);

  for (i = 0; i < records->n; i++) {
    bson_oid_init (&oid, NULL);
    doc = bson_new_from_json(kC(kK(records)[i]),(kK(records)[i])->n,&error);
    bson_append_oid(doc, "_id", -1, &oid);
    mongoc_bulk_operation_insert (bulk, doc);
    bson_destroy (doc);
    bson_oid_to_string(&oid, oidstr);
    kK(qoids)[i] = kp(oidstr);
  }

  ret = mongoc_bulk_operation_execute (bulk, &reply, &error);

  str = bson_as_json (&reply, NULL);
  printf ("%s\n", str);
  bson_free (str);

  if (!ret) {
    fprintf (stderr, "Error: %s\n", error.message);
  }

  bson_destroy (&reply);
  mongoc_bulk_operation_destroy (bulk);
  mongoc_collection_destroy (collection);

  return qoids;
}


K mongo_find(K qtable, K qquery, K qfields)
{
   // mongoc_client_t *client;
   mongoc_collection_t *collection;
   mongoc_cursor_t *cursor;
   const bson_t *item;
   bson_error_t error;
   bson_t *query;
   bson_t *fields;
   char *str;
   bool r;
   char oidstr[25];
   int i;
   K rtn,record;

   if(qquery->t!=10){krr("type");return (K)0;}; 

   /* get a handle to our collection */
   collection = mongoc_client_get_collection (client, database, qtable->s);

   query = bson_new_from_json(kC(qquery),qquery->n,&error);
   fields = bson_new_from_json(kC(qfields),qfields->n,&error);

   /* execute the query and iterate the results */
   cursor = mongoc_collection_find (collection, MONGOC_QUERY_NONE, 0, 0, 0, query, fields, NULL);
   rtn = ktn(0, 0);
   while (mongoc_cursor_next (cursor, &item)) {
      str = bson_as_json (item, NULL);
      record = kp(str);
      jk(&rtn,record);
      bson_free (str);
   }

   /* release everything */
   mongoc_cursor_destroy (cursor);
   mongoc_collection_destroy (collection);
   // mongoc_client_destroy (client);
   bson_destroy (query);
   bson_destroy (fields);
   
   return rtn;
}


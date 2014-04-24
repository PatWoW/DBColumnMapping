DBColumnMapping
===============

DBColumnMapping project enables you to generate .h and .m file for the sqlite database tables

Header file maps to sqlite data type/column to objective c datatype /property 

e.g Database table “Customer” Which has firstname as varchar column.

DBColumnMapping generates DBCustomer.h and DBCustomer.m file

Sample output of the header file

@property(strong,nonatomic) NSString *firstname;

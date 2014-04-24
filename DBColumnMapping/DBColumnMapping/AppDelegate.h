//
//  AppDelegate.h
//  DBColumnMapping
//
//  Created by Muthu Rama on 25/04/2014.
//  Copyright (c) 2014 Black Pearl Info Tech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBLogDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,DBLogDelegate>

@property (assign) IBOutlet NSWindow *window;

//Database file name and path
@property (weak) IBOutlet NSTextField *txtDatabasePath;

//Name of subclass to extend
@property (weak) IBOutlet NSTextField *txtSubClass;

//Output folder path and name
@property (weak) IBOutlet NSTextField *txtOutputFolder;

/**
 * This method loop through all the table in sqlite database and outputs header and implementation file 
 * Header file maps to database datatype and column name
 *
 * e.g Database table Customer
 * -----------------------------------------------------------------
 * Column name: customerid int
 * Column name: customername varchar
 * Column name: DOB date
 *
 * -----------------------------------------------------------------
 *
 * Output Header File
 * 
 * @ interface DBCustomer:NSObect
 * 
 * @property (strong,nonatomic) NSNumber *customerid;
 * 
 * @property (strong,nonatomic) NSString *customername;
 *
 * @property (strong,nonatomic) NSDate *DOB;
 */
- (IBAction)GenerateDBColumnMapping:(id)sender;



@property (weak) IBOutlet NSTextField *logInfo;

@end

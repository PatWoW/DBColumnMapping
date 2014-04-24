//
//  AppDelegate.m
//  DBColumnMapping
//
//  Created by Muthu Rama on 25/04/2014.
//  Copyright (c) 2014 Black Pearl Info Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "DBUtil.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)GenerateDBColumnMapping:(id)sender {
    
    //Clear log info
    
    [_logInfo setStringValue:@""];
    
    NSString *path = [_txtDatabasePath stringValue];
    
    if([path length]==0){
        [self writeLog:@"Database path is empty"];
        return ;
    }
    
    DBUtil *dbUtil = [[DBUtil alloc]init];
    
    dbUtil.logDelegate=self;
    
    dbUtil.extClass = [_txtSubClass stringValue];
    [dbUtil generateGetterAndSetterDBPath:path];
    
    [_txtOutputFolder setStringValue:[dbUtil outputPath]];
    
    
     
}


- (void) writeLog:(NSString *) logMessage{
    NSLog(@"%@",logMessage);
    
    NSString *extString = [_logInfo stringValue];
    
    logMessage = [NSString stringWithFormat: @"%@\n", logMessage];
    
   
    
    [_logInfo setStringValue:[extString stringByAppendingString:logMessage]];
}

@end

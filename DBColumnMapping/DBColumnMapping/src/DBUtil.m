//
//  DBUtil.m
//  DBColumnMapping
//
//  Created by Muthu Rama on 22/04/2014.
//  Copyright (c) 2014 Muthu Rama. All rights reserved.
//

#import "DBUtil.h"

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@implementation DBUtil

NSString *outputFolderPath;
NSString *outputFolderName = @"DBColumnMappingOutput";

-(void) generateGetterAndSetterDBPath:(NSString *)dbPath {
    
    [self logMessage:[NSString stringWithFormat:@"Database Path %@",dbPath]];
    
    //Check Database file exit and connect
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
       
        [self logMessage:[NSString stringWithFormat:@"Database file not found %@",dbPath]];
        //[self logMessage:[NSString stringWithFormat:@"Database file not found %@",dbPath);
        return;
    }
    
    
    [self logMessage:[NSString stringWithFormat:@"Database file exits"]];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //NSURL *docsurl = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask  appropriateForURL:nil create:YES error:&error];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    outputFolderPath = [documentsDirectory stringByAppendingPathComponent:outputFolderName];
   
    
    //outputFolderPath=[ myfolder description];
    
    outputFolderPath = [outputFolderPath stringByReplacingOccurrencesOfString:@"file:///"
                                                                   withString:@"/"];
    
    [self logMessage:[NSString stringWithFormat:@"Output Folder Path %@",outputFolderPath]];
    
    _outputPath = outputFolderPath;
    NSError * err = nil;
    
    //if ([fm createDirectoryAtURL:myfolder withIntermediateDirectories:YES attributes:nil error:&err]) {
    

    
    if ([fm createDirectoryAtPath:outputFolderPath withIntermediateDirectories:YES attributes:nil error:&err]) {

        if(err!=nil){
            [self logMessage:[NSString stringWithFormat:@"Unable to create directory %@",outputFolderPath]];        }
        
    }
    else {
        [self logMessage:[NSString stringWithFormat:@"Unable to create directory %@", err]];
    }
    
    
    [self logMessage:[NSString stringWithFormat:@"Trying to connect database"]];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    [db open];
    
    [self logMessage:[NSString stringWithFormat:@"Database connected"]];
    
    FMResultSet *results = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type = 'table'"];
    
    while([results next])
    {
        
        NSString *tblName = [results stringForColumnIndex:0];
       

        if([[tblName lowercaseString] hasPrefix:[@"sqlite" lowercaseString]]){
            continue;
        }
        
         [self logMessage:[NSString stringWithFormat:@"Processing Table : %@", tblName]];
        
        
        FMResultSet *columnNamesSet = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", tblName]];
        
        NSMutableDictionary *colNameDictionary = [[NSMutableDictionary alloc] init];
        
        while ([columnNamesSet next]) {
            
            [colNameDictionary setObject:[columnNamesSet stringForColumn:@"type"] forKey:[columnNamesSet stringForColumn:@"name"]];
            
        }
        
        [self createFileWithTableName:tblName columnDetails:colNameDictionary prefix:@"DB"];
        
        
        //break;
        
    }
    
    
    [self logMessage:[NSString stringWithFormat:@"Closing database connection"]];
    
    [db close];
    
    [self logMessage:[NSString stringWithFormat:@"Database connection closed"]];
    
    [self logMessage:[NSString stringWithFormat:@"Output Folder : %@",outputFolderPath]];
    
    
}

-(void)createFileWithTableName:(NSString *) tblName columnDetails:(NSMutableDictionary *)columnDetails prefix:(NSString *)preFix{
    
    
    NSString *firstCapChar = [[tblName substringToIndex:1] capitalizedString];
    NSString *fileName = [tblName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    fileName = [NSString stringWithFormat:@"%@%@",preFix,fileName];
    
    NSString *headerFile =  [NSString stringWithFormat: @"%@/%@.h",outputFolderPath,fileName];
    
    [self logMessage:[NSString stringWithFormat:@"Processing %@.h file .....",fileName]];
    
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:headerFile contents:nil attributes:nil];
    
    if(!success){
        [self logMessage:[NSString stringWithFormat:@"Error in creating .h file : %@",fileName]];
        return;
    }
    
    [self logMessage:[NSString stringWithFormat:@".h file created for %@",fileName]];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:headerFile];
    
    
    
    [self writeToFile:fileHandle texttoWrite:@"//"];
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"// %@",fileName]];
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"// Created by Muthu Rama %@",[NSDate date]]];
    [self writeToFile:fileHandle texttoWrite:@"//"];
    
    
    
    [self writeToFile:fileHandle texttoWrite:@"#import <Foundation/Foundation.h>"];
    
    if([self isEmptyString:_extClass]){
        _extClass =@"NSObject";
    }
    
    ;
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"#import \"%@.h\"",_extClass]];
    
    [self writeToFile:fileHandle texttoWrite:@""];
    
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"@interface %@ : %@",fileName,_extClass]];
    
    [self writeToFile:fileHandle texttoWrite:@""];
    
    
    for(id key in columnDetails) {
        
        NSString *columnName =key;
        NSString * sqlDataType =  [columnDetails objectForKey:key];
        NSString *dataType =[self mapDataType:sqlDataType];
        
        [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"@property(strong,nonatomic) %@ *%@;",dataType,columnName]];
        [self writeToFile:fileHandle texttoWrite:@""];
        
        
    }
    
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"@end"]];
    
    
    
    [fileHandle closeFile];
    [self logMessage:[NSString stringWithFormat:@"Completed .h file : %@",fileName]];
    
    
    //Create .m file
    
    NSString *moduleFile =  [NSString stringWithFormat: @"%@/%@.m",outputFolderPath,fileName];
    [self createModuleFilePath:moduleFile fileName:fileName];
    
    
    
}

-(void) createModuleFilePath:(NSString *)moduleFile fileName:(NSString *)name {
    
    [self logMessage:[NSString stringWithFormat:@"Processing .m file %@ .....",name]];
    
    
    BOOL success = [[NSFileManager defaultManager] createFileAtPath:moduleFile contents:nil attributes:nil];
    
    if(!success){
        [self logMessage:[NSString stringWithFormat:@"Error in creating .m file : %@",name]];
        return;
    }
    
    
    [self logMessage:[NSString stringWithFormat:@".m file created for %@",name]];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:moduleFile];
    
    [self writeToFile:fileHandle texttoWrite:@"//"];
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"// %@.m",name]];
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"// Created by Muthu Rama %@",[NSDate date]]];
    [self writeToFile:fileHandle texttoWrite:@"//"];
    
    
    
    
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"#import \"%@.h\"",name]];
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:@""];
    
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"@implementation %@",name]];
    
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:@""];
    [self writeToFile:fileHandle texttoWrite:[NSString stringWithFormat:@"@end"]];
    
    
    
    [fileHandle closeFile];
    
    [self logMessage:[NSString stringWithFormat:@"Completed .m file : %@",name]];
    
    
}

-(void) writeToFile:(NSFileHandle *)fileHandle texttoWrite:content{
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}


-(NSString *) mapDataType:(NSString *)sqlliteDataType{
    NSString *dataType;
    NSString *NSType;
    
    
    dataType = [sqlliteDataType uppercaseString];
    
    //NSNUMBER - BIGINT BIT BOOL BOOLEAN INT INT2 INT8 INTEGER MEDIUMINT SMALLINT TINYINT
    
    //NSData - BINARY BLOB VARBINARY
    
    //NSDate - DATE DATETIME TIMESTAMP
    
    //NSDecimalNumber - DECIMAL DOUBLE DOUBLE PRECISION FLOAT NUMERIC REAL
    
    //NSNull - NULL
    
    if([dataType isEqualToString:@"BIGINT"] || [dataType isEqualToString:@"BIT"]|| [dataType isEqualToString:@"BOOL"]|| [dataType isEqualToString:@"BOOLEAN"]|| [dataType isEqualToString:@"INT"]|| [dataType isEqualToString:@"INT2"]|| [dataType isEqualToString:@"INTEGER"]|| [dataType isEqualToString:@"MEDIUMINT"]|| [dataType isEqualToString:@"SMALLINT"]|| [dataType isEqualToString:@"TINYINT"]){
        NSType = @"NSNumber";
    }else if([dataType isEqualToString:@"BINARY"] || [dataType isEqualToString:@"BLOB"]|| [dataType isEqualToString:@"VARBINARY"]){
        
        NSType = @"NSData";
        
    }else if([dataType isEqualToString:@"DATE"]|| [dataType isEqualToString:@"DATETIME"]|| [dataType isEqualToString:@"TIMESTAMP"]){
        
        NSType = @"NSDate";
        
    }else if([dataType isEqualToString:@"DECIMAL"]|| [dataType isEqualToString:@"DOUBLE"]|| [dataType isEqualToString:@"DOUBLE PRECISION"]|| [dataType isEqualToString:@"FLOAT"]|| [dataType isEqualToString:@"NUMERIC"]|| [dataType isEqualToString:@"REAL"]){
        
        NSType = @"NSDecimalNumber";
        
    }else if([dataType isEqualToString:@"NULL"]){
        NSType = @"NSNull";
        
    }else {
        NSType =@"NSString";
    }
    
    
    return NSType;
}

       
-(BOOL) isEmptyString:(NSString *)inputString{
    
    return [allTrim( inputString ) length] == 0;
           
}

-(void) logMessage:(NSString *) msg{
    [self.logDelegate writeLog:msg];
}
        
@end

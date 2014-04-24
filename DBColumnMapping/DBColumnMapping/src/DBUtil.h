//
//  DBUtil.h
//  FMDB ORM
//
//  Created by Muthu Rama on 22/04/2014.
//  Copyright (c) 2014 Muthu Rama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "DBLogDelegate.h"

@interface DBUtil : NSObject

-(void) generateGetterAndSetterDBPath:(NSString *)dbPath;

@property(strong,nonatomic) NSString *outputPath;
@property(strong,nonatomic) NSString *extClass;

@property(assign,nonatomic)id<DBLogDelegate> logDelegate;

@end

//
//  UtilFunctions.h
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UtilFunctions : NSObject


+(UIAlertController *)getSimpleAlertVC:(NSString *)msgTitle msg:(NSString *)msg okMsg:(NSString *)okMsg;
+(UIAlertController *)getSimpleAlertVC:(NSString *)msgTitle msg:(NSString *)msg;


@end

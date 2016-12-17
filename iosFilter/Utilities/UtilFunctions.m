//
//  UtilFunctions.m
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 17..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import "UtilFunctions.h"

@implementation UtilFunctions


+(UIAlertController *)getSimpleAlertVC:(NSString *)msgTitle msg:(NSString *)msg okMsg:(NSString *)okMsg{
    //Alert window
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:msgTitle
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:okMsg
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];

    
    [alert addAction:ok];

    return alert;

}

@end

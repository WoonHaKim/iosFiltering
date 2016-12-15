//
//  AppDelegate.h
//  iosFilter
//
//  Created by 김운하 on 2016. 12. 15..
//  Copyright © 2016년 김운하. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end


//
//  UIViewController+SHSegueBlock.m
//  Example
//
//  Created by Seivan Heidari on 5/16/13.
//  Copyright (c) 2013 Seivan Heidari. All rights reserved.
//

#import "UIViewController+SHSegueBlocks.h"

@interface SHSegueBlocksManager : NSObject

@property(nonatomic,strong) NSMapTable * mapBlocks;
@property(nonatomic,strong) NSMapTable * mapUserInfo;

+(instancetype)sharedManager;

-(void)SH_memoryDebugger;
@end


@implementation SHSegueBlocksManager
#pragma mark -
#pragma mark Init & Dealloc
-(instancetype)init; {
  self = [super init];
  if (self) {
    self.mapBlocks      = [NSMapTable weakToWeakObjectsMapTable];
    self.mapUserInfo    = [NSMapTable weakToStrongObjectsMapTable];
//    [self SH_memoryDebugger];
  }
  
  return self;
}

+(instancetype)sharedManager; {
  static SHSegueBlocksManager *_sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[SHSegueBlocksManager alloc] init];
    
  });
  
  return _sharedInstance;
  
}

#pragma mark -
#pragma mark Debugger
-(void)SH_memoryDebugger; {
  double delayInSeconds = 5.0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    NSLog(@"USERINFO %@",self.mapUserInfo);
    NSLog(@"BLOCK %@",self.mapBlocks);
    [self SH_memoryDebugger];
  });
}

@end

@interface UIViewController ()

@property(nonatomic,readonly) NSMapTable * mapBlocks;
@property(nonatomic,readonly) NSMapTable * mapUserInfo;

@end

@implementation UIViewController (SHSegueBlock)

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Getters

-(NSMutableDictionary *)SH_userInfo; {
  NSMutableDictionary * userInfo = [self.mapUserInfo objectForKey:self];
  if(userInfo == nil){
    userInfo = @{}.mutableCopy;
    self.SH_userInfo = userInfo;
  }
  return userInfo;
}

#pragma mark -
#pragma mark Setters

-(void)setSH_userInfo:(NSMutableDictionary *)userInfo; {
  if(userInfo)
    [self.mapUserInfo setObject:userInfo forKey:self];
  else
    [self.mapUserInfo removeObjectForKey:self];
}

#pragma mark -
#pragma mark Segue Performers


-(void)SH_performSegueWithIdentifier:(NSString *)theIdentifier
           andPrepareForSegueBlock:(SHPrepareForSegue)theBlock; {
  NSMutableDictionary * blocks = [self.mapBlocks objectForKey:self];
  if(blocks == nil) blocks = @{}.mutableCopy;
  if(theBlock) blocks[theIdentifier] = [theBlock copy];
  [self.mapBlocks setObject:blocks forKey:self];
  [self performSegueWithIdentifier:theIdentifier sender:self];
}

-(void)SH_performSegueWithIdentifier:(NSString *)theIdentifier
       andDestionationViewController:(SHPrepareForSegueDestinationViewController)theBlock; {
  [self SH_performSegueWithIdentifier:theIdentifier andPrepareForSegueBlock:^(UIStoryboardSegue *theSegue) {
    UIViewController * destinationViewController = theSegue.destinationViewController;
    if(theBlock) theBlock(destinationViewController);
  }];
}


-(BOOL)SH_handlesBlockForSegue:(UIStoryboardSegue *)theSegue; {
  BOOL handlesBlockForSegue = NO;
  NSMutableDictionary * blocks = [SHSegueBlocksManager.sharedManager.mapBlocks objectForKey:self];
  SHPrepareForSegue block = blocks[theSegue.identifier];
  if(block) {
    handlesBlockForSegue = YES;
    block(theSegue);
  }
  return handlesBlockForSegue;

}


#pragma mark -
#pragma mark Don't Use
-(void)SH_performSegueWithIdentifier:(NSString *)theIdentifier
                         withUserInfo:(NSDictionary *)theUserInfo; {
  [self SH_performSegueWithIdentifier:theIdentifier andDestionationViewController:^(UIViewController * theDestinationViewController) {
    theDestinationViewController.SH_userInfo = [theUserInfo mutableCopy];
  }];
}

//- (void)SH_performSegueWithIdentifier:(NSString *)identifier
//      andPrepareUserInfoForSegueBlock:(SHPrepareUserInfoForSegue)theBlock; {
//  [self SH_performSegueWithIdentifier:identifier andPrepareForSegueBlock:^(UIStoryboardSegue *theSegue) {
//    UIViewController * destionationViewController = theSegue.destinationViewController;
//    theBlock(destionationViewController.userInfo);
//  }];
//}

#pragma mark -
#pragma mark Privates

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Getters
-(NSMapTable *)mapBlocks; {
  return SHSegueBlocksManager.sharedManager.mapBlocks;
}
-(NSMapTable *)mapUserInfo; {
  return SHSegueBlocksManager.sharedManager.mapUserInfo;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender; {
  NSMutableDictionary * blocks = [SHSegueBlocksManager.sharedManager.mapBlocks objectForKey:self];
  SHPrepareForSegue block = blocks[segue.identifier];
  if(block) block(segue);
//Don't need to do this as we have weak2weak references  [blocks removeObjectForKey:segue.identifier];
  [SHSegueBlocksManager.sharedManager.mapBlocks setObject:blocks forKey:self];

}
#pragma clang diagnostic pop



@end

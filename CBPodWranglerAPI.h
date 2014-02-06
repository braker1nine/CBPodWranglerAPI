//
//  CBPodWranglerAPI.h
//  Podcasts
//
//  Created by Chris Brakebill on 1/26/14.
//  Copyright (c) 2014 Chris Brakebill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBPodWranglerAPI : NSObject

@property (nonatomic, strong) NSString *client_key;
@property (nonatomic, assign) BOOL authenticated;
@property (nonatomic, strong, readonly) NSString *access_token;


-(id)initWithClientKey:(NSString *)key;
-(void)authenticateWithEmail:(NSString *)email
                 andPassword:(NSString *)password
                  completion:(void (^)(BOOL success, NSError *err))completionHandler;
-(void)getPodcasts:(void (^)(NSArray *arr, NSError *err))completionHandler;
-(void)getUnheardEpisodesWithParams:(NSDictionary *)params completion:(void (^)(NSArray *arr, NSError *err))completionHandler;
-(void)getEpisodes:(void (^)(NSArray *arr, NSError *err))completionHandler params:(NSDictionary *)params;
-(void)updatePodcastWithId: (NSString *)pid params:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *err))completion;

@end

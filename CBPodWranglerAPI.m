//
//  CBPodWranglerAPI.m
//  Podcasts
//
//  Created by Chris Brakebill on 1/26/14.
//  Copyright (c) 2014 Chris Brakebill. All rights reserved.
//

#import "CBPodWranglerAPI.h"

@implementation CBPodWranglerAPI

@synthesize client_key = _client_key,
access_token = _access_token,
authenticated = _authenticated;

-(id)initWithClientKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _client_key = key;
        _access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
        if (_access_token != nil) {
            _authenticated = YES;
        } else {
            _authenticated = NO;
        }
    }
    return self;
}

-(void)makeRequestWithLocation:(NSString *)location andParams:(NSDictionary *)dict completionHandler:(void (^)(NSDictionary *arr, NSError *err))completion
{
    NSMutableString *baseUrl = [NSMutableString stringWithString:@"https://feedwrangler.net/api/v2"];
    [baseUrl appendString:location];
    [baseUrl appendString:@"?"];
    if (dict != nil) {
        for (NSString *key in dict.allKeys) {
            [baseUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, [dict objectForKey:key]]];
        }
    }
    if (_access_token != nil) {
        [baseUrl appendString:[NSString stringWithFormat:@"access_token=%@", _access_token]];
    } else {
        [baseUrl appendString:[NSString stringWithFormat:@"client_key=%@", _client_key]];
    }
    
    
    NSURL *url = [NSURL URLWithString:baseUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               //NSLog(@"%@", result);
                               if (completion != nil) {
                                   completion(result, connectionError);
                               }
                           }
     ];
}

-(void)authenticateWithEmail:(NSString *)email
                 andPassword:(NSString *)password
                  completion:(void (^)(BOOL success, NSError *err))completionHandler
{
    
    [self makeRequestWithLocation:@"/users/authorize"
                        andParams:@{@"email":email,
                                    @"password":password}
                completionHandler:^(NSDictionary *resp, NSError *err) {
                    BOOL success = [[resp objectForKey:@"result"] isEqualToString:@"success"];
                    
                    if (success) {
                        _access_token = [resp objectForKey:@"access_token"];
                        [[NSUserDefaults standardUserDefaults] setObject:_access_token forKey:@"access_token"];
                        _authenticated = YES;
                    }
                    
                    if (completionHandler != nil) {
                        completionHandler(success, nil);
                    }
                }
     ];
}

-(void)getPodcasts:(void (^)(NSArray *arr, NSError *err))completionHandler;
{
    [self makeRequestWithLocation:@"/podcasts/podcasts"
                        andParams:nil
                completionHandler:^(NSDictionary *resp, NSError *err) {
                    NSLog(@"%@", resp);
                    if (completionHandler != nil) {
                        if ([self successResponse:resp])  {
                            completionHandler([resp objectForKey:@"podcasts"], nil);
                        } else {
                            completionHandler(nil, [NSError errorWithDomain:@"ERROR" code:1 userInfo:nil]);
                        }
                    }
                }];
}

-(BOOL)successResponse:(NSDictionary *)response
{
    return [[response objectForKey:@"result"] isEqualToString:@"success"];
}

-(void)getEpisodes:(void (^)(NSArray *arr, NSError *err))completionHandler params:(NSDictionary *)params
{
    [self makeRequestWithLocation:@"/podcasts/episodes"
                        andParams:params
                completionHandler:^(NSDictionary *resp, NSError *err) {
                    NSLog(@"%@", resp);
                    if (completionHandler != nil) {
                        if ([self successResponse:resp]) {
                            completionHandler([resp objectForKey:@"episodes"], nil);
                        }
                    }
                }];
}

-(void)getUnheardEpisodesWithParams:(NSDictionary *)params completion:(void (^)(NSArray *arr, NSError *err))completionHandler
{
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:params];
    p[@"heard"] = @"false";
    [self getEpisodes:completionHandler params:p];
}

-(void)updatePodcastWithId: (NSString *)pid params:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *err))completion
{
    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:params];
    p[@"episode_id"] = pid;
    
    [self makeRequestWithLocation:@"/podcasts/update" andParams:p completionHandler:^(NSDictionary *arr, NSError *err) {
        NSLog(@"Updated: %@", arr);
    }];
}

@end

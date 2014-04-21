//
//  HomeViewController.m
//  QuickMenu
//
//  Created by Noah Martin on 4/14/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTableViewController.h"
#import "RestaurantFactory.h"

#import "OAuthConsumer.h"

@interface HomeViewController()
@property CLLocationManager *locationManager;
@property double longtidude;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) HomeTableViewController *tableController;
@property (strong, nonatomic) NSMutableArray* data; // The resturants from Yelp
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSURLConnection *conn;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) RestaurantFactory* factory;
@property double latitude;
@end

@implementation HomeViewController

-(RestaurantFactory*)factory
{
    if(!_factory)
    {
        return _factory = [[RestaurantFactory alloc] init];
    }
    return _factory;
}

-(void)viewDidLoad
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.tableController = [[HomeTableViewController alloc] init];
    self.refreshControl = [[UIRefreshControl alloc]
                                        init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.table addSubview:self.refreshControl];
    
    [self.table setDataSource:self.tableController];
    [self.table setDelegate:self.tableController];
    [self.tableController setTableView:self.table];
    
    [self.locationManager startUpdatingLocation];

}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self.locationManager startUpdatingLocation];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.data = [self.factory restaurantsForData:self.responseData];
    // TODO: at this point our api should be called on the list of restuarts to get a list of menus or null if the menu is not found
    // Then the menus that are not found should be removed and everything else should be stored by this class
    self.tableController.restaurants = self.data;
    self.responseData = NULL;  // Stop referencing this for the GC
    
    [self.refreshControl endRefreshing];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // TODO: handle this fail
    NSLog(@"failed");
    [self.refreshControl endRefreshing];
}

-(void)updateYelp
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?sort=1&ll=%f,%f", self.latitude, self.longtidude]];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"iIixPO3MfoeJp2NOyTlpVw" secret:@"LOn-ZnCRWv_4xU_4-CR0Zjf6CmU"];
    OAToken *token = [[OAToken alloc] initWithKey:@"f_MXBL42HAdYTfSP4bGx0WOxGYuFPr60" secret:@"ob9tIi9tc40InGRM-qPtfwVrTYc"];
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    _responseData = [[NSMutableData alloc] init];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.longtidude = currentLocation.coordinate.longitude;
        self.latitude = currentLocation.coordinate.latitude;
    }
    [self.locationManager stopUpdatingLocation];

    [self updateYelp];
}

@end

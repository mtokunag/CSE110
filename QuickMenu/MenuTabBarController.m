//
//  MenuTabBarController.m
//  Menyou
//
//  Created by Noah Martin on 4/21/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "MenuTabBarController.h"
#import "MyMenuViewController.h"

@implementation MenuTabBarController

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"showMyMenuSegue"])
    {
        if(!([self.menu numberSelected] > 0))
        {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"No dishes in your menu" message:@"You haven't added anything to your menu!" delegate:nil cancelButtonTitle:@"Add food!" otherButtonTitles:nil];
            [errorAlert show];
            return NO;
        }
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showMyMenuSegue"])
    {
        MyMenuViewController* newController = ((MyMenuViewController*) segue.destinationViewController);
        newController.myMenu = self.menu;
    }
}

@end

//
//  MlWelcomePageViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/20/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlWelcomePageViewController.h"
#import "MlWelcomeScreenViewController.h"

@interface MlWelcomePageViewController ()

@property NSMutableArray *pages;

@end

@implementation MlWelcomePageViewController

int numberOfPages = 3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self createPages];
    self.dataSource = self;
    [self setViewControllers:[NSArray arrayWithObject:[self.pages objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:true completion:nil];
}

-(void) createPages{
    self.pages = [[NSMutableArray alloc]initWithCapacity:3];
    
    MlWelcomeScreenViewController *controller;
    for (int i = 0; i < numberOfPages; i++) {
        controller = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"welcomeScreenPage%d",i]];
        controller.pageNumber = [NSNumber numberWithInt:i];
        [self.pages addObject:controller];
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    MlWelcomeScreenViewController *view = nil;
    
    if ([self.pages objectAtIndex:numberOfPages - 1] != viewController){ // If it's not the last page
        for (int i = 0; i < numberOfPages; i++) {
            if ([self.pages objectAtIndex:i] == viewController){
                view = [self.pages objectAtIndex:i+1];
                break;
            }
        }
    }
    return view;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    MlWelcomeScreenViewController *view = nil;
    
    if ([self.pages objectAtIndex:0] != viewController){
        for (int i = numberOfPages - 1; i > 0 ; i--) {
            if ([self.pages objectAtIndex:i] == viewController){
                view = [self.pages objectAtIndex:i-1];
                break;
            }
        }
    }
    return view;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [[(MlWelcomePageViewController *)pageViewController pages] count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

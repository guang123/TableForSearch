//
//  ViewController.m
//  ShowLabel
//
//  Created by Yx on 15/6/15.
//  Copyright (c) 2015年 Yx. All rights reserved.
//

#import "ViewController.h"
#import "SearchViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)pushSearchVC:(id)sender {
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    [self presentViewController:searchVC animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

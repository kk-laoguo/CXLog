//
//  ViewController.m
//  CXConsoleDemo
//
//  Created by zainguo on 2019/10/18.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)jump:(id)sender {
    
    [self.navigationController pushViewController:[NSClassFromString(@"TestViewController") new]  animated:YES];
}

@end

//
//  HelpViewController.m
//  Netvirta_Test
//
//  Created by Mohammad Zulqurnain on 15/04/2018.
//  Copyright © 2018 Mohammad Zulqurnain. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnGoBackAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}

@end

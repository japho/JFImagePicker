//
//  ViewController.m
//  JFImagePicker
//
//  Created by 汪继峰 on 16/7/25.
//  Copyright © 2016年 汪继峰. All rights reserved.
//

#import "ViewController.h"
#import "JFImagePickerController.h"

@interface ViewController () <JFImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)show:(id)sender
{
    JFImagePickerController *imagePicker = [JFImagePickerController imagePicker];
    imagePicker.jfDelegate = self;
    imagePicker.maxAmount = 9;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - --- JFImagePickerController Delegate ---

- (void)imagePickerControllerDidFinishWithArray:(NSArray *)array
{
    NSLog(@"%@",array);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果" message:[array description] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alert show];
}

@end

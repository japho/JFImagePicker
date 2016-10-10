//
//  JFAlbumVC.m
//  JFAlbum
//
//  Created by Japho on 15/10/22.
//  Copyright © 2015年 Japho. All rights reserved.
//

#import "JFAlbumVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JFGroupInfo.h"
#import "JFGroupCell.h"
#import "JFPhotoVC.h"
#import "JFImagePickerController.h"

@interface JFAlbumVC () <UITableViewDataSource,UITableViewDelegate>
{
    ALAssetsLibrary *_assetsLibrary;//资源库
    NSMutableArray *_groupArray;
    UITableView *_tableView;
}
@end

@implementation JFAlbumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"照片";
    
    //设置navigation的属性
    [self setNavigationBar];
    //添加tableView
    [self addTableView];
    //从资源库中加载相册信息
    [self loadAssetsGroup];
    
}

- (void)setNavigationBar
{
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                              NSFontAttributeName:[UIFont boldSystemFontOfSize:20]
                              }];
    
    //设置导航条的背景颜色（图片）
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"JFImagePicker.bundle/jf_nav_purple"] forBarMetrics:UIBarMetricsDefault];
    
    //设置导航条按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //设置导航栏按钮颜色为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//添加tableView
- (void)addTableView
{
    CGRect frame = self.view.frame;
    frame.size.height -= 44 + 20;
    
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

//从资源库中加载相册信息
- (void)loadAssetsGroup
{
    ALAuthorizationStatus authorStatus = [ALAssetsLibrary authorizationStatus];
    if (authorStatus == ALAuthorizationStatusDenied || authorStatus == ALAuthorizationStatusRestricted)
    {
        //程序的名字
        NSDictionary*info = [[NSBundle mainBundle] infoDictionary];
        NSString*projectName = [info objectForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:@"请在%@的“设置－隐私－照片”选项中，允许%@访问您的手机。",[UIDevice currentDevice].model,projectName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alertView show];
    }
    
    //初始化资源库
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    //初始化数组
    _groupArray = [NSMutableArray arrayWithCapacity:10];
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group)
        {
            //添加资源过滤器
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            //判断照片里的照片数量大于零·
            if (group.numberOfAssets > 0)
            {
                JFGroupInfo *groupInfo = [JFGroupInfo groupInfoWithGroup:group];
                [_groupArray addObject:groupInfo];
            }
        }
        else
        {
            _groupArray = (NSMutableArray *)[[_groupArray reverseObjectEnumerator] allObjects];
            
            JFPhotoVC *firstPhotoVC = [[JFPhotoVC alloc] initWithGroupInfo:_groupArray[0]];
            firstPhotoVC.delegate = self.navigationController;
            firstPhotoVC.maxAmount = _maxAmount;
            [self.navigationController pushViewController:firstPhotoVC animated:NO];
            
            //获取组结束
            [_tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"获取组失败");
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cell";
    JFGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell)
    {
        cell = [[JFGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
    }
    
    [cell setContentView:_groupArray[indexPath.row]];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JFPhotoVC *photoVC = [[JFPhotoVC alloc] initWithGroupInfo:_groupArray[indexPath.row]];
    photoVC.delegate = self.navigationController;
    photoVC.maxAmount = _maxAmount;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JFGroupCell getCellHeight];
}

@end

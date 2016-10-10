//
//  JFPhotoVC.m
//  JFAlbum
//
//  Created by Japho on 15/10/22.
//  Copyright © 2015年 Japho. All rights reserved.
//

#import "JFPhotoVC.h"
#import "JFGroupInfo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JFAssetsInfo.h"
#import "MBProgressHUD.h"

#define kMargin 5
#define kBottomHeight 40
#define kCountButtonHeight 18
#define LIGHT_GREEN_COLOR [UIColor colorWithRed:83.0/255.0f green:181.0/255.0f blue:70.0/255.0f alpha:1.0f]
#define LIGHT_WHITE_COLOR [UIColor colorWithRed:231.0/255.0f green:231.0/255.0f blue:231.0/255.0f alpha:1.0f]
#define kMaxAmount 6

static NSString *cellIdentifier = @"cellIdentifier";

@interface JFPhotoVC () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    JFGroupInfo *_groupInfo;
    UICollectionView *_collectionView;
    NSMutableArray *_assetInfoArray;
    NSMutableArray *_selectedAssetsInfoArray;
    UIButton *_doneButton;//完成按钮
    UIButton *_countButotn;
    MBProgressHUD *_HUD;
    dispatch_queue_t _queue;//全局串行队列
}
@end

@implementation JFPhotoVC

- (instancetype)initWithGroupInfo:(JFGroupInfo *)groupInfo
{
    self = [super init];
    if (self)
    {
        _groupInfo = groupInfo;
        self.title = groupInfo.title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    //添加collectionView
    [self addCollectionView];
    
    //添加底部视图
    [self addBottomView];
    
    //加载相册里的照片
    [self loadAssets];
}

- (void)addCollectionView
{
    CGRect frame = self.view.frame;
    frame.size.height -= 44 + 20 + kBottomHeight;
    //初始化
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    //注册
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.allowsMultipleSelection = YES;
    [self.view addSubview:_collectionView];
}

//添加底部视图
- (void)addBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), self.view.bounds.size.width, kBottomHeight)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setFrame:CGRectMake(self.view.bounds.size.width - 50 - 10, (kBottomHeight - 20) / 2, 50, 20)];
    [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [_doneButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_doneButton setUserInteractionEnabled:NO];
    [_doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_doneButton];
    
    _countButotn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_countButotn setFrame:CGRectMake(CGRectGetMinX(_doneButton.frame) - kCountButtonHeight + 5, (kBottomHeight - kCountButtonHeight) / 2, kCountButtonHeight, kCountButtonHeight)];
    [_countButotn setBackgroundColor:LIGHT_GREEN_COLOR];
    [_countButotn.layer setCornerRadius:9];
    [_countButotn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_countButotn setHidden:YES];
    [bottomView addSubview:_countButotn];
}

//加载相册里的照片
- (void)loadAssets
{
    _assetInfoArray = [NSMutableArray arrayWithCapacity:10];
    
    ALAssetsGroup *group = _groupInfo.group;
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result)
        {
            JFAssetsInfo *assetInfo = [[JFAssetsInfo alloc] initWithAsset:result];
            [_assetInfoArray addObject:assetInfo];
        }
        else
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_assetInfoArray.count - 1 inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
    }];
}

//设置按钮的状态
- (void)setButtonStatus:(int)count
{
    if (count > 0)
    {
        [_doneButton setTitleColor:LIGHT_GREEN_COLOR forState:UIControlStateNormal];
        [_doneButton setUserInteractionEnabled:YES];
        _countButotn.hidden = NO;
        [_countButotn setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
    }
    else
    {
        [_doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_doneButton setUserInteractionEnabled:NO];
        _countButotn.hidden = YES;
    }
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(photoViewControllerImagePickerSuccess:)])
    {
        [self.delegate photoViewControllerImagePickerSuccess:_selectedAssetsInfoArray];
    }
    
    [self back];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assetInfoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    JFAssetsInfo *assetsInfo = _assetInfoArray[indexPath.item];
    
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:assetsInfo.thumbNailImage]];
    [cell setSelectedBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"JFImagePicker.bundle/jf_overlay"]]];
    
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.view.bounds.size.width - 5 * kMargin) / 4, (self.view.bounds.size.width - 5 * kMargin) / 4);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMargin;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_selectedAssetsInfoArray)
    {
        _selectedAssetsInfoArray = [NSMutableArray arrayWithCapacity:10];
    }
    
    if (_selectedAssetsInfoArray.count >= _maxAmount)
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self showHUD:self.view mode:MBProgressHUDModeText text:[NSString stringWithFormat:@"最多可选%d张照片",_maxAmount]];
        [self hideHUD:1.5f];
    }
    else
    {
        JFAssetsInfo *assetInfo = _assetInfoArray[indexPath.item];
        
        if (!_queue)
        {
            _queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
        }
        
        dispatch_async(_queue, ^{
            
            if (!assetInfo.fullScreenImage)
            {
                UIImage *image = [UIImage imageWithCGImage:assetInfo.asset.defaultRepresentation.fullResolutionImage];
                assetInfo.fullScreenImage = image;
            }
            
            [_selectedAssetsInfoArray addObject:assetInfo.fullScreenImage];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setButtonStatus:(int)_selectedAssetsInfoArray.count];
            });
        });
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(_queue, ^{
        
        JFAssetsInfo *assetInfo = _assetInfoArray[indexPath.item];
        [_selectedAssetsInfoArray removeObject:assetInfo.fullScreenImage];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self setButtonStatus:(int)_selectedAssetsInfoArray.count];
        });
    });
}

#pragma mark HUD

- (void)showHUD:(UIView *)view mode:(MBProgressHUDMode)mode text:(NSString *)text
{
    _HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [_HUD setMode:mode];
    [_HUD setLabelText:text];
}

- (void)hideHUD:(CGFloat)delay
{
    [_HUD hide:YES afterDelay:delay];
}

@end

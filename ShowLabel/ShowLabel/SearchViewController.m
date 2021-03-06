//
//  SearchViewController.m
//  ShowLabel
//
//  Created by Yx on 15/6/15.
//  Copyright (c) 2015年 Yx. All rights reserved.
//  转屏时刷新table可以适配横竖屏
#import "SearchViewController.h"
#import "FirstTableViewCell.h"
#import "SecondTableViewCell.h"
#import "BUIControl.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface SearchViewController ()<UISearchControllerDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *iSearch;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *arrForSectionName;
@property (strong, nonatomic) NSMutableArray *arrForDataSource;
@property (strong, nonatomic) NSMutableArray *arrCopyDataSource;//保存搜索前数据
@property (strong, nonatomic) UINib *nNib;
@property (strong, nonatomic) UINib *SecondNib;
@property (strong, nonatomic) NSMutableArray *arrForBut;//记录创建的标签按钮
@property (assign, nonatomic) int profession;//记录换行数
@property (strong, nonatomic) NSArray *arrSearchHistory;//搜索历史
@property (strong, nonatomic) NSArray *arr;//热门搜索标签数组
@property (strong, nonatomic) NSArray *arr2;//历史搜索标签数组
@property (strong, nonatomic) NSString *searchStr;//用于搜索关键字
@end

@implementation SearchViewController
@synthesize arrForSectionName;
@synthesize arrForDataSource;
@synthesize arrCopyDataSource;
@synthesize profession;
@synthesize iSearch;
@synthesize arr;
@synthesize arr2;
@synthesize arrSearchHistory;

- (void)viewDidLoad {
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.view.bounds = CGRectMake(0,-20, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-20);
        //self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height-20);
    }
    arr = [[NSArray alloc] initWithObjects:@"酒店",@"机票",@"旅游",@"攻略",@"旅行wifi",@"签证",@"周末游",@"火车票",@"邮轮",@"天海邮轮",@"抢2000红包",@"顶级游",@"差旅",@"游古镇",@"暑假超优惠",@"首尔酒店",@"避暑",@"杭州",@"三亚", nil];
    arr2 = [[NSArray alloc] initWithObjects:@"我搜",@"我搜1",@"我搜2",@"我搜3",@"我搜4", nil];
    arrForSectionName = [[NSMutableArray alloc] initWithObjects:@"热门搜索",@"历史搜索",nil];
    arrForDataSource = [[NSMutableArray alloc] initWithObjects:arr,arr2, nil];
    self.arrForBut = [[NSMutableArray alloc] init];
    
    //转屏通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    self.mainTableView.frame = CGRectMake(0, 44, ScreenWidth, ScreenHeight-20-20-44);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0)
        [self.mainTableView reloadData];//ios7中table初始化时仅执行一次heightForRowAtIndexPath方法，导致后面计算的高度没有应用到cell上，引发按钮无法点击
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -UISearchBarDelegate

//开始搜索
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    searchBar.text = @"";
    return YES;
}
//结束编辑
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    
}
//点击取消搜索按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
//点击搜索按钮
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if (searchBar.text != nil || [searchBar.text isEqualToString:@""]|| ![searchBar.text isEqualToString:@"(null)"])
    {
        [self saveSearchHistory:searchBar.text];
    }
    self.searchStr = searchBar.text;
    [self prenSearchVC];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrForDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * arrDate = arrForDataSource[section];
    if (section == 0) {
        return 1;
    }else
    {
        return arrDate.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *firstCellID = @"FirstTableViewCell";
    if (!self.nNib)
    {
        self.nNib = [UINib nibWithNibName:firstCellID bundle:nil];
        [tableView registerNib:self.nNib forCellReuseIdentifier:firstCellID];
    }
    static  NSString *secondCellID = @"SecondTableViewCell";
    if (!self.SecondNib)
    {
        self.SecondNib = [UINib nibWithNibName:secondCellID bundle:nil];
        [tableView registerNib:self.SecondNib forCellReuseIdentifier:secondCellID];
    }
    
    
    if (indexPath.section == 0 ) {
        FirstTableViewCell *cell =(FirstTableViewCell*)[tableView dequeueReusableCellWithIdentifier:firstCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSArray *arrDate = arrForDataSource[indexPath.section];
        if (self.arrForBut.count != 0) {//修改因cell重用造成的按钮覆盖问题
            for (UIButton *but in self.arrForBut) {
                [but removeFromSuperview];
            }
            [self.arrForBut removeAllObjects];
        }
        profession = 0;
        for (int i = 1; i <= arrDate.count; i++)
        {
            UIButton *lateBut = self.arrForBut.lastObject;
            CGFloat lateButO = lateBut.frame.size.width + lateBut.frame.origin.x;
            NSString *text = [arrDate objectAtIndex:i-1];
            CGFloat butWidth = [self getLabelSizeWith:text].width;
            UIButton *butLabel =  [UIButton buttonWithType:UIButtonTypeCustom];
            [butLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [butLabel setTitle:text forState:UIControlStateNormal];
            [butLabel setBackgroundImage:[UIImage imageNamed:@"thrMenuBtn.png"] forState:UIControlStateNormal];
            [butLabel setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateHighlighted];
            if (lateButO + butWidth  > [[UIScreen mainScreen] bounds].size.width-50)
            {
                ++profession;//记录换行数
                butLabel.frame = CGRectMake(10 , 10 + 40*profession, butWidth+20, 30);
            }else
            {
                butLabel.frame = CGRectMake(10 + lateButO, 10 + 40*profession, butWidth+20, 30);
            }
            [butLabel handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender)
             {
                 UIButton *but = (UIButton *)sender;
                 self.searchStr = but.titleLabel.text;
                 NSLog(@"搜索：%@",self.searchStr);
                 [self saveSearchHistory:self.searchStr];
                 [self prenSearchVC];
             }];
            [self.arrForBut addObject:butLabel];
            [cell.viewBotton addSubview:butLabel];
        }
        cell.viewBotton.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40*(++profession) );
        return cell;
    }else
    {
        SecondTableViewCell *cell =(SecondTableViewCell*)[tableView dequeueReusableCellWithIdentifier:secondCellID];
        int row = indexPath.row;
        NSArray *arr = arrForDataSource[indexPath.section];
        cell.labName.text = arr[row];
        return cell;
    }
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        NSLog(@"hahah");
    }else
    {
        //tableView deleteSections:<#(NSIndexSet *)#> withRowAnimation:<#(UITableViewRowAnimation)#>
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:tableView.tableHeaderView.frame];
    customView.backgroundColor = [UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:0.3];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15];
    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 30);
    headerLabel.text =  self.arrForSectionName[section];
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ){
        return 40*(profession) +10;
    }
    else{
        return 44;
    }
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取字符串宽高
-(CGSize)getLabelSizeWith:(NSString *)text
{
    NSDictionary * extdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17.0], NSFontAttributeName,nil];
    CGSize explainlabelSize = CGSizeZero;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        explainlabelSize =[text boundingRectWithSize:CGSizeMake(203, 10000) options:NSStringDrawingUsesLineFragmentOrigin  attributes:extdic context:nil].size;
    }else
    {
        explainlabelSize = [text sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(203, 10000) lineBreakMode:NSLineBreakByCharWrapping];
    }
    return explainlabelSize;
}

//取消搜索历史
-(void)clearSearchHistory
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"SearchHistory"];
    [arrForDataSource removeAllObjects];
}

//获取搜索历史
-(void)getSearchHistory
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strCommonCity = [userDefaults valueForKey:@"SearchHistory"];
    arrSearchHistory = [[NSArray alloc]init];
    arrSearchHistory = [strCommonCity componentsSeparatedByString:@","];
}

//保存搜索历史
-(void)saveSearchHistory:(NSString *)strSearch
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strSearchHistory = [userDefaults valueForKey:@"SearchHistory"];
    NSArray *searchHistory = [[NSArray alloc]init];
    searchHistory = [strSearchHistory componentsSeparatedByString:@","];
    BOOL haveHotel = NO;
    for (NSString *strHistory in searchHistory) {
        if ([strSearch isEqualToString:strHistory]) {
            haveHotel = YES;
            break;
        }
    }
    if (!haveHotel) {
        if (strSearchHistory == nil || strSearchHistory == NULL || [strSearchHistory isEqualToString:@""]) {
            [userDefaults setValue:strSearch forKey:@"SearchHistory"];
        }else
        {
            NSString * strCityName = [strSearchHistory stringByAppendingFormat:@",%@",strSearch];
            [userDefaults setValue:strCityName forKey:@"SearchHistory"];
        }
        
        
    }
}
//跳转到搜索结果页
-(void)prenSearchVC
{
    /*
    SearchResultViewController *searchResultVC = [[SearchResultViewController alloc]init];
    searchResultVC.searchStr = self.searchStr;
    searchResultVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchResultVC animated:YES];
     */
}


- (void)statusBarDidChangeFrame:(NSNotification *)notification {
    [self.mainTableView reloadData];
}
@end
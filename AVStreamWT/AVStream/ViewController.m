//
//  ViewController.m
//  AVStream
//
//  Created by gaoshuang  on 2018/4/26.
//  Copyright © 2018年 gaoshuang . All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView* tableView;
@property (strong, nonatomic)NSArray* arrayData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    
//    https://blog.csdn.net/a411358606/article/details/52168452
    _arrayData = @[@"WT",@"GPUImage使用",@"LFLiveKit+WT",@"TGTGCamera+LFLiveKit",@"滤镜",@"萌颜",@"直播",@"FFmpeg",@"其它"];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arrayData.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* str = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
    }
    cell.textLabel.text = _arrayData[indexPath.section];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
//        [self pushCanvas:@"RecordVideoViewController" withComplete:nil];
        [self pushCanvas:@"WTRecordVideoViewController" withComplete:nil];

    }
    if (indexPath.section==1) {
        [self pushCanvas:@"RecordVideoViewController" withComplete:nil];
        
    }
     if (indexPath.section==2) {
           [self pushCanvas:@"LFLiveKitViewController" withComplete:nil];
           
       }
    if (indexPath.section==3) {
        
        [self pushCanvas:@"TGViewController" withComplete:nil];

    }
    if (indexPath.section == 4) {
        [self pushCanvas:@"FlitersViewController" withComplete:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

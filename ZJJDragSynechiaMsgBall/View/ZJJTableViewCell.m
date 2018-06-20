//
//  ZJJTableViewCell.m
//  ZJJDragSynechiaMsgBall
//
//  Created by 张锦江 on 2018/6/20.
//  Copyright © 2018年 xtayqria. All rights reserved.
//

#define  CELL_H  60.0f

#import "ZJJTableViewCell.h"
#import "ZJJDragBallView.h"
#import "Header.h"

@interface ZJJTableViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) ZJJDragBallView *ballView;

@end

@implementation ZJJTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
    }
    return self;
}

- (void)creatUI {
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.frame = CGRectMake(10, 5, CELL_H-10, CELL_H-10);
    self.headImageView.layer.cornerRadius = (CELL_H-10)/2;
    self.headImageView.clipsToBounds = YES;
    [self addSubview:self.headImageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.frame = CGRectMake(CELL_H+5, 5, 70, 20);
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16.0f];
    [self addSubview:self.nameLabel];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.frame = CGRectMake(CELL_H+5, 35, 250, 20);
    self.contentLabel.textColor = [UIColor grayColor];
    self.contentLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:self.contentLabel];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.frame = CGRectMake(SCREEN_WIDTH-50, 5, 40, 10);
    self.dateLabel.textColor = [UIColor lightGrayColor];
    self.dateLabel.font = [UIFont systemFontOfSize:11.0f];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.dateLabel];
    
    self.ballView = [[ZJJDragBallView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-40, (CELL_H-30)/2, 40, 40)];
    [self addSubview:self.ballView];
}

- (void)setDataDic:(NSDictionary *)dataDic {
    if (dataDic) {
        _dataDic = dataDic;
        self.headImageView.image = [UIImage imageNamed:_dataDic[@"img"]];
        self.nameLabel.text = _dataDic[@"name"];
        self.contentLabel.text = _dataDic[@"content"];
        self.dateLabel.text = _dataDic[@"date"];
        self.ballView.msgCount = [_dataDic[@"count"] intValue];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

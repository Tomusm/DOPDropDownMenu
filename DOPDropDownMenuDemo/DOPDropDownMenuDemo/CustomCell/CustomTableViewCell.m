//
//  CustomTableViewCell.m
//  DOPDropDownMenuDemo
//
//  Created by Tomusm on 22/12/2015.
//  Copyright © 2015 fengweizhou. All rights reserved.
//

#import "CustomTableViewCell.h"

@interface CustomTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTitle:(NSString *)title {
    [self.label setText:title];
}

@end

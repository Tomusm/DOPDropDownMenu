//
//  DOPDropDownMenu.h
//  DOPDropDownMenuDemo
//
//  Created by weizhou on 9/26/14.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DOPDirectionDown = 0,
    DOPDirectionUp = 1
} DOPDirection;

@interface DOPIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row;

@end

#pragma mark - data source protocol
@class DOPDropDownMenu;

@protocol DOPDropDownMenuDataSource <NSObject>

@required
- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column;
- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath;
@optional
//default value is 1
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu;

/**
 * If the cell returned is not nil, the tableView will display it.
 * Otherwise it will display the default cell
**/
- (UITableViewCell *)menu:(DOPDropDownMenu *)menu cellForRowAtIndexPath:(DOPIndexPath *)indexPath;
@end

#pragma mark - delegate
@protocol DOPDropDownMenuDelegate <NSObject>
@optional
- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath;
@end

#pragma mark - interface
@interface DOPDropDownMenu : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <DOPDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <DOPDropDownMenuDelegate> delegate;

@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, strong) UIImageView *customIndicatorView;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong, readonly) UITableView *tableView;

/**
 * Define the menu showing direction
 *
 * @default DOPDirectionDown
**/
@property (nonatomic, assign) DOPDirection menuDirection;

/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

- (instancetype)initWithFrame:(CGRect)frame;

- (NSString *)titleForRowAtIndexPath:(DOPIndexPath *)indexPath;

//programmatically dismiss
- (void)dismiss;

@end

//
//  CustomAutoCompleteCell.m
//  PPLKPR
//
//  Created by Lauren McCarthy on 8/26/14.
//  Copyright (c) 2014 Lauren McCarthy. All rights reserved.
//

#import "CustomAutoCompleteCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomAutoCompleteCell

- (id)init
{
    self = [super init];
    if (self) {     
        [self initialize];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {     
        [self initialize];
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {      
        [self initialize];
        
        // Helpers
        CGSize size = self.contentView.frame.size;
        
        // Initialize Main Label
        [self.textLabel setFrame:CGRectMake(8.0, 8.0, size.width - 16.0, size.height - 16.0)];
        
        // Configure Main Label
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        [self.textLabel setTextColor:[UIColor redColor]];
        [self.textLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        [self setBackgroundColor:[UIColor redColor]];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize
{
    [self setSelectedBackgroundView:[self redBackgroundView]];
}


- (UIView *)redBackgroundView
{
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [selectedBackgroundView setBackgroundColor:[UIColor redColor]];
    return selectedBackgroundView;
}

@end

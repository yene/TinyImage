//
//  ViewController.h
//  TinyImage
//
//  Created by Yannick Weiss on 06/01/15.
//  Copyright (c) 2015 Yannick Weiss. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
  NSMutableArray *images; // contains ImageModel
}
@property (weak) IBOutlet NSTableView *tableView;

@end


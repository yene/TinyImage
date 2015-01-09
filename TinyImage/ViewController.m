//
//  ViewController.m
//  TinyImage
//
//  Created by Yannick Weiss on 06/01/15.
//  Copyright (c) 2015 Yannick Weiss. All rights reserved.
//

#import "ViewController.h"
#import "ImageModel.h"

@implementation ViewController

- (void)viewDidLoad {
  images = [NSMutableArray array];
  myQueue = [[NSOperationQueue alloc] init];
  myQueue.name = @"Download Queue";
  myQueue.MaxConcurrentOperationCount = 3;
  
  [super viewDidLoad];

  // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}

- (IBAction)addImage:(id)sender {
  NSOpenPanel* openDialog = [NSOpenPanel openPanel];
  [openDialog setPrompt:@"Select Images"];
  [openDialog setAllowsMultipleSelection:YES];
  [openDialog setAllowedFileTypes:@[@"jpg", @"png"]];
  
  [openDialog beginWithCompletionHandler:^(NSInteger result){
    NSArray *files = [openDialog URLs];
    for (NSURL *url in files) {
     // add to model
      ImageModel *image = [[ImageModel alloc] init];
      image.URL = url;
      image.filename = [[url path] lastPathComponent];
      image.status = @"waiting...";
      [images addObject:image];
      
      NSInteger newRowIndex = [images count]-1;
      [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex] withAnimation:NSTableViewAnimationEffectGap];
      [self.tableView scrollRowToVisible:newRowIndex];
      
      __weak ViewController *weakSelf = self;
      [myQueue addOperationWithBlock:^{
        image.status = @"processing...";
        [weakSelf convertImage:image];
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
          [weakSelf.tableView reloadData];
        }];
      }];
      
    }
  }];
}

- (void)convertImage:(ImageModel *)image;
{
  NSData *imageData = [NSData dataWithContentsOfURL:image.URL];
  NSString *postLength = [NSString stringWithFormat:@"%lu", [imageData length]];
  
  // Init the URLRequest
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setHTTPMethod:@"POST"];
  [request setURL:[NSURL URLWithString:@"https://api.tinypng.com/shrink"]];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  
  NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"api", @""];
  NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
  NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
  [request setValue:authValue forHTTPHeaderField:@"Authorization"];
  [request setHTTPBody:imageData];
  
  NSURLResponse *response;
  NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
  
  NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
  NSInteger statusCode = [HTTPResponse statusCode];
  if (statusCode != 201) {
    // TODO it did fail, use documented error handling from https://tinypng.com/developers/reference
  }
  
  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:nil];
  
  NSString *inputSize = [results valueForKeyPath:@"input.size"];
  NSString *outputSize = [results valueForKeyPath:@"output.size"];
  NSString *ratio = [results valueForKeyPath:@"output.ratio"];
  NSString *location = [[HTTPResponse allHeaderFields] objectForKey:@"Location"];
  NSString *compressionCount = [[HTTPResponse allHeaderFields] objectForKey:@"Compression-Count"];
  image.status = location;
}

#pragma table data source
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  
  // Get a new ViewCell
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  
  // Since this is a single-column table view, this would not be necessary.
  // But it's a good practice to do it in order by remember it when a table is multicolumn.
  if( [tableColumn.identifier isEqualToString:@"ImageName"] ) {
    ImageModel *image = [images objectAtIndex:row];
    cellView.textField.stringValue = image.filename;
    return cellView;
  }
  if( [tableColumn.identifier isEqualToString:@"Status"] ) {
    ImageModel *image = [images objectAtIndex:row];
    cellView.textField.stringValue = image.status;
    return cellView;
  }
  
  
  return cellView;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [images count];
}

@end

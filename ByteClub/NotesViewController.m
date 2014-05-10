//
//  NotesViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "NotesViewController.h"
#import "DBFile.h"
#import "NoteDetailsViewController.h"
#import "Dropbox.h"
#import "NSArray+FunctionalExtension.h"
#import "NSURLSession+jbeslkfhslf.h"

@interface NotesViewController ()<NoteDetailsViewControllerDelegate>

@property (nonatomic, strong) NSArray *notes;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NotesViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPAdditionalHeaders = @{@"Authorization" : [Dropbox apiAuthorizationHeader]};
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self notesOnDropbox];
}

// list files found in the root dir of appFolder
- (void)notesOnDropbox
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [Dropbox appRootURL];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        NSLog(@"%@", dataDic);
        NSArray *filesAttributes = dataDic[@"contents"];
        filesAttributes = [filesAttributes ex_filter:^BOOL(id obj) {
            return ![obj[@"is_dir"] boolValue];
        }];
        filesAttributes = [filesAttributes ex_map:^id(id obj) {
            return [[DBFile alloc] initWithJSONData:obj];
        }];
        filesAttributes = [filesAttributes sortedArrayUsingSelector:@selector(compare:)];
        
        _notes = filesAttributes;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
    [task resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    DBFile *note = _notes[indexPath.row];
    cell.textLabel.text = [[note fileNameShowExtension:YES]lowercaseString];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = segue.destinationViewController;
    NoteDetailsViewController *showNote = (NoteDetailsViewController*) [navigationController viewControllers][0];
    showNote.delegate = self;
        
    // pass selected note to be edited //
    if ([segue.identifier isEqualToString:@"editNote"]) {
        DBFile *note =  _notes[[self.tableView indexPathForSelectedRow].row];
        showNote.note = note;
    }
    showNote.session = _session;
}

#pragma mark - NoteDetailsViewController Delegate methods

-(void)noteDetailsViewControllerDoneWithDetails:(NoteDetailsViewController *)controller
{
    // refresh to get latest
    [self dismissViewControllerAnimated:YES completion:nil];
    [self notesOnDropbox];
}

-(void)noteDetailsViewControllerDidCancel:(NoteDetailsViewController *)controller
{
    // just close modal vc
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

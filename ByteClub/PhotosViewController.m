//
//  PhotosViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoCell.h"
#import "Dropbox.h"
#import "DBFile.h"
#import "NSArray+FunctionalExtension.h"

@interface PhotosViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *uploadView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *photoThumbnails;


@property (nonatomic, strong) NSURLSession *session;



@end

@implementation PhotosViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"Authorization": [Dropbox apiAuthorizationHeader]}];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self refreshPhotos];
}

- (void)refreshPhotos
{
    NSURL *url = [Dropbox allPhotoURL];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *filesAttributes = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        filesAttributes = [filesAttributes ex_filter:^BOOL(id obj) {
            return [obj[@"thumb_exists"] boolValue];
        }];
        filesAttributes = [filesAttributes ex_map:^id(id obj) {
            return [[DBFile alloc] initWithJSONData:obj];
        }];
        filesAttributes = [filesAttributes sortedArrayUsingSelector:@selector(compare:)];
        
        self.photoThumbnails = filesAttributes;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [task resume];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDatasource and UITableViewDelegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_photoThumbnails count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DBFile *photo = _photoThumbnails[indexPath.row];
    
    if (!photo.thumbNail) {
        // only download if we are moving
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            if(photo.thumbExists) {
                NSString *urlString = [NSString stringWithFormat:@"https://api-content.dropbox.com/1/thumbnails/dropbox%@?size=xl",photo.path];
                NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:encodedUrl];
                NSLog(@"logging this url so no warning in starter project %@",url);
                
                [[self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    UIImage *img = [UIImage imageWithData:data];
                    NSData *data2 = UIImageJPEGRepresentation(img, 0.9);
                    img = [UIImage imageWithData:data2];
                    photo.thumbNail = img;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([indexPath isEqual:[tableView indexPathForCell:cell]]){
                            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
                        }
                    });
                }] resume];
            }
        }
    }
    
    cell.thumbnailImage.image = photo.thumbNail;
    return cell;
}

- (IBAction)choosePhoto:(UIBarButtonItem *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadImage:image];
}

// stop upload
- (IBAction)cancelUpload:(id)sender
{
    
}

- (void)uploadImage:(UIImage*)image
{
  
}


@end

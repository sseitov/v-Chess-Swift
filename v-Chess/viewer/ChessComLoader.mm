//
//  ChessComLoader.m
//  vChess
//
//  Created by Sergey Seitov on 12.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import "ChessComLoader.h"
#import "PGNImporter.h"
#import "StorageManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation ChessComLoader

@synthesize webView, delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    label.text = @"Download PGN Files";
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.pgnmentor.com/files.html"]]];
}
    
- (void)back {

	[webView goBack];
}
    
- (IBAction)cancel:(id)sender {
    if (doImport) {
        doImport = NO;
        [importStopped lockWhenCondition:ImportIsDone];
        [importStopped unlock];
    }
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    [SVProgressHUD dismiss];
	if ([theWebView canGoBack]) {
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(back)];
        backButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = backButton;
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSString* pathExt = request.URL.lastPathComponent.pathExtension;
    if ([pathExt isEqual:@"html"]) {
        return YES;
    } else if ([pathExt isEqual:@"pgn"] || [pathExt isEqual:@"zip"]) {
        bool isZip = [pathExt isEqual:@"zip"];
		NSString *package = [request.URL.lastPathComponent stringByDeletingPathExtension];
        NSString *text = [NSString stringWithFormat:@"Do you want to download %@?", package];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:text
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            
            [SVProgressHUD showProgress:0];
            [[StorageManager sharedStorageManager] removePackage:package];
            [self importZipPGN:request.URL name:package isZip:isZip progress:^(float progress){
                [SVProgressHUD showProgress:progress];
            } complete:^(int count){
                [SVProgressHUD dismiss];
                [self.delegate loaderDidFinish:count];
            }];
        }]];
        [self presentViewController:alert animated:true completion:nil];
		return NO;
    } else {
        return NO;
    }
}

#pragma mark - Import thread

- (void)importZipPGN:(NSURL*)url name:(NSString*)package isZip:(bool)isZip progress:(void (^)(float))progress complete:(void (^)(int))complete{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        self->doImport = YES;
        self->importStopped = [[NSConditionLock alloc] initWithCondition:ImportIsWorking];
        
        PGNImporter *importer = [PGNImporter sharedPGNImporter];
        
        NSMutableArray *catalog = [NSMutableArray array];
        int countGames = [importer fillImportCatalog:catalog fromURL:url isZip:isZip];
        if (countGames < 1) {
            complete(0);
        }
        
        float delta = 1.0 / (float)countGames;
        float currentProgress = 0;
        
        int success = 0;
        for (NSString *file in catalog) {
            NSString* gameText;
            if (isZip) {
                NSError *error = nil;
                gameText = [NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:&error];
                if (error) {
                    NSLog(@"ERROR: %@", [error localizedDescription]);
                    continue;
                }
            } else {
                gameText = [catalog objectAtIndex:0];
            }
            NSArray *elements = [gameText componentsSeparatedByString:@"\r\n\r\n"];
            if (!elements || elements.count < 2) {
                elements = [gameText componentsSeparatedByString:@"\n\n"];
            }
            if (!elements || elements.count < 2) {
                continue;
            }
            
            NSEnumerator *enumerator = [elements objectEnumerator];
            NSString *header;
            while (header = [enumerator nextObject]) {
                NSString *pgn = [enumerator nextObject];
                if (!pgn) {
                    break;
                }
                @autoreleasepool {
                    if ([importer appendGame:package header:header pgn:pgn]) {
                        success++;
                    };
                }
                
                currentProgress += delta;
                dispatch_async(dispatch_get_main_queue(), ^(){
                    progress(currentProgress);
                });
                
                if (!self->doImport) {
                    break;
                }
            }
            if (!self->doImport) {
                break;
            }
        }
        
        if (self->doImport) {
            self->doImport = NO;
        }
        [self->importStopped lock];
        [self->importStopped unlockWithCondition:ImportIsDone];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            complete(success);
        });
    });
}

@end

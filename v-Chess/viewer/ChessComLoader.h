//
//  ChessComLoader.h
//  vChess
//
//  Created by Sergey Seitov on 12.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChessComLoaderDelegate <NSObject>

- (void)loaderDidFinish:(int)count;

@end

enum {
	ImportIsWorking,
	ImportIsDone
};

@interface ChessComLoader : UIViewController <UIWebViewDelegate> {	
	BOOL doImport;
	NSConditionLock *importStopped;
}
    
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) id<ChessComLoaderDelegate> delegate;

@end

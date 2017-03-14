//
//  ChessEngine.m
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

#import "ChessEngine.h"
#import "Desk.h"
#import "FigureView.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface NSIndexSet (indexOfIndex)

- (NSUInteger)indexAtIndex:(NSUInteger)anIndex;

@end

@implementation NSIndexSet (indexOfIndex)

- (NSUInteger)indexAtIndex:(NSUInteger)anIndex
{
    if (anIndex >= [self count])
        return NSNotFound;
    
    NSUInteger index = [self firstIndex];
    for (NSUInteger i = 0; i < anIndex; i++)
        index = [self indexGreaterThanIndex:index];
    return index;
}

@end

@interface ChessEngine () <DeskDelegate> {
    vchess::Disposition _currentGame;
    vchess::Moves _moves;
    int _turnTime;
}

@property (strong, nonatomic, readonly) Desk* desk;
@property (strong, nonatomic) NSTimer *timer;

@property (readwrite, nonatomic) BOOL isDebut;
@property (readwrite, nonatomic) enum Depth depth;

@property (weak, nonatomic) UIView *deskView;
@property (weak, nonatomic) UISegmentedControl *timerView;

@end

@implementation ChessEngine

- (instancetype)initWithView:(UIView*)view forDepth:(Depth)depth timerView:(UISegmentedControl*)timerView
{
    self = [super init];
    if (self) {
        _desk = [[Desk alloc] initWithFrame:view.bounds];
        _depth = depth;
        _deskView = view;
        _timerView = timerView;
        [_deskView addSubview:_desk];
        
        srand((unsigned int)time(NULL));
        _desk.delegate = self;
        
        _timerView.enabled = NO;
        [_desk resetDisposition:_currentGame.state()];
    }
    return self;
}

- (void)rotateDesk:(bool)rotate
{
    [_desk startUpdate];
    [UIView animateWithDuration:0.2
                     animations:^{
                         _desk.frame = _deskView.bounds;
                     }
                     completion:^(BOOL finished){
                         if (_desk.rotated != rotate) {
                             [_desk rotate];
                         } else {
                             [_desk update];
                         }
                         [_desk endUpdate];
                     }
     ];
}

- (void)switchColor
{
    [_timer invalidate];
    if (_desk.activeColor) {
        [_timerView setTitle:@"00:00" forSegmentAtIndex:0];
    } else {
        [_timerView setTitle:@"00:00" forSegmentAtIndex:1];
    }
    _desk.activeColor = !_desk.activeColor;
    _turnTime = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

- (void)timerTick:(NSTimer *)timer
{
    _turnTime++;
    NSString *txt = [NSString stringWithFormat:@"%.2d:%.2d", _turnTime/60, _turnTime % 60];
    if (_desk.activeColor) {
        [_timerView setTitle:txt forSegmentAtIndex:1];
    } else {
        [_timerView setTitle:txt forSegmentAtIndex:0];
    }
}

- (void)logMove:(vchess::Move)move
{
#ifdef DO_LOG
    NSString* color = _desk.activeColor ? @"BLACK" : @"WHITE";
    if (move.moveType != vchess::NotMove) {
        NSLog(@"%@ %s", color, move.notation().c_str());
    } else {
        NSLog(@"Null move");
    }
#endif
}

- (bool)gameStarted
{
    return _timerView.enabled;
}

- (void)startGame:(bool)white
{
    _timerView.enabled = YES;
    
    _isDebut = YES;
#pragma mark - TODO insert code
//    [_whiteLostFigures clear];
//    [_blackLostFigures clear];
    _moves.clear();
    _currentGame.reset();
    [_desk resetDisposition:_currentGame.state()];
    
    _turnTime = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    if (!white) {	// первый ход от компьютера
        [self bestMove];
    } else {			// первый ход человека
        _desk.userInteractionEnabled = YES;
    }
}

- (void)stopGame
{
    _desk.userInteractionEnabled = NO;
    [_timer invalidate];
    _timer = nil;
    
    _timerView.enabled = NO;
    [_timerView setTitle:@"00:00" forSegmentAtIndex:0];
    [_timerView setTitle:@"00:00" forSegmentAtIndex:1];
}

- (void)surrender
{
    [self stopGame];
    [[NSNotificationCenter defaultCenter] postNotificationName:YouWinNotification object:nil];
}

#pragma mark - Desk delegate

- (void)didMakeMove:(vchess::Move)move
{
    [_desk makeMove:move inGame:&_currentGame completion:nil];
    _moves.push_back(move);
    [self logMove:move];
    _desk.userInteractionEnabled = NO;
    [self switchColor];
    [self bestMove];
    //	_desk.userInteractionEnabled = YES;
}

- (vchess::Moves)generateMovesForFigure:(FigureView*)figure
{
    return _currentGame.genMoves(vchess::COLOR(figure.model), figure.position);
}

- (void)killFigure:(FigureView*)f
{
    f.liveState = KILLED;
    [f removeFromSuperview];
    [_desk.figures removeObject:f];
    
#pragma mark - TODO insert code
/*
    if (vchess::COLOR(f.model)) {
        [_blackLostFigures addFigure:f];
    } else {
        [_whiteLostFigures addFigure:f];
    }
 */
}

- (void)aliveFigure:(FigureView*)f
{
#pragma mark - TODO insert code
/*
    if (vchess::COLOR(f.model)) {
        [_blackLostFigures removeFigure:f];
    } else {
        [_whiteLostFigures removeFigure:f];
    }
*/
    f.liveState = LIVING;
    f.frame = [_desk cellFrameForPosition:f.position];
    [_desk.figures addObject:f];
    [_desk addSubview:f];
}


#pragma mark - Chess brain

- (NSString*)gameText
{
    std::string text;
    for (int i=0; i<_moves.size(); i++) {
        text += (_moves[i].shortNotation() + " ");
    }
    return [NSString stringWithUTF8String:text.c_str()];
}

- (vchess::Move)searchFromBook
{
    NSString *text = [self gameText];
    NSArray* debutBook = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"debut_book" withExtension:@"plist"]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    if ([text isEqual:@""]) {
        [indexes addIndexesInRange:{0, debutBook.count}];
    } else {
        for (NSString *line in debutBook) {
            if ([line rangeOfString:text].location == 0 && line.length > text.length) {
                [indexes addIndex:[debutBook indexOfObject:line]];
            }
        }
    }
    if (indexes.count == 0) {
        return vchess::Move();
    }
    NSInteger index = rand() % indexes.count;
    NSArray *bookTurns = [[debutBook objectAtIndex:[indexes indexAtIndex:index]] componentsSeparatedByString:@" "];
    const char *turn = [[bookTurns objectAtIndex:_moves.size()] UTF8String];
    int x1 = turn[0] - 'a';
    int y1 = turn[1] - '1';
    int x2 = turn[2] - 'a';
    int y2 = turn[3] - '1';
    vchess::Position from(x1, y1);
    vchess::Position to(x2, y2);
    unsigned char fromFigure = _currentGame.state().cellAt(from);
    unsigned char toFigure = _currentGame.state().cellAt(to);
    if (toFigure) {
        vchess::Move m(vchess::FIGURE(fromFigure), from, to, vchess::Capture);
        m.capturePosition = to;
        m.captureFigure = toFigure;
        return m;
    } else {
        return vchess::Move(vchess::FIGURE(fromFigure),from, to, vchess::Normal);
    }
}

static vchess::Move best_move;
static int DEPTH;

int search(vchess::Disposition position, bool color, int depth, int alpha, int beta)
{
    if (depth == 0) return position.evaluate(color);
    
    vchess::Moves turns = position.genMoves(color, vchess::Position());
    
    std::vector<vchess::Move>::iterator it = turns.begin();
    
#pragma mark - TODO фильтр для чистки ошибочных ходов
    while (it != turns.end() && alpha < beta) {
        vchess::Move m = *it;
        bool moveColor = vchess::COLOR(position.state().cellAt(m.from));
        if (moveColor != color) {
            //			NSLog(@"error move %s", m.notation().c_str());
            it = turns.erase(it);
        } else {
            it++;
        }
    }
    
    it = turns.begin();
    while (it != turns.end() && alpha < beta) {
        vchess::Move m = *it;
        position.pushState();
        position.doMove(m);
        int tmp = -search(position, !color, depth-1, -beta, -alpha);
        position.popState();
        if (tmp > alpha) {
            alpha = tmp;
            if (depth == DEPTH) {
                best_move = m;
            }
        }
        it++;
    }
    return alpha;
}

- (void)bestMove
{
    [SVProgressHUD showWithStatus:@"Think..."];
    best_move = vchess::Move();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        if (_isDebut) {
            best_move = [self searchFromBook];
        }
        if (best_move.moveType == vchess::NotMove) {
            _isDebut = NO;
            best_move = vchess::Move();
            DEPTH = _depth;
            search(_currentGame, _desk.activeColor, DEPTH, -vchess::W_INFINITY, vchess::W_INFINITY);
        }
        [self logMove:best_move];
        dispatch_async(dispatch_get_main_queue(), ^()
                       {
                           [SVProgressHUD dismiss];
                           if (best_move.moveType != vchess::NotMove) {
                               [_desk makeMove:best_move
                                        inGame:&_currentGame
                                    completion:^(BOOL success)
                                {
                                    if (success) {
                                        _moves.push_back(best_move);
                                        [self switchColor];
                                        _desk.userInteractionEnabled = YES;
                                        //									   [self bestMove];
                                    } else {
                                        [self surrender];
                                    }
                                }];
                           } else {
                               [self surrender];
                           }
                       });
    });
}

@end

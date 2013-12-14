#import "BackgroundView.h"
#import "StatusItemView.h"
#import "Timer.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, TimerDelegate>
{
  BOOL _hasActivePanel;
  __unsafe_unretained BackgroundView *_backgroundView;
  __unsafe_unretained id<PanelControllerDelegate> _delegate;
  __unsafe_unretained NSSearchField *_searchField;
  __unsafe_unretained NSTextField *_textField;
  Timer *_timer;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (weak) IBOutlet NSButton *startButton;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (IBAction)startClicked:(id)sender;

@end

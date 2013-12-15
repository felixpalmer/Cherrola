#import "BackgroundView.h"
#import "Panel.h"
#import "StatusItemView.h"
#import "Timer.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, TimerDelegate, PanelDelegate>
{
  BOOL _hasActivePanel;
  __unsafe_unretained id<PanelControllerDelegate> _delegate;
  Timer *_timer;
}

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end

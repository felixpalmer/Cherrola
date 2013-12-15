#import "Timer.h"

@protocol PanelDelegate <NSObject>
- (void)startPressed:(id)sender;
- (void)cancelPressed:(id)sender;
@end

@interface Panel : NSPanel
@property (weak) id<PanelDelegate> panelDelegate;

@property (weak) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *cancelButton;

- (void)configureForState:(enum TIMERSTATE)state;
@end

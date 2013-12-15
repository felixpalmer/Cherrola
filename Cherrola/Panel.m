#import "Panel.h"

@implementation Panel

@synthesize panelDelegate;

- (IBAction)startPressed:(id)sender {
  [[self panelDelegate] startPressed:sender];
}

- (void)configureForState:(enum TIMERSTATE)state
{
  switch (state) {
    case OFF:
      [[[self message] cell] setTitle:@"Start Pomodoro"];
      [[self startButton] setEnabled:YES];
      break;
    case POMODORO:
      [[[self message] cell] setTitle:@"Pomodoro Running"];
      [[self startButton] setEnabled:NO];
      break;
    case POMODORO_ENDED:
      [[[self message] cell] setTitle:@"Pomodoro Ended"];
      [[self startButton] setEnabled:NO];
      break;
    case REST:
      [[[self message] cell] setTitle:@"Rest"];
      [[self startButton] setEnabled:NO];
      break;
    default:
      break;
  }
}

@end

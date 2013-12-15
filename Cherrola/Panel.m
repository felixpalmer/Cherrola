#import "Panel.h"

@implementation Panel

@synthesize panelDelegate;

- (IBAction)startPressed:(id)sender {
  [[self panelDelegate] startPressed:sender];
}

- (IBAction)cancelPressed:(id)sender {
  [[self panelDelegate] cancelPressed:sender];
}

- (void)configureForState:(enum TIMERSTATE)state
{
  NSLog(@"state %u", state);
  switch (state) {
    case OFF:
      [[[self message] cell] setTitle:@"Start Pomodoro"];
      [[self startButton] setEnabled:YES];
      [[self cancelButton] setEnabled:NO];
      break;
    case POMODORO:
      [[[self message] cell] setTitle:@"Pomodoro Running"];
      [[self startButton] setEnabled:NO];
      [[self cancelButton] setEnabled:YES];
      break;
    case POMODORO_ENDED:
      [[[self message] cell] setTitle:@"Pomodoro Ended"];
      [[self startButton] setEnabled:NO];
      [[self cancelButton] setEnabled:NO];
      break;
    case REST:
      [[[self message] cell] setTitle:@"Take a break"];
      [[self startButton] setEnabled:NO];
      [[self cancelButton] setEnabled:YES];
      break;
    default:
      break;
  }
}

@end

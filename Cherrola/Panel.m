#import "Panel.h"
#define FADE_DURATION 0.5
#define SLIDE_DISTANCE 10

@interface Panel() {
  NSDateFormatter *_formatter;
}

@end

@implementation Panel

@synthesize panelDelegate;

- (void)awakeFromNib {
  _formatter = [[NSDateFormatter alloc] init];
  [_formatter setDateFormat:@"mm:ss"];
}

- (IBAction)startPressed:(id)sender {
  [[self panelDelegate] startPressed:sender];
}

- (IBAction)cancelPressed:(id)sender {
  [[self panelDelegate] cancelPressed:sender];
}

- (void)configureForState:(enum TIMERSTATE)state
{
  NSLog(@"state %u", state);
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:FADE_DURATION];
  switch (state) {
    case OFF:
      if (![[self message] isHidden]) {
        NSRect frame = [[self message] frame];
        frame.origin.y -= SLIDE_DISTANCE;
        [[[self message] animator] setFrame:frame];
      }
      [[[self message] animator] setHidden:YES];
      [[[self startButton] animator] setEnabled:YES];
      [[[self startButton] animator] setHidden:NO];
      [[[self cancelButton] animator] setEnabled:NO];
      [[[self cancelButton] animator] setHidden:YES];
      break;
    case POMODORO:
      [[[self message] cell] setTitle:@"Time remaining"];
      if ([[self message] isHidden]) {
        NSRect frame = [[self message] frame];
        frame.origin.y += SLIDE_DISTANCE;
        [[[self message] animator] setFrame:frame];
      }
      [[[self message] animator] setHidden:NO];
      [[[self startButton] animator] setEnabled:NO];
      [[[self startButton] animator] setHidden:YES];
      [[[self cancelButton] animator] setEnabled:YES];
      [[[self cancelButton] animator] setHidden:NO];
      break;
    case POMODORO_ENDED:
      [[[self message] cell] setTitle:@"Ended"];
      if ([[self message] isHidden]) {
        NSRect frame = [[self message] frame];
        frame.origin.y += SLIDE_DISTANCE;
        [[[self message] animator] setFrame:frame];
      }
      [[[self message] animator] setHidden:NO];
      [[[self startButton] animator] setEnabled:NO];
      [[[self startButton] animator] setHidden:YES];
      [[[self cancelButton] animator] setEnabled:NO];
      [[[self cancelButton] animator] setHidden:YES];
      break;
    case REST:
      [[[self message] cell] setTitle:@"Take a break"];
      if ([[self message] isHidden]) {
        NSRect frame = [[self message] frame];
        frame.origin.y += SLIDE_DISTANCE;
        [[[self message] animator] setFrame:frame];
      }
      [[[self message] animator] setHidden:NO];
      [[[self startButton] animator] setEnabled:NO];
      [[[self startButton] animator] setHidden:YES];
      [[[self cancelButton] animator] setEnabled:NO];
      [[[self cancelButton] animator] setHidden:YES];
      break;
    default:
      break;
  }
  [NSAnimationContext endGrouping];
}

- (void)setTimeRemaining:(NSTimeInterval)remaining
{
  NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:remaining];
  [[[self countdown] cell] setTitle:[_formatter stringFromDate:date]];
}

@end

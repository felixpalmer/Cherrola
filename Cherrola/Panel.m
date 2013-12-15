#import "Panel.h"

@implementation Panel

@synthesize panelDelegate;

- (IBAction)startPressed:(id)sender {
  [[self panelDelegate] startPressed:sender];
}

@end

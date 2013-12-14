#import "Panel.h"

@implementation Panel

- (void)awakeFromNib
{

}

- (BOOL)canBecomeKeyWindow;
{
    return YES; // Allow Search field to become the first responder
}

@end

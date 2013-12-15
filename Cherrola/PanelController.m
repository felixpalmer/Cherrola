#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#define OPEN_DURATION .4
#define CLOSE_DURATION .1

#define POPUP_HEIGHT 500
#define PANEL_WIDTH 800
#define POPUP_PADDING 5

#define MENU_ANIMATION_DURATION .9

#pragma mark -

@implementation PanelController

@synthesize delegate = _delegate;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
  self = [super initWithWindowNibName:@"Panel"];
  if (self != nil)
  {
    _delegate = delegate;
    _timer = [[Timer alloc] initWithDelegate:self];
  }
  return self;
}

#pragma mark -

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  // Make a fully skinned panel
  Panel *panel = (Panel*)[self window];
  [panel setAcceptsMouseMovedEvents:YES];
  [panel setLevel:NSPopUpMenuWindowLevel];
  [panel setOpaque:NO];
  [panel setBackgroundColor:[NSColor clearColor]];
  [panel setPanelDelegate:self];
  
  // Resize panel
  NSRect panelRect = [[self window] frame];
  panelRect.size.height = POPUP_HEIGHT;
  [[self window] setFrame:panelRect display:NO];
  
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
  return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
  if (_hasActivePanel != flag)
  {
    _hasActivePanel = flag;
    
    if (_hasActivePanel)
    {
      [self openPanel];
    }
    else
    {
      [self closePanel];
    }
  }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
  self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
  if ([[self window] isVisible])
  {
    self.hasActivePanel = NO;
  }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
  self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
  NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
  NSRect statusRect = NSZeroRect;
  
  StatusItemView *statusItemView = nil;
  if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
  {
    statusItemView = [self.delegate statusItemViewForPanelController:self];
  }
  
  if (statusItemView)
  {
    statusRect = statusItemView.globalRect;
    statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
  }
  else
  {
    statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
    statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
    statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
  }
  return statusRect;
}

- (void)openPanel
{
  // Setup panel size
  Panel *panel = (Panel*)[self window];
  
  NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
  NSRect statusRect = [self statusRectForWindow:panel];
  
  NSRect panelRect = [panel frame];
  panelRect.size.width = screenRect.size.width - 2 * POPUP_PADDING;
  panelRect.size.height = screenRect.size.height - statusRect.size.height - 2 * POPUP_PADDING;
  panelRect.origin.x = POPUP_PADDING;
  panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect) - POPUP_PADDING;
  
  // Setup UI based on timer state
  [panel configureForState:[_timer state]];
  
  // Animate panel onto screen
  [NSApp activateIgnoringOtherApps:NO];
  [panel setAlphaValue:0];
  [panel setFrame:panelRect display:YES];
  [panel makeKeyAndOrderFront:nil];
  
  NSTimeInterval openDuration = OPEN_DURATION;
  
  NSEvent *currentEvent = [NSApp currentEvent];
  if ([currentEvent type] == NSLeftMouseDown)
  {
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
    if (shiftPressed || shiftOptionPressed)
    {
      openDuration *= 10;
      
      if (shiftOptionPressed)
        NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
              NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
    }
  }
  
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:openDuration];
  [[panel animator] setAlphaValue:1];
  [NSAnimationContext endGrouping];
}

- (void)closePanel
{
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
  [[[self window] animator] setAlphaValue:0];
  [NSAnimationContext endGrouping];
  
  dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
    
    [self.window orderOut:nil];
  });
}

- (void)startPressed:(id)sender
{
  [_timer startPomodoro];
  [self closePanel];
}

- (void)pomodoroEnded
{
  [self openPanel];
}

- (void)restEnded
{
  [self openPanel];
}

@end

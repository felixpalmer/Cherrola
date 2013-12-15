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
  
  // Configure panel
  _panel = (Panel*)[self window];
  [_panel setAcceptsMouseMovedEvents:YES];
  [_panel setLevel:NSPopUpMenuWindowLevel];
  [_panel setOpaque:NO];
  [_panel setBackgroundColor:[NSColor clearColor]];
  [_panel setPanelDelegate:self];
  [_panel setTimeRemaining:[_timer timeRemaining]];
  
  // Resize panel
  NSRect panelRect = [_panel frame];
  panelRect.size.height = POPUP_HEIGHT;
  [_panel setFrame:panelRect display:NO];
  
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
  [self setHasActivePanel:NO];
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
  if ([_panel isVisible])
  {
    [self setHasActivePanel:NO];
  }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
  [self setHasActivePanel:NO];
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
  [[_panel animator] setAlphaValue:1];
  [NSAnimationContext endGrouping];
}

- (void)closePanel
{
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
  [[_panel animator] setAlphaValue:0];
  [NSAnimationContext endGrouping];
  
  dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
    
    [self.window orderOut:nil];
  });
}

#pragma mark - PanelDelegate methods

- (void)startPressed:(id)sender
{
  [_timer startPomodoro];
  [_panel configureForState:[_timer state]];
  [self setHasActivePanel:NO];
}

- (void)cancelPressed:(id)sender
{
  if ([_timer state] == POMODORO) {
    [_timer cancelPomodoro];
  } else if ([_timer state] == REST) {
    [_timer cancelRest];
  }
  [_panel configureForState:[_timer state]];
}

#pragma mark - TimerDelegate methods

- (void)pomodoroEnded
{
  [_timer startRest];
  [_panel configureForState:[_timer state]];
  [self setHasActivePanel:YES];
}

- (void)restEnded
{
  [_panel configureForState:[_timer state]];
  [self setHasActivePanel:YES];
}

- (void)tick:(NSTimeInterval)remaining
{
  [_panel setTimeRemaining:remaining];
}

@end

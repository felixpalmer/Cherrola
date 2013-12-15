#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"

#define OPEN_DURATION .7
#define CLOSE_DELAY 1.337
#define CLOSE_DURATION .4

#define SLIDE_DISTANCE 10
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
  [[self panel] setAcceptsMouseMovedEvents:YES];
  [[self panel] setLevel:NSPopUpMenuWindowLevel];
  [[self panel] setOpaque:NO];
  [[self panel] setBackgroundColor:[NSColor clearColor]];
  [[self panel] setPanelDelegate:self];
  [[self panel] setTimeRemaining:[_timer timeRemaining]];
}

- (Panel*)panel
{
  return (Panel*)[self window];
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
  if ([[self panel] isVisible])
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
  [[self panel] configureForState:[_timer state]];
  
  // Resize panel
  NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
  NSRect statusRect = [self statusRectForWindow:[self panel]];
  NSRect panelRect = [[self panel] frame];
  panelRect.size.width = screenRect.size.width - 2 * POPUP_PADDING;
  panelRect.size.height = screenRect.size.height - statusRect.size.height - 2 * POPUP_PADDING;
  panelRect.origin.x = POPUP_PADDING;
  panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect) - POPUP_PADDING;

  // Animate panel onto screen
  panelRect.origin.y -= SLIDE_DISTANCE;
  [NSApp activateIgnoringOtherApps:NO];
  [[self panel] setFrame:panelRect display:YES];
  [[self panel] setAlphaValue:0];
  [[self panel] makeKeyAndOrderFront:nil];
  
  panelRect.origin.y += SLIDE_DISTANCE;
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:OPEN_DURATION];
  [[[self panel] animator] setAlphaValue:1];
  [[[self panel] animator] setFrame:panelRect display:YES];
  [NSAnimationContext endGrouping];
}

- (void)closePanel
{
  NSRect panelRect = [[self panel] frame];
  panelRect.origin.y -= SLIDE_DISTANCE;
  
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
  [[[self panel] animator] setAlphaValue:0];
  [[[self panel] animator] setFrame:panelRect display:YES];
  [NSAnimationContext endGrouping];
  
  dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
    [self.window orderOut:nil];
  });
}

#pragma mark - PanelDelegate methods

- (void)startPressed:(id)sender
{
  [_timer startPomodoro];
  [[self panel] configureForState:[_timer state]];
  dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DELAY), dispatch_get_main_queue(), ^{
    [self setHasActivePanel:NO];
  });
}

- (void)cancelPressed:(id)sender
{
  if ([_timer state] == POMODORO) {
    [_timer cancelPomodoro];
  } else if ([_timer state] == REST) {
    [_timer cancelRest];
  }
  [[self panel] configureForState:[_timer state]];
}

#pragma mark - TimerDelegate methods

- (void)pomodoroEnded
{
  [_timer startRest];
  [[self panel] configureForState:[_timer state]];
  [self setHasActivePanel:YES];
}

- (void)restEnded
{
  [[self panel] configureForState:[_timer state]];
  [self setHasActivePanel:YES];
}

- (void)tick:(NSTimeInterval)remaining
{
  [[self panel] setTimeRemaining:remaining];
}

@end

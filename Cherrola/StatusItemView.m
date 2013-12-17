#import "StatusItemView.h"
#import "Timer.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
  CGFloat itemWidth = [statusItem length];
  CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
  NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
  self = [super initWithFrame:itemRect];
  
  if (self != nil) {
    _statusItem = statusItem;
    [_statusItem setView:self];
  }
  return self;
}


#pragma mark - Drawing methods

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
  // Calculate angle of wedge from remaing time
  CGFloat angle = 2.0 * pi;
  CGFloat workBreakRatio = (float)POMODORO_DURATION / (float)(POMODORO_DURATION + REST_DURATION);
  if ([[Timer sharedInstance] state] == POMODORO) {
    CGFloat timeElapsed = (float)POMODORO_DURATION - [[Timer sharedInstance] timeRemaining];
    angle = 2.0 * pi * workBreakRatio * (timeElapsed / (float)POMODORO_DURATION);
  } else if ([[Timer sharedInstance] state] == REST) {
    CGFloat timeElapsed = (float)REST_DURATION - [[Timer sharedInstance] timeRemaining];
    angle = 2.0 * pi * (workBreakRatio + (1.0 - workBreakRatio) * (timeElapsed / (float)REST_DURATION));
  }

  // Draw outline circle
  [self drawArcWithRadius:7.5
                   center:CGPointMake(self.frame.size.width / 2, 12)
              highlighted:self.isHighlighted
                     fill:NO
                lineWidth:1.337
               startAngle:0
               sweepAngle:2 * pi * workBreakRatio];

  // Draw wedge
  [self drawArcWithRadius:5
                   center:CGPointMake(self.frame.size.width / 2, 12)
              highlighted:self.isHighlighted
                     fill:YES
                lineWidth:1.337
               startAngle:0
               sweepAngle:angle];
}

- (void)drawArcWithRadius:(CGFloat)radius
                   center:(CGPoint)center
              highlighted:(BOOL)highlighted
                     fill:(BOOL)fill
                lineWidth:(CGFloat)lineWidth
               startAngle:(float)startAngle
               sweepAngle:(float)sweepAngle
{
  NSColor *color = highlighted ? [NSColor whiteColor] : [NSColor blackColor];

  CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
  if (!highlighted) {
  CGContextSetShadowWithColor(ctx,
                              CGSizeMake(0, -1.0), 0,
                              CGColorCreateGenericGray(1.0, 0.7));
  }
  
  // Trace out path - measure angles from positive y axis
  if (fill) {
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddLineToPoint(ctx, center.x, center.y + radius);
  } else {
    CGContextMoveToPoint(ctx, center.x, center.y + radius);
  }
  CGContextAddArc(ctx, center.x , center.y, radius,
                  pi / 2 + startAngle, pi / 2 + startAngle - sweepAngle, 1);
  
  // Configure stroke and fill colors
  CGContextSetStrokeColorWithColor(ctx, [color CGColor]);
  CGContextSetFillColorWithColor(ctx, [color CGColor]);
  CGContextSetLineWidth(ctx, lineWidth);

  // Fill and stroke
  if (fill) {
    CGContextFillPath(ctx);
  }
  CGContextStrokePath(ctx);
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
  [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
  if (_isHighlighted == newFlag) return;
  _isHighlighted = newFlag;
  [self setNeedsDisplay:YES];
}

#pragma mark -

- (NSRect)globalRect
{
  NSRect frame = [self frame];
  frame.origin = [self.window convertBaseToScreen:frame.origin];
  return frame;
}

@end

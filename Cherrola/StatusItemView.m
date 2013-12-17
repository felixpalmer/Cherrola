#import "StatusItemView.h"

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
    _statusItem.view = self;
  }
  return self;
}


#pragma mark - Drawing methods

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
  NSColor *color = self.isHighlighted ? [NSColor whiteColor] : [NSColor blackColor];
  [self drawArcWithRadius:7
              color:[color CGColor]
                lineWidth:1.5
                    angle:1.5 * pi];
}

- (void)drawArcWithRadius:(CGFloat)radius
              color:(CGColorRef)color
                lineWidth:(CGFloat)lineWidth
                  angle:(float)angle
{
  CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
  CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
  
  // Trace out path
  CGContextMoveToPoint(ctx, center.x, center.y);
  CGContextAddLineToPoint(ctx, center.x, center.y + radius);
  CGContextAddArc(ctx, center.x , center.y, radius, pi/2, pi/2 - angle, 1);
  CGContextAddLineToPoint(ctx, center.x, center.y);
  
  // Configure stroke and fill colors
  CGContextSetStrokeColorWithColor(ctx, color);
  CGContextSetFillColorWithColor(ctx, color);
  CGContextSetLineWidth(ctx, lineWidth);

  // Fill and stroke
  //CGContextFillPath(ctx);
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

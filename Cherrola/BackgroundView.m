#import "BackgroundView.h"

#define FILL_OPACITY 0.9f
#define STROKE_OPACITY 1.0f

#define LINE_THICKNESS 2.0f
#define CORNER_RADIUS 10.0f

#pragma mark -

@implementation BackgroundView

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect contentRect = NSInsetRect([self bounds], LINE_THICKNESS, LINE_THICKNESS);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect))];
    
    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)
         controlPoint1:topRightCorner controlPoint2:topRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
    
    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))
         controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))];
    
    [path curveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
         controlPoint1:contentRect.origin controlPoint2:contentRect.origin];
    
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect))
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    //[path lineToPoint:NSMakePoint(_arrowX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path closePath];
    
    [[NSColor colorWithDeviceWhite:0.1 alpha:FILL_OPACITY] setFill];
    [path fill];
    
    [NSGraphicsContext saveGraphicsState];

    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [path setLineWidth:LINE_THICKNESS * 2];
    [[NSColor blackColor] setStroke];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end

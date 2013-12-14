//
//  Timer.m
//  Cherrola
//
//  Created by Felix Palmer on 12/14/13.
//
//

#import "Timer.h"

@implementation Timer

@synthesize delegate;

- (id)initWithDelegate:(id<TimerDelegate>)d
{
  if (self = [super init]) {
    [self setDelegate:d];
  }
  return self;
}

- (void)startPomodoro
{
  if (_timer) {
    [self cancelPomodoro];
  }
  _timer = [NSTimer scheduledTimerWithTimeInterval:POMODORO_DURATION
                                            target:[self delegate]
                                          selector:@selector(pomodoroEnded:)
                                          userInfo:nil
                                           repeats:NO];
}

- (void)cancelPomodoro
{
  [_timer invalidate];
  _timer = nil;
}

- (void)startBreak
{
  
}

- (void)cancelBreak
{
  [_timer invalidate];
  _timer = nil;
}


@end

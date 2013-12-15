//
//  Timer.m
//  Cherrola
//
//  Created by Felix Palmer on 12/14/13.
//
//

#import "Timer.h"

@interface Timer ()
@property (nonatomic, assign, readwrite) enum TIMERSTATE state;
@end

@implementation Timer

@synthesize delegate;
@synthesize state;

- (id)initWithDelegate:(id<TimerDelegate>)d
{
  if (self = [super init]) {
    [self setDelegate:d];
    [self setState:OFF];
  }
  return self;
}

- (void)startPomodoro
{
  if ([self state] != OFF) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot start Pomodoro, Timer in state %u", [self state]];
    return;
  }
  _timer = [NSTimer scheduledTimerWithTimeInterval:POMODORO_DURATION
                                            target:self
                                          selector:@selector(endPomodoro)
                                          userInfo:nil
                                           repeats:NO];
  [self setState:POMODORO];
}

- (void)endPomodoro
{
  if ([self state] != POMODORO) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot end Pomodoro, Timer in state %u", [self state]];
    return;
  }
  [_timer invalidate];
  [self setState:POMODORO_ENDED];
  [[self delegate] pomodoroEnded];
}

- (void)cancelPomodoro
{
  if ([self state] != POMODORO) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot cancel Pomodoro, Timer in state %u", [self state]];
    return;
  }
  [self setState:OFF];
  [_timer invalidate];
}

- (void)startRest
{
  if ([self state] != POMODORO_ENDED) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot start rest, Timer in state %u", [self state]];
    return;
  }
  _timer = [NSTimer scheduledTimerWithTimeInterval:REST_DURATION
                                            target:self
                                          selector:@selector(endRest)
                                          userInfo:nil
                                           repeats:NO];
  [self setState:REST];
}

- (void)endRest
{
  if ([self state] != REST) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot end rest, Timer in state %u", [self state]];
    return;
  }
  [_timer invalidate];
  [self setState:OFF];
  [[self delegate] restEnded];
}

- (void)cancelRest
{
  if ([self state] != REST) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot cancel rest, Timer in state %u", [self state]];
    return;
  }
  [self setState:OFF];
  [_timer invalidate];
}

@end

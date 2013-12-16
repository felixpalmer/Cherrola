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

static Timer *_sharedInstance;

+ (Timer*)sharedInstance
{
  if (_sharedInstance == nil) {
    _sharedInstance = [[Timer alloc] init];
  }
  return _sharedInstance;
}

- (id)init
{
  if (self = [super init]) {
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
  _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                            target:self
                                          selector:@selector(tick)
                                          userInfo:nil
                                           repeats:YES];

  [self setState:POMODORO];
}

- (void)endPomodoro
{
  if ([self state] != POMODORO) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot end Pomodoro, Timer in state %u", [self state]];
    return;
  }
  [_timer invalidate];
  [_tickTimer invalidate];
  [[self delegate] tick:0];
  [self setState:POMODORO_ENDED];
  [[self delegate] pomodoroEnded];
}

- (void)cancelPomodoro
{
  if ([self state] != POMODORO) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot cancel Pomodoro, Timer in state %u", [self state]];
    return;
  }
  [_timer invalidate];
  [_tickTimer invalidate];
  [[self delegate] tick:POMODORO_DURATION];
  [self setState:OFF];
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
  _tickTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(tick)
                                              userInfo:nil
                                               repeats:YES];
  [[self delegate] tick:REST_DURATION];
  [self setState:REST];
}

- (void)endRest
{
  if ([self state] != REST) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot end rest, Timer in state %u", [self state]];
    return;
  }
  [_timer invalidate];
  [_tickTimer invalidate];
  [[self delegate] tick:POMODORO_DURATION];
  [self setState:OFF];
  [[self delegate] restEnded];
}

- (void)cancelRest
{
  if ([self state] != REST) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot cancel rest, Timer in state %u", [self state]];
    return;
  }
  [_timer invalidate];
  [_tickTimer invalidate];
  [[self delegate] tick:POMODORO_DURATION];
  [self setState:OFF];
}

- (NSTimeInterval)timeRemaining
{
  if ([self state] == OFF) {
    return POMODORO_DURATION;
  } else {
    return [[_timer fireDate] timeIntervalSinceDate:[NSDate date]] + 0.5 ;
  }
}

- (void)tick
{
  [[self delegate] tick:[self timeRemaining]];
}

@end

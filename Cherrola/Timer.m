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

- (void)willSleepNotification:(NSNotification*) note;
- (void)willWakeNotification:(NSNotification*) note;

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

    // Register with system to be notified when system is put to/wakes from sleep
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(willSleepNotification:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(willWakeNotification:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
  }
  return self;
}

#pragma mark - Timer control methods

- (void)startPomodoro
{
  [self startPomodoro:POMODORO_DURATION];
}

- (void)startPomodoro:(NSTimeInterval)duration
{
  if ([self state] != OFF) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot start Pomodoro, Timer in state %u", [self state]];
    return;
  }
  _timer = [NSTimer scheduledTimerWithTimeInterval:duration
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
  [self startRest:REST_DURATION];
}

- (void)startRest:(NSTimeInterval)duration
{
  if ([self state] != POMODORO_ENDED) {
    [NSException raise:@"Invalid timer transition" format:@"Cannot start rest, Timer in state %u", [self state]];
    return;
  }
  _timer = [NSTimer scheduledTimerWithTimeInterval:duration
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

#pragma mark - Timer remaining methods
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

#pragma mark - Sleep notification methods
- (void)willSleepNotification:(NSNotification*) note
{
  if ([self state] == POMODORO) {
    // If we're in the middle of a timer session, just cancel it. It seems safe to assume the user
    // has given up on the session, and best not to confuse them when returning
    NSLog(@"Cancelling Pomodoro, as system is going to sleep");
    [self cancelPomodoro];
  }
}

- (void)willWakeNotification:(NSNotification*) note
{
  if ([self state] == REST) {
    // System was put to sleep during REST, need to reschedule timer as it was paused.
    // timeRemainging is still valid though, so use that to reschedule
    NSTimeInterval timeRemaining = [self timeRemaining];
    if (timeRemaining < 0) {
      // If rest is over, cancel the rest
      NSLog(@"Ending rest, as system woke up after end of break");
      [self endRest];
    } else {
      // Otherwise, restart the break, but with the remaining time only
      NSLog(@"Rescheduling rest, as system woke up before end of break");
      [self cancelRest];
      [self setState:POMODORO_ENDED];
      [self startRest:timeRemaining];
    }
  }
}

@end

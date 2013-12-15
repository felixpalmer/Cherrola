//
//  Timer.h
//  Cherrola
//
//  Created by Felix Palmer on 12/14/13.
//
//

#import <Foundation/Foundation.h>

#define POMODORO_DURATION 1500 // 25 minutes
#define REST_DURATION 600 // 5 minutes
//#define POMODORO_DURATION 15 // Testing 15 seconds
//#define REST_DURATION 10 // Testing 10 seconds

enum TIMERSTATE {
  OFF = 0,
  POMODORO = 1,
  POMODORO_PAUSED = 2,
  POMODORO_ENDED = 3,
  REST = 4,
  REST_PAUSED = 5
};

@protocol TimerDelegate <NSObject>

- (void)pomodoroEnded;
- (void)restEnded;
- (void)tick:(NSTimeInterval)remaining;

@end

@interface Timer : NSObject
{
  NSTimer *_timer;
  NSTimer *_tickTimer;
}

@property (nonatomic, weak) id<TimerDelegate> delegate;
@property (nonatomic, assign, readonly) enum TIMERSTATE state;

- (id)initWithDelegate:(id<TimerDelegate>)delegate;
- (NSTimeInterval)timeRemaining;

- (void)startPomodoro;
- (void)cancelPomodoro;
- (void)startRest;
- (void)cancelRest;

@end

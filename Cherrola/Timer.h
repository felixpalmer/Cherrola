//
//  Timer.h
//  Cherrola
//
//  Created by Felix Palmer on 12/14/13.
//
//

#import <Foundation/Foundation.h>
//#define POMODORO_DURATION 1500 // 25 minutes
#define POMODORO_DURATION 1 // 25 minutes
#define BREAK DURATION 300 // 5 minutes

@protocol TimerDelegate <NSObject>

- (void)pomodoroEnded:(NSTimer*)timer;
- (void)breakEnded:(NSTimer*)timer;

@end

@interface Timer : NSObject
{
  NSTimer *_timer;
}

@property (nonatomic, weak) id<TimerDelegate> delegate;

- (id)initWithDelegate:(id<TimerDelegate>)delegate;

- (void)startPomodoro;
- (void)cancelPomodoro;
- (void)startBreak;
- (void)cancelBreak;

@end

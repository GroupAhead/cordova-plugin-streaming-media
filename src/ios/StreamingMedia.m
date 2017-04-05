#import "StreamingMedia.h"
#import <Cordova/CDV.h>

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface StreamingMedia()
- (void)play:(CDVInvokedUrlCommand *) command type:(NSString *) type;
- (void)startPlayer:(NSString*)uri;
@end

@implementation StreamingMedia {
    NSString* callbackId;
    AVPlayerViewController *moviePlayer;
}

NSString * const TYPE_VIDEO = @"VIDEO";
NSString * const TYPE_AUDIO = @"AUDIO";

-(void)play:(CDVInvokedUrlCommand *) command type:(NSString *) type {
    callbackId = command.callbackId;
    NSString *mediaUrl  = [command.arguments objectAtIndex:0];
    [self startPlayer:mediaUrl];
}

-(void)pause:(CDVInvokedUrlCommand *) command type:(NSString *) type {
    callbackId = command.callbackId;
    if (moviePlayer) {
        [moviePlayer.player pause];
    }
}

-(void)resume:(CDVInvokedUrlCommand *) command type:(NSString *) type {
    callbackId = command.callbackId;
    if (moviePlayer) {
        [moviePlayer.player play];
    }
}

-(void)stop:(CDVInvokedUrlCommand *) command type:(NSString *) type {
    callbackId = command.callbackId;
    if (moviePlayer) {
        [moviePlayer.player setRate:0];
    }
}

-(void)playVideo:(CDVInvokedUrlCommand *) command {
    [self play:command type:[NSString stringWithString:TYPE_VIDEO]];
}

-(void)playAudio:(CDVInvokedUrlCommand *) command {
    [self play:command type:[NSString stringWithString:TYPE_AUDIO]];
}

-(void)pauseAudio:(CDVInvokedUrlCommand *) command {
    [self pause:command type:[NSString stringWithString:TYPE_AUDIO]];
}

-(void)resumeAudio:(CDVInvokedUrlCommand *) command {
    [self resume:command type:[NSString stringWithString:TYPE_AUDIO]];
}

-(void)stopAudio:(CDVInvokedUrlCommand *) command {
    [self stop:command type:[NSString stringWithString:TYPE_AUDIO]];
}

// Start the player
-(void)startPlayer:(NSString*)uri {
    NSURL *url = [NSURL URLWithString:uri];
    
    moviePlayer =  [AVPlayerViewController new];
    
    // Add the player to the ViewController
    AVPlayer *player = [AVPlayer playerWithURL:url];
    moviePlayer.player = player;
    
    // Add notification for when the video is done playing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:player.currentItem];

    [moviePlayer.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    // Show the player and start playing video immediately
    [moviePlayer.player play];
    moviePlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.viewController presentViewController:moviePlayer animated:YES completion:nil];
}

// When player is done playing, move seekbar to beginning and pause video
-(void)playerFinished:(NSNotification *)notification {
    [moviePlayer.player pause];
    [moviePlayer.player.currentItem seekToTime:kCMTimeZero];
}

@end

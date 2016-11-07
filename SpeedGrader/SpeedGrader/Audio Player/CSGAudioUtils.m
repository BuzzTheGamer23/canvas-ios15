//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CSGAudioUtils.h"

@implementation CSGAudioUtils

#pragma mark - Helper methods

+ (NSInteger)totalAudioTimeInSecondsForPlayer:(AVPlayer *)player
{
    NSInteger totalTime = 0;
    if (player) {
        double durationValue = player.currentItem.asset.duration.value;
        double durationTimescale = player.currentItem.asset.duration.timescale;
        totalTime = durationValue / durationTimescale;
    }
    return totalTime;
}

+ (double)currentPositionForTime:(CMTime)time Player:(AVPlayer *)player
{
    if (time.value == 0){
        time = player.currentItem.currentTime;
    }
    
    if (player) {
        double now = time.value / time.timescale;
        return now / [CSGAudioUtils totalAudioTimeInSecondsForPlayer:player];
    }
    return 0;
}

+ (CMTime)currentTimeForSliderWithPlayer:(AVPlayer *)player SeekBarValue:(float)seekValue
{
    if (player) {
        return CMTimeMake(seekValue * [CSGAudioUtils totalAudioTimeInSecondsForPlayer:player], 1);
    }
    
    return kCMTimeZero;
}

+ (NSString *)stringFormatForCMTime:(CMTime)time
{
    NSInteger seconds = CMTimeGetSeconds(time);
    
    return [self stringFormatForSeconds:seconds];
}

+ (NSString *)stringFormatForSeconds:(NSInteger)seconds
{
    NSString *emptyString = @"00:00";
    
    if (seconds <= 0) {
        return emptyString;
    }
    
    if (seconds < 60) {
        return [NSString stringWithFormat:@"00:%02ld",(long)seconds];
    }
    
    if (seconds < 3600) {
        int minutes = floor(seconds/60);
        int rseconds = trunc(seconds - minutes * 60);
        
        return [NSString stringWithFormat:@"%02d:%02d",minutes,rseconds];
    }
    
    if (seconds >= 3600) {
        int hours = floor(seconds/60);
        int minutes = floor(seconds/60);
        int rseconds = trunc(seconds - minutes * 60);
        
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,rseconds];
    }
    
    return emptyString;
}

+ (NSString *)verboseStringFormatForSeconds:(NSInteger)seconds
{
    NSString *secs = NSLocalizedString(@"secs", @"abbreviation for seconds");
    NSString *mins = NSLocalizedString(@"mins", @"abbreviation for minutes");
    NSString *hrs = NSLocalizedString(@"hrs", @"abbreviation for hours");
    NSString *remaining = NSLocalizedString(@"remaining", @"remaining");
    NSString *emptyString = [NSString stringWithFormat:@"00 %@ %@",secs, remaining];
    
    if (seconds <= 0) {
        return emptyString;
    }
    
    if (seconds < 60) {
        return [NSString stringWithFormat:@"%02ld %@ %@",(long)seconds, secs, remaining];
    }
    
    if (seconds < 3600) {
        int minutes = floor(seconds/60);
        int rseconds = trunc(seconds - minutes * 60);
        
        return [NSString stringWithFormat:@"%02d %@ %02d %@ %@",minutes, mins, rseconds, secs, remaining];
    }
    
    if (seconds >= 3600) {
        int hours = floor(seconds/60);
        int minutes = floor(seconds/60);
        int rseconds = trunc(seconds - minutes * 60);
        
        return [NSString stringWithFormat:@"%02d %@ %02d %@ %02d %@ %@",hours, hrs, minutes, mins, rseconds, secs, remaining];
    }
    
    return emptyString;
}

+ (NSString *)titleForFileWithPlayer:(AVPlayer *)player
{
    NSString *defaultTitle = NSLocalizedString(@"Audio File Submission", @"The default title for an audio file submission");
    if (player.currentItem) {
        NSArray *metadataList = [player.currentItem.asset commonMetadata];
        for (AVMetadataItem *metaItem in metadataList) {
            if ([[metaItem commonKey] isEqualToString:@"title"]) {
                defaultTitle = [[metaItem value] description];
            }
        }
    }
    
    return defaultTitle;
}

@end

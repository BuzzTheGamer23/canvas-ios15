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

#import "CSGFlyingPandaAnimationView.h"

@interface CSGFlyingPandaAnimationView ()

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) NSInteger maxOnscreenClouds;
@property (nonatomic, strong) CADisplayLink *cloudDisplayLink;
@property (nonatomic, assign) CFTimeInterval currentFrameTimestamp;
@property (nonatomic, assign) CFTimeInterval nextCloudTimestamp;
@property (nonatomic, strong) NSArray *cloudImages;

@end

@implementation CSGFlyingPandaAnimationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeAnimationView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeAnimationView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeAnimationView];
    }
    return self;
}

- (void)initializeAnimationView
{
    _flyingPandaImageView = [[UIImageView alloc] init];
    _flyingPandaImageView.animationImages = @[[UIImage imageNamed:@"panda_1"], [UIImage imageNamed:@"panda_2"], [UIImage imageNamed:@"panda_3"], [UIImage imageNamed:@"panda_4"], [UIImage imageNamed:@"panda_5"]];
    _flyingPandaImageView.animationDuration = kFlyingPandaAnimationImageCount / 14.0;
    _flyingPandaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_flyingPandaImageView];

    _cloudImages = @[[UIImage imageNamed:@"cloud_1"], [UIImage imageNamed:@"cloud_2"], [UIImage imageNamed:@"cloud_3"], [UIImage imageNamed:@"cloud_4"], [UIImage imageNamed:@"cloud_5"]];

    _onscreenClouds = [NSMutableArray array];

    srand48(time(0));
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat cloudToSkyRatio = 0.33f;// 1/3rd of the screen should be filled, potentially overlapping though, of clouds
    CGFloat skyArea = self.bounds.size.width * self.bounds.size.height;
    CGFloat avgCloudArea = 80.0f * 60.0f; // the average size of a cloud;
    self.maxOnscreenClouds = skyArea / avgCloudArea * cloudToSkyRatio;
}

- (void)startAnimating
{
    [self.flyingPandaImageView startAnimating];
    self.cloudDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateClouds)];
    [self.cloudDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    self.isAnimating = YES;
}

- (void)stopAnimating
{
    [self.flyingPandaImageView.layer removeAllAnimations];
    [self.cloudDisplayLink invalidate];
    self.cloudDisplayLink = nil;
    for (UIImageView *onscreenCloud in self.onscreenClouds) {
        [onscreenCloud removeFromSuperview];
    }
    [self.onscreenClouds removeAllObjects];

    self.isAnimating = NO;
}


#pragma mark - Private methods

- (void)updateClouds
{
    CFTimeInterval currentTime = self.cloudDisplayLink.timestamp;
    self.currentFrameTimestamp = currentTime;

    if (self.onscreenClouds.count == 0) {
        self.nextCloudTimestamp = self.currentFrameTimestamp;
    }

    if (self.currentFrameTimestamp >= self.nextCloudTimestamp && self.isAnimating) {
        UIImage *cloudImage = [self randomCloudImage];
        UIImageView *cloudImageView = [[UIImageView alloc] initWithImage:cloudImage];
        cloudImageView.frame = CGRectMake(self.bounds.size.width, [self randomCloudYValueForImage:cloudImage viewHeight:self.bounds.size.height], cloudImage.size.width, cloudImage.size.height);
        [self insertSubview:cloudImageView belowSubview:self.flyingPandaImageView];
        [self.onscreenClouds addObject:cloudImageView];

        [UIView animateWithDuration:[self randomCloudTravelTime] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect destinationRect = cloudImageView.frame;
            destinationRect.origin.x = 0 - cloudImage.size.width;
            cloudImageView.frame = destinationRect;
        } completion:^(BOOL finished) {
            [self.onscreenClouds removeObject:cloudImageView];
            [cloudImageView removeFromSuperview];
        }];

        self.nextCloudTimestamp = [self nextCloudAppearanceTime];
    }
}

- (UIImage *)randomCloudImage
{
    NSInteger random = arc4random_uniform(kCloudAnimationImageCount);
    UIImage *cloudImage = self.cloudImages[random];
    return cloudImage;
}

- (CGFloat)randomCloudYValueForImage:(UIImage *)cloudImage viewHeight:(CGFloat)viewHeight
{
    CGFloat randomY = arc4random_uniform(viewHeight - cloudImage.size.height);
    return randomY;
}

- (CFTimeInterval)nextCloudAppearanceTime
{
    double random = drand48() * 2; // 0-2 seconds spacing
    CFTimeInterval nextAppearance = self.currentFrameTimestamp + random;
    return nextAppearance;
}

- (NSTimeInterval)randomCloudTravelTime
{
    NSInteger ptsPerSec = arc4random_uniform(40) + 120; // 120-159 is the range for pts per second
    double time = self.bounds.size.width / ptsPerSec;
    return time;
}

@end

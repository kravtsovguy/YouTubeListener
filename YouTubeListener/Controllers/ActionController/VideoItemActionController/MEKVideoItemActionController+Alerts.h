//
//  MEKVideoItemActionController+Alerts.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionController.h"
#import "MEKAlertController.h"

@interface MEKVideoItemActionController (Alerts)

- (void)showActionDialog:(VideoItemMO *)item;
- (void)showDownloadQualityDialog:(VideoItemMO *)item;
- (void)showPlayQualityDialog:(VideoItemMO *)item withCurrentQuality:(VideoItemQuality)currentQuality;

@end

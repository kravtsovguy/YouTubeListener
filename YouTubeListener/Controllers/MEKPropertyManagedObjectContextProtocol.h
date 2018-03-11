//
//  MEKPropertyManagedObjectContextProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol MEKPropertyManagedObjectContextProtocol

@property (nonatomic, strong, readonly) NSManagedObjectContext *coreDataContext;

@end

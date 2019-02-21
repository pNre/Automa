#import <Automa.h>
#import <AppList/AppList.h>

#import <NAAlert.h>

#import "AutomaAlertsTableViewManager.h"

@implementation AutomaAlertsTableViewManager {
    NSMutableArray * _blockedAlerts;
    NSMutableArray * _iconsToLoad;
    OSSpinLock _spinLock;
}

- (void)loadIconsFromBackground
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    OSSpinLockLock(&_spinLock);
    ALApplicationList * appList = [ALApplicationList sharedApplicationList];
    while ([_iconsToLoad count]) {
        NSString * bundleID = [[_iconsToLoad objectAtIndex:0] retain];
        [_iconsToLoad removeObjectAtIndex:0];
        OSSpinLockUnlock(&_spinLock);
        CGImageRelease([appList copyIconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:bundleID]);
        [bundleID release];
        [pool drain];
        pool = [[NSAutoreleasePool alloc] init];
        OSSpinLockLock(&_spinLock);
    }
    OSSpinLockUnlock(&_spinLock);
    PNLog(@"Load done");
    [pool drain];
}

- (id)init {
    self = [super init];

    if (self) {
        NSDictionary * _settingsPlist = [NSDictionary dictionaryWithContentsOfFile:kAlertsFile];
        NSArray * blockedAlertsEntries = [_settingsPlist objectForKey:kBlockedAlerts];

        _iconsToLoad = [[NSMutableArray alloc] init];

        if (blockedAlertsEntries) {
            _blockedAlerts = [[NSMutableArray alloc] initWithCapacity:BlockingModesCount];

            for (NSUInteger i = 0; i < BlockingModesCount; i++)
                [_blockedAlerts addObject:[NSMutableArray array]];

            for (NSDictionary * entry in blockedAlertsEntries) {
                NAAlert * alert = [[[%c(NAAlert) alloc] initWithDictionaryRepresentation:entry] autorelease];

                if (!alert.bundleID)
                    continue;

                [_blockedAlerts[alert.blockingMode] addObject:alert];
            }
        }
    }

    return self;
}

- (void)dealloc
{
    if (_blockedAlerts)
        [_blockedAlerts release];

    if (_iconsToLoad)
        [_iconsToLoad release];

    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return BlockingModesCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blockedAlerts ? [[_blockedAlerts objectAtIndex:section] count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AlertEntryCell"];

    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AlertEntryCell"] autorelease];

    NAAlert * alert = [_blockedAlerts objectAtIndex:indexPath.section][indexPath.row];

    if (alert.message || alert.title) {
        NSString * message = alert.message ? [NSString stringWithFormat:@"%@\n%@", alert.title, alert.message] : alert.title;
        NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", message, alert.actionTitle]];
        [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:cell.detailTextLabel.font.pointSize] range:NSMakeRange(0, message.length)];
        [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:cell.detailTextLabel.font.pointSize] range:NSMakeRange(message.length, alert.actionTitle.length + 1)];
        cell.detailTextLabel.attributedText = text;
        [text release];
    } else {
        NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:alert.actionTitle];
        [text addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:cell.detailTextLabel.font.pointSize] range:NSMakeRange(0, text.length)];
        cell.detailTextLabel.attributedText = text;
        [text release];
    }

    //cell.detailTextLabel.font = [UIFont systemFontOfSize:cell.detailTextLabel.font.pointSize];
    cell.detailTextLabel.numberOfLines = 4;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;

    if ([alert.bundleID isEqualToString:@"*"] ||
        [alert.bundleID caseInsensitiveCompare:@"com.apple.springboard"] == NSOrderedSame) {
        //cell.textLabel.text = @"Any";

        NSBundle * bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AutomaPrefs.bundle"];
        cell.imageView.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"Automa" ofType:@"png"]];
    } else {
        cell.textLabel.text = [[ALApplicationList sharedApplicationList] valueForKey:@"displayName" forDisplayIdentifier:alert.bundleID];

        ALApplicationList * appList = [ALApplicationList sharedApplicationList];
        if ([appList hasCachedIconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:alert.bundleID]) {
            cell.imageView.image = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:alert.bundleID];
        } else {
            OSSpinLockLock(&_spinLock);
            [_iconsToLoad insertObject:alert.bundleID atIndex:0];
            [self performSelectorInBackground:@selector(loadIconsFromBackground) withObject:nil];
            OSSpinLockUnlock(&_spinLock);
        }
    }

    return cell;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"Blocked" : @"Presented as banner";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (tableView.editing) {
        return nil;
    }

    if (!_blockedAlerts || _blockedAlerts.count <= section || [[_blockedAlerts objectAtIndex:section] count] == 0) {
        return @"Long press an alert message to start using Automa";
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 88.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_blockedAlerts[indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        if (!tableView.editing)
            [self save];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == destinationIndexPath.section)
        return;

    NSMutableArray * from = _blockedAlerts[sourceIndexPath.section];
    NSMutableArray * to = _blockedAlerts[destinationIndexPath.section];

    NAAlert * alert = [from[sourceIndexPath.row] retain];
    [from removeObjectAtIndex:sourceIndexPath.row];

    alert.blockingMode = destinationIndexPath.section;

    [to addObject:alert];

    [alert release];

}

- (void)save {
    NSMutableDictionary * _settingsPlist = [NSMutableDictionary dictionaryWithContentsOfFile:kAlertsFile];

    if (_settingsPlist) {
        NSMutableArray * blocked = [NSMutableArray array];

        for (NSArray * entries in _blockedAlerts)
            for (NAAlert * alert in entries) {
                [blocked addObject:[alert dictionaryRepresentation]];
            }

        _settingsPlist[kBlockedAlerts] = blocked;
        [_settingsPlist writeToFile:kAlertsFile atomically:YES];

        PNLog(@"%@", _settingsPlist);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("co.pNre.automa/settingsupdated"), NULL, NULL, YES);

    }
}

@end

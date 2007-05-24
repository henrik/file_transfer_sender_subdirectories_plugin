//
//  FileTransferSenderSubdirectoriesPlugin
//
//  By Henrik Nyh, 2007-05-24.
//  Free to modify and redistribute with due credit.
//

#import "FileTransferSenderSubdirectoriesPlugin.h"
#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/ESFileTransfer.h>
#import <AIUtilities/AIFileManagerAdditions.h>
#import <AIUtilities/AIStringAdditions.h>

@implementation FileTransferSenderSubdirectoriesPlugin

- (NSString *)pluginAuthor {
	return @"Henrik Nyh";
}
- (NSString *)pluginURL {
	return @"http://henrik.nyh.se/";
}
- (NSString *)pluginVersion {
	return @"1.0";
}
- (NSString *)pluginDescription {
	return @"Puts incoming files in per-sender subdirectories of the default directory.";
}


- (void)installPlugin {

	NSLog(@"FileTransferSenderSubdirectoriesPlugin loaded!");
	[[adium notificationCenter] addObserver:self
	                               selector:@selector(transferStarted:)
	                                   name:FILE_TRANSFER_BEGAN
	                                 object:nil];
}


- (void)uninstallPlugin {

	[[adium notificationCenter] removeObserver:self];
	NSLog(@"FileTransferSenderSubdirectoriesPlugin unloaded!");
}


- (void)transferStarted:(NSNotification *)notification {

	ESFileTransfer *transfer = (ESFileTransfer *)[notification userInfo];
	
	// Determine the name for the user directory: "Display Name (User ID)" or "User ID"
	NSString *displayName = [[transfer contact] displayName];
	NSString *fUID = [[transfer contact] formattedUID];
	NSString *userDirectoryName = [NSString stringWithFormat: (displayName ? @"%@ (%@)" : @"%@%@"), displayName, fUID];

	// Replace "/" with "-" and abbreviate long names
	userDirectoryName = [userDirectoryName safeFilenameString];

	// Figure out where this file is destined
	NSString *destinationPath = [transfer localFilename];
	NSString *destinationDirectory = [destinationPath stringByDeletingLastPathComponent];

	// Use the remote filename, since the local filename may have been uniqued ("foo.jpg" becomes "foo-1.jpg") based on the contents of the default download directory rather than the user directory
	NSString *destinationFile = [transfer remoteFilename];
	
	// Bail if the file is not destined for the default download directory (i.e. the user was prompted and chose someplace else)
	NSString *defaultDirectory = [[adium preferenceController] userPreferredDownloadFolder];
	if (![destinationDirectory isEqualToString:defaultDirectory]) return;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// Find existing user directory, if any: the UID should be identical, though the display name may vary
	NSString *fileOrDir;
	NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:defaultDirectory];
	while (fileOrDir = [dirEnumerator nextObject]) {
		BOOL sameUID = [fileOrDir isEqualToString:fUID] || [fileOrDir hasSuffix:[NSString stringWithFormat:@" (%@)", fUID]];
		BOOL isDirectory; [fileManager fileExistsAtPath:[defaultDirectory stringByAppendingPathComponent:fileOrDir] isDirectory:&isDirectory];
		if (sameUID && isDirectory) {
			userDirectoryName = fileOrDir;
			break;
		}
	}
	
	// Create user directory if necessary
	NSString *userDirectory = [defaultDirectory stringByAppendingPathComponent:userDirectoryName];
	if (![fileManager fileExistsAtPath:userDirectory]) {
		[fileManager createDirectoryAtPath:userDirectory attributes:nil];
	}

	// Change destination filename
	NSString *userPath = [fileManager uniquePathForPath:[userDirectory stringByAppendingPathComponent:destinationFile]];
	[transfer setLocalFilename:userPath];
}

@end

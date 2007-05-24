//
//  FileTransferFoldersPerSenderPlugin
//
//  By Henrik Nyh, 2007-05-24.
//  Free to modify and redistribute with due credit.
//

#import "FileTransferFoldersPerSenderPlugin.h"
#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/ESFileTransfer.h>
#import <AIUtilities/AIFileManagerAdditions.h>
#import <AIUtilities/AIStringAdditions.h>

@implementation FileTransferFoldersPerSenderPlugin

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
	return @"Puts incoming files in per-sender subdirectories of the download folder.";
}


- (void)installPlugin {

	NSLog(@"FileTransferFoldersPerSenderPlugin loaded!");
	[[adium notificationCenter] addObserver:self
	                               selector:@selector(transferStarted:)
	                                   name:FILE_TRANSFER_BEGAN
	                                 object:nil];
}


- (void)uninstallPlugin {

	[[adium notificationCenter] removeObserver:self];
	NSLog(@"FileTransferFoldersPerSenderPlugin unloaded!");
}


- (void)transferStarted:(NSNotification *)notification {

	ESFileTransfer *transfer = (ESFileTransfer *)[notification userInfo];
	
	// Determine the name for the user folder: "Display Name (User ID)" or "User ID"
	NSString *displayName = [[transfer contact] displayName];
	NSString *fUID = [[transfer contact] formattedUID];
	NSString *userFolderName = [NSString stringWithFormat: (displayName ? @"%@ (%@)" : @"%@%@"), displayName, fUID];

	// Replace "/" with "-" and abbreviate long names
	userFolderName = [userFolderName safeFilenameString];

	// Figure out where this file is destined
	NSString *destinationPath = [transfer localFilename];
	NSString *destinationFolder = [destinationPath stringByDeletingLastPathComponent];

	// Use the remote filename, since the local filename may have been uniqued ("foo.jpg" becomes "foo-1.jpg") based on the contents of the default download folder rather than the user folder
	NSString *destinationFile = [transfer remoteFilename];
	
	// Bail if the file is not destined for the default download folder (i.e. the user was prompted and chose someplace else)
	NSString *defaultFolder = [[adium preferenceController] userPreferredDownloadFolder];
	if (![destinationFolder isEqualToString:defaultFolder]) return;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// Find existing user folder, if any: the UID should be identical, though the display name may vary
	NSString *file;
	NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:defaultFolder];
	while (file = [dirEnum nextObject]) {
		if ([file isEqualToString:fUID] || [file hasSuffix:[NSString stringWithFormat:@" (%@)", fUID]]) {
			userFolderName = file;
			break;
		}
	}

	// Create user folder if necessary
	NSString *userFolder = [defaultFolder stringByAppendingPathComponent:userFolderName];
	if (![fileManager fileExistsAtPath:userFolder]) {
		[fileManager createDirectoryAtPath:userFolder attributes:nil];
	}

	// Change destination filename
	NSString *userPath = [fileManager uniquePathForPath:[userFolder stringByAppendingPathComponent:destinationFile]];
	[transfer setLocalFilename:userPath];
}

@end

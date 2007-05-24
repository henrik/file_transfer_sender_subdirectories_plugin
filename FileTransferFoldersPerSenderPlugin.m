//
//  FileTransferFoldersPerSenderPlugin.m
//  FileTransferFoldersPerSenderPlugin
//
//  By Henrik Nyh, 2007-05-24.
//  Free to modify and redistribute with due credit.
//

#import "FileTransferFoldersPerSenderPlugin.h"
#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/AIFileTransferControllerProtocol.h>
#import <AIUtilities/AIFileManagerAdditions.h>

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
	return @"TODO.";
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
	
	NSString *displayName = [[transfer contact] displayName];
	NSString *fUID = [[transfer contact] formattedUID];
	NSString *userFolderName = [NSString stringWithFormat: (displayName ? @"%@ (%@)" : @"%@%@"), displayName, fUID];

	NSString *destinationPath = [transfer localFilename];
	NSString *destinationFolder = [destinationPath stringByDeletingLastPathComponent];
	NSString *destinationFile = [destinationPath lastPathComponent];
	
	NSString *defaultFolder = [[adium preferenceController] userPreferredDownloadFolder];
	
	// FIXME: Will rename foo.jpg to foo-1.jpg if default dir contains foo.jpg, even if user dir doesn't
	
	// Only move it if it would have gone into the default folder
	if ([destinationFolder isEqualToString:defaultFolder]) {
	
		NSString *userFolder = [defaultFolder stringByAppendingPathComponent:userFolderName];
		NSString *userPath = [[NSFileManager defaultManager] uniquePathForPath:[userFolder stringByAppendingPathComponent:destinationFile]];
	
		// Create userFolder if necessary
		if (![[NSFileManager defaultManager] fileExistsAtPath:userFolder]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:userFolder attributes:nil];
		}

		// Change destination filename
		[transfer setLocalFilename:userPath];
	}

}

@end

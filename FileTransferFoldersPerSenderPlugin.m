//
//  FileTransferFoldersPerSenderPlugin.m
//  FileTransferFoldersPerSenderPlugin
//
//  By Henrik Nyh, 2007-05-24.
//  Free to modify and redistribute with due credit.
//

#import "FileTransferFoldersPerSenderPlugin.h"


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
}


- (void)uninstallPlugin {

	NSLog(@"FileTransferFoldersPerSenderPlugin unloaded!");
}

@end

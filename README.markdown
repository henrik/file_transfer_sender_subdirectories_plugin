# FileTransferSenderSubdirectoriesPlugin

An Adium plugin that puts incoming files in per-sender subdirectories of the default directory.

A compiled version can be installed [from Adium Xtras](http://www.adiumxtras.com/index.php?a=xtras&xtra_id=4282).

## Functionality

If your Adium is configured to automatically accept files, things should Just Work. If you're prompted for the download directory, going with the default directory (the "Save files to" directory in the File Transfer settings) will cause the file(s) to go into a sender subdirectory. If any directory other than the default directory is selected, the file(s) will go where specified and not into a subdirectory.

The subdirectory will be named "Display Name (Unique Name)", where the "Unique Name" is unchanging: the ICQ UIN, MSN username, Jabber JID etc. The same directory will be used for later file transfers as long as the unique name is unchanged.

## Building

In addition to the code in this repository, you need to add the linked frameworks

  * Adium.framework
  * AIUtilities.framework
  * FriBidi.framework

to the project directory. Compile Adium to get compiled versions of these frameworks in build/{Deployment|Development}.

You can read more about [checking out the Adium source](http://trac.adiumx.com/wiki/GettingReleaseAdiumSource) and [writing Adium plugins](http://fadeover.org/blog/archives/25).

## Credits

By [Henrik Nyh](http://henrik.nyh.se/).

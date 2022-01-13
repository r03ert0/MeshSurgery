//
//  MyDocument.m
//  StereotaxicEditorRAMON
//
//  Created by roberto on 01/07/2009.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "DocumentRAMON.h"

@implementation DocumentRAMON

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}
#pragma mark -
-(char*)objectType
{
	return objectType;
}
-(void)setObjectType:(char*)newObjectType
{
	strcpy(objectType,newObjectType);
}
#pragma mark -
-(void)ramonizeAtLaunch
{
	int			catFD;
	char		*cshm=nil;
	
	key=-1;
	strcpy(consoleMsg,"empty string");
	
	// 1. start connection to catalogue
	catFD=shm_open(KEYCATALOGUE,O_RDWR,S_IRUSR|S_IWUSR);
		if(catFD<0) printf("shm_open() failed\n");
		else{
	cshm=mmap(NULL,(size_t)sizeof(Catalogue),PROT_READ|PROT_WRITE,MAP_SHARED,catFD,0);
		if(cshm==(char*)-1) printf("mmap() failed\n");
		else{
	ctlg=(Catalogue*)cshm;
	
	// 2. start connection-check timer
	timer=[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkConnection:) userInfo:nil repeats:YES];
		}
		}
}
-(void)ramonizeAtTerminate
{
	if(key>0)		[self stopConnection];
	if((char*)ctlg)	munmap((char*)ctlg,(size_t)sizeof(Catalogue));
}
#pragma mark -
// show and check connections to catalogue
-(void)checkConnection:(NSTimer*)theTimer
{
	int	i,n=(*ctlg).nconnections;
	char	cmsg[512];

	if(key>=0)
	for(i=0;i<n;i++)
	if(key==(*ctlg).connection[i].key)
	{
		sprintf(cmsg,"key=%i, %s\n",(*ctlg).connection[i].key,(*ctlg).connection[i].msg);
		if(strcmp(cmsg,consoleMsg))
		{
			strcpy(consoleMsg,cmsg);
			printf("%s",consoleMsg);
		}
		if(strcmp((*ctlg).connection[i].msg,"unwilling")==0)
		{
			[self stopConnection];
			[self cleanVisualisation];
		}
		break;
	}
	if(i==n && key>=0) // lost connection! (catalogue quited?)
	{
		[self stopConnection];
		[self cleanVisualisation];
	}
	
	if(key<0)
	{
		for(i=0;i<n;i++)
		if(	strcmp((*ctlg).connection[i].msg,"willing")==0 &&
			strcmp((*ctlg).connection[i].type,[self objectType])==0)
		{
			printf(">>key:%i, name:%s\n",(*ctlg).connection[i].key,(*ctlg).connection[i].name);
			[self startConnectionWithKey:(*ctlg).connection[i].key];
			[self configureVisualisation];
			
			[[[NSApp orderedWindows] objectAtIndex:0] setTitle:[NSString stringWithUTF8String:(*ctlg).connection[i].name]];
			(*ctlg).connection[i].connections++;
			break;
		}
		if(i==n)
		{
			sprintf(cmsg,"no data available\n");
			if(strcmp(cmsg,consoleMsg))
			{
				strcpy(consoleMsg,cmsg);
				printf("%s",consoleMsg);
			}
		}
	}
}
-(void)startConnectionWithKey:(int)newKey
{	
	int			err;
	char		skey[10];
	struct stat	sb;
	
	printf("____\n");
	printf("starting connection for key %i\n",newKey);
	key=newKey;
	sprintf(skey,"%i",key);
	shmFD=shm_open(skey,O_RDWR,S_IRUSR|S_IWUSR);  if(shmFD<0) printf("shm_open() failed\n");
	err=fstat(shmFD,&sb); if(err<0) printf("fstat() failed\n");
	size=sb.st_size;
	shm=mmap(NULL,(size_t)size,PROT_READ|PROT_WRITE,MAP_SHARED,shmFD,0); if((char*)shm==(char*)-1)  printf("mmap() failed\n");
}
-(void)stopConnection
{
	printf("stop connection\n");
	int		i,n=(*ctlg).nconnections;
	
	for(i=0;i<n;i++)
	if(key==(*ctlg).connection[i].key)
	{
		(*ctlg).connection[i].connections--;
		break;
	}	

	munmap(shm,(size_t)size);
	close(shmFD);
	
	key=-1;
	shm=nil;
}
-(void)sendMessage:(char*)s
{
	printf("send message:%s\n",s);
	int		i,n=(*ctlg).nconnections;
	char	msg[256];
	
	for(i=0;i<n;i++)
	if(key==(*ctlg).connection[i].key)
	{
		sprintf(msg,"*%s",s);
		strcpy((*ctlg).connection[i].msg,msg);
		break;
	}	
}
#pragma mark -
-(void)configureVisualisation
{
}
-(void)cleanVisualisation
{
}
@end

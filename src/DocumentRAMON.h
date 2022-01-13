//
//  DocumentRAMON.h
//
//  Created by roberto on 01/07/2009.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

#include <sys/mman.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#define KEYCATALOGUE	"/nineteenseventytwo"
#define MAXCONNECTIONS	10

typedef struct
{
	char	name[256];
	char	type[32];
	char	msg[32];
	int		key;
	short	connections;
}Connection;
typedef struct
{
	int			nconnections;
	Connection	connection[MAXCONNECTIONS];
}Catalogue;

@interface DocumentRAMON : NSDocument
{
	char		objectType[64];

	NSTimer		*timer;
	char		consoleMsg[512];

	Catalogue	*ctlg;
	int			key,shmFD,size;
	char		*shm;
}
-(char*)objectType;
-(void)setObjectType:(char*)newObjectType;

-(void)ramonizeAtLaunch;
-(void)ramonizeAtTerminate;

-(void)checkConnection:(NSTimer*)theTimer;
-(void)startConnectionWithKey:(int)newKey;
-(void)stopConnection;
-(void)sendMessage:(char*)s;

-(void)configureVisualisation;
-(void)cleanVisualisation;
@end
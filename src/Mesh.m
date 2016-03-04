//
//  Mesh.m
//  MeanValueCoordinates
//
//  Created by rOBERTO tORO on 02/02/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Mesh.h"


@implementation Mesh
-(id)init
{
	edges=[[NSMutableArray new] retain];
	triangles=[[NSMutableArray new] retain];
	points=[[NSMutableArray new] retain];
    colours=[[NSMutableArray new] retain];
    neighbours=[[NSMutableArray new] retain];

	// initialize cursor
	cp[0]=(float3D){1,1,-1};	// cursor vertices
	cp[1]=(float3D){-1,1,-1};
	cp[2]=(float3D){-1,-1,-1};
	cp[3]=(float3D){1,-1,-1};
	cp[4]=(float3D){1,1,1};
	cp[5]=(float3D){-1,1,1};
	cp[6]=(float3D){-1,-1,1};
	cp[7]=(float3D){1,-1,1};
	ct[0]=(int3D){0,1,5};		// cursor triangles
	ct[1]=(int3D){0,5,4};
	ct[2]=(int3D){1,2,6};
	ct[3]=(int3D){1,6,5};
	ct[4]=(int3D){2,3,7};
	ct[5]=(int3D){2,7,6};
	ct[6]=(int3D){3,0,4};
	ct[7]=(int3D){3,4,7};
	ct[8]=(int3D){0,2,1};
	ct[9]=(int3D){0,3,2};
	ct[10]=(int3D){4,5,6};
	ct[11]=(int3D){4,6,7};
	cc[0]=(float3D){0,1,0};		// cursor triangle's colours
	cc[1]=(float3D){0,1,0};
	cc[2]=(float3D){1,0,1};
	cc[3]=(float3D){1,0,1};
	cc[4]=(float3D){1,1,0};
	cc[5]=(float3D){1,1,0};
	cc[6]=(float3D){1,0,0};
	cc[7]=(float3D){1,0,0};
	cc[8]=(float3D){0,1,1};
	cc[9]=(float3D){0,1,1};
	cc[10]=(float3D){0,0,1};
	cc[11]=(float3D){0,0,1};
	
	displaySurface=YES;
	displayWireframe=YES;
	displayVertices=YES;
	displayNormals=NO;
	zoom=1;
	filename=nil;
	center=(float3D){0,0,0};
	smoothFlag=NO;
	smoothValue=0;
    smoothIter=200;
	angle1=0;
	angle2=0;
	
	return self;
}
-(float3D)center
{
	return center;
}
-(void)setCenter:(float3D)theCenter
{
	center=theCenter;
}
-(NSMutableArray*)edges
{
	return edges;
}
-(NSMutableArray*)triangles
{
	return triangles;
}
-(NSMutableArray*)points
{
	return points;
}
-(NSMutableArray*)colours
{
    return colours;
}
-(NSMutableArray*)neighbours
{
    return neighbours;
}
-(int)selectedCount
{
	int		i,sel;
	Float3D	*p;
	
	sel=0;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		sel+=[p selected]*(![p deleted]);
	}
	
	return sel;
}
-(void)selectAll
{
	int		i;
	Float3D	*p;
	
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p deleted]==NO)
			[p setSelected:YES];
	}
}
-(void)selectNone
{
	int		i;
	Float3D	*p;
	
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		[p setSelected:NO];
	}
	
}
-(void)selectConnected
{
	int				*pointClass,*class;
	int				nclass;
	int				i,j,min,max,imax,n,nn;
	NSEnumerator	*e = [triangles objectEnumerator];
	id				obj;
	int				*tr;
	
	pointClass=(int*)calloc([points count],sizeof(int));
	class=(int*)calloc([points count],sizeof(int));
	nclass=1;

	// 1. Assign points to classes, build the class equivalence table
	while(obj=[e nextObject])
	{
		tr=[obj ve];
		min=-1;
		for(i=0;i<3;i++)
			if(pointClass[tr[i]]>0)
			{
				if(min<0)
					min=pointClass[tr[i]];
				else
					min=MIN(min,pointClass[tr[i]]);
			}
		if(min==-1)
		{
			for(i=0;i<3;i++)
				pointClass[tr[i]]=nclass;
			class[nclass]=nclass;
			nclass++;
		}
		else
		{
			for(i=0;i<3;i++)
			{
				if(pointClass[tr[i]] && pointClass[tr[i]]!=min)
					class[pointClass[tr[i]]]=-min;
				pointClass[tr[i]]=min;
			}
		}
	}
	
	// 2. Clean the class equivalence table
	for(i=2;i<nclass;i++)
	{
		if(class[i]<0)
		{
			while(class[i]<0)
				class[i]=class[-class[i]];
			class[i]=-class[i];
		}
	}
	
	// 3. Assign points to final classes and find the largest class
	n=1;
	max=0;
	for(i=1;i<nclass;i++)
	{
		if(class[i]>0)
		{
			nn=0;
			for(j=0;j<[points count];j++)
			{
				if(abs(class[pointClass[j]])==class[i])
				{
					pointClass[j]=n;
					nn++;
				}
			}
			if(nn>max)
			{
				max=nn;
				imax=n;
			}
			n++;
		}
	}
	printf("maxclass=%i, N=%i\n",imax,max);
	
	// 4. Select only vertices in the largest class
	for(i=0;i<[points count];i++)
	if(pointClass[i]==imax)
		[(Float3D*)[points objectAtIndex:i] setSelected:YES];
	else
		[(Float3D*)[points objectAtIndex:i] setSelected:NO];
}
-(void)selectMore
{
	int		j;
	int		*tr;
	int		found[3];
	NSMutableArray	*toAdd=[NSMutableArray new];
	NSEnumerator	*e = [triangles objectEnumerator];
	id		obj;
 
	while(obj=[e nextObject])
	{
		tr=[obj ve];
		for(j=0;j<3;j++)
			found[j]=[[points objectAtIndex:tr[j]] selected];
		if(found[0]+found[1]+found[2]==0)
			continue;
		for(j=0;j<3;j++)
			if(found[j]==0 && [[points objectAtIndex:tr[j]] deleted]==FALSE)
				[toAdd addObject:[NSNumber numberWithInt:tr[j]]];
	}
	for(j=0;j<[toAdd count];j++)
		[(Float3D*)[points objectAtIndex:[[toAdd objectAtIndex:j] intValue]] setSelected:YES];
	[toAdd release];
}
-(void)selectLess
{
	int				i,j;
	int				*tr;
	int				found[3];
	NSMutableArray	*toRemove=[NSMutableArray new];
	
	for(i=0;i<[triangles count];i++)
	{
		tr=[[triangles objectAtIndex:i] ve];
		for(j=0;j<3;j++)
			found[j]=[[points objectAtIndex:tr[j]] selected];
		if(found[0]+found[1]+found[2]==0 || found[0]+found[1]+found[2]==3)
			continue;
		for(j=0;j<3;j++)
			if(found[j]==1)
				[toRemove addObject:[NSNumber numberWithInt:tr[j]]];
	}
	for(j=0;j<[toRemove count];j++)
		[(Float3D*)[points objectAtIndex:[[toRemove objectAtIndex:j] intValue]] setSelected:NO];
	[toRemove release];
}
/*
3 5 4 5		c1: e1.a<e2.a					r -1
4 5 3 5		c2: e1.a>e2.a					r  1
3 5 3 7		c3: e1.a==e2.a, e1.b<e2.b		r -1
3 7 3 5		c4: e1.a==e2.a, e1.b>e2.b		r  1
			c5: e1.a==e2.a, e1.b==e2.b		r  0
*/
int compareEdges (const void *a, const void *b)
{
	int2D	e1=*(int2D*)a;
	int2D	e2=*(int2D*)b;

	if(e1.a==e2.a)
	{
		if(e1.b==e2.b)
			return 0;
		else
		if(e1.b<e2.b)
			return -1;
		else
			return 1;
	}
	else
	{
		if(e1.a<e2.a)
			return -1;
		else
			return	1;
	}
}
-(NSArray *)selectLoopAtVertex:(int)psel
{
	int     i,j;
    int     n;  // # manifold edges
    int3D	*e;
	int3D	*nme;
	int2D	*m;
	int		*p0,*p1,nn,s0,nl,sz;
	int		i1,j1,k,found,t0,t1;
	int		*t;
    NSMutableArray  *arr=[NSMutableArray new];

	// make a list of all edges
	e=(int3D*)calloc([triangles count]*3,sizeof(int3D));
	for(i=0;i<[triangles count];i++)
	{
		t=[[triangles objectAtIndex:i] ve];
		for(j=0;j<3;j++)
		{
			if(t[j]<t[(j+1)%3])
			{
				e[3*i+j].a=t[j];        // 1st vertex
				e[3*i+j].b=t[(j+1)%3];  // 2nd vertex
				e[3*i+j].c=i;           // # triangle
			}
			else
			{
				e[3*i+j].a=t[(j+1)%3];  // 1st vertex
				e[3*i+j].b=t[j];        // 2nd vertex
				e[3*i+j].c=i;           // # triangle
			}
		}
	}
	
	// sort edges
	qsort(e,[triangles count]*3,sizeof(int3D),compareEdges);
	
	// count nonmanifold edges
	i=0;
	j=0;
	n=0;
	do
	{
		if(e[j].a==e[j+1].a && e[j].b==e[j+1].b)
			j+=2;
		else
		{
			j++;
			n++;
		}
	}
	while(j<[triangles count]*3);
	printf("nonmanifold edges:%i\n",n);
	
	// store nonmanifold edges
	nme=(int3D*)calloc(n,sizeof(int3D));
	i=0;
	j=0;
	n=0;
	do
	{
		if(e[j].a==e[j+1].a && e[j].b==e[j+1].b)
			j+=2;
		else
		{
			nme[n++]=e[j];
			j++;
		}
	}
	while(j<[triangles count]*3);
	
	// recode vertices
	p0=(int*)calloc([points count],sizeof(int));	// p0[#orig]=#new
	for(i=0;i<[points count];i++)
		p0[i]=-1;
	p1=(int*)calloc(n,sizeof(int));					// p1[#new]=#orig
	nn=0;
	for(i=0;i<n;i++)
	{
		if(p0[nme[i].a]<0)
		{
			p0[nme[i].a]=nn;
			p1[nn]=nme[i].a;
			nn++;
		}
		if(p0[nme[i].b]<0)
		{
			p0[nme[i].b]=nn;
			p1[nn]=nme[i].b;
			nn++;
		}
	}
	
	// make a non-manifold edge matrix
	m=(int2D*)calloc(n*n,sizeof(int2D));
	for(i=0;i<n;i++)
	{
		m[p0[nme[i].b]*n+p0[nme[i].a]]=(int2D){-1,i};
		m[p0[nme[i].a]*n+p0[nme[i].b]]=(int2D){-1,i};
	}
	
	// find loop intersections (if any)
	for(i=0;i<n;i++)
	{
		s0=0;
		for(j=0;j<n;j++)
			if(m[i*n+j].a<0)
				s0++;
		if(s0>2)
		{
			printf("loop intersection: %i\n",s0);
			for(j=0;j<n;j++)
				if(m[i*n+j].a<0)
					m[i*n+j].a=m[j*n+i].a=-2;
		}
	}
	
	// find the loop
    int alter;
	nl=1;
	for(i=0;i<n;i++)
        for(j=0;j<n;j++)
            if(m[i*n+j].a==-1 && p1[i]==psel)
            {
                [(Float3D*)[points objectAtIndex:p1[j]] setSelected:YES];
                alter=p1[j];
                
                i1=i;
                j1=j;
                t0=nme[m[i*n+j].b].c;   // (nme: non-manifold edges array, m: non-manifold edge matrix)
                sz=1;
                do
                {
                    m[i1*n+j1].a=nl;
                    m[j1*n+i1].a=nl;
                    found=0;
                    for(k=0;k<n;k++)
                    {
                        if(m[i1*n+k].a==-1)
                        {
                            j1=k;
                            t1=nme[m[i1*n+k].b].c;
                            sz++;
                            found=1;
                            break;
                        }
                        if(m[k*n+j1].a==-1)
                        {
                            i1=k;
                            t1=nme[m[k*n+j1].b].c;
                            sz++;
                            found=1;
                            break;
                        }
                    }
                    if(found)
                    {
                        [(Float3D*)[points objectAtIndex:p1[k]] setSelected:YES];
                        [arr addObject:[NSNumber numberWithInt:p1[k]]];
                    }
                }
                while(found);
                break;
            }
	free(e);
	free(m);
	free(p0);
	free(p1);
	free(nme);
    
    if([[arr lastObject] intValue]==alter)
    {
        [arr insertObject:[NSNumber numberWithInt:psel] atIndex:0];
    }
    else
    {
        [arr insertObject:[NSNumber numberWithInt:alter] atIndex:0];
        [arr insertObject:[NSNumber numberWithInt:psel] atIndex:0];
        [arr removeLastObject];
    }
    return arr;
}
-(NSArray*)selectLoop
{
	int		i;
	Float3D	*p;
	int		psel;
	
	[self cleanMesh];
	[self depth];

	psel=-1;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p selected] && psel<0)
			psel=i;
		else
			[p setSelected:NO];
	}
	if(psel<0)
		return nil;
    return [self selectLoopAtVertex:psel];
}
-(void)fillLoop
{
	int				i,n;
	Float3D			*p,*q,*r;
	Int3D			*t,*tr;
	float3D			c;
	int				*ve;
	NSMutableArray	*toAdd=[NSMutableArray new];
	
	[self selectLoop];
	c=(float3D){0,0,0};
	n=0;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p selected] && ![p deleted])
		{
			c=add3D(c,*(float3D*)[p co]);
			n++;
		}
	}
	c=sca3D(c,1/(float)n);
	[self addVertex:c];
	
	for(i=0;i<[triangles count];i++)
	{
		t=[triangles objectAtIndex:i];
		ve=[t ve];
		p=[points objectAtIndex:ve[0]];
		q=[points objectAtIndex:ve[1]];
		r=[points objectAtIndex:ve[2]];
		if([p selected]&&[q selected])
		{
			tr=[[Int3D alloc] init];
			[tr setVerts:[points count]-1:ve[1]:ve[0]];
			[toAdd addObject:tr];
			[tr release];
		}
		if([q selected]&&[r selected])
		{
			tr=[[Int3D alloc] init];
			[tr setVerts:[points count]-1:ve[2]:ve[1]];
			[toAdd addObject:tr];
			[tr release];
		}
		if([r selected]&&[p selected])
		{
			tr=[[Int3D alloc] init];
			[tr setVerts:[points count]-1:ve[0]:ve[2]];
			[toAdd addObject:tr];
			[tr release];
		}
	}
	
	[triangles addObjectsFromArray:toAdd];
	[toAdd release];
	
	smoothFlag=NO;
}
-(void)fillLoop2
{
	int				i,i0,i1,i2,n;
	Int3D			*tr;
	NSMutableArray	*toAdd=[NSMutableArray new];
    NSArray         *arr;
	
	arr=[self selectLoop];
    printf("%s\n",(char*)[[arr description] UTF8String]);

    i=0;
    n=[arr count]-1;
    i0=0;
    i1=1;
    i2=n;
    while(i0!=i1 && i1!=i2)
    {
        // make triangle i0,i1,i2
        tr=[[Int3D alloc] init];
        [tr setVerts:[[arr objectAtIndex:i0] intValue]:[[arr objectAtIndex:i1] intValue]:[[arr objectAtIndex:i2] intValue]];
        printf("+ %i %i %i\n",[[arr objectAtIndex:i0] intValue],[[arr objectAtIndex:i1] intValue],[[arr objectAtIndex:i2] intValue]);
        [toAdd addObject:tr];
        [tr release];
        
        // next triangle
        if(i%2==0)
        {
            i0=i1;
            i1=i2-1;
        }
        else
        {
            i2=i1;
            i1=i0+1;
        }
        
        i++;
    }
	
	[triangles addObjectsFromArray:toAdd];
	[toAdd release];
	
	smoothFlag=NO;
}
-(void)selectTunnel
{
	int				i,j,k,l,m,E,nv,ne,nt,flagAdded,flagSomethingDone;
	int				*tr,*tr1;
	int				found[3];
	int				*mark,level,v0,v,min,val,MaxLevel=10;
	NSMutableArray	*selvtx=[NSMutableArray new];
	NSMutableArray	*seledg=[NSMutableArray new];
	NSMutableArray	*seltri0=[NSMutableArray new];
	NSMutableArray	*seltri1=[NSMutableArray new];
	NSMutableArray	*tmptri=[NSMutableArray new];
	NSMutableArray	*tmptri1=[NSMutableArray new];
	NSMutableArray	*tmpvtx=[NSMutableArray new];
	NSEnumerator	*e;
	id				obj;
	NSNumber		*vtx;
	NSString		*edg;

	mark=(int*)calloc([points count],sizeof(int));
	level=1;
	
	// Add completely selected triangles to seltri0
	e=[triangles objectEnumerator];
	while(obj=[e nextObject])
	{
		tr=[obj ve];
		for(j=0;j<3;j++)
			found[j]=[[points objectAtIndex:tr[j]] selected];
		if(found[0]+found[1]+found[2]==3)
		{
			[seltri0 addObject:obj];
			tr=[obj ve];
			for(j=0;j<3;j++)
			{
				mark[tr[j]]=level;
				
				vtx=[NSNumber numberWithInt:tr[j]];
				if([selvtx containsObject:vtx]==NO)
					[selvtx addObject:vtx];
				if(tr[j]<tr[(j+1)%3])
					edg=[NSString stringWithFormat:@"%i,%i",tr[j],tr[(j+1)%3]];
				else
					edg=[NSString stringWithFormat:@"%i,%i",tr[(j+1)%3],tr[j]];
				if([seledg containsObject:edg]==NO)
					[seledg addObject:edg];
			}
		}
	}
	
	// Part 1: Grow selection until topology change (or max)
	//-------------------------------------------------------
	do
	{
		// Add partially-selected triangles to seltri1
		e=[triangles objectEnumerator];
		while(obj=[e nextObject])
		{
			tr=[obj ve];
			for(j=0;j<3;j++)
				found[j]=[[points objectAtIndex:tr[j]] selected];
			if((found[0]+found[1]+found[2]==1) || (found[0]+found[1]+found[2]==2))
				[seltri1 addObject:obj];
		}
		
		// Test partially-selected triangles 1 by 1,
		// and add them to the selection disk if they       ________
		// do not change its topology (the process has      \2 /\4 /\
		// to be iterated until no new triangles can be      \/_5\/_3\
		// added, because the order of the addition can       \1 /
		// ignore a triangle at first, but add it later)       \/
		level++;
		do
		{
			printf("add loop-----------\n");
			flagAdded=NO;

			for(i=0;i<[seltri1 count];i++)
			{
				if([tmptri1 containsObject:[seltri1 objectAtIndex:i]])
					continue;

				tr=[[seltri1 objectAtIndex:i] ve];

				// test the change in E that would be produced by triangle i
				nv=ne=0;
				nt=1;
				for(j=0;j<3;j++)
				{
					vtx=[NSNumber numberWithInt:tr[j]];
					if([selvtx containsObject:vtx]==NO)
						nv++;
					if(tr[j]<tr[(j+1)%3])
						edg=[NSString stringWithFormat:@"%i,%i",tr[j],tr[(j+1)%3]];
					else
						edg=[NSString stringWithFormat:@"%i,%i",tr[(j+1)%3],tr[j]];
					if([seledg containsObject:edg]==NO)
						ne++;
				}
				
				if(ne==3)		// add only triangles already sharing 1 or 2 edges with the selection
					continue;
				
				E=([selvtx count]+nv)-([seledg count]+ne)+([seltri0 count]+nt);
				printf("triangle %i,%i,%i adds #v=%i, #e=%i, #t=%i: ",tr[0],tr[1],tr[2],nv,ne,nt);
				
				// if the topology is still disc-like, add the triangle
				if(E==1)
				{
					flagAdded=YES;
					printf("added\n");
					for(j=0;j<3;j++)
					{
						vtx=[NSNumber numberWithInt:tr[j]];
						if([selvtx containsObject:vtx]==NO)
						{
							[selvtx addObject:vtx];
							mark[tr[j]]=level;
						}

						if(tr[j]<tr[(j+1)%3])
							edg=[NSString stringWithFormat:@"%i,%i",tr[j],tr[(j+1)%3]];
						else
							edg=[NSString stringWithFormat:@"%i,%i",tr[(j+1)%3],tr[j]];
						if([seledg containsObject:edg]==NO)
							[seledg addObject:edg];
						[(Float3D*)[points objectAtIndex:tr[j]] setSelected:YES];
					}
					[seltri0 addObject:[seltri1 objectAtIndex:i]];
					[tmptri addObject:[seltri1 objectAtIndex:i]];
				}
				else		// topology changed (maybe momentarily), store the triangle
							// [* it seems that only topology changing triangles enter here]
				{
					printf("ignored\n");
					[tmptri1 addObject:[seltri1 objectAtIndex:i]];
				}
			}
			[seltri1 removeObjectsInArray:tmptri];
			[tmptri removeAllObjects];
		}
		while(flagAdded);
	}
	while([seltri1 count]==0 && level<=MaxLevel);
		
	// Unselect everything
	for(i=0;i<[points count];i++)
		[(Float3D*)[points objectAtIndex:i] setSelected:NO];

	// Part 2: Select a ring around the tunnel
	//-----------------------------------------
	
	// -> Do it without searching !!
	
	if([seltri1 count])
	{
		printf("%i topology-changing triangle%c\n",(int)[seltri1 count],([seltri1 count]>1)?'s':' ');
		
		for(i=0;i<1/*[seltri1 count]*/;i++)
		{
			[seltri0 addObject:[seltri1 objectAtIndex:i]];
			
			// find v0, the topology-changing vertex, by
			// finding the edge shared with the selection
			// (whose two vertices are innocent)
			tr=[[seltri1 objectAtIndex:i] ve];
			for(j=0;j<3;j++)
			{
				if(tr[j]<tr[(j+1)%3])
					edg=[NSString stringWithFormat:@"%i,%i",tr[j],tr[(j+1)%3]];
				else
					edg=[NSString stringWithFormat:@"%i,%i",tr[(j+1)%3],tr[j]];
				if([seledg containsObject:edg]==YES)
					break;
			}
			v0=tr[(j+2)%3];
			
			// find the 2 arms from v0 to the origin
			for(l=0;l<2;l++)
			{
				v=v0;
				val=mark[v]=level+1;
				[tmpvtx addObject:[points objectAtIndex:v]];
				printf("\narm %i\n%i: %i\n",l,v,val);
		
				while(val>1)
				{
					flagAdded=NO;
					flagSomethingDone=NO;
					for(k=0;k<[seltri0 count];k++)
					{
						tr=[[seltri0 objectAtIndex:k] ve];
						
						for(j=0;j<3;j++)					// find triangles containing v
							if(tr[j]==v)
								break;
						if(j==3)
							continue;
						
						min=-1;
						if(mark[tr[0]]>0) min=0;
						else if(mark[tr[1]]>0) min=1;
						else if(mark[tr[2]]>0) min=2;
						if(mark[tr[1]]>0 && mark[tr[1]]<mark[tr[min]]) min=1;
						if(mark[tr[2]]>0 && mark[tr[2]]<mark[tr[min]]) min=2;
						
						if(min>-1 && mark[tr[min]]<val)
						{
							val=mark[tr[min]];
							printf("%i: %i\n",tr[min],val);
							
							// add k-th triangle to delete list
							[tmptri addObject:[seltri0 objectAtIndex:k]];
							
							// add the other triangle sharing the v,tr[min] edge to delete list
							for(m=0;m<[seltri0 count];m++)
							if(m!=k)
							{
								tr1=[[seltri0 objectAtIndex:m] ve];
								if((tr1[0]==v||tr1[1]==v||tr1[2]==v)&&
								   (tr1[0]==tr[min]||tr1[1]==tr[min]||tr1[2]==tr[min]))
								{
									[tmptri addObject:[seltri0 objectAtIndex:m]];
									break;
								}
							}
								
							// add the vertex tr[min] to the ring list
							[tmpvtx addObject:[points objectAtIndex:tr[min]]];
							flagAdded=YES;
							if(val==1)
							{
								for(j=0;j<[tmpvtx count];j++)
									[(Float3D*)[tmpvtx objectAtIndex:j] setSelected:YES];
								break;
							}
							v=tr[min];
							flagSomethingDone=YES;
						}
					}
					if(flagAdded==NO && flagSomethingDone==YES)
					{
						l=0;
						break;
					}
				}
				[tmpvtx removeAllObjects];
				for(k=0;k<[tmptri count];k++)
				{
					tr=[[tmptri objectAtIndex:k] ve];
					printf("removing %i,%i,%i\n",tr[0],tr[1],tr[2]);
				}
				[seltri0 removeObjectsInArray:tmptri];
				[tmptri removeAllObjects];
			}
		}
	}

	[selvtx release];
	[seledg release];
	[seltri0 release];
	[seltri1 release];
	[tmptri release];
	[tmptri1 release];
	[tmpvtx release];
	free(mark);
}
-(void)invertSelection
{
	int	i;
	Float3D	*p;
	
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		[p setSelected:![p selected]];
	}
}
-(void)fixNormals
{
	int		i;
	Int3D	*t;
	int		*ve;
	
	for(i=0;i<[triangles count];i++)
	{
		t=[triangles objectAtIndex:i];
		ve=[t ve];
		if(	[(Float3D*)[points objectAtIndex:ve[0]] selected] &&
			[(Float3D*)[points objectAtIndex:ve[1]] selected] &&
			[(Float3D*)[points objectAtIndex:ve[2]] selected])
		{
			[t setVerts:ve[0]:ve[2]:ve[1]];
		}
	}
}
-(void)flipNormals
{
	int		i;
	Int3D	*t;
	int		*ve;
	
	for(i=0;i<[triangles count];i++)
	{
		t=[triangles objectAtIndex:i];
		ve=[t ve];
		[t setVerts:ve[0]:ve[2]:ve[1]];
	}
}
-(void)selectNonmanifoldVerts
{
    int3D   *e;
    int e_length=0;
    int i,j,k,found,loop;
    int *t1,t1_length;
    int *i1,i1_length;
    NSMutableArray *ne;
    int *t;

    [self configureNeighbours];

    printf("non manifold vertices\n");
    for(i=0;i<[points count];i++)
    {
        // store all the edges in the triangles connected to vertex p[i]
        // that do not contain vertex p[i]
        ne=[neighbours objectAtIndex:i];
        e=(int3D*)calloc([ne count]*3,sizeof(int3D));
        e_length=0;
        ne=[neighbours objectAtIndex:i];
        for(j=0;j<[ne count];j++)
        {
            t=[[triangles objectAtIndex:[[ne objectAtIndex:j] intValue]] ve];
            if(t[0]==i)
                e[e_length++]=(int3D){t[1],t[2],[(NSNumber*)[ne objectAtIndex:j] intValue]};
            else
            if(t[1]==i)
                e[e_length++]=(int3D){t[2],t[0],[(NSNumber*)[ne objectAtIndex:j] intValue]};
            else
                e[e_length++]=(int3D){t[0],t[1],[(NSNumber*)[ne objectAtIndex:j] intValue]};
        }
        /*
         printf("p[%i]: ",i); for(j=0;j<e_length;j++) printf("(%i,%i) ",e[j].a,e[j].b); printf("\n");
         */
        // scan the list of edges, if 2 edges share a vertex,
        // delete the vertex and connect the points directly.
        // at the end, there should be only one edge remaining
        // connecting one vertex to itself. All remaining a-a
        // edges represent supplementary loops, then, non-manifoldness
        j=0;
        i1=(int*)calloc([ne count],sizeof(int));
        t1=(int*)calloc([ne count]*3,sizeof(int));
        i1_length=0;
        t1_length=0;
        i1[i1_length++]=t1_length;
        t1[t1_length++]=e[j].c;
        while(j<e_length-1)
        {
            loop=0;
            k=j+1;
            while(k<e_length)
            {
                found=1;
                if(e[j].a==e[k].a)
                    e[j]=(int3D){e[j].b,e[k].b,e[j].c};
                else if(e[j].a==e[k].b)
                    e[j]=(int3D){e[j].b,e[k].a,e[j].c};
                else if(e[j].b==e[k].a)
                    e[j]=(int3D){e[j].a,e[k].b,e[j].c};
                else if(e[j].b==e[k].b)
                    e[j]=(int3D){e[j].a,e[k].a,e[j].c};
                else
                    found=0;
                if(found)
                {
                    t1[t1_length++]=e[k].c; //printf("t[%i] ",e[k].c);
                    e[k]=e[--e_length];
                    if(e[j].a==e[j].b)
                    {
                        //printf("\n");
                        loop=1;
                        j++;
                        if(j<e_length)
                        {
                            i1[i1_length++]=t1_length;
                            t1[t1_length++]=e[j].c; //printf("  t[%i] ",e[j].c);
                        }
                        break;
                    }
                }
                else
                    k++;
            }
        }
        // printf("p[%i]: ",i); for(j=0;j<e_length;j++) printf("(%i,%i) ",e[j].a,e[j].b); printf("\n");
        free(e);
        free(t1);
        free(i1);
        
        [(Float3D*)[points objectAtIndex:i] setSelected:YES];
        if([ne count]==0)      printf("WARNING, %i is isolated: remove it\n",i);
        else if([ne count]==1) printf("WARNING, %i is dangling: remove the the vertex and its triangle\n",i);
        else if(loop==0)    printf("WARNING, %i is in a degenerate region: examine more in detail\n",i);
        else if(e_length>1) printf("WARNING, %i has %i loops: split the vertex into %i vertices and remesh\n",i,e_length,e_length);
        else
        {
            [(Float3D*)[points objectAtIndex:i] setSelected:NO];
        }
    }
}

-(void)selectNonmanifoldEds
{
    int		i,j,n;
    int3D	*e;
    int		*t;
    
    [self cleanMesh];
    [self depth];
    
    // make a list of all edges
    e=(int3D*)calloc([triangles count]*3,sizeof(int3D));
    for(i=0;i<[triangles count];i++)
    {
        t=[[triangles objectAtIndex:i] ve];
        for(j=0;j<3;j++)
        {
            if(t[j]<t[(j+1)%3])
            {
                e[3*i+j].a=t[j];
                e[3*i+j].b=t[(j+1)%3];
                e[3*i+j].c=i;
            }
            else
            {
                e[3*i+j].a=t[(j+1)%3];
                e[3*i+j].b=t[j];
                e[3*i+j].c=i;
            }
        }
    }
    
    // sort edges
    qsort(e,[triangles count]*3,sizeof(int3D),compareEdges);
    
    // count nonmanifold edges
    i=0;
    j=0;
    n=0;
    do
    {
        if(e[j].a==e[j+1].a && e[j].b==e[j+1].b)
            j+=2;
        else
        {
            [(Float3D*)[points objectAtIndex:e[j].a] setSelected:YES];
            [(Float3D*)[points objectAtIndex:e[j].b] setSelected:YES];
            j++;
            n++;
        }
    }
    while(j<[triangles count]*3);
    printf("nonmanifold edges:%i\n",n);
    free(e);
}
-(int)selectNonmanifoldTris
{
    int   i,j,found;
    int   *t,*t1;
    NSMutableArray  *ne;
    Int3D *tr;
    
    [self configureNeighbours];


    found=0;
    for(i=0;i<[triangles count];i++)
    {
        t=[[triangles objectAtIndex:i] ve];
        ne=[neighbours objectAtIndex:t[0]];
        for(j=0;j<[ne count];j++)
            if([(NSNumber*)[ne objectAtIndex:j] intValue]!=i)
            {
                tr=(Int3D*)[triangles objectAtIndex:[(NSNumber*)[ne objectAtIndex:j] intValue]];
                t1=[tr ve];
                if((t1[0]==t[0]||t1[0]==t[1]||t1[0]==t[2])&&
                   (t1[1]==t[0]||t1[1]==t[1]||t1[1]==t[2])&&
                   (t1[2]==t[0]||t1[2]==t[1]||t1[2]==t[2]))
                {
                    found++;
                    printf("triangle %i doubles triangle %i\n",i,[(NSNumber*)[ne objectAtIndex:j] intValue]);
                    [(Float3D*)[points objectAtIndex:t[0]] setSelected:YES];
                    [(Float3D*)[points objectAtIndex:t[1]] setSelected:YES];
                    [(Float3D*)[points objectAtIndex:t[2]] setSelected:YES];
                    break;
                }
            }
    }
    printf("%i double triangles found\n",found/2);
    return found/2;
}
-(void)splitVertex
{
    int3D   *e;
    int e_length=0;
    int i,j,k,found,loop;
    int *t1,t1_length;
    int *i1,i1_length;
    NSMutableArray *ne;
    int *t;
    Int3D *obj;
    float *p;
    
    [self configureNeighbours];
    
    for(i=0;i<[points count];i++)
        if([(Float3D*)[points objectAtIndex:i] selected]==YES)
            break;
    if(i==[points count])
    {
        printf("You have to select a vertex to split\n");
        return;
    }
    
    printf("Splitting vertex %i\n",i);
    p=[(Float3D*)[points objectAtIndex:i] co];
    
    // store all the edges in the triangles connected to vertex p[i]
    // that do not contain vertex p[i]
    ne=[neighbours objectAtIndex:i];
    e=(int3D*)calloc([ne count]*3,sizeof(int3D));
    e_length=0;
    ne=[neighbours objectAtIndex:i];
    for(j=0;j<[ne count];j++)
    {
        t=[(Int3D*)[triangles objectAtIndex:[[ne objectAtIndex:j] intValue]] ve];
        if(t[0]==i)
            e[e_length++]=(int3D){t[1],t[2],[(NSNumber*)[ne objectAtIndex:j] intValue]};
        else
        if(t[1]==i)
            e[e_length++]=(int3D){t[2],t[0],[(NSNumber*)[ne objectAtIndex:j] intValue]};
        else
            e[e_length++]=(int3D){t[0],t[1],[(NSNumber*)[ne objectAtIndex:j] intValue]};
    }

    // scan the list of edges, if 2 edges share a vertex,
    // delete the vertex and connect the points directly.
    // at the end, there should be only one edge remaining
    // connecting one vertex to itself. All remaining a-a
    // edges represent supplementary loops, then, non-manifoldness
    j=0;
    i1=(int*)calloc([ne count],sizeof(int));
    t1=(int*)calloc([ne count]*3,sizeof(int));
    i1_length=0;
    t1_length=0;
    i1[i1_length++]=t1_length;
    t1[t1_length++]=e[j].c;
    while(j<e_length-1)
    {
        loop=0;
        k=j+1;
        while(k<e_length)
        {
            found=1;
            if(e[j].a==e[k].a)
                e[j]=(int3D){e[j].b,e[k].b,e[j].c};
            else if(e[j].a==e[k].b)
                e[j]=(int3D){e[j].b,e[k].a,e[j].c};
            else if(e[j].b==e[k].a)
                e[j]=(int3D){e[j].a,e[k].b,e[j].c};
            else if(e[j].b==e[k].b)
                e[j]=(int3D){e[j].a,e[k].a,e[j].c};
            else
                found=0;
            if(found)
            {
                t1[t1_length++]=e[k].c; //printf("t[%i] ",e[k].c);
                e[k]=e[--e_length];
                if(e[j].a==e[j].b)
                {
                    //printf("\n");
                    loop=1;
                    j++;
                    if(j<e_length)
                    {
                        i1[i1_length++]=t1_length;
                        t1[t1_length++]=e[j].c; //printf("  t[%i] ",e[j].c);
                    }
                    break;
                }
            }
            else
                k++;
        }
    }
    // printf("p[%i]: ",i); for(j=0;j<e_length;j++) printf("(%i,%i) ",e[j].a,e[j].b); printf("\n");
    free(e);
    
    if([ne count]==0)       printf("WARNING, %i is isolated: remove it\n",i);
    else if([ne count]==1)  printf("WARNING, %i is dangling: remove the the vertex and its triangle\n",i);
    else if(loop==0)        printf("WARNING, %i is in a degenerate region: examine more in detail\n",i);
    else if(e_length>1)
    {
        printf("WARNING, %i has %i loops: split the vertex into %i vertices and remesh\n",i,e_length,e_length);
        
        [self addVertex:(float3D){p[0],p[1],p[2]}];
        
        k=1;
        for(j=0;j<t1_length;j++)
        {
            obj=(Int3D*)[triangles objectAtIndex:t1[j]];
            t=[obj ve];
            if(i1[k]==j)
            {
                printf(" | ");
                k++;
            }
            printf("%i ",t1[j]);
            if(k>1)
            {
                if(t[0]==i)   t[0]=[points count]-1;
                if(t[1]==i)   t[1]=[points count]-1;
                if(t[2]==i)   t[2]=[points count]-1;
                [obj setVerts:t[0] :t[1] :t[2]];
            }
        }
        printf("\n");
    }
    free(t1);
    free(i1);
}
-(void)configureSmooth
{
	float3D	*smooth;
	int		i,j;
	int		*itmp;
	float3D	*ftmp;
	Int3D	*t;
	int		*ve;
	
	if(smoothFlag==YES)
		return;

	smooth=(float3D*)calloc([points count],sizeof(float3D));
	for(i=0;i<[points count];i++)
		smooth[i]=*(float3D*)[(Float3D*)[points objectAtIndex:i] co];
	
	ftmp=(float3D*)calloc([points count],sizeof(float3D));
	itmp=(int*)calloc([points count],sizeof(int));
	for(j=0;j<smoothIter;j++)
	{
		for(i=0;i<[triangles count];i++)
		{
			t=[triangles objectAtIndex:i];
			ve=[t ve];
			ftmp[ve[0]]=add3D(ftmp[ve[0]],add3D(smooth[ve[1]],smooth[ve[2]]));
			ftmp[ve[1]]=add3D(ftmp[ve[1]],add3D(smooth[ve[2]],smooth[ve[0]]));
			ftmp[ve[2]]=add3D(ftmp[ve[2]],add3D(smooth[ve[0]],smooth[ve[1]]));
			itmp[ve[0]]+=2;
			itmp[ve[1]]+=2;
			itmp[ve[2]]+=2;
		}
		for(i=0;i<[points count];i++)
		{
			smooth[i]=sca3D(ftmp[i],1/(float)itmp[i]);
			ftmp[i]=(float3D){0,0,0};
			itmp[i]=0;
		}
	}
	free(ftmp);
	free(itmp);
	
	for(i=0;i<[points count];i++)
		[(Float3D*)[points objectAtIndex:i] setSmoothCoords:smooth[i].x:smooth[i].y:smooth[i].z];
	free(smooth);
	
	smoothFlag=YES;
}
-(void)setSmoothValue:(float)t
{
	smoothValue=t;
}
-(void)setDisplaySurface:(int)flag
{
	displaySurface=flag;
}
-(void)setDisplayWireframe:(int)flag
{
	displayWireframe=flag;
}
-(void)setDisplayVertices:(int)flag
{
	displayVertices=flag;
}
-(void)setDisplayNormals:(int)flag
{
	displayNormals=flag;
}
-(void)setZoom:(float)theZoom
{
	zoom=theZoom;
}
-(NSString*)filename
{
	return filename;
}
#pragma mark -
-(void)draw
{
	if(displaySurface)
		[self drawSurface];
	if(displayWireframe)
		[self drawWireframe];
	if(displayVertices)
		[self drawVertices];
	if(displayNormals)
		[self drawNormals];

	[self drawEdges];
	
	[self drawSelectedVertices];
}
-(float3D)interp:(Float3D*)p
{
	return (float3D){	[p cos][0]*smoothValue+[p co][0]*(1-smoothValue),
						[p cos][1]*smoothValue+[p co][1]*(1-smoothValue),
						[p cos][2]*smoothValue+[p co][2]*(1-smoothValue)};
}
-(void)drawSurface
{
	int		i,j;
	float3D	x;
	float	*co;
	int		*tr;
	NSEnumerator	*e;
	id      obj;
    float   area0,area1,g;

	// display surface triangles
    
    for(i=0;i<2;i++)
    {
        if(i==0)
            glCullFace(GL_FRONT);
        else
            glCullFace(GL_BACK);
        
        glBegin(GL_TRIANGLES);
        e=[triangles objectEnumerator];
        while(obj=[e nextObject])
        {
            tr=[obj ve];
            if(tr[0]<0||tr[1]<0||tr[2]<0)
                continue;
            
            area0=triangle_perimetre([self interp:[points objectAtIndex:tr[0]]],
                                [self interp:[points objectAtIndex:tr[1]]],
                                [self interp:[points objectAtIndex:tr[2]]]);
            area1=triangle_perimetre(*(float3D*)[[points objectAtIndex:tr[0]] co],
                                *(float3D*)[[points objectAtIndex:tr[1]] co],
                                *(float3D*)[[points objectAtIndex:tr[2]] co]);
            g=1;//pow(area0/area1,2);
            
            for(j=0;j<3;j++)
            {
                co=[[colours objectAtIndex:tr[j]] co];
                if(i==0)
                    glColor4f(g*co[0],co[1]*0.8,co[2]*0.8,1);
                else
                    glColor4f(g*co[0],co[1],co[2],1);
                x=[self interp:[points objectAtIndex:tr[j]]];
                glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
            }
        }
        glEnd();
    }
    [self depth];
}
/*
-(void)drawSurface
{
	int				j;
	float3D			x;
	float			*co;
	int				*tr;
	NSEnumerator	*e;
	id				obj;
	Float3D			*p;
	float			v0,v1;
	
	// display surface triangles
	glBegin(GL_TRIANGLES);
	e=[triangles objectEnumerator];
	while(obj=[e nextObject])
	{
		tr=[obj ve];
		
		for(j=0;j<3;j++)
		{
			co=[[colours objectAtIndex:tr[j]] co];
			glColor4f(co[0],co[1],co[2],0.5);
			
			p=[points objectAtIndex:tr[j]];
			// smooth
			x=[self interp:[points objectAtIndex:tr[j]]];

			// flexure
			mobius1(x.z,x.x,angle1,0.5,&v0,&v1);
			x.x=v1;
			x.y=x.y;
			x.z=v0;

			// left-right
			mobius2(x.y,x.x,angle2,0.1,&v0,&v1);
			x.x=v1;
			x.y=v0;
	
			glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
		}
	}
	glEnd();
}
*/
-(void)drawWireframe
{
	int				j;
	float3D			x;
	int				*tr;
	NSEnumerator	*e;
	id				obj;
	Float3D			*p;
	
	// display surface triangles
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glEnable(GL_POLYGON_OFFSET_FILL);
	glPolygonOffset(1,1);
    glLineWidth(1);

	glCullFace(GL_FRONT);
    glBegin(GL_TRIANGLES);
	glColor4f(0,0,0,1);
	e=[triangles objectEnumerator];
	while(obj=[e nextObject])
	{
		tr=[obj ve];
		
		for(j=0;j<3;j++)
		{			
			p=[points objectAtIndex:tr[j]];
			// smooth
			x=[self interp:[points objectAtIndex:tr[j]]];
			glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
		}
	}
	glEnd();
    
	glCullFace(GL_BACK);
    glBegin(GL_TRIANGLES);
	glColor4f(0,0,0,1);
	e=[triangles objectEnumerator];
	while(obj=[e nextObject])
	{
		tr=[obj ve];
		
		for(j=0;j<3;j++)
		{
			p=[points objectAtIndex:tr[j]];
			// smooth
			x=[self interp:[points objectAtIndex:tr[j]]];
			glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
		}
	}
	glEnd();

	glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
}
-(void)drawEdges
{
	int		i;
	float3D	x;
	int		*ed;
	float	black[]={0,0,0};
	
	// display surface triangles' edges
	//glEnable(GL_POLYGON_OFFSET_FILL);
	//glPolygonOffset(1,1);
	glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
	glBegin(GL_LINES);
	
	for(i=0;i<[edges count];i++)
	{
		ed=[[edges objectAtIndex:i] ve];
		
		glColor3fv(black);
		x=[self interp:[points objectAtIndex:ed[0]]];
		glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
		x=[self interp:[points objectAtIndex:ed[1]]];
		glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
	}
	glEnd();
	glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
}
/*
-(void)drawEdges
{
	int		i;
	float3D	x;
	int		*ed;
	float	black[]={0,0,0};
	Float3D	*p;
	float	v0,v1,R=0.3;
	
	// display surface triangles' edges
	glEnable(GL_POLYGON_OFFSET_FILL);
	glPolygonOffset(1,1);
	glBegin(GL_LINES);
	
	for(i=0;i<[edges count];i++)
	{
		ed=[[edges objectAtIndex:i] ve];
		
		glColor3fv(black);
		
		
		p=[points objectAtIndex:ed[0]];
		// smooth
		x=[self interp:p];
		// flexure
		mobius1(x.z,x.x,angle1,0.5,&v0,&v1);
		x.x=v1;
		x.y=x.y;
		x.z=v0;
		// left-right
		mobius2(x.y,x.x,angle2,R,&v0,&v1);
		x.x=v1;
		x.y=v0;
		glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
		
		
		p=[points objectAtIndex:ed[1]];
		// smooth
		x=[self interp:p];
		// flexure
		mobius1(x.z,x.x,angle1,0.5,&v0,&v1);
		x.x=v1;
		x.y=x.y;
		x.z=v0;
		// left-right
		mobius2(x.y,x.x,angle2,R,&v0,&v1);
		x.x=v1;
		x.y=v0;
		glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
	}
	glEnd();
}
*/
-(void)drawNormals
{
	int		i;
	int		*tr;
	float	red[]={1,0,0};
	float3D	a,b,c,p,x;

	printf("normals\n");
	
	// display triangle's normals
	glBegin(GL_LINES);
	for(i=0;i<[triangles count];i++)
	{
		glColor3fv(red);

		tr=[[triangles objectAtIndex:i] ve];
		
		a=*(float3D*)[[points objectAtIndex:tr[0]] co];
		b=*(float3D*)[[points objectAtIndex:tr[1]] co];
		c=*(float3D*)[[points objectAtIndex:tr[2]] co];
		x=sca3D(add3D(a,add3D(b,c)),1/3.0);
		glVertex3f(x.x-center.x,x.y-center.y,x.z-center.z);
		
		p=cross3D(sub3D(b,a),sub3D(c,a));
		p=add3D(x,sca3D(p,1/norm3D(p)));
		glVertex3f(p.x-center.x,p.y-center.y,p.z-center.z);
	}
	glEnd();
}

-(void)drawVertices
{
	int		i,j;
	float3D	x;
	float3D	tmp;
	float	green[]={0,1,0};
	float	usz=0.0025;	// size of unselected unvertices

	// display vertices
	glBegin(GL_TRIANGLES);
	for(j=0;j<[points count];j++)
	if([[points objectAtIndex:j] deleted]==NO)
	{
		x=[self interp:[points objectAtIndex:j]];
		for(i=0;i<12;i++)
		{
			glColor3fv(green);
			tmp=sub3D(add3D(sca3D(cp[ct[i].a],usz*zoom),x),center); glVertex3fv((float*)&tmp);
			tmp=sub3D(add3D(sca3D(cp[ct[i].b],usz*zoom),x),center); glVertex3fv((float*)&tmp);
			tmp=sub3D(add3D(sca3D(cp[ct[i].c],usz*zoom),x),center); glVertex3fv((float*)&tmp);
		}
	}
	glEnd();
}
-(void)drawSelectedVertices
{
	int		i,j;
	Float3D	*p;
	float3D	x;
	float3D	tmp;
	float	ssz=0.01;	// size of selected vertices

	// display vertices
	glBegin(GL_TRIANGLES);
	numberOfSelectedVertices=0;
	for(j=0;j<[points count];j++)
	{
		p=[points objectAtIndex:j];
		if([p deleted]==NO && [p selected]==YES)
		{
			numberOfSelectedVertices++;
			x=[self interp:p];
			for(i=0;i<12;i++)
			{
				glColor3fv((float*)&cc[i]);
				tmp=sub3D(add3D(sca3D(cp[ct[i].a],ssz*zoom),x),center); glVertex3fv((float*)&tmp);
				tmp=sub3D(add3D(sca3D(cp[ct[i].b],ssz*zoom),x),center); glVertex3fv((float*)&tmp);
				tmp=sub3D(add3D(sca3D(cp[ct[i].c],ssz*zoom),x),center); glVertex3fv((float*)&tmp);
			}
		}
	}
	glEnd();
}

-(Float3D*)addVertex:(float3D)p
{
	Float3D	*po,*co;
	po=[[Float3D alloc] init];
	[po setCoords:p.x:p.y:p.z];
	[points addObject:po];
	[po release];

	co=[[Float3D alloc] init];
	[co setCoords:0.5:0.5:0.5];
	[co setSelected:YES];
	[colours addObject:co];
	[co release];
	
	return po;
	
//		[self addEdge];
}
-(void)addEdge
{
	int		i,n,v0,v1;
	Float3D	*p;
	Int2D	*ed;
	
	n=0;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p selected]*(![p deleted]))
		{
			if(n==0)		{	v0=i;	n=1;			}
			else if(n==1)	{	v1=i;	n=2;	break;	}
		}
	}
	if(n<2)
		return;
	
	ed=[[Int2D alloc] init];
	[ed setVerts:v0:v1];
	[edges addObject:ed];
	[ed release];
}
-(void)addTriangle
{
	int		i,n,v0,v1,v2,*ve;
	Float3D	*p;
	Int3D	*tr;
	
	n=0;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p selected]*(![p deleted]))
		{
			if(n==0)		{	v0=i;	n=1;			}
			else if(n==1)	{	v1=i;	n=2;			}
			else if(n==2)	{	v2=i;	n=3;	break;	}
		}
	}
	if(n<3)
		return;
	
	// if the triangle existe already, invert its normal.
	// Most often, this will be a newly created triangle,
	// so start searching from the end.
	for(i=[triangles count]-1;i>=0;i--)
	{
		tr=[triangles objectAtIndex:i];
		ve=[tr ve];
		if((v0==ve[0] ||v0==ve[1] ||v0==ve[2])&&
		   (v1==ve[0] ||v1==ve[1] ||v1==ve[2])&&
		   (v2==ve[0] ||v2==ve[1] ||v2==ve[2]))
		{
			[tr setVerts:ve[0]:ve[2]:ve[1]];
			return;
		}
	}
	
	tr=[[Int3D alloc] init];
	[tr setVerts:v0:v1:v2];
	[triangles addObject:tr];
	[tr release];
}
-(void)deleteSelectedVertices
{
	int		i,j;
	int		*tr,*ed;
	Float3D	*p;
	NSMutableArray	*trianglesToRemove=[NSMutableArray new];
	NSMutableArray	*edgesToRemove=[NSMutableArray new];
		
	// look for affected triangles, edges and points
	for(j=0;j<[triangles count];j++)
	{
		tr=[[triangles objectAtIndex:j] ve];
		if(	[(Float3D*)[points objectAtIndex:tr[0]] selected] ||
			[(Float3D*)[points objectAtIndex:tr[1]] selected] ||
			[(Float3D*)[points objectAtIndex:tr[2]] selected])
			[trianglesToRemove addObject:[triangles objectAtIndex:j]];
	}
	[triangles removeObjectsInArray:trianglesToRemove];
	for(j=0;j<[edges count];j++)
	{
		ed=[[edges objectAtIndex:j] ve];
		if(	[(Float3D*)[points objectAtIndex:ed[0]] selected] ||
			[(Float3D*)[points objectAtIndex:ed[1]] selected])
			[edgesToRemove addObject:[edges objectAtIndex:j]];
	}
	[edges removeObjectsInArray:edgesToRemove];
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p selected])
		{
			[p setDeleted:YES];
			[p setSelected:NO];
		}
	}
}
-(void)deleteSelectedTriangles
{
	int				j;
	int				*tr;
	NSMutableArray	*trianglesToRemove=[NSMutableArray new];
		
	// look for affected triangles and edges
	for(j=0;j<[triangles count];j++)
	{
		tr=[[triangles objectAtIndex:j] ve];
		if( [[points objectAtIndex:tr[0]] selected] &&
			[[points objectAtIndex:tr[1]] selected] &&
			[[points objectAtIndex:tr[2]] selected] )
			[trianglesToRemove addObject:[triangles objectAtIndex:j]];
	}
	[triangles removeObjectsInArray:trianglesToRemove];
}
-(void)cleanMesh
{
	int				np=[points count];
	int				*lut=(int*)calloc(np,sizeof(int));
	NSMutableArray	*newPoints=[NSMutableArray new];
	int				i,j,*ve;
	Float3D			*p;
	Int3D			*t;
	Int2D			*e;
	
	// update points
	j=0;
	for(i=0;i<np;i++)
	{
		p=[points objectAtIndex:i];
		if(![p deleted])
		{
			[newPoints addObject:p];
			lut[i]=j++;					// lut[#old]=#new
		}
	}
	[points release];
	points=newPoints;
	
	// update triangles
	for(i=0;i<[triangles count];i++)
	{
		t=[triangles objectAtIndex:i];
		ve=[t ve];
		[t setVerts:lut[ve[0]]:lut[ve[1]]:lut[ve[2]]];
	}

	// update edges
	for(i=0;i<[edges count];i++)
	{
		e=[edges objectAtIndex:i];
		ve=[e ve];
		[e setVerts:lut[ve[0]]:lut[ve[1]]];
	}
}
-(void)setCenterToSelectedVertex
{
	int		i,n;
	float3D	o={0,0,0};
	
	n=0;
	for(i=0;i<[points count];i++)
	{
		if([[points objectAtIndex:i] selected])
		{
			o=add3D(o,*(float3D*)[[points objectAtIndex:i] co]);
			n++;
		}
	}
	center=sca3D(o,1/(float)n);
}

#pragma mark -
-(void)depth
{
    int			i;
    float		n,max;
	float3D		o,pmin,pmax;
	float		*p,*c;
	float		nump=[points count];
	Float3D		*co;

    if(nump==0)
        return;
    
	o=(float3D){0,0,0};
	p=[(Float3D*)[points objectAtIndex:0] co];
	pmin=pmax=*(float3D*)p;
	for(i=0;i<nump;i++)
	{
		p=[(Float3D*)[points objectAtIndex:i] co];
		o=(float3D){o.x+p[0],o.y+p[1],o.z+p[2]};
		if(p[0]<pmin.x)	pmin.x=p[0];
		if(p[1]<pmin.y)	pmin.y=p[1];
		if(p[2]<pmin.z)	pmin.z=p[2];
		if(p[0]>pmax.x)	pmax.x=p[0];
		if(p[1]>pmax.y)	pmax.y=p[1];
		if(p[2]>pmax.z)	pmax.z=p[2];
	}
	o=(float3D){o.x/nump,o.y/nump,o.z/nump};

	if(colours)
		[colours release];
	colours=[[NSMutableArray new] retain];

    max=0;
    for(i=0;i<nump;i++)
    {
		p=[(Float3D*)[points objectAtIndex:i] co];
        n=	pow(2*(p[0]-o.x)/(pmax.x-pmin.x),2) +
			pow(2*(p[1]-o.y)/(pmax.y-pmin.y),2) +
            pow(2*(p[2]-o.z)/(pmax.z-pmin.z),2);

		co=[[Float3D alloc] init];
		[co setCoords:sqrt(n):sqrt(n):sqrt(n)];
		[colours addObject:co];
		[co release];

        if(sqrt(n)>max)
			max=sqrt(n);
    }
    max*=1.05;	// pure white is not nice...
    for(i=0;i<nump;i++)
	{
		co=[colours objectAtIndex:i];
		c=[co co];
		[co setCoords:c[0]/max:c[1]/max:c[2]/max];
	}
}
-(void)foldingPattern
{
    int			i,*ve;
	float3D		*tmp,*tmp1,a,b,c,nn;
	int			*itmp;
	int			np=[points count];
	Float3D		*co;
	float		*x;
	
    // compute smoothing direction as the vector to the average of neighbour vertices
    itmp=(int*)calloc(np,sizeof(int));
    tmp=(float3D*)calloc(np,sizeof(float3D));
	for(i=0;i<[triangles count];i++)
	{
		ve=[[triangles objectAtIndex:i] ve];
		a=*(float3D*)[[points objectAtIndex:ve[0]] co];
		b=*(float3D*)[[points objectAtIndex:ve[1]] co];
		c=*(float3D*)[[points objectAtIndex:ve[2]] co];
		tmp[ve[0]]=add3D(tmp[ve[0]],add3D(b,c));
		tmp[ve[1]]=add3D(tmp[ve[1]],add3D(c,a));
		tmp[ve[2]]=add3D(tmp[ve[2]],add3D(a,b));
		itmp[ve[0]]+=2;
		itmp[ve[1]]+=2;
		itmp[ve[2]]+=2;
	}
	for(i=0;i<np;i++)
		tmp[i]=sub3D(sca3D(tmp[i],1/(float)itmp[i]),*(float3D*)[[points objectAtIndex:i] co]);
	
    // compute normal direction as the average of neighbour triangle normals
    tmp1=(float3D*)calloc(np,sizeof(float3D));
	for(i=0;i<[triangles count];i++)
	{
		ve=[[triangles objectAtIndex:i] ve];
		a=*(float3D*)[[points objectAtIndex:ve[0]] co];
		b=*(float3D*)[[points objectAtIndex:ve[1]] co];
		c=*(float3D*)[[points objectAtIndex:ve[2]] co];
		nn=cross3D(sub3D(b,a),sub3D(c,a));
		nn=sca3D(nn,1/norm3D(nn));
    	tmp1[ve[0]]=add3D(tmp1[ve[0]],nn);
    	tmp1[ve[1]]=add3D(tmp1[ve[1]],nn);
    	tmp1[ve[2]]=add3D(tmp1[ve[2]],nn);
	}
    for(i=0;i<np;i++)
    	tmp1[i]=sca3D(tmp1[i],1/(float)itmp[i]);
    
    // folding pattern: gyri in red, sulci in green
	for(i=0;i<np;i++)
	{
		co=[colours objectAtIndex:i];
		x=[co co];
		
		if(-dot3D(tmp1[i],tmp[i])>0)
			[co setCoords:x[0]:0.5*x[1]:0.5*x[2]];
		else
			[co setCoords:0.5*x[0]:x[1]:0.5*x[2]];
	}
	free(tmp);
	free(tmp1);
}
#pragma mark -
-(void)exportTextToPath:(NSString*)path
{
	FILE	*f;
	int		i;
	float3D	p;
	int3D	t;
    int2D   e;
	
	f=fopen([path UTF8String],"w");
	fprintf(f,"%i %i %i\n",(int)[points count],(int)[triangles count],(int)[edges count]);
	for(i=0;i<[points count];i++)
	{
		p=*(float3D*)[(Float3D*)[points objectAtIndex:i] co];
		fprintf(f,"%f %f %f\n",p.x,p.y,p.z);
	}
	for(i=0;i<[triangles count];i++)
	{
		t=*(int3D*)[(Int3D*)[triangles objectAtIndex:i] ve];
		fprintf(f,"%i %i %i\n",t.a,t.b,t.c);
	}
	for(i=0;i<[edges count];i++)
	{
		e=*(int2D*)[(Int2D*)[edges objectAtIndex:i] ve];
		fprintf(f,"%i %i\n",e.a,e.b);
	}
	fclose(f);
}
-(void)exportPlyToPath:(NSString*)path
{
	FILE	*f;
	int		i;
	float3D	p;
	int3D	t;

	f=fopen([path UTF8String],"w");

    // WRITE HEADER
    fprintf(f,"ply\n");
    fprintf(f,"format ascii 1.0\n");
    fprintf(f,"comment meshconvert, R. Toro 2010\n");
    fprintf(f,"element vertex %i\n",(int)[points count]);
    fprintf(f,"property float x\n");
    fprintf(f,"property float y\n");
    fprintf(f,"property float z\n");
    fprintf(f,"element face %i\n",(int)[triangles count]);
    fprintf(f,"property list uchar int vertex_indices\n");
    fprintf(f,"end_header\n");
    // WRITE VERTICES
    for(i=0;i<[points count];i++)
    {
        p=*(float3D*)[(Float3D*)[points objectAtIndex:i] co];
        fprintf(f,"%f %f %f \n",p.x,p.y,p.z);
    }
    // WRITE TRIANGLES
    for(i=0;i<[triangles count];i++)
    {
        t=*(int3D*)[(Int3D*)[triangles objectAtIndex:i] ve];
        fprintf(f,"3 %i %i %i\n",t.a,t.b,t.c);
    }
    fclose(f);
}
void import_txt(float3D **p, int3D **t, int2D **e, int *np, int *nt, int *ne, char *path)
{
	FILE	*f;
	int		i;
	char	str[256];
	
	f=fopen(path,"r");
	fgets(str,256,f);
    *np=0;
    *nt=0;
    *ne=0;
	sscanf(str," %i %i %i ",np,nt,ne);
	*p=(float3D*)calloc(*np,sizeof(float3D));
    for(i=0;i<*np;i++)
	{
		fgets(str,256,f);
		sscanf(str," %f %f %f ",&((*p)[i].x),&((*p)[i].y),&((*p)[i].z));
	}

    *t=(int3D*)calloc(*nt,sizeof(int3D));
	for(i=0;i<*nt;i++)
	{
		fgets(str,256,f);
		sscanf(str," %i %i %i ",&((*t)[i].a),&((*t)[i].b),&((*t)[i].c));
	}
	*e=(int2D*)calloc(*ne,sizeof(int2D));
	for(i=0;i<*ne;i++)
	{
		fgets(str,256,f);
		sscanf(str," %i %i ",&((*e)[i].a),&((*e)[i].b));
	}
	fclose(f);
}
void import_ply(float3D **p, int3D **t, int2D **e, int *np, int *nt, int *ne, char *path)
{
	FILE	*f;
	int		i,x;
	char	str[256],str1[256],str2[256];
	float3D	center={0,0,0};
	
    f=fopen(path,"r");
    if(f==NULL){printf("ERROR: Cannot open file\n");return;}
    
    // READ HEADER
    *np=*nt=*ne=0;
    do
    {
        fgets(str,511,f);
        sscanf(str," %s %s %i ",str1,str2,&x);
        if(strcmp(str1,"element")==0&&strcmp(str2,"vertex")==0)
            *np=x;
        else
        if(strcmp(str1,"element")==0&&strcmp(str2,"face")==0)
            *nt=x;
    }
    while(strcmp(str1,"end_header")!=0 && !feof(f));
    if(*np * *nt==0)
    {
        printf("ERROR: Bad Ply file header format\n");
        return;
    }
    *p = (float3D*)calloc(*np,sizeof(float3D));
    *t = (int3D*)calloc(*nt,sizeof(int3D));
    // READ VERTICES
    if(*p==NULL){printf("ERROR: Not enough memory for mesh vertices\n");return;}
    for(i=0;i<*np;i++)
    {
        fgets(str,512,f);
        sscanf(str," %f %f %f ",&((*p)[i].x),&((*p)[i].y),&((*p)[i].z));
   		center=(float3D){center.x+(*p)[i].x,center.y+(*p)[i].y,center.z+(*p)[i].z};
    }
	center=(float3D){center.x/(float)(*np),center.y/(float)(*np),center.z/(float)(*np)};
	/*
    for(i=0;i<*np;i++)
		(*p)[i]=(float3D){(*p)[i].x-center.x,(*p)[i].y-center.y,(*p)[i].z-center.z};
     */
    printf("Read %i vertices\n",*np);
    
    // READ TRIANGLES
    if(*t==NULL){printf("ERROR: Not enough memory for mesh triangles\n"); return;}
    for(i=0;i<*nt;i++)
        fscanf(f," 3 %i %i %i ",&((*t)[i].a),&((*t)[i].b),&((*t)[i].c));
    printf("Read %i triangles\n",*nt);
    
    fclose(f);
}
-(void)writeToPath:(NSString*)path
{
	NSString    *ext=[path pathExtension];
	
	[self cleanMesh];

	if([ext isEqualToString:@"txt"])
        [self exportTextToPath:path];
    else
    if([ext isEqualToString:@"ply"])
        [self exportPlyToPath:path];
	;
}
-(void)readFromPath:(NSString*)path
{
	NSString    *ext=[path pathExtension];
    char	*str=(char*)[path UTF8String];
	float3D	*p;
	int3D	*t;
    int2D   *e;
	int		i,nptmp,nttmp,netmp;
	Float3D	*po;
	Int3D	*tr;
    Int2D   *ed;
    float3D	mi,ma;

	if([ext isEqualToString:@"txt"])
        import_txt(&p,&t,&e,&nptmp,&nttmp,&netmp,str);
    else
    if([ext isEqualToString:@"ply"])
        import_ply(&p,&t,&e,&nptmp,&nttmp,&netmp,str);
	
	if(points)									// add points
		[points release];
	points=[[NSMutableArray new] retain];
	for(i=0;i<nptmp;i++)
	{
		po=[[Float3D alloc] init];
		[po setCoords:p[i].x:p[i].y:p[i].z];
		[points addObject:po];
		[po release];
	}
	
	if(triangles)								// add triangles
		[triangles release];
	triangles=[[NSMutableArray new] retain];
	for(i=0;i<nttmp;i++)
	{
		tr=[[Int3D alloc] init];
		[tr setVerts:t[i].a:t[i].b:t[i].c];
		[triangles addObject:tr];
		[tr release];
	}
	
	if(edges)								// add edges
		[edges release];
	edges=[[NSMutableArray new] retain];
	for(i=0;i<netmp;i++)
	{
		ed=[[Int2D alloc] init];
		[ed setVerts:e[i].a:e[i].b];
		[edges addObject:ed];
		[ed release];
	}
	
    // configure display center
    mi=ma=p[0];
    for(i=0;i<nptmp;i++)
    {
        if(p[i].x<mi.x) mi.x=p[i].x;
        if(p[i].y<mi.y) mi.y=p[i].y;
        if(p[i].z<mi.z) mi.z=p[i].z;
        if(p[i].x>ma.x) ma.x=p[i].x;
        if(p[i].y>ma.y) ma.y=p[i].y;
        if(p[i].z>ma.z) ma.z=p[i].z;
    }
    center=(float3D){(mi.x+ma.x)/2.0,(mi.y+ma.y)/2.0,(mi.z+ma.z)/2.0};

    free(p);
	free(t);
	
	[self depth];								// add colours (depth)

	filename=[path retain];
}
-(void)readVerticesFromPath:(NSString*)path
{
    char *str=(char*)[path UTF8String];
    float3D	*p;
    int3D	*t;
    int2D   *e;
    int		nptmp,nttmp,netmp,i;
    
    import_txt(&p,&t,&e,&nptmp,&nttmp,&netmp,str);
    
    if(nptmp!=[points count])
    {
        [[NSAlert	alertWithMessageText:@"Incorrect number of vertices"
                         defaultButton:nil alternateButton:nil otherButton:nil
             informativeTextWithFormat:@"It is %i, and should be %i.\n",nptmp,(int)[points count]]
         runModal];
        return;
    }
    
    for(i=0;i<nptmp;i++)
        [[points objectAtIndex:i] setCoords:p[i].x:p[i].y:p[i].z];
    
    free(p);
    free(t);
    free(e);
}
-(void)readSmoothedVerticesFromPath:(NSString*)path
{
    char *str=(char*)[path UTF8String];
    NSString *ext=[path pathExtension];
    float3D	*p;
    int3D	*t;
    int2D   *e;
    int		nptmp,nttmp,netmp,i;
    float3D min0,max0,min1,max1,p1;
    float   s;
    
    if([ext isEqualToString:@"txt"])
        import_txt(&p,&t,&e,&nptmp,&nttmp,&netmp,str);
    else
    if([ext isEqualToString:@"ply"])
        import_ply(&p,&t,&e,&nptmp,&nttmp,&netmp,str);
    
    if(nptmp!=[points count])
    {
        [[NSAlert	alertWithMessageText:@"Incorrect number of vertices"
                         defaultButton:nil alternateButton:nil otherButton:nil
             informativeTextWithFormat:@"It is %i, and should be %i.\n",nptmp,(int)[points count]]
         runModal];
        return;
    }
    
    min0=max0=p[0];
    min1=max1=*(float3D*)[[points objectAtIndex:0] co];
    for(i=0;i<nptmp;i++) {
        if(p[i].x<min0.x) min0.x=p[i].x;
        if(p[i].y<min0.y) min0.y=p[i].y;
        if(p[i].z<min0.z) min0.z=p[i].z;
        if(p[i].x>max0.x) max0.x=p[i].x;
        if(p[i].y>max0.y) max0.y=p[i].y;
        if(p[i].z>max0.z) max0.z=p[i].z;

        p1=*(float3D*)[[points objectAtIndex:i] co];
        if(p1.x<min1.x) min1.x=p1.x;
        if(p1.y<min1.y) min1.y=p1.y;
        if(p1.z<min1.z) min1.z=p1.z;
        if(p1.x>max1.x) max1.x=p1.x;
        if(p1.y>max1.y) max1.y=p1.y;
        if(p1.z>max1.z) max1.z=p1.z;
    }
    s=(max1.x-min1.x)*(max1.y-min1.y)*(max1.z-min1.z) / ((max0.x-min0.x)*(max0.y-min0.y)*(max0.z-min0.z));
    s=1;//pow(s,0.33333);
    
    for(i=0;i<nptmp;i++)
        [[points objectAtIndex:i] setSmoothCoords:p[i].x*s:p[i].y*s:p[i].z*s];
    
    free(p);
    free(t);
    //free(e);
}
-(int)numberOfSelectedVertices
{
	return numberOfSelectedVertices;
}
-(int)indexOfFirstSelectedVertex
{
	int i;
	Float3D	*p;
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p deleted]==NO && [p selected]==YES)
			break;
	}
	return i;
}
-(void)nradio
{
	int		i;
	Float3D	*p;
    float3D co;
	float   R=2.534;
	
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
		if([p selected])
        {
            co=*(float3D*)[p co];
            co=sca3D(co,R/(float)norm3D(co));
            [p setCoords:co.x:co.y:co.z];
        }
	}
}
-(void)flipEdge
{
    printf("flipEdge\n");
	int		i0,i1,j,tmp[3];
	int		*tr0,*tr1;
	int		found[3];
	NSEnumerator	*e = [triangles objectEnumerator];
	Int3D		*obj,*obj0,*obj1;
    
	obj0=NULL;
    obj1=NULL;
    
    while(obj=[e nextObject])
	{
		tr0=[obj ve];
        
        for(j=0;j<3;j++)
        {
			found[j]=([[points objectAtIndex:tr0[j]] selected]==YES) && ([[points objectAtIndex:tr0[j]] deleted]==NO);
            if([[points objectAtIndex:tr0[j]] selected]==NO)
                i0=j;
        }
		if(found[0]+found[1]+found[2]!=2)
			continue;
        obj0=obj;
        printf("found obj0\n");
        break;
	}
	while(obj=[e nextObject])
	{
		tr1=[obj ve];
		for(j=0;j<3;j++)
        {
			found[j]=([[points objectAtIndex:tr1[j]] selected]==YES) && ([[points objectAtIndex:tr1[j]] deleted]==NO);
            if([[points objectAtIndex:tr1[j]] selected]==NO)
                i1=j;
        }
		if(found[0]+found[1]+found[2]!=2)
			continue;
        
		if(tr0[(i0+1)%3]!=tr1[(i1+2)%3] || tr0[(i0+2)%3]!=tr1[(i1+1)%3])
            continue;
        obj1=obj;
        printf("found obj1\n");
        break;
	}
    
    if(obj0==NULL || obj1==NULL)
        return;
    
    printf("%i,%i,%i %i,%i,%i\n",tr0[i0],tr0[(i0+1)%3],tr0[(i0+2)%3],tr1[i1],tr1[(i1+1)%3],tr1[(i1+2)%3]);
    printf("%i,%i,%i %i,%i,%i\n",tr0[i0],tr1[i1],tr1[(i1+1)%3],tr0[i0],tr0[(i0+1)%3],tr1[i1]);
    tmp[0]=tr0[i0];
    tmp[1]=tr0[(i0+1)%3];
    tmp[2]=tr1[i1];
    [obj0 setVerts:tr0[i0] :tr1[i1] :tr1[(i1+1)%3]];
    [obj1 setVerts:tmp[0] :tmp[1] :tmp[2]];
}
-(void)applyRotation
{
    printf("Mesh.m [applyRotation]\n");
    float	m[16],r[3],*v;
    glGetFloatv(GL_MODELVIEW_MATRIX, m);

	int		i;
	Float3D	*p;
	
	for(i=0;i<[points count];i++)
	{
		p=[points objectAtIndex:i];
        v=[p co];
        v_m(r,v,m);
        [p setCoords:r[0]:r[1]:r[2]];
	}
}
-(void)configureNeighbours
{
    // find incident triangles for every vertex

    int             i;
    int             *tr;
    
    if([neighbours count])
        [neighbours removeAllObjects];
    for(i=0;i<[points count];i++)
        [neighbours addObject:[NSMutableArray arrayWithCapacity:32]];
    for(i=0;i<[triangles count];i++)
    {
        tr=[[triangles objectAtIndex:i] ve];
        [[neighbours objectAtIndex:tr[0]] addObject:[NSNumber numberWithInt:i]];
        [[neighbours objectAtIndex:tr[1]] addObject:[NSNumber numberWithInt:i]];
        [[neighbours objectAtIndex:tr[2]] addObject:[NSNumber numberWithInt:i]];
    }
}
#pragma mark -
#pragma mark [ Möbius ]
void mobius1(float x0, float y0, float th, float R, float *x1, float *y1)
{
	float	x,y;
	float	a;
	float	w,ss;
	float	s0x,s0y,s0z;
	float	s1x,s1y,s1z;
	
	a=-22.5*kPi/180.0;
	a=-30.5*kPi/180.0;
	a=0;
	
	x=x0*cos(a)-y0*sin(a);
	y=x0*sin(a)+y0*cos(a);
	
	ss=sqrt(x*x+y*y);
	w=atan2(2*R,ss);
	
	s0x=x*R*sin(2*w)/ss;
	s0y=y*R*sin(2*w)/ss;
	s0z=R*(1+cos(2*w));
	
	s1x=s0x;
	s1y=s0y*cos(th)-(s0z-R)*sin(th);
	s1z=s0y*sin(th)+(s0z-R)*cos(th)+R;
	
	*x1=s1x/(1-s1z/(2*R));
	*y1=s1y/(1-s1z/(2*R));
	
	/*
	x0=*x1;
	y0=*y1;
	
	*x1=x0*cos(a)-y0*sin(a);
	*y1=x0*sin(a)+y0*cos(a);
	 */
}
void mobius2(float x0, float y0, float th, float R, float *x1, float *y1)
{
	float	x,y;
	float	a;
	float	w,ss;
	float	s0x,s0y,s0z;
	float	s1x,s1y,s1z;
	
	a=0;
	
	x=x0*cos(a)-y0*sin(a);
	y=x0*sin(a)+y0*cos(a);
	
	ss=sqrt(x*x+y*y);
	w=atan2(2*R,ss);
	
	s0x=x*R*sin(2*w)/ss;
	s0y=y*R*sin(2*w)/ss;
	s0z=R*(1+cos(2*w));
	
	s1x=s0x;
	s1y=s0y*cos(th)-(s0z-R)*sin(th);
	s1z=s0y*sin(th)+(s0z-R)*cos(th)+R;
	
	*x1=s1x/(1-s1z/(2*R));
	*y1=s1y/(1-s1z/(2*R));
}
-(void)setAngle1:(float)a
{
	angle1=a;
}
-(void)setAngle2:(float)a
{
	angle2=a;
}
#pragma mark -
#pragma mark -
/*
 * dijkstra.js
 *
 * Dijkstra's single source shortest path algorithm in JavaScript.
 *
 * Cameron McCormack <cam (at) mcc.id.au>
 *
 * Permission is hereby granted to use, copy, modify and distribute this
 * code for any purpose, without fee.
 *
 * Initial version: October 21, 2004
 */

/*
-(void)shortestPath:(int)startVertex
{
    char    *done;
    float   *pathLengths;
    int     *predecesors;
    int     i,j,Infinity=1000;
    
    done=(char*)calloc([points count],1);
    pathLengths=(float*)calloc([points count],sizeof(float));
    predecesors=(int*)calloc([points count],sizeof(int));
    done[startVertex] = true;
    
    
    for(i=0;i<[points count];i++)
    {
        pathLengths[i] = edges[startVertex][i];
        if (edges[startVertex][i] != Infinity) {
            predecessors[i] = startVertex;
        }
    }
    pathLengths[startVertex]=0;
    for(i=0;i<[points count]-1;i++)
    {
        int closest=-1;
        float closestDistance = Infinity;
        for (var j = 0; j < [points count]; j++) {
            if (!done[j] && pathLengths[j] < closestDistance) {
                closestDistance = pathLengths[j];
                closest = j;
            }
        }
        done[closest] = true;
        for (var j = 0; j < [points count]; j++) {
            if (!done[j]) {
                var possiblyCloserDistance = pathLengths[closest] + edges[closest][j];
                if (possiblyCloserDistance < pathLengths[j]) {
                    pathLengths[j] = possiblyCloserDistance;
                    predecessors[j] = closest;
                }
            }
        }
    }
    return { "startVertex": startVertex,
        "pathLengths": pathLengths,
        "predecessors": predecessors };
}

function constructPath(shortestPathInfo, endVertex) {
    var path = [];
    while (endVertex != shortestPathInfo.startVertex) {
        path.unshift(endVertex);
        endVertex = shortestPathInfo.predecessors[endVertex];
    }
    return path;
}

// Example //////////////////////////////////////////////////////////////////

// The adjacency matrix defining the graph.
var _ = Infinity;
var e = [
         [ _, _, _, _, _, _, _, _, 4, 2, 3 ],
         [ _, _, 5, 2, 2, _, _, _, _, _, _ ],
         [ _, 5, _, _, _, 1, 4, _, _, _, _ ],
         [ _, 2, _, _, 3, 6, _, 3, _, _, _ ],
         [ _, 2, _, 3, _, _, _, 4, 3, _, _ ],
         [ _, _, 1, 6, _, _, 2, 5, _, _, _ ],
         [ _, _, 4, _, _, 2, _, 5, _, _, 3 ],
         [ _, _, _, 3, 4, 5, 5, _, 3, 2, 4 ],
         [ 4, _, _, _, 3, _, _, 3, _, 3, _ ],
         [ 2, _, _, _, _, _, _, 2, 3, _, 3 ],
         [ 3, _, _, _, _, _, 3, 4, _, 3, _ ]
         ];

// Compute the shortest paths from vertex number 1 to each other vertex
// in the graph.
var shortestPathInfo = shortestPath(e, 11, 1);

// Get the shortest path from vertex 1 to vertex 6.
var path1to6 = constructPath(shortestPathInfo, 6);
*/
 @end

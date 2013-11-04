//
//  PKMeetViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKMeetViewController.h"



@interface PKMeetViewController ()

@end

@implementation PKMeetViewController

@synthesize bleManager, guiRefreshTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bleManager = [[HxMBLEConnectionManager alloc] initWithDeleget:self];
    devicesArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) connectClicked:(id)sender
{
    if(selectedDevice) {
        [bleManager setReconnectOnDisconnect:YES];
        [bleManager connectToHxmDevice:selectedDevice];
    }
    
}
-(IBAction) disconnectClicked:(id)sende
{
    [bleManager setReconnectOnDisconnect:NO];
    [bleManager disconnectHxmDevice];
}
-(IBAction) startScanClicked:(id)sender
{
    [bleManager disconnectHxmDevice];
    if(devicesArray) {
        [devicesArray removeAllObjects];

    } else {
        devicesArray = [[NSMutableArray alloc] init];

    }
    [bleManager startScan];
    [devicesTableView reloadData];
}
-(IBAction) stopScanClicked:(id)sender
{
    [bleManager stopScan];
}
-(IBAction) exitClicked:(id)sender
{
    exit(0);
}

-(void)dealloc
{
    if(guiRefreshTimer) {
        [guiRefreshTimer invalidate];
        guiRefreshTimer = nil;
    }
    if(bleManager) {
        [bleManager release];
        bleManager = nil;
    }
    [super dealloc];
}

-(void) onUnspportedHarware:(NSString *) error
{
    NSLog(@"$$$$$$$$$$$ Iphone does not support BLE.   Error:%@",error);
}
-(void) onHxmDeviceDiscovered:(CBPeripheral *) device
{
    NSLog(@"$$$$$$$$$$$ HxM device discovered: %@",device);
    if(device && ![devicesArray containsObject:device]) {
        [devicesArray addObject:device];
        [devicesTableView reloadData];
    }
}
-(void) onHxmDeviceConnected:(CBPeripheral *) device
{
    NSLog(@"$$$$$$$$$$$ HxM device Connected: %@",device);
    statusLbl.text = @"Connected";
}
-(void) onHxmdeviceFialedToConnect:(CBPeripheral *)device error:(NSError *)error
{
    NSLog(@"$$$$$$$$$$$ HxM device Failed to connect: %@      Error is:%@",device, error);
}
-(void) onHxmDeviceDisconnected:(CBPeripheral *)device error:(NSError *)error
{
    NSLog(@"$$$$$$$$$$$ HxM device disconnected: %@      Error is:%@",device, error);
    statusLbl.text = @"Not Connected";
}
-(void) onPhysiologicalDataReceived:(PhysiologicalData *) data
{
    NSLog(@"$$$$$$$$$$$ Hxm device data received. HR:%d    isDeviceWorn: %@",[data heartRate],
		  [data isDeviceWorn]?@"YES":@"NO");
    hrLbl.text = [NSString stringWithFormat:@"%d",[data heartRate]];
    deviceWornLbl.text = [NSString stringWithFormat:@"%@",[data isDeviceWorn]?@"YES":@"NO"];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    }
    if (devicesArray)
    {
        CBPeripheral *per = [devicesArray objectAtIndex:indexPath.row];
        CFUUIDRef uuid = [per UUID];
        NSString *name = [per name];
        if(name && ![name isEqualToString:@"(null)"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",name];
        } else if(uuid) {
            CFStringRef strUuid = CFUUIDCreateString(CFAllocatorGetDefault(), uuid);
            cell.textLabel.text = [NSString stringWithFormat:@"%@",strUuid];
        } else {
            cell.textLabel.text = @"Zephyr HxM2";
        }
        //CFStringRef strUuid = CFUUIDCreateString(CFAllocatorGetDefault(), uuid);
        
    }
    //NSLog(@"Device name is:%@",[per name]);
    return  cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [bleManager stopScan];
    selectedDevice = [devicesArray objectAtIndex:indexPath.row];
    //redirect to connected screen
    [self.view addSubview:connectView];
    [deviceNameLbl setText:[NSString stringWithFormat:@"%@",[selectedDevice name]]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [devicesArray count];
}

-(IBAction)backClicked:(id)sender
{
    [bleManager setReconnectOnDisconnect:NO];
    [connectView removeFromSuperview];
    selectedDevice = nil;
    [bleManager disconnectHxmDevice];
}
@end

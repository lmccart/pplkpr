//
//  PKViewController.m
//  pplkpr
//
//  Created by Lauren McCarthy on 7/25/13.
//  Copyright (c) 2013 Lauren McCarthy. All rights reserved.
//

#import "PKViewController.h"
#import "PKMeetViewController.h"
#import "PKLeftViewController.h"
#import "PKInteractionData.h"
#import "PKAppDelegate.h"
#import "Report.h"

@interface PKViewController() <UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableData *receivedData;
}


@property (retain, nonatomic) NSArray *priorityData;
@property (retain, nonatomic) IBOutlet UITableView *priorityView;

@property (nonatomic,strong) NSArray* fetchedReportsArray;
@property (retain, nonatomic) IBOutlet UITableView *reportsView;

@end




@implementation PKViewController

@synthesize peripheralManager, selectedPeripheral;


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	devicesArray = [[NSMutableArray alloc] init];
	self.peripheralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
	
	_priorityData = [[NSArray alloc] init];
	[_priorityView setDelegate:self];
    [_priorityView setDataSource:self];
	
	_fetchedReportsArray = [[PKInteractionData data] getAllReports];
	[_reportsView setDelegate:self];
    [_reportsView setDataSource:self];
	[_reportsView reloadData];
	
	[self requestData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	_fetchedReportsArray = [[PKInteractionData data] getAllReports];
	[_reportsView reloadData];
}



-(IBAction) startScanClicked:(id)sender {
	NSLog(@"start scan");
	[peripheralManager scanForPeripheralsWithServices:nil options:nil];
	
	// start log to file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
	NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
	 
}

-(IBAction) stopScanClicked:(id)sender {
	
	// log back to console
	int stderrSave = dup(STDERR_FILENO);
	fflush(stderr);
	dup2(stderrSave, STDERR_FILENO);
	close(stderrSave);
	NSLog(@"stop scan");
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"manager updated state");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	
    NSLog(@"Discovered %@", peripheral.name);
	
	if (peripheral) {
		selectedPeripheral = [peripheral retain];
		
		//[peripheralManager stopScan];
		NSLog(@"Scanning stopped");
		
		[peripheralManager connectPeripheral:selectedPeripheral options:nil];
	}
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	
    NSLog(@"Peripheral connected");
	
	peripheral.delegate = self;
	// PEND: set reconnect [bleManager setReconnectOnDisconnect:YES];
	// PEND: handle errors
	[peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	
	CBUUID* target = [CBUUID UUIDWithString:@"180d"]; // heart rate service
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service.UUID);
		if([[service.UUID data] isEqualToData:[target data]]) {
			[peripheral discoverCharacteristics:nil forService:service];
		}
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
			 error:(NSError *)error {
	
	CBUUID* target = [CBUUID UUIDWithString:@"2a38"]; // body location characteristic (testing)
    for (CBCharacteristic *characteristic in service.characteristics) {
		if([[characteristic.UUID data] isEqualToData:[target data]]) {
			[peripheral readValueForCharacteristic:characteristic];
		}
        NSLog(@"Discovered characteristic %@ for service %@ notifying %hhd", characteristic.UUID, service.UUID, characteristic.isNotifying);
		[peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error {
	CBUUID* target = [CBUUID UUIDWithString:@"2902"]; // client characteristic configuration
	for(CBDescriptor *descriptor in characteristic.descriptors) {
		NSLog(@"Discovered descriptor %@ for characteristic %@ ", descriptor.UUID, characteristic.UUID);
		if([[descriptor.UUID data] isEqualToData:[target data]]) {
			// need to configure here according to https://developer.bluetooth.org/gatt/descriptors/Pages/DescriptorViewer.aspx?u=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
			NSLog(@"Ready to configure heart rate notifications");
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
			// stopScan should call the following
			// [peripheral setNotifyValue:NO forCharacteristic:characteristic];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
	if (error) {
		return;
	}
	CBUUID* target = [CBUUID UUIDWithString:@"2a37"]; // heart rate measurement characteristic
	if([[characteristic.UUID data] isEqualToData:[target data]]) {
		NSData* data = characteristic.value;
		
		int readOffset = 0;
		
		uint8_t flags;
		[data getBytes:&flags range:NSMakeRange(readOffset, 1)];
		readOffset += 1;
		
		uint8_t HeartRateValueFormat = (flags & (1 << 0)) >> 0;
		uint8_t SensorContactStatus = (flags & (3 << 1)) >> 1;
		uint8_t EnergyExpendedStatus = (flags & (1 << 3)) >> 3;
		uint8_t RRInterval = (flags & (1 << 4)) >> 4;
		
		//        NSLog(@"Heart Rate %@ flags %hhu, %hhu, %hhu, %hhu for %@", characteristic.value, HeartRateValueFormat, SensorContactStatus, EnergyExpendedStatus, RRInterval, characteristic.UUID);
		
		if(HeartRateValueFormat) {
			uint16_t HeartRateMeasurementValue;
			[data getBytes:&HeartRateMeasurementValue range:NSMakeRange(readOffset, sizeof(HeartRateMeasurementValue))];
			readOffset += sizeof(HeartRateMeasurementValue);
			NSLog(@"Heart rate is %hu", HeartRateMeasurementValue);
		} else {
			uint8_t HeartRateMeasurementValue;
			[data getBytes:&HeartRateMeasurementValue range:NSMakeRange(readOffset, sizeof(HeartRateMeasurementValue))];
			readOffset += sizeof(HeartRateMeasurementValue);
			NSLog(@"Heart rate is %hhu", HeartRateMeasurementValue);
		}
		
		if(SensorContactStatus == 2) {
			NSLog(@"Sensor contact is not detected");
		} else if(SensorContactStatus == 3) {
			//			NSLog(@"Sensor contact is detected");
		}
		
		if(EnergyExpendedStatus == 1) {
			uint16_t EnergyExpended;
			[data getBytes:&EnergyExpended range:NSMakeRange(readOffset, sizeof(EnergyExpended))];
			readOffset += sizeof(EnergyExpended);
			NSLog(@"Energy expended is %hu", EnergyExpended);
		}
		
		if(RRInterval) {
			//			NSLog(@"One or more RR-Interval values are present.");
			uint8_t entry = 0;
			while(readOffset < data.length) {
				uint16_t rr;
				[data getBytes:&rr range:NSMakeRange(readOffset, sizeof(rr))];
				NSLog(@"RR-Interval %hhu: %hu", entry, rr);
				entry++;
				readOffset += sizeof(rr);
			}
		}
	} else {
		NSLog(@"Heart Rate %@ for %@", characteristic.value, characteristic.UUID);
	}
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
			 error:(NSError *)error {
	if (!error) {
        NSLog(@"didUpdateNotificationStateForCharacteristic %@ for %@", characteristic.value, characteristic.UUID);
	}
}



#pragma textfield handling

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
}


#pragma table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView == _priorityView) {
		if (_priorityData) {
			return 1;
		}
		else return 0;
	} else if (tableView == _reportsView && [_fetchedReportsArray count] > 0) {
		return 1;
	} else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"NOTIFICATIONS";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == _priorityView) {
		if (_priorityData) {
			return [_priorityData count];
		} else return 0;
	} else if (tableView == _reportsView) {
		return [_fetchedReportsArray count];
	} else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *cellIdentifier = @"cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
	
	if (tableView == _priorityView) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ makes you most %@", [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0], [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:1]];
	} else if (tableView == _reportsView) {
		Report * report = [self.fetchedReportsArray objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@, %@, %@",report.name, report.emotion, report.rating];
	}
	
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == _priorityView) {
		[self pushPersonViewController:[[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0]];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == _priorityView) {
		NSString *text = [NSString stringWithFormat:@"%@ makes you most %@", [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:0], [[_priorityData objectAtIndex:indexPath.row] objectAtIndex:1]];

		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
		
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
												   options:NSStringDrawingUsesLineFragmentOrigin
												   context:nil];
		return rect.size.height+25;
	} else if (tableView == _reportsView) {
		NSString *text = [[_fetchedReportsArray objectAtIndex:indexPath.row] name];
		
		NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]}];
		
		CGRect rect = [attributedText boundingRectWithSize:(CGSize){260, CGFLOAT_MAX}
												   options:NSStringDrawingUsesLineFragmentOrigin
												   context:nil];
		return rect.size.height+25;
	}
	else return 0;
}



#pragma data / view handling

- (void)requestData {
	
	NSArray *keys = [NSArray arrayWithObjects:@"func", @"user", nil];
	NSArray *objects = [NSArray arrayWithObjects:@"priority", @"lauren", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
	
	
	NSURL *url = [NSURL URLWithString:@"http://lauren-mccarthy.com/pplkpr-server/submit.php"];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:jsonData];
	
	
	receivedData = [[NSMutableData alloc] init];
	
	NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
	if (!connection) {
		receivedData = nil;
		NSLog(@"connection failed");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Succeeded! Received %d bytes of data", [receivedData length]);
	
	NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
	_priorityData = [(NSArray *)jsonObject retain];
	NSLog(@"%@ %d",_priorityData, [_priorityData count]);
	
	connection = nil;
    receivedData = nil;
	
	[self updateView];
	
}

- (void)updateView {
	[_priorityView reloadData];
}


- (void)pushPersonViewController:(NSString *)name
{
	[[PKInteractionData data] setJumpToName:name];
	[self.tabBarController setSelectedIndex:1];
}



- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	[super dealloc];
}

@end

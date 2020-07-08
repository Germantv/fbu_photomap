//
//  PhotoMapViewController.m
//  PhotoMap
//
//  Created by emersonmalca on 7/8/18.
//  Copyright © 2018 Codepath. All rights reserved.
//

#import "PhotoMapViewController.h"
#import <MapKit/MapKit.h>
#import "LocationsViewController.h"

@interface PhotoMapViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate>

// MARK: Outlets
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

// MARK: Properties
@property (strong, nonatomic) UIImage *picture;

@end

@implementation PhotoMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    [self setInitRegion];
}

- (void)setInitRegion {
    //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:sfRegion animated:false];
}

- (IBAction)onCameraButton:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
    
}

// MARK: ImagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    //UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    self.picture = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion: ^() {
        [self performSegueWithIdentifier:@"tagSegue" sender:nil];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"tagSegue"]) {
        LocationsViewController *locationsVC = segue.destinationViewController;
        locationsVC.delegate = self;
    }
}

// MARK: LocationsProtocol
- (void)locationsViewController:(LocationsViewController *)controller didPickLocationWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude {
    
    [controller.navigationController popToViewController:self animated:YES];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    // Add annotation
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    NSString *latString =  [[NSNumber numberWithDouble: coordinate.latitude] stringValue];
    NSString *lonString =  [[NSNumber numberWithDouble: coordinate.longitude] stringValue];
    annotation.title = [NSString stringWithFormat:@"%@,%@", latString, lonString];
    [self.mapView addAnnotation:annotation];
    [self.mapView viewForAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        annotationView.canShowCallout = true;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    }

    UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    imageView.image = [UIImage imageNamed:@"camera"];

    return annotationView;
}
@end

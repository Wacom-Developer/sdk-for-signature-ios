//
//  FileBrowser.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 06/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "FileBrowser.h"
#import "UIImage+TintImage.h"

@interface FileBrowser ()

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) UIColor *tintColour;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIView *textFieldUnderline;
@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) NSString *currentDirectory;
@property (strong, nonatomic) NSArray *fileList;
@property (strong, nonatomic) NSArray *signatureExtensions;
@property (strong, nonatomic) UIImage *directoryIcon;
@property (strong, nonatomic) UIImage *textIcon;
@property (strong, nonatomic) UIImage *imageIcon;
@property (strong, nonatomic) UIImage *binaryIcon;


- (IBAction)dismissKeyboard;

- (void)updateFileList;

@end

@implementation FileBrowser


- (void)viewDidLoad {
    [super viewDidLoad];
    self.okButton.layer.cornerRadius = 5.0f;
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.tintColour = [UIColor colorWithRed:0.0f green:0.592 blue:0.831 alpha:1.0f];
    self.tableView.layer.cornerRadius = 3.0f;
    self.tableView.layer.borderColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f].CGColor;
    self.tableView.layer.borderWidth = 1.0f;
    //Tint the logo
    [self.logo setImage:[[UIImage imageNamed:@"logo_window"] tintedImageWithColour:[UIColor colorWithRed:0.4f
                                                                                                        green:0.4f
                                                                                                         blue:0.4f
                                                                                                        alpha:1.0f]]];
    self.currentDirectory = self.baseDirectory;
    self.signatureExtensions = @[@"png", @"txt", @"fss"];
    
    //Create icons for list
    self.directoryIcon = [[UIImage imageNamed:@"action_collection"] tintedImageWithColour:[UIColor colorWithRed:0.121f green:0.494f blue:0.807f alpha:1.0f]];
    self.textIcon = [[UIImage imageNamed:@"text_file"] tintedImageWithColour:[UIColor colorWithRed:0.121f green:0.494f blue:0.807f alpha:1.0f]];
    self.imageIcon = [[UIImage imageNamed:@"action_picture"] tintedImageWithColour:[UIColor colorWithRed:0.121f green:0.494f blue:0.807f alpha:1.0f]];
    self.binaryIcon = [[UIImage imageNamed:@"binary_file"] tintedImageWithColour:[UIColor colorWithRed:0.121f green:0.494f blue:0.807f alpha:1.0f]];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleLabel.text = self.titleText;
    self.inputTextField.text = self.selectedFilename;
    
    [self updateFileList];
}

- (IBAction)dismissKeyboard {
    [self.inputTextField resignFirstResponder];
}

#pragma mark - Interface methods

- (void)setSignatureTypesOnly:(BOOL)signatureTypesOnly {
    _signatureTypesOnly = signatureTypesOnly;
    [self updateFileList];
}

- (void)updateFileList {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:self.currentDirectory];
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSPredicate *extensionPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.signatureExtensions];
    
    NSString *currentFile;
    while(currentFile = [dirEnum nextObject]) {
        
        //Skip files starting '.' and subdirs
        if([currentFile characterAtIndex:0] == '.' ||  [currentFile rangeOfString:@"/"].length > 0) {
            continue;
        }
        
        if(self.signatureTypesOnly) {
            if(dirEnum.fileAttributes[NSFileType] == NSFileTypeDirectory || [extensionPredicate evaluateWithObject:[currentFile pathExtension]]) {
                NSMutableDictionary *file = [NSMutableDictionary dictionaryWithDictionary:dirEnum.fileAttributes];
                [file setObject:[currentFile pathExtension] forKey:@"PATH_EXT"];
                [file setObject:[currentFile lastPathComponent] forKey:@"FILENAME"];
                [files addObject:file];
            }
        } else {
            NSMutableDictionary *file = [NSMutableDictionary dictionaryWithDictionary:dirEnum.fileAttributes];
            [file setObject:[currentFile pathExtension] forKey:@"PATH_EXT"];
            [file setObject:[currentFile lastPathComponent] forKey:@"FILENAME"];
            [files addObject:file];
        }
    }
    //Sort file list A->Z
    
    [files sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return([obj1[@"FILENAME"] compare:obj2[@"FILENAME"] options:NSCaseInsensitiveSearch]);
    }];
    
    self.fileList = [NSArray arrayWithArray:files];
    [self.tableView reloadData];
}

#pragma mark - UITableView methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.baseDirectory isEqualToString:self.currentDirectory]) {
        return(self.fileList.count);
    } else {
        return(self.fileList.count + 1);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return(1);
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return([UIView new]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FILEBROWSER" forIndexPath:indexPath];
    NSInteger idx = [self.baseDirectory isEqualToString:self.currentDirectory] ? indexPath.row : indexPath.row - 1; //Add a ".." entry for sub dirs at the top of the list
    NSPredicate *imageExts = [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"jpg", @"png", @"bmp", @"jpeg", @"tiff", @"gif"]];
    NSPredicate *docExts = [NSPredicate predicateWithFormat:@"SELF IN %@", @[@"txt", @"doc", @"pdf", @"docx", @"pages"]];
    
    
    if(indexPath.row == 0 && ![self.baseDirectory isEqualToString:self.currentDirectory]) {
        cell.textLabel.text = @"..";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = self.directoryIcon;
    } else {
        NSDictionary *fileDetails = self.fileList[idx];
        
        if(fileDetails[NSFileType] == NSFileTypeDirectory) { //Directory
            cell.imageView.image = self.directoryIcon;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if([imageExts evaluateWithObject:fileDetails[@"PATH_EXT"]]) { //Image file
            cell.imageView.image = self.imageIcon;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if([docExts evaluateWithObject:fileDetails[@"PATH_EXT"]]) { //Txt / doc file
            cell.imageView.image = self.textIcon;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else { //Give it the binary icon
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = self.binaryIcon;
        }
        
        cell.textLabel.text = fileDetails[@"FILENAME"];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]];

    return(cell);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger fileIdx = [self.currentDirectory isEqualToString:self.baseDirectory] ? indexPath.row : indexPath.row - 1;
    [self dismissKeyboard];
    
    //Special case for ..
    if(![self.currentDirectory isEqualToString:self.baseDirectory] && indexPath.row == 0) {
        self.currentDirectory = [self.currentDirectory stringByDeletingLastPathComponent];
        [self updateFileList];
        return;
    }
    
    //If it is a directory, change to that directory
    if(self.fileList[fileIdx][NSFileType] == NSFileTypeDirectory) {
        self.currentDirectory = [self.currentDirectory stringByAppendingPathComponent:self.fileList[fileIdx][@"FILENAME"]];
        [self updateFileList];
        self.selectedFilename = @"";
    } else { //Fill in the name in the filename field
        [self.inputTextField setText:self.fileList[fileIdx][@"FILENAME"]];
        self.selectedFilename = [self.currentDirectory stringByAppendingPathComponent:self.fileList[fileIdx][@"FILENAME"]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Special case for ..
    if(![self.currentDirectory isEqualToString:self.baseDirectory] && [textField.text isEqualToString:@".."]) {
        self.currentDirectory = [self.currentDirectory stringByDeletingLastPathComponent];
        self.selectedFilename = @"";
        textField.text = @"";
        [self updateFileList];
        return(YES);
    }
    
    for(int i = 0; i < self.fileList.count; i++) {
        NSDictionary *file = self.fileList[i];
        if([file[@"FILENAME"] compare:textField.text options:NSLiteralSearch] == NSOrderedSame) {
            if(file[NSFileType] == NSFileTypeDirectory) {
                self.currentDirectory = [self.currentDirectory stringByAppendingPathComponent:textField.text];
                self.selectedFilename = @"";
                textField.text = @"";
                [self updateFileList];
            } else {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                self.selectedFilename = [self.currentDirectory stringByAppendingPathComponent:textField.text];
                [self performSegueWithIdentifier:@"UnwindFileOpen" sender:nil];
            }
            return(YES);
        }
    }
    
    //File not found. Throw warning and clear entry if open dialog otherwise set values
    if(self.isOpenDialog) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"File not found:%@", textField.text] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        self.selectedFilename = @"";
        textField.text = @"";
    } else {
        self.selectedFilename = [self.currentDirectory stringByAppendingPathComponent:textField.text];
        [self performSegueWithIdentifier:@"UnwindFileOpen" sender:nil];
    }
    
    return(YES);
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return(NO);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *textPath  = [self.currentDirectory stringByAppendingPathComponent:self.inputTextField.text];
    
    if(self.selectedFilename == nil || [self.selectedFilename compare:textPath options:NSLiteralSearch] != NSOrderedSame) {
        self.selectedFilename = textPath;
    }
}
@end
